/**
 * Created by Ronan Williams on 20/06/2018.
 */

@IsTest
public class CashFlowControlTest {

    @TestSetup
    public static void doSetup(){

        List<CashFlow__c> flows = new List<CashFlow__c>();

        for (Integer i = -2; i < 500; i++){
            CashFlow__c c = new CashFlow__c(Number__c = i);
            flows.add(c);
        }

        insert flows;

        insert new Account(Name = 'Test');

        Opportunity opp1 = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp1.AccountId = [SELECT Id FROM Account LIMIT 1].Id;
        opp1.StageName = 'Closed Won';
        opp1.Amount = 1200;
        opp1.Invoice_Schedule__c = 'Three stage invoice';
        opp1.Event_start__c = Date.today().addDays(20);
        opp1.Event_end__c = Date.today().addDays(20);
        insert opp1;

        Opportunity opp2 = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp2.AccountId = [SELECT Id FROM Account LIMIT 1].Id;
        opp2.StageName = 'Costed Prospect';
        opp2.Probability = 50;
        opp2.Amount = 1200;
        opp2.Invoice_Schedule__c = 'Three stage invoice';
        opp2.Event_start__c = Date.today().addDays(40);
        opp2.Event_end__c = Date.today().addDays(40);
        insert opp2;

        Opportunity opp3 = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp3.AccountId = [SELECT Id FROM Account LIMIT 1].Id;
        opp3.StageName = 'Costed Prospect';
        opp3.Probability = 90;
        opp3.Amount = 111200;
        opp3.Forecast_COS__c = 50000;
        opp3.Invoice_Schedule__c = 'Three stage invoice';
        opp3.Event_start__c = Date.today().addDays(40);
        opp3.Event_end__c = Date.today().addDays(40);
        insert opp3;

        Opportunity opp4 = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp4.AccountId = [SELECT Id FROM Account LIMIT 1].Id;
        opp4.StageName = 'Closed Won';
        opp4.Probability = 100;
        opp4.Amount = 211200;
        opp4.Forecast_COS__c = 50000;
        opp4.Invoice_Schedule__c = 'Three stage invoice';
        opp4.Event_start__c = Date.today().addDays(40);
        opp4.Event_end__c = Date.today().addDays(40);
        insert opp4;

        Opportunity opp5 = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp5.AccountId = [SELECT Id FROM Account LIMIT 1].Id;
        opp5.StageName = 'Closed Won';
        opp5.Probability = 100;
        opp5.Amount = 11200;
        opp5.Forecast_COS__c = 800;
        opp5.Invoice_Schedule__c = 'Three stage invoice';
        opp5.Event_start__c = Date.today().addDays(40);
        opp5.Event_end__c = Date.today().addDays(40);
        insert opp5;

        Opportunity opp6 = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp6.AccountId = [SELECT Id FROM Account LIMIT 1].Id;
        opp6.StageName = 'Closed Won';
        opp6.Probability = 100;
        opp6.Amount = 11200;
        opp6.Forecast_COS__c = 800;
        opp6.Invoice_Schedule__c = 'Three stage invoice';
        opp6.Event_start__c = Date.today().addYears(-1).addDays(170);
        opp6.Event_end__c = Date.today().addYears(-1).addDays(170);
        opp6.CreatedDate = Date.today().addYears(-1).addDays(1);
        insert opp6;

        List<CashFlowEntry__c> entries = new List<CashFlowEntry__c>();

        entries.add(new CashFlowEntry__c(
                InFlow__c       = flows[1].Id,
                Source__c       = 'Quickbooks',
                Category__c     = 'Credit card',
                Description__c  = 'Credit card',
                Details__c      = 'Credit card',
                Amount__c       = 100,
                QuickbooksId__c = 'Credit card',
                Adjusted__c     = true,
                AmountAdjusted__c = true
        ));

        entries.add(new CashFlowEntry__c(
                OutFlow__c       = flows[2].Id,
                Source__c       = 'Quickbooks',
                Category__c     = 'Credit card',
                Description__c  = 'Credit card',
                Details__c      = 'Credit card',
                Amount__c       = 100,
                QuickbooksId__c = 'Credit card',
                Paid__c     = true
        ));

        entries.add(new CashFlowEntry__c(
                OutFlow__c       = flows[3].Id,
                Source__c       = 'Quickbooks',
                Category__c     = 'Credit card',
                Description__c  = 'Credit card',
                Details__c      = 'Credit card',
                Amount__c       = 100,
                QuickbooksId__c = 'Credit card',
                Adjusted__c     = true
        ));

        entries.add(new CashFlowEntry__c(
                OutFlow__c       = flows[4].Id,
                Source__c       = 'Custom',
                Category__c     = 'Credit card',
                Description__c  = 'Credit card',
                Details__c      = 'Credit card',
                Amount__c       = 100,
                QuickbooksId__c = 'Credit card',
                Paid__c     = true
        ));

        insert entries;

        List<QBSupplierProfile__c> profiles = new List<QBSupplierProfile__c>();

        profiles.add(new QBSupplierProfile__c(
                Name            = 'PHS Group Ltd',
                SupplierId__c   = '1409',
                Category__c     = 'Payment run',
                Frequency__c    = 12,
                DayFrequency__c = 0,
                Day__c          = 0,
                Split__c        = 1,
                Terms__c        = 'Direct debit'
        ));

        profiles.add(new QBSupplierProfile__c(
                Name            = 'Castle Water Limited',
                SupplierId__c   = '1352',
                Category__c     = 'Freelancers',
                Frequency__c    = 12,
                DayFrequency__c = 0,
                Day__c          = 0,
                Split__c        = 1,
                Terms__c        = 'Post payment',
                NextInstance__c = Date.today()
        ));

        insert profiles;


    }

