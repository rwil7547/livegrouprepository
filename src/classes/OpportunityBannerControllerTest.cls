@isTest
private class OpportunityBannerControllerTest{
	
	@isTest
	static void callBannerControllerUnsentInvoices() {

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

        // modify the values of the invoice schedules belong to the opp
        List<Invoice_Schedule__c> isList = [SELECT Id 
        									FROM Invoice_Schedule__c
        									ORDER BY Name ASC];

        // verify that three invoice schedules were created 
        System.assertEquals(3,isList.size());

        isList[0].Send_Date__c = Date.today().addDays(-2);        
        isList[1].Send_Date__c = Date.today();        
        isList[2].Send_Date__c = Date.today().addDays(2);        

        update isList;         

        ApexPages.currentPage().getParameters().put('id', opp.Id);		
 		OpportunityBannerController obc = new OpportunityBannerController();           

 		// verify the controller list returns three invoice schedules 
 		System.assertEquals(3,obc.schedules.size());

 		// verify that the string values returned by the controller are as expected
 		System.assertEquals('Invoice due 2 days ago',obc.schedules[0].invoiceStatus);
 		System.assertEquals('Invoice due today',obc.schedules[1].invoiceStatus);
 		System.assertEquals('Invoice due in 2 days',obc.schedules[2].invoiceStatus);

 		// verify that the url returned is correct 
		String shortId = String.valueOf(opp.Id).substring(0, 15);
		String listView = System.URL.getSalesforceBaseURL().toExternalForm() + '/apex/InvoiceSchedulesRelatedList?id=' + shortId; 		
		System.assertEquals(listView, obc.listView);

	}

	@isTest
	static void callBannerControllerSentInvoices() {

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

        // modify the values of the invoice schedules belong to the opp
        List<Invoice_Schedule__c> isList = [SELECT Id 
        									FROM Invoice_Schedule__c
        									ORDER BY Name ASC];

        // verify that three invoice schedules were created 
        System.assertEquals(3,isList.size());

        isList[0].Invoice_Sent__c = true;        
        isList[0].Payment_Date__c = Date.today().addDays(-2);
        isList[1].Invoice_Sent__c = true;             
        isList[1].Payment_Date__c = Date.today();
        isList[2].Invoice_Sent__c = true;               
        isList[2].Payment_Date__c = Date.today().addDays(2);

        update isList;         

        ApexPages.currentPage().getParameters().put('id', opp.Id);		
 		OpportunityBannerController obc = new OpportunityBannerController();           

 		// verify the controller list returns three invoice schedules 
 		System.assertEquals(3,obc.schedules.size());

 		// verify that the string values returned by the controller are as expected
 		System.assertEquals('Payment due 2 days ago',obc.schedules[0].paymentStatus);
 		System.assertEquals('Payment due today',obc.schedules[1].paymentStatus);
 		System.assertEquals('Payment due in 2 days',obc.schedules[2].paymentStatus);

 		// verify that the url returned is correct 
		String shortId = String.valueOf(opp.Id).substring(0, 15);
		String listView = System.URL.getSalesforceBaseURL().toExternalForm() + '/apex/InvoiceSchedulesRelatedList?id=' + shortId; 		
		System.assertEquals(listView, obc.listView);

	}	
}