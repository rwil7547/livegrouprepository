@IsTest
public class InvoiceScheduleTriggerHandlerTest {

	@IsTest
	public static void updateAmountSingleInvoice() {

        Account acc = (Account)SmartFactory.createSObject('Account');
        insert acc;

        Opportunity opp         = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp.AccountId           = acc.Id;
        opp.Amount              = 5000;
        opp.StageName           = 'Costed prospect';
        opp.Invoice_Schedule__c = 'Single up-front invoice';
        opp.Event_start__c      = Date.today();
        opp.Event_end__c        = Date.today();
        insert opp;

        insert new SBQQ__Quote__c(
            SBQQ__Primary__c        = true,
            SBQQ__Opportunity2__c   = opp.Id
        );

        opp.StageName = 'Closed Won';
        update opp;

        // assert that one child invoice schedule has been created
        System.assertEquals(1,[SELECT Id FROM Invoice_Schedule__c].size());
        System.assertEquals(5000,[SELECT Invoices_Sum__c FROM Opportunity WHERE Id = :opp.Id].Invoices_Sum__c);

        // editing the schedule amount should trigger the creation of more invoice
        // schedules
        OpportunityTriggerHandler.noConflict = true;
        InvoiceScheduleTriggerHandler.noConflict = true;
        Invoice_Schedule__c is = [SELECT Id FROM Invoice_Schedule__c]; 
        is.Amount__c = 6000;
        update is;

        System.assertEquals(2,[SELECT Id FROM Invoice_Schedule__c].size());
        System.assertEquals(5000,[SELECT Invoices_Sum__c FROM Opportunity WHERE Id = :opp.Id].Invoices_Sum__c);

        // editing the opportunity amount should revert the schedule count 
        // back to one
        opp.Amount = 1000;
        update opp;

        System.assertEquals(1,[SELECT Id FROM Invoice_Schedule__c].size());
        System.assertEquals(1000,[SELECT Invoices_Sum__c FROM Opportunity WHERE Id = :opp.Id].Invoices_Sum__c);

	}

	@IsTest
	public static void updateDatetSingleInvoice() {

        Account acc = (Account)SmartFactory.createSObject('Account');
        insert acc;

        Opportunity opp         = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp.AccountId           = acc.Id;
        opp.Amount              = 5000;
        opp.StageName           = 'Costed prospect';
        opp.Invoice_Schedule__c = 'Single up-front invoice';
        opp.Event_start__c      = Date.today();
        opp.Event_end__c        = Date.today();
        insert opp;

        insert new SBQQ__Quote__c(
            SBQQ__Primary__c        = true,
            SBQQ__Opportunity2__c   = opp.Id
        );

        opp.StageName = 'Closed Won';
        update opp;

        // assert that one child invoice schedule has been created
        System.assertEquals(1,[SELECT Id FROM Invoice_Schedule__c].size());
        System.assertEquals(5000,[SELECT Invoices_Sum__c FROM Opportunity WHERE Id = :opp.Id].Invoices_Sum__c);

        // edit the date on the Opportunity and check that the send date on the 
        // invoice schedule has updated
        OpportunityTriggerHandler.noConflict = true;
        InvoiceScheduleTriggerHandler.noConflict = true;
        Invoice_Schedule__c is = [SELECT Id FROM Invoice_Schedule__c]; 
        is.Send_Date__c = Date.today().addDays(30);
        update is;
        System.assertEquals(Date.today().addDays(60),[SELECT Payment_Date__c FROM Invoice_Schedule__c].Payment_Date__c);

    } 

