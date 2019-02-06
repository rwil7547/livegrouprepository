/**
 * Created by Ronan Williams on 07/12/2018.
 */

@IsTest
public class QuickbooksMonthEndCOSTest {

    @TestSetup
    public static void doSetup(){

        insert new Account(Name = 'Test');

        // opp from prior month which is fully expensed and has corresponding QB Bill
        Opportunity opp1    = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp1.AccountId      = [SELECT Id FROM Account LIMIT 1].Id;
        opp1.Name           = 'CURRENT';
        opp1.StageName      = 'Closed Won';
        opp1.Committed__c   = true;
        opp1.Amount         = 1000;
        opp1.Calder_Opportunity__c = true;
        opp1.CommittedRevenue__c = 900;
        opp1.CommittedProfit__c = 400;
        opp1.CommittedCOS__c = 500;
        opp1.Forecast_COS__c = 500;
        opp1.QuickbooksClassId__c = '1111';
        opp1.Invoice_Schedule__c = 'Single up-front invoice';
        opp1.Event_start__c = Date.today().toStartOfMonth().addMonths(-1);
        opp1.Event_end__c   = Date.today().toStartOfMonth().addMonths(-1);
        opp1.Committed__c   = true;
        insert opp1;

        // insert expense
        insert new Expense__c(
                Opportunity__c  = opp1.Id,
                Amount__c       = 500,
                QuickbooksId__c = '1111',
                Description__c  = 'Test'
        );

        // opp from month prior which needs to be accrued
        Opportunity opp4    = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp4.AccountId      = [SELECT Id FROM Account LIMIT 1].Id;
        opp4.Name           = 'PAST NOT EXPENSED';
        opp4.StageName      = 'Closed Won';
        opp4.Committed__c   = true;
        opp4.Amount         = 1000;
        opp4.CommittedRevenue__c = 1000;
        opp1.CommittedProfit__c = 400;
        opp1.CommittedCOS__c = 500;
        opp4.QuickbooksClassId__c = '1112';
        opp1.Forecast_COS__c = 500;
        opp4.Invoice_Schedule__c = 'Single up-front invoice';
        opp4.Event_start__c = Date.today().toStartOfMonth().addMonths(-1);
        opp4.Event_end__c   = Date.today().toStartOfMonth().addMonths(-1);
        insert opp4;

        // opp from two months prior which is expensed and has associated Deferred QB Journal
        Opportunity opp5    = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp5.AccountId      = [SELECT Id FROM Account LIMIT 1].Id;
        opp5.StageName      = 'Closed Won';
        opp5.Committed__c   = true;
        opp5.Name           = 'PAST EXPENSED';
        opp5.Amount         = 1000;
        opp5.CommittedRevenue__c = 1000;
        opp1.CommittedProfit__c = 400;
        opp1.CommittedCOS__c = 500;
        opp5.QuickbooksClassId__c = '1114';
        opp5.Forecast_COS__c = 500;
        opp5.Invoice_Schedule__c = 'Single up-front invoice';
        opp5.Event_start__c = Date.today().toStartOfMonth().addMonths(-1);
        opp5.Event_end__c   = Date.today().toStartOfMonth().addMonths(-1);
        insert opp5;

        // insert expense
        insert new Expense__c(
                Opportunity__c  = opp5.Id,
                Amount__c       = 500,
                QuickbooksId__c = '1112',
                Description__c  = 'Test'
        );

        // opp from current month which is expensed and should be deferred
        Opportunity opp6    = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp6.AccountId      = [SELECT Id FROM Account LIMIT 1].Id;
        opp6.StageName      = 'Closed Won';
        opp6.Name           = 'FUTURE EXPENSED';
        opp6.Amount         = 1000;
        opp6.QuickbooksClassId__c = '1115';
        opp6.Forecast_COS__c = 500;
        opp6.Invoice_Schedule__c = 'Single up-front invoice';
        opp6.Event_start__c = Date.today().toStartOfMonth();
        opp6.Event_end__c   = Date.today().toStartOfMonth();
        insert opp6;

        // insert expense
        insert new Expense__c(
                Opportunity__c  = opp6.Id,
                Amount__c       = 500,
                QuickbooksId__c = '1112',
                Description__c  = 'Test'
        );

        SalesDashboardUtils.commitOpportunites();
//        SalesDashboardUtils.adjustOpportunities();

    }

