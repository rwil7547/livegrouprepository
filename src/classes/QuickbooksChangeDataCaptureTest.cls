@isTest
private class QuickbooksChangeDataCaptureTest {

     @isTest static void testGetInvoices() {

     	// the method tests for three things
     	// 1. updated invoices returned by the callout
     	// 2. deleted invoices returned by the callout
     	// 3. dereferenced invoices returned by the callout 

		// insert new Opp and account. The opp is set to closed won to trigger
		// the creation of an invoice schedule record. 
		insert new Account(Name = 'Test');

		Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
		opp.AccountId = [SELECT Id FROM Account LIMIT 1].id;
		opp.StageName = 'Closed Won';
		opp.Amount = 1200;
		opp.Invoice_Schedule__c = 'Three stage invoice';
		opp.Event_Start__c = Date.today();
		opp.Event_End__c = Date.today().addDays(1);
		insert opp;

    	// determine range via custom setting 	
		insert new CDCRange__c(Name = 'QuickbooksCDC', Days__c = 1);   

		// verify that two invoice schedules were created 
		List<Invoice_Schedule__c> isList = [SELECT Id, Invoice_Id__c, Amount__c 
											  FROM Invoice_Schedule__c
											  WHERE Opportunity__c = :opp.Id];

		System.assertEquals(3, isList.size());
		System.assertEquals(400,isList[0].Amount__c);
		System.assertEquals(400,isList[1].Amount__c);
		System.assertEquals(400,isList[2].Amount__c);

		// update the Quickbooks invoice number on the second record in the list
		// this number will be identified as deleted in the callout
        Test.startTest();
		isList[1].QBOInvoiceId__c = '18971';
		isList[2].QBOInvoiceId__c = '3034';
		update isList;				  

		// obtain the string value of the first invoie schedule in the list, to be sent to the 
		// mock callout class
     	String autoNumber = String.valueOf(isList[0].Invoice_Id__c);

        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new InvoiceCDCMock(autoNumber));
        
        // Call method to test
        QuickbooksChangeDataCapture.getInvoices();
        Test.stopTest();

        // verify that the values on the first invoice schedule have been changed 
        // when the callout response has been returned 
		Invoice_Schedule__c is1 = [SELECT Id, Invoice_Id__c, Invoice_Amount__c,
										Amount__c, Invoice_Number__c, Payment_Date__c 
								  FROM Invoice_Schedule__c
								  WHERE Invoice_Id__c = :isList[0].Invoice_Id__c];   

		System.assertEquals(5077, is1.Invoice_Amount__c);
		System.assertEquals(5077, is1.Amount__c);
		System.assertEquals(Date.newInstance(2017,03,31), is1.Payment_Date__c);
		System.assertEquals('16080', is1.Invoice_Number__c);

		// verify that the values on the second invoice schedule have been cleared
		// because the callout has returned a deleted record
		Invoice_Schedule__c is2 = [SELECT QBOInvoiceId__c 
								  FROM Invoice_Schedule__c
								  WHERE Invoice_Id__c = :isList[1].Invoice_Id__c];  								       
        
        System.assertEquals(null,is2.QBOInvoiceId__c);

		// verify that the values on the third invoice schedule have been cleared
		// because the callout has returned a derefenced record
		Invoice_Schedule__c is3 = [SELECT QBOInvoiceId__c 
								  FROM Invoice_Schedule__c
								  WHERE Invoice_Id__c = :isList[2].Invoice_Id__c];  								       
        
