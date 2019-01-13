/**
 * Created by Ronan Williams on 31/07/2018.
 */

public class CashFlowUtils {

    public static Map<Date,CashFlow__c> getFlowMap() {

        List<CashFlow__c> flows = [SELECT Id, Date__c, In__c, Out__c,
                                        InPlus__c, OutPlus__c,
                                        InDescription__c, OutDescription__c,
                                        Balance__c, BalancePlus__c, BalancePredict__c
                                FROM CashFlow__c
                                ORDER BY Date__c ASC];

        Map<Date,CashFlow__c> flowMap = new Map<Date, CashFlow__c>();

        for (CashFlow__c flow : flows){
            flow.In__c            = 0;
            flow.Out__c           = 0;
            flow.InPlus__c        = 0;
            flow.OutPlus__c       = 0;
            flow.InPredict__c     = 0;
            flow.OutPredict__c    = 0;
            flow.OutPlus__c       = 0;
            flow.InDescription__c = '';
            flow.OutDescription__c = '';
            flowMap.put(flow.Date__c,flow);
        }

        return flowMap;
    }


    public static Map<Integer, Decimal> getMonthlyOverheadMap(){

        Map<Integer, Decimal> monthlyOverheads = new Map<Integer, Decimal>();

        for (Integer i = 1; i < 13; i++) {
            monthlyOverheads.put(Date.today().addMonths(i).month(), 0);
        }

        return monthlyOverheads;
    }


    public static HttpRequest doCallout(String query) {

        // build callout parameters
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:QuickBooksOnline/' + query);
        request.setHeader('Accept', 'application/json');
        request.setMethod('GET');
        request.setTimeout(120000);

        return request;

    }


    public static Map<String, Decimal> getPayMap(){

        Map<String,Decimal> payMap = new Map<String,Decimal>();

        AggregateResult[] groupedResults
                = [SELECT Opportunity__r.Account.QuickbooksId__c qid, AVG(PaymentTime__c) time
                    FROM Invoice_Schedule__c
                    WHERE Invoice_Sent__c = TRUE
                    AND Invoice_Paid__c = TRUE
                    AND Opportunity__r.Account.QuickbooksId__c != NULL
                    GROUP BY Opportunity__r.Account.QuickbooksId__c];

        for (AggregateResult ar : groupedResults)  {
            payMap.put((String)ar.get('qid'), (Decimal)ar.get('time'));
        }

        return payMap;
    }

    public static Map<String,QBSupplierProfile__c> getSupplierProfilesMap() {

        Map<String,QBSupplierProfile__c> supplierProfilesMap = new Map<String,QBSupplierProfile__c>();

        QBSupplierProfile__c[] supplierProfiles =  [SELECT SupplierId__c, Name, LastInstance__c, NextInstance__c,
                                                        LastAmount__c, LastBillId__c, Split__c ,Frequency__c,
                                                        DayFrequency__c, Terms__c, Day__c, Category__c
                                                    FROM QBSupplierProfile__c];

        for (QBSupplierProfile__c sp : supplierProfiles){
            supplierProfilesMap.put(sp.SupplierId__c, sp);
        }

        return supplierProfilesMap;
    }



    public static Map<String,String> getCustomerMap(Set<String> invoiceIds) {

        List<Invoice_Schedule__c> schedules = [SELECT Invoice_Id__c, Opportunity__r.Account.Name
                                                FROM Invoice_Schedule__c];

        Map<String,String> customerMap = new Map<String,String>();

        for (Invoice_Schedule__c is : schedules){
            customerMap.put(is.Invoice_Id__c,is.Opportunity__r.Account.Name);
        }

        return customerMap;
    }

    public static Map<String,Date> getUnpaidMap() {

        List<Opportunity> opps = [SELECT Filtered_Job_Number__c, Event_end__c
                                    FROM Opportunity
                                    WHERE StageName = 'Closed Won'
                                    AND PaymentOutstanding__c > 0];

        Map<String,Date> oppMap = new Map<String,Date>();

        for (Opportunity opp : opps){
            oppMap.put(opp.Filtered_Job_Number__c,opp.Event_end__c);
        }

        return oppMap;
    }

    public static Decimal calculateVAT(Date startDate, Date endDate){

        AggregateResult[] groupedOpportunityResults
                = [SELECT SUM(Amount_Calder__c)revenue, SUM(Filtered_Cost_of_Sale__c)cos
                    FROM Opportunity
                    WHERE StageName = 'Closed Won'
                    AND Event_end__c >= :startDate
                    AND Event_end__c <= :endDate];

        Decimal revenueVAT  = (groupedOpportunityResults[0].get('revenue') != null) ?
                                ((Decimal)groupedOpportunityResults[0].get('revenue')) * 0.19 : 0;
        Decimal cosVAT      = (groupedOpportunityResults[0].get('cos') != null) ?
                                ((Decimal)groupedOpportunityResults[0].get('cos')) * 0.15 : 0;

        AggregateResult[] groupedOpexResults
                = [SELECT SUM(Actual__c)actual
                    FROM QBProfitAndLoss__c
                    WHERE Opex__c = TRUE
                    AND Month__c >= :startDate
                    AND Month__c <= :endDate];

        Decimal opexVAT = (groupedOpexResults[0].get('actual') != null) ?
                ((Decimal)groupedOpexResults[0].get('actual')) * 0.1 : 0;

        return (revenueVAT - (cosVAT + opexVAT));
    }


    public static Map<Date,List<Opportunity>> getPedictiveCashFlow(){

        Map<Date,List<Opportunity>> unknownOpportunitiesByDates = new Map<Date,List<Opportunity>>();

        Date onePriorStart  = Date.today().addYears(-1);
        Date onePriorEnd    = Date.today().addYears(-1).addDays(180);
        Date twoPriorStart  = Date.today().addYears(-2);
        Date twoPriorEnd    = Date.today().addYears(-2).addDays(180);

        List<Opportunity> unknownOpportunities = [SELECT Id, Name, Event_end__c, Amount_Calder__c,
                                                        Filtered_Cost_of_Sale__c, Account.Name, Filtered_Job_Number__c,
                                                        Account.MostRecentOpportunity__c
                                                FROM Opportunity
                                                WHERE StageName = 'Closed Won'
                                                AND One_off_Event__c != TRUE
                                                AND ((Event_end__c < :onePriorEnd AND CreatedDate > :onePriorStart)
                                                OR (Event_end__c < :twoPriorEnd AND CreatedDate > :twoPriorStart))];

        for (Opportunity opp : unknownOpportunities) {

            Date oppDate = (opp.Event_end__c.year() == Date.today().year() - 2) ?
                    opp.Event_end__c.addYears(2).addMonths(1).toStartOfMonth().addDays(20).toStartOfWeek().addDays(3) :
                    opp.Event_end__c.addYears(1).addMonths(1).toStartOfMonth().addDays(20).toStartOfWeek().addDays(3);

            if (!unknownOpportunitiesByDates.containsKey(oppDate)) {
                unknownOpportunitiesByDates.put(oppDate, new List<Opportunity>());
            }

            unknownOpportunitiesByDates.get(oppDate).add(opp);
        }

        return unknownOpportunitiesByDates;

    }

}