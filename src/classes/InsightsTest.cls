/**
 * Created by Ronan Williams on 18/10/2018.
 */

@IsTest
public class InsightsTest {

    //// TEST SETUP
    @TestSetup
    public static void doSetup() {

        // insert account
        Account acc = new Account(Name = 'TestAcc');
        insert acc;

        SBQQ__Quote__c primaryQuote = new SBQQ__Quote__c();
        primaryQuote.SBQQ__Primary__c = true;
        insert primaryQuote;

        // insert Opportunities
        List<Opportunity> oppsToInsert = new List<Opportunity>();

        // insert won opps
        for (Integer x = 0; x < 13; x++) {

            if (x < 2) {
                Opportunity opp = (Opportunity) SmartFactory.createSObject('Opportunity');
                opp.AccountId = acc.Id;
                opp.Amount = 750001;
                opp.Forecast_COS__c = 1000;
                opp.Committed__c = true;
                opp.CommittedRevenue__c = 1000;
                opp.CommittedCOS__c = 1000;
                opp.CommittedProfit__c = 1000;
                opp.Calder_Opportunity__c = true;
                opp.StageName = 'Closed Won';
                opp.SBQQ__PrimaryQuote__c = primaryQuote.Id;
                opp.Invoice_Schedule__c = 'Single up-front invoice';
                opp.Event_start__c = Date.today().toStartOfMonth().addMonths(x + 1);
                opp.Event_end__c = Date.today().toStartOfMonth().addMonths(x + 1);
                oppsToInsert.add(opp);
            } else if (x < 4) {
                Opportunity opp = (Opportunity) SmartFactory.createSObject('Opportunity');
                opp.AccountId = acc.Id;
                opp.Amount = 400001;
                opp.Forecast_COS__c = 1000;
                opp.Calder_Opportunity__c = true;
                opp.StageName = 'Closed Won';
                opp.SBQQ__PrimaryQuote__c = primaryQuote.Id;
                opp.Invoice_Schedule__c = 'Single up-front invoice';
                opp.Event_start__c = Date.today().toStartOfMonth().addMonths(x - 1);
                opp.Event_end__c = Date.today().toStartOfMonth().addMonths(x - 1);
                oppsToInsert.add(opp);
            } else if (x < 5) {
                Opportunity opp = (Opportunity) SmartFactory.createSObject('Opportunity');
                opp.AccountId = acc.Id;
                opp.Amount = 10000;
                opp.Forecast_COS__c = 1000;
                opp.Calder_Opportunity__c = true;
                opp.StageName = 'Closed Lost';
                opp.Event_start__c = Date.today().toStartOfMonth().addMonths(x - 1);
                opp.Event_end__c = Date.today().toStartOfMonth().addMonths(x - 1);
                oppsToInsert.add(opp);
            } else if (x < 6) {
                Opportunity opp = (Opportunity) SmartFactory.createSObject('Opportunity');
                opp.AccountId = acc.Id;
                opp.Amount = 10000;
                opp.Forecast_COS__c = 1000;
                opp.Probability = 50;
                opp.Calder_Opportunity__c = true;
                opp.StageName = 'Costed prospect';
                opp.Event_start__c = Date.today().toStartOfMonth().addMonths(x - 1);
                opp.Event_end__c = Date.today().toStartOfMonth().addMonths(x - 1);
                oppsToInsert.add(opp);
            } else if (x < 8) {
                Opportunity opp = (Opportunity) SmartFactory.createSObject('Opportunity');
                opp.AccountId = acc.Id;
                opp.Amount = 10000;
                opp.Forecast_COS__c = 1000;
                opp.Probability = 50;
                opp.Calder_Opportunity__c = true;
                opp.StageName = 'Pipeline prospect';
                opp.Event_start__c = Date.today().toStartOfMonth().addMonths(x - 15);
                opp.Event_end__c = Date.today().toStartOfMonth().addMonths(x - 15);
                oppsToInsert.add(opp);
            } else if (x < 12) {
                Opportunity opp = (Opportunity) SmartFactory.createSObject('Opportunity');
                opp.AccountId = acc.Id;
                opp.Amount = 10000;
                opp.Forecast_COS__c = 1000;
                opp.Probability = 50;
                opp.Calder_Opportunity__c = true;
                opp.StageName = 'Repeat Prospect';
                opp.Event_start__c = Date.today().toStartOfMonth().addMonths(x - 1);
                opp.Event_end__c = Date.today().toStartOfMonth().addMonths(x - 1);
                oppsToInsert.add(opp);
            } else {
                Opportunity opp = (Opportunity) SmartFactory.createSObject('Opportunity');
                opp.AccountId = acc.Id;
                opp.Amount = 10000;
                opp.Forecast_COS__c = 1000;
                opp.Probability = 50;
                opp.Calder_Opportunity__c = true;
                opp.StageName = 'Closed Won';
                opp.SBQQ__PrimaryQuote__c = primaryQuote.Id;
                opp.Invoice_Schedule__c = 'Single up-front invoice';
                opp.Event_start__c = Date.newInstance(2018, 03, 01);
                opp.Event_end__c = Date.newInstance(2018, 03, 01);
                oppsToInsert.add(opp);
            }

        }

        insert oppsToInsert;

        // update sample invoice schedules
        List<Invoice_Schedule__c> schedules = [
                SELECT Opportunity__r.Amount_Calder__c
                FROM Invoice_Schedule__c
                LIMIT 1
        ];

        for (Invoice_Schedule__c is : schedules) {
            is.Send_Date__c = Date.today();
            is.Payment_Date__c = Date.today();
            is.Invoice_Paid__c = true;
            is.Invoice_Sent__c = true;
            is.Invoice_Amount__c = is.Opportunity__r.Amount_Calder__c * 0.5;
            is.Amount_Paid__c = is.Opportunity__r.Amount_Calder__c * 0.1;
        }

        update schedules;

        // insert sample expenses
        List<Expense__c> expenses = new List<Expense__c>();
        List<Opportunity> oppIds = [SELECT Id FROM Opportunity WHERE StageName = 'Closed Won'];

        for (Integer x = 0; x < 3; x++) {
            Expense__c ex = new Expense__c(
                    Opportunity__c = oppIds[x].Id,
                    Amount__c = 500
            );

            expenses.add(ex);
        }

        insert expenses;

        // insert sample operating costs
        List<QBProfitAndLoss__c> operatingCosts = new List<QBProfitAndLoss__c>();

        List<String> parents = new List<String>{
                'Revenue', 'Cost of Sales', 'Payroll', 'IT costs',
                'PR and bus. development', 'Utilities', 'Other'
        };

        for (Integer x = 0; x < parents.size(); x++) {

            operatingCosts.add(new QBProfitAndLoss__c(
                    Month__c = Date.today().toStartOfMonth().addMonths(x - 5),
                    Nominal__c = 'Test ' + x,
                    Parent__c = parents[x],
                    QBUpdated__c = (x < 15) ? true : false,
                    IsOpex__c = (x > 1) ? true : false,
                    Actual__c = 100,
                    ForecastSource__c = 'Test',
                    Budget__c = 50,
                    BudgetSource__c = 'Test'
            ));
        }

        insert operatingCosts;

        Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;


        // insert adjustment connected to an Opportunity
        insert new Adjustment__c(
                Opportunity__c = oppId,
                Revenue__c = 1000,
                Profit__c = 500,
                CostOfSale__c = 20,
                Month__c = Date.today());

        // insert adjustment connected to an Opportunity which is committed
        insert new Adjustment__c(
                Opportunity__c = oppId,
                Revenue__c = 1000,
                Profit__c = 500,
                CostOfSale__c = 20,
                Committed__c = true,
                Month__c = Date.today());

        // insert statutory adjustment with no opportunity
        insert new Adjustment__c(
                Revenue__c = 1000,
                Profit__c = 500,
                CostOfSale__c = 20,
                Month__c = Date.today());

        // insert cashflow entries
        List<CashFlow__c> flows = new List<CashFlow__c>();

        for (Integer i = -1; i < 730; i++) {
            flows.add(new CashFlow__c(
                    Number__c = i,
                    Balance__c = i,
                    BalancePlus__c = i,
                    BalancePredict__c = i
            ));
        }

        insert flows;

        // insert supplier profiles used to create direct debits
        List<QBSupplierProfile__c> directDebitProfiles = new List<QBSupplierProfile__c>();


        directDebitProfiles.add(
                new QBSupplierProfile__c(
                        SupplierId__c = 'vendorRef1',
                        SupplierName__c = 'supplierName',
                        Category__c = 'nominal',
                        Type__c = 'DD',
                        Amount__c = 1,
                        Terms__c = 'weekly',
                        Day__c = 1,
                        EndDate__c = Date.today().addMonths(12)
                ));

        directDebitProfiles.add(
                new QBSupplierProfile__c(
                        SupplierId__c = 'vendorRef2',
                        SupplierName__c = 'supplierName',
                        Category__c = 'nominal',
                        Type__c = 'DD',
                        Amount__c = 1,
                        Terms__c = 'monthly',
                        Day__c = 1,
                        EndDate__c = Date.today().addMonths(12)
                ));

        directDebitProfiles.add(
                new QBSupplierProfile__c(
                        SupplierId__c = 'vendorRef3',
                        SupplierName__c = 'supplierName',
                        Category__c = 'nominal',
                        Type__c = 'DD',
                        Amount__c = 1,
                        Terms__c = 'quarterly',
                        Day__c = 1,
                        EndDate__c = Date.today().addMonths(12)
                ));

        insert directDebitProfiles;

        List<CashFlowEntry__c> entries = new List<CashFlowEntry__c>();

        entries.add(new CashFlowEntry__c(
                CashFlow__c = flows[1].Id,
                Source__c = 'Quickbooks',
                Category__c = 'Credit card',
                Description__c = 'Credit card',
                Details__c = 'Credit card',
                Amount__c = 100,
                QuickbooksId__c = 'Credit card',
                Adjusted__c = true,
                AmountAdjusted__c = true
        ));

        entries.add(new CashFlowEntry__c(
                CashFlow__c = flows[2].Id,
                Out__c = true,
                Source__c = 'Quickbooks',
                Category__c = 'Credit card',
                Description__c = 'Credit card',
                Details__c = 'Credit card',
                Amount__c = 100,
                QuickbooksId__c = 'Credit card',
                Paid__c = true
        ));

        entries.add(new CashFlowEntry__c(
                CashFlow__c = flows[3].Id,
                Out__c = true,
                Source__c = 'Quickbooks',
                Category__c = 'Credit card',
                Description__c = 'Credit card',
                Details__c = 'Credit card',
                Amount__c = 100,
                QuickbooksId__c = 'Credit card',
                Adjusted__c = true
        ));

        entries.add(new CashFlowEntry__c(
                CashFlow__c = flows[4].Id,
                Out__c = true,
                Source__c = 'Custom',
                Category__c = 'Credit card',
                Description__c = 'Credit card',
                Details__c = 'Credit card',
                Amount__c = 100,
                QuickbooksId__c = 'Credit card',
                Paid__c = true
        ));

        insert entries;

        QBBalance__c balance = new QBBalance__c(
                Date__c = Date.today().addDays(-1),
                Confirmed__c = 1000
        );

        insert balance;

        // create sample data snapshots
        SalesDashboardUtils.createSnapshots();

        // create fake snapshots stretching further back in time
        SalesDashboardSnapshot__c snapshot = [
                SELECT TotalRevenue__c, TotalGrossProfit__c, CreatedDate,
                        Id
                FROM SalesDashboardSnapshot__c
                LIMIT 1
        ];

        List<SalesDashboardSnapshot__c> newSnapshots = new List<SalesDashboardSnapshot__c>();

        for (Integer x = 0; x < 10; x++) {
            newSnapshots.add(
                    new SalesDashboardSnapshot__c(
                            TotalRevenue__c = snapshot.TotalRevenue__c,
                            TotalGrossProfit__c = snapshot.TotalGrossProfit__c,
                            CreatedDate = snapshot.CreatedDate.addDays(-(x + 1))
                    )
            );
        }

        insert newSnapshots;

    }

