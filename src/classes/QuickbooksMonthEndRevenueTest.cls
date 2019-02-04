/**
 * Created by Ronan Williams on 04/12/2018.
 */

@IsTest
public class QuickbooksMonthEndRevenueTest {

    @TestSetup
    public static void doSetup(){

        insert new Account(Name = 'Test');

        // opp from prior month which is fully invoiced and has corresponding QB Invoice
        Opportunity opp1    = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp1.AccountId      = [SELECT Id FROM Account LIMIT 1].Id;
        opp1.Name           = 'CURRENT';
        opp1.StageName      = 'Closed Won';
        opp1.Committed__c   = true;
        opp1.Amount         = 1000;
        opp1.Calder_Opportunity__c = true;
        opp1.CommittedRevenue__c = 900;
        opp1.Invoice_Schedule__c = 'Single up-front invoice';
        opp1.Event_start__c = Date.today().toStartOfMonth().addMonths(-1);
        opp1.Event_end__c   = Date.today().toStartOfMonth().addMonths(-1);
        opp1.Committed__c   = true;
        insert opp1;

        // update invoice schedules
        List<Invoice_Schedule__c> opp1Schedules = [SELECT Id
                                                    FROM Invoice_Schedule__c
                                                    WHERE Opportunity__c = :opp1.Id];

        for (Invoice_Schedule__c schedule : opp1Schedules){
            schedule.Invoice_Sent__c = true;
        }

        update opp1Schedules;

        // opp from two months prior which is fully invoiced and has corresponding QB Journal
        Opportunity opp4    = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp4.AccountId      = [SELECT Id FROM Account LIMIT 1].Id;
        opp4.Name           = 'PAST INVOICED';
        opp4.StageName      = 'Closed Won';
        opp4.Committed__c   = true;
        opp4.Amount         = 1000;
        opp4.CommittedRevenue__c = 1000;
        opp4.QuickbooksClassId__c = '12345';
        opp4.Invoice_Schedule__c = 'Single up-front invoice';
        opp4.Event_start__c = Date.today().toStartOfMonth().addMonths(-1);
        opp4.Event_end__c   = Date.today().toStartOfMonth().addMonths(-1);
        insert opp4;

        // update invoice schedules
        List<Invoice_Schedule__c> opp4Schedules = [SELECT Id
                                                    FROM Invoice_Schedule__c
                                                    WHERE Opportunity__c = :opp4.Id];

        for (Invoice_Schedule__c schedule : opp4Schedules){
            schedule.Invoice_Sent__c = true;
        }

        update opp4Schedules;

        // opp from month prior which is not invoiced and should be accrued
        Opportunity opp5    = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp5.AccountId      = [SELECT Id FROM Account LIMIT 1].Id;
        opp5.StageName      = 'Closed Won';
        opp5.Committed__c   = true;
        opp5.Name           = 'PAST NOT INVOICED';
        opp5.Amount         = 1000;
        opp5.CommittedRevenue__c = 1000;
        opp5.Invoice_Schedule__c = 'Single up-front invoice';
        opp5.Event_start__c = Date.today().toStartOfMonth().addMonths(-1);
        opp5.Event_end__c   = Date.today().toStartOfMonth().addMonths(-1);
        insert opp5;

        // opp from current month which is invoiced and should be deferred
        Opportunity opp6    = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp6.AccountId      = [SELECT Id FROM Account LIMIT 1].Id;
        opp6.StageName      = 'Closed Won';
        opp6.Name           = 'FUTURE';
        opp6.Amount         = 1000;
        opp1.Calder_Opportunity__c = true;
        opp6.Invoice_Schedule__c = 'Single up-front invoice';
        opp6.Event_start__c = Date.today().toStartOfMonth();
        opp6.Event_end__c   = Date.today().toStartOfMonth();
        insert opp6;

        // update invoice schedules
        List<Invoice_Schedule__c> opp6Schedules = [SELECT Id FROM Invoice_Schedule__c
                                                    WHERE Opportunity__c = :opp6.Id];

        for (Invoice_Schedule__c schedule : opp6Schedules){
            schedule.Invoice_Sent__c = true;
        }

        update opp6Schedules;

    }


