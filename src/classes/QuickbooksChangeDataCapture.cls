public class QuickbooksChangeDataCapture {

	// build the callout content 
	public static HttpRequest buildCallout(String entity) {

    	// determine range via custom setting 	
		CDCRange__c range = CDCRange__c.getInstance('QuickbooksCDC');
		Integer DAYS      = Integer.valueOf(range.Days__c);    	

    	// generate string of date value based on custom setting 
		String dateValue = String.valueOf(Date.today().addDays(-DAYS)).substring(0,10);
		String query = 'cdc?entities=' + entity + '&changedSince=' + dateValue + '&minorversion=4';

		// build callout parameters        
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:QuickBooksOnline/' + query);
        request.setHeader('Accept', 'application/json');
        request.setMethod('GET');
        request.setTimeout(120000);  

        return request;

	}

    public static Map<String,String> getOppClassMap(){

        Map<String,String> oppClassMap = new Map<String,String>();

        for (Opportunity opp : [SELECT QuickbooksClassId__c, Filtered_Job_Number__c
                                FROM Opportunity WHERE StageName = 'Closed Won']){
            oppClassMap.put(opp.QuickbooksClassId__c, opp.Filtered_Job_Number__c);
        }

        return oppClassMap;

    }

	// method makes a call to the change data capture service 
	// offered by the Quickbooks API. the method calls for all 
	// created, updated or deleted Invoice records.
	@future(callout=true)
    public static void getInvoices() {

    	// obtain callout information and call Quickbooks change data capture web service
    	Http http 				= new http(); 
        HttpRequest request 	= buildCallout('invoice');    
        HttpResponse response 	= http.send(request);

        if (response.getStatusCode() == 200) {

        	// parse response
			JSONParserQBOInvoiceCDC parsedResults = JSONParserQBOInvoiceCDC.parse(response.getBody());

        	// declare maps to hold all invoice schedule records returned in callout
        	Map<String,Invoice_Schedule__c> updateSchedules = new Map<String,Invoice_Schedule__c>();
        	Map<String,Invoice_Schedule__c> deleteSchedules = new Map<String,Invoice_Schedule__c>();
        	List<Invoice_Schedule__c> dereferencedSchedules = new List<Invoice_Schedule__c>();
        	
        	// capture schdeule ids of all invoices returned in callout
        	Set<String> updateIds 				= new Set<String>();
        	Set<String> deleteIds 				= new Set<String>();
        	Map<String,String> referencedIds	= new Map<String,String>();

        	System.debug(parsedResults.CDCResponse[0]);

        	// add all schedule ids found in call to set
        	if (parsedResults.CDCResponse.size() > 0 && parsedResults.CDCResponse[0].QueryResponse.size() > 0 
        		&& parsedResults.CDCResponse[0].QueryResponse[0].Invoice != null) {
	            for (JSONParserQBOInvoiceCDC.cls_Invoice inv : parsedResults.CDCResponse[0].QueryResponse[0].Invoice) {	            	
	            	
	            	// Todo: iterating through all custom fields returned, filtering by Name value
	            	// for the one called scheulde number, if it has a string value, add to lists 	
	            	if (inv.CustomField != null) {
	            		referencedIds.put(inv.Id,inv.CustomField[0].StringValue);
	            		updateIds.add(inv.CustomField[0].StringValue);
	            	} else if (inv.status == 'Deleted') {
	            		deleteIds.add(inv.Id);
	            	} 
	            }

	            // query for all invoice schedule records with the Quickbooks record id in the set
	            List<Invoice_Schedule__c> references = [SELECT Id, Invoice_Id__c, QBOInvoiceId__c, Credit_Note__c
								            			FROM Invoice_Schedule__c
								            			WHERE QBOInvoiceId__c IN:referencedIds.keySet()];

				// for each record in the references list, check that the Schedule_id__c on the corresponding 
				// quickbooks record matches that on the Invoice_Schedule__c
				for (Invoice_Schedule__c is : references) {
					if (referencedIds.get(is.QBOInvoiceId__c) != is.Invoice_Id__c) {
		            	is.QBOInvoiceLastUpdate__c 	= null;
		            	is.Invoice_Number__c		= null;
		            	is.QBOInvoiceId__c			= null;
		            	is.Invoice_Amount__c		= 0;
		            	is.Invoice_Sent__c			= false;
		            	is.Invoice_Paid__c 			= false;
		            	dereferencedSchedules.add(is); 						
					}
				}

				if (dereferencedSchedules.size() > 0) {
					update dereferencedSchedules;
				} 			            						            				                

	            // query for all invoice schedules with Schedule_id__c in set
	            List<Invoice_Schedule__c> updateRecords = [SELECT Id, Opportunity__r.Calder_Opportunity__c, 
	            											 Invoice_Amount__c, Credit_Note__c, QBOInvoiceLastUpdate__c,
	            											 Amount__c, Invoice_Id__c, Invoice_Number__c													 
								            			FROM Invoice_Schedule__c 
								            			WHERE Invoice_Id__c IN:updateIds];

				// add salesforce invoice schedules to maps  
				for (Invoice_Schedule__c inv : updateRecords) {
					updateSchedules.put(inv.Invoice_Id__c, inv);
				}

				// query for all invoice schedules with id in set of deleted records
	            List<Invoice_Schedule__c> deleteRecords = [SELECT Id, Amount__c, QBOInvoiceId__c, Credit_Note__c
								            			FROM Invoice_Schedule__c 
								            			WHERE QBOInvoiceId__c IN:deleteIds
														AND Invoice_Id__c NOT IN:updateIds];

				// add salesforce invoice schedules to maps 
				for (Invoice_Schedule__c inv : deleteRecords) {
					deleteSchedules.put(inv.QBOInvoiceId__c, inv);				            			             
				}	

				// for each returned quickbooks invoice, update the corresponding salesforce invoice schedule
	            for (JSONParserQBOInvoiceCDC.cls_Invoice inv : parsedResults.CDCResponse[0].QueryResponse[0].Invoice) {

	            	// check whether the record is an update or a deleted record
	            	if (inv.status == 'Deleted') {
	            		if (deleteSchedules.containsKey(inv.Id)) {
	            			// reset the values on the salesforce record if the quickbooks entity has been deleted 
			            	Invoice_Schedule__c is 		= deleteSchedules.get(inv.Id);
			            	is.QBOInvoiceLastUpdate__c 	= null;
			            	is.Invoice_Number__c		= null;
			            	is.QBOInvoiceId__c			= null;
			            	is.Invoice_Sent__c			= false;
			            	is.Invoice_Paid__c 			= false; 
	            		} else {
	            			// record not found logic to go here 
	            		}
	            	} else if (updateSchedules.containsKey(inv.CustomField[0].StringValue)){
		            	// check to see if the salesforce record has already been updated and
		            	// remove from the map if so, otherwise apply updates
		            	if (inv.MetaData.LastUpdatedTime == updateSchedules.get(inv.CustomField[0].StringValue).QBOInvoiceLastUpdate__c) {
		            		updateSchedules.remove(inv.CustomField[0].StringValue);
		            	} else {

		            		// populate invoice schedule fields with updates	
			            	Invoice_Schedule__c is 		= updateSchedules.get(inv.CustomField[0].StringValue);
			            	is.QBOInvoiceLastUpdate__c 	= inv.MetaData.LastUpdatedTime;
			            	is.Invoice_Number__c		= inv.DocNumber;
			            	is.QBOInvoiceId__c			= inv.Id;
			            	is.Invoice_Amount__c		= inv.TxnTaxDetail.TaxLine[0].TaxLineDetail.NetAmountTaxable;
							if (is.Credit_Note__c != null){
								is.Amount__c 			= is.Invoice_Amount__c - is.Credit_Note__c;
							} else {
								is.Amount__c 			= is.Invoice_Amount__c;
							}
			            	is.Send_Date__c				= Date.valueOf(inv.MetaData.CreateTime);
			            	is.Payment_Date__c 			= Date.valueOf(inv.DueDate);
			            	is.Invoice_Sent__c			= true;
			            	if (inv.Balance == 0) is.Invoice_Paid__c = true;
		            	} 
		            } 
	            }

	            if (updateSchedules.size() > 0) {

					for (Invoice_Schedule__c is : updateSchedules.values()){
						system.debug('update list: ' + is);
					}

	            	update updateSchedules.values();
	            } 
	            if (deleteSchedules.size() > 0) {
					for (Invoice_Schedule__c is : deleteSchedules.values()){
						system.debug('delete list: ' + is);
					}



					update deleteSchedules.values();
	        	}
	        }
    	}
    }


	// method makes a call to the change data capture service 
	// offered by the Quickbooks API. the method calls for all 
	// created, updated or deleted Credit Memo records.
	@future(callout=true)
    public static void getCreditMemos() {

    	// obtain callout information and call Quickbooks change data capture web service
    	Http http 				= new http(); 
        HttpRequest request 	= buildCallout('creditmemo');    
        HttpResponse response 	= http.send(request); 

        if (response.getStatusCode() == 200) {

        	// parse response
			JSONParserQBOCreditMemoCDC parsedResults = JSONParserQBOCreditMemoCDC.parse(response.getBody());

        	// declare maps to hold all invoice schedule records returned in callout
        	Map<String,Invoice_Schedule__c> updateSchedules = new Map<String,Invoice_Schedule__c>();
        	Map<String,Invoice_Schedule__c> deleteSchedules = new Map<String,Invoice_Schedule__c>();
        	List<Invoice_Schedule__c> dereferencedSchedules = new List<Invoice_Schedule__c>();
        	
        	// capture schdeule ids of all invoices returned in callout
        	Set<String> updateIds 				= new Set<String>();
        	Set<String> deleteIds 				= new Set<String>();
        	Map<String,String> referencedIds	= new Map<String,String>();

        	// all all schedule ids found in call to set
        	if (parsedResults.CDCResponse.size() > 0 && parsedResults.CDCResponse[0].QueryResponse.size() > 0 
        		&& parsedResults.CDCResponse[0].QueryResponse[0].CreditMemo != null) {	
        	    for (JSONParserQBOCreditMemoCDC.cls_CreditMemo cm : parsedResults.CDCResponse[0].QueryResponse[0].CreditMemo) {
	            	if (cm.CustomField != null) {
	            		referencedIds.put(cm.Id,cm.CustomField[0].StringValue);
	            		updateIds.add(cm.CustomField[0].StringValue);
	            	} else if (cm.status == 'Deleted') {
	            		deleteIds.add(cm.Id);
	            	}
	            }

	            // query for all invoice schedule records with the Quickbooks record id in the set
	            List<Invoice_Schedule__c> references = [SELECT Id, Invoice_Id__c, QBOCreditNoteId__c, Invoice_Amount__c
								            			FROM Invoice_Schedule__c 
								            			WHERE QBOCreditNoteId__c IN:referencedIds.keySet()];

				System.debug(references.size());				            			

				// for each record in the references list, check that the Schedule_id__c on the corresponding 
				// quickbooks record matches that on the Invoice_Schedule__c
				for (Invoice_Schedule__c is : references) {
					if (referencedIds.get(is.QBOCreditNoteId__c) != is.Invoice_Id__c) {
			            	is.QBOCreditMemoLastUpdate__c 	= null;
			            	is.Credit_Note_Number__c		= null;
			            	is.QBOCreditNoteId__c			= null;
			            	is.Credit_Note__c				= 0;
							if (is.Invoice_Amount__c != 0){
								is.Amount__c 	= is.Invoice_Amount__c - is.Credit_Note__c;
							}
						dereferencedSchedules.add(is);
					}
				}

				if (dereferencedSchedules.size() > 0) {
					update dereferencedSchedules;			            	           
				}	

	            // query for all invoice schedules with id in set of updated records
	            List<Invoice_Schedule__c> updateRecords = [SELECT Id, Invoice_Id__c, QBOCreditMemoLastUpdate__c,
																	Invoice_Amount__c, Amount__c, Invoice_Number__c
								            			FROM Invoice_Schedule__c 
								            			WHERE Invoice_Id__c IN:updateIds];

				// add salesforce invoice schedules to maps  
				for (Invoice_Schedule__c inv : updateRecords) {
					updateSchedules.put(inv.Invoice_Id__c, inv);
				}

				// query for all invoice schedules with id in set of deleted records
	            List<Invoice_Schedule__c> deleteRecords = [SELECT Id, QBOCreditNoteId__c, Invoice_Amount__c
								            			FROM Invoice_Schedule__c 
								            			WHERE QBOCreditNoteId__c IN:deleteIds
														AND Invoice_Id__c NOT IN:updateIds];

				// add salesforce invoice schedules to maps 
				for (Invoice_Schedule__c inv : deleteRecords) {
					deleteSchedules.put(inv.QBOCreditNoteId__c, inv);				            			             
				}	

				// for each returned quickbooks invoice, update the corresponding salesforce invoice schedule
	            for (JSONParserQBOCreditMemoCDC.cls_CreditMemo cm : parsedResults.CDCResponse[0].QueryResponse[0].CreditMemo) {

	            	// check whether the record is an update or a deleted record
	            	if (cm.status == 'Deleted') {
	            		if (deleteSchedules.containsKey(cm.Id)) {
			            	Invoice_Schedule__c is 			= deleteSchedules.get(cm.Id);
			            	is.QBOCreditMemoLastUpdate__c 	= null;
			            	is.Credit_Note_Number__c		= null;
			            	is.QBOCreditNoteId__c			= null;
			            	is.Credit_Note__c				= 0;
							if (is.Invoice_Amount__c != 0){
								is.Amount__c 	= is.Invoice_Amount__c - is.Credit_Note__c;
							}
						} else {
	            			// record not found logic to go here 
	            		}
	            	} else if (updateSchedules.containsKey(cm.CustomField[0].StringValue)){
		            	// check to see if the salesforce record has already been updated and
		            	// remove from the map if so, otherwise apply updates
		            	if (cm.MetaData.LastUpdatedTime == updateSchedules.get(cm.CustomField[0].StringValue).QBOCreditMemoLastUpdate__c) {
		            		updateSchedules.remove(cm.CustomField[0].StringValue);
		            	} else {
		            		// populate invoice schedule fields with updates	
			            	Invoice_Schedule__c is 			= updateSchedules.get(cm.CustomField[0].StringValue);
			            	is.QBOCreditMemoLastUpdate__c 	= cm.MetaData.LastUpdatedTime;
			            	is.Credit_Note_Number__c		= cm.DocNumber;
			            	is.QBOCreditNoteId__c			= cm.Id;
			            	is.Credit_Note__c				= cm.TxnTaxDetail.TaxLine[0].TaxLineDetail.NetAmountTaxable;
							if (is.Invoice_Amount__c != 0 && is.Invoice_Number__c != null){
								is.Amount__c 	= is.Invoice_Amount__c - is.Credit_Note__c;
							} else {
								is.Amount__c 	= (is.Credit_Note__c * -1);
								is.Invoice_Sent__c = true;
								is.Invoice_Paid__c = true;
							}
						}
		            } 	
	            }

	            if (updateSchedules.size() > 0) {
	            	update updateSchedules.values();
	            }
	            if (deleteSchedules.size() > 0) {
	            	update deleteSchedules.values();	        
	        	}
	        }
        }
    }


	// method makes a call to the change data capture service 
	// offered by the Quickbooks API. the method calls for all 
	// created, updated or deleted Bill records.
	@future(callout=true)
    public static void getBills() {

    	// obtain callout information and call Quickbooks change data capture web service
    	Http http 				= new http(); 
        HttpRequest request 	= buildCallout('bill');    
        HttpResponse response 	= http.send(request);

        if (response.getStatusCode() == 200) {

        	// parse response
			JSONParserQBOBillCDC parsedResults = JSONParserQBOBillCDC.parse(response.getBody());

        	// STEP 1: TARGET COLLECTIONS  
        	// declare target Expense__c record lists 
        	List<Expense__c> deleteExpenses			= new List<Expense__c>();
        	List<Expense__c> upsertExpenses 		= new List<Expense__c>();

        	// STEP 2: SOURCE COLLECTIONS  
        	// declare Quickbooks Bill record collections and maps which relate these to 
        	// Salesforce records  
        	Set<String> deletedBillIds 			 	= new Set<String>();
        	Set<String> activeBillIds			 	= new Set<String>();
        	Set<String> activeLineItemIds 		 	= new Set<String>();
        	Set<String> jobNumbers				 	= new Set<String>();
        	Map<String,Expense__c> existingExpenses = new Map<String,Expense__c>();
        	Map<String,Id> jobNumberOppMap			= new Map<String,Id>();

            Map<String,String> oppClassMap          = getOppClassMap();

        	// STEP 3: SOURCE ALLOCATION 
        	// assign Quickbooks Bill records to the relevant source collections  
        	if (parsedResults.CDCResponse.size() > 0 && parsedResults.CDCResponse[0].QueryResponse.size() > 0 
        		&& parsedResults.CDCResponse[0].QueryResponse[0].Bill != null) {
	            for (JSONParserQBOBillCDC.cls_Bill bill : parsedResults.CDCResponse[0].QueryResponse[0].Bill) {
	            	// 1. bill has been deleted 
	            	if (bill.Status == 'Deleted') {
	            		deletedBillIds.add(bill.Id);
	            	} else {
	            		// 2. bill is still active
	            		activeBillIds.add(bill.Id);
	            		// 3. bill is associated with an Opportunity 
	            		for (JSONParserQBOBillCDC.cls_Line line : bill.Line) {

                            if (line.AccountBasedExpenseLineDetail.ClassRef != null){
                                jobNumbers.add(oppClassMap.get(line.AccountBasedExpenseLineDetail.ClassRef.value));
                                String itemId = bill.Id + '-' + line.Id;
                                activeLineItemIds.add(itemId);
                                // todo: section below needs to be removed
                            } else if (line.AccountBasedExpenseLineDetail != null
                                    && line.AccountBasedExpenseLineDetail.CustomerRef != null
                                    && line.AccountBasedExpenseLineDetail.CustomerRef.name != null
                                    && line.AccountBasedExpenseLineDetail.CustomerRef.name.contains(':')) {

                                String extendedName 	= line.AccountBasedExpenseLineDetail.CustomerRef.name.substring(line.AccountBasedExpenseLineDetail.CustomerRef.name.lastIndexOf(':') + 1);
                                String jobNumber 		= extendedName.substring(0,5);
                                jobNumbers.add(jobNumber);
                                String itemId = bill.Id + '-' + line.Id;
                                activeLineItemIds.add(itemId);
                            }
	            		}
	            	}
	            } 
	        }

        	// STEP 4: TARGET ALLOCATION 
        	// populate the target Expense__c record lists  

        	// delete Expense__c records where either the whole bill 
        	// has been deleted, the line item has been deleted or the 
        	// project has been dereferenced on the line item
	        deleteExpenses = [SELECT Id													 
	            			 FROM Expense__c 
	            			 WHERE QuickbooksId__c IN:deletedBillIds
	            			 OR (QuickbooksId__c IN:activeBillIds
	            			 AND Name NOT IN: activeLineItemIds)];	

	        List<Expense__c> expensesToUpdate = [SELECT Id, Name, Quickbooks_Last_Update__c 													 
						            			 FROM Expense__c 
						            			 WHERE Name IN:activeLineItemIds];

			for (Expense__c ex : expensesToUpdate){
				existingExpenses.put(ex.Name, ex);
			}

			List<Opportunity> oppsInReference = [SELECT Id, Filtered_Job_Number__c, QuickbooksClassId__c
												 FROM Opportunity
												 WHERE Filtered_Job_Number__c IN :jobNumbers
												 FOR UPDATE];

			for (Opportunity opp : oppsInReference){
				jobNumberOppMap.put(opp.Filtered_Job_Number__c, opp.Id);
				jobNumberOppMap.put(opp.QuickbooksClassId__c, opp.Id);
			}
		
			if (parsedResults.CDCResponse[0].QueryResponse[0].Bill != null){

				// for each returned quickbooks invoice, update the corresponding salesforce invoice schedule
	            for (JSONParserQBOBillCDC.cls_Bill bill : parsedResults.CDCResponse[0].QueryResponse[0].Bill) {

	            	if (bill.Line != null && bill.Line.size() > 0 ) {

	            		for (JSONParserQBOBillCDC.cls_Line line : bill.Line) {

//	            			if (li.AccountBasedExpenseLineDetail != null
//	            				&& li.AccountBasedExpenseLineDetail.CustomerRef != null
//	            				&& li.AccountBasedExpenseLineDetail.CustomerRef.name != null
//	            				&& li.AccountBasedExpenseLineDetail.CustomerRef.name.contains(':')) {
//
//								String extendedName 	= li.AccountBasedExpenseLineDetail.CustomerRef.name.substring(li.AccountBasedExpenseLineDetail.CustomerRef.name.lastIndexOf(':') + 1);
//	            				String jobNumber 		= extendedName.substring(0,5);

                            if (line.AccountBasedExpenseLineDetail.ClassRef != null){
	            				if (jobNumberOppMap.containsKey(oppClassMap.get(line.AccountBasedExpenseLineDetail.ClassRef.value))){

                                    Id oppId                = jobNumberOppMap.get(oppClassMap.get(line.AccountBasedExpenseLineDetail.ClassRef.value));
		            				String lineItemId 		= bill.Id + '-' + line.Id;

			            			if (existingExpenses.containsKey(lineItemId)){
			            				if (existingExpenses.get(lineItemId).Quickbooks_Last_Update__c
		            					    != bill.MetaData.LastUpdatedTime){
					            			Expense__c ex 			 = new Expense__c();
					            			ex.Id = existingExpenses.get(lineItemId).Id;					            			
					            			ex.QuickbooksId__c		 = bill.Id;
					            			ex.Name 				 = lineItemId;
					            			ex.Amount__c 			 = line.Amount;
					            			ex.Paid__c 				 = (bill.Balance == 0) ? true : false;
					            			ex.Due_Date__c 			 = Date.valueOf(bill.DueDate);
											ex.Description__c		 = line.Description;
											ex.Opportunity__c 		 = oppId;
											ex.Supplier__c 			 = bill.VendorRef.Name;
											ex.Supplier_Ref__c 		 = bill.DocNumber;
											ex.Quickbooks_Last_Update__c = bill.MetaData.LastUpdatedTime; 
											upsertExpenses.add(ex);
			            				}
			            			} else {
				            			Expense__c ex 			 = new Expense__c();
				            			ex.QuickbooksId__c		 = bill.Id;
				            			ex.Name 				 = lineItemId;
				            			ex.Amount__c 			 = line.Amount;
				            			ex.Paid__c 				 = (bill.Balance == 0) ? true : false;
				            			ex.Due_Date__c 			 = Date.valueOf(bill.DueDate);
										ex.Description__c		 = line.Description;
										ex.Opportunity__c 		 = oppId;
										ex.Supplier__c 			 = bill.VendorRef.Name;
										ex.Supplier_Ref__c 		 = bill.DocNumber;
										ex.Quickbooks_Last_Update__c = bill.MetaData.LastUpdatedTime; 
										upsertExpenses.add(ex);
			            			}
	            				}
	            			}
	            		}
	            	}
	            }
	        }    

    		// STEP 5: DML            
            if (deleteExpenses.size() > 0) {
            	delete deleteExpenses;
	        } 
            if (upsertExpenses.size() > 0) {
            	upsert upsertExpenses;
            }  
        }
	}


	// method makes a call to the change data capture service
	// offered by the Quickbooks API. the method calls for all
	// created, updated or deleted Bill records.
	@future(callout=true)
	public static void getVendorCredits() {

		// obtain callout information and call Quickbooks change data capture web service
		Http http 				= new http();
		HttpRequest request 	= buildCallout('vendorCredit');
		HttpResponse response 	= http.send(request);

		if (response.getStatusCode() == 200) {

			// parse response
			JSONParserQBVendorCreditCDC parsedResults = JSONParserQBVendorCreditCDC.parse(response.getBody());

			// STEP 1: TARGET COLLECTIONS
			// declare target Expense__c record lists
			List<Expense__c> deleteExpenses			= new List<Expense__c>();
			List<Expense__c> upsertExpenses 		= new List<Expense__c>();

			// STEP 2: SOURCE COLLECTIONS
			// declare Quickbooks Bill record collections and maps which relate these to
			// Salesforce records
			Set<String> deletedBillIds 			 	= new Set<String>();
			Set<String> activeBillIds			 	= new Set<String>();
			Set<String> activeLineItemIds 		 	= new Set<String>();
			Set<String> jobNumbers				 	= new Set<String>();
			Map<String,Expense__c> existingExpenses = new Map<String,Expense__c>();
			Map<String,Id> jobNumberOppMap			= new Map<String,Id>();

			Map<String,String> oppClassMap          = getOppClassMap();

			// STEP 3: SOURCE ALLOCATION
			// assign Quickbooks Bill records to the relevant source collections
			if (parsedResults.CDCResponse.size() > 0 && parsedResults.CDCResponse[0].QueryResponse.size() > 0
					&& parsedResults.CDCResponse[0].QueryResponse[0].VendorCredit != null) {
				for (JSONParserQBVendorCreditCDC.cls_VendorCredit vendorCredit : parsedResults.CDCResponse[0].QueryResponse[0].VendorCredit) {
					// 1. bill has been deleted
					if (vendorCredit.Status == 'Deleted') {
						deletedBillIds.add(vendorCredit.Id);
					} else {
						// 2. bill is still active
						activeBillIds.add(vendorCredit.Id);
						// 3. bill is associated with an Opportunity
						for (JSONParserQBVendorCreditCDC.cls_Line line : vendorCredit.Line) {

							if (line.AccountBasedExpenseLineDetail.ClassRef != null){
								jobNumbers.add(oppClassMap.get(line.AccountBasedExpenseLineDetail.ClassRef.value));
								String itemId = vendorCredit.Id + '-' + line.Id;
								activeLineItemIds.add(itemId);
								// todo: section below needs to be removed
							} else if (line.AccountBasedExpenseLineDetail != null
									&& line.AccountBasedExpenseLineDetail.CustomerRef != null
									&& line.AccountBasedExpenseLineDetail.CustomerRef.name != null
									&& line.AccountBasedExpenseLineDetail.CustomerRef.name.contains(':')) {

								String extendedName 	= line.AccountBasedExpenseLineDetail.CustomerRef.name.substring(line.AccountBasedExpenseLineDetail.CustomerRef.name.lastIndexOf(':') + 1);
								String jobNumber 		= extendedName.substring(0,5);
								jobNumbers.add(jobNumber);
								String itemId = vendorCredit.Id + '-' + line.Id;
								activeLineItemIds.add(itemId);
							}
						}
					}
				}
			}

			// STEP 4: TARGET ALLOCATION
			// populate the target Expense__c record lists

			// delete Expense__c records where either the whole bill
			// has been deleted, the line item has been deleted or the
			// project has been dereferenced on the line item
			deleteExpenses = [SELECT Id
								FROM Expense__c
								WHERE QuickbooksId__c IN:deletedBillIds
								OR (QuickbooksId__c IN:activeBillIds
								AND Name NOT IN: activeLineItemIds)];

			List<Expense__c> expensesToUpdate = [SELECT Id, Name, Quickbooks_Last_Update__c
												FROM Expense__c
												WHERE Name IN:activeLineItemIds];

			for (Expense__c ex : expensesToUpdate){
				existingExpenses.put(ex.Name, ex);
			}

			List<Opportunity> oppsInReference = [SELECT Id, Filtered_Job_Number__c, QuickbooksClassId__c
												FROM Opportunity
												WHERE Filtered_Job_Number__c IN :jobNumbers
												FOR UPDATE];

			for (Opportunity opp : oppsInReference){
				jobNumberOppMap.put(opp.Filtered_Job_Number__c, opp.Id);
				jobNumberOppMap.put(opp.QuickbooksClassId__c, opp.Id);
			}

			if (parsedResults.CDCResponse[0].QueryResponse[0].VendorCredit != null){

				// for each returned quickbooks invoice, update the corresponding salesforce invoice schedule
				for (JSONParserQBVendorCreditCDC.cls_VendorCredit vendorCredit : parsedResults.CDCResponse[0].QueryResponse[0].VendorCredit) {

					if (vendorCredit.Line != null && vendorCredit.Line.size() > 0 ) {

						for (JSONParserQBVendorCreditCDC.cls_Line line : vendorCredit.Line) {

							if (line.AccountBasedExpenseLineDetail.ClassRef != null){
								if (jobNumberOppMap.containsKey(oppClassMap.get(line.AccountBasedExpenseLineDetail.ClassRef.value))){

									Id oppId                = jobNumberOppMap.get(oppClassMap.get(line.AccountBasedExpenseLineDetail.ClassRef.value));
									String lineItemId 		= vendorCredit.Id + '-' + line.Id;

									if (existingExpenses.containsKey(lineItemId)){
										if (existingExpenses.get(lineItemId).Quickbooks_Last_Update__c
												!= vendorCredit.MetaData.LastUpdatedTime){
											Expense__c ex 			 = new Expense__c();
											ex.Id = existingExpenses.get(lineItemId).Id;
											ex.QuickbooksId__c		 = vendorCredit.Id;
											ex.Name 				 = lineItemId;
											ex.Amount__c 			 = (line.Amount * -1);
											ex.Paid__c 				 = true;
											ex.Due_Date__c 			 = Date.valueOf(vendorCredit.TxnDate);
											ex.Description__c		 = 'Credit note: ' + line.Description;
											ex.Opportunity__c 		 = oppId;
											ex.Supplier__c 			 = vendorCredit.VendorRef.Name;
											ex.Supplier_Ref__c 		 = vendorCredit.DocNumber;
											ex.Quickbooks_Last_Update__c = vendorCredit.MetaData.LastUpdatedTime;
											upsertExpenses.add(ex);
										}
									} else {
										Expense__c ex 			 = new Expense__c();
										ex.QuickbooksId__c		 = vendorCredit.Id;
										ex.Name 				 = lineItemId;
										ex.Amount__c 			 = (line.Amount * -1);
										ex.Paid__c 				 = true;
										ex.Due_Date__c 			 = Date.valueOf(vendorCredit.TxnDate);
										ex.Description__c		 = 'Credit note: ' + line.Description;
										ex.Opportunity__c 		 = oppId;
										ex.Supplier__c 			 = vendorCredit.VendorRef.Name;
										ex.Supplier_Ref__c 		 = vendorCredit.DocNumber;
										ex.Quickbooks_Last_Update__c = vendorCredit.MetaData.LastUpdatedTime;
										upsertExpenses.add(ex);
									}
								}
							}
						}
					}
				}
			}

			// STEP 5: DML
			if (deleteExpenses.size() > 0) {
				delete deleteExpenses;
			}
			if (upsertExpenses.size() > 0) {
				upsert upsertExpenses;
			}
		}
	}

}