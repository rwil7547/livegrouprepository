/**
 * Created by Ronan Williams on 17/09/2018.
 */

global class SalesDashboardRemoter {

    private static Map<String,List<Decimal>> buildMap(String start, String endD){

        Date startDate      = Date.valueOf(start);
        Date endDate        = Date.valueOf(endD);

        Map<Integer,String> monthsMap = new Map<Integer,String>();
        monthsMap.put(1, 'Jan');
        monthsMap.put(2, 'Feb');
        monthsMap.put(3, 'Mar');
        monthsMap.put(4, 'Apr');
        monthsMap.put(5, 'May');
        monthsMap.put(6, 'Jun');
        monthsMap.put(7, 'Jul');
        monthsMap.put(8, 'Aug');
        monthsMap.put(9, 'Sep');
        monthsMap.put(10, 'Oct');
        monthsMap.put(11, 'Nov');
        monthsMap.put(12, 'Dec');

        Map<String,List<Decimal>> objectAggregates = new Map<String,List<Decimal>>();

        Date incrementDate = startDate;

        List<String> months = new List<String>();

        while (incrementDate < endDate.addMonths(1).toStartOfMonth().addDays(-1)){

            objectAggregates.put(monthsMap.get(incrementDate.month()) + ' ' +
                    incrementDate.year(), new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0,0,0});

            months.add(monthsMap.get(incrementDate.month()) + ' ' +
                    incrementDate.year());

            incrementDate = incrementDate.addMonths(1);
        }

        return objectAggregates;

    }

    private static void calculateBalances(){

        Decimal balance         = 0;
        Decimal balancePlus     = 0;
        Decimal balancePredict  = 0;

        List<CashFlow__c> cashFlows = [SELECT Date__c, In__c, InPlus__c, InPredict__c, Out__c, OutPlus__c,OutPredict__c
        FROM CashFlow__c ORDER BY Date__c ASC];

        for (CashFlow__c flow : cashFlows){

            balance += (flow.In__c - flow.Out__c);
            balancePlus += (flow.In__c + flow.InPlus__c - flow.Out__c - flow.OutPlus__c);
            balancePredict += (flow.In__c + flow.InPlus__c + flow.InPredict__c - flow.Out__c - flow.OutPlus__c - flow.OutPredict__c);
            flow.Balance__c = balance;
            flow.BalancePlus__c = balancePlus;
            flow.BalancePredict__c = balancePredict;
        }

        update cashFlows;

    }

    @RemoteAction
    global static Map<String,List<Decimal>> getOppRevenueTotals(String start, String endD){

        Date startDate      = Date.valueOf(start);
        Date endDate        = Date.valueOf(endD);

        Map<String,List<Decimal>> revenueAggregates = buildMap(start,endD);

        List<String> months = new List<String>();
        months.addAll(revenueAggregates.keySet());

        for (Opportunity opp : [SELECT Amount_Calder__c, Probability, Event_End_Grouping__c, StageName,
                                    EventMonthYear__c, Committed__c, CommittedRevenue__c
                                FROM Opportunity
                                WHERE StageName != 'Closed Lost'
                                AND Event_end__c >= :startDate
                                AND Event_end__c <= :endDate]){

            if (opp.Committed__c){
                revenueAggregates.get(opp.EventMonthYear__c)[0] += opp.CommittedRevenue__c;
            } else if (opp.StageName == 'Closed Won') {
                revenueAggregates.get(opp.EventMonthYear__c)[0] += opp.Amount_Calder__c;
            } else {
                revenueAggregates.get(opp.EventMonthYear__c)[1] += (opp.Amount_Calder__c * opp.Probability) / 100;
                revenueAggregates.get(opp.EventMonthYear__c)[2] += opp.Amount_Calder__c - (opp.Amount_Calder__c * opp.Probability) / 100;
            }
        }

        for (Adjustment__c adj : [SELECT Revenue__c, EventMonthYear__c
                                  FROM Adjustment__c
                                  WHERE Month__c >= :startDate
                                  AND Month__c <= :endDate]) {
            revenueAggregates.get(adj.EventMonthYear__c)[0] += adj.Revenue__c;
        }

        List<SalesTarget__c> targets = [SELECT Revenue__c, EventMonthYear__c
                                        FROM SalesTarget__c
                                        WHERE Month__c >= :startDate
                                        AND Month__c <= :endDate];

        for (SalesTarget__c target : [SELECT Revenue__c, EventMonthYear__c
                                        FROM SalesTarget__c
                                        WHERE Month__c >= :startDate
                                        AND Month__c <= :endDate]) {

            revenueAggregates.get(target.EventMonthYear__c)[3] = target.Revenue__c;
        }

        for (Integer x = 0; x < months.size(); x++){

            revenueAggregates.get(months[x])[4] += revenueAggregates.get(months[x])[0];
            revenueAggregates.get(months[x])[5] += revenueAggregates.get(months[x])[0];
            revenueAggregates.get(months[x])[6] += revenueAggregates.get(months[x])[0];
            revenueAggregates.get(months[x])[5] += revenueAggregates.get(months[x])[1];
            revenueAggregates.get(months[x])[6] += revenueAggregates.get(months[x])[2] + revenueAggregates.get(months[x])[1];

            Integer y = months.size() -1;

            while (y > x){
                revenueAggregates.get(months[y])[3] += (targets.size() > x) ? targets[x].Revenue__c : revenueAggregates.get(months[x])[3];
                revenueAggregates.get(months[y])[4] += revenueAggregates.get(months[x])[0];
                revenueAggregates.get(months[y])[5] += revenueAggregates.get(months[x])[0];
                revenueAggregates.get(months[y])[6] += revenueAggregates.get(months[x])[0];
                revenueAggregates.get(months[y])[5] += revenueAggregates.get(months[x])[1];
                revenueAggregates.get(months[y])[6] += revenueAggregates.get(months[x])[2] + revenueAggregates.get(months[x])[1];
                y--;
            }
        }

        return revenueAggregates;
    }

    @RemoteAction
    global static Map<String,List<Decimal>> getOppInvoiceTotals(String start, String endD){

        Date startDate      = Date.valueOf(start);
        Date endDate        = Date.valueOf(endD);

        Map<String,List<Decimal>> revenueAggregates = buildMap(start,endD);

        List<String> months = new List<String>();
        months.addAll(revenueAggregates.keySet());

        for (Opportunity opp : [SELECT EventMonthYear__c, Amount_Calder__c, Amount_Invoiced2__c,
                                        Amount_Paid__c, Filtered_Cost_of_Sale__c, Quickbooks_COS__c, Quickbooks_COS_Paid__c
                                FROM Opportunity
                                WHERE StageName = 'Closed Won'
                                AND Event_end__c >= :startDate
                                AND Event_end__c <= :endDate]){

            revenueAggregates.get(opp.EventMonthYear__c)[0] += opp.Amount_Paid__c;
            revenueAggregates.get(opp.EventMonthYear__c)[1] += (opp.Amount_Invoiced2__c - opp.Amount_Paid__c);
            revenueAggregates.get(opp.EventMonthYear__c)[2] += (opp.Amount_Calder__c - opp.Amount_Invoiced2__c);
            revenueAggregates.get(opp.EventMonthYear__c)[3] += opp.Quickbooks_COS_Paid__c;
            revenueAggregates.get(opp.EventMonthYear__c)[4] += (opp.Quickbooks_COS__c - opp.Quickbooks_COS_Paid__c);
            revenueAggregates.get(opp.EventMonthYear__c)[5] += (opp.Filtered_Cost_of_Sale__c - opp.Quickbooks_COS__c);
        }

        return revenueAggregates;
    }

    @RemoteAction
    global static Map<String,List<Decimal>> getOppTypeTotals(String start, String endD){

        Date startDate      = Date.valueOf(start);
        Date endDate        = Date.valueOf(endD);

        Map<String,List<Decimal>> oppTypeAggregates = buildMap(start,endD);

        List<String> months = new List<String>();
        months.addAll(oppTypeAggregates.keySet());

        for (Opportunity opp : [SELECT EventMonthYear__c, Amount_Calder__c, Amount_Invoiced2__c,
                                        Amount_Paid__c, Gross_profit_2__c, Gross_Margin__c,
                                        Filtered_Cost_of_Sale__c, StageName, Committed__c,
                                        CommittedRevenue__c, CommittedProfit__c
                                FROM Opportunity
                                WHERE StageName != 'Closed Lost'
                                AND Event_end__c >= :startDate
                                AND Event_end__c <= :endDate]){

            if (opp.Committed__c){
                oppTypeAggregates.get(opp.EventMonthYear__c)[0] += opp.CommittedRevenue__c;
                oppTypeAggregates.get(opp.EventMonthYear__c)[4] += opp.CommittedProfit__c;
                oppTypeAggregates.get(opp.EventMonthYear__c)[8] += (opp.CommittedRevenue__c - opp.CommittedProfit__c);
            } else if (opp.StageName == 'Closed Won') {
                oppTypeAggregates.get(opp.EventMonthYear__c)[0] += opp.Amount_Calder__c;
                oppTypeAggregates.get(opp.EventMonthYear__c)[4] += opp.Gross_profit_2__c;
                oppTypeAggregates.get(opp.EventMonthYear__c)[8] += opp.Filtered_Cost_of_Sale__c;
            } else if (opp.StageName == 'Costed prospect'){
                oppTypeAggregates.get(opp.EventMonthYear__c)[1] += opp.Amount_Calder__c;
                oppTypeAggregates.get(opp.EventMonthYear__c)[5] += opp.Gross_profit_2__c;
                oppTypeAggregates.get(opp.EventMonthYear__c)[9] += opp.Filtered_Cost_of_Sale__c;
            } else if (opp.StageName == 'Pipeline prospect'){
                oppTypeAggregates.get(opp.EventMonthYear__c)[2] += opp.Amount_Calder__c;
                oppTypeAggregates.get(opp.EventMonthYear__c)[6] += opp.Gross_profit_2__c;
                oppTypeAggregates.get(opp.EventMonthYear__c)[10] += opp.Filtered_Cost_of_Sale__c;
            } else if (opp.StageName == 'Repeat Prospect'){
                oppTypeAggregates.get(opp.EventMonthYear__c)[3] += opp.Amount_Calder__c;
                oppTypeAggregates.get(opp.EventMonthYear__c)[7] += opp.Gross_profit_2__c;
                oppTypeAggregates.get(opp.EventMonthYear__c)[11] += opp.Filtered_Cost_of_Sale__c;
            }
        }

        for (Adjustment__c adj : [SELECT Revenue__c, Profit__c, EventMonthYear__c
                                  FROM Adjustment__c
                                  WHERE Month__c >= :startDate
                                  AND Month__c <= :endDate]) {
            oppTypeAggregates.get(adj.EventMonthYear__c)[0] += adj.Revenue__c;
            oppTypeAggregates.get(adj.EventMonthYear__c)[4] += adj.Profit__c;
            oppTypeAggregates.get(adj.EventMonthYear__c)[8] += (adj.Revenue__c - adj.Profit__c);
        }

        return oppTypeAggregates;
    }

    @RemoteAction
    global static Map<String,List<Decimal>> getOppProfitTotals(String start, String endD){

        Date startDate      = Date.valueOf(start);
        Date endDate        = Date.valueOf(endD);

        Map<String,List<Decimal>> profitAggregates = buildMap(start,endD);

        List<String> months = new List<String>();
        months.addAll(profitAggregates.keySet());

        for (Opportunity opp : [SELECT Gross_profit_2__c, Probability, Event_End_Grouping__c, StageName,
                                        EventMonthString__c, EventMonthYear__c, Committed__c, CommittedProfit__c
                                FROM Opportunity
                                WHERE StageName != 'Closed Lost'
                                AND Event_end__c >= :startDate
                                AND Event_end__c <= :endDate]){

            if (opp.Committed__c){
                profitAggregates.get(opp.EventMonthYear__c)[0] += opp.CommittedProfit__c;
            } else if (opp.StageName == 'Closed Won') {
                profitAggregates.get(opp.EventMonthYear__c)[0] += opp.Gross_profit_2__c;
            } else {
                profitAggregates.get(opp.EventMonthYear__c)[1] += (opp.Gross_profit_2__c * opp.Probability) / 100;
                profitAggregates.get(opp.EventMonthYear__c)[2] += opp.Gross_profit_2__c - (opp.Gross_profit_2__c * opp.Probability) / 100;
            }
        }

        for (Adjustment__c adj : [SELECT Profit__c, EventMonthYear__c
                                  FROM Adjustment__c
                                  WHERE Month__c >= :startDate
                                  AND Month__c <= :endDate]) {
            profitAggregates.get(adj.EventMonthYear__c)[0] += adj.Profit__c;
        }

        for (Integer x = 0; x < months.size(); x++){

            profitAggregates.get(months[x])[4] += profitAggregates.get(months[x])[0];
            profitAggregates.get(months[x])[5] += profitAggregates.get(months[x])[0];
            profitAggregates.get(months[x])[6] += profitAggregates.get(months[x])[0];
            profitAggregates.get(months[x])[5] += profitAggregates.get(months[x])[1];
            profitAggregates.get(months[x])[6] += profitAggregates.get(months[x])[2] + profitAggregates.get(months[x])[1];

            Integer y = months.size() -1;

            while (y > x){
                profitAggregates.get(months[y])[4] += profitAggregates.get(months[x])[0];
                profitAggregates.get(months[y])[5] += profitAggregates.get(months[x])[0];
                profitAggregates.get(months[y])[6] += profitAggregates.get(months[x])[0];
                profitAggregates.get(months[y])[5] += profitAggregates.get(months[x])[1];
                profitAggregates.get(months[y])[6] += profitAggregates.get(months[x])[2] + profitAggregates.get(months[x])[1];
                y--;
            }
        }

        return profitAggregates;
    }

    @RemoteAction
    global static Map<String,List<Decimal>> getOperatingCosts(String start, String endD){

        Date startDate      = Date.valueOf(start);
        Date endDate        = Date.valueOf(endD);

        // work out if start date and end date are not clean start and end dates
        Decimal numberOfDaysStart   = Date.daysInMonth(startDate.year(), startDate.month());
        Decimal daysMissing         = startDate.day() - 1;
        Decimal startPortion        = (numberOfDaysStart - daysMissing) / numberOfDaysStart;

        Decimal numberOfDaysEnd     = Date.daysInMonth(endDate.year(), endDate.month());
        Decimal dayCountEnd         = endDate.day();
        Decimal endPortion          = (numberOfDaysEnd - (numberOfDaysEnd - dayCountEnd)) / numberOfDaysEnd;


        Map<String,List<Decimal>> opexAggregates = buildMap(start,endD);

        List<String> months = new List<String>();
        months.addAll(opexAggregates.keySet());

        List<QBProfitAndLoss__c> results = [SELECT Actual__c, Budget__c, Grouping__c,
                                                Month__c, EventMonthYear__c, QBUpdated__c
                                            FROM QBProfitAndLoss__c
                                            WHERE Month__c >= :startDate.toStartOfMonth()
                                            AND Month__c <= :endDate
                                            AND Opex__c = TRUE
                                            ORDER BY Month__c DESC];

        for (QBProfitAndLoss__c qpl : results) {

            Decimal multiplier = 1;

            if (qpl.Month__c.month() == startDate.month()) {
                multiplier = startPortion;
            } else if (qpl.Month__c.month() == endDate.month()) {
                multiplier = endPortion;
            }

            if (qpl.QBUpdated__c) {
                opexAggregates.get(qpl.EventMonthYear__c)[0] += (qpl.Actual__c * multiplier);
            } else {
                opexAggregates.get(qpl.EventMonthYear__c)[1] += (qpl.Actual__c * multiplier);
            }
            opexAggregates.get(qpl.EventMonthYear__c)[2] += ((qpl.Budget__c - qpl.Actual__c) * multiplier);
            opexAggregates.get(qpl.EventMonthYear__c)[3] += (qpl.Budget__c * multiplier);

            if (qpl.Grouping__c == 'Payroll'){
                opexAggregates.get(qpl.EventMonthYear__c)[6] += (qpl.Actual__c * multiplier);
            } else if (qpl.Grouping__c == 'IT'){
                opexAggregates.get(qpl.EventMonthYear__c)[7] += (qpl.Actual__c * multiplier);
            } else if (qpl.Grouping__c == 'Bus Dev'){
                opexAggregates.get(qpl.EventMonthYear__c)[8] += (qpl.Actual__c * multiplier);
            } else if (qpl.Grouping__c == 'Office'){
                opexAggregates.get(qpl.EventMonthYear__c)[9] += (qpl.Actual__c * multiplier);
            } else if (qpl.Grouping__c == 'Other'){
                opexAggregates.get(qpl.EventMonthYear__c)[10] += (qpl.Actual__c * multiplier);
            }
        }

        for (Integer x = 0; x < months.size(); x++){

            opexAggregates.get(months[x])[4] += opexAggregates.get(months[x])[0] + opexAggregates.get(months[x])[1];
            opexAggregates.get(months[x])[5] += opexAggregates.get(months[x])[3];

            Integer y = months.size() - 1;

            while (y > x){
                opexAggregates.get(months[y])[4] += opexAggregates.get(months[x])[0] + opexAggregates.get(months[x])[1];
                opexAggregates.get(months[y])[5] += opexAggregates.get(months[x])[3];
                y--;
            }
        }

        return opexAggregates;
    }

    @RemoteAction
    global static List<Decimal> getHeadlineTotals(String start, String endD){

        Date startDate      = Date.valueOf(start);
        Date endDate        = Date.valueOf(endD);

        List<Decimal> totalFigures = new List<Decimal>{0,0,0,0,0,0,0,0,0};

        List<AggregateResult> oppAggregates =
                                [SELECT Committed__c,
                                        SUM(Amount_Calder__c) Revenue,
                                        SUM(Gross_profit_2__c) Profit,
                                        SUM(CommittedRevenue__c) CommittedRevenue,
                                        SUM(CommittedProfit__c) CommittedProfit,
                                        SUM(Filtered_Cost_of_Sale__c) COS,
                                        SUM(Quickbooks_COS__c) COSBilled,
                                        SUM(Quickbooks_COS_Paid__c) COSPaid,
                                        SUM(Amount_Invoiced2__c) Invoiced,
                                        SUM(Amount_Paid__c) Paid
                                FROM Opportunity
                                WHERE StageName = 'Closed Won'
                                AND Event_end__c >= :startDate
                                AND Event_end__c <= :endDate
                                GROUP BY Committed__c];

        for (AggregateResult ar : oppAggregates){
            if (ar.get('Committed__c') == true){
                totalFigures[0] += (Decimal)ar.get('CommittedRevenue');
                totalFigures[1] += (Decimal)ar.get('CommittedProfit');
            } else {
                totalFigures[0] += (Decimal)ar.get('Revenue');
                totalFigures[1] += (Decimal)ar.get('Profit');
            }
            totalFigures[4] += (Decimal)ar.get('Invoiced');
            totalFigures[5] += (Decimal)ar.get('Paid');
            totalFigures[6] += (Decimal)ar.get('COS');
            totalFigures[7] += (Decimal)ar.get('COSBilled');
            totalFigures[8] += (Decimal)ar.get('COSPaid');

        }

        List<AggregateResult> adjustmentAggregates = [SELECT SUM(Revenue__c) Revenue,
                                                             SUM(Profit__c) Profit
                                                      FROM Adjustment__c
                                                      WHERE Month__c >= :startDate
                                                      AND Month__c <= :endDate];

        for (AggregateResult ar : adjustmentAggregates){
            totalFigures[0] += ((Decimal)ar.get('Revenue') == null) ? 0 : (Decimal)ar.get('Revenue');
            totalFigures[1] += ((Decimal)ar.get('Profit') == null) ? 0 : (Decimal)ar.get('Profit');
        }

        List<AggregateResult> opexAggregate =
                                [SELECT SUM(Actual__c) Amount
                                FROM QBProfitAndLoss__c
                                WHERE Opex__c = TRUE
                                AND Month__c >= :startDate.toStartOfMonth()
                                AND Month__c <= :endDate];

        for (AggregateResult ar : opexAggregate) {
            if (ar.get('Amount') != null) {
                totalFigures[2] = (Decimal) ar.get('Amount');
            }
        }

        totalFigures[3] = totalFigures[1] - totalFigures[2];

        return totalFigures;

    }

    @RemoteAction
    global static Map<String,List<Object>> getOppChanges(String start, String endD, Integer days, Decimal currentTotal){

        Date startDate      = Date.valueOf(start);
        Date endDate        = Date.valueOf(endD);

        Map<String,List<Object>> changeMap = new Map<String,List<Object>>();

        Map<String,String> imageMap = new Map<String,String>();

        for (Employee1__c emp : [SELECT FirstName__c, LastName__c, ImageLink__c FROM Employee1__c WHERE ImageLink__c != NULL]){
            imageMap.put(emp.FirstName__c + emp.LastName__c, emp.ImageLink__c);
        }

        if (!imageMap.isEmpty()){
            changeMap.put('Images', new List<Object>{imageMap});
        }

        for (Integer x = 0; x < days; x++){
            changeMap.put(String.valueOf(x), new List<Object>());
        }

//        Date fallBack = Date.valueOf(Date.today().addDays(-(days +1)));
        Date fallBack = Date.valueOf(Date.today().addDays(-(days-1)));

        List<SalesDashboardSnapshot__c> snapshots =
                [SELECT TotalRevenue__c, DateCreated__c, CreatedDate,
                        CreatedBy.FirstName, CreatedBy.LastName
                FROM SalesDashboardSnapshot__c
                WHERE DateCreated__c >= :fallBack
                AND PeriodEnd__c <= :endDate
                ORDER BY CreatedDate DESC];

        List<SalesDashboardSnapshot__c> snapshotsClone = snapshots.deepClone();

        for (Integer x = 0; x < snapshots.size(); x++){

            if (x == 0){
                snapshots[x].TotalRevenue__c =  currentTotal - snapshots[x].TotalRevenue__c;
            } else {
                snapshots[x].TotalRevenue__c =  snapshotsClone[x - 1].TotalRevenue__c -  snapshots[x].TotalRevenue__c;
            }
//            String dayString = String.valueOf(Date.valueOf(snapshots[x].DateCreated__c).daysBetween(Date.today().addDays(-1)));
//            String dayString = String.valueOf(Date.valueOf(snapshots[x].DateCreated__c).daysBetween(Date.today().addDays(-1)));
//
//            system.debug('looking for daystring ' + dayString + ' when date val is ' + snapshots[x].DateCreated__c);
//            changeMap.get(dayString).add(snapshots[x]);
            changeMap.get(String.valueOf(x)).add(snapshots[x]);
        }

        // capture date changes
        List<OpportunityFieldHistory> dateChanges =
                [SELECT OpportunityId,
                    Opportunity.Name, Opportunity.Filtered_Job_Number__c,
                    Opportunity.Amount_Calder__c, Opportunity.StageName,
                    Field, OldValue, NewValue, CreatedDate,
                    CreatedBy.FirstName, CreatedBy.LastName
                FROM OpportunityFieldHistory
                WHERE Opportunity.StageName = 'Closed Won'
                AND CreatedDate >= :fallBack
                AND Field = 'Event_end__c'
                ORDER BY CreatedDate DESC];

        for (OpportunityFieldHistory ofs : dateChanges) {

            Date createdDate = Date.newInstance(ofs.CreatedDate.year(), ofs.CreatedDate.month(), ofs.CreatedDate.day());
            String dayString = String.valueOf(createdDate.daysBetween(Date.today()));

            // Revenue which has gone out of the current financial year
            if (((Date)ofs.OldValue >= startDate && (Date)ofs.OldValue <= endDate)
                    && ((Date)ofs.NewValue < startDate || (Date)ofs.NewValue > endDate)) {
                changeMap.get(dayString).add(ofs);

                // Revenue which has entered the current financial year
            } else if (((Date)ofs.OldValue < startDate || (Date)ofs.OldValue > endDate)
                    && ((Date)ofs.NewValue >= startDate && (Date)ofs.NewValue <= endDate)) {

                changeMap.get(dayString).add(ofs);
            }
        }


        // capture amount changes and relevant stage (Closed Won) at time of change
        List<OpportunityFieldHistory> revenueChanges =
                [SELECT OpportunityId, Opportunity.Name, Opportunity.Filtered_Job_Number__c,
                        Opportunity.Amount_Calder__c, Opportunity.Calder_Opportunity__c,
                        Opportunity.StageName, Field, OldValue, NewValue, CreatedDate,
                        CreatedBy.FirstName, CreatedBy.LastName, CreatedById
                FROM OpportunityFieldHistory
                WHERE Opportunity.Event_end__c >= :startDate
                AND Opportunity.Event_end__c <= :endDate
                AND CreatedDate >= :fallBack
                AND Field = 'Amount'
                ORDER BY CreatedDate DESC];

        Map<Id,List<OpportunityFieldHistory>> stageHistoriesByIds   = new Map<Id,List<OpportunityFieldHistory>>();

        for (OpportunityFieldHistory ofs : revenueChanges) {
            stageHistoriesByIds.put(ofs.OpportunityId, new List<OpportunityFieldHistory>());
        }

        for (OpportunityFieldHistory ofs :
                            [SELECT OpportunityId, Opportunity.Name, Opportunity.Filtered_Job_Number__c,
                                    Opportunity.Amount, Opportunity.Calder_Opportunity__c,
                                    Opportunity.StageName, Field, OldValue, NewValue, CreatedDate,
                                    CreatedBy.FirstName, CreatedBy.LastName
                            FROM OpportunityFieldHistory
                            WHERE Field = 'StageName'
                            AND OpportunityId IN :stageHistoriesByIds.keySet()
                            ORDER BY CreatedDate ASC]){
            stageHistoriesByIds.get(ofs.OpportunityId).add(ofs);
        }

        // detect duplicate entries caused by quote change
        Map<String,List<Object>> changeTimeMap = new Map<String,List<Object>>();

        for (OpportunityFieldHistory ofs : revenueChanges) {
            if (changeTimeMap.containsKey(ofs.Opportunity.Filtered_Job_Number__c)) {

                Boolean isDuplicate = false;
                List<Object> siblings = changeTimeMap.get(ofs.Opportunity.Filtered_Job_Number__c);

                for (Integer x = 0; x < siblings.size(); x++){

                    Map<String,Object> fieldMap = (Map<String, Object>)siblings[x];
                    String dateString           = (String)fieldMap.get('CreatedDate');
                    dateString                  = dateString.replace('T',' ');
                    Datetime siblingCreatedTime = Datetime.valueOf(dateString.substring(0,19));

                    if (siblingCreatedTime <= ofs.CreatedDate.addMinutes(2) && siblingCreatedTime >= ofs.CreatedDate.addMinutes(-2)) {

                        isDuplicate = true;
                        fieldMap.put('OldValue', ofs.OldValue);
                        changeTimeMap.get(ofs.Opportunity.Filtered_Job_Number__c).remove(x);
                        changeTimeMap.get(ofs.Opportunity.Filtered_Job_Number__c).add((Object)fieldMap);
                    }
                }

                if (!isDuplicate){
                    String ofsString = JSON.serialize(ofs);
                    Object ofsObject = JSON.deserializeUntyped(ofsString);
                    changeTimeMap.get(ofs.Opportunity.Filtered_Job_Number__c).add(ofsObject);
                }
            } else {

                String ofsString = JSON.serialize(ofs);
                Object ofsObject = JSON.deserializeUntyped(ofsString);
                changeTimeMap.put(ofs.Opportunity.Filtered_Job_Number__c, new List<Object>{ofsObject});
            }
        }

        for (String jobNo : changeTimeMap.keySet()) {

            for (Object ofsObject : changeTimeMap.get(jobNo)) {

                Map<String,Object> fieldMap = (Map<String, Object>)ofsObject;
                Map<String,Object> oppMap = (Map<String,Object>)fieldMap.get('Opportunity');

                String createdString    = (String)fieldMap.get('CreatedDate');
                createdString           = createdString.replace('T',' ');
                Date createdDate        = Date.valueOf(createdString);
                createdDate             = Date.newInstance(createdDate.year(), createdDate.month(), createdDate.day());
                Datetime createdTime    = Datetime.valueOf(createdString);

                if (stageHistoriesByIds.containsKey((String)fieldMap.get('OpportunityId'))){

                    for (OpportunityFieldHistory stageHistory : stageHistoriesByIds.get((String)fieldMap.get('OpportunityId'))){
                        if (stageHistory.CreatedDate.getTime() <= createdTime.getTime()){
                            oppMap.put('StageName', stageHistory.NewValue );
                        }
                    }

                }

                if (oppMap.get('StageName') == (String)'Closed Won'){
                    fieldMap.put('Opportunity', oppMap);
                    String newOfsString = JSON.serialize(fieldMap);
                    Object newOfsObject = JSON.deserializeUntyped(newOfsString);
                    String dayString        = String.valueOf(createdDate.daysBetween(Date.today()));
                    changeMap.get(dayString).add(newOfsObject);
                }
            }
        }

        // capture stage changes and relevant amounts at time of change
        List<OpportunityFieldHistory> stageChanges =
                [SELECT OpportunityId, Opportunity.Name, Opportunity.Filtered_Job_Number__c,
                        Opportunity.Amount, Opportunity.Calder_Opportunity__c,
                        Opportunity.StageName, Field, OldValue, NewValue, CreatedDate,
                        CreatedBy.FirstName, CreatedBy.LastName
                FROM OpportunityFieldHistory
                WHERE Opportunity.Event_end__c >= :startDate
                AND Opportunity.Event_end__c <= :endDate
                AND CreatedDate >= :fallBack
                AND Field = 'StageName'
                ORDER BY CreatedDate DESC];

        Map<Id,List<OpportunityFieldHistory>> revenueHistoriesByIds   = new Map<Id,List<OpportunityFieldHistory>>();

        for (OpportunityFieldHistory ofs : stageChanges) {
            // Revenue which has gone out of the current financial year
            if (ofs.OldValue == 'Closed Won' || ofs.NewValue == 'Closed Won') {
                revenueHistoriesByIds.put(ofs.OpportunityId, new List<OpportunityFieldHistory>());
            }
        }

        for (OpportunityFieldHistory ofs :
                            [SELECT OpportunityId, Opportunity.Name, Opportunity.Filtered_Job_Number__c,
                                    Opportunity.Amount, Opportunity.Calder_Opportunity__c,
                                    Opportunity.StageName, Field, OldValue, NewValue, CreatedDate,
                                    CreatedBy.FirstName, CreatedBy.LastName
                            FROM OpportunityFieldHistory
                            WHERE Field = 'Amount'
                            AND OpportunityId IN :revenueHistoriesByIds.keySet()
                            ORDER BY CreatedDate ASC]){
            revenueHistoriesByIds.get(ofs.OpportunityId).add(ofs);
        }

        for (OpportunityFieldHistory ofs : stageChanges){

            if (revenueHistoriesByIds.containsKey(ofs.OpportunityId)){
                for (OpportunityFieldHistory revenueHistory : revenueHistoriesByIds.get(ofs.OpportunityId)){
                    if (revenueHistory.CreatedDate.getTime() <= ofs.CreatedDate.getTime()){
                        ofs.Opportunity.Amount = Decimal.valueOf((String)revenueHistory.NewValue);
                    }
                }
            }

            Date createdDate = Date.newInstance(ofs.CreatedDate.year(), ofs.CreatedDate.month(), ofs.CreatedDate.day());
            String dayString = String.valueOf(createdDate.daysBetween(Date.today().addDays(0)));

            // Revenue which has gone out of the current financial year
            if (ofs.OldValue == 'Closed Won' || ofs.NewValue == 'Closed Won') {
                String ofsString = JSON.serialize(ofs);
                Object ofsObject = JSON.deserializeUntyped(ofsString);
                changeMap.get(dayString).add(ofsObject);
            }
        }

        // capture newly created calder commissions
        List<Adjustment__c> newCommissions =
                [SELECT Revenue__c, CreatedDate, Month__c, CreatedBy.FirstName, CreatedBy.LastName, EventMonthYear__c
                FROM Adjustment__c WHERE Calder__c = TRUE
                AND CreatedDate >= :fallBack
                AND Month__c >= :startDate
                AND Month__c <= :endDate];

        for (Adjustment__c adj : newCommissions){
            Date createdDate = Date.newInstance(adj.CreatedDate.year(), adj.CreatedDate.month(), adj.CreatedDate.day());
            String dayString = String.valueOf(createdDate.daysBetween(Date.today()));
            changeMap.get(dayString).add(adj);
        }

        // capture changed calder commissions
        List<Adjustment__History> changedCommissions =
                [SELECT Field, OldValue, NewValue, CreatedDate, CreatedBy.FirstName, CreatedBy.LastName,
                        Parent.Calder__c, Parent.Month__c, Parent.EventMonthYear__c
                FROM Adjustment__History
                WHERE CreatedDate >= :fallBack
                AND Parent.Calder__c = TRUE
                AND Field = 'Revenue__c'
                AND Parent.Month__c >= :startDate
                AND Parent.Month__c <= :endDate];

        for (Adjustment__History adj : changedCommissions){
            Date createdDate = Date.newInstance(adj.CreatedDate.year(), adj.CreatedDate.month(), adj.CreatedDate.day());
            String dayString = String.valueOf(createdDate.daysBetween(Date.today()));
            changeMap.get(dayString).add(adj);
        }

        return changeMap;
    }

    @RemoteAction
    global static Map<String,List<Object>> getOppProfitChanges(String start, String endD, Integer days, Decimal currentTotal){

        Date startDate      = Date.valueOf(start);
        Date endDate        = Date.valueOf(endD);

        Map<String,List<Object>> changeMap = new Map<String,List<Object>>();

        Map<String,String> imageMap = new Map<String,String>();

        for (Employee1__c emp : [SELECT FirstName__c, LastName__c, ImageLink__c FROM Employee1__c WHERE ImageLink__c != NULL]){
            imageMap.put(emp.FirstName__c + emp.LastName__c, emp.ImageLink__c);
        }

        if (!imageMap.isEmpty()){
            changeMap.put('Images', new List<Object>{imageMap});
        }

        for (Integer x = 0; x < days; x++){
            changeMap.put(String.valueOf(x), new List<Object>());

            system.debug('adding ' + x);
        }



//        Date fallBack = Date.valueOf(Date.today().addDays(-(days +1)));
        Date fallBack = Date.valueOf(Date.today().addDays(-(days-1)));

        List<SalesDashboardSnapshot__c> snapshots =
                        [SELECT TotalGrossProfit__c, DateCreated__c, CreatedDate,
                                CreatedBy.FirstName, CreatedBy.LastName
                        FROM SalesDashboardSnapshot__c
                        WHERE DateCreated__c >= :fallBack.addDays(-1)
                        AND PeriodEnd__c <= :endDate
                        ORDER BY CreatedDate DESC];

        List<SalesDashboardSnapshot__c> snapshotsClone = snapshots.deepClone(false);

        system.debug('before ' + snapshotsClone);

        for (Integer x = 0; x < snapshots.size() - 1; x++){

            if (x == 0){
                snapshots[x].TotalGrossProfit__c = currentTotal - snapshots[x].TotalGrossProfit__c;
            } else {
                snapshots[x].TotalGrossProfit__c = snapshotsClone[x + 1].TotalGrossProfit__c - snapshots[x].TotalGrossProfit__c;
            }
//            String dayString = String.valueOf(Date.valueOf(snapshots[x].DateCreated__c).daysBetween(Date.today().addDays(-1)));
//            String dayString = String.valueOf(Date.valueOf(snapshots[x].DateCreated__c).daysBetween(Date.today()));


//            system.debug('looking for daystring ' + dayString + ' when date val is ' + snapshots[x].DateCreated__c);
//            changeMap.get(dayString).add(snapshots[x]);
            changeMap.get(String.valueOf(x)).add(snapshots[x]);

        }

        system.debug('after ' + snapshotsClone);


        // track date changes
        List<OpportunityFieldHistory> dateChanges = [SELECT OpportunityId, Opportunity.Name, Opportunity.Filtered_Job_Number__c,
                                                            Opportunity.Gross_Profit_Field_History__c,
                                                            Opportunity.StageName, Field, OldValue, NewValue, CreatedDate,
                                                            CreatedBy.FirstName, CreatedBy.LastName
                                                    FROM OpportunityFieldHistory
                                                    WHERE Opportunity.StageName = 'Closed Won'
                                                    AND CreatedDate >= :fallBack
                                                    AND Field = 'Event_end__c'
                                                    ORDER BY CreatedDate DESC];

        for (OpportunityFieldHistory ofs : dateChanges) {

            Date createdDate = Date.newInstance(ofs.CreatedDate.year(), ofs.CreatedDate.month(), ofs.CreatedDate.day());
            String dayString = String.valueOf(createdDate.daysBetween(Date.today()));

            // Revenue which has gone out of the current financial year
            if (((Date)ofs.OldValue >= startDate && (Date)ofs.OldValue <= endDate)
                    && ((Date)ofs.NewValue < startDate || (Date)ofs.NewValue > endDate)) {

                changeMap.get(dayString).add(ofs);

                // Revenue which has entered the current financial year
            } else if (((Date)ofs.OldValue < startDate || (Date)ofs.OldValue > endDate)
                    && ((Date)ofs.NewValue >= startDate && (Date)ofs.NewValue <= endDate)) {

                changeMap.get(dayString).add(ofs);
            }
        }



//
//        // derive possible source of profit change as Quickbooks integration
//        Map<String,List<Expense__c>> expenseMap = new Map<String,List<Expense__c>>();
//
//        for (Expense__c expense : [SELECT Id, Amount__c, Description__c, Opportunity__c, CreatedDate
//        FROM Expense__c
//        WHERE Opportunity__c IN :stageHistoriesByIds.keySet()]){
//            String key = expense.Opportunity__c + String.valueOf(expense.CreatedDate.getTime()).substring(0,8);
//            if (!expenseMap.containsKey(key)){
//                expenseMap.put(key, new List<Expense__c>());
//            }
//            expenseMap.get(key).add(expense);
//        }




//        // track revenue changes
//        List<OpportunityFieldHistory> revenueChanges = [SELECT OpportunityId, Opportunity.Name, Opportunity.Filtered_Job_Number__c,
//                                                                Opportunity.Gross_Profit_Field_History__c,
//                                                                Opportunity.Calder_Opportunity__c,Opportunity.StageName,
//                                                                Field, OldValue, NewValue, CreatedDate,
//                                                                CreatedBy.FirstName, CreatedBy.LastName
//                                                        FROM OpportunityFieldHistory
//                                                        WHERE Opportunity.StageName = 'Closed Won'
//                                                        AND Opportunity.Event_end__c >= :startDate
//                                                        AND Opportunity.Event_end__c <= :endDate
//                                                        AND CreatedDate >= :fallBack
//                                                        AND Field = 'Gross_Profit_Field_History__c'
//                                                        ORDER BY CreatedDate DESC];
//
////        for (OpportunityFieldHistory ofs : revenueChanges) {
////            String dayString = String.valueOf(Date.valueOf(ofs.CreatedDate).daysBetween(Date.today()));
////            changeMap.get(dayString).add(ofs);
////        }
//
//        // detect duplicate entries caused by quote change
//        Map<String,List<Object>> changeTimeMap = new Map<String,List<Object>>();
//
//        for (OpportunityFieldHistory ofs : revenueChanges) {
//
//            system.debug('prof change for ' + ofs.Opportunity.Name + ' prior val ' + ofs.OldValue +
//            ' and new val ' + ofs.NewValue);
//
//
//            if (changeTimeMap.containsKey(ofs.Opportunity.Filtered_Job_Number__c)) {
//
//                Boolean isDuplicate = false;
//                List<Object> siblings = changeTimeMap.get(ofs.Opportunity.Filtered_Job_Number__c);
//
//                for (Integer x = 0; x < siblings.size(); x++){
//
//                    Map<String,Object> fieldMap = (Map<String, Object>)siblings[x];
//                    String dateString = (String)fieldMap.get('CreatedDate');
//                    dateString = dateString.replace('T',' ');
//                    Datetime siblingCreatedTime = Datetime.valueOf(dateString.subString(0,19));
//
//                    if (siblingCreatedTime <= ofs.CreatedDate.addSeconds(5) && siblingCreatedTime >= ofs.CreatedDate.addSeconds(-5)) {
//
//                        isDuplicate = true;
//
//                        System.debug('the less recent of the changes, which should contain the original value is ' + ofs);
//
//                        fieldMap.put('OldValue', ofs.OldValue);
//
//                        changeTimeMap.get(ofs.Opportunity.Filtered_Job_Number__c).remove(x);
//                        changeTimeMap.get(ofs.Opportunity.Filtered_Job_Number__c).add((Object)fieldMap);
//                    }
//                }
//
//                if (!isDuplicate){
//                    String ofsString = JSON.serialize(ofs);
//                    Object ofsObject = JSON.deserializeUntyped(ofsString);
//                    changeTimeMap.get(ofs.Opportunity.Filtered_Job_Number__c).add(ofsObject);
//                }
//            } else {
//
//                System.debug('the most recent of the changes, which should contain the ending value is ' + ofs);
//
//                String ofsString = JSON.serialize(ofs);
//                Object ofsObject = JSON.deserializeUntyped(ofsString);
//                changeTimeMap.put(ofs.Opportunity.Filtered_Job_Number__c, new List<Object>{ofsObject});
//            }
//        }
//
//        for (String jobNo : changeTimeMap.keySet()) {
//            for (Object ofsObject : changeTimeMap.get(jobNo)) {
//
//                Map<String,Object> fieldMap = (Map<String, Object>)ofsObject;
//                String createdString = (String)fieldMap.get('CreatedDate');
//                createdString = createdString.replace('T',' ');
//
//                Date createdDate = Date.valueOf(createdString);
//
//                String dayString = String.valueOf(createdDate.daysBetween(Date.today()));
//                changeMap.get(dayString).add(ofsObject);
//            }
//        }


        // capture amount changes and relevant stage (Closed Won) at time of change
        List<OpportunityFieldHistory> revenueChanges =
                                    [SELECT OpportunityId, Opportunity.Name, Opportunity.Filtered_Job_Number__c,
                                            Opportunity.Amount_Calder__c, Opportunity.Calder_Opportunity__c,
                                            Opportunity.StageName, Field, OldValue, NewValue, CreatedDate,
                                            CreatedBy.FirstName, CreatedBy.LastName, CreatedById
                                    FROM OpportunityFieldHistory
                                    WHERE Opportunity.Event_end__c >= :startDate
                                    AND Opportunity.Event_end__c <= :endDate
                                    AND CreatedDate >= :fallBack
                                    AND Field = 'Gross_Profit_Field_History__c'
                                    ORDER BY CreatedDate DESC];

        Map<Id,List<OpportunityFieldHistory>> stageHistoriesByIds   = new Map<Id,List<OpportunityFieldHistory>>();

        for (OpportunityFieldHistory ofs : revenueChanges) {
            stageHistoriesByIds.put(ofs.OpportunityId, new List<OpportunityFieldHistory>());
        }

        // track stage at time of change
        for (OpportunityFieldHistory ofs :
                                    [SELECT OpportunityId, Opportunity.Name, Opportunity.Filtered_Job_Number__c,
                                            Opportunity.Amount, Opportunity.Calder_Opportunity__c,
                                            Opportunity.StageName, Field, OldValue, NewValue, CreatedDate,
                                            CreatedBy.FirstName, CreatedBy.LastName
                                    FROM OpportunityFieldHistory
                                    WHERE Field = 'StageName'
                                    AND OpportunityId IN :stageHistoriesByIds.keySet()
                                    ORDER BY CreatedDate ASC]){
            stageHistoriesByIds.get(ofs.OpportunityId).add(ofs);
        }

        // derive possible source of profit change as Quickbooks integration
        Map<String,List<Expense__c>> expenseMap = new Map<String,List<Expense__c>>();

        for (Expense__c expense : [SELECT Id, Amount__c, Description__c, Opportunity__c, CreatedDate
                                    FROM Expense__c
                                    WHERE Opportunity__c IN :stageHistoriesByIds.keySet()]){
            String key = expense.Opportunity__c + String.valueOf(expense.CreatedDate.getTime()).substring(0,8);
            if (!expenseMap.containsKey(key)){
                expenseMap.put(key, new List<Expense__c>());
            }
            expenseMap.get(key).add(expense);
        }


        Map<String,OpportunityFieldHistory> revenueHistoryMap = new Map<String,OpportunityFieldHistory>();

        // derive possible source of profit change as revenue change
        for (OpportunityFieldHistory ofs :
                                    [SELECT OpportunityId, Opportunity.Name, Opportunity.Filtered_Job_Number__c,
                                            Opportunity.Amount, Opportunity.Calder_Opportunity__c,
                                            Opportunity.StageName, Field, OldValue, NewValue, CreatedDate,
                                            CreatedBy.FirstName, CreatedBy.LastName
                                    FROM OpportunityFieldHistory
                                    WHERE Field = 'Amount'
                                    AND OpportunityId IN :stageHistoriesByIds.keySet()
                                    ORDER BY CreatedDate ASC]){
            String key = ofs.OpportunityId + String.valueOf(ofs.CreatedDate.getTime()).substring(0,8);
            revenueHistoryMap.put(key, ofs);
        }


        // detect duplicate entries caused by quote change
        Map<String,List<Object>> changeTimeMap = new Map<String,List<Object>>();

        for (OpportunityFieldHistory ofs : revenueChanges) {
            if (changeTimeMap.containsKey(ofs.Opportunity.Filtered_Job_Number__c)) {

                Boolean isDuplicate = false;
                List<Object> siblings = changeTimeMap.get(ofs.Opportunity.Filtered_Job_Number__c);

                for (Integer x = 0; x < siblings.size(); x++){

                    Map<String,Object> fieldMap = (Map<String, Object>)siblings[x];
                    String dateString           = (String)fieldMap.get('CreatedDate');
                    dateString                  = dateString.replace('T',' ');
                    Datetime siblingCreatedTime = Datetime.valueOf(dateString.substring(0,19));

                    if (siblingCreatedTime <= ofs.CreatedDate.addMinutes(2) && siblingCreatedTime >= ofs.CreatedDate.addMinutes(-2)) {

                        isDuplicate = true;
                        fieldMap.put('OldValue', ofs.OldValue);
                        changeTimeMap.get(ofs.Opportunity.Filtered_Job_Number__c).remove(x);
                        changeTimeMap.get(ofs.Opportunity.Filtered_Job_Number__c).add((Object)fieldMap);
                    }
                }

                if (!isDuplicate){

                    String ofsString = JSON.serialize(ofs);
                    Object ofsObject = JSON.deserializeUntyped(ofsString);
                    changeTimeMap.get(ofs.Opportunity.Filtered_Job_Number__c).add(ofsObject);
                }
            } else {

                String ofsString = JSON.serialize(ofs);
                Object ofsObject = JSON.deserializeUntyped(ofsString);
                changeTimeMap.put(ofs.Opportunity.Filtered_Job_Number__c, new List<Object>{ofsObject});
            }
        }

        for (String jobNo : changeTimeMap.keySet()) {

            for (Object ofsObject : changeTimeMap.get(jobNo)) {

                Map<String,Object> fieldMap = (Map<String, Object>)ofsObject;
                Map<String,Object> oppMap = (Map<String,Object>)fieldMap.get('Opportunity');

                String createdString    = (String)fieldMap.get('CreatedDate');
                createdString           = createdString.replace('T',' ');
                Date createdDate        = Date.valueOf(createdString);
                createdDate             = Date.newInstance(createdDate.year(), createdDate.month(), createdDate.day());
                Datetime createdTime    = Datetime.valueOf(createdString);

                if (stageHistoriesByIds.containsKey((String)fieldMap.get('OpportunityId'))){

                    for (OpportunityFieldHistory stageHistory : stageHistoriesByIds.get((String)fieldMap.get('OpportunityId'))){
                        if (stageHistory.CreatedDate.getTime() <= createdTime.getTime()){
                            oppMap.put('StageName', stageHistory.NewValue );
                        }
                    }
                }

                if (oppMap.get('StageName') == (String)'Closed Won'){

                    // get key
                    String key           = (String)fieldMap.get('OpportunityId') +
                                            String.valueOf(createdTime.getTime()).substring(0,8);

                    // check both maps
                    if (expenseMap.containsKey(key)){

                        system.debug('found matching expenses');
                        fieldMap.put('Expenses', expenseMap.get(key));
                    }

                    if (revenueHistoryMap.containsKey(key)){
                        system.debug('found revenue changes');
                        fieldMap.put('Revenue', revenueHistoryMap.get(key));
                    }
                    // add values to obj if found in maps

                    fieldMap.put('Opportunity', oppMap);
                    String newOfsString = JSON.serialize(fieldMap);
                    Object newOfsObject = JSON.deserializeUntyped(newOfsString);
                    String dayString    = String.valueOf(createdDate.daysBetween(Date.today()));
                    changeMap.get(dayString).add(newOfsObject);
                }
            }
        }



//
//
//        for (OpportunityFieldHistory ofs : stageChanges) {
//
//            Date createdDate = Date.newInstance(ofs.CreatedDate.year(), ofs.CreatedDate.month(), ofs.CreatedDate.day());
//            String dayString = String.valueOf(createdDate.daysBetween(Date.today()));
//
//            // Profit which has gone out of the current financial year
////            Integer day = Date.valueOf(ofs.CreatedDate).day();
//
//            if (ofs.OldValue == 'Closed Won' || ofs.NewValue == 'Closed Won') {
////                if (day == Date.today().day()) {
//                    changeMap.get(dayString).add(ofs);
////                }
//            }
//        }

        // capture stage changes and relevant amounts at time of change
        List<OpportunityFieldHistory> stageChanges = [SELECT OpportunityId, Opportunity.Name, Opportunity.Filtered_Job_Number__c,
                                                            Opportunity.Gross_Profit_Field_History__c, Opportunity.Calder_Opportunity__c,
                                                            Opportunity.StageName, Field, OldValue, NewValue, CreatedDate,
                                                            CreatedBy.FirstName, CreatedBy.LastName, Opportunity.Gross_profit_2__c
                                                    FROM OpportunityFieldHistory
                                                    WHERE Opportunity.Event_end__c >= :startDate
                                                    AND Opportunity.Event_end__c <= :endDate
                                                    AND CreatedDate >= :fallBack
                                                    AND Field = 'StageName'
                                                    ORDER BY CreatedDate DESC];

        Map<Id,List<OpportunityFieldHistory>> revenueHistoriesByIds   = new Map<Id,List<OpportunityFieldHistory>>();

        for (OpportunityFieldHistory ofs : stageChanges) {
            // Revenue which has gone out of the current financial year
            if (ofs.OldValue == 'Closed Won' || ofs.NewValue == 'Closed Won') {
                revenueHistoriesByIds.put(ofs.OpportunityId, new List<OpportunityFieldHistory>());
            }
        }

        for (OpportunityFieldHistory ofs :
                                        [SELECT OpportunityId, Opportunity.Name, Opportunity.Filtered_Job_Number__c,
                                                Opportunity.Amount, Opportunity.Calder_Opportunity__c,
                                                Opportunity.StageName, Field, OldValue, NewValue, CreatedDate,
                                                CreatedBy.FirstName, CreatedBy.LastName
                                        FROM OpportunityFieldHistory
                                        WHERE Field = 'Gross_Profit_Field_History__c'
                                        AND OpportunityId IN :revenueHistoriesByIds.keySet()
                                        ORDER BY CreatedDate ASC]){
            revenueHistoriesByIds.get(ofs.OpportunityId).add(ofs);
        }

        for (OpportunityFieldHistory ofs : stageChanges){

            if (revenueHistoriesByIds.containsKey(ofs.OpportunityId)){
                for (OpportunityFieldHistory revenueHistory : revenueHistoriesByIds.get(ofs.OpportunityId)){
                    if (revenueHistory.CreatedDate.getTime() <= ofs.CreatedDate.getTime()){
                        ofs.Opportunity.Gross_Profit_Field_History__c = Decimal.valueOf((String)revenueHistory.NewValue);
                    }
                }
            }

            if (ofs.Opportunity.Gross_Profit_Field_History__c == null){
                ofs.Opportunity.Gross_Profit_Field_History__c = ofs.Opportunity.Gross_profit_2__c;
            }

            Date createdDate = Date.newInstance(ofs.CreatedDate.year(), ofs.CreatedDate.month(), ofs.CreatedDate.day());
            String dayString = String.valueOf(createdDate.daysBetween(Date.today().addDays(0)));

            // Revenue which has gone out of the current financial year
            if (ofs.OldValue == 'Closed Won' || ofs.NewValue == 'Closed Won') {
                String ofsString = JSON.serialize(ofs);
                Object ofsObject = JSON.deserializeUntyped(ofsString);
                changeMap.get(dayString).add(ofsObject);
            }
        }











        List<Adjustment__c> newCommissions =
                                            [SELECT Profit__c, CreatedDate, Month__c, CreatedBy.FirstName,
                                                    CreatedBy.LastName, EventMonthYear__c
                                            FROM Adjustment__c WHERE Calder__c = TRUE
                                            AND CreatedDate >= :fallBack
                                            AND Month__c >= :startDate
                                            AND Month__c <= :endDate];

        for (Adjustment__c adj : newCommissions){
            Date createdDate = Date.newInstance(adj.CreatedDate.year(), adj.CreatedDate.month(), adj.CreatedDate.day());
            String dayString = String.valueOf(createdDate.daysBetween(Date.today()));
            changeMap.get(dayString).add(adj);
        }

        List<Adjustment__History> changedCommissions =
                                                [SELECT Field, OldValue, NewValue, CreatedDate, CreatedBy.FirstName,
                                                        CreatedBy.LastName, Parent.Calder__c,
                                                        Parent.Month__c, Parent.EventMonthYear__c
                                                FROM Adjustment__History
                                                WHERE CreatedDate >= :fallBack
                                                AND Parent.Calder__c = TRUE
                                                AND Parent.Month__c >= :startDate
                                                AND Parent.Month__c <= :endDate];

        for (Adjustment__History adj : changedCommissions){
            Date createdDate = Date.newInstance(adj.CreatedDate.year(), adj.CreatedDate.month(), adj.CreatedDate.day());
            String dayString = String.valueOf(createdDate.daysBetween(Date.today()));
            changeMap.get(dayString).add(adj);
        }


        return changeMap;
    }

    @RemoteAction
    global static Map<Date, List<Object>> getBalances(String start, String endD){

        Date startDate      = Date.valueOf(start);
        Date endDate        = Date.valueOf(endD);

        Map<Date, List<Object>> balanceMap = new Map<Date, List<Object>>();

        Date iterator = startDate;

        while (iterator <= endDate){
            balanceMap.put(iterator, new List<Object>{'',null,null,null,null});
            iterator = iterator.addDays(1);
        }

        for (QBBalance__c b : [SELECT Date__c, DayMonthYear__c, Confirmed__c, Weighted__c,
                                Predictive__c
                                FROM QBBalance__c
                                WHERE Date__c >= :startDate
                                AND Date__c <= :endDate
                                ORDER BY Date__c ASC]){
            balanceMap.get(b.Date__c)[0] = b.DayMonthYear__c;
            balanceMap.get(b.Date__c)[1] = b.Confirmed__c;
        }


        for (CashFlow__c c : [SELECT Date__c, DayMonthYear__c, Balance__c, BalancePlus__c,
                                    BalancePredict__c
                                FROM CashFlow__c
                                WHERE Date__c >= :startDate
                                AND Date__c <= :endDate]){
            balanceMap.get(c.Date__c)[0] = c.DayMonthYear__c;
            balanceMap.get(c.Date__c)[1] = c.Balance__c;
            balanceMap.get(c.Date__c)[2] = c.Balance__c;
            balanceMap.get(c.Date__c)[3] = c.BalancePlus__c;
            balanceMap.get(c.Date__c)[4] = c.BalancePredict__c;
        }

        return balanceMap;
    }


    @RemoteAction
    global static Map<String,Map<String,List<Object>>> getOppReportData(String start, String endD){

        Date startDate      = Date.valueOf(start);
        Date endDate        = Date.valueOf(endD);

        Map<Integer,String> monthsMap = new Map<Integer,String>();
        monthsMap.put(1, 'Jan');
        monthsMap.put(2, 'Feb');
        monthsMap.put(3, 'Mar');
        monthsMap.put(4, 'Apr');
        monthsMap.put(5, 'May');
        monthsMap.put(6, 'Jun');
        monthsMap.put(7, 'Jul');
        monthsMap.put(8, 'Aug');
        monthsMap.put(9, 'Sep');
        monthsMap.put(10, 'Oct');
        monthsMap.put(11, 'Nov');
        monthsMap.put(12, 'Dec');

        Map<String,Map<String,List<Object>>> reportingMap =
                new Map<String,Map<String,List<Object>>>();

        Date incrementDate = startDate;

        List<String> months = new List<String>();

        while (incrementDate < endDate){

            String key = monthsMap.get(incrementDate.month()) + ' ' +
                    incrementDate.year();

            reportingMap.put(key, new Map<String,List<Object>>());

            reportingMap.get(key).put('Closed Won', new List<Object>());
            reportingMap.get(key).put('Costed prospect', new List<Object>());
            reportingMap.get(key).put('Pipeline prospect', new List<Object>());
            reportingMap.get(key).put('Repeat Prospect', new List<Object>());

            months.add(key);

            incrementDate = incrementDate.addMonths(1);
        }

        for (Adjustment__c adj : [SELECT EventMonthYear__c, Month__c, Revenue__c, Profit__c, CostOfSale__c, Calder__c
                                  FROM Adjustment__c
                                  WHERE Month__c >= :startDate
                                  AND Month__c <= :endDate
                                  AND Opportunity__c = NULL]){

            String adjustmentString = JSON.serialize(adj);

            String jobNumber = (adj.Calder__c) ? 'Calder' : 'Statutory accounts';
            String name = (adj.Calder__c) ? 'commission' : 'realignment';

            Object result = JSON.deserializeUntyped('{"Name" : "' + name + '", ' +
                    '"Filtered_Job_Number__c" : "' + jobNumber + '", ' +
                    '"Adjustments__r" : [' + adjustmentString + ']}');

            if (reportingMap.containsKey(adj.EventMonthYear__c)){
                reportingMap.get(adj.EventMonthYear__c).get('Closed Won').add(result);
            }
        }

        Set<Id> floatingAdjustments = new Set<Id>();

        for (Adjustment__c adj : [SELECT Opportunity__c
                                  FROM Adjustment__c
                                  WHERE Month__c >= :startDate
                                  AND Month__c <= :endDate
                                  AND Opportunity__r.Event_end__c < :startDate]){
            floatingAdjustments.add(adj.Opportunity__c);
        }

        for (Opportunity opp : [SELECT Id, StageName, Owner.FirstName, Owner.LastName, Filtered_Job_Number__c, Project_Manager__c,
                                        Project_Manager__r.FirstName, Project_Manager__r.LastName, Name,
                                        Account.Name, Event_start__c, Event_end__c, Probability,
                                        Amount_Calder__c, Gross_profit_2__c, Gross_Margin__c,
                                        Filtered_Cost_of_Sale__c, Quickbooks_COS__c, Quickbooks_COS_Paid__c,
                                        Quote_Status__c, Amount_Invoiced2__c, Amount_Paid__c, EventMonthYear__c,
                                        CommittedRevenue__c, CommittedProfit__c, CommittedCOS__c, Committed__c,
                                        (SELECT Revenue__c, Profit__c, CostOfSale__c, EventMonthYear__c, Month__c
                                        FROM Adjustments__r)
                                FROM Opportunity
                                WHERE (StageName != 'Closed Lost'
                                AND Event_end__c >= :startDate
                                AND Event_end__c <= :endDate)
                                OR (Id IN: floatingAdjustments)
                                ORDER BY Event_end__c ASC]){

            System.debug(opp.Adjustments__r);

            if (opp.Name.contains('\'') || opp.Account.Name.contains('\'')){
                System.debug('replacing');
                opp.Name = opp.Name.replaceAll('\'','');
                opp.Account.Name = opp.Account.Name.replaceAll('\'','');
            }

            if (reportingMap.containsKey(opp.EventMonthYear__c)){
                reportingMap.get(opp.EventMonthYear__c).get(opp.StageName).add(opp);
            }

            Set<String> monthsAdded = new Set<String>();

            for (Adjustment__c adj : opp.Adjustments__r){
                if (reportingMap.containsKey(adj.EventMonthYear__c) && !monthsAdded.contains(adj.EventMonthYear__c)){
                    reportingMap.get(adj.EventMonthYear__c).get('Closed Won').add(opp);
                    monthsAdded.add(adj.EventMonthYear__c);
                }
            }

        }

        return reportingMap;
    }


    @RemoteAction
    global static Map<String,Map<String,Map<String,List<Decimal>>>> getOpexReportData(String start, String endD) {

        Date startDate = Date.valueOf(start);
        Date endDate = Date.valueOf(endD);

        // work out if start date and end date are not clean start and end dates
        Decimal numberOfDaysStart   = Date.daysInMonth(startDate.year(), startDate.month());
        Decimal daysMissing         = startDate.day() - 1;
        Decimal startPortion        = (numberOfDaysStart - daysMissing) / numberOfDaysStart;

        Decimal numberOfDaysEnd     = Date.daysInMonth(endDate.year(), endDate.month());
        Decimal dayCountEnd         = endDate.day();
        Decimal endPortion          = (numberOfDaysEnd - (numberOfDaysEnd - dayCountEnd)) / numberOfDaysEnd;


        Map<String,Map<String,Map<String,List<Decimal>>>> opexMap =
                new Map<String,Map<String,Map<String,List<Decimal>>>>();

        List<QBProfitAndLoss__c> entries = [SELECT Id, Month__c, Actual__c, Nominal__c,
                                                    Parent__c, Grouping__c
                                            FROM QBProfitAndLoss__c
                                            WHERE Opex__c = TRUE
                                            AND Month__c >= :startDate.toStartOfMonth()
                                            AND Month__c <= :endDate
                                            ORDER BY Month__c ASC, Nominal__c ASC];

        for (QBProfitAndLoss__c q : entries){
            Decimal multiplier = 1;
            if (q.Month__c.month() == startDate.month()){
                multiplier = startPortion;
            } else if (q.Month__c.month() == endDate.month()){
                multiplier = endPortion;
            }

            if (!opexMap.containsKey(q.Grouping__c)){
                opexMap.put(q.Grouping__c, new Map<String,Map<String,List<Decimal>>>());
                opexMap.get(q.Grouping__c).put(q.Parent__c, new Map<String,List<Decimal>>());
                opexMap.get(q.Grouping__c).get(q.Parent__c).put(q.Nominal__c, new List<Decimal>());
            } else if (!opexMap.get(q.Grouping__c).containsKey(q.Parent__c)){
                opexMap.get(q.Grouping__c).put(q.Parent__c, new Map<String,List<Decimal>>());
                opexMap.get(q.Grouping__c).get(q.Parent__c).put(q.Nominal__c, new List<Decimal>());
            } else if (!opexMap.get(q.Grouping__c).get(q.Parent__c).containsKey(q.Nominal__c)){
                opexMap.get(q.Grouping__c).get(q.Parent__c).put(q.Nominal__c, new List<Decimal>());
            }
            opexMap.get(q.Grouping__c).get(q.Parent__c).get(q.Nominal__c).add(q.Actual__c * multiplier);
        }

        return opexMap;

    }

    @RemoteAction
    global static List<Date> getSnapshots(String endDate){

        Date periodEnd = Date.valueOf(endDate);

        List<Date> availableDates = new List<Date>();

        for(SalesDashboardSnapshot__c snapshot : [SELECT Id, CreatedDate
                                                 FROM SalesDashboardSnapshot__c
                                                 WHERE PeriodEnd__c = :periodEnd
                                                 ORDER BY CreatedDate ASC]){
            availableDates.add(Date.valueOf(snapshot.CreatedDate));
        }

        return availableDates;
    }

    @RemoteAction
    global static SalesDashboardSnapshot__c getSnapshotData(String createdDate, String endDate){

        if ([SELECT Id FROM SalesDashboardSnapshot__c
            WHERE DateCreated__c = :Date.valueOf(createdDate)
            AND PeriodEnd__c = :Date.valueOf(endDate)
            ORDER BY CreatedDate DESC LIMIT 1].size() > 0){
            return  [SELECT
                    QBCloseDate__c, PeriodEnd__c, DateCreated__c, Budget11__c, Budget12__c,
                    Budget1__c, Budget2__c, Budget3__c, Budget4__c, Budget5__c, Budget6__c,
                    Budget7__c, Budget8__c, Budget9__c, GPConf10__c, GPConf11__c, GPConf12__c,
                    GPConf1__c, GPConf2__c, GPConf3__c, GPConf4__c, GPConf5__c, GPConf6__c,
                    GPConf7__c, GPConf8__c, GPConf9__c, GPPipeline10__c, GPPipeline11__c,
                    GPPipeline12__c, GPPipeline1__c, GPPipeline2__c, GPPipeline3__c, GPPipeline4__c,
                    GPPipeline5__c, GPPipeline6__c, GPPipeline7__c, GPPipeline8__c,
                    GPPipeline9__c, GPWeighted10__c, GPWeighted11__c, GPWeighted12__c,
                    GPWeighted1__c,  GPWeighted2__c, GPWeighted3__c, GPWeighted4__c, GPWeighted5__c,
                    GPWeighted6__c, GPWeighted7__c, GPWeighted8__c, GPWeighted9__c, Opex10__c,
                    Opex11__c, Opex12__c, Opex1__c, Opex2__c, Opex3__c, Opex4__c, Opex5__c,
                    Opex6__c, Opex7__c, Opex8__c, Opex9__c,  RevConf10__c, RevConf11__c,
                    RevConf12__c,  RevConf1__c, RevConf2__c,  RevConf3__c,  RevConf4__c,
                    RevConf5__c,  RevConf6__c, RevConf7__c, RevConf8__c, RevConf9__c, RevPipeline10__c,
                    RevPipeline11__c, RevPipeline12__c, RevPipeline1__c, RevPipeline2__c,
                    RevPipeline3__c, RevPipeline4__c, RevPipeline5__c, RevPipeline6__c,
                    RevPipeline7__c, RevPipeline8__c, RevPipeline9__c, RevTarget10__c,
                    RevTarget11__c, RevTarget12__c, RevTarget1__c, RevTarget2__c, RevTarget3__c,
                    RevTarget4__c, RevTarget5__c, RevTarget6__c, RevTarget7__c, RevTarget8__c,
                    RevTarget9__c, RevWeighted10__c, RevWeighted11__c, RevWeighted12__c,
                    RevWeighted1__c, RevWeighted2__c, RevWeighted3__c, RevWeighted4__c,
                    RevWeighted5__c, RevWeighted6__c, RevWeighted7__c, RevWeighted8__c,
                    RevWeighted9__c, Balance__c, TotalRevenue__c, TotalGrossProfit__c,
                    TotalOpex__c, TotalNetProfit__c, PriorRevenue__c, PriorGrossProfit__c,
                    PriorNetProfit__c, PriorOpex__c
            FROM SalesDashboardSnapshot__c
            WHERE DateCreated__c = :Date.valueOf(createdDate)
            AND PeriodEnd__c = :Date.valueOf(endDate)
            ORDER BY CreatedDate DESC LIMIT 1];
        } else {
            return null;
        }
    }

    @RemoteAction
    global static Object getPriorTotals(String endDate){

        List<SalesDashboardSnapshot__c> priorSnaps =
                            [SELECT TotalRevenue__c, TotalGrossProfit__c, TotalOpex__c, TotalNetProfit__c
                            FROM SalesDashboardSnapshot__c
                            WHERE PeriodEnd__c = :Date.valueOf(endDate)
                                AND TotalRevenue__c != NULL
                            ORDER BY CreatedDate DESC LIMIT 6];

        if (priorSnaps.isEmpty()){
            return JSON.deserializeUntyped('{"TotalRevenue__c" : 0, ' +
                    '"TotalGrossProfit__c" : 0, ' +
                    '"TotalOpex__c" : 0, ' +
                    '"TotalNetProfit__c" : 0}');
        } else {
            return priorSnaps[priorSnaps.size()-1];
        }
    }

    @RemoteAction
    global static Map<String,Object> getCashflowData(){

        Map<String,Object> cashflowDataMap = new  Map<String,Object>();

        /// first - work out dates
        List<Date> dates              = new List<Date>();
        List<Decimal> figures         = new List<Decimal>();
        List<Decimal> openingBalances = new List<Decimal>();
        List<Decimal> closingBalances = new List<Decimal>();
        List<Decimal> totalInflows    = new List<Decimal>();
        List<Decimal> totalOutflows   = new List<Decimal>();

        Map<String,List<Decimal>> inEntries  = new Map<String,List<Decimal>>();
        Map<String,List<Decimal>> outEntries = new Map<String,List<Decimal>>();

        // begin payment runs on thursday
        Date entryDate = (Date.today() > Date.today().toStartOfWeek().addDays(3)) ?
                Date.today().toStartOfWeek().addDays(10) : Date.today().toStartOfWeek().addDays(3);

        for (Integer x = 0; x < 12; x++){
            if (x == 0){
                dates.add(Date.today());
            } else if (x == 1 && entryDate == Date.today()) {
                entryDate = entryDate.addDays(7);
                dates.add(entryDate);
                entryDate = entryDate.addDays(7);
            } else {
                dates.add(entryDate);
                entryDate = entryDate.addDays(7);
            }
            figures.add(0);

        }

        List<CashFlow__c> flows = [SELECT Date__c, BalancePlus__c
                                    FROM CashFlow__c
                                    WHERE Date__c <= :dates[11].addDays(6)
                                    ORDER BY Date__c ASC];

        Map<Date,CashFlow__c> flowMap = new Map<Date,CashFlow__c>();

        for (CashFlow__c flow : flows){
            flowMap.put(flow.Date__c, flow);
        }

        for (Integer x = 0; x < 12; x++){

            Date startDate  = Date.valueOf(dates[x]);
            Date endDate;

            if (startDate.toStartOfWeek().addDays(3) < startDate){
                endDate = startDate.toStartOfWeek().addDays(9);
            } else if (startDate.toStartOfWeek().addDays(3) > startDate) {
                endDate = startDate.toStartOfWeek().addDays(2);
            } else {
                endDate = startDate.addDays(6);
            }

            openingBalances.add(flowMap.get(startDate.addDays(-1)).BalancePlus__c);
            closingBalances.add(flowMap.get(endDate).BalancePlus__c);

            Decimal totalInflow     = 0;
            Decimal totalOutflow    = 0;

            for (CashFlow__c flow : [SELECT Date__c, In__c, InPlus__c, Out__c, OutPlus__c,
                                        (SELECT Category__c, Amount__c FROM InEntries__r
                                        WHERE Source__c != 'Predictive' ORDER BY Source__c ),
                                        (SELECT Category__c, Amount__c FROM OutEntries__r
                                        WHERE Source__c != 'Predictive' ORDER BY Source__c)
                                    FROM CashFlow__c
                                    WHERE Date__c >= : startDate
                                    AND Date__c <= : endDate]){

                totalInflow += (flow.In__c + flow.InPlus__c);
                totalOutflow += (flow.Out__c + flow.OutPlus__c);

                for (CashFlowEntry__c entry : flow.InEntries__r){
                    if (!inEntries.containsKey(entry.Category__c)){
                        inEntries.put(entry.Category__c, figures.clone());
                    }
                    inEntries.get(entry.Category__c)[x] += entry.Amount__c;
                }
                for (CashFlowEntry__c entry : flow.OutEntries__r){
                    if (!outEntries.containsKey(entry.Category__c)){
                        outEntries.put(entry.Category__c, figures.clone());
                    }
                    outEntries.get(entry.Category__c)[x] += entry.Amount__c;
                }
            }

            totalInflows.add(totalInflow);
            totalOutflows.add(totalOutflow);
        }

        /// load data map with opening balances
        cashflowDataMap.put('WEEK COMMENCING', dates);
        cashflowDataMap.put('OPENING BALANCE', openingBalances);
        cashflowDataMap.put('IN ENTRIES', inEntries);
        cashflowDataMap.put('TOTAL INFLOW', totalInflows);
        cashflowDataMap.put('OUT ENTRIES', outEntries);
        cashflowDataMap.put('TOTAL OUTFLOW', totalOutflows);
        cashflowDataMap.put('CLOSING BALANCE', closingBalances);

        return cashflowDataMap;

    }

    @RemoteAction
    global static List<CashFlowEntry__c> getCashflowEntries(String endDate){

        return [SELECT Id, Category__c, Date__c, Amount__c, Description__c,
                       Details__c, Source__c, InFlow__c, OutFlow__c, QuickbooksId__c,
                       AmountAdjusted__c, Adjusted__c
                FROM CashFlowEntry__c
                WHERE Date__c <= :Date.valueOf(endDate).addDays(6)
                AND Source__c != 'Predictive'
                AND Paid__c != TRUE
                ORDER BY Source__c DESC, Date__c DESC];
    }

    @RemoteAction
    global static CashFlowEntry__c updateEntryDate(String entryId, String dateString, String type){

        Date flowDate = Date.valueOf(dateString);

        CashFlowEntry__c entry = [SELECT Id, Amount__c, InFlow__c, InFlow__r.Date__c, Details__c,
                                        OutFlow__c, OutFlow__r.Date__c, AmountAdjusted__c, Category__c
                                    FROM CashFlowEntry__c WHERE Id = :entryId];

        CashFlow__c newParent = [SELECT Id, In__c, Out__c, Date__c FROM CashFlow__c
                                 WHERE Date__c = :flowDate LIMIT 1];

        CashFlow__c oldParent = null;

        if (type == 'IN'){
            entry.InFlow__c = newParent.Id;
            newParent.In__c += entry.Amount__c;
            oldParent = [SELECT Id, In__c FROM CashFlow__c
                        WHERE Date__c = :entry.InFlow__r.Date__c LIMIT 1];
            oldParent.In__c -= entry.Amount__c;
        } else {
            entry.OutFlow__c = newParent.Id;
            newParent.Out__c += entry.Amount__c;
            oldParent = [SELECT Id, Out__c FROM CashFlow__c
                        WHERE Date__c = :entry.OutFlow__r.Date__c LIMIT 1];
            oldParent.Out__c -= entry.Amount__c;
        }

        if (!entry.Adjusted__c){
            entry.Adjusted__c = true;
            entry.Details__c = entry.Details__c.replace('System generated date', 'Custom date manually specified');
        }

        update entry;
        update newParent;
        update oldParent;

        calculateBalances();

        return [SELECT Id, Category__c, Date__c, Amount__c, Description__c,
                Details__c, Source__c, InFlow__c, OutFlow__c, QuickbooksId__c,
                AmountAdjusted__c, Adjusted__c
                FROM CashFlowEntry__c
                WHERE Id = :entryId];
    }

    @RemoteAction
    global static CashFlowEntry__c updateEntryAmount(String entryId, Decimal amount, String type) {

        CashFlowEntry__c entry = [SELECT Id, Amount__c, InFlow__c, InFlow__r.Date__c, Details__c,
                                        OutFlow__c, OutFlow__r.Date__c, AmountAdjusted__c, Category__c
                                FROM CashFlowEntry__c WHERE Id = :entryId];

        Decimal priorAmount = entry.Amount__c;
        entry.Amount__c     = amount;

        if (!entry.AmountAdjusted__c){
            entry.AmountAdjusted__c = true;
            entry.Details__c = entry.Details__c.replace('System generated amount', 'Custom amount manually specified');
        }

        update entry;

        String parentId = (type == 'IN') ? entry.InFlow__c : entry.OutFlow__c;

        CashFlow__c parent = [SELECT Id, In__c, Out__c, Date__c FROM CashFlow__c
                              WHERE Id = :parentId LIMIT 1];

        if (type == 'IN'){
            parent.In__c -= priorAmount;
            parent.In__c += amount;
        } else {
            parent.Out__c -= priorAmount;
            parent.Out__c += amount;
        }

        update parent;

        calculateBalances();

        return [SELECT Id, Category__c, Date__c, Amount__c, Description__c,
                Details__c, Source__c, InFlow__c, OutFlow__c, QuickbooksId__c,
                AmountAdjusted__c, Adjusted__c
                FROM CashFlowEntry__c
                WHERE Id = :entryId];

    }


    @RemoteAction
    global static Boolean markAsPaid(String entryId, String type){

        CashFlowEntry__c entry = [SELECT Id, Amount__c, InFlow__c, OutFlow__c
                                    FROM CashFlowEntry__c WHERE Id = :entryId];

        entry.Paid__c = true;
        update entry;

        String parentId = (type == 'IN') ? entry.InFlow__c : entry.OutFlow__c;

        CashFlow__c parent = [SELECT Id, In__c, Out__c, Date__c FROM CashFlow__c
                              WHERE Id = :parentId LIMIT 1];

        if (type == 'IN'){
            parent.In__c -= entry.Amount__c;
        } else {
            parent.Out__c -= entry.Amount__c;
        }

        update parent;

        calculateBalances();

        return true;
    }

    @RemoteAction
    global static Map<String,Object> getQBBudgets(String year){

        String fiscalYear;

        if (year.equalsIgnoreCase('CURRENT FY')){
            fiscalYear = 'THIS_FISCAL_YEAR';
        } else if (year.equalsIgnoreCase('NEXT FY')){
            fiscalYear = 'NEXT_FISCAL_YEAR';
        }

        Map<String,Object> responseMap = new Map<String,Object>();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:QuickBooksOnline/query?query=select%20name,metadata,BudgetEntryType,StartDate,' +
                'EndDate%2c%20Id%20from%20budget&minorversion=4');
        request.setHeader('Accept', 'application/json');
        request.setMethod('GET');
        request.setTimeout(120000);
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200){
            responseMap.put('budgets', JSON.deserializeUntyped(response.getBody()));
        }

        List<QBProfitAndLoss__c> budgetSourceList =
                                Database.query('SELECT BudgetSource__c, LastModifiedDate ' +
                                'FROM QBProfitAndLoss__c ' +
                                'WHERE Month__c = ' + fiscalYear  + ' ' +
                                'ORDER BY Month__c DESC LIMIT 1');

        if (!budgetSourceList.isEmpty()){
            if (budgetSourceList[0].BudgetSource__c != null){
                responseMap.put('budgetSource', budgetSourceList[0].BudgetSource__c);
            } else {
                responseMap.put('budgetSource', 'Unknown Budget');
            }

            responseMap.put('budgetUpdate', budgetSourceList[0].LastModifiedDate);
        }

        List<QBProfitAndLoss__c> forecastSourceList =
                Database.query('SELECT ForecastSource__c, LastModifiedDate ' +
                        'FROM QBProfitAndLoss__c ' +
                        'WHERE Month__c = ' + fiscalYear  + ' ' +
                        'ORDER BY Month__c DESC LIMIT 1');

        if (!forecastSourceList.isEmpty()){
            if (forecastSourceList[0].ForecastSource__c != null){
                responseMap.put('forecastSource', forecastSourceList[0].ForecastSource__c);
            } else {
                responseMap.put('forecastSource', 'Unknown Forecast');
            }
            responseMap.put('forecastUpdate', forecastSourceList[0].LastModifiedDate);
        }

        for (QBClosedMonth__c month : QBClosedMonth__c.getAll().values()){
            if (month.Name == 'QBClosedMonth'){
                responseMap.put('closedMonth', month.Month__c);
            }
        }

        return responseMap;
    }

    @RemoteAction
    global static Boolean updateBudgets(String budgetId, String forecastId, String year, String month){

        Boolean result = QuickbooksBudgetCallout.updateOpexForecast(budgetId, forecastId, year, month);
        return result;
    }

}