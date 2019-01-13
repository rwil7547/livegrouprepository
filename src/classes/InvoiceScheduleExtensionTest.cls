@isTest
private class InvoiceScheduleExtensionTest {
	
	@isTest
	static void callExtension() {

        Account acc = (Account)SmartFactory.createSOBject('Account');
        insert acc;

        Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp.AccountId = acc.Id;
        opp.Amount = 6000;
        opp.StageName = 'Closed Won';
        opp.Invoice_Schedule__c = 'Three stage invoice';
        opp.Event_Start__c = Date.today();
        opp.Event_End__c = Date.today();
        insert opp;

        Expense__c ex = new Expense__c();
        ex.Amount__c = 100;
        ex.Opportunity__c = opp.Id;
        insert ex;
 
 		ApexPages.StandardController sc = new ApexPages.StandardController(opp);  		
 		InvoiceScheduleExtension ise = new InvoiceScheduleExtension(sc);   		

 		// verify the controller list returns three invoice schedules 
 		System.assertEquals(3,ise.cSchedules.size());

 		// verify the controller list returns one expense record 
 		System.assertEquals(1,ise.expenses.size());

 		// verify that the default value to distribute among invoices is correct
 		System.assertEquals(2000,ise.defaultValue);

 		// verify that edit mode is false 
 		System.assertEquals(false,ise.editMode);

 		// call allowEdit()
 		String isId = ise.cSchedules[0].is.Id;
 		System.currentPageReference().getParameters().put('selectedId', isId);
 		ise.allowEdit();

 		// verify that the selected schedule is now editable 
 		System.assertEquals(true, ise.cSchedules[0].selected);

 		// verify that edit mode is on 
 		System.assertEquals(true,ise.editMode);

		// call doEdit()		
		ise.cSchedules[0].is.Amount__c = 3000;
 		System.currentPageReference().getParameters().put('editId', isId);		
		ise.doEdit();

		// verify that the value of the schedule is now 3000
 		System.assertEquals(3000,[SELECT Amount__c FROM Invoice_Schedule__c WHERE Id = :isId].Amount__c);		

 		ise.doCancel();

 		// verify that after all methods in controller have been called the opp values remain the same 
 		System.assertEquals(6000, [SELECT Amount FROM Opportunity WHERE Id = :opp.Id].Amount);
	}
}