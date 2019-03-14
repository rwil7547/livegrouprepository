/**
 * Created by Ronan Williams on 05/03/2019.
 */

public class VueTestController {

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
    public static Map<Date, List<Object>> getBalances(String start, String endD){

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
//    public static Map<String,Map<String,List<Decimal>>> getOppRevenueTotals(String start, String endD){
    public static Map<String,Object> getOppRevenueTotals(String start, String endD){

        Date startDate      = Date.valueOf(start);
        Date endDate        = Date.valueOf(endD);

//        Map<String,Map<String,List<Decimal>>> figuresMap = new Map<String,Map<String,List<Decimal>>>();
        Map<String,Object> figuresMap                   = new Map<String,Object>();
        Map<String,List<Decimal>> revenueAggregates     = buildMap(start,endD);
        Map<String,List<Decimal>> profitAggregates      = buildMap(start,endD);
        Map<String,List<Decimal>> opexAggregates        = buildMap(start,endD);
        Map<String,List<Decimal>> netProfitAggregates   = buildMap(start,endD);
        Map<String,Decimal> totals                      = new Map<String,Decimal>();
        totals.put('revenue', 0);
        totals.put('profit', 0);
        totals.put('opex', 0);
        totals.put('netProfit', 0);


        // work out if start date and end date are not clean start and end dates
        Decimal numberOfDaysStart   = Date.daysInMonth(startDate.year(), startDate.month());
        Decimal daysMissing         = startDate.day() - 1;
        Decimal startPortion        = (numberOfDaysStart - daysMissing) / numberOfDaysStart;

        Decimal numberOfDaysEnd     = Date.daysInMonth(endDate.year(), endDate.month());
        Decimal dayCountEnd         = endDate.day();
        Decimal endPortion          = (numberOfDaysEnd - (numberOfDaysEnd - dayCountEnd)) / numberOfDaysEnd;

        List<String> months = new List<String>();
        months.addAll(revenueAggregates.keySet());


        // get all committed opp data
        for (Opportunity opp : [SELECT Amount_Calder__c, Probability, StageName,
                                        EventMonthYear__c, Committed__c, CommittedRevenue__c, CommittedProfit__c,
                                        Gross_profit_2__c, Event_End_Grouping__c,
                                        EventMonthString__c
                                FROM Opportunity
                                WHERE StageName != 'Closed Lost'
                                AND Event_end__c >= :startDate
                                AND Event_end__c <= :endDate]){

            if (opp.Committed__c){
                totals.put('revenue',totals.get('revenue') + opp.CommittedRevenue__c);
                totals.put('profit',totals.get('profit') + opp.CommittedProfit__c);
                revenueAggregates.get(opp.EventMonthYear__c)[0] += opp.CommittedRevenue__c;
                profitAggregates.get(opp.EventMonthYear__c)[0] += opp.CommittedProfit__c;
            } else if (opp.StageName == 'Closed Won') {
                totals.put('revenue',totals.get('revenue') + opp.Amount_Calder__c);
                totals.put('profit',totals.get('profit') + opp.Gross_profit_2__c);
                revenueAggregates.get(opp.EventMonthYear__c)[0] += opp.Amount_Calder__c;
                profitAggregates.get(opp.EventMonthYear__c)[0] += opp.Gross_profit_2__c;
            } else {
                revenueAggregates.get(opp.EventMonthYear__c)[1] += (opp.Amount_Calder__c * opp.Probability) / 100;
                profitAggregates.get(opp.EventMonthYear__c)[1] += (opp.Gross_profit_2__c * opp.Probability) / 100;
                revenueAggregates.get(opp.EventMonthYear__c)[2] += opp.Amount_Calder__c - (opp.Amount_Calder__c * opp.Probability) / 100;
                profitAggregates.get(opp.EventMonthYear__c)[2] += opp.Gross_profit_2__c - (opp.Gross_profit_2__c * opp.Probability) / 100;

            }
        }

        for (Adjustment__c adj : [SELECT Revenue__c, Profit__c, EventMonthYear__c
                                    FROM Adjustment__c
                                    WHERE Month__c >= :startDate
                                    AND Month__c <= :endDate]) {
            revenueAggregates.get(adj.EventMonthYear__c)[0] += adj.Revenue__c;
            profitAggregates.get(adj.EventMonthYear__c)[0] += adj.Profit__c;
        }

        List<SalesTarget__c> targets = [SELECT Revenue__c, EventMonthYear__c
                                        FROM SalesTarget__c
                                        WHERE Month__c >= :startDate
                                        AND Month__c <= :endDate];

        for (SalesTarget__c target : targets) {
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

        for (Integer x = 0; x < months.size(); x++){
            netProfitAggregates.get(months[x])[0] = (profitAggregates.get(months[x])[0] - opexAggregates.get(months[x])[0]);
            netProfitAggregates.get(months[x])[1] = (profitAggregates.get(months[x])[1] - opexAggregates.get(months[x])[0]);
            netProfitAggregates.get(months[x])[2] = (profitAggregates.get(months[x])[2] - opexAggregates.get(months[x])[0]);

        }

        figuresMap.put('revenue',revenueAggregates);
        figuresMap.put('profit',profitAggregates);
        figuresMap.put('opex',opexAggregates);
        figuresMap.put('netProfit',netProfitAggregates);
        figuresMap.put('totals',totals);

        return figuresMap;
    }

    @RemoteAction
    public static List<Opportunity> getOppsApex(){

        return [SELECT Id, Name FROM Opportunity LIMIT 20];

    }

}