	@IsTest
	public static void causeScheduleCreate() {

        Account acc = (Account)SmartFactory.createSObject('Account');
        insert acc;

        Opportunity opp         = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp.AccountId           = acc.Id;
        opp.Amount              = 5000;
        opp.StageName           = 'Costed prospect';
        opp.Invoice_Schedule__c = 'Single up-front invoice';
        opp.Event_start__c      = Date.today();
        opp.Event_end__c        = Date.today();
        insert opp;

        insert new SBQQ__Quote__c(
                SBQQ__Primary__c = true,
                SBQQ__Opportunity2__c = opp.Id
        );

        opp.StageName = 'Closed Won';
        update opp;

        // assert that one child invoice schedule has been created
        System.assertEquals(1,[SELECT Id FROM Invoice_Schedule__c].size());
        System.assertEquals(5000,[SELECT Invoices_Sum__c FROM Opportunity WHERE Id = :opp.Id].Invoices_Sum__c);

        // set the schedule as sent and update the amount, and check that this causes
        // the creation of an additional schedule
        OpportunityTriggerHandler.noConflict = true;  
        InvoiceScheduleTriggerHandler.noConflict = true; 
        Invoice_Schedule__c is = [SELECT Id FROM Invoice_Schedule__c]; 
        is.Amount__c = 6000;
        is.Invoice_Sent__c = true;
        update is;
        System.assertEquals(2,[SELECT Id FROM Invoice_Schedule__c].size());
        System.assertEquals(5000,[SELECT Invoices_Sum__c FROM Opportunity WHERE Id = :opp.Id].Invoices_Sum__c);

        // mark both schedules as sent, change the amounts and verify that three
        // schedules exist as a result
        OpportunityTriggerHandler.noConflict = true;  
        InvoiceScheduleTriggerHandler.noConflict = true;          
        List<Invoice_Schedule__c> isList = [SELECT Id FROM Invoice_Schedule__c];
        for (Invoice_Schedule__c schedule : isList) {
        	schedule.Invoice_Sent__c = true;
        	schedule.Amount__c = 10000;
        	update schedule;
        	OpportunityTriggerHandler.noConflict = true;  
        	InvoiceScheduleTriggerHandler.noConflict = true;  
        }      


        System.assertEquals(3,[SELECT Id FROM Invoice_Schedule__c].size());
        System.assertEquals(5000,[SELECT Invoices_Sum__c FROM Opportunity WHERE Id = :opp.Id].Invoices_Sum__c);

	}

	@IsTest
	public static void causeScheduleDelete() {

        Account acc = (Account)SmartFactory.createSObject('Account');
        insert acc;

        Opportunity opp         = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp.AccountId           = acc.Id;
        opp.Amount              = 5000;
        opp.StageName           = 'Costed prospect';
        opp.Invoice_Schedule__c = 'Two stage invoice';
        opp.Event_start__c      = Date.today();
        opp.Event_end__c        = Date.today();
        insert opp;

        insert new SBQQ__Quote__c(
                SBQQ__Primary__c = true,
                SBQQ__Opportunity2__c = opp.Id
        );

        opp.StageName = 'Closed Won';
        update opp;

        // assert that two child invoice schedules have been created
        System.assertEquals(2,[SELECT Id FROM Invoice_Schedule__c].size());
        System.assertEquals(5000,[SELECT Invoices_Sum__c FROM Opportunity WHERE Id = :opp.Id].Invoices_Sum__c);

        // set the value of one invoice schedule to the total amount on the Opportunity
        // and verify that the second schedule has been deleted 
        OpportunityTriggerHandler.noConflict = true;  
        InvoiceScheduleTriggerHandler.noConflict = true; 
        Invoice_Schedule__c is = [SELECT Id FROM Invoice_Schedule__c LIMIT 1]; 
        is.Amount__c = 5000;
        is.Invoice_Sent__c = true;
        update is;

        System.assertEquals(1,[SELECT Id FROM Invoice_Schedule__c].size());
        System.assertEquals(5000,[SELECT Invoices_Sum__c FROM Opportunity WHERE Id = :opp.Id].Invoices_Sum__c);

	}