    ///// TEST DASHBOARD MAIN METHODS

    @IsTest
    public static void testGetOppRecords() {

        InsightsController.getOppRecords(String.valueOf(Date.today().addYears(-5)), String.valueOf(Date.today().addYears(5)));

    }

    @IsTest
    public static void testGetCashflowData() {

        InsightsController.getCashflowData(true);

    }

    @IsTest
    public static void testCalculateBalances() {

        InsightsController.calculateBalances();

    }

    @IsTest
    public static void testCashflowDateChange() {

        CashFlowEntry__c entry = [SELECT Id, Description__c FROM CashFlowEntry__c LIMIT 1];
        InsightsController.changeEntryDate(entry.Id, String.valueOf(Date.today()));
    }


    @IsTest
    public static void testCashflowAmountChange() {

        CashFlowEntry__c entry = [SELECT Id, Description__c FROM CashFlowEntry__c LIMIT 1];
        InsightsController.updateAmount(entry.Id, 500);
    }

    @IsTest
    public static void testCashflowCommentPaid() {

        CashFlowEntry__c entry = [SELECT Id, Description__c FROM CashFlowEntry__c LIMIT 1];
        InsightsController.markAsPaid(entry.Id);
        InsightsController.updateComment(entry.Id, 'Test comment');

    }