    @IsTest
    public static void buildFlow(){

        String dateValue            = String.valueOf(Date.today().addDays(-35)).substring(0,10);
        String startValue           = String.valueOf(Date.today().addMonths(-3).toStartOfMonth()).substring(0, 10);
        String endValue             = String.valueOf(Date.today().toStartOfMonth()).substring(0, 10);
        String dividendDateValue    = String.valueOf(Date.today().addDays(-35)).substring(0,10);

        JSONParserQBOInvoiceFlowMock invMock        = new JSONParserQBOInvoiceFlowMock();
        JSONParserQBOBillFlowMock billMock1         = new JSONParserQBOBillFlowMock();
        JSONParserQBOBillFlowMock billMock2         = new JSONParserQBOBillFlowMock();
        JSONParserQBOCurrentAccountMock accMock     = new JSONParserQBOCurrentAccountMock();
        JSONParserQBOJournalFlowMock jrnlMock       = new JSONParserQBOJournalFlowMock();
        JSONParserQBOJournalFlowMock divMock        = new JSONParserQBOJournalFlowMock();

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20invoice%20where%20Balance%20%3e%20%270%27&minorversion=4',invMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20bill%20where%20Balance%20%21%3d%20%270%27&minorversion=4',billMock1);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20bill%20where%20metadata.createtime%20%3e%20%27' + startValue +
                                                    'T02%3a32%3a09-07%3a00%27%20and%20metadata.createtime%20%3c%20%27' + endValue +
                                                    'T02%3a32%3a09-07%3a00%27%20MAXRESULTS%20500&minorversion=4',billMock2);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20account%20where%20name%20%3d%20%27Bank%20Current%20Account%27&minorversion=4',accMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20journalentry%20where%20TxnDate%20%3e%20%27'
                + dateValue + '%27&minorversion=4',jrnlMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20journalentry%20where%20docNumber%' + '20Like%20%27%25dividend%25%27%20and%20TxnDate%20%3e%20%27'
                + dividendDateValue + '%27&minorversion=4',divMock);

        CashFlowMultiRequestMock cashMultiMock = new CashFlowMultiRequestMock(endpoint2TestResp);

        Test.setMock(HttpCalloutMock.class, cashMultiMock);

        Test.startTest();
        CashFlowControl.buildFlow();
        Test.stopTest();

        CashFlowReviewController cfc = new CashFlowReviewController();
        cfc.newEntry.Description__c = 'test';
        cfc.newEntry.Amount__c = 100;
        cfc.newEntryDate = Date.today();
        cfc.insertEntry();

    }
}