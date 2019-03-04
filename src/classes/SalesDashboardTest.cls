/**
 * Created by Ronan Williams on 18/10/2018.
 */

@IsTest
public class SalesDashboardTest {

    //// TEST SETUP
    @TestSetup
    public static void doSetup(){

        // insert account
        Account acc = new Account(Name = 'TestAcc');
        insert acc;

        // insert Opportunities
        List<Opportunity> oppsToInsert          = new List<Opportunity>();
        List<SalesTarget__c> targetsToInsert    = new List<SalesTarget__c>();

        // insert 10 won opps
        for (Integer x = 0; x < 13; x++){

            if (x < 2) {
                Opportunity opp         = (Opportunity)SmartFactory.createSObject('Opportunity');
                opp.AccountId           = acc.Id;
                opp.Amount              = 750001;
                opp.Forecast_COS__c     = 1000;
                opp.Committed__c        = true;
                opp.CommittedRevenue__c = 1000;
                opp.CommittedCOS__c     = 1000;
                opp.CommittedProfit__c  = 1000;
                opp.Calder_Opportunity__c = true;
                opp.StageName           = 'Closed Won';
                opp.Invoice_Schedule__c = 'Single up-front invoice';
                opp.Event_start__c      = Date.today().toStartOfMonth().addMonths(x + 15);
                opp.Event_end__c        = Date.today().toStartOfMonth().addMonths(x + 15);
                oppsToInsert.add(opp);
            } else if (x <4){
                Opportunity opp         = (Opportunity)SmartFactory.createSObject('Opportunity');
                opp.AccountId           = acc.Id;
                opp.Amount              = 400001;
                opp.Forecast_COS__c     = 1000;
                opp.Calder_Opportunity__c = true;
                opp.StageName           = 'Closed Won';
                opp.Invoice_Schedule__c = 'Single up-front invoice';
                opp.Event_start__c      = Date.today().toStartOfMonth().addMonths(x -5);
                opp.Event_end__c        = Date.today().toStartOfMonth().addMonths(x -5);
                oppsToInsert.add(opp);
            } else if (x < 5){
                Opportunity opp         = (Opportunity)SmartFactory.createSObject('Opportunity');
                opp.AccountId           = acc.Id;
                opp.Amount              = 10000;
                opp.Forecast_COS__c     = 1000;
                opp.Calder_Opportunity__c = true;
                opp.StageName           = 'Closed Lost';
                opp.Event_start__c      = Date.today().toStartOfMonth().addMonths(x -15);
                opp.Event_end__c        = Date.today().toStartOfMonth().addMonths(x -15);
                oppsToInsert.add(opp);
            } else if (x <6){
                Opportunity opp         = (Opportunity)SmartFactory.createSObject('Opportunity');
                opp.AccountId           = acc.Id;
                opp.Amount              = 10000;
                opp.Forecast_COS__c     = 1000;
                opp.Probability         = 50;
                opp.Calder_Opportunity__c = true;
                opp.StageName           = 'Costed prospect';
                opp.Event_start__c      = Date.today().toStartOfMonth().addMonths(x -15);
                opp.Event_end__c        = Date.today().toStartOfMonth().addMonths(x -15);
                oppsToInsert.add(opp);
            } else if (x < 8) {
                Opportunity opp         = (Opportunity)SmartFactory.createSObject('Opportunity');
                opp.AccountId           = acc.Id;
                opp.Amount              = 10000;
                opp.Forecast_COS__c     = 1000;
                opp.Probability         = 50;
                opp.Calder_Opportunity__c = true;
                opp.StageName           = 'Pipeline prospect';
                opp.Event_start__c      = Date.today().toStartOfMonth().addMonths(x -15);
                opp.Event_end__c        = Date.today().toStartOfMonth().addMonths(x -15);
                oppsToInsert.add(opp);
            } else if (x < 12) {
                Opportunity opp         = (Opportunity)SmartFactory.createSObject('Opportunity');
                opp.AccountId           = acc.Id;
                opp.Amount              = 10000;
                opp.Forecast_COS__c     = 1000;
                opp.Probability         = 50;
                opp.Calder_Opportunity__c = true;
                opp.StageName           = 'Repeat Prospect';
                opp.Event_start__c      = Date.today().toStartOfMonth().addMonths(x -15);
                opp.Event_end__c        = Date.today().toStartOfMonth().addMonths(x -15);
                oppsToInsert.add(opp);
            } else {
                Opportunity opp         = (Opportunity)SmartFactory.createSObject('Opportunity');
                opp.AccountId           = acc.Id;
                opp.Amount              = 10000;
                opp.Forecast_COS__c     = 1000;
                opp.Probability         = 50;
                opp.Calder_Opportunity__c = true;
                opp.StageName           = 'Closed Won';
                opp.Invoice_Schedule__c = 'Single up-front invoice';
                opp.Event_start__c      = Date.newInstance(2018,03,01);
                opp.Event_end__c        = Date.newInstance(2018,03,01);
                oppsToInsert.add(opp);
            }

            // create sample sales targets
            targetsToInsert.add(new SalesTarget__c(
                    Month__c    = Date.today().toStartOfMonth().addMonths(x -15),
                    Revenue__c  = 1000));
        }

        insert oppsToInsert;
        insert targetsToInsert;

        // update sample invoice schedules
        List<Invoice_Schedule__c> schedules = [SELECT Opportunity__r.Amount_Calder__c
                                                FROM Invoice_Schedule__c];

        for (Invoice_Schedule__c is : schedules){
            is.Send_Date__c     = Date.today();
            is.Payment_Date__c  = Date.today();
            is.Invoice_Paid__c  = true;
            is.Invoice_Sent__c  = true;
            is.Invoice_Amount__c = is.Opportunity__r.Amount_Calder__c * 0.5;
            is.Amount_Paid__c   = is.Opportunity__r.Amount_Calder__c * 0.1;
        }

        update schedules;

        // insert sample expenses
        List<Expense__c> expenses = new List<Expense__c>();
        List<Opportunity> oppIds = [SELECT Id FROM Opportunity WHERE StageName = 'Closed Won'];

        for (Integer x = 0 ; x < 3; x++){
            Expense__c ex = new Expense__c(
                    Opportunity__c = oppIds[x].Id,
                    Amount__c  = 500
            );

            expenses.add(ex);
        }

        insert expenses;

        // insert sample operating costs
        List<QBProfitAndLoss__c> operatingCosts = new List<QBProfitAndLoss__c>();

        List<String> parents = new List<String>{'Payroll', 'IT costs', 'PR and bus. development', 'Utilities', 'Other'};

        for (Integer x = 0; x < 5; x++){
//        for (Integer x = 0; x < 5; x++){

            operatingCosts.add(new QBProfitAndLoss__c(
                    Month__c    = Date.today().toStartOfMonth().addMonths(x -5),
                    Nominal__c  = 'Test ' + x,
                    Parent__c   = parents[x],
                    QBUpdated__c = (x < 15) ? true : false,
                    Actual__c   = 100,
                    ForecastSource__c = 'Test',
                    Budget__c   = 50,
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

        for (Integer i = -1; i < 500; i++){
            flows.add(new CashFlow__c(
                    Number__c = i,
                    In__c = 0,
                    InPlus__c = 0,
                    InPredict__c = 0,
                    Out__c = 0,
                    OutPlus__c = 0,
                    OutPredict__c = 0
            ));
        }

        insert flows;

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

        QBBalance__c balance = new QBBalance__c(
                Date__c         = Date.today().addDays(-1),
                Confirmed__c    = 1000
        );

        insert balance;

        // create sample data snapshots
        SalesDashboardUtils.createSnapshots();

        // create fake snapshots stretching further back in time
        SalesDashboardSnapshot__c snapshot = [SELECT TotalRevenue__c, TotalGrossProfit__c, CreatedDate,
                                                Id FROM SalesDashboardSnapshot__c LIMIT 1];

        List<SalesDashboardSnapshot__c> newSnapshots = new List<SalesDashboardSnapshot__c>();

        for (Integer x = 0; x < 10; x++){
            newSnapshots.add(
                    new SalesDashboardSnapshot__c(
                            TotalRevenue__c = snapshot.TotalRevenue__c,
                            TotalGrossProfit__c = snapshot.TotalGrossProfit__c,
                            CreatedDate = snapshot.CreatedDate.addDays(- (x + 1))
                    )
            );
        }

        insert newSnapshots;

    }

    ///// TEST DASHBOARD MAIN METHODS
    @IsTest
    public static void testGetOperatingCosts(){
        String startDate    = String.valueOf(Date.today().addMonths(-20));
        String endDate      = String.valueOf(Date.today().addMonths(20));

        Map<String,List<Decimal>> operatingCosts = SalesDashboardRemoter.getOperatingCosts(startDate, endDate);
    }

    @IsTest
    public static void testGetHeadlineTotals(){
        String startDate    = String.valueOf(Date.today().addMonths(-20));
        String endDate      = String.valueOf(Date.today().addMonths(20));

        List<Decimal> headlineTotals = SalesDashboardRemoter.getHeadlineTotals(startDate, endDate);
    }

    @IsTest
    public static void testGetOppChanges(){

        delete [SELECT Id FROM Invoice_Schedule__c];

        // set opp to lost
        Opportunity oppToLose = [SELECT Id, Event_end__c, Amount, Forecast_COS__c, StageName
                                FROM Opportunity WHERE StageName = 'Closed Won'
                                AND Event_end__c > :Date.today() LIMIT 1];

        oppToLose.StageName = 'Closed Lost';

        update oppToLose;

        // change opp date
        Opportunity oppToDateChange = [SELECT Id, Event_end__c, Amount, Forecast_COS__c, StageName
                                        FROM Opportunity WHERE StageName = 'Closed Won'
                                        AND Event_end__c > :Date.today() LIMIT 1];

        oppToDateChange.Event_end__c = Date.newInstance(2010,01,01);
        oppToDateChange.Event_start__c = Date.newInstance(2010,01,01);

        update oppToDateChange;

        // REMOVED DUE TO NEW VALIDATION RULE PREVENTING CHANGES TO OPP STATUS ONCE CLOSED LOST
//        // set opp to won
//        Opportunity oppToWin = [SELECT Id, Event_end__c, Amount, Forecast_COS__c, StageName
//            FROM Opportunity WHERE StageName != 'Closed Won' AND Event_end__c > :Date.today() LIMIT 1];
//
//        oppToWin.StageName = 'Closed Won';
//
//        update oppToWin;

        String startDate    = String.valueOf(Date.today().addMonths(-20));
        String endDate      = String.valueOf(Date.today().addMonths(20));

        Map<String,List<Object>> results = SalesDashboardRemoter.getOppChanges(startDate, endDate, 7, 200);
    }

    @IsTest
    public static void testGetOppProfitChanges(){

        delete [SELECT Id FROM Invoice_Schedule__c];

        List<Opportunity> opps = [SELECT Id, Event_end__c, Amount, Forecast_COS__c, StageName
                                  FROM Opportunity WHERE StageName = 'Closed Won'
                                  AND Event_end__c > :Date.today() LIMIT 2];

        for (Opportunity opp : opps) {
            opp.StageName = 'Closed Lost';
        }

        update opps;

        List<Opportunity> opps2 = [SELECT Id, Event_end__c, Amount, Forecast_COS__c, StageName
                                    FROM Opportunity WHERE StageName = 'Closed Lost'
                                    AND Event_end__c > :Date.today() LIMIT 2];

        for (Opportunity opp : opps) {
            opp.StageName = 'Closed Won';
        }

        update opps2;

        List<Opportunity> opps3 = [SELECT Id, Event_end__c, Amount, Forecast_COS__c, StageName
                                    FROM Opportunity WHERE StageName = 'Closed Won' LIMIT 2];

        for (Opportunity opp : opps) {
            opp.Amount = 1;
            opp.Forecast_COS__c = 1;
        }

        update opps3;

        String startDate    = String.valueOf(Date.today().addYears(-3));
        String endDate      = String.valueOf(Date.today().addYears(3));

        Map<String,List<Object>> results = SalesDashboardRemoter.getOppProfitChanges(startDate, endDate, 7, 200);
    }

    @IsTest
    public static void testGetBalances(){

        String dateValue            = String.valueOf(Date.today().addDays(-35)).substring(0,10);
        String startValue           = String.valueOf(Date.today().addMonths(-3).toStartOfMonth()).substring(0, 10);
        String endValue             = String.valueOf(Date.today().toStartOfMonth()).substring(0, 10);
        String dividendDateValue    = String.valueOf(Date.today().addDays(-35)).substring(0,10);

        JSONParserQBOInvoiceFlowMock invMock        = new JSONParserQBOInvoiceFlowMock();
        JSONParserQBOBillFlowMock billMock1         = new JSONParserQBOBillFlowMock();
        JSONParserQBOBillFlowMock billMock2         = new JSONParserQBOBillFlowMock();
        JSONParserQBOCurrentAccountMock accMock     = new JSONParserQBOCurrentAccountMock(200);
        JSONParserQBOJournalFlowMock jrnlMock       = new JSONParserQBOJournalFlowMock();
        JSONParserQBOJournalFlowMock divMock        = new JSONParserQBOJournalFlowMock();

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20i' +
                'nvoice%20where%20Balance%20%3e%20%270%27&minorversion=4',invMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20' +
                'bill%20where%20Balance%20%21%3d%20%270%27&minorversion=4',billMock1);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20bill' +
                '%20where%20metadata.createtime%20%3e%20%27' + startValue +
                'T02%3a32%3a09-07%3a00%27%20and%20metadata.createtime%20%3c%20%27' + endValue +
                'T02%3a32%3a09-07%3a00%27%20MAXRESULTS%20500&minorversion=4',billMock2);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20account' +
                '%20where%20name%20%3d%20%27Bank%20Current%20Account%27&minorversion=4',accMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20journalentry%20where%20TxnDate%20%3e%20%27'
                + dateValue + '%27&minorversion=4',jrnlMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20' +
                'journalentry%20where%20docNumber%' + '20Like%20%27%25dividend%25%27%20and%20TxnDate%20%3e%20%27'
                + dividendDateValue + '%27&minorversion=4',divMock);

        CashFlowMultiRequestMock cashMultiMock = new CashFlowMultiRequestMock(endpoint2TestResp);

        Test.setMock(HttpCalloutMock.class, cashMultiMock);

        Test.startTest();
        CashFlowControl.buildFlow();
        Test.stopTest();

        String startDate    = String.valueOf(Date.today().addMonths(-20));
        String endDate      = String.valueOf(Date.today().addMonths(20));

        Map<Date, List<Object>> balances = SalesDashboardRemoter.getBalances(startDate, endDate);

    }

