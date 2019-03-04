@isTest
public class QuickbooksCustomerBatchTest {

	@testSetup static void insertAccountandOpportunity() {

		// insert new Opp and account
		Account acc = new Account();
		acc.Name = 'Test';
		insert acc;

		Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
		opp.AccountId = [SELECT Id FROM Account LIMIT 1].id;
		opp.StageName = 'Costed Prospect';
		opp.Amount = 0;
		opp.QuickbooksClassId__c = '123';
		opp.Invoice_Schedule__c = 'Three stage invoice';
		opp.Event_Start__c = Date.today();
		opp.Event_End__c = Date.today().addDays(1);

		insert opp;

	}

	@isTest static void insertCustomerFromInsertTrigger() {

		// method purpose: ensure that when an Opportunity is closed won
		// on insert, and the account does not exist as a customer in Quickbooks,
		// the trigger will make a callout to Quickbooks and populate the
		// account record with the Id returned from Quickbooks.

		// ensure the trigger allows the callout in test context
		TestHelper.calloutTest = true;

		// insert new Opp and account
		Account acc = [SELECT Id,Name FROM Account LIMIT 1];

		Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
		opp.AccountId = [SELECT Id FROM Account LIMIT 1].id;
		opp.StageName = 'Closed Won';
		opp.Amount = 1200;
		opp.QuickbooksClassId__c = '123';
		opp.Invoice_Schedule__c = 'Three stage invoice';
		opp.Event_Start__c = Date.today();
		opp.Event_End__c = Date.today().addDays(1);

		Test.startTest();

    	// Set mock callout class and pass the name of the account
        Test.setMock(HttpCalloutMock.class, new QuickbooksCustomerBatchMock(acc.Name, 'random name'));

     	// trigger the callout
		insert opp;

		Test.stopTest();

		// todo: reinstate assertions, disabled due to implementation of new quote interface
		// verify that the account
//		System.assertEquals('1303',[SELECT QuickbooksId__c FROM Account].QuickbooksId__c);

	}

	@isTest static void insertCustomerFromUpdateTrigger() {

		// method purpose: ensure that when an Opportunity is closed won
		// on update, and the account does not exist as a customer in Quickbooks,
		// the trigger will make a callout to Quickbooks and populate the
		// account record with the Id returned from Quickbooks.

		// ensure the trigger allows the callout in test context
		TestHelper.calloutTest = true;

		// insert new Opp and account
		Account acc = [SELECT Id, Name FROM Account LIMIT 1];

		Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :acc.Id];

		// verify that the callout has not yet taken place
		System.assertEquals(null,[SELECT QuickbooksId__c FROM Account].QuickbooksId__c);

    	// Set mock callout class and pass the name of the account
        Test.setMock(HttpCalloutMock.class, new QuickbooksCustomerBatchMock(acc.Name, 'random name'));

     	// trigger the callout
		opp.StageName = 'Closed Won';
		update opp;

		// reset the test context to ensure the results of the @future method are accessible
		Test.startTest();
		Test.stopTest();