	@IsTest
	public static void causeMultiScheduleDelete() {

        Account acc = (Account)SmartFactory.createSObject('Account');
        insert acc;

        Opportunity opp         = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp.AccountId           = acc.Id;
        opp.Amount              = 5000;
        opp.StageName           = 'Costed prospect';
        opp.Invoice_Schedule__c = 'Single up-front invoice';
        opp.Event_start__c      = Date.today();
        opp.Event_end__c        = Date.today();
        insert opp;

        insert new SBQQ__Quote__c(
                SBQQ__Primary__c = true,
                SBQQ__Opportunity2__c = opp.Id
        );

        opp.StageName = 'Closed Won';
        update opp;

        // assert that one child invoice schedule has been created
        System.assertEquals(1,[SELECT Id FROM Invoice_Schedule__c].size());
        System.assertEquals(5000,[SELECT Invoices_Sum__c FROM Opportunity WHERE Id = :opp.Id].Invoices_Sum__c);

        // set the value of one invoice schedule to less than the total amount on the Opportunity
        // and verify that a second invoice schedule has been created 
        OpportunityTriggerHandler.noConflict        = true;
        InvoiceScheduleTriggerHandler.noConflict    = true;
        Invoice_Schedule__c is  = [SELECT Id FROM Invoice_Schedule__c LIMIT 1];
        is.Amount__c            = 1000;
        is.Invoice_Sent__c      = true;
        update is;

        System.assertEquals(2,[SELECT Id FROM Invoice_Schedule__c].size());
        System.assertEquals(1,[SELECT Id FROM Invoice_Schedule__c WHERE Invoice_Sent__c = FALSE].size());
        System.assertEquals(5000,[SELECT Invoices_Sum__c FROM Opportunity WHERE Id = :opp.Id].Invoices_Sum__c);

        // set the value of the second invoice schedule to less than the total amount on the Opportunity
        // and verify that a third invoice schedule has been created 
        OpportunityTriggerHandler.noConflict = true;  
        InvoiceScheduleTriggerHandler.noConflict = true; 
        Invoice_Schedule__c is2 = [SELECT Id FROM Invoice_Schedule__c WHERE Invoice_Sent__c = FALSE LIMIT 1];
        is2.Amount__c = 1000;
        is2.Invoice_Sent__c = true;
        update is2;

        System.assertEquals(3,[SELECT Id FROM Invoice_Schedule__c].size());
        System.assertEquals(1,[SELECT Id FROM Invoice_Schedule__c WHERE Invoice_Sent__c = FALSE].size());
        System.assertEquals(5000,[SELECT Invoices_Sum__c FROM Opportunity WHERE Id = :opp.Id].Invoices_Sum__c);

        // mark all schedules as unsent and verify that three
        // schedules still exist 
        OpportunityTriggerHandler.noConflict        = true;
        InvoiceScheduleTriggerHandler.noConflict    = true;
        List<Invoice_Schedule__c> isList = [SELECT Id FROM Invoice_Schedule__c];
        for (Invoice_Schedule__c schedule : isList) {
        	schedule.Invoice_Sent__c = false;
        	update schedule;
        	OpportunityTriggerHandler.noConflict = true;  
        	InvoiceScheduleTriggerHandler.noConflict = true;  
        }

        System.assertEquals(3,[SELECT Id FROM Invoice_Schedule__c].size());
        System.assertEquals(3,[SELECT Id FROM Invoice_Schedule__c WHERE Invoice_Sent__c = FALSE].size());
        System.assertEquals(5000,[SELECT Invoices_Sum__c FROM Opportunity WHERE Id = :opp.Id].Invoices_Sum__c);


        // amend the value of one schedule and ensure that only two remain  
        OpportunityTriggerHandler.noConflict = true;  
        InvoiceScheduleTriggerHandler.noConflict = true; 
        Invoice_Schedule__c is3 = [SELECT Id FROM Invoice_Schedule__c LIMIT 1]; 
        is3.Amount__c = 1;
        is3.Invoice_Sent__c = true;
        update is3;

        System.assertEquals(2,[SELECT Id FROM Invoice_Schedule__c].size());
        System.assertEquals(5000,[SELECT Invoices_Sum__c FROM Opportunity WHERE Id = :opp.Id].Invoices_Sum__c);
	}
}