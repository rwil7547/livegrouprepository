@isTest
private class OppEmailControllerTest {
	
	@isTest static void withTwoOpportunities() {

		insert new Account(Name = 'Test');

		Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
		opp.AccountId = [SELECT Id FROM Account LIMIT 1].id;
		opp.StageName = 'Closed Won';
		opp.Invoice_Schedule__c = 'Single post-event invoice';
		opp.Event_Start__c = Date.today();
		opp.Event_End__c = Date.today().addDays(1);
		insert opp;

		Opportunity opp2 = (Opportunity)SmartFactory.createSOBject('Opportunity');
		opp2.AccountId = [SELECT Id FROM Account LIMIT 1].id;
		opp2.StageName = 'Closed Won';
		opp2.Invoice_Schedule__c = 'Single post-event invoice';
		opp2.Event_Start__c = Date.today().addDays(-1);
		opp2.Event_End__c = Date.today().addDays(2);
		insert opp2;

		OppEmailController oec = new OppEmailController();
		oec.opportunityId = opp.Id;
		oec.getDataSetup();

		String oppCount = 'There is currently 1 other confirmed event taking place on these dates:';
		string dates =  ' goes from ' + 
			String.valueOf(DateTime.newInstance(opp.Event_Start__c.year(),opp.Event_Start__c.month(),opp.Event_Start__c.day()).format('EEEEE')) + 
			' ' + opp.Event_Start__c.day() + ' ' + 
			String.valueOf(DateTime.newInstance(opp.Event_Start__c.year(),opp.Event_Start__c.month(),opp.Event_Start__c.day()).format('MMMMM')) + 
    		' to ' + String.valueOf(DateTime.newInstance(opp.Event_End__c.year(),opp.Event_End__c.month(),opp.Event_End__c.day()).format('EEEEE')) + ' ' + 
    		opp.Event_End__c.day() + ' ' + String.valueOf(DateTime.newInstance(opp.Event_End__c.year(),opp.Event_End__c.month(),opp.Event_End__c.day()).format('MMMMM')) + 
    		' ' + opp.Event_End__c.year() + ' (location TBC)';

//    	System.AssertEquals(oppCount, oec.getCount());
//    	System.AssertEquals(dates, oec.getDates());
//    	System.AssertEquals(1, oec.getDetails().size());
//    	System.AssertEquals(true, oec.gethasValues());

	}

	@isTest static void withTwoOppsOneRoadshow() {

		insert new Account(Name = 'Test');

		Opportunity opp 		= (Opportunity)SmartFactory.createSOBject('Opportunity');
		opp.AccountId 			= [SELECT Id FROM Account LIMIT 1].id;
		opp.StageName 			= 'Closed Won';
		opp.Invoice_Schedule__c = 'Single post-event invoice';
		opp.Event_Start__c 		= Date.today();
		opp.Event_End__c 		= Date.today().addDays(2);
		insert opp;

		Opportunity opp2 		= (Opportunity)SmartFactory.createSOBject('Opportunity');
		opp2.AccountId 			= [SELECT Id FROM Account LIMIT 1].id;
		opp2.StageName 			= 'Closed Won';
		opp2.Invoice_Schedule__c = 'Single post-event invoice';
		opp2.Event_Start__c 	= Date.today().addDays(-1);
		opp2.Event_End__c 		= Date.today().addDays(3);
		insert opp2;

		Roadshow_Event__c rs 	= new Roadshow_Event__c();
		rs.Parent_Opportunity__c = opp.Id;
		rs.Event_Start__c 		= opp.Event_Start__c;
		rs.Event_End__c 		= opp.Event_End__c;
		insert rs;

		OppEmailController oec = new OppEmailController();
		oec.opportunityId = opp.Id;
		oec.getDataSetup();

		String oppCount = 'There are currently 2 other confirmed events taking place on these dates:';

		string dates =  ' takes place on ' + String.valueOf(DateTime.newInstance(opp.Event_End__c.year(),opp.Event_End__c.month(),opp.Event_End__c.day()).format('EEEEE')) + ' '+
    		opp.Event_End__c.day() + ' ' + String.valueOf(DateTime.newInstance(opp.Event_End__c.year(),opp.Event_End__c.month(),opp.Event_End__c.day()).format('MMMMM')) + 
    		' ' + opp.Event_End__c.year() + ' (location TBC)';

//    	System.AssertEquals(oppCount, oec.getCount());
//    	System.AssertEquals(dates, oec.getDates());
//    	System.AssertEquals(2, oec.getDetails().size());
//    	System.AssertEquals(true, oec.gethasValues());

	}

	
	@isTest static void withOneOpportunity() {

		insert new Account(Name = 'Test');

		Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
		opp.AccountId = [SELECT Id FROM Account LIMIT 1].id;
		opp.StageName = 'Closed Won';
		opp.Invoice_Schedule__c = 'Single post-event invoice';
		opp.Event_Start__c = Date.today();
		opp.Event_End__c = Date.today();
		insert opp;

		OppEmailController oec = new OppEmailController();
		oec.opportunityId = opp.Id;
		oec.getDataSetup();

		String oppCount = 'There are currently no other confirmed events taking place on this date.';
		string dates =  ' takes place on ' + String.valueOf(DateTime.newInstance(opp.Event_Start__c.year(),opp.Event_Start__c.month(),opp.Event_Start__c.day()).format('EEEEE')) + ' '+
    		opp.Event_Start__c.day() + ' ' + String.valueOf(DateTime.newInstance(opp.Event_Start__c.year(),opp.Event_Start__c.month(),opp.Event_Start__c.day()).format('MMMMM')) + 
    		' ' + opp.Event_Start__c.year() + ' (location TBC)';

//    	System.AssertEquals(oppCount, oec.getCount());
//    	System.AssertEquals(dates, oec.getDates());
//    	System.AssertEquals(0, oec.getDetails().size());
//    	System.AssertEquals(false, oec.gethasValues());

	}
	
}