    @IsTest
    public static void testJournalCreate(){

        // calculate PNL target amount
        String monthStart           = String.valueOf(Date.today().addMonths(-1).toStartOfMonth().addDays(-1)).substring(0, 10);
        String monthEnd             = String.valueOf(Date.today().toStartOfMonth()).substring(0, 10);
        String lastDayOfPriorMonth  = String.valueOf(Date.today().toStartOfMonth().addDays(-1)).substring(0, 10);

        String currentOppInvoiceId  = [SELECT Invoice_Id__c FROM Invoice_Schedule__c
                                        WHERE Opportunity__r.Name = 'CURRENT'].Invoice_Id__c;
        String futureOppInvoiceId   = [SELECT Invoice_Id__c FROM Invoice_Schedule__c
                                        WHERE Opportunity__r.Name = 'FUTURE'].Invoice_Id__c;

        MonthEndInvoiceJournalMock invMock              = new MonthEndInvoiceJournalMock(currentOppInvoiceId,futureOppInvoiceId);
        MonthEndRevenueJournalMock jrnlMock             = new MonthEndRevenueJournalMock();
        MonthEndCreditMemoJournalMock memoMock          = new MonthEndCreditMemoJournalMock(currentOppInvoiceId,futureOppInvoiceId);
        MonthEndInvoiceJournalMock invFutureMock        = new MonthEndInvoiceJournalMock('SI90998','SI90999');
        MonthEndCreditMemoJournalMock memoFutureMock    = new MonthEndCreditMemoJournalMock('SI90998','SI90999');

        Map<String, HttpCalloutMock> endpoint2TestResp  = new Map<String,HttpCalloutMock>();

        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20invoice%20where%20TxnDate%20%3e%20%27' +
                                monthStart + '%27%20and%20TxnDate%20%3c%20%27' + monthEnd + '%27&minorversion=4', invMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20journalentry%20where%20Id%20%3d%20%27' +
                                '23133' + '%27&minorversion=4', jrnlMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20creditMemo%20where%20TxnDate%20%3e%20%27' +
                                monthStart + '%27%20and%20TxnDate%20%3c%20%27' + monthEnd + '%27&minorversion=4', memoMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20invoice%20where%20TxnDate%20%3e%20%27' +
                                lastDayOfPriorMonth + '%27&minorversion=4', invFutureMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20creditMemo%20where%20TxnDate%20%3e%20%27' +
                                lastDayOfPriorMonth + '%27&minorversion=4', memoFutureMock);

        CashFlowMultiRequestMock cashMultiMock = new CashFlowMultiRequestMock(endpoint2TestResp);

        Test.setMock(HttpCalloutMock.class, cashMultiMock);

        Test.startTest();
        QuickbooksMonthEndRevenue.calculateRevenueJournal(Date.today().addMonths(-1).toStartOfMonth(), new Set<String>{'23133'});
        Test.stopTest();

    }

    @IsTest
    public static void testJournalPost(){

        QBJournal__c journal = new QBJournal__c(
                DocNumber__c = 'Test',
                TxnDate__c   = Date.today().toStartOfMonth().addMonths(-1),
                Target__c    = '4000 Revenue'
        );

        insert journal;

        QBJournalEntry__c entry1 = new QBJournalEntry__c(
                QBJournal__c        = journal.Id,
                Description__c      = 'Pxx Mgt Accs Defer sales ' +
                        System.now().addMonths(-1).format('MMM') + ' ' +
                        String.valueOf(Date.today().addMonths(-1).year()).substring(2) + ' YTD',
                PostingType__c      = 'Credit',
                AccountRefId__c     = '333',
                AccountRefName__c   = '',
                Amount__c           = 10,
                ClassRefId__c       = '333',
                ClassRefName__c     = 'Test'
        );

        insert entry1;

        QBJournalEntry__c entry2 = new QBJournalEntry__c(
                QBJournal__c        = journal.Id,
                Description__c      = 'Pxx Mgt Accs Defer sales ' +
                        System.now().addMonths(-1).format('MMM') + ' ' +
                        String.valueOf(Date.today().addMonths(-1).year()).substring(2) + ' YTD',
                PostingType__c      = 'Debit',
                AccountRefId__c     = '333',
                AccountRefName__c   = '',
                Amount__c           = 10,
                ClassRefId__c       = '333',
                ClassRefName__c     = 'Test'
        );

        insert entry2;

        Test.setMock(HttpCalloutMock.class, new MonthEndRevenueJournalPostMock());

        Test.startTest();
        QuickbooksMonthEndJournal.postRevenueJournal();
        Test.stopTest();

    }
}