    @IsTest
    public static void testCashflowDelete() {

        CashFlowEntry__c entry = [SELECT Id, Description__c FROM CashFlowEntry__c LIMIT 1];
        InsightsController.deleteEntry(entry.Id);

    }

    @IsTest
    public static void testInsertCustomEntry() {
        InsightsController.addCustomEntry('type', 'description', 'budgetKey', 100, String.valueOf(Date.today()));
    }


    @IsTest
    public static void testFreelancerConfig() {

        CashFlowEntry__c entry = [SELECT Id, Description__c FROM CashFlowEntry__c LIMIT 1];
        InsightsController.toggleFreelancer(entry.Id);
    }

    @IsTest
    public static void testDirectDebitConfig() {

        InsightsController.convertToDirectDebit('vendorRef', 'supplierName', 'monthly',
                1, 100, String.valueOf(Date.today().addMonths(6)), 'nominal');
        InsightsController.disableDirectDebit('vendorRef');

    }

    @IsTest
    public static void testUpdateBudgetsPreviousFY() {

        String budgetId = '1';
        String forecastId = '2';
        String year = 'PREVIOUS FY';
        String month = String.valueOf(Date.today());

        insert new QBClosedMonth__c(Name = 'QBClosedMonth', Month__c = Date.today().addYears(-1).toStartOfMonth());

        QuickbooksProfitAndLossCalloutMock pnlMock = new QuickbooksProfitAndLossCalloutMock();
        QBOBudgetMock budgetMock = new QBOBudgetMock();
        QBOBudgetMock forecastMock = new QBOBudgetMock();
        JSONParserQBOAccountMock accountMock = new JSONParserQBOAccountMock();

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('pnl', pnlMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20budget%20' +
                'where%20id%20%3d%20%27' + forecastId + '%27&minorversion=4', forecastMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20budget%20' +
                'where%20id%20%3d%20%27' + budgetId + '%27&minorversion=4', budgetMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20account%20max' +
                'Results%201000&minorversion=4', accountMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20account%20where' +
                '%20active%20%3d%20false%20maxResults%201000&minorversion=4', accountMock);

        QBBudgetMultiRequestMock multiMock = new QBBudgetMultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiMock);

