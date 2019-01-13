@isTest
public class JSONParserQBOBillCDCTest {
	static testMethod void testParse() {
		String json= '{'+
		'  "CDCResponse": ['+
		'    {'+
		'      "QueryResponse": ['+
		'        {'+
		'          "Bill": ['+
		'            {'+
		'              "SalesTermRef": {'+
		'                "value": "6"'+
		'              },'+
		'              "DueDate": "2018-05-20",'+
		'              "Balance": 2450.0,'+
		'              "domain": "QBO",'+
		'              "sparse": false,'+
		'              "Id": "19036",'+
		'              "SyncToken": "25",'+
		'              "MetaData": {'+
		'                "CreateTime": "2018-03-21T03:32:24-07:00",'+
		'                "LastUpdatedTime": "2018-03-28T08:09:59-07:00"'+
		'              },'+
		'              "TxnDate": "2018-03-21",'+
		'              "CurrencyRef": {'+
		'                "value": "GBP",'+
		'                "name": "British Pound Sterling"'+
		'              },'+
		'              "Line": ['+
		'                {'+
		'                  "Id": "8",'+
		'                  "Description": "paying rent again",'+
		'                  "Amount": 2000.0,'+
		'                  "DetailType": "AccountBasedExpenseLineDetail",'+
		'                  "AccountBasedExpenseLineDetail": {'+
		'                    "CustomerRef": {'+
		'                      "value": "1230",'+
		'                      "name": "Highways England:17349"'+
		'                    },'+
		'                    "ClassRef": {'+
		'                      "value": "testId",'+
		'                      "name": "17349"'+
		'                    },'+
		'                    "AccountRef": {'+
		'                      "value": "443",'+
		'                      "name": "7100 Rent"'+
		'                    },'+
		'                    "BillableStatus": "Billable",'+
		'                    "TaxCodeRef": {'+
		'                      "value": "26"'+
		'                    }'+
		'                  }'+
		'                },'+
		'                {'+
		'                  "Id": "10",'+
		'                  "Description": "staging equip",'+
		'                  "Amount": 50.0,'+
		'                  "DetailType": "AccountBasedExpenseLineDetail",'+
		'                  "AccountBasedExpenseLineDetail": {'+
		'                    "AccountRef": {'+
		'                      "value": "528",'+
		'                      "name": "1002 Work in Progress"'+
		'                    },'+
		'                    "BillableStatus": "NotBillable",'+
		'                    "TaxCodeRef": {'+
		'                      "value": "28"'+
		'                    }'+
		'                  }'+
		'                }'+
		'              ],'+
		'              "TxnTaxDetail": {'+
		'                "TotalTax": 400.0,'+
		'                "TaxLine": ['+
		'                  {'+
		'                    "Amount": 400.0,'+
		'                    "DetailType": "TaxLineDetail",'+
		'                    "TaxLineDetail": {'+
		'                      "TaxRateRef": {'+
		'                        "value": "47"'+
		'                      },'+
		'                      "PercentBased": true,'+
		'                      "TaxPercent": 20,'+
		'                      "NetAmountTaxable": 2000.0'+
		'                    }'+
		'                  },'+
		'                  {'+
		'                    "Amount": -10.0,'+
		'                    "DetailType": "TaxLineDetail",'+
		'                    "TaxLineDetail": {'+
		'                      "TaxRateRef": {'+
		'                        "value": "51"'+
		'                      },'+
		'                      "PercentBased": true,'+
		'                      "TaxPercent": -20,'+
		'                      "NetAmountTaxable": 50.0'+
		'                    }'+
		'                  },'+
		'                  {'+
		'                    "Amount": 10.0,'+
		'                    "DetailType": "TaxLineDetail",'+
		'                    "TaxLineDetail": {'+
		'                      "TaxRateRef": {'+
		'                        "value": "52"'+
		'                      },'+
		'                      "PercentBased": true,'+
		'                      "TaxPercent": 20,'+
		'                      "NetAmountTaxable": 50.0'+
		'                    }'+
		'                  }'+
		'                ]'+
		'              },'+
		'              "VendorRef": {'+
		'                "value": "1143",'+
		'                "name": "Terry Tew Sound and Light Ltd"'+
		'              },'+
		'              "APAccountRef": {'+
		'                "value": "383",'+
		'                "name": "2100 Creditors Control Account"'+
		'              },'+
		'              "TotalAmt": 2450.0,'+
		'              "GlobalTaxCalculation": "TaxExcluded"'+
		'            }'+
		'          ],'+
		'          "startPosition": 1,'+
		'          "maxResults": 1,'+
		'          "totalCount": 1'+
		'        }'+
		'      ]'+
		'    }'+
		'  ],'+
		'  "time": "2018-03-30T03:46:21.379-07:00"'+
		'}';
		JSONParserQBOBillCDC obj = JSONParserQBOBillCDC.parse(json);
		System.assert(obj != null);
	}
}