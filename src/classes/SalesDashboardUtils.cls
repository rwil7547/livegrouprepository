/**
 * Created by Ronan Williams on 11/10/2018.
 */

public class SalesDashboardUtils {

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

            Map<String, List<Decimal>> currentFYRevenue =
                    SalesDashboardRemoter.getOppRevenueTotals(String.valueOf(startDate), String.valueOf(endDate));

            Map<String, List<Decimal>> currentFYProfit =
                    SalesDashboardRemoter.getOppProfitTotals(String.valueOf(startDate), String.valueOf(endDate));

            Map<String, List<Decimal>> currentFYOpex =
                    SalesDashboardRemoter.getOperatingCosts(String.valueOf(startDate), String.valueOf(endDate));

            Map<Date, List<Object>> balances =
                    SalesDashboardRemoter.getBalances(String.valueOf(startDate), String.valueOf(endDate));

            List<String> months = new List<String>(currentFYRevenue.keySet());

            for (Integer x = 0; x < 12; x++) {
                snapshot.put('RevConf' + (x + 1) + '__c', currentFYRevenue.get(months[x])[0]);
                snapshot.put('RevWeighted' + (x + 1) + '__c', currentFYRevenue.get(months[x])[1]);
                snapshot.put('RevPipeline' + (x + 1) + '__c', currentFYRevenue.get(months[x])[2]);
                snapshot.put('RevTarget' + (x + 1) + '__c', currentFYRevenue.get(months[x])[3]);

                snapshot.put('GPConf' + (x + 1) + '__c', currentFYProfit.get(months[x])[0]);
                snapshot.put('GPWeighted' + (x + 1) + '__c', currentFYProfit.get(months[x])[1]);
                snapshot.put('GPPipeline' + (x + 1) + '__c', currentFYProfit.get(months[x])[2]);

                snapshot.put('Opex' + (x + 1) + '__c', currentFYOpex.get(months[x])[0] + currentFYOpex.get(months[x])[1]);
                snapshot.put('Budget' + (x + 1) + '__c', currentFYOpex.get(months[x])[3]);
            }

            for (Date balDate : balances.keySet()){

                Decimal balOne      = (balances.get(balDate)[1] == null) ? 0 : ((Decimal)balances.get(balDate)[1]).setScale(2);
                Decimal balTwo      = (balances.get(balDate)[2] == null) ? 0 : ((Decimal)balances.get(balDate)[2]).setScale(2);
                Decimal balThree    = (balances.get(balDate)[3] == null) ? 0 : ((Decimal)balances.get(balDate)[3]).setScale(2);
                Decimal balFour     = (balances.get(balDate)[4] == null) ? 0 : ((Decimal)balances.get(balDate)[4]).setScale(2);

                snapshot.Balance__c += ':' + balances.get(balDate)[0] +
                        ' *' + balOne +
                        ' *' + balTwo +
                        ' *' + balThree +
                        ' *' + balFour + ' ';
            }

            List<Decimal> totals = SalesDashboardRemoter.getHeadlineTotals(String.valueOf(startDate), String.valueOf(endDate));
            snapshot.TotalRevenue__c        = totals[0];
            snapshot.TotalGrossProfit__c    = totals[1];
            snapshot.TotalOpex__c           = totals[2];
            snapshot.TotalNetProfit__c      = totals[3];


            List<SalesDashboardSnapshot__c> priorSnaps =
                                                [SELECT TotalRevenue__c, TotalGrossProfit__c, TotalOpex__c, TotalNetProfit__c
                                                FROM SalesDashboardSnapshot__c
                                                WHERE DateCreated__c = :Date.today().addDays(-7)
                                                AND PeriodEnd__c = :endDate
                                                ORDER BY CreatedDate DESC LIMIT 1];

