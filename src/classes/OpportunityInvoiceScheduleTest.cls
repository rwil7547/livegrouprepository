@isTest
public class OpportunityInvoiceScheduleTest {

	@isTest
	public static void singleOppInsertPositiveCase() {

        Account acc = (Account)SmartFactory.createSOBject('Account');
        insert acc;

        Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp.AccountId = acc.Id;
        opp.Amount = 5000;
        opp.StageName = 'Closed Won';
        opp.Invoice_Schedule__c = 'Single post-event invoice';
        opp.Event_Start__c = Date.today();
        opp.Event_End__c = Date.today();
        insert opp;

        Invoice_Schedule__c is = [SELECT Id 
                                        FROM Invoice_Schedule__c
        				WHERE Opportunity__c = :opp.Id LIMIT 1];

        // assert that one child invoice schedule has been created
        System.AssertNotEquals(null, is);
	}

	@isTest
	public static void singleOppInsertNegativeCase() {

        Account acc = (Account)SmartFactory.createSOBject('Account');
        insert acc;
        
        Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp.AccountId = acc.Id;
        opp.Amount = 5000;
        opp.StageName = 'Costed Prospect';
        opp.Invoice_Schedule__c = 'Single post-event invoice';
        opp.Event_Start__c = Date.today();
        opp.Event_End__c = Date.today();
        insert opp;

        // assert that no schedule objects have been created
        System.assertEquals(0,[SELECT Id FROM Invoice_Schedule__c].size());
		
	}

	@isTest
	public static void singleOppStatusUpdateClosed() {

        Account acc = (Account)SmartFactory.createSOBject('Account');
        insert acc;
        
        Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp.AccountId = acc.Id;
        opp.Amount = 5000;
        opp.StageName = 'Costed Prospect';
        opp.Invoice_Schedule__c = 'Three stage invoice';
        opp.Event_Start__c = Date.today();
        opp.Event_End__c = Date.today();
        insert opp;

        opp.StageName = 'Closed Won';
        update opp;

        // query for newly created invoice schedules 
        List<Invoice_Schedule__c> isList = [SELECT Id 
                                                FROM Invoice_Schedule__c
        					WHERE Opportunity__c = :opp.Id];
		
		// check that three invoice schedules have been created 
		System.assertEquals(3,isList.size());
	}

	@isTest
	public static void singleOppStatusUpdateOpen() {

        Account acc = (Account)SmartFactory.createSOBject('Account');
        insert acc;
        
        Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp.AccountId = acc.Id;
        opp.Amount = 5000;
        opp.StageName = 'Closed Won';
        opp.Invoice_Schedule__c = 'Two stage invoice';
        opp.Event_Start__c = Date.today();
        opp.Event_End__c = Date.today();
        insert opp;

        // query for newly created invoice schedules 
        List<Invoice_Schedule__c> isList = [SELECT Id 
                                                FROM Invoice_Schedule__c
        					WHERE Opportunity__c = :opp.Id];
		
		// check that three invoice schedules have been created 
		System.assertEquals(2,isList.size());

        opp.StageName = 'Costed Prospect';
        update opp;

        // query for newly created invoice schedules 
        List<Invoice_Schedule__c> isList2 = [SELECT Id 
                                                FROM Invoice_Schedule__c
        					WHERE Opportunity__c = :opp.Id];
		
		// check that three invoice schedules have been created 
		System.assertEquals(0,isList2.size());

	}

	@isTest
	public static void singleOppDateUpdated() {
		// check that the amount on the invoice schedule object updates
		// when the Opportunity amount is updated

        Account acc = (Account)SmartFactory.createSOBject('Account');
        insert acc;

        Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp.AccountId = acc.Id;
        opp.Amount = 5000;
        opp.StageName = 'Closed Won';
        opp.Invoice_Schedule__c = 'Single up-front invoice';
        opp.Event_Start__c = Date.today();
        opp.Event_End__c = Date.today();
        insert opp;

        Invoice_Schedule__c is = [SELECT Id, Send_Date__c 
                                        FROM Invoice_Schedule__c
        				WHERE Opportunity__c = :opp.Id];

        // assert that the schedule's send date is three days from today
        System.assertEquals(Date.today() + 3,is.Send_Date__c);

        opp.Event_End__c = Date.today().addDays(10);
        update opp;

        // update the end date of the opportunity 
        Invoice_Schedule__c is2 = [SELECT Id, Send_Date__c 
                                        FROM Invoice_Schedule__c
        				WHERE Opportunity__c = :opp.Id];

        // assert that the schedule's send date has moved forward by the same 
        // number of days as the end date on the opportunity
        System.assertEquals(Date.today() + 13,is2.Send_Date__c);        							

	}

