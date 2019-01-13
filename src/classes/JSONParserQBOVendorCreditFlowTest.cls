/**
 * Created by Ronan Williams on 15/11/2018.
 */

@IsTest
public class JSONParserQBOVendorCreditFlowTest {

    static testMethod void testParse() {
        String json=		'{'+
                '  "QueryResponse": {'+
                '    "VendorCredit": ['+
                '      {'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "22304",'+
                '        "SyncToken": "0",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-11-14T04:47:59-08:00",'+
                '          "LastUpdatedTime": "2018-11-14T04:47:59-08:00"'+
                '        },'+
                '        "DocNumber": "CN099 31.10.18",'+
                '        "TxnDate": "2018-11-01",'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "Line": ['+
                '          {'+
                '            "Id": "1",'+
                '            "LineNum": 1,'+
                '            "Description": "Credit re invoice 3611",'+
                '            "Amount": 162.0,'+
                '            "DetailType": "AccountBasedExpenseLineDetail",'+
                '            "AccountBasedExpenseLineDetail": {'+
                '              "CustomerRef": {'+
                '                "value": "1652",'+
                '                "name": "Highways England:18148 Highways UK 2018"'+
                '              },'+
                '              "ClassRef": {'+
                '                "value": "1400000000001111219",'+
                '                "name": "18148 Highways 18"'+
                '              },'+
                '              "AccountRef": {'+
                '                "value": "646",'+
                '                "name": "5000 Cost of sales:Events COS"'+
                '              },'+
                '              "BillableStatus": "Billable",'+
                '              "TaxCodeRef": {'+
                '                "value": "42"'+
                '              }'+
                '            }'+
                '          }'+
                '        ],'+
                '        "TxnTaxDetail": {'+
                '          "TotalTax": 32.4,'+
                '          "TaxLine": ['+
                '            {'+
                '              "Amount": 32.4,'+
                '              "DetailType": "TaxLineDetail",'+
                '              "TaxLineDetail": {'+
                '                "TaxRateRef": {'+
                '                  "value": "78"'+
                '                },'+
                '                "PercentBased": true,'+
                '                "TaxPercent": 20,'+
                '                "NetAmountTaxable": 162.0'+
                '              }'+
                '            }'+
                '          ]'+
                '        },'+
                '        "VendorRef": {'+
                '          "value": "1364",'+
                '          "name": "Inspire Displays Ltd"'+
                '        },'+
                '        "APAccountRef": {'+
                '          "value": "802",'+
                '          "name": "2100 Trade Creditors"'+
                '        },'+
                '        "TotalAmt": 194.4,'+
                '        "GlobalTaxCalculation": "TaxExcluded"'+
                '      },'+
                '      {'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "22021",'+
                '        "SyncToken": "2",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-11-01T07:00:08-07:00",'+
                '          "LastUpdatedTime": "2018-11-14T02:28:34-08:00"'+
                '        },'+
                '        "DocNumber": "CC-OCT24-RW",'+
                '        "TxnDate": "2018-10-24",'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "Line": ['+
                '          {'+
                '            "Id": "1",'+
                '            "LineNum": 1,'+
                '            "Description": "refund for incorrect charge in last statement  Project management",'+
                '            "Amount": 282.68,'+
                '            "DetailType": "AccountBasedExpenseLineDetail",'+
                '            "AccountBasedExpenseLineDetail": {'+
                '              "AccountRef": {'+
                '                "value": "758",'+
                '                "name": "7501 IT costs:Computer Software"'+
                '              },'+
                '              "BillableStatus": "NotBillable",'+
                '              "TaxCodeRef": {'+
                '                "value": "46"'+
                '              }'+
                '            }'+
                '          }'+
                '        ],'+
                '        "TxnTaxDetail": {'+
                '          "TotalTax": 0,'+
                '          "TaxLine": ['+
                '            {'+
                '              "Amount": 0,'+
                '              "DetailType": "TaxLineDetail",'+
                '              "TaxLineDetail": {'+
                '                "TaxRateRef": {'+
                '                  "value": "86"'+
                '                },'+
                '                "PercentBased": true,'+
                '                "TaxPercent": 0,'+
                '                "NetAmountTaxable": 282.68'+
                '              }'+
                '            }'+
                '          ]'+
                '        },'+
                '        "VendorRef": {'+
                '          "value": "1387",'+
                '          "name": "Barclaycard"'+
                '        },'+
                '        "APAccountRef": {'+
                '          "value": "802",'+
                '          "name": "2100 Trade Creditors"'+
                '        },'+
                '        "TotalAmt": 282.68,'+
                '        "GlobalTaxCalculation": "TaxExcluded"'+
                '      },'+
                '      {'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "22162",'+
                '        "SyncToken": "1",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-11-06T07:40:01-08:00",'+
                '          "LastUpdatedTime": "2018-11-06T07:42:29-08:00"'+
                '        },'+
                '        "DocNumber": "Q855703 22.06.18",'+
                '        "TxnDate": "2018-10-01",'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "Line": ['+
                '          {'+
                '            "Id": "1",'+
                '            "LineNum": 1,'+
                '            "Description": "Sale of Ford Transit RE15XRB in June",'+
                '            "Amount": 8797.5,'+
                '            "DetailType": "AccountBasedExpenseLineDetail",'+
                '            "AccountBasedExpenseLineDetail": {'+
                '              "AccountRef": {'+
                '                "value": "751",'+
                '                "name": "7402 Motor expenses:Vehicle Lease"'+
                '              },'+
                '              "BillableStatus": "NotBillable",'+
                '              "TaxCodeRef": {'+
                '                "value": "42"'+
                '              }'+
                '            }'+
                '          },'+
                '          {'+
                '            "Id": "2",'+
                '            "LineNum": 2,'+
                '            "Description": "Profit on sale of Van RE15XRB",'+
                '            "Amount": 4409.5,'+
                '            "DetailType": "AccountBasedExpenseLineDetail",'+
                '            "AccountBasedExpenseLineDetail": {'+
                '              "AccountRef": {'+
                '                "value": "814",'+
                '                "name": "8200 Non-operating Income & Expenditure:Other Non-operating Income"'+
                '              },'+
                '              "BillableStatus": "NotBillable",'+
                '              "TaxCodeRef": {'+
                '                "value": "42"'+
                '              }'+
                '            }'+
                '          }'+
                '        ],'+
                '        "TxnTaxDetail": {'+
                '          "TotalTax": 2641.4,'+
                '          "TaxLine": ['+
                '            {'+
                '              "Amount": 2641.4,'+
                '              "DetailType": "TaxLineDetail",'+
                '              "TaxLineDetail": {'+
                '                "TaxRateRef": {'+
                '                  "value": "78"'+
                '                },'+
                '                "PercentBased": true,'+
                '                "TaxPercent": 20,'+
                '                "NetAmountTaxable": 13207.0'+
                '              }'+
                '            }'+
                '          ]'+
                '        },'+
                '        "VendorRef": {'+
                '          "value": "1457",'+
                '          "name": "Ford Lease"'+
                '        },'+
                '        "APAccountRef": {'+
                '          "value": "802",'+
                '          "name": "2100 Trade Creditors"'+
                '        },'+
                '        "TotalAmt": 15848.4,'+
                '        "GlobalTaxCalculation": "TaxExcluded"'+
                '      },'+
                '      {'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "21401",'+
                '        "SyncToken": "2",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-09-17T07:15:37-07:00",'+
                '          "LastUpdatedTime": "2018-11-05T02:09:25-08:00"'+
                '        },'+
                '        "DocNumber": "CRedit re inv 2428550",'+
                '        "TxnDate": "2018-09-01",'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "Line": ['+
                '          {'+
                '            "Id": "1",'+
                '            "LineNum": 1,'+
                '            "Description": "Credit for Diana Seferyan taken off AXA re Sept 18 to Feb  19",'+
                '            "Amount": 292.53,'+
                '            "DetailType": "AccountBasedExpenseLineDetail",'+
                '            "AccountBasedExpenseLineDetail": {'+
                '              "AccountRef": {'+
                '                "value": "716",'+
                '                "name": "6005 Payroll:Private Health Insurance & Staff Healthcare"'+
                '              },'+
                '              "BillableStatus": "NotBillable",'+
                '              "TaxCodeRef": {'+
                '                "value": "46"'+
                '              }'+
                '            }'+
                '          }'+
                '        ],'+
                '        "TxnTaxDetail": {'+
                '          "TotalTax": 0,'+
                '          "TaxLine": ['+
                '            {'+
                '              "Amount": 0,'+
                '              "DetailType": "TaxLineDetail",'+
                '              "TaxLineDetail": {'+
                '                "TaxRateRef": {'+
                '                  "value": "86"'+
                '                },'+
                '                "PercentBased": true,'+
                '                "TaxPercent": 0,'+
                '                "NetAmountTaxable": 292.53'+
                '              }'+
                '            }'+
                '          ]'+
                '        },'+
                '        "VendorRef": {'+
                '          "value": "1348",'+
                '          "name": "AXA PPP Healthcare Limited"'+
                '        },'+
                '        "APAccountRef": {'+
                '          "value": "802",'+
                '          "name": "2100 Trade Creditors"'+
                '        },'+
                '        "TotalAmt": 292.53,'+
                '        "GlobalTaxCalculation": "TaxExcluded"'+
                '      },'+
                '      {'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "21806",'+
                '        "SyncToken": "1",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-10-24T03:17:15-07:00",'+
                '          "LastUpdatedTime": "2018-10-30T03:49:38-07:00"'+
                '        },'+
                '        "DocNumber": "CN-2709",'+
                '        "TxnDate": "2018-10-03",'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "Line": ['+
                '          {'+
                '            "Id": "1",'+
                '            "LineNum": 1,'+
                '            "Description": "50% of picking August  & September",'+
                '            "Amount": 304.7,'+
                '            "DetailType": "AccountBasedExpenseLineDetail",'+
                '            "AccountBasedExpenseLineDetail": {'+
                '              "CustomerRef": {'+
                '                "value": "1674",'+
                '                "name": "Highways England:18289 Webstore August & September orders & hosting"'+
                '              },'+
                '              "ClassRef": {'+
                '                "value": "1400000000001147921",'+
                '                "name": "18289 Webstore Highways"'+
                '              },'+
                '              "AccountRef": {'+
                '                "value": "646",'+
                '                "name": "5000 Cost of sales:Events COS"'+
                '              },'+
                '              "BillableStatus": "Billable",'+
                '              "TaxCodeRef": {'+
                '                "value": "42"'+
                '              }'+
                '            }'+
                '          }'+
                '        ],'+
                '        "TxnTaxDetail": {'+
                '          "TotalTax": 60.94,'+
                '          "TaxLine": ['+
                '            {'+
                '              "Amount": 60.94,'+
                '              "DetailType": "TaxLineDetail",'+
                '              "TaxLineDetail": {'+
                '                "TaxRateRef": {'+
                '                  "value": "78"'+
                '                },'+
                '                "PercentBased": true,'+
                '                "TaxPercent": 20,'+
                '                "NetAmountTaxable": 304.7'+
                '              }'+
                '            }'+
                '          ]'+
                '        },'+
                '        "VendorRef": {'+
                '          "value": "1571",'+
                '          "name": "Thefullworks  Limited"'+
                '        },'+
                '        "APAccountRef": {'+
                '          "value": "802",'+
                '          "name": "2100 Trade Creditors"'+
                '        },'+
                '        "TotalAmt": 365.64,'+
                '        "GlobalTaxCalculation": "TaxExcluded"'+
                '      },'+
                '      {'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "21819",'+
                '        "SyncToken": "2",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-10-24T08:10:43-07:00",'+
                '          "LastUpdatedTime": "2018-10-30T03:42:37-07:00"'+
                '        },'+
                '        "DocNumber": "88489",'+
                '        "TxnDate": "2018-10-01",'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "Line": ['+
                '          {'+
                '            "Id": "1",'+
                '            "LineNum": 1,'+
                '            "Description": "LEICESTER LOW CUPBOARD - WHITE",'+
                '            "Amount": 76.0,'+
                '            "DetailType": "AccountBasedExpenseLineDetail",'+
                '            "AccountBasedExpenseLineDetail": {'+
                '              "CustomerRef": {'+
                '                "value": "1549",'+
                '                "name": "Highways England:18168 Traffex/Seeing is Believing"'+
                '              },'+
                '              "ClassRef": {'+
                '                "value": "1400000000000981849",'+
                '                "name": "18168 Traffex/Seeing is Believing"'+
                '              },'+
                '              "AccountRef": {'+
                '                "value": "646",'+
                '                "name": "5000 Cost of sales:Events COS"'+
                '              },'+
                '              "BillableStatus": "Billable",'+
                '              "TaxCodeRef": {'+
                '                "value": "42"'+
                '              }'+
                '            }'+
                '          }'+
                '        ],'+
                '        "TxnTaxDetail": {'+
                '          "TotalTax": 15.2,'+
                '          "TaxLine": ['+
                '            {'+
                '              "Amount": 15.2,'+
                '              "DetailType": "TaxLineDetail",'+
                '              "TaxLineDetail": {'+
                '                "TaxRateRef": {'+
                '                  "value": "78"'+
                '                },'+
                '                "PercentBased": true,'+
                '                "TaxPercent": 20,'+
                '                "NetAmountTaxable": 76.0'+
                '              }'+
                '            }'+
                '          ]'+
                '        },'+
                '        "VendorRef": {'+
                '          "value": "1554",'+
                '          "name": "Showlite Ltd"'+
                '        },'+
                '        "APAccountRef": {'+
                '          "value": "802",'+
                '          "name": "2100 Trade Creditors"'+
                '        },'+
                '        "TotalAmt": 91.2,'+
                '        "GlobalTaxCalculation": "TaxExcluded"'+
                '      },'+
                '      {'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "20265",'+
                '        "SyncToken": "3",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-06-21T02:11:11-07:00",'+
                '          "LastUpdatedTime": "2018-10-30T03:42:37-07:00"'+
                '        },'+
                '        "DocNumber": "88285",'+
                '        "TxnDate": "2018-06-01",'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "PrivateNote": "Credit re Leicester low cupboard & Water",'+
                '        "Line": ['+
                '          {'+
                '            "Id": "1",'+
                '            "LineNum": 1,'+
                '            "Description": "Credit re Leicester low cupboard & Water",'+
                '            "Amount": 218.0,'+
                '            "DetailType": "AccountBasedExpenseLineDetail",'+
                '            "AccountBasedExpenseLineDetail": {'+
                '              "CustomerRef": {'+
                '                "value": "1549",'+
                '                "name": "Highways England:18168 Traffex/Seeing is Believing"'+
                '              },'+
                '              "ClassRef": {'+
                '                "value": "1400000000000981849",'+
                '                "name": "18168 Traffex/Seeing is Believing"'+
                '              },'+
                '              "AccountRef": {'+
                '                "value": "646",'+
                '                "name": "5000 Cost of sales:Events COS"'+
                '              },'+
                '              "BillableStatus": "Billable",'+
                '              "TaxCodeRef": {'+
                '                "value": "42"'+
                '              }'+
                '            }'+
                '          }'+
                '        ],'+
                '        "TxnTaxDetail": {'+
                '          "TotalTax": 43.6,'+
                '          "TaxLine": ['+
                '            {'+
                '              "Amount": 43.6,'+
                '              "DetailType": "TaxLineDetail",'+
                '              "TaxLineDetail": {'+
                '                "TaxRateRef": {'+
                '                  "value": "78"'+
                '                },'+
                '                "PercentBased": true,'+
                '                "TaxPercent": 20,'+
                '                "NetAmountTaxable": 218.0'+
                '              }'+
                '            }'+
                '          ]'+
                '        },'+
                '        "VendorRef": {'+
                '          "value": "1554",'+
                '          "name": "Showlite Ltd"'+
                '        },'+
                '        "APAccountRef": {'+
                '          "value": "802",'+
                '          "name": "2100 Trade Creditors"'+
                '        },'+
                '        "TotalAmt": 261.6,'+
                '        "GlobalTaxCalculation": "TaxExcluded"'+
                '      }'+
                '    ],'+
                '    "startPosition": 1,'+
                '    "maxResults": 41,'+
                '    "totalCount": 41'+
                '  },'+
                '  "time": "2018-11-15T01:51:09.348-08:00"'+
                '}';
        JSONParserQBOVendorCreditFlow obj = JSONParserQBOVendorCreditFlow.parse(json);
        System.assert(obj != null);
    }

}