    @IsTest
    public static void testJournalCreate(){

        // calculate PNL target amount
        String monthStart           = String.valueOf(Date.today().addMonths(-1).toStartOfMonth().addDays(-1)).substring(0, 10);
        String monthEnd             = String.valueOf(Date.today().toStartOfMonth()).substring(0, 10);
        String lastDayOfPriorMonth  = String.valueOf(Date.today().toStartOfMonth().addDays(-1)).substring(0, 10);

        MonthEndBillJournalMock billMock                    = new MonthEndBillJournalMock();
        MonthEndCosAccJournalMock accJrnlMock               = new MonthEndCosAccJournalMock();
        MonthEndCosDefJournalMock defJrnlMock               = new MonthEndCosDefJournalMock();
        MonthEndVendorCreditJournalMock creditMock          = new MonthEndVendorCreditJournalMock();
        MonthEndBillJournalMock futureBillMock              = new MonthEndBillJournalMock();
        MonthEndVendorCreditJournalMock futurecreditMock    = new MonthEndVendorCreditJournalMock();

        Map<String, HttpCalloutMock> endpoint2TestResp      = new Map<String,HttpCalloutMock>();

        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20bill%20where%20TxnDate%20%3e%20%27' +
                monthStart + '%27%20and%20TxnDate%20%3c%20%27' + monthEnd + '%27%20maxResults%201000&minorversion=4', billMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20journalentry%20where%20Id%20%3d%20%27' +
                '23363' + '%27&minorversion=4', accJrnlMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20journalentry%20where%20Id%20%3d%20%27' +
                '23364' + '%27&minorversion=4', defJrnlMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20VendorCredit%20where%20TxnDate%20%3e%20%27' +
                monthStart + '%27%20and%20TxnDate%20%3c%20%27' + monthEnd + '%27&minorversion=4', creditMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20bill%20where%20TxnDate%20%3e%20%27' +
                lastDayOfPriorMonth + '%27&minorversion=4', futureBillMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20VendorCredit%20where%20TxnDate%20%3e%20%27' +
                lastDayOfPriorMonth + '%27&minorversion=4', futurecreditMock);

        CashFlowMultiRequestMock cashMultiMock = new CashFlowMultiRequestMock(endpoint2TestResp);

        Test.setMock(HttpCalloutMock.class, cashMultiMock);

        Test.startTest();
        QuickbooksMonthEndCOS.calculateCOSJournal(Date.today().addMonths(-1).toStartOfMonth(), new Set<String>{'23363'}, new Set<String>{'23364'});
        Test.stopTest();

    }

    @IsTest
    public static void testAccrualJournalPost(){

        QBJournal__c accrualJournal = new QBJournal__c(
                DocNumber__c = 'Test',
                TxnDate__c   = Date.today().toStartOfMonth().addMonths(-1),
                Target__c    = '5000 Cost of sales'
        );

        insert accrualJournal;

        QBJournalEntry__c accrualEntry1 = new QBJournalEntry__c(
                QBJournal__c        = accrualJournal.Id,
                Description__c      = 'Pxx Mgt Accs Acc sales ' +
                        System.now().addMonths(-1).format('MMM') + ' ' +
                        String.valueOf(Date.today().addMonths(-1).year()).substring(2) + ' YTD',
                PostingType__c      = 'Credit',
                AccountRefId__c     = '333',
                AccountRefName__c   = '',
                Amount__c           = 10,
                ClassRefId__c       = '333',
                ClassRefName__c     = 'Test'
        );

        insert accrualEntry1;

        QBJournalEntry__c accryalEntry2 = new QBJournalEntry__c(
                QBJournal__c        = accrualJournal.Id,
                Description__c      = 'Pxx Mgt Accs Acc sales ' +
                        System.now().addMonths(-1).format('MMM') + ' ' +
                        String.valueOf(Date.today().addMonths(-1).year()).substring(2) + ' YTD',
                PostingType__c      = 'Debit',
                AccountRefId__c     = '333',
                AccountRefName__c   = '',
                Amount__c           = 10,
                ClassRefId__c       = '333',
                ClassRefName__c     = 'Test'
        );

        insert accryalEntry2;

        QBJournal__c deferralJournal = new QBJournal__c(
                DocNumber__c = 'Test',
                TxnDate__c   = Date.today().toStartOfMonth().addMonths(-1),
                Target__c    = '5000 Cost of sales'
        );

        insert deferralJournal;

        QBJournalEntry__c deferralEntry1 = new QBJournalEntry__c(
                QBJournal__c        = deferralJournal.Id,
                Description__c      = 'Pxx Mgt Accs Def sales ' +
                        System.now().addMonths(-1).format('MMM') + ' ' +
                        String.valueOf(Date.today().addMonths(-1).year()).substring(2) + ' YTD',
                PostingType__c      = 'Credit',
                AccountRefId__c     = '657',
                AccountRefName__c   = '',
                Amount__c           = 10,
                ClassRefId__c       = '333',
                ClassRefName__c     = 'Test'
        );

        insert deferralEntry1;

        QBJournalEntry__c deferralEntry2 = new QBJournalEntry__c(
                QBJournal__c        = deferralJournal.Id,
                Description__c      = 'Pxx Mgt Accs Acc sales ' +
                        System.now().addMonths(-1).format('MMM') + ' ' +
                        String.valueOf(Date.today().addMonths(-1).year()).substring(2) + ' YTD',
                PostingType__c      = 'Debit',
                AccountRefId__c     = '333',
                AccountRefName__c   = '',
                Amount__c           = 10,
                ClassRefId__c       = '333',
                ClassRefName__c     = 'Test'
        );

        insert deferralEntry2;


        Test.setMock(HttpCalloutMock.class, new MonthEndCosJournalMock());

        Test.startTest();
        QuickbooksMonthEndJournal.postCOSJournals();
        Test.stopTest();

    }
}