	@isTest
	public static void singleOppAmountUpdateProcessed() {
		// check that a new invoice schedule is created when the opp 
		// amount is updated, because the existing invoice schedule 
		// is already processed

        Account acc = (Account)SmartFactory.createSOBject('Account');
        insert acc;

        Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp.AccountId = acc.Id;
        opp.Amount = 5000;
        opp.StageName = 'Closed Won';
        opp.Invoice_Schedule__c = 'Single up-front invoice';
        opp.Event_Start__c = Date.today();
        opp.Event_End__c = Date.today();
        insert opp;

        Invoice_Schedule__c is = [SELECT Id,Amount__c 
                                  FROM Invoice_Schedule__c
        		          WHERE Opportunity__c = :opp.Id];

        // mark the invoice schedule as sent 
        is.Invoice_Sent__c = true;							
        update is;							

        // change the amount on the Opportunity
        opp.Amount = 1000;
        update opp;

        List<Invoice_Schedule__c> isList = [SELECT Id,Amount__c 
                                             FROM Invoice_Schedule__c
        				     WHERE Opportunity__c = :opp.Id];

        // assert that the invoice schedule amount has been updated 
        System.AssertEquals(2, isList.size());							

	}

	@isTest
	public static void singleOppAmountUpdateExcessSchedules() {
		// check that a new invoice schedule is created when the opp 
		// amount is updated, if the existing invoice schedules 
		// are already processed

        Account acc = (Account)SmartFactory.createSOBject('Account');
        insert acc;

        Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp.AccountId = acc.Id;
        opp.Amount = 5000;
        opp.StageName = 'Closed Won';
        opp.Invoice_Schedule__c = 'Three stage invoice';
        opp.Event_Start__c = Date.today();
        opp.Event_End__c = Date.today();
        insert opp;

        List<Invoice_Schedule__c> isList = [SELECT Id,Amount__c 
                                            FROM Invoice_Schedule__c
        				    WHERE Opportunity__c = :opp.Id];

        // verify that three schedules were created on opp insert
        System.assertEquals(3,isList.size());									

        // mark the invoice schedules as sent 
        for (Invoice_Schedule__c is1 : isList) is1.Invoice_Sent__c = true;							
        update isList;

        // change the amount on the Opportunity
        opp.Amount = 1000;
        update opp;

        List<Invoice_Schedule__c> isList2 = [SELECT Id,Amount__c 
                                             FROM Invoice_Schedule__c
        				     WHERE Opportunity__c = :opp.Id];

        // assert that the invoice schedule amount has been updated 
        System.AssertEquals(4, isList2.size());

        Invoice_Schedule__c is = [SELECT Id, Amount__c 
                                  FROM Invoice_Schedule__c
        			  WHERE Opportunity__c = :opp.Id 
        			  AND Invoice_Sent__c = false LIMIT 1];

        // assert that there is only one invoice schedule not marked as sent, 
        // and that the total amount of all invoices still equals the total
        // amount on the opportunity 
        System.assertNotEquals(null, is);
        System.assertEquals(-4000, is.Amount__c); 

        // check that the number of schedules reduces back to three if the existing
        // schedules are marked as unsent and the opp amount is changed
        for (Invoice_Schedule__c is2 : isList) is2.Invoice_Sent__c = false;							
        update isList;

        // update the amount on the Opportunity 
        opp.Amount = 20000;
        update opp;

        List<Invoice_Schedule__c> isList3 = [SELECT Id,Amount__c 
                                             FROM Invoice_Schedule__c
        			             WHERE Opportunity__c = :opp.Id];

        // assert that the excess schedule has been removed and only three remain 
        System.AssertEquals(3, isList3.size());        
	}

	@isTest
	public static void singleOppAmountUpdateUnprocessed() {
		// check that the amount on the invoice schedule object updates
		// when the Opportunity amount is updated

        Account acc = (Account)SmartFactory.createSOBject('Account');
        insert acc;

        Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp.AccountId = acc.Id;
        opp.Amount = 5000;
        opp.StageName = 'Closed Won';
        opp.Invoice_Schedule__c = 'Single up-front invoice';
        opp.Event_Start__c = Date.today();
        opp.Event_End__c = Date.today();
        insert opp;

        Invoice_Schedule__c is = [SELECT Id,Amount__c 
                                 FROM Invoice_Schedule__c
        			 WHERE Opportunity__c = :opp.Id];

        // assert that one child invoice schedule has been created
        System.AssertNotEquals(null, is);
        // assert that the schedule's amount matches the opp amount
        System.assertEquals(5000,is.Amount__c);

        opp.Amount = 1000;
        update opp;

        Invoice_Schedule__c is2 = [SELECT Id,Amount__c 
                                   FROM Invoice_Schedule__c
        			   WHERE Opportunity__c = :opp.Id];

        // assert that the invoice schedule amount has been updated 
        System.AssertEquals(1000, is2.Amount__c);							

	}

	@isTest
	public static void bulkOppInsert() {

        Account acc = (Account)SmartFactory.createSOBject('Account');
        acc.OwnerId = UserInfo.getUserId();
        insert acc;

        List<Opportunity> opps = new List<Opportunity>();

        for (Integer i = 0; i < 30; i++){
	        Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
	        opp.AccountId = acc.Id;
	        opp.Amount = 5000;
	        opp.StageName = 'Closed Won';
	        opp.Invoice_Schedule__c = 'Single post-event invoice';
	        opp.Event_Start__c = Date.today();
	        opp.Event_End__c = Date.today();
	        opp.OwnerId = acc.OwnerId;
	        opps.add(opp);
	    }    

	insert opps; 

        List<Invoice_Schedule__c> isList = [SELECT Id 
        				    FROM Invoice_Schedule__c];

        // assert that one child invoice schedule has been created
        System.AssertEquals(30, isList.size());
	}


}