            if (priorSnaps.isEmpty()){
                snapshot.PriorRevenue__c        = totals[0];
                snapshot.PriorGrossProfit__c    = totals[1];
                snapshot.PriorOpex__c           = totals[2];
                snapshot.PriorNetProfit__c      = totals[3];
            } else {
                snapshot.PriorRevenue__c        = priorSnaps[0].TotalRevenue__c;
                snapshot.PriorGrossProfit__c    = priorSnaps[0].TotalGrossProfit__c;
                snapshot.PriorOpex__c           = priorSnaps[0].TotalOpex__c;
                snapshot.PriorNetProfit__c      = priorSnaps[0].TotalNetProfit__c;
            }
        }

        insert snapshots;

    }

    public static void commitOpportunites(){

        List<Opportunity> priorOpportunities = [SELECT Id, Amount_Calder__c, Gross_profit_2__c,
                                                        Filtered_Cost_of_Sale__c
                                                FROM Opportunity
                                                WHERE StageName = 'Closed Won'
                                                AND Event_end__c < :Date.today().toStartOfMonth()
                                                AND Committed__c = FALSE
                                                ORDER BY Event_end__c DESC];

        for (Opportunity opp : priorOpportunities){
            opp.Committed__c        = true;
            opp.CommittedRevenue__c = opp.Amount_Calder__c;
            opp.CommittedProfit__c  = opp.Gross_profit_2__c;
            opp.CommittedCOS__c     = opp.Filtered_Cost_of_Sale__c;
        }

        update priorOpportunities;

        List<Adjustment__c> priorAdjustments = [SELECT Id FROM Adjustment__c
                                                WHERE Month__c < :Date.today().toStartOfMonth()
                                                AND Committed__c = FALSE];

        for (Adjustment__c adj : priorAdjustments){
            adj.Committed__c = true;
        }

        update priorAdjustments;

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
                                            AND Event_end__c = THIS_FISCAL_YEAR
                                            GROUP BY FISCAL_MONTH(Event_end__c)
                                            ORDER BY FISCAL_MONTH(Event_end__c) ASC];

        List<AggregateResult> commissionAggregates =
                                            [SELECT SUM(Revenue__c) amount,
                                                    FISCAL_MONTH(Month__c) month
                                            FROM Adjustment__c
                                            WHERE Calder__c = TRUE
                                            AND Month__c = THIS_FISCAL_YEAR
                                            AND Month__c <= LAST_MONTH
                                            GROUP BY FISCAL_MONTH(Month__c)
                                            ORDER BY FISCAL_MONTH(Month__c) ASC];

        Decimal runningRevenueTotal     = 0;
        Decimal runningCommissionTotal  = 0;

        Map<Integer,Decimal> revenueMap = new Map<Integer,Decimal>();

        for (Integer x = 1; x < 13; x++){
            revenueMap.put(x,0);
        }

        for (AggregateResult ar : revenueAggregates){
            runningRevenueTotal += (Decimal)ar.get('amount');
            revenueMap.put((Integer)ar.get('month'),runningRevenueTotal);
        }

        for (AggregateResult ar : commissionAggregates){
            runningCommissionTotal += (Decimal)ar.get('amount');
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

            System.debug('iterating over date ' + startingDate + ' and value is ' + revenueMap.get(startingDate.month()));

            if (revenueMap.get(startingDate.month()) > 750000){

                Decimal total = revenueMap.get(startingDate.month()) - 750000;
                Decimal commission = total * 0.05;
                Decimal owing = commission - runningCommissionTotal;
                runningCommissionTotal += owing;

                if (!calderAdjustments.containsKey(startingDate)){
                    calderAdjustments.put(startingDate, new Adjustment__c(
                            Calder__c = true,
                            Month__c = startingDate));
                }

                calderAdjustments.get(startingDate).Revenue__c = (owing * -1);

            } else if (revenueMap.get(startingDate.month()) > 400000){

                Decimal total = revenueMap.get(startingDate.month()) - 400000;
                Decimal commission = total * 0.025;
                Decimal owing = commission - runningCommissionTotal;
                runningCommissionTotal += owing;

                if (!calderAdjustments.containsKey(startingDate)){
                    calderAdjustments.put(startingDate, new Adjustment__c(
                            Calder__c = true,
                            Month__c = startingDate));
                }

                calderAdjustments.get(startingDate).Revenue__c = (owing * -1);

            }

            startingDate = startingDate.addMonths(1);
        }

        for (Date d : calderAdjustments.keySet()){
            System.debug('month entry is ' + calderAdjustments.get(d));
        }

        ///upsert calderAdjustments.values();

    }

}