    @IsTest
    public static void testGetOppReportingData(){

        String startDate    = String.valueOf(Date.today().addMonths(-20));
        String endDate      = String.valueOf(Date.today().addMonths(20));

        Map<String,Map<String,List<Object>>> reportData = SalesDashboardRemoter.getOppReportData(startDate, endDate);
    }


    @IsTest
    public static void testGetOpexReportData(){

        String startDate    = String.valueOf(Date.today().addMonths(-20));
        String endDate      = String.valueOf(Date.today().addMonths(20));

        Map<String,Map<String,Map<String,List<Decimal>>>> reportData =
                SalesDashboardRemoter.getOpexReportData(startDate, endDate);
    }

    @IsTest
    public static void testGetRevenueTotals(){

        String startDate    = String.valueOf(Date.today().addMonths(-20));
        String endDate      = String.valueOf(Date.today().addMonths(20));

        Map<String,List<Decimal>> oppRevenueTotals = SalesDashboardRemoter.getOppRevenueTotals(startDate, endDate);

    }

    @IsTest
    public static void testGetOppInvoiceTotals(){

        String startDate    = String.valueOf(Date.today().addMonths(-20));
        String endDate      = String.valueOf(Date.today().addMonths(20));

        Map<String,List<Decimal>> oppTypeTotals = SalesDashboardRemoter.getOppInvoiceTotals(startDate, endDate);

    }

