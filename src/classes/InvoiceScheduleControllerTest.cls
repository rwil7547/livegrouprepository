/**
 * Created by Ronan Williams on 15/05/2018.
 */

@IsTest
public class InvoiceScheduleControllerTest {

    @TestSetup
    static void createOpportunities() {

        insert new Account(Name = 'Test');

        List<Opportunity> opps = new List<Opportunity>();

        Opportunity opp1 = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp1.AccountId = [SELECT Id FROM Account LIMIT 1].Id;
        opp1.StageName = 'Closed Won';
        opp1.Amount = 1200;
        opp1.Invoice_Schedule__c = 'Three stage invoice';
        opp1.Event_start__c = Date.today();
        opp1.Event_end__c = Date.today();
        opps.add(opp1);

        Opportunity opp2 = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp2.AccountId = [SELECT Id FROM Account LIMIT 1].Id;
        opp2.StageName = 'Closed Won';
        opp2.Amount = 1200;
        opp2.Invoice_Schedule__c = 'Three stage invoice';
        opp2.Event_start__c = Date.today().addDays(-35);
        opp2.Event_end__c = Date.today().addDays(-35);
        opps.add(opp2);

        Opportunity opp3 = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp3.AccountId = [SELECT Id FROM Account LIMIT 1].Id;
        opp3.StageName = 'Closed Won';
        opp3.Amount = 1200;
        opp3.Invoice_Schedule__c = 'Three stage invoice';
        opp3.Event_start__c = Date.today().addDays(-70);
        opp3.Event_end__c = Date.today().addDays(-70);
        opps.add(opp3);

        insert opps;

        // determine range via custom setting
        insert new CDCRange__c(Name = 'QuickbooksCDC', Days__c = 1);

    }

    @IsTest
    static void testController(){

        // verify that the values returned by the controller upon load are correct
        InvoiceScheduleController isc = new InvoiceScheduleController();

        System.assertEquals(3,isc.copps.size());
        System.assertEquals(3,isc.coppsMap.size());
        System.assertEquals(3,isc.monthGroupings.size());

        // verify the values returned by the controller are correct when the date
        // range is changed
        isc.defaultStart = Date.today();
        isc.defaultEnd = Date.today();
        PageReference updateRetrun = isc.processOppsRange();

        System.assertEquals(1,isc.copps.size());
        System.assertEquals(1,isc.coppsMap.size());
        System.assertEquals(1,isc.monthGroupings.size());

        // verify that the controller values remain the same when the save method is called
        PageReference saveReturn = isc.saveChanges();

        System.assertEquals(1,isc.copps.size());
        System.assertEquals(1,isc.coppsMap.size());
        System.assertEquals(1,isc.monthGroupings.size());

        // vefrify that the update invoice function works
        isc.invoiceDate = String.valueOf(Date.today()).substring(0,10);
        isc.currentId = [SELECT Id FROM Invoice_Schedule__c WHERE Invoice_Sent__c = False LIMIT 1].Id;
        isc.currentAmount = '100';

        PageReference updateInvoiceReturn = isc.updateInvoiceDate();
        Invoice_Schedule__c is = [SELECT Send_Date__c, Amount__c FROM Invoice_Schedule__c WHERE Id = :isc.currentId];
        System.assertEquals(Date.today(),is.Send_Date__c);
        System.assertEquals(100,is.Amount__c);
        

//        // verify that the controller values are reset to defaults when the quickbooks callout
//        // is made
//        Test.startTest();
//        Test.setMock(HttpCalloutMock.class, new InvoiceCDCMock('12345'));
//        PageReference calloutReturn = isc.calloutQuickbooks();
//        Test.stopTest();
//
//        System.assertEquals(3,isc.copps.size());
//        System.assertEquals(3,isc.coppsMap.size());
//        System.assertEquals(3,isc.monthGroupings.size());
    }

}