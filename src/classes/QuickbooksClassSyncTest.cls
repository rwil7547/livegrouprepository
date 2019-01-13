/**
 * Created by Ronan Williams on 22/11/2018.
 */

@IsTest
public class QuickbooksClassSyncTest {

    @TestSetup
    public static void doSetup(){

        Account acc = (Account)SmartFactory.createSObject('Account');
        insert acc;

        Opportunity opp = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp.Clive_job_number__c = 12345;
        opp.AccountId           = acc.Id;
        opp.Amount              = 5000;
        opp.StageName           = 'Closed Won';
        opp.Invoice_Schedule__c = 'Single post-event invoice';
        opp.Event_start__c      = Date.today();
        opp.Event_end__c        = Date.today();
        insert opp;

        Opportunity opp2 = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp2.Clive_job_number__c = 54321;
        opp2.AccountId          = acc.Id;
        opp2.Amount             = 5000;
        opp2.StageName          = 'Closed Won';
        opp2.Invoice_Schedule__c = 'Single post-event invoice';
        opp2.Event_start__c     = Date.today();
        opp2.Event_end__c       = Date.today();
        insert opp2;

        Opportunity opp3 = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp3.Clive_job_number__c = 11111;
        opp3.AccountId          = acc.Id;
        opp3.Amount             = 5000;
        opp3.StageName          = 'Closed Won';
        opp3.Invoice_Schedule__c = 'Single post-event invoice';
        opp3.Event_start__c     = Date.today();
        opp3.Event_end__c       = Date.today();
        insert opp3;

    }

    @IsTest
    public static void testRefreshClassSync(){

        // set mock attributes
        QuickbooksClassQueryMock queryMock  = new QuickbooksClassQueryMock();
        QuickbooksClassPostMock postMock    = new QuickbooksClassPostMock();

        Map<String, HttpCalloutMock> mockMap = new Map<String,HttpCalloutMock>();
        mockMap.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20class%20order%20by%20' +
                'MetaData.CreateTime%20desc%20maxresults%201000&minorversion=4',queryMock);
        mockMap.put('callout:QuickBooksOnline/batch?minorversion=4',postMock);

        MultiRequestMock multiMock = new MultiRequestMock(mockMap);

        Test.setMock(HttpCalloutMock.class, multiMock);

        Test.startTest();
        QuickbooksClassSync.refreshClassSync(new Map<String,String>());
        Test.stopTest();

    }

    @IsTest
    public static void testOppTriggerCallout(){

        // set mock attributes
        QuickbooksClassQueryMock queryMock  = new QuickbooksClassQueryMock();
        QuickbooksClassPostMock postMock    = new QuickbooksClassPostMock();

        Map<String, HttpCalloutMock> mockMap = new Map<String,HttpCalloutMock>();
        mockMap.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20class%20order%20by%20' +
                'MetaData.CreateTime%20desc%20maxresults%201000&minorversion=4',queryMock);
        mockMap.put('callout:QuickBooksOnline/batch?minorversion=4',postMock);

        MultiRequestMock multiMock = new MultiRequestMock(mockMap);

        Account acc = (Account)SmartFactory.createSObject('Account');
        insert acc;

        Opportunity opp = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp.Clive_job_number__c = 12345;
        opp.AccountId           = acc.Id;
        opp.Amount              = 5000;
        opp.StageName           = 'Costed prospect';
        opp.Invoice_Schedule__c = 'Single post-event invoice';
        opp.Event_start__c      = Date.today();
        opp.Event_end__c        = Date.today();
        insert opp;

        Test.startTest();
        opp.StageName  = 'Closed Won';
        update opp;
        Test.stopTest();
    }
}