        Test.startTest();
        QuickbooksDashboardCallout.updateOpexForecast(budgetId, forecastId, year, month);
        Test.stopTest();

    }


    @IsTest
    public static void testUpdateBudgetsCurrentFY() {

        String budgetId = '1';
        String forecastId = '2';
        String year = 'CURRENT FY';
        String month = String.valueOf(Date.today());

        insert new QBClosedMonth__c(Name = 'QBClosedMonth', Month__c = Date.today().addYears(-1).toStartOfMonth());

        QuickbooksProfitAndLossCalloutMock pnlMock = new QuickbooksProfitAndLossCalloutMock();
        QBOBudgetMock budgetMock = new QBOBudgetMock();
        QBOBudgetMock forecastMock = new QBOBudgetMock();
        JSONParserQBOAccountMock accountMock = new JSONParserQBOAccountMock();

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('pnl', pnlMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20budget%20' +
                'where%20id%20%3d%20%27' + forecastId + '%27&minorversion=4', forecastMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20budget%20' +
                'where%20id%20%3d%20%27' + budgetId + '%27&minorversion=4', budgetMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20account%20max' +
                'Results%201000&minorversion=4', accountMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20account%20where' +
                '%20active%20%3d%20false%20maxResults%201000&minorversion=4', accountMock);

        QBBudgetMultiRequestMock multiMock = new QBBudgetMultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiMock);

        Test.startTest();
        QuickbooksDashboardCallout.updateOpexForecast(budgetId, forecastId, year, month);
        Test.stopTest();

    }

    @IsTest
    public static void testUpdateBudgetsNextFY() {

        String budgetId = '1';
        String forecastId = '2';
        String year = 'NEXT FY';
        String month = String.valueOf(Date.today());

        insert new QBClosedMonth__c(Name = 'QBClosedMonth', Month__c = Date.today().addYears(-1).toStartOfMonth());

        QuickbooksProfitAndLossCalloutMock pnlMock = new QuickbooksProfitAndLossCalloutMock();
        QBOBudgetMock budgetMock = new QBOBudgetMock();
        QBOBudgetMock forecastMock = new QBOBudgetMock();
        JSONParserQBOAccountMock accountMock = new JSONParserQBOAccountMock();

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('pnl', pnlMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20budget%20' +
                'where%20id%20%3d%20%27' + forecastId + '%27&minorversion=4', forecastMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20budget%20' +
                'where%20id%20%3d%20%27' + budgetId + '%27&minorversion=4', budgetMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20account%20max' +
                'Results%201000&minorversion=4', accountMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20account%20where' +
                '%20active%20%3d%20false%20maxResults%201000&minorversion=4', accountMock);

        QBBudgetMultiRequestMock multiMock = new QBBudgetMultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiMock);

        Test.startTest();
        QuickbooksDashboardCallout.updateOpexForecast(budgetId, forecastId, year, month);
        Test.stopTest();

    }

    @IsTest
    public static void testGetRecordChanges() {

        delete [SELECT Id FROM Invoice_Schedule__c];

        // set opp to lost
        Opportunity oppToLose = [
                SELECT Id, Event_end__c, Amount, Forecast_COS__c, StageName
                FROM Opportunity
                WHERE StageName = 'Closed Won'
                AND Event_end__c > :Date.today()
                LIMIT 1
        ];

        oppToLose.StageName = 'Closed Lost';

        update oppToLose;

        // change opp date
        Opportunity oppToDateChange = [
                SELECT Id, Event_end__c, Amount, Forecast_COS__c, StageName
                FROM Opportunity
                WHERE StageName = 'Closed Won'
                AND Event_end__c > :Date.today()
                LIMIT 1
        ];

        oppToDateChange.Event_end__c = Date.newInstance(2010, 01, 01);
        oppToDateChange.Event_start__c = Date.newInstance(2010, 01, 01);

        update oppToDateChange;

        Map<String, Map<String, List<Object>>> recordChanges =
                InsightsController.getRecordChanges(
                        String.valueOf(Date.today().addMonths(-6)),
                        String.valueOf(Date.today().addMonths(6)),
                        7,
                        10000
                );
    }

    @IsTest
    public static void testGetOppHistory(){

        Opportunity opp = [SELECT Id FROM Opportunity WHERE StageName = 'Repeat Prospect' LIMIT 1];

        opp.StageName = 'Costed prospect';
        opp.Amount = 0;
        opp.Forecast_COS__c = 0;
        update opp;


        opp.StageName = 'Pipeline prospect';
        opp.Amount = 100;
        opp.Forecast_COS__c = 100;
        update opp;

        InsightsController.getOpportunityHistory(opp.Id);

        Opportunity opp2 = [SELECT Id FROM Opportunity WHERE Quickbooks_COS__c > 0 LIMIT 1];
        opp2.Event_start__c = Date.today().addDays(-20);
        opp2.Event_end__c = Date.today().addDays(-20);
        update opp2;
        InsightsController.getOpportunityHistory(opp2.Id);

    }

    @IsTest
    public static void testCashflowGenerator() {

        JSONParserQBOInvoiceFlowMock invMock    = new JSONParserQBOInvoiceFlowMock();
        JSONParserQBOBillFlowMock billMock1     = new JSONParserQBOBillFlowMock();
        JSONParserQBOCurrentAccountMock accMock = new JSONParserQBOCurrentAccountMock(200);

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20i' +
                'nvoice%20where%20Balance%20%3e%20%270%27&minorversion=4', invMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20' +
                'bill%20where%20Balance%20%21%3d%20%270%27&minorversion=4', billMock1);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20account' +
                '%20where%20name%20%3d%20%27Bank%20Current%20Account%27&minorversion=4', accMock);

        CashFlowMultiRequestMock cashMultiMock = new CashFlowMultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, cashMultiMock);

        Test.startTest();
        CashflowGenerator.buildFlow(false, false, null);
        Test.stopTest();

    }

    @IsTest
    public static void testCashflowScheduler() {

        JSONParserQBOInvoiceFlowMock invMock    = new JSONParserQBOInvoiceFlowMock();
        JSONParserQBOBillFlowMock billMock1     = new JSONParserQBOBillFlowMock();
        JSONParserQBOCurrentAccountMock accMock = new JSONParserQBOCurrentAccountMock(200);

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20i' +
                'nvoice%20where%20Balance%20%3e%20%270%27&minorversion=4', invMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20' +
                'bill%20where%20Balance%20%21%3d%20%270%27&minorversion=4', billMock1);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20account' +
                '%20where%20name%20%3d%20%27Bank%20Current%20Account%27&minorversion=4', accMock);
