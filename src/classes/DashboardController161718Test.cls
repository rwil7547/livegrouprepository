@isTest
private class DashboardController161718Test {
	
	@isTest static void testController() {
		
		// create and insert revenue snapshot records
		for (Integer x = 1; x < 31; x++) {

			Confirmed_Revenue_Snapshot__c cr = new Confirmed_Revenue_Snapshot__c();
			cr.Financial_Year__c 	= 'FY16/17/18 Snapshot';
			cr.Gross_Profit__c 		= x;	 
			cr.Net_Amount__c 		= x;
			cr.Net_Profit__c 		= x;
			insert cr;
			Test.setCreatedDate(cr.Id,Date.newInstance(2017, 09, x));
		}

		for (Confirmed_Revenue_Snapshot__c cr : [SELECT Id, CreatedDate
												FROM Confirmed_Revenue_Snapshot__c]){
			System.debug(cr.CreatedDate);
		}

		// create dashboard controller and check returned values 
		DashboardController dbc = new DashboardController();

		System.assertEquals(30, dbc.getCurrentRevenue());
		System.assertEquals(30, dbc.getCurrentGrossProfit());
		System.assertEquals(30, dbc.getCurrentNetProfit());
		System.assertEquals(6, dbc.getRevenueChange());
		System.assertEquals(6, dbc.getGrossProfitChange());
		System.assertEquals(6, dbc.getNetProfitChange());

	}

	
}