/**
 * Created by Ronan Williams on 11/10/2018.
 */

public class SalesDashboardUtils  {

    @Future(Callout=true)
    public static void getCurrentBalance(){

        List<QBBalance__c> currentBalances = [SELECT Id FROM QBBalance__c WHERE Date__c = TODAY];

        if (currentBalances.isEmpty()) {

            // callout quickbooks for bank balance
            String query = 'query?query=select%20%2a%20from%20account%20where%20name%20' +
                    '%3d%20%27Bank%20Current%20Account%27&minorversion=4';

            // do callout
            Http http = new http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:QuickBooksOnline/' + query);
            request.setHeader('Accept', 'application/json');
            request.setMethod('GET');
            request.setTimeout(120000);

            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                JSONParserQBOCurrentAccount parsedResults = JSONParserQBOCurrentAccount.parse(response.getBody());

                Decimal currentBalance = parsedResults.QueryResponse.Account[0].CurrentBalance;
                QBBalance__c balance = new QBBalance__c(
                        Date__c         = Date.today(),
                        Confirmed__c    = currentBalance
                );

                insert balance;
            } else {

                QBBalance__c priorBalance = [SELECT Confirmed__c FROM QBBalance__c
                                             ORDER BY Date__c DESC LIMIT 1];

                Decimal currentBalance = priorBalance.Confirmed__c;
                QBBalance__c balance = new QBBalance__c(
                        Date__c         = Date.today(),
                        Confirmed__c    = currentBalance
                );

                insert balance;
            }
        }
    }

    public static void createSnapshots(){

        List<SalesDashboardSnapshot__c> snapshots = new List<SalesDashboardSnapshot__c>();

        Date currentFYEnd   = Date.newInstance(Date.today().year(), 03, 31);
        Date nextFYEnd      = Date.newInstance(Date.today().addYears(1).year(), 03, 31);

        if (Date.today().month() > 3){
            currentFYEnd    = currentFYEnd.addYears(1);
            nextFYEnd       = nextFYEnd.addYears(1);
        }

        snapshots.add(new SalesDashboardSnapshot__c(PeriodEnd__c  = currentFYEnd));
        snapshots.add(new SalesDashboardSnapshot__c(PeriodEnd__c  = nextFYEnd));

        List<SalesDashboardSnapshot__c> duplicates = [SELECT Id FROM SalesDashboardSnapshot__c
                                                        WHERE CreatedDate = TODAY
                                                        AND (PeriodEnd__c = :currentFYEnd
                                                        OR PeriodEnd__c = :nextFYEnd)];

        delete duplicates;

        // line up current FY snapshots
        for (SalesDashboardSnapshot__c snapshot : snapshots) {

            Date startDate = snapshot.PeriodEnd__c.addYears(-1).addDays(1);
            Date endDate   = snapshot.PeriodEnd__c;

            Map<String,Object> oppRecords       = InsightsController.getOppRecords(String.valueOf(startDate), String.valueOf(endDate));
            List<String> months                 = (List<String>)oppRecords.get('MONTHS');
            Map<String,List<Decimal>> revenue   = (Map<String,List<Decimal>>)oppRecords.get('revenue');
            Map<String,List<Decimal>> profit    = (Map<String,List<Decimal>>)oppRecords.get('profit');
            Map<String,List<Decimal>> opex      = (Map<String,List<Decimal>>)oppRecords.get('opex');
            Map<String,Decimal> totals          = (Map<String,Decimal>)oppRecords.get('TOTALS');

            for (Integer x = 0; x < 12; x++) {
                snapshot.put('RevConf' + (x + 1) + '__c', revenue.get(months[x])[0]);
                snapshot.put('RevWeighted' + (x + 1) + '__c', revenue.get(months[x])[1]);
                snapshot.put('RevPipeline' + (x + 1) + '__c', revenue.get(months[x])[2]);
                snapshot.put('RevTarget' + (x + 1) + '__c', revenue.get(months[x])[3]);

                snapshot.put('GPConf' + (x + 1) + '__c', profit.get(months[x])[0]);
                snapshot.put('GPWeighted' + (x + 1) + '__c', profit.get(months[x])[1]);
                snapshot.put('GPPipeline' + (x + 1) + '__c', profit.get(months[x])[2]);

                snapshot.put('Opex' + (x + 1) + '__c', opex.get(months[x])[1]);
                snapshot.put('Budget' + (x + 1) + '__c', opex.get(months[x])[2]);
            }

            snapshot.TotalRevenue__c        = totals.get('revenue');
            snapshot.TotalGrossProfit__c    = totals.get('profit');
            snapshot.TotalOpex__c           = totals.get('opex');
            snapshot.TotalNetProfit__c      = totals.get('netProfit');


            List<SalesDashboardSnapshot__c> priorSnaps =
                                                [SELECT TotalRevenue__c, TotalGrossProfit__c, TotalOpex__c, TotalNetProfit__c
                                                FROM SalesDashboardSnapshot__c
                                                WHERE DateCreated__c = :Date.today().addDays(-7)
                                                AND PeriodEnd__c = :endDate
                                                ORDER BY CreatedDate DESC LIMIT 1];

            if (priorSnaps.isEmpty()){
                snapshot.TotalRevenue__c        = totals.get('revenue');
                snapshot.TotalGrossProfit__c    = totals.get('profit');
                snapshot.TotalOpex__c           = totals.get('opex');
                snapshot.TotalNetProfit__c      = totals.get('netProfit');
            } else {
                snapshot.PriorRevenue__c        = priorSnaps[0].TotalRevenue__c;
                snapshot.PriorGrossProfit__c    = priorSnaps[0].TotalGrossProfit__c;
                snapshot.PriorOpex__c           = priorSnaps[0].TotalOpex__c;
                snapshot.PriorNetProfit__c      = priorSnaps[0].TotalNetProfit__c;
            }
        }

        insert snapshots;

    }

    public static void commitOpportunities(Date commitMonth){

        QBClosedMonth__c month = QBClosedMonth__c.getInstance('SFCommitMonth');
        commitMonth = commitMonth.addMonths(1).toStartOfMonth().addDays(-1);

        List<Opportunity> priorOpportunities = [SELECT Id, Event_end__c, Amount_Calder__c, Gross_profit_2__c,
                                                        Filtered_Cost_of_Sale__c
                                                FROM Opportunity
                                                WHERE StageName = 'Closed Won'
                                                AND Event_end__c <= :commitMonth
                                                AND Committed__c = FALSE
                                                ORDER BY Event_end__c DESC];

        for (Opportunity opp : priorOpportunities){
            opp.Committed__c        = true;
            // if the opportunity falls in the prior month
            if (opp.Event_end__c >= month.Month__c.toStartOfMonth()){
                opp.CommittedRevenue__c = opp.Amount_Calder__c;
                opp.CommittedProfit__c  = opp.Gross_profit_2__c;
                opp.CommittedCOS__c     = opp.Filtered_Cost_of_Sale__c;
            } else {
                // if the opportunity is earlier than the prior month
                opp.CommittedRevenue__c = 0;
                opp.CommittedProfit__c  = 0;
                opp.CommittedCOS__c     = 0;
            }
        }

        update priorOpportunities;

        List<Adjustment__c> priorAdjustments = [SELECT Id FROM Adjustment__c
                                                WHERE Month__c <= :commitMonth
                                                AND Committed__c = FALSE];

        for (Adjustment__c adj : priorAdjustments){
            adj.Committed__c = true;
        }

        update priorAdjustments;

        month.Month__c = commitMonth;
        update month;


    }


    public static void adjustOpportunities(){

        Map<Id,Opportunity> adjustedOpps =
                new Map<Id,Opportunity>([SELECT Id FROM Opportunity
                                        WHERE Committed__c = TRUE
                                        AND LastModifiedDate > :Datetime.now().addDays(-3)]);

        if (!adjustedOpps.isEmpty()) {

            Map<Id, Adjustment__c> adjustmentMap = new Map<Id, Adjustment__c>();

            for (Adjustment__c adj : [
                    SELECT Id, Revenue__c, Profit__c, CostOfSale__c, Opportunity__c
                    FROM Adjustment__c
                    WHERE Committed__c = FALSE]) {
                adjustmentMap.put(adj.Opportunity__c, adj);
            }

            for (Opportunity opp : [
                    SELECT Id, Amount_Calder__c, Gross_profit_2__c,
                            CommittedRevenue__c, CommittedProfit__c, CommittedCOS__c,
                            Filtered_Cost_of_Sale__c, Event_end__c,
                            (SELECT Id, Revenue__c, Profit__c, CostOfSale__c FROM Adjustments__r
                            WHERE Committed__c = TRUE)
                    FROM Opportunity
                    WHERE Id IN :adjustedOpps.keySet()]) {

                Decimal committedRevenue = opp.CommittedRevenue__c;
                Decimal committedProfit  = opp.CommittedProfit__c;
                Decimal committedCOS     = opp.CommittedCOS__c;

                for (Adjustment__c adj : opp.Adjustments__r){
                    committedRevenue += adj.Revenue__c;
                    committedProfit  += adj.Profit__c;
                    committedCOS     += adj.CostOfSale__c;
                }

                if (opp.Amount_Calder__c != committedRevenue || opp.Gross_profit_2__c != committedProfit
                        || opp.Filtered_Cost_of_Sale__c != committedCOS) {
                    if (adjustmentMap.containsKey(opp.Id)) {
                        adjustmentMap.get(opp.Id).Revenue__c    = (opp.Amount_Calder__c - committedRevenue);
                        adjustmentMap.get(opp.Id).Profit__c     = (opp.Gross_profit_2__c - committedProfit);
                        adjustmentMap.get(opp.Id).CostOfSale__c = (opp.Filtered_Cost_of_Sale__c - committedCOS);

                    } else {
                        // this is a concession for adjustments to old jobs which were never set as
                        // reconciliation complete. This clause prevents adjustments from these old jobs from created
                        // unwanted adjustments in the current financial period
                        if (opp.Event_end__c < Date.newInstance(2018,04,01)){

                            adjustmentMap.put(opp.Id, new Adjustment__c(
                                    Opportunity__c  = opp.Id,
                                    Revenue__c      = (opp.Amount_Calder__c - committedRevenue),
                                    Profit__c       = (opp.Gross_profit_2__c - committedProfit),
                                    CostOfSale__c   = (opp.Filtered_Cost_of_Sale__c - committedCOS),
                                    Committed__c    = true
                            ));

                        } else {
                            adjustmentMap.put(opp.Id, new Adjustment__c(
                                    Opportunity__c  = opp.Id,
                                    Month__c        = Date.today().toStartOfMonth(),
                                    Revenue__c      = (opp.Amount_Calder__c - committedRevenue),
                                    Profit__c       = (opp.Gross_profit_2__c - committedProfit),
                                    CostOfSale__c   = (opp.Filtered_Cost_of_Sale__c - committedCOS)
                            ));
                        }
                    }
                }
            }

            upsert adjustmentMap.values();
        }
    }

    public static void adjustCalderCommissions(){

        List<AggregateResult> revenueAggregates =
                                            [SELECT SUM(Amount) amount,
                                                    FISCAL_MONTH(Event_end__c) month
                                            FROM Opportunity
                                            WHERE StageName = 'Closed Won'
                                            AND Calder_Opportunity__c = TRUE
                                            AND ((Event_end__c = THIS_FISCAL_YEAR
                                                AND Event_month__c != 3) OR
                                                (Event_end__c = LAST_FISCAL_YEAR
                                                AND Event_month__c = 3))
                                            GROUP BY FISCAL_MONTH(Event_end__c)
                                            ORDER BY FISCAL_MONTH(Event_end__c) ASC];

        List<AggregateResult> commissionAggregates =
                                            [SELECT SUM(Revenue__c) amount
                                            FROM Adjustment__c
                                            WHERE Calder__c = TRUE
                                            AND Month__c = THIS_FISCAL_YEAR
                                            AND Month__c <= LAST_MONTH];

        Decimal runningRevenueTotal     = 0;
        Decimal runningCommissionTotal  = 0;

        Map<Integer,Decimal> revenueMap = new Map<Integer,Decimal>();

        for (AggregateResult ar : revenueAggregates){

            system.debug('for month ' + (Integer)ar.get('month') + ' the revenue is ' + (Decimal)ar.get('amount'));
            runningRevenueTotal += (Decimal)ar.get('amount');
            Integer month = (Integer)ar.get('month');

            while (month < 13){
                revenueMap.put(month,runningRevenueTotal);
                month = month + 1;
            }
        }

        if (commissionAggregates[0].get('amount') != null){
            runningCommissionTotal += ((Decimal)commissionAggregates[0].get('amount') * -1);
        }

        Map<Date, Adjustment__c> calderAdjustments = new Map<Date, Adjustment__c>();

        for (Adjustment__c adj : [SELECT Id, Committed__c, Revenue__c, CostOfSale__c, Profit__c, Month__c
                                FROM Adjustment__c
                                WHERE Month__c = THIS_FISCAL_YEAR
                                AND Calder__c  = TRUE]){
            calderAdjustments.put(adj.Month__c, adj);
        }

        Date startingDate = Date.today().toStartOfMonth();
        Date endingDate = (startingDate.month() < 4) ?
                Date.newInstance(Date.today().year(), 04, 01) :
                Date.newInstance(Date.today().year() + 1, 04, 01);


        while (startingDate < endingDate){

            Integer financialMonth = (startingDate.month() < 4) ? startingDate.month() + 9 : startingDate.month() - 3;

            if (revenueMap.get(financialMonth) > 750000){

                Decimal total = revenueMap.get(financialMonth) - 750000;
                Decimal commission = (total * 0.05) + (350000 * 0.025);
                Decimal owing = commission - runningCommissionTotal;

                runningCommissionTotal += owing;

                if (!calderAdjustments.containsKey(startingDate)){
                    calderAdjustments.put(startingDate, new Adjustment__c(
                            Calder__c = true,
                            Month__c = startingDate));
                }

                calderAdjustments.get(startingDate).Revenue__c = (owing * -1);
                calderAdjustments.get(startingDate).Profit__c = (owing * -1);
                calderAdjustments.get(startingDate).CostOfSale__c = 0;

            } else if (revenueMap.get(financialMonth) > 400000){

                Decimal total = revenueMap.get(financialMonth) - 400000;
                Decimal commission = total * 0.025;
                Decimal owing = commission - runningCommissionTotal;
                runningCommissionTotal += owing;

                if (!calderAdjustments.containsKey(startingDate)){
                    calderAdjustments.put(startingDate, new Adjustment__c(
                            Calder__c = true,
                            Month__c = startingDate));
                }

                calderAdjustments.get(startingDate).Revenue__c = (owing * -1);
                calderAdjustments.get(startingDate).Profit__c = (owing * -1);
                calderAdjustments.get(startingDate).CostOfSale__c = 0;

            }

            startingDate = startingDate.addMonths(1);
        }

        upsert calderAdjustments.values();

    }

}