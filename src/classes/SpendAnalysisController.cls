/**
 * Created by Ronan Williams on 18/07/2018.
 */

public class SpendAnalysisController {

    public static void distributeSpend() {

        // DELETE OLD DISTRIBUTIONS
        List<Spend_Distribution__c> oldDistributions = [SELECT Id FROM Spend_Distribution__c];

        if (!oldDistributions.isEmpty()){
            delete oldDistributions;
        }

        // INSTANTIATE NEW DISTRIBUTIONS
        Map<Integer,Spend_Distribution__c> newDistributions = new Map<Integer,Spend_Distribution__c>();

        for (Integer x = -50 ; x < 50; x++){
            Spend_Distribution__c sd = new Spend_Distribution__c();
            sd.Name = String.valueOf(x);
            newDistributions.put(x, sd);
        }

        // CALCULATE EXPENDITURE DISTRIBUTION
        Map<Integer,Decimal> revMap = new Map<Integer,Decimal>();
        Map<Integer,Decimal> cosMap = new Map<Integer,Decimal>();

        for (Integer x = -20 ; x < 21 ; x++){
            revMap.put(x,0);
            cosMap.put(x,0);
        }

        List<Opportunity> closedOpps = [SELECT Id, Event_end__c, Amount_Calder__c, Filtered_Cost_of_Sale__c,
                                                Quickbooks_COS__c, Percent_Invoiced__c,
                                            (SELECT Amount__c, Payment_Date__c FROM Invoice_Schedules__r),
                                            (SELECT Amount__c, Due_Date__c FROM Expenses__r)
                                        FROM Opportunity
                                        WHERE StageName = 'Closed Won'];

        System.debug('Number of opss is' + closedOpps.size() + ' and ' + closedOpps[0].Percent_Invoiced__c);

        Integer revCount = 0;
        Integer cosCount = 0;


        for (Opportunity opp : closedOpps){

            if (opp.Invoice_Schedules__r.size() > 0) revCount += 1;
            if (opp.Expenses__r.size() > 0) cosCount += 1;

            System.debug('Number of expenses is' + opp.Expenses__r.size());

            for (Invoice_Schedule__c is : opp.Invoice_Schedules__r) {

                Integer range = Integer.valueOf(opp.Event_end__c.daysBetween(is.Payment_Date__c) / 7);
                Decimal amount = (opp.Amount_Calder__c == 0) ? 1 : opp.Amount_Calder__c;

                if (revMap.containsKey(range)) {
                    revMap.put(range, revMap.get(range) + ((is.Amount__c / amount) * 100));
                } else {
                    revMap.put(range, (is.Amount__c / amount) * 100);
                }

            }

            for (Expense__c ex : opp.Expenses__r) {

                Integer range = Integer.valueOf(opp.Event_end__c.daysBetween(ex.Due_Date__c) / 7);
                Decimal amount = (opp.Quickbooks_COS__c == 0) ? 1 : opp.Quickbooks_COS__c;

                if (cosMap.containsKey(range)) {
                    cosMap.put(range, cosMap.get(range) + ((ex.Amount__c / amount) * 100));
                } else {
                    cosMap.put(range, (ex.Amount__c / amount) * 100);
                }

            }

        }

        Decimal cosTotal = 0;
        Decimal revTotal = 0;

        for (Integer x : cosMap.keySet()){
            cosMap.put(x, (cosMap.get(x) / cosCount));
            cosTotal += cosMap.get(x);

        }

        for (Integer x : revMap.keySet()){
            revMap.put(x, (revMap.get(x) / revCount));
            revTotal += revMap.get(x);

        }

        // ASSIGN DISTRUBUTIONS TO MAP
        for (Spend_Distribution__c sd : newDistributions.values()){

            if (revMap.containsKey(Integer.valueOf(sd.Name))){
                sd.In__c = revMap.get(Integer.valueOf(sd.Name));
            }
            if (cosMap.containsKey(Integer.valueOf(sd.Name))){
                sd.Out__c = cosMap.get(Integer.valueOf(sd.Name));
            }

        }

        // INSERT NEW RECORDS
        insert newDistributions.values();

        System.debug('Rev total is :' + revTotal + ' and revCount is  :' +  revCount);
        System.debug('Cos total is :' + cosTotal + ' and cosCount is ' +  cosCount);

    }

}