		// todo: reinstate assertions, disabled due to implementation of new quote interface
		// verify that the account
//		System.assertEquals('1303',[SELECT QuickbooksId__c FROM Account WHERE Id = :acc.Id].QuickbooksId__c);

	}

	@isTest static void insertCustomerFromInlineVFPage() {

		// method purpose: ensure that when an the 'Create Customer in Quickbooks'
		// button on the Account inline visualforce page is clicked, the callout to quickbooks
		// is made via the AccountQuickbooksStatusController.

		Account acc = [SELECT Id, Name FROM Account LIMIT 1];

		// populate controller and page parameters
 		ApexPages.StandardController sc = new ApexPages.StandardController(acc);
 		AccountQuickbooksStatusController aqsc = new AccountQuickbooksStatusController(sc);
		Test.setCurrentPageReference(new PageReference('Page.myPage'));
		System.currentPageReference().getParameters().put('id', acc.Id);

		Test.startTest();

    	// Set mock callout class and pass the name of the account
        Test.setMock(HttpCalloutMock.class, new QuickbooksCustomerBatchMock(acc.Name, 'random name'));

     	// trigger the callout
		aqsc.createCustomer();

		Test.stopTest();

		// verify that the account's Id has been populated
		System.assertEquals('1303',[SELECT QuickbooksId__c FROM Account].QuickbooksId__c);

	}

	@isTest static void insertCustomerNoIdReturned() {

		// method purpose: ensure that when an the 'Create Customer in Quickbooks'
		// button on the Account inline visualforce page is clicked, the callout to quickbooks
		// is made via the AccountQuickbooksStatusController. Ensure that if the Id
		// is not returned in the callout, an Integration_Error__c record is created.

		Account acc = [SELECT Id, Name FROM Account LIMIT 1];

		// populate controller and page parameters
 		ApexPages.StandardController sc = new ApexPages.StandardController(acc);
 		AccountQuickbooksStatusController aqsc = new AccountQuickbooksStatusController(sc);
		Test.setCurrentPageReference(new PageReference('Page.myPage'));
		System.currentPageReference().getParameters().put('id', acc.Id);

		Test.startTest();

    	// Set mock callout class and pass the wrong name for the account
        Test.setMock(HttpCalloutMock.class, new QuickbooksCustomerBatchMock('Wrong Account Name', 'random name'));

     	// trigger the callout
		aqsc.createCustomer();

		Test.stopTest();

		// verify that the account does not have an Id
		System.assertEquals(null,[SELECT QuickbooksId__c FROM Account].QuickbooksId__c);

		// verify that the Integration_Error__c record has been created with the expected values
		Integration_Error__c ie = [SELECT Id, Class__c, sObject__c, Action__c, Outcome__c FROM Integration_Error__c];
		System.assertEquals('QuickbooksCustomerBatch',ie.Class__c);
		System.assertEquals(acc.Id,ie.sObject__c);
		System.assertEquals('Attempt to retrieve Id from Quickbooks',ie.Action__c);
		System.assertEquals('No Id for the record returned',ie.Outcome__c);

	}

	@isTest static void bulkOpportunityClosedWon() {

		// method purpose: ensure that when multiple Opportunities are confirmed
		// only a single callout is made and that the values returned are the values expected

		List<Account> accounts = new List<Account>();
		List<Opportunity> opps = new List<Opportunity>();

		// create ten accounts with closed Opportunities associated with them
		for (Integer x = 0; x < 10; x++) {
			Account acc = new Account(Name = 'Account ' + x);
			accounts.add(acc);
		}

		insert accounts;

		// create and ten closed won Opportunities
		for (Integer x = 0; x < 10; x++) {

			Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
			opp.AccountId = accounts[x].id;
			opp.StageName = 'Closed Won';
			opp.Amount = 1200;
			opp.QuickbooksClassId__c = '123';
			opp.Invoice_Schedule__c = 'Three stage invoice';
			opp.Event_Start__c = Date.today();
			opp.Event_End__c = Date.today().addDays(1);
			opps.add(opp);
		}

		Test.startTest();

		// ensure the trigger allows the callout in test context
		TestHelper.calloutTest = true;

    	// Set mock callout class and pass the name of the account
        Test.setMock(HttpCalloutMock.class, new QuickbooksCustomerBatchMock(accounts[0].Name, accounts[1].Name));

     	// trigger the callout
		insert opps;

		Test.stopTest();

		// todo: reinstate assertions, disabled due to implementation of new quote interface
//		// verify that two accounts have Ids returned by Quickbooks
//		System.assertEquals(2,[SELECT Id FROM Account WHERE QuickbooksId__c != null].size());
//
//		// assert that 8 Integration_Error__c records have been created for the 8
//		// accounts which did not have Ids returned in the callout
//		System.assertEquals(8,[SELECT Id FROM Integration_Error__c].size());

	}
}