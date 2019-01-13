@isTest
private class DashboardControllerTest {
    
    @isTest static void testControllerCurrentFY() {
        
        // create and insert revenue snapshot records
        for (Integer x = 1; x < 31; x++) {

            Confirmed_Revenue_Snapshot__c cr = new Confirmed_Revenue_Snapshot__c();
            cr.Financial_Year__c    = 'CurrentFY';
            cr.Gross_Profit__c      = x;     
            cr.Net_Amount__c        = x;
            cr.Net_Profit__c        = x;
            insert cr;
            Test.setCreatedDate(cr.Id,Date.newInstance(Date.today().year(), Date.today().month(), x));
        }

        // create and insert opportunity record
        Account acc = (Account)SmartFactory.createSOBject('Account');
        insert acc;
        Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp.AccountId = acc.Id;
        opp.Amount = 5000;
        opp.Forecast_COS__c = 2500;
        opp.StageName = 'Closed Won';
        opp.Invoice_Schedule__c = 'Single post-event invoice';
        opp.Event_Start__c = Date.today();
        opp.Event_End__c = Date.today();
        insert opp;

        // create and insert revenue summary record 
        Revenue_Summary__c rs = new Revenue_Summary__c();
        rs.Month__c = Date.today();
        rs.Operating_Cost__c = 1000;
        insert rs;

        // create dashboard controller and check returned values 
        DashboardControllerCurrentFY dbc = new DashboardControllerCurrentFY();

        System.assertEquals(5000, dbc.getCurrentRevenue());
        System.assertEquals(2500, dbc.getCurrentGrossProfit());
        System.assertEquals(1500, dbc.getCurrentNetProfit());
        System.assertEquals(5000 - 24, dbc.getRevenueChange());
        System.assertEquals(2500 - 24, dbc.getGrossProfitChange());
        System.assertEquals(1500 - 24, dbc.getNetProfitChange());

    }

    @isTest static void testControllerNextFY() {
        
        // create and insert revenue snapshot records
        for (Integer x = 1; x < 31; x++) {

            Confirmed_Revenue_Snapshot__c cr = new Confirmed_Revenue_Snapshot__c();
            cr.Financial_Year__c    = 'NextFY';
            cr.Gross_Profit__c      = x;     
            cr.Net_Amount__c        = x;
            cr.Net_Profit__c        = x;
            insert cr;
            Test.setCreatedDate(cr.Id,Date.newInstance(Date.today().year(),  Date.today().month(), x));
        }

        // create and insert opportunity record
        Account acc = (Account)SmartFactory.createSOBject('Account');
        insert acc;
        Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp.AccountId = acc.Id;
        opp.Amount = 5000;
        opp.Forecast_COS__c = 2500;
        opp.StageName = 'Closed Won';
        opp.Invoice_Schedule__c = 'Single post-event invoice';
        opp.Event_Start__c = Date.today().addYears(1);
        opp.Event_End__c = Date.today().addYears(1);
        insert opp;        

        // create and insert revenue summary record 
        Revenue_Summary__c rs = new Revenue_Summary__c();
        rs.Month__c = Date.today().addYears(1);
        rs.Operating_Cost__c = 1000;
        insert rs;

        // create dashboard controller and check returned values 
        DashboardControllerNextFY dbc = new DashboardControllerNextFY();

        System.assertEquals(5000, dbc.getCurrentRevenue());
        System.assertEquals(2500, dbc.getCurrentGrossProfit());
        System.assertEquals(1500, dbc.getCurrentNetProfit());

        if (Date.today().month() == 4 && Date.today().day() < 7) {        
            System.assertEquals(0, dbc.getRevenueChange());
            System.assertEquals(0, dbc.getGrossProfitChange());
            System.assertEquals(0, dbc.getNetProfitChange());
        } else {
            System.assertEquals(5000 - 24, dbc.getRevenueChange());
            System.assertEquals(2500 - 24, dbc.getGrossProfitChange());
            System.assertEquals(1500 - 24, dbc.getNetProfitChange());            
        }    
    }      
}