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
    public static Map<String,List<Decimal>> getOppRevenueTotals(String start, String endD){

        Date startDate      = Date.valueOf(start);
        Date endDate        = Date.valueOf(endD);

        Map<String,List<Decimal>> revenueAggregates = buildMap(start,endD);

        List<String> months = new List<String>();
        months.addAll(revenueAggregates.keySet());

        for (Opportunity opp : [SELECT Amount_Calder__c, Probability, StageName,
                                        EventMonthYear__c, Committed__c, CommittedRevenue__c, CommittedProfit__c,
                                        Gross_profit_2__c, Event_End_Grouping__c,
                                        EventMonthString__c
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
    public static Map<String,List<Decimal>> getOppProfitTotals(String start, String endD){

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
    public static List<Opportunity> getOppsApex(){

        return [SELECT Id, Name FROM Opportunity LIMIT 20];

    }

}