public class QuickbooksCustomerBatch {
	
	private static String processAccounts(List<Account> accs){
	
		String accountString = '';

		for (Integer x = 0; x < accs.size(); x++){

			// check for null fields in order to prevent Quickbooks fields being populated with 'null' string
			String billingStreet 	 = (accs[x].BillingStreet == null) ? '' : accs[x].BillingStreet;
			String billingCity 		 = (accs[x].BillingCity == null) ? '' : accs[x].BillingCity;
			String billingCountry 	 = (accs[x].BillingCountry == null) ? '' : accs[x].BillingCountry;	
			String billingPostalCode = (accs[x].BillingPostalCode == null) ? '' : accs[x].BillingPostalCode;
			String phone 			 = (accs[x].Phone == null) ? '' : accs[x].Phone;	 

			// build json string of account details 
			accountString = accountString + 
			'      {  '+
			'         "bId":"bid' + String.valueof(x + 1) + '",'+
			'         "operation":"create",'+
			'         "Customer":{  '+
			'            "BillAddr":{  '+
			'               "Line1":"' + billingStreet + '",'+
			'               "City":"' + billingCity + '",'+
			'               "Country":"' + billingCountry + '",'+
			'               "PostalCode":"' + billingPostalCode + '"'+
			'            },'+
			'            "FullyQualifiedName":"' + accs[x].Name + '",'+
			'            "CompanyName":"' + accs[x].Name + '",'+
			'            "DisplayName":"' + accs[x].Name + '",'+
			'            "PrimaryPhone":{  '+
			'               "FreeFormNumber":"' + phone + '"'+
			'            },'+
			'            "PrimaryEmailAddr":{  '+
			'               "Address":""'+
			'            }'+
			'         }'+
			'      }';

			// add comma to json string if there are still accounts to add to the string 
			if ((x +1) < accs.size()) {
				accountString = accountString + ',';
			}			
		}    				    

		return accountString;
	}	

	// callout to create a new customers object in Quickbooks
	@Future(Callout=true)
    public static void createCustomers(Set<Id> accIds) {

    	List<Account> accs = [SELECT Id, Name, Phone, BillingStreet, BillingCity, 
    								 BillingCountry, BillingPostalCode		    						 
		    				    FROM Account
		    				    WHERE Id = :accIds];    	

		String accountString = processAccounts(accs);

		// declare batch container json string and insert accounts string 
		String batchString = '{  '+
			'   "BatchItemRequest":[  '+
			accountString +
			'   ]'+
			'}';

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:QuickBooksOnline/batch?minorversion=4');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Accept', 'application/json');
        request.setBody(batchString);
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
        	System.debug('Response: ' + response.getBody());
        	System.debug('Accounts: ' + accs);	
        	updateAccounts(response.getBody(), accs);
        } else {
            System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());

            Integration_Error__c error  = new Integration_Error__c();
            error.Class__c 				= 'QuickbooksCustomerBatch';
            error.sObject__c 			= '';
            error.Action__c 			= 'Attempt to insert new Customers';
            error.Outcome__c			= 'The status code returned was not expected: ' +
            								response.getStatusCode() + ' ' + response.getStatus();
            insert error;						    	        	        
        }
    }	

    private static void updateAccounts(String queryResponse, List<Account> accounts){

    	Map<String,String> nameIdMap 		= new Map<String,String>();
    	List<Account> accountsToUpdate 		= new List<Account>();
    	List<Integration_Error__c> errors 	= new List<Integration_Error__c>();

	    // Parse entire JSON response.
	    JSONParser parser = JSON.createParser(queryResponse);
	    while (parser.nextToken() != null) {

	        // Start at the array of customers
	        if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
	            while (parser.nextToken() != null) {
	                // Advance to the start object marker to
	                // find next customer statement object.
	                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {

	                    // Read entire customer object
	                    cls_BatchItemResponse batchItem = (cls_BatchItemResponse)parser.readValueAs(cls_BatchItemResponse.class);

						if (batchItem.Customer != null && batchItem.Customer.DisplayName != null && batchItem.Customer.Id != null) {
							nameIdMap.put(batchItem.Customer.DisplayName, batchItem.Customer.Id);
						}	                    
	                    
	                    // Skip the child start array and start object markers.
	                    parser.skipChildren();
	                }
	            }
	        }
	    }
    
		for (Account acc : accounts) {
			if (nameIdMap.containsKey(acc.Name)){
				acc.QuickbooksId__c = nameIdMap.get(acc.Name);
				accountsToUpdate.add(acc);
			} else {
	            Integration_Error__c error  = new Integration_Error__c();
	            error.Class__c 				= 'QuickbooksCustomerBatch';
	            error.sObject__c 			= acc.Id;
	            error.Action__c 			= 'Attempt to retrieve Id from Quickbooks';
	            error.Outcome__c			= 'No Id for the record returned';
	            errors.add(error);
			}		
		}

		update accountsToUpdate;
		insert errors;
    }


    // inner classes used to parse the Json response 
	public class cls_BatchItemResponse {
		public cls_Customer Customer;
		public String bId;	//bid1
	}    

	public class cls_Customer {
		public Boolean Taxable;
		public cls_BillAddr BillAddr;
		public Boolean Job;
		public Boolean BillWithParent;
		public Integer Balance;	//0
		public Integer BalanceWithJobs;	//0
		public cls_CurrencyRef CurrencyRef;
		public String PreferredDeliveryMethod;	//Email
		public String domain;	//QBO
		public Boolean sparse;
		public String Id;	//1242
		public String SyncToken;	//0
		public cls_MetaData MetaData;
		public String FullyQualifiedName;	//King's Groceries12
		public String CompanyName;	//King Groceries12
		public String DisplayName;	//King's Groceries12
		public String PrintOnCheckName;	//King Groceries12
		public Boolean Active;
		public cls_PrimaryPhone PrimaryPhone;
		public cls_PrimaryEmailAddr PrimaryEmailAddr;
	}
	public class cls_BillAddr {
		public String Id;	//1011
		public String Line1;	//123 Main Street
		public String City;	//Mountain View
		public String Country;	//USA
		public String CountrySubDivisionCode;	//CA
		public String PostalCode;	//94042
	}
	public class cls_CurrencyRef {
		public String value;	//GBP
		public String name;	//British Pound Sterling
	}
	public class cls_MetaData {
		public String CreateTime;	//2018-04-23T02:59:59-07:00
		public String LastUpdatedTime;	//2018-04-23T02:59:59-07:00
	}
	public class cls_PrimaryPhone {
		public String FreeFormNumber;	//(555) 555-5555
	}
	public class cls_PrimaryEmailAddr {
		public String Address;	//jdrew@myemail.com
	}

}