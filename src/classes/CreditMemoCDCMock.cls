@isTest
global class CreditMemoCDCMock implements HttpCalloutMock {
    
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
		'          "CreditMemo": ['+
		'            {'+
		'              "RemainingCredit": 90.0,'+
		'              "domain": "QBO",'+
		'              "sparse": false,'+
		'              "Unpredicted field": "Unpredicted value",'+			
		'              "Id": "18974",'+
		'              "SyncToken": "1",'+
		'              "MetaData": {'+
		'                "CreateTime": "2018-03-01T02:26:54-08:00",'+
		'                "LastUpdatedTime": "2018-03-01T02:28:18-08:00"'+
		'              },'+
		'              "CustomField": ['+
		'                {'+
		'                  "DefinitionId": "1",'+
		'                  "Name": "Schedule Number",'+
		'                  "Type": "StringType",'+
		'                  "StringValue": "' + autoNumber + '"' +
		'                }'+
		'              ],'+
		'              "DocNumber": "1019",'+
		'              "TxnDate": "2018-03-01",'+
		'              "CurrencyRef": {'+
		'                "value": "GBP",'+
		'                "name": "British Pound Sterling"'+
		'              },'+
		'              "Line": ['+
		'                {'+
		'                  "Id": "1",'+
		'                  "LineNum": 1,'+
		'                  "Description": "This",'+
		'                  "Amount": 90.0,'+
		'                  "DetailType": "SalesItemLineDetail",'+
		'                  "SalesItemLineDetail": {'+
		'                    "ServiceDate": "2018-03-01",'+
		'                    "ItemRef": {'+
		'                      "value": "18",'+
		'                      "name": "_EXISTING_Services"'+
		'                    },'+
		'                    "TaxCodeRef": {'+
		'                      "value": "35"'+
		'                    }'+
		'                  }'+
		'                },'+
		'                {'+
		'                  "Amount": 90.0,'+
		'                  "DetailType": "SubTotalLineDetail",'+
		'                  "SubTotalLineDetail": {}'+
		'                }'+
		'              ],'+
		'              "TxnTaxDetail": {'+
		'                "TotalTax": 0,'+
		'                "TaxLine": ['+
		'                  {'+
		'                    "Amount": 0,'+
		'                    "DetailType": "TaxLineDetail",'+
		'                    "TaxLineDetail": {'+
		'                      "TaxRateRef": {'+
		'                        "value": "66"'+
		'                      },'+
		'                      "PercentBased": true,'+
		'                      "TaxPercent": 0,'+
		'                      "NetAmountTaxable": 90.0'+
		'                    }'+
		'                  }'+
		'                ]'+
		'              },'+
		'              "CustomerRef": {'+
		'                "value": "687",'+
		'                "name": "Highways England"'+
		'              },'+
		'              "BillAddr": {'+
		'                "Id": "557",'+
		'                "Line1": "Bridge House",'+
		'                "Line2": "Walnut Tree Close",'+
		'                "City": "Guildford",'+
		'                "Country": "United Kingdom",'+
		'                "PostalCode": "GU1 4GA"'+
		'              },'+
		'              "GlobalTaxCalculation": "TaxExcluded",'+
		'              "TotalAmt": 90.0,'+
		'              "PrintStatus": "NotSet",'+
		'              "EmailStatus": "NotSet",'+
		'              "BillEmail": {'+
		'                "Address": "INVOICES@highwaysengland.co.uk"'+
		'              },'+
		'              "Balance": 90.0'+
		'            },'+
		'            {'+
		'              "RemainingCredit": 90.0,'+
		'              "domain": "QBO",'+
		'              "sparse": false,'+
		'              "Id": "18975",'+
		'              "SyncToken": "1",'+
		'              "MetaData": {'+
		'                "CreateTime": "2018-03-01T02:26:54-08:00",'+
		'                "LastUpdatedTime": "2018-03-01T02:28:18-08:00"'+
		'              },'+
		'              "CustomField": ['+
		'                {'+
		'                  "DefinitionId": "1",'+
		'                  "Name": "Schedule Number",'+
		'                  "Type": "StringType",'+
		'                  "StringValue": ""' +
		'                }'+
		'              ],'+
		'              "DocNumber": "1019",'+
		'              "TxnDate": "2018-03-01",'+
		'              "CurrencyRef": {'+
		'                "value": "GBP",'+
		'                "name": "British Pound Sterling"'+
		'              },'+
		'              "Line": ['+
		'                {'+
		'                  "Id": "1",'+
		'                  "LineNum": 1,'+
		'                  "Description": "This",'+
		'                  "Amount": 90.0,'+
		'                  "DetailType": "SalesItemLineDetail",'+
		'                  "SalesItemLineDetail": {'+
		'                    "ServiceDate": "2018-03-01",'+
		'                    "ItemRef": {'+
		'                      "value": "18",'+
		'                      "name": "_EXISTING_Services"'+
		'                    },'+
		'                    "TaxCodeRef": {'+
		'                      "value": "35"'+
		'                    }'+
		'                  }'+
		'                },'+
		'                {'+
		'                  "Amount": 90.0,'+
		'                  "DetailType": "SubTotalLineDetail",'+
		'                  "SubTotalLineDetail": {}'+
		'                }'+
		'              ],'+
		'              "TxnTaxDetail": {'+
		'                "TotalTax": 0,'+
		'                "TaxLine": ['+
		'                  {'+
		'                    "Amount": 0,'+
		'                    "DetailType": "TaxLineDetail",'+
		'                    "TaxLineDetail": {'+
		'                      "TaxRateRef": {'+
		'                        "value": "66"'+
		'                      },'+
		'                      "PercentBased": true,'+
		'                      "TaxPercent": 0,'+
		'                      "NetAmountTaxable": 90.0'+
		'                    }'+
		'                  }'+
		'                ]'+
		'              },'+
		'              "CustomerRef": {'+
		'                "value": "687",'+
		'                "name": "Highways England"'+
		'              },'+
		'              "BillAddr": {'+
		'                "Id": "557",'+
		'                "Line1": "Bridge House",'+
		'                "Line2": "Walnut Tree Close",'+
		'                "City": "Guildford",'+
		'                "Country": "United Kingdom",'+
		'                "PostalCode": "GU1 4GA"'+
		'              },'+
		'              "GlobalTaxCalculation": "TaxExcluded",'+
		'              "TotalAmt": 90.0,'+
		'              "PrintStatus": "NotSet",'+
		'              "EmailStatus": "NotSet",'+
		'              "BillEmail": {'+
		'                "Address": "INVOICES@highwaysengland.co.uk"'+
		'              },'+
		'              "Balance": 90.0'+
		'            },'+
		'            {'+
		'              "domain": "QBO",'+
		'              "status": "Deleted",'+
		'              "Id": "18955",'+
		'              "MetaData": {'+
		'                "LastUpdatedTime": "2018-03-02T02:57:14-08:00"'+
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
		'  "time": "2018-03-02T02:57:21.088-08:00"'+
		'}');
        res.setStatusCode(200);
        return res;
    }

    global CreditMemoCDCMock(String autoNumber) {

    	this.autoNumber = autoNumber;

    }

}