        System.assertEquals(null,is3.QBOInvoiceId__c);
    }

    @isTest static void testGetCreditMemos() {

     	// the method tests for three things
     	// 1. updated credit memos returned by the callout
     	// 2. deleted credit memos returned by the callout
     	// 3. dereferenced credit memos returned by the callout 

		// insert new Opp and account. The opp is set to closed won to trigger
		// the creation of an invoice schedule record. 
		insert new Account(Name = 'Test');

		Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
		opp.AccountId = [SELECT Id FROM Account LIMIT 1].id;
		opp.StageName = 'Closed Won';
		opp.Amount = 1200;
		opp.Invoice_Schedule__c = 'Three stage invoice';
		opp.Event_Start__c = Date.today();
		opp.Event_End__c = Date.today().addDays(1);
		insert opp;

    	// determine range via custom setting 	
		insert new CDCRange__c(Name = 'QuickbooksCDC', Days__c = 1);   

		// verify that two invoice schedules were created 
		List<Invoice_Schedule__c> isList = [SELECT Id, Invoice_Id__c, Amount__c 
											  FROM Invoice_Schedule__c
											  WHERE Opportunity__c = :opp.Id];

		System.assertEquals(3, isList.size());
		System.assertEquals(400,isList[0].Amount__c);
		System.assertEquals(400,isList[1].Amount__c);
		System.assertEquals(400,isList[2].Amount__c);

		// update the Quickbooks invoice number on the second record in the list
		// this number will be identified as deleted in the callout
		isList[1].QBOCreditNoteId__c = '18955';
		isList[2].QBOCreditNoteId__c = '18975';
		update isList;				  

		// obtain the string value of the first invoie schedule in the list, to be sent to the 
		// mock callout class
     	String autoNumber = String.valueOf(isList[0].Invoice_Id__c);

		Test.startTest();

		// Set mock callout class
        Test.setMock(HttpCalloutMock.class, new CreditMemoCDCMock(autoNumber));
        
        // Call method to test
        QuickbooksChangeDataCapture.getCreditMemos();
        Test.stopTest();

        // verify that the values on the first invoice schedule have been changed 
        // when the callout response has been returned 
		Invoice_Schedule__c is1 = [SELECT Id, Invoice_Id__c, Credit_Note__c,
										 Credit_Note_Number__c 
								  FROM Invoice_Schedule__c
								  WHERE Invoice_Id__c = :isList[0].Invoice_Id__c];   

		System.assertEquals(90, is1.Credit_Note__c);
		System.assertEquals('1019', is1.Credit_Note_Number__c);

		// verify that the values on the second invoice schedule have been cleared
		// because the callout has returned a deleted record
		Invoice_Schedule__c is2 = [SELECT QBOCreditNoteId__c 
								  FROM Invoice_Schedule__c
								  WHERE Invoice_Id__c = :isList[1].Invoice_Id__c];  								       
        
        System.assertEquals(null,is2.QBOCreditNoteId__c);

		// verify that the values on the third invoice schedule have been cleared
		// because the callout has returned a derefenced record
		Invoice_Schedule__c is3 = [SELECT QBOCreditNoteId__c 
								  FROM Invoice_Schedule__c
								  WHERE Invoice_Id__c = :isList[2].Invoice_Id__c];  								       
        
        System.assertEquals(null,is3.QBOCreditNoteId__c);

    }

    @isTest static void testGetBills() {

     	// the method tests for five things
     	// 1. updated bill line items 
     	// 2. new bill line items 
     	// 3. deleted bill line items 
     	// 4. deleted bills 
     	// 5. dereferenced bill line items  

		// insert new Opp and account. The opp is set to closed won to trigger
		// the creation of an invoice schedule record. 
		insert new Account(Name = 'Test');

		Opportunity opp 	= (Opportunity)SmartFactory.createSOBject('Opportunity');
		opp.AccountId 		= [SELECT Id FROM Account LIMIT 1].id;
		opp.StageName 		= 'Closed Won';
		opp.Amount 			= 1200;
		opp.Invoice_Schedule__c = 'Three stage invoice';
		opp.QuickbooksClassId__c = 'testId';
		opp.Event_Start__c 	= Date.today();
		opp.Event_End__c 	= Date.today().addDays(1);
		insert opp;

		// retrieve the job number from the inserted Opportunity 
		String extendedJobNumber = String.valueOf([SELECT Filtered_Job_Number__c FROM Opportunity].Filtered_Job_Number__c);
		String jobNumber = extendedJobNumber.substring(0,5);

		opp.Clive_job_number__c = Decimal.valueOf(jobNumber);
		update opp;

		System.debug('the job number of the opp created in the test is ' + jobNumber);

		// create expense records 
		List<Expense__c> expenses = new List<Expense__c>();

		// expense record with value to be updated 
		Expense__c ex1 		= new Expense__c();
		ex1.Opportunity__c 	= opp.Id;
		ex1.Amount__c 		= 10;
		ex1.Paid__c 		= true;
		ex1.Name 			= '19036-8';
		ex1.QuickbooksId__c	= '19036';
		ex1.Due_Date__c		= Date.today();
		expenses.add(ex1);

		// expense record which has been dereferenced  
		Expense__c ex2 		= new Expense__c();
		ex2.Opportunity__c 	= opp.Id;
		ex2.Amount__c 		= 20;
		ex2.Name 			= '19036-10';
		ex2.QuickbooksId__c	= '19036';
		ex2.Due_Date__c		= Date.today();
		expenses.add(ex2);

		// expense record which references a deleted line item  
		Expense__c ex3 		= new Expense__c();
		ex3.Opportunity__c 	= opp.Id;
		ex3.Amount__c 		= 20;
		ex3.Name 			= '19036-99';
		ex3.QuickbooksId__c	= '19036';
		ex3.Due_Date__c		= Date.today();
		expenses.add(ex3);

		insert expenses;

    	// determine range via custom setting 	
		insert new CDCRange__c(Name = 'QuickbooksCDC', Days__c = 1);   

        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new BillCDCMock(jobNumber));
        
        // Call method to test
        QuickbooksChangeDataCapture.getBills();
        Test.stopTest();

        // verify that only two Expense__c records now exist - two should 
        // have been deleted based on the contents of the mock, and one
        // additional expense should have been created
        System.assertEquals(2,[SELECT Id FROM Expense__c].size());

        // verify that the Expense__c record which existed prior to the callout 
        // now has updated values 
        Expense__c expense1 = [SELECT Id, Amount__c, Paid__c, Due_Date__c
        						FROM Expense__c 
        						WHERE Name = '19036-8'];

        System.assertEquals(2000,expense1.Amount__c);       
        System.assertEquals(false,expense1.Paid__c); 
        System.assertEquals(Date.newInstance(2018,05,20),expense1.Due_Date__c); 

        // verify that a new Expense__c record has been created with the right values
        Expense__c expense2 = [SELECT Id, Amount__c, Paid__c, Due_Date__c
        						FROM Expense__c 
        						WHERE Name = '19036-22'];

        System.assertEquals(1000,expense2.Amount__c);       
        System.assertEquals(false,expense2.Paid__c); 
        System.assertEquals(Date.newInstance(2018,05,20),expense2.Due_Date__c); 

    }

	@isTest static void testGetVendorCredits() {

		// the method tests for five things
		// 1. updated vendorCredit line items
		// 2. new vendorCredit line items
		// 3. deleted vendorCredit line items
		// 4. deleted vendorCredits
		// 5. dereferenced vendorCredit line items

		// insert new Opp and account. The opp is set to closed won to trigger
		// the creation of an invoice schedule record.
		insert new Account(Name = 'Test');

		Opportunity opp 	= (Opportunity)SmartFactory.createSOBject('Opportunity');
		opp.AccountId 		= [SELECT Id FROM Account LIMIT 1].id;
		opp.StageName 		= 'Closed Won';
		opp.Amount 			= 1200;
		opp.Invoice_Schedule__c = 'Three stage invoice';
		opp.QuickbooksClassId__c = 'testId';
		opp.Event_Start__c 	= Date.today();
		opp.Event_End__c 	= Date.today().addDays(1);
		insert opp;

		// retrieve the job number from the inserted Opportunity
		String extendedJobNumber = String.valueOf([SELECT Filtered_Job_Number__c FROM Opportunity].Filtered_Job_Number__c);
		String jobNumber = extendedJobNumber.substring(0,5);

		opp.Clive_job_number__c = Decimal.valueOf(jobNumber);
		update opp;

		System.debug('the job number of the opp created in the test is ' + jobNumber);

		// create expense records
		List<Expense__c> expenses = new List<Expense__c>();

		// expense record with value to be updated
		Expense__c ex1 		= new Expense__c();
		ex1.Opportunity__c 	= opp.Id;
		ex1.Amount__c 		= -10;
		ex1.Paid__c 		= true;
		ex1.Name 			= '19036-8';
		ex1.QuickbooksId__c	= '19036';
		ex1.Due_Date__c		= Date.today();
		expenses.add(ex1);

		// expense record which has been dereferenced
		Expense__c ex2 		= new Expense__c();
		ex2.Opportunity__c 	= opp.Id;
		ex2.Amount__c 		= -20;
		ex2.Name 			= '19036-10';
		ex2.QuickbooksId__c	= '19036';
		ex2.Due_Date__c		= Date.today();
		expenses.add(ex2);

		// expense record which references a deleted line item
		Expense__c ex3 		= new Expense__c();
		ex3.Opportunity__c 	= opp.Id;
		ex3.Amount__c 		= -20;
		ex3.Name 			= '19036-99';
		ex3.QuickbooksId__c	= '19036';
		ex3.Due_Date__c		= Date.today();
		expenses.add(ex3);

		insert expenses;

		// determine range via custom setting
		insert new CDCRange__c(Name = 'QuickbooksCDC', Days__c = 1);

		Test.startTest();
		// Set mock callout class
		Test.setMock(HttpCalloutMock.class, new VendorCreditCDCMock(jobNumber));

		// Call method to test
		QuickbooksChangeDataCapture.getVendorCredits();
		Test.stopTest();

		// verify that only two Expense__c records now exist - two should
		// have been deleted based on the contents of the mock, and one
		// additional expense should have been created
		System.assertEquals(2,[SELECT Id FROM Expense__c].size());

		// verify that the Expense__c record which existed prior to the callout
		// now has updated values
		Expense__c expense1 = [SELECT Id, Amount__c, Paid__c, Due_Date__c
								FROM Expense__c
								WHERE Name = '19036-8'];

		System.assertEquals(-2000,expense1.Amount__c);
		System.assertEquals(true,expense1.Paid__c);
		System.assertEquals(Date.newInstance(2018,05,20),expense1.Due_Date__c);

		// verify that a new Expense__c record has been created with the right values
		Expense__c expense2 = [SELECT Id, Amount__c, Paid__c, Due_Date__c
								FROM Expense__c
								WHERE Name = '19036-22'];

		System.assertEquals(-1000,expense2.Amount__c);
		System.assertEquals(true,expense2.Paid__c);
		System.assertEquals(Date.newInstance(2018,05,20),expense2.Due_Date__c);

	}


}