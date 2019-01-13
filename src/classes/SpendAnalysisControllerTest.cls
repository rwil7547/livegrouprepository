/**
 * Created by Ronan Williams on 19/07/2018.
 */

@IsTest
public class SpendAnalysisControllerTest {

    @TestSetup
    public static void doSetup(){

        // INSTANTIATE OLD DISTRIBUTIONS
        Map<Integer,Spend_Distribution__c> oldDistributions = new Map<Integer,Spend_Distribution__c>();

        for (Integer x = -50 ; x < 50; x++){
            Spend_Distribution__c sd = new Spend_Distribution__c();
            sd.Name = String.valueOf(x);
            oldDistributions.put(x, sd);
        }

        insert oldDistributions.values();

        // INSERT OPPORTUNITIES WITH INVOICES PAID AND ASSOCIATED EXPENSES
        insert new Account(Name = 'Test');

        Opportunity opp1 = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp1.AccountId = [SELECT Id FROM Account LIMIT 1].Id;
        opp1.StageName = 'Closed Won';
        opp1.Amount = 1200;
        opp1.Forecast_COS__c = 600;
        opp1.Invoice_Schedule__c = 'Three stage invoice';
        opp1.Event_start__c = Date.today();
        opp1.Event_end__c = Date.today();
        insert opp1;

        for (Invoice_Schedule__c is : [SELECT Id FROM Invoice_Schedule__c WHERE Opportunity__c = :opp1.Id]){
            is.Invoice_Sent__c = true;
            is.Invoice_Paid__c = true;
            is.Payment_Date__c = Date.today().addDays(-14);
            update is;
        }

        Expense__c ex1 = new Expense__c();
        ex1.Opportunity__c = opp1.Id;
        ex1.Amount__c  = 600;
        ex1.Due_Date__c = Date.today().addDays(-14);
        insert ex1;

        Opportunity opp2 = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp2.AccountId = [SELECT Id FROM Account LIMIT 1].Id;
        opp2.StageName = 'Closed Won';
        opp2.Amount = 1200;
        opp2.Forecast_COS__c = 600;
        opp2.Invoice_Schedule__c = 'Three stage invoice';
        opp2.Event_start__c = Date.today().addDays(28);
        opp2.Event_end__c = Date.today().addDays(28);
        insert opp2;

        for (Invoice_Schedule__c is : [SELECT Id FROM Invoice_Schedule__c WHERE Opportunity__c = :opp2.Id]){
            is.Invoice_Sent__c = true;
            is.Invoice_Paid__c = true;
            is.Payment_Date__c = Date.today().addDays(14);
            update is;
        }

        Expense__c ex2 = new Expense__c();
        ex2.Opportunity__c = opp2.Id;
        ex2.Amount__c  = 600;
        ex2.Due_Date__c = Date.today().addDays(14);
        insert ex2;

    }

    @IsTest
    public static void testDistributions(){

        SpendAnalysisController.distributeSpend();

        // ASSERT CORRECT VALUES
        System.assertEquals(100, [SELECT Id FROM Spend_Distribution__c].size());
        System.assertEquals(1, [SELECT Id FROM Spend_Distribution__c WHERE In__c > 0].size());
        System.assertEquals(1, [SELECT Id FROM Spend_Distribution__c WHERE Out__c > 0].size());
    }

}