//
        CashFlowMultiRequestMock cashMultiMock = new CashFlowMultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, cashMultiMock);
        CashFlowScheduler scheduler = new CashFlowScheduler();
        String sch = '0 0 0 * * ?';
//
//        Test.startTest();
//        System.schedule('Cashflow Hourly', sch, scheduler);
//        Test.stopTest();
        Test.startTest();

        CashflowGenerator.buildFlowFuture(false,false);
        System.schedule('Cashflow Hourly', sch, scheduler);
        Test.stopTest();

    }

    @IsTest
    public static void testAdjustCalderCommission(){
        SalesDashboardUtils.adjustCalderCommissions();
    }

    @IsTest
    public static void testGetSnapshots(){

        SalesDashboardUtils.createSnapshots();

        String createdDate  = String.valueOf(Date.today());
        String endDate      = String.valueOf(Date.today().addMonths(20));

        Test.startTest();
        List<Date> snapshotDates = SalesDashboardRemoter.getSnapshots(endDate);
        Test.stopTest();
    }

    @IsTest
    public static void testGetPriorTotals(){

        String createdDate  = String.valueOf(Date.today());
        String endDate      = String.valueOf(Date.today());

        QBClosedMonth__c closedMonth = new QBClosedMonth__c();
        closedMonth.Name = 'SFCommitMonth';
        insert closedMonth;

        Object priorsnapshot = SalesDashboardRemoter.getPriorTotals(endDate);
        SalesDashboardSnapshot__c snapshotData = SalesDashboardRemoter.getSnapshotData(createdDate, endDate);

        SalesDashboardUtils.commitOpportunities(Date.today());
        SalesDashboardUtils.adjustOpportunities();
    }

    @IsTest
    public static void testGetBalance200Response(){

        Test.setMock(HttpCalloutMock.class, new JSONParserQBOCurrentAccountMock(200));

        Test.startTest();
        SalesDashboardUtils.getCurrentBalance();
        Test.stopTest();
    }

    @IsTest
    public static void testGetBalance400Response(){

        Test.setMock(HttpCalloutMock.class, new JSONParserQBOCurrentAccountMock(400));

        Test.startTest();
        SalesDashboardUtils.getCurrentBalance();
        Test.stopTest();
    }

}