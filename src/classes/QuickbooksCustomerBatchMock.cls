@IsTest
global class QuickbooksCustomerBatchMock implements HttpCalloutMock {

	private String accountName1;
	private String accountName2;

    global HttpResponse respond(HttpRequest req) {

        // mock response 
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{'+
		'  "BatchItemResponse": ['+
		'    {'+
		'      "Customer": {'+
		'        "Taxable": false,'+
		'        "Job": false,'+
		'        "BillWithParent": false,'+
		'        "Balance": 0,'+
		'        "BalanceWithJobs": 0,'+
		'        "Unexpected field": "unexpected value",'+ // unexpected field and value		
		'        "CurrencyRef": {'+
		'          "value": "GBP",'+
		'          "name": "British Pound Sterling"'+
		'        },'+
		'        "PreferredDeliveryMethod": "Email",'+
		'        "domain": "QBO",'+
		'        "sparse": false,'+
		'        "Id": "1303",'+
		'        "SyncToken": "0",'+
		'        "MetaData": {'+
		'          "CreateTime": "2018-04-24T09:20:12-07:00",'+
		'          "LastUpdatedTime": "2018-04-24T09:20:12-07:00"'+
		'        },'+
		'        "FullyQualifiedName": "1",'+
		'        "DisplayName": "' + accountName1 + '",'+
		'        "PrintOnCheckName": "1",'+
		'        "Active": true'+
		'      },'+
		'      "bId": "bid2"'+
		'    },'+
		'    {'+
		'      "Customer": {'+
		'        "Taxable": false,'+
		'        "Job": false,'+
		'        "BillWithParent": false,'+
		'        "Balance": 0,'+
		'        "Unexpected field": "unexpected value",'+ // unexpected field and value
		'        "BalanceWithJobs": 0,'+
		'        "CurrencyRef": {'+
		'          "value": "GBP",'+
		'          "name": "British Pound Sterling"'+
		'        },'+
		'        "PreferredDeliveryMethod": "Email",'+
		'        "domain": "QBO",'+
		'        "sparse": false,'+
		'        "Id": "1304",'+
		'        "SyncToken": "0",'+
		'        "MetaData": {'+
		'          "CreateTime": "2018-04-24T09:20:12-07:00",'+
		'          "LastUpdatedTime": "2018-04-24T09:20:12-07:00"'+
		'        },'+
		'        "FullyQualifiedName": "2",'+
		'        "DisplayName": "' + accountName2 + '",'+
		'        "PrintOnCheckName": "2",'+
		'        "Active": true'+
		'      },'+
		'      "bId": "bid2"'+
		'    }'+
		'  ],'+
		'  "time": "2018-04-24T09:20:12.374-07:00"'+
		'}');
        res.setStatusCode(200);
        return res;
    }		

	public QuickbooksCustomerBatchMock(String accountName1, String accountName2) {

		this.accountName1 = accountName1;
		this.accountName2 = accountName2;
		
	}
}