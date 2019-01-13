/**
 * Created by Ronan Williams on 20/06/2018.
 */

@IsTest
public class JSONParserQBOBillFlowTest {

    static testMethod void testParse() {
        String json = '{' +
                '  "QueryResponse": {' +
                '    "Bill": [' +
                '      {' +
                '        "SalesTermRef": {' +
                '          "value": "11"' +
                '        },' +
                '        "DueDate": "2018-05-10",' +
                '        "Balance": 995.0,' +
                '        "domain": "QBO",' +
                '        "sparse": false,' +
                '        "Id": "19748",' +
                '        "SyncToken": "0",' +
                '        "MetaData": {' +
                '          "CreateTime": "2018-05-16T05:22:38-07:00",' +
                '          "LastUpdatedTime": "2018-05-16T05:22:38-07:00"' +
                '        },' +
                '        "DocNumber": "503918",' +
                '        "TxnDate": "2018-04-10",' +
                '        "CurrencyRef": {' +
                '          "value": "GBP",' +
                '          "name": "British Pound Sterling"' +
                '        },' +
                '        "Line": [' +
                '          {' +
                '            "Id": "1",' +
                '            "Description": "Post Event",' +
                '            "Amount": 995.0,' +
                '            "DetailType": "AccountBasedExpenseLineDetail",' +
                '            "AccountBasedExpenseLineDetail": {' +
                '              "CustomerRef": {' +
                '                "value": "1367",' +
                '                "name": "Calders:17603 NHS111 Workforce Development Event Support"' +
                '              },' +
                '              "AccountRef": {' +
                '                "value": "646",' +
                '                "name": "5000 Cost of sales:Events COS"' +
                '              },' +
                '              "BillableStatus": "Billable",' +
                '              "TaxCodeRef": {' +
                '                "value": "46"' +
                '              }' +
                '            }' +
                '          }' +
                '        ],' +
                '        "TxnTaxDetail": {' +
                '          "TotalTax": 0,' +
                '          "TaxLine": [' +
                '            {' +
                '              "Amount": 0,' +
                '              "DetailType": "TaxLineDetail",' +
                '              "TaxLineDetail": {' +
                '                "TaxRateRef": {' +
                '                  "value": "86"' +
                '                },' +
                '                "PercentBased": true,' +
                '                "TaxPercent": 0,' +
                '                "NetAmountTaxable": 995.0' +
                '              }' +
                '            }' +
                '          ]' +
                '        },' +
                '        "VendorRef": {' +
                '          "value": "1490",' +
                '          "name": "Z-CARD Ltd"' +
                '        },' +
                '        "APAccountRef": {' +
                '          "value": "802",' +
                '          "name": "Creditors"' +
                '        },' +
                '        "TotalAmt": 995.0,' +
                '        "GlobalTaxCalculation": "TaxExcluded"' +
                '      },' +
                '      {' +
                '        "SalesTermRef": {' +
                '          "value": "11"' +
                '        },' +
                '        "DueDate": "2018-05-01",' +
                '        "Balance": 2282.4,' +
                '        "domain": "QBO",' +
                '        "sparse": false,' +
                '        "Id": "19701",' +
                '        "SyncToken": "1",' +
                '        "MetaData": {' +
                '          "CreateTime": "2018-05-16T04:30:11-07:00",' +
                '          "LastUpdatedTime": "2018-05-16T04:30:16-07:00"' +
                '        },' +
                '        "DocNumber": "7020124592",' +
                '        "TxnDate": "2018-04-01",' +
                '        "CurrencyRef": {' +
                '          "value": "GBP",' +
                '          "name": "British Pound Sterling"' +
                '        },' +
                '        "Line": [' +
                '          {' +
                '            "Id": "1",' +
                '            "Description": "Hospitality - tea/coffees, water and buffet",' +
                '            "Amount": 1902.0,' +
                '            "DetailType": "AccountBasedExpenseLineDetail",' +
                '            "AccountBasedExpenseLineDetail": {' +
                '              "CustomerRef": {' +
                '                "value": "1327",' +
                '                "name": "Calders:18038 ESFA (Fire & Police) Employer Event"' +
                '              },' +
                '              "AccountRef": {' +
                '                "value": "646",' +
                '                "name": "5000 Cost of sales:Events COS"' +
                '              },' +
                '              "BillableStatus": "Billable",' +
                '              "TaxCodeRef": {' +
                '                "value": "42"' +
                '              }' +
                '            }' +
                '          }' +
                '        ],' +
                '        "TxnTaxDetail": {' +
                '          "TotalTax": 380.4,' +
                '          "TaxLine": [' +
                '            {' +
                '              "Amount": 380.4,' +
                '              "DetailType": "TaxLineDetail",' +
                '              "TaxLineDetail": {' +
                '                "TaxRateRef": {' +
                '                  "value": "78"' +
                '                },' +
                '                "PercentBased": true,' +
                '                "TaxPercent": 20,' +
                '                "NetAmountTaxable": 1902.0' +
                '              }' +
                '            }' +
                '          ]' +
                '        },' +
                '        "VendorRef": {' +
                '          "value": "1482",' +
                '          "name": "Elior UK plc"' +
                '        },' +
                '        "APAccountRef": {' +
                '          "value": "802",' +
                '          "name": "Creditors"' +
                '        },' +
                '        "TotalAmt": 2282.4,' +
                '        "GlobalTaxCalculation": "TaxExcluded"' +
                '      },' +
                '      {' +
                '        "DueDate": "2018-04-01",' +
                '        "Balance": 0.8,' +
                '        "domain": "QBO",' +
                '        "sparse": false,' +
                '        "Id": "19631",' +
                '        "SyncToken": "2",' +
                '        "MetaData": {' +
                '          "CreateTime": "2018-05-16T01:59:34-07:00",' +
                '          "LastUpdatedTime": "2018-05-16T03:34:40-07:00"' +
                '        },' +
                '        "DocNumber": "28.03.18",' +
                '        "TxnDate": "2018-04-01",' +
                '        "CurrencyRef": {' +
                '          "value": "GBP",' +
                '          "name": "British Pound Sterling"' +
                '        },' +
                '        "LinkedTxn": [' +
                '          {' +
                '            "TxnId": "19633",' +
                '            "TxnType": "BillPaymentCheck"' +
                '          }' +
                '        ],' +
                '        "Line": [' +
                '          {' +
                '            "Id": "1",' +
                '            "Description": "On site staff P Bedwell",' +
                '            "Amount": 226.8,' +
                '            "DetailType": "AccountBasedExpenseLineDetail",' +
                '            "AccountBasedExpenseLineDetail": {' +
                '              "CustomerRef": {' +
                '                "value": "1254",' +
                '                "name": "Calders:17579 HMT FinTech Conference"' +
                '              },' +
                '              "AccountRef": {' +
                '                "value": "646",' +
                '                "name": "5000 Cost of sales:Events COS"' +
                '              },' +
                '              "BillableStatus": "Billable",' +
                '              "TaxCodeRef": {' +
                '                "value": "46"' +
                '              }' +
                '            }' +
                '          }' +
                '        ],' +
                '        "TxnTaxDetail": {' +
                '          "TotalTax": 0,' +
                '          "TaxLine": [' +
                '            {' +
                '              "Amount": 0,' +
                '              "DetailType": "TaxLineDetail",' +
                '              "TaxLineDetail": {' +
                '                "TaxRateRef": {' +
                '                  "value": "86"' +
                '                },' +
                '                "PercentBased": true,' +
                '                "TaxPercent": 0,' +
                '                "NetAmountTaxable": 226.8' +
                '              }' +
                '            }' +
                '          ]' +
                '        },' +
                '        "VendorRef": {' +
                '          "value": "1406",' +
                '          "name": "Paige Bedwell"' +
                '        },' +
                '        "APAccountRef": {' +
                '          "value": "802",' +
                '          "name": "Creditors"' +
                '        },' +
                '        "TotalAmt": 226.8,' +
                '        "GlobalTaxCalculation": "TaxExcluded"' +
                '      },' +
                '      {' +
                '        "SalesTermRef": {' +
                '          "value": "9"' +
                '        },' +
                '        "DueDate": "2018-04-23",' +
                '        "Balance": 189.0,' +
                '        "domain": "QBO",' +
                '        "sparse": false,' +
                '        "Id": "19447",' +
                '        "SyncToken": "1",' +
                '        "MetaData": {' +
                '          "CreateTime": "2018-05-10T04:00:00-07:00",' +
                '          "LastUpdatedTime": "2018-05-10T04:01:22-07:00"' +
                '        },' +
                '        "DocNumber": "278544",' +
                '        "TxnDate": "2018-04-23",' +
                '        "CurrencyRef": {' +
                '          "value": "GBP",' +
                '          "name": "British Pound Sterling"' +
                '        },' +
                '        "LinkedTxn": [' +
                '          {' +
                '            "TxnId": "19450",' +
                '            "TxnType": "BillPaymentCheck"' +
                '          }' +
                '        ],' +
                '        "Line": [' +
                '          {' +
                '            "Id": "1",' +
                '            "Description": "Group booking accomodation",' +
                '            "Amount": 4567.5,' +
                '            "DetailType": "AccountBasedExpenseLineDetail",' +
                '            "AccountBasedExpenseLineDetail": {' +
                '              "CustomerRef": {' +
                '                "value": "1325",' +
                '                "name": "Calders:17294 MeetGREAT Event"' +
                '              },' +
                '              "AccountRef": {' +
                '                "value": "646",' +
                '                "name": "5000 Cost of sales:Events COS"' +
                '              },' +
                '              "BillableStatus": "Billable",' +
                '              "TaxCodeRef": {' +
                '                "value": "42"' +
                '              }' +
                '            }' +
                '          },' +
                '          {' +
                '            "Id": "2",' +
                '            "Description": "Accomdation for C Kelsy paid Via CC",' +
                '            "Amount": 189.0,' +
                '            "DetailType": "AccountBasedExpenseLineDetail",' +
                '            "AccountBasedExpenseLineDetail": {' +
                '              "CustomerRef": {' +
                '                "value": "1325",' +
                '                "name": "Calders:17294 MeetGREAT Event"' +
                '              },' +
                '              "AccountRef": {' +
                '                "value": "646",' +
                '                "name": "5000 Cost of sales:Events COS"' +
                '              },' +
                '              "BillableStatus": "Billable",' +
                '              "TaxCodeRef": {' +
                '                "value": "46"' +
                '              }' +
                '            }' +
                '          }' +
                '        ],' +
                '        "TxnTaxDetail": {' +
                '          "TotalTax": 913.5,' +
                '          "TaxLine": [' +
                '            {' +
                '              "Amount": 913.5,' +
                '              "DetailType": "TaxLineDetail",' +
                '              "TaxLineDetail": {' +
                '                "TaxRateRef": {' +
                '                  "value": "78"' +
                '                },' +
                '                "PercentBased": true,' +
                '                "TaxPercent": 20,' +
                '                "NetAmountTaxable": 4567.5' +
                '              }' +
                '            },' +
                '            {' +
                '              "Amount": 0,' +
                '              "DetailType": "TaxLineDetail",' +
                '              "TaxLineDetail": {' +
                '                "TaxRateRef": {' +
                '                  "value": "86"' +
                '                },' +
                '                "PercentBased": true,' +
                '                "TaxPercent": 0,' +
                '                "NetAmountTaxable": 189.0' +
                '              }' +
                '            }' +
                '          ]' +
                '        },' +
                '        "VendorRef": {' +
                '          "value": "1444",' +
                '          "name": "Ibis London Blackfriars"' +
                '        },' +
                '        "APAccountRef": {' +
                '          "value": "802",' +
                '          "name": "Creditors"' +
                '        },' +
                '        "TotalAmt": 5670.0,' +
                '        "GlobalTaxCalculation": "TaxExcluded"' +
                '      },' +
                '      {' +
                '        "DueDate": "2018-03-31",' +
                '        "Balance": 180.76,' +
                '        "domain": "QBO",' +
                '        "sparse": false,' +
                '        "Id": "19187",' +
                '        "SyncToken": "0",' +
                '        "MetaData": {' +
                '          "CreateTime": "2018-05-02T08:35:15-07:00",' +
                '          "LastUpdatedTime": "2018-05-02T08:35:15-07:00"' +
                '        },' +
                '        "DocNumber": "65678273",' +
                '        "TxnDate": "2018-03-31",' +
                '        "CurrencyRef": {' +
                '          "value": "GBP",' +
                '          "name": "British Pound Sterling"' +
                '        },' +
                '        "Line": [' +
                '          {' +
                '            "Id": "1",' +
                '            "Description": "Opening Balances - Sanitary disposal  06.04.18 to 05.07.18",' +
                '            "Amount": 180.76,' +
                '            "DetailType": "AccountBasedExpenseLineDetail",' +
                '            "AccountBasedExpenseLineDetail": {' +
                '              "AccountRef": {' +
                '                "value": "794",' +
                '                "name": "9999 Mispostings Account"' +
                '              },' +
                '              "BillableStatus": "NotBillable",' +
                '              "TaxCodeRef": {' +
                '                "value": "46"' +
                '              }' +
                '            }' +
                '          }' +
                '        ],' +
                '        "TxnTaxDetail": {' +
                '          "TotalTax": 0,' +
                '          "TaxLine": [' +
                '            {' +
                '              "Amount": 0,' +
                '              "DetailType": "TaxLineDetail",' +
                '              "TaxLineDetail": {' +
                '                "TaxRateRef": {' +
                '                  "value": "86"' +
                '                },' +
                '                "PercentBased": true,' +
                '                "TaxPercent": 0,' +
                '                "NetAmountTaxable": 180.76' +
                '              }' +
                '            }' +
                '          ]' +
                '        },' +
                '        "VendorRef": {' +
                '          "value": "1409",' +
                '          "name": "PHS Group Ltd"' +
                '        },' +
                '        "APAccountRef": {' +
                '          "value": "802",' +
                '          "name": "Creditors"' +
                '        },' +
                '        "TotalAmt": 180.76,' +
                '        "GlobalTaxCalculation": "TaxExcluded"' +
                '      },' +
                '      {' +
                '        "DueDate": "2018-03-31",' +
                '        "Balance": 9.37,' +
                '        "domain": "QBO",' +
                '        "sparse": false,' +
                '        "Id": "19110",' +
                '        "SyncToken": "1",' +
                '        "MetaData": {' +
                '          "CreateTime": "2018-04-26T07:21:18-07:00",' +
                '          "LastUpdatedTime": "2018-04-30T01:14:51-07:00"' +
                '        },' +
                '        "DocNumber": "198652",' +
                '        "TxnDate": "2018-03-31",' +
                '        "CurrencyRef": {' +
                '          "value": "GBP",' +
                '          "name": "British Pound Sterling"' +
                '        },' +
                '        "Line": [' +
                '          {' +
                '            "Id": "1",' +
                '            "Description": "Opening Balances - Water charges 15.312.16-3.03.18 (472 days)",' +
                '            "Amount": 9.37,' +
                '            "DetailType": "AccountBasedExpenseLineDetail",' +
                '            "AccountBasedExpenseLineDetail": {' +
                '              "AccountRef": {' +
                '                "value": "794",' +
                '                "name": "9999 Mispostings Account"' +
                '              },' +
                '              "BillableStatus": "NotBillable",' +
                '              "TaxCodeRef": {' +
                '                "value": "46"' +
                '              }' +
                '            }' +
                '          }' +
                '        ],' +
                '        "TxnTaxDetail": {' +
                '          "TotalTax": 0,' +
                '          "TaxLine": [' +
                '            {' +
                '              "Amount": 0,' +
                '              "DetailType": "TaxLineDetail",' +
                '              "TaxLineDetail": {' +
                '                "TaxRateRef": {' +
                '                  "value": "86"' +
                '                },' +
                '                "PercentBased": true,' +
                '                "TaxPercent": 0,' +
                '                "NetAmountTaxable": 9.37' +
                '              }' +
                '            }' +
                '          ]' +
                '        },' +
                '        "VendorRef": {' +
                '          "value": "1352",' +
                '          "name": "Castle Water Limited"' +
                '        },' +
                '        "APAccountRef": {' +
                '          "value": "802",' +
                '          "name": "Creditors"' +
                '        },' +
                '        "TotalAmt": 9.37,' +
                '        "GlobalTaxCalculation": "TaxExcluded"' +
                '      },' +
                '      {' +
                '        "DueDate": "2018-03-31",' +
                '        "Balance": 120.0,' +
                '        "domain": "QBO",' +
                '        "sparse": false,' +
                '        "Id": "19122",' +
                '        "SyncToken": "0",' +
                '        "MetaData": {' +
                '          "CreateTime": "2018-04-26T08:01:19-07:00",' +
                '          "LastUpdatedTime": "2018-04-26T08:01:19-07:00"' +
                '        },' +
                '        "DocNumber": "99132-2902",' +
                '        "TxnDate": "2018-03-31",' +
                '        "CurrencyRef": {' +
                '          "value": "GBP",' +
                '          "name": "British Pound Sterling"' +
                '        },' +
                '        "Line": [' +
                '          {' +
                '            "Id": "1",' +
                '            "Description": "Opening Balances - Livegroup Cabinet flyers",' +
                '            "Amount": 120.0,' +
                '            "DetailType": "AccountBasedExpenseLineDetail",' +
                '            "AccountBasedExpenseLineDetail": {' +
                '              "AccountRef": {' +
                '                "value": "794",' +
                '                "name": "9999 Mispostings Account"' +
                '              },' +
                '              "BillableStatus": "NotBillable",' +
                '              "TaxCodeRef": {' +
                '                "value": "46"' +
                '              }' +
                '            }' +
                '          }' +
                '        ],' +
                '        "TxnTaxDetail": {' +
                '          "TotalTax": 0,' +
                '          "TaxLine": [' +
                '            {' +
                '              "Amount": 0,' +
                '              "DetailType": "TaxLineDetail",' +
                '              "TaxLineDetail": {' +
                '                "TaxRateRef": {' +
                '                  "value": "86"' +
                '                },' +
                '                "PercentBased": true,' +
                '                "TaxPercent": 0,' +
                '                "NetAmountTaxable": 120.0' +
                '              }' +
                '            }' +
                '          ]' +
                '        },' +
                '        "VendorRef": {' +
                '          "value": "1359",' +
                '          "name": "FT Solutions"' +
                '        },' +
                '        "APAccountRef": {' +
                '          "value": "802",' +
                '          "name": "Creditors"' +
                '        },' +
                '        "TotalAmt": 120.0,' +
                '        "GlobalTaxCalculation": "TaxExcluded"' +
                '      },' +
                '      {' +
                '        "DueDate": "2018-03-31",' +
                '        "Balance": 291.6,' +
                '        "domain": "QBO",' +
                '        "sparse": false,' +
                '        "Id": "19121",' +
                '        "SyncToken": "1",' +
                '        "MetaData": {' +
                '          "CreateTime": "2018-04-26T07:59:09-07:00",' +
                '          "LastUpdatedTime": "2018-04-26T08:00:06-07:00"' +
                '        },' +
                '        "DocNumber": "96979/2864",' +
                '        "TxnDate": "2018-03-31",' +
                '        "CurrencyRef": {' +
                '          "value": "GBP",' +
                '          "name": "British Pound Sterling"' +
                '        },' +
                '        "Line": [' +
                '          {' +
                '            "Id": "1",' +
                '            "Description": "Opening Balances - Live Ltd UKHMF flyers",' +
                '            "Amount": 291.6,' +
                '            "DetailType": "AccountBasedExpenseLineDetail",' +
                '            "AccountBasedExpenseLineDetail": {' +
                '              "AccountRef": {' +
                '                "value": "794",' +
                '                "name": "9999 Mispostings Account"' +
                '              },' +
                '              "BillableStatus": "NotBillable",' +
                '              "TaxCodeRef": {' +
                '                "value": "46"' +
                '              }' +
                '            }' +
                '          }' +
                '        ],' +
                '        "TxnTaxDetail": {' +
                '          "TotalTax": 0,' +
                '          "TaxLine": [' +
                '            {' +
                '              "Amount": 0,' +
                '              "DetailType": "TaxLineDetail",' +
                '              "TaxLineDetail": {' +
                '                "TaxRateRef": {' +
                '                  "value": "86"' +
                '                },' +
                '                "PercentBased": true,' +
                '                "TaxPercent": 0,' +
                '                "NetAmountTaxable": 291.6' +
                '              }' +
                '            }' +
                '          ]' +
                '        },' +
                '        "VendorRef": {' +
                '          "value": "1359",' +
                '          "name": "FT Solutions"' +
                '        },' +
                '        "APAccountRef": {' +
                '          "value": "802",' +
                '          "name": "Creditors"' +
                '        },' +
                '        "TotalAmt": 291.6,' +
                '        "GlobalTaxCalculation": "TaxExcluded"' +
                '      },' +
                '      {' +
                '        "DueDate": "2018-03-31",' +
                '        "Balance": 90.0,' +
                '        "domain": "QBO",' +
                '        "sparse": false,' +
                '        "Id": "19120",' +
                '        "SyncToken": "0",' +
                '        "MetaData": {' +
                '          "CreateTime": "2018-04-26T07:58:24-07:00",' +
                '          "LastUpdatedTime": "2018-04-26T07:58:24-07:00"' +
                '        },' +
                '        "DocNumber": "93395/2752",' +
                '        "TxnDate": "2018-03-31",' +
                '        "CurrencyRef": {' +
                '          "value": "GBP",' +
                '          "name": "British Pound Sterling"' +
                '        },' +
                '        "Line": [' +
                '          {' +
                '            "Id": "1",' +
                '            "Description": "Opening Balances- Bespoke books for presentation",' +
                '            "Amount": 90.0,' +
                '            "DetailType": "AccountBasedExpenseLineDetail",' +
                '            "AccountBasedExpenseLineDetail": {' +
                '              "AccountRef": {' +
                '                "value": "794",' +
                '                "name": "9999 Mispostings Account"' +
                '              },' +
                '              "BillableStatus": "NotBillable",' +
                '              "TaxCodeRef": {' +
                '                "value": "46"' +
                '              }' +
                '            }' +
                '          }' +
                '        ],' +
                '        "TxnTaxDetail": {' +
                '          "TotalTax": 0,' +
                '          "TaxLine": [' +
                '            {' +
                '              "Amount": 0,' +
                '              "DetailType": "TaxLineDetail",' +
                '              "TaxLineDetail": {' +
                '                "TaxRateRef": {' +
                '                  "value": "86"' +
                '                },' +
                '                "PercentBased": true,' +
                '                "TaxPercent": 0,' +
                '                "NetAmountTaxable": 90.0' +
                '              }' +
                '            }' +
                '          ]' +
                '        },' +
                '        "VendorRef": {' +
                '          "value": "1359",' +
                '          "name": "FT Solutions"' +
                '        },' +
                '        "APAccountRef": {' +
                '          "value": "802",' +
                '          "name": "Creditors"' +
                '        },' +
                '        "TotalAmt": 90.0,' +
                '        "GlobalTaxCalculation": "TaxExcluded"' +
                '      }' +
                '    ],' +
                '    "startPosition": 1,' +
                '    "maxResults": 28,' +
                '    "totalCount": 28' +
                '  },' +
                '  "time": "2018-06-20T04:21:40.128-07:00"' +
                '}';
        JSONParserQBOBillFlow obj = JSONParserQBOBillFlow.parse(json);
        System.assert(obj != null);
    }
}