    @IsTest
    public static void tesGetOppTypeTotals(){

        String startDate    = String.valueOf(Date.today().addMonths(-20));
        String endDate      = String.valueOf(Date.today().addMonths(20));

        Map<String,List<Decimal>> oppTypeTotals = SalesDashboardRemoter.getOppTypeTotals(startDate, endDate);
    }


    @IsTest
    public static void testGetOppProfitTotals(){
        String startDate    = String.valueOf(Date.today().addMonths(-20));
        String endDate      = String.valueOf(Date.today().addMonths(20));

        Map<String,List<Decimal>> oppProfitTotals = SalesDashboardRemoter.getOppProfitTotals(startDate, endDate);
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

        Object priorsnapshot = SalesDashboardRemoter.getPriorTotals(endDate);
        SalesDashboardSnapshot__c snapshotData = SalesDashboardRemoter.getSnapshotData(createdDate, endDate);

        SalesDashboardUtils.commitOpportunites();
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

    @IsTest
    public static void testGetCashflowData(){

        Map<String,Object> cashflowData = SalesDashboardRemoter.getCashflowData();

    }

    @IsTest
    public static void testGetCashflowEntries(){

        String endDate      = String.valueOf(Date.today().addMonths(20));
        List<CashFlowEntry__c> cashflowEntries = SalesDashboardRemoter.getCashflowEntries(endDate);
    }

    @IsTest
    public static void testUpdateEntryAmount(){

        String entryId = [SELECT Id FROM CashFlowEntry__c WHERE InFlow__c != NULL LIMIT 1].Id;
        CashFlowEntry__c entry = SalesDashboardRemoter.updateEntryAmount(entryId, 500, 'IN');
    }

    @IsTest
    public static void testUpdateEntryDate(){

        String entryId = [SELECT Id FROM CashFlowEntry__c WHERE InFlow__c != NULL LIMIT 1].Id;
        CashFlowEntry__c entry = SalesDashboardRemoter.updateEntryDate(entryId, String.valueOf(Date.today().addDays(30)), 'IN');
    }

    @IsTest
    public static void testMarkAsPaid(){

        String entryId = [SELECT Id FROM CashFlowEntry__c WHERE InFlow__c != NULL LIMIT 1].Id;
        Boolean success = SalesDashboardRemoter.markAsPaid(entryId,'IN');
    }

    @IsTest
    public static void testScheduleOpportunityAdjustments(){

        Test.startTest();
        ScheduledOpportunityAdjustments scheduler = new ScheduledOpportunityAdjustments();
        String sch = '0 0 23 * * ?';
        System.schedule('TestScheduledOpportunityAdjustment', sch, scheduler);
        Test.stopTest();

    }

    @IsTest
    public static void testAdjustCalderCommission(){
        SalesDashboardUtils.adjustCalderCommissions();
    }

    @IsTest
    public static void testGetBudgetOptions(){

        Test.setMock(HttpCalloutMock.class, new QBOBudgetMock());

        Test.startTest();
        SalesDashboardRemoter.getQBBudgets('CURRENT FY');
        Test.stopTest();
    }

    @IsTest
    public static void testUpdateBudgets(){

        String budgetId     = '1';
        String forecastId   = '2';
        String year         = 'CURRENT FY';
        String month        = String.valueOf(Date.today());

        insert new QBClosedMonth__c(Name = 'QBClosedMonth', Month__c = Date.today().toStartOfMonth());

        QuickbooksProfitAndLossCalloutMock pnlMock  = new QuickbooksProfitAndLossCalloutMock();
        QBOBudgetMock budgetMock      = new QBOBudgetMock();
        QBOBudgetMock forecastMock    = new QBOBudgetMock();

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('pnl',pnlMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20budget%20' +
                'where%20id%20%3d%20%27' + forecastId + '%27&minorversion=4',forecastMock);
        endpoint2TestResp.put('callout:QuickBooksOnline/query?query=select%20%2a%20from%20budget%20' +
                'where%20id%20%3d%20%27' + budgetId + '%27&minorversion=4',budgetMock);

        QBBudgetMultiRequestMock multiMock = new QBBudgetMultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiMock);

        Test.startTest();
        Boolean success = SalesDashboardRemoter.updateBudgets(budgetId, forecastId, year, month);
        Test.stopTest();

    }

}