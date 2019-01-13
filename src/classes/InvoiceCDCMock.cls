@isTest
global class InvoiceCDCMock implements HttpCalloutMock {
    
	private String autoNumber;

    global HTTPResponse respond(HTTPRequest req) {
        
        // mock response 
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{'+
		'  "CDCResponse": ['+
		'    {'+
		'      "QueryResponse": ['+
		'        {'+
		'          "Invoice": ['+
		'            {'+
		'              "Deposit": 0,'+
		'              "AllowIPNPayment": false,'+
		'              "AllowOnlinePayment": false,'+
		'              "AllowOnlineCreditCardPayment": false,'+
		'              "AllowOnlineACHPayment": false,'+
		'              "domain": "QBO",'+
		'              "sparse": false,'+
		'              "Id": "3033",'+
		'              "SyncToken": "3",'+
		'              "Unpredicted field": "Unpredicted value",'+			
		'              "MetaData": {'+
		'                "CreateTime": "2018-01-26T08:30:20-08:00",'+
		'                "LastUpdatedTime": "2018-02-27T07:32:34-08:00"'+
		'              },'+
		'              "CustomField": ['+
		'                {'+
		'                  "DefinitionId": "1",'+
		'                  "Name": "Schedule Number",'+
		'                  "Type": "StringType",'+
		'                  "StringValue": "' + autoNumber + '"' +
		'                }'+
		'              ],'+
		'              "DocNumber": "16080",'+
		'              "TxnDate": "2017-03-01",'+
		'              "CurrencyRef": {'+
		'                "value": "GBP",'+
		'                "name": "British Pound Sterling"'+
		'              },'+
		'              "PrivateNote": "Payment for event services",'+
		'              "LinkedTxn": ['+
		'                {'+
		'                  "TxnId": "15890",'+
		'                  "TxnType": "Payment"'+
		'                }'+
		'              ],'+
		'              "Line": ['+
		'                {'+
		'                  "Id": "1",'+
		'                  "LineNum": 1,'+
		'                  "Description": "Payment for event servicesAO: Sheryl Manders & Tracy Collingwood",'+
		'                  "Amount": 5077,'+
		'                  "DetailType": "SalesItemLineDetail",'+
		'                  "SalesItemLineDetail": {'+
		'                    "ItemRef": {'+
		'                      "value": "21",'+
		'                      "name": "Defered income"'+
		'                    },'+
		'                    "UnitPrice": 5077,'+
		'                    "Qty": 1,'+
		'                    "TaxCodeRef": {'+
		'                      "value": "26"'+
		'                    }'+
		'                  }'+
		'                },'+
		'                {'+
		'                  "Amount": 5077,'+
		'                  "DetailType": "SubTotalLineDetail",'+
		'                  "SubTotalLineDetail": {}'+
		'                }'+
		'              ],'+
		'              "TxnTaxDetail": {'+
		'                "TotalTax": 1015.4,'+
		'                "TaxLine": ['+
		'                  {'+
		'                    "Amount": 1015.4,'+
		'                    "DetailType": "TaxLineDetail",'+
		'                    "TaxLineDetail": {'+
		'                      "TaxRateRef": {'+
		'                        "value": "48"'+
		'                      },'+
		'                      "PercentBased": true,'+
		'                      "TaxPercent": 20,'+
		'                      "NetAmountTaxable": 5077'+
		'                    }'+
		'                  }'+
		'                ]'+
		'              },'+
		'              "CustomerRef": {'+
		'                "value": "687",'+
		'                "name": "Highways England"'+
		'              },'+
		'              "CustomerMemo": {'+
		'                "value": "Payment for event services"'+
		'              },'+
		'              "BillAddr": {'+
		'                "Id": "557",'+
		'                "Line1": "Bridge House",'+
		'                "Line2": "Walnut Tree Close",'+
		'                "City": "Guildford",'+
		'                "Country": "United Kingdom",'+
		'                "PostalCode": "GU1 4GA"'+
		'              },'+
		'              "DueDate": "2017-03-31",'+
		'              "GlobalTaxCalculation": "TaxExcluded",'+
		'              "TotalAmt": 6092.4,'+
		'              "PrintStatus": "NeedToPrint",'+
		'              "EmailStatus": "NotSet",'+
		'              "Balance": 0'+
		'            },'+
		'            {'+
		'              "Deposit": 0,'+
		'              "AllowIPNPayment": false,'+
		'              "AllowOnlinePayment": false,'+
		'              "AllowOnlineCreditCardPayment": false,'+
		'              "AllowOnlineACHPayment": false,'+
		'              "domain": "QBO",'+
		'              "sparse": false,'+
		'              "Id": "3034",'+
		'              "SyncToken": "3",'+
		'              "MetaData": {'+
		'                "CreateTime": "2018-01-26T08:30:20-08:00",'+
		'                "LastUpdatedTime": "2018-02-27T07:32:34-08:00"'+
		'              },'+
		'              "CustomField": ['+
		'                {'+
		'                  "DefinitionId": "1",'+
		'                  "Name": "Schedule Number",'+
		'                  "Type": "StringType",'+
		'                  "StringValue": ""' +
		'                }'+
		'              ],'+
		'              "DocNumber": "16080",'+
		'              "TxnDate": "2017-03-01",'+
		'              "CurrencyRef": {'+
		'                "value": "GBP",'+
		'                "name": "British Pound Sterling"'+
		'              },'+
		'              "PrivateNote": "Payment for event services",'+
		'              "LinkedTxn": ['+
		'                {'+
		'                  "TxnId": "15890",'+
		'                  "TxnType": "Payment"'+
		'                }'+
		'              ],'+
		'              "Line": ['+
		'                {'+
		'                  "Id": "1",'+
		'                  "LineNum": 1,'+
		'                  "Description": "Payment for event servicesAO: Sheryl Manders & Tracy Collingwood",'+
		'                  "Amount": 5077,'+
		'                  "DetailType": "SalesItemLineDetail",'+
		'                  "SalesItemLineDetail": {'+
		'                    "ItemRef": {'+
		'                      "value": "21",'+
		'                      "name": "Defered income"'+
		'                    },'+
		'                    "UnitPrice": 5077,'+
		'                    "Qty": 1,'+
		'                    "TaxCodeRef": {'+
		'                      "value": "26"'+
		'                    }'+
		'                  }'+
		'                },'+
		'                {'+
		'                  "Amount": 5077,'+
		'                  "DetailType": "SubTotalLineDetail",'+
		'                  "SubTotalLineDetail": {}'+
		'                }'+
		'              ],'+
		'              "TxnTaxDetail": {'+
		'                "TotalTax": 1015.4,'+
		'                "TaxLine": ['+
		'                  {'+
		'                    "Amount": 1015.4,'+
		'                    "DetailType": "TaxLineDetail",'+
		'                    "TaxLineDetail": {'+
		'                      "TaxRateRef": {'+
		'                        "value": "48"'+
		'                      },'+
		'                      "PercentBased": true,'+
		'                      "TaxPercent": 20,'+
		'                      "NetAmountTaxable": 5077'+
		'                    }'+
		'                  }'+
		'                ]'+
		'              },'+
		'              "CustomerRef": {'+
		'                "value": "687",'+
		'                "name": "Highways England"'+
		'              },'+
		'              "CustomerMemo": {'+
		'                "value": "Payment for event services"'+
		'              },'+
		'              "BillAddr": {'+
		'                "Id": "557",'+
		'                "Line1": "Bridge House",'+
		'                "Line2": "Walnut Tree Close",'+
		'                "City": "Guildford",'+
		'                "Country": "United Kingdom",'+
		'                "PostalCode": "GU1 4GA"'+
		'              },'+
		'              "DueDate": "2017-03-31",'+
		'              "GlobalTaxCalculation": "TaxExcluded",'+
		'              "TotalAmt": 6092.4,'+
		'              "PrintStatus": "NeedToPrint",'+
		'              "EmailStatus": "NotSet",'+
		'              "Balance": 0'+
		'            },'+
		'            {'+
		'              "domain": "QBO",'+
		'              "status": "Deleted",'+
		'              "Id": "18971",'+
		'              "MetaData": {'+
		'                "LastUpdatedTime": "2018-02-27T02:51:59-08:00"'+
		'              }'+
		'            }'+
		'          ],'+
		'          "startPosition": 1,'+
		'          "maxResults": 2,'+
		'          "totalCount": 2'+
		'        }'+
		'      ]'+
		'    }'+
		'  ],'+
		'  "time": "2018-03-01T04:35:06.96-08:00"'+
		'}');
        res.setStatusCode(200);
        return res;
    }

    global InvoiceCDCMock(String autoNumber) {

    	this.autoNumber = autoNumber;

    }

}