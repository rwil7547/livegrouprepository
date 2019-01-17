/**
 * Created by Ronan Williams on 09/11/2018.
 */

@IsTest
public class JSONParserQBOCreditMemoFlowTest {

    @IsTest
    static void testParse() {
        String json=		'{'+
                '  "QueryResponse": {'+
                '    "CreditMemo": ['+
                '      {'+
                '        "RemainingCredit": 0,'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "20542",'+
                '        "SyncToken": "5",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-07-05T01:24:44-07:00",'+
                '          "LastUpdatedTime": "2018-07-19T06:50:27-07:00"'+
                '        },'+
                '        "CustomField": ['+
                '          {'+
                '            "DefinitionId": "1",'+
                '            "Name": "Schedule",'+
                '            "Type": "StringType",'+
                '            "StringValue": "SI01203"'+
                '          },'+
                '          {'+
                '            "DefinitionId": "2",'+
                '            "Name": "Your Ref",'+
                '            "Type": "StringType",'+
                '            "StringValue": "CCS3354741"'+
                '          },'+
                '          {'+
                '            "DefinitionId": "3",'+
                '            "Name": "Our Ref",'+
                '            "Type": "StringType",'+
                '            "StringValue": "18177"'+
                '          }'+
                '        ],'+
                '        "DocNumber": "1152",'+
                '        "TxnDate": "2018-07-05",'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "Line": ['+
                '          {'+
                '            "Id": "1",'+
                '            "LineNum": 1,'+
                '            "Description": "Commission for invoice 1151Re:  ESFA Booking ref: CCS3354741FAO: Tracy Iley",'+
                '            "Amount": 855.64,'+
                '            "SalesItemLineDetail": {'+
                '              "ItemRef": {'+
                '                "value": "36",'+
                '                "name": "Events Income"'+
                '              },'+
                '              "ClassRef": {'+
                '                "value": "1400000000000992827",'+
                '                "name": "18177 House of Commons Event (July)"'+
                '              },'+
                '              "TaxCodeRef": {'+
                '                "value": "42"'+
                '              }'+
                '            }'+
                '          },'+
                '          {'+
                '            "Amount": 855.64,'+
                '            "DetailType": "SubTotalLineDetail",'+
                '            "SubTotalLineDetail": {}'+
                '          }'+
                '        ],'+
                '        "TxnTaxDetail": {'+
                '          "TotalTax": 171.13,'+
                '          "TaxLine": ['+
                '            {'+
                '              "Amount": 171.13,'+
                '              "DetailType": "TaxLineDetail",'+
                '              "TaxLineDetail": {'+
                '                "TaxRateRef": {'+
                '                  "value": "79"'+
                '                },'+
                '                "PercentBased": true,'+
                '                "TaxPercent": 20,'+
                '                "NetAmountTaxable": 855.64'+
                '              }'+
                '            }'+
                '          ]'+
                '        },'+
                '        "CustomerRef": {'+
                '          "value": "1569",'+
                '          "name": "18177 House of Commons Event (July)"'+
                '        },'+
                '        "CustomerMemo": {'+
                '          "value": "House of Commons Event (July) Job no 18177 Event 26th June 2018"'+
                '        },'+
                '        "BillAddr": {'+
                '          "Id": "1343",'+
                '          "Line1": "Calders",'+
                '          "Line2": "4 Woodside Court",'+
                '          "Line3": "Clayton Wood Rise",'+
                '          "Line4": "Leeds",'+
                '          "Line5": "LS16 6RF"'+
                '        },'+
                '        "GlobalTaxCalculation": "TaxExcluded",'+
                '        "TotalAmt": 1026.77,'+
                '        "PrintStatus": "NotSet",'+
                '        "EmailStatus": "NeedToSend",'+
                '        "BillEmail": {'+
                '          "Address": "tracy@calders.org.uk"'+
                '        },'+
                '        "Balance": 0,'+
                '        "DeliveryInfo": {'+
                '          "DeliveryType": "Email"'+
                '        }'+
                '      },'+
                '      {'+
                '        "RemainingCredit": 0,'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "20189",'+
                '        "SyncToken": "4",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-06-19T01:52:41-07:00",'+
                '          "LastUpdatedTime": "2018-07-19T06:50:27-07:00"'+
                '        },'+
                '        "CustomField": ['+
                '          {'+
                '            "DefinitionId": "1",'+
                '            "Name": "Schedule",'+
                '            "Type": "StringType",'+
                '            "StringValue": "SI01212"'+
                '          },'+
                '          {'+
                '            "DefinitionId": "2",'+
                '            "Name": "Your Ref",'+
                '            "Type": "StringType",'+
                '            "StringValue": "CCS330978/1"'+
                '          },'+
                '          {'+
                '            "DefinitionId": "3",'+
                '            "Name": "Our Ref",'+
                '            "Type": "StringType",'+
                '            "StringValue": "18181"'+
                '          }'+
                '        ],'+
                '        "DocNumber": "1137",'+
                '        "TxnDate": "2018-06-18",'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "Line": ['+
                '          {'+
                '            "Id": "1",'+
                '            "LineNum": 1,'+
                '            "Description": "Commission re invoice 1136 RE: NHS Booking ref: CCS330971 FAO: Tracy Iley",'+
                '            "Amount": 619.5,'+
                '            "DetailType": "SalesItemLineDetail",'+
                '            "SalesItemLineDetail": {'+
                '              "ItemRef": {'+
                '                "value": "36",'+
                '                "name": "Events Income"'+
                '              },'+
                '              "ClassRef": {'+
                '                "value": "1400000000000981846",'+
                '                "name": "18181 NHS 111 Blue Print Film"'+
                '              },'+
                '              "TaxCodeRef": {'+
                '                "value": "42"'+
                '              }'+
                '            }'+
                '          },'+
                '          {'+
                '            "Amount": 619.5,'+
                '            "DetailType": "SubTotalLineDetail",'+
                '            "SubTotalLineDetail": {}'+
                '          }'+
                '        ],'+
                '        "TxnTaxDetail": {'+
                '          "TotalTax": 123.9,'+
                '          "TaxLine": ['+
                '            {'+
                '              "Amount": 123.9,'+
                '              "DetailType": "TaxLineDetail",'+
                '              "TaxLineDetail": {'+
                '                "TaxRateRef": {'+
                '                  "value": "79"'+
                '                },'+
                '                "PercentBased": true,'+
                '                "TaxPercent": 20,'+
                '                "NetAmountTaxable": 619.5'+
                '              }'+
                '            }'+
                '          ]'+
                '        },'+
                '        "CustomerRef": {'+
                '          "value": "1547",'+
                '          "name": "18181 NHS 111 Blue Print Film"'+
                '        },'+
                '        "CustomerMemo": {'+
                '          "value": "NHS 111 Blue Print Film Job no 18181 Event 12th June 2018"'+
                '        },'+
                '        "BillAddr": {'+
                '          "Id": "1309",'+
                '          "Line1": "Calders",'+
                '          "Line2": "4 Woodside Court",'+
                '          "Line3": "Clayton Wood Rise",'+
                '          "Line4": "Leeds",'+
                '          "Line5": "LS16 6RF"'+
                '        },'+
                '        "GlobalTaxCalculation": "TaxExcluded",'+
                '        "TotalAmt": 743.4,'+
                '        "PrintStatus": "NotSet",'+
                '        "EmailStatus": "NotSet",'+
                '        "BillEmail": {'+
                '          "Address": "tracy@calders.org.uk"'+
                '        },'+
                '        "Balance": 0'+
                '      },'+
                '      {'+
                '        "RemainingCredit": 0,'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "20105",'+
                '        "SyncToken": "2",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-06-06T08:25:44-07:00",'+
                '          "LastUpdatedTime": "2018-07-16T04:21:34-07:00"'+
                '        },'+
                '        "CustomField": ['+
                '          {'+
                '            "DefinitionId": "1",'+
                '            "Name": "Schedule",'+
                '            "Type": "StringType",'+
                '            "StringValue": "SI01183"'+
                '          },'+
                '          {'+
                '            "DefinitionId": "2",'+
                '            "Name": "Your Ref",'+
                '            "Type": "StringType",'+
                '            "StringValue": "PO4204880"'+
                '          },'+
                '          {'+
                '            "DefinitionId": "3",'+
                '            "Name": "Our Ref",'+
                '            "Type": "StringType",'+
                '            "StringValue": "17584"'+
                '          }'+
                '        ],'+
                '        "DocNumber": "1121",'+
                '        "TxnDate": "2018-06-06",'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "Line": ['+
                '          {'+
                '            "Id": "1",'+
                '            "LineNum": 1,'+
                '            "Description": "Credit re invoice 1097 PO4204880 FAO: Hannah Hayes",'+
                '            "Amount": 1143.95,'+
                '            "DetailType": "SalesItemLineDetail",'+
                '            "SalesItemLineDetail": {'+
                '              "ItemRef": {'+
                '                "value": "36",'+
                '                "name": "Events Income"'+
                '              },'+
                '              "ClassRef": {'+
                '                "value": "1400000000000858552",'+
                '                "name": "17584 CYBER UK"'+
                '              },'+
                '              "TaxCodeRef": {'+
                '                "value": "42"'+
                '              }'+
                '            }'+
                '          },'+
                '          {'+
                '            "Amount": 1143.95,'+
                '            "DetailType": "SubTotalLineDetail",'+
                '            "SubTotalLineDetail": {}'+
                '          }'+
                '        ],'+
                '        "TxnTaxDetail": {'+
                '          "TotalTax": 228.79,'+
                '          "TaxLine": ['+
                '            {'+
                '              "Amount": 228.79,'+
                '              "DetailType": "TaxLineDetail",'+
                '              "TaxLineDetail": {'+
                '                "TaxRateRef": {'+
                '                  "value": "79"'+
                '                },'+
                '                "PercentBased": true,'+
                '                "TaxPercent": 20,'+
                '                "NetAmountTaxable": 1143.95'+
                '              }'+
                '            }'+
                '          ]'+
                '        },'+
                '        "CustomerRef": {'+
                '          "value": "1385",'+
                '          "name": "17584 CYBERUK 2018"'+
                '        },'+
                '        "CustomerMemo": {'+
                '          "value": "CYBERUK 2018Job no 17584Event 10th- 12th April 2018"'+
                '        },'+
                '        "BillAddr": {'+
                '          "Id": "1289",'+
                '          "Line1": "National Cyber Security Centre",'+
                '          "Line2": "A2 J Hubble Road",'+
                '          "Line3": "Cheltenham",'+
                '          "Line4": "Gloucester",'+
                '          "Line5": "GL51 0EX"'+
                '        },'+
                '        "GlobalTaxCalculation": "TaxExcluded",'+
                '        "TotalAmt": 1372.74,'+
                '        "PrintStatus": "NotSet",'+
                '        "EmailStatus": "NotSet",'+
                '        "Balance": 0'+
                '      },'+
                '      {'+
                '        "RemainingCredit": 0,'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "20005",'+
                '        "SyncToken": "2",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-05-31T06:57:33-07:00",'+
                '          "LastUpdatedTime": "2018-07-11T06:54:02-07:00"'+
                '        },'+
                '        "CustomField": ['+
                '          {'+
                '            "DefinitionId": "1",'+
                '            "Name": "Schedule",'+
                '            "Type": "StringType",'+
                '            "StringValue": "SI01184"'+
                '          },'+
                '          {'+
                '            "DefinitionId": "2",'+
                '            "Name": "Your Ref",'+
                '            "Type": "StringType",'+
                '            "StringValue": "CCS328825//1"'+
                '          },'+
                '          {'+
                '            "DefinitionId": "3",'+
                '            "Name": "Our Ref",'+
                '            "Type": "StringType",'+
                '            "StringValue": "18172"'+
                '          }'+
                '        ],'+
                '        "DocNumber": "1117",'+
                '        "TxnDate": "2018-05-31",'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "Line": ['+
                '          {'+
                '            "Id": "1",'+
                '            "LineNum": 1,'+
                '            "Description": "Commission re invoice 1116 \\nRE: UKHMF\\nBooking ref: CCS328825//1\\nFAO: Tracy Iley",'+
                '            "Amount": 171.0,'+
                '            "DetailType": "SalesItemLineDetail",'+
                '            "SalesItemLineDetail": {'+
                '              "ItemRef": {'+
                '                "value": "36",'+
                '                "name": "Events Income"'+
                '              },'+
                '              "ClassRef": {'+
                '                "value": "1400000000000993295",'+
                '                "name": "18172 Storage of Exhibition Stand May to July 18"'+
                '              },'+
                '              "TaxCodeRef": {'+
                '                "value": "42"'+
                '              }'+
                '            }'+
                '          },'+
                '          {'+
                '            "Amount": 171.0,'+
                '            "DetailType": "SubTotalLineDetail",'+
                '            "SubTotalLineDetail": {}'+
                '          }'+
                '        ],'+
                '        "TxnTaxDetail": {'+
                '          "TotalTax": 34.2,'+
                '          "TaxLine": ['+
                '            {'+
                '              "Amount": 34.2,'+
                '              "DetailType": "TaxLineDetail",'+
                '              "TaxLineDetail": {'+
                '                "TaxRateRef": {'+
                '                  "value": "79"'+
                '                },'+
                '                "PercentBased": true,'+
                '                "TaxPercent": 20,'+
                '                "NetAmountTaxable": 171.0'+
                '              }'+
                '            }'+
                '          ]'+
                '        },'+
                '        "CustomerRef": {'+
                '          "value": "1531",'+
                '          "name": "18172 Storage of Exhibition Stand May to July 2018"'+
                '        },'+
                '        "CustomerMemo": {'+
                '          "value": "Storage of Exhibition Stand May to July 2018\\nJob no 18172\\nEvent 18th May 2018"'+
                '        },'+
                '        "BillAddr": {'+
                '          "Id": "1277",'+
                '          "Line1": "Calders",'+
                '          "Line2": "4 Woodside Court",'+
                '          "Line3": "Clayton Wood Rise",'+
                '          "Line4": "Leeds",'+
                '          "Line5": "LS16 6RF"'+
                '        },'+
                '        "GlobalTaxCalculation": "TaxExcluded",'+
                '        "TotalAmt": 205.2,'+
                '        "PrintStatus": "NotSet",'+
                '        "EmailStatus": "NeedToSend",'+
                '        "BillEmail": {'+
                '          "Address": "tracy@calders.org.uk"'+
                '        },'+
                '        "Balance": 0,'+
                '        "DeliveryInfo": {'+
                '          "DeliveryType": "Email"'+
                '        }'+
                '      },'+
                '      {'+
                '        "RemainingCredit": 0,'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "20036",'+
                '        "SyncToken": "2",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-06-05T02:29:58-07:00",'+
                '          "LastUpdatedTime": "2018-07-11T06:53:42-07:00"'+
                '        },'+
                '        "CustomField": ['+
                '          {'+
                '            "DefinitionId": "1",'+
                '            "Name": "Schedule",'+
                '            "Type": "StringType",'+
                '            "StringValue": "SI01096"'+
                '          },'+
                '          {'+
                '            "DefinitionId": "2",'+
                '            "Name": "Your Ref",'+
                '            "Type": "StringType",'+
                '            "StringValue": "CCS329454//1"'+
                '          },'+
                '          {'+
                '            "DefinitionId": "3",'+
                '            "Name": "Our Ref",'+
                '            "Type": "StringType",'+
                '            "StringValue": "18026"'+
                '          }'+
                '        ],'+
                '        "DocNumber": "1119",'+
                '        "TxnDate": "2018-05-31",'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "Line": ['+
                '          {'+
                '            "Id": "1",'+
                '            "LineNum": 1,'+
                '            "Description": "Commission re invoice 1117 \\nRE: ESFA\\nBooking ref: CCS329454/1\\nFAO: Tracy Iley",'+
                '            "Amount": 2466.56,'+
                '            "DetailType": "SalesItemLineDetail",'+
                '            "SalesItemLineDetail": {'+
                '              "ItemRef": {'+
                '                "value": "36",'+
                '                "name": "Events Income"'+
                '              },'+
                '              "ClassRef": {'+
                '                "value": "1400000000000993300",'+
                '                "name": "18026 ESFA (NHS Procurement Events)"'+
                '              },'+
                '              "TaxCodeRef": {'+
                '                "value": "42"'+
                '              }'+
                '            }'+
                '          },'+
                '          {'+
                '            "Amount": 2466.56,'+
                '            "DetailType": "SubTotalLineDetail",'+
                '            "SubTotalLineDetail": {}'+
                '          }'+
                '        ],'+
                '        "TxnTaxDetail": {'+
                '          "TotalTax": 493.31,'+
                '          "TaxLine": ['+
                '            {'+
                '              "Amount": 493.31,'+
                '              "DetailType": "TaxLineDetail",'+
                '              "TaxLineDetail": {'+
                '                "TaxRateRef": {'+
                '                  "value": "79"'+
                '                },'+
                '                "PercentBased": true,'+
                '                "TaxPercent": 20,'+
                '                "NetAmountTaxable": 2466.56'+
                '              }'+
                '            }'+
                '          ]'+
                '        },'+
                '        "CustomerRef": {'+
                '          "value": "1538",'+
                '          "name": "18026 ESFA (NHS Procurement Events)"'+
                '        },'+
                '        "CustomerMemo": {'+
                '          "value": "ESFA (NHS Procurement Events)\\nJob no 18026\\nEvent  1st-10th May 2018"'+
                '        },'+
                '        "BillAddr": {'+
                '          "Id": "1284",'+
                '          "Line1": "Calders",'+
                '          "Line2": "4 Woodside Court",'+
                '          "Line3": "Clayton Wood Rise",'+
                '          "Line4": "Leeds",'+
                '          "Line5": "LS16 6RF"'+
                '        },'+
                '        "GlobalTaxCalculation": "TaxExcluded",'+
                '        "TotalAmt": 2959.87,'+
                '        "PrintStatus": "NotSet",'+
                '        "EmailStatus": "NotSet",'+
                '        "BillEmail": {'+
                '          "Address": "tracy@calders.org.uk"'+
                '        },'+
                '        "Balance": 0'+
                '      },'+
                '      {'+
                '        "RemainingCredit": 0,'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "19538",'+
                '        "SyncToken": "2",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-05-15T02:12:27-07:00",'+
                '          "LastUpdatedTime": "2018-07-11T06:32:54-07:00"'+
                '        },'+
                '        "CustomField": ['+
                '          {'+
                '            "DefinitionId": "1",'+
                '            "Name": "Schedule",'+
                '            "Type": "StringType",'+
                '            "StringValue": "SI00877"'+
                '          },'+
                '          {'+
                '            "DefinitionId": "2",'+
                '            "Name": "Your Ref",'+
                '            "Type": "StringType",'+
                '            "StringValue": "CCS261837/1"'+
                '          },'+
                '          {'+
                '            "DefinitionId": "3",'+
                '            "Name": "Our Ref",'+
                '            "Type": "StringType",'+
                '            "StringValue": "17294"'+
                '          }'+
                '        ],'+
                '        "DocNumber": "1104",'+
                '        "TxnDate": "2018-05-15",'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "Line": ['+
                '          {'+
                '            "Id": "1",'+
                '            "LineNum": 1,'+
                '            "Description": "Commission re invoice 1103\\nRE Visit Britain\\nBooking ref:CCS261837/1\\nFAO: Tracy Iley",'+
                '            "Amount": 22087.74,'+
                '            "DetailType": "SalesItemLineDetail",'+
                '            "SalesItemLineDetail": {'+
                '              "ItemRef": {'+
                '                "value": "36",'+
                '                "name": "Events Income"'+
                '              },'+
                '              "ClassRef": {'+
                '                "value": "1400000000000993207",'+
                '                "name": "17294 MeetGB"'+
                '              },'+
                '              "TaxCodeRef": {'+
                '                "value": "42"'+
                '              }'+
                '            }'+
                '          },'+
                '          {'+
                '            "Amount": 22087.74,'+
                '            "DetailType": "SubTotalLineDetail",'+
                '            "SubTotalLineDetail": {}'+
                '          }'+
                '        ],'+
                '        "TxnTaxDetail": {'+
                '          "TotalTax": 4417.55,'+
                '          "TaxLine": ['+
                '            {'+
                '              "Amount": 4417.55,'+
                '              "DetailType": "TaxLineDetail",'+
                '              "TaxLineDetail": {'+
                '                "TaxRateRef": {'+
                '                  "value": "79"'+
                '                },'+
                '                "PercentBased": true,'+
                '                "TaxPercent": 20,'+
                '                "NetAmountTaxable": 22087.74'+
                '              }'+
                '            }'+
                '          ]'+
                '        },'+
                '        "CustomerRef": {'+
                '          "value": "1325",'+
                '          "name": "17294 MeetGREAT Event"'+
                '        },'+
                '        "CustomerMemo": {'+
                '          "value": "MeetGREAT Event\\nJob no 17294\\nEvent 16th -20th April 2018"'+
                '        },'+
                '        "BillAddr": {'+
                '          "Id": "1212",'+
                '          "Line1": "Calders",'+
                '          "Line2": "4 Woodside Court",'+
                '          "Line3": "Clayton Wood Rise",'+
                '          "Line4": "Leeds",'+
                '          "Line5": "LS16 6RF"'+
                '        },'+
                '        "GlobalTaxCalculation": "TaxExcluded",'+
                '        "TotalAmt": 26505.29,'+
                '        "PrintStatus": "NotSet",'+
                '        "EmailStatus": "NotSet",'+
                '        "BillEmail": {'+
                '          "Address": "tracy@calders.org.uk"'+
                '        },'+
                '        "Balance": 0'+
                '      },'+
                '      {'+
                '        "RemainingCredit": 0,'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "19549",'+
                '        "SyncToken": "2",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-05-15T02:52:31-07:00",'+
                '          "LastUpdatedTime": "2018-07-11T06:30:53-07:00"'+
                '        },'+
                '        "CustomField": ['+
                '          {'+
                '            "DefinitionId": "1",'+
                '            "Name": "Schedule",'+
                '            "Type": "StringType",'+
                '            "StringValue": "SI01045"'+
                '          },'+
                '          {'+
                '            "DefinitionId": "2",'+
                '            "Name": "Your Ref",'+
                '            "Type": "StringType",'+
                '            "StringValue": "CCS323172/1"'+
                '          },'+
                '          {'+
                '            "DefinitionId": "3",'+
                '            "Name": "Our Ref",'+
                '            "Type": "StringType",'+
                '            "StringValue": "18008"'+
                '          }'+
                '        ],'+
                '        "DocNumber": "1106",'+
                '        "TxnDate": "2018-05-15",'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "Line": ['+
                '          {'+
                '            "Id": "1",'+
                '            "LineNum": 1,'+
                '            "Description": "Commission re invoice 1105\\nRE Visit Britain\\nBooking ref : CCS323172/1\\nFAO: Tracy Iley",'+
                '            "Amount": 3009.98,'+
                '            "DetailType": "SalesItemLineDetail",'+
                '            "SalesItemLineDetail": {'+
                '              "ItemRef": {'+
                '                "value": "36",'+
                '                "name": "Events Income"'+
                '              },'+
                '              "ClassRef": {'+
                '                "value": "1400000000000993368",'+
                '                "name": "18008 Educational Programme at MeetGB 2018"'+
                '              },'+
                '              "TaxCodeRef": {'+
                '                "value": "42"'+
                '              }'+
                '            }'+
                '          },'+
                '          {'+
                '            "Amount": 3009.98,'+
                '            "DetailType": "SubTotalLineDetail",'+
                '            "SubTotalLineDetail": {}'+
                '          }'+
                '        ],'+
                '        "TxnTaxDetail": {'+
                '          "TotalTax": 602.0,'+
                '          "TaxLine": ['+
                '            {'+
                '              "Amount": 602.0,'+
                '              "DetailType": "TaxLineDetail",'+
                '              "TaxLineDetail": {'+
                '                "TaxRateRef": {'+
                '                  "value": "79"'+
                '                },'+
                '                "PercentBased": true,'+
                '                "TaxPercent": 20,'+
                '                "NetAmountTaxable": 3009.98'+
                '              }'+
                '            }'+
                '          ]'+
                '        },'+
                '        "CustomerRef": {'+
                '          "value": "1394",'+
                '          "name": "18008 Educational Programme at MeetGB 2018"'+
                '        },'+
                '        "CustomerMemo": {'+
                '          "value": "Educational Programme at MeetGB 2018\\nJob no 18008\\nEvent 19th-20th April 2018"'+
                '        },'+
                '        "BillAddr": {'+
                '          "Id": "1214",'+
                '          "Line1": "Calders",'+
                '          "Line2": "4 Woodside Court",'+
                '          "Line3": "Clayton Wood Rise",'+
                '          "Line4": "Leeds",'+
                '          "Line5": "LS16 6RF"'+
                '        },'+
                '        "GlobalTaxCalculation": "TaxExcluded",'+
                '        "TotalAmt": 3611.98,'+
                '        "PrintStatus": "NotSet",'+
                '        "EmailStatus": "NeedToSend",'+
                '        "BillEmail": {'+
                '          "Address": "tracy@calders.org.uk"'+
                '        },'+
                '        "Balance": 0,'+
                '        "DeliveryInfo": {'+
                '          "DeliveryType": "Email"'+
                '        }'+
                '      },'+
                '      {'+
                '        "RemainingCredit": 0,'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "19071",'+
                '        "SyncToken": "4",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-04-25T07:13:42-07:00",'+
                '          "LastUpdatedTime": "2018-05-08T04:57:07-07:00"'+
                '        },'+
                '        "CustomField": ['+
                '          {'+
                '            "DefinitionId": "1",'+
                '            "Name": "Schedule",'+
                '            "Type": "StringType",'+
                '            "StringValue": "SI01050"'+
                '          },'+
                '          {'+
                '            "DefinitionId": "2",'+
                '            "Name": "Your Ref",'+
                '            "Type": "StringType",'+
                '            "StringValue": "Sage inv 2111"'+
                '          },'+
                '          {'+
                '            "DefinitionId": "3",'+
                '            "Name": "Our Ref",'+
                '            "Type": "StringType",'+
                '            "StringValue": "18018"'+
                '          }'+
                '        ],'+
                '        "DocNumber": "1054",'+
                '        "TxnDate": "2018-03-31",'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "Line": ['+
                '          {'+
                '            "Id": "1",'+
                '            "LineNum": 1,'+
                '            "Description": "Commission",'+
                '            "Amount": 700.39,'+
                '            "DetailType": "SalesItemLineDetail",'+
                '            "SalesItemLineDetail": {'+
                '              "ItemRef": {'+
                '                "value": "38",'+
                '                "name": "Opening Balances"'+
                '              },'+
                '              "TaxCodeRef": {'+
                '                "value": "46"'+
                '              }'+
                '            }'+
                '          },'+
                '          {'+
                '            "Amount": 700.39,'+
                '            "DetailType": "SubTotalLineDetail",'+
                '            "SubTotalLineDetail": {}'+
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
                '                  "value": "87"'+
                '                },'+
                '                "PercentBased": true,'+
                '                "TaxPercent": 0,'+
                '                "NetAmountTaxable": 700.39'+
                '              }'+
                '            }'+
                '          ]'+
                '        },'+
                '        "CustomerRef": {'+
                '          "value": "1328",'+
                '          "name": "18014 ADCN Celebration Event"'+
                '        },'+
                '        "BillAddr": {'+
                '          "Id": "1091",'+
                '          "Line1": "Calders",'+
                '          "Line2": "4 Woodside Court",'+
                '          "Line3": "Clayton Wood Rise",'+
                '          "Line4": "Leeds",'+
                '          "Line5": "LS16 6RF"'+
                '        },'+
                '        "GlobalTaxCalculation": "TaxExcluded",'+
                '        "TotalAmt": 700.39,'+
                '        "PrintStatus": "NotSet",'+
                '        "EmailStatus": "NotSet",'+
                '        "BillEmail": {'+
                '          "Address": "tracy@calders.org.uk"'+
                '        },'+
                '        "Balance": 0'+
                '      },'+
                '      {'+
                '        "RemainingCredit": 0,'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "19070",'+
                '        "SyncToken": "1",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-04-25T07:07:34-07:00",'+
                '          "LastUpdatedTime": "2018-05-08T04:57:07-07:00"'+
                '        },'+
                '        "CustomField": ['+
                '          {'+
                '            "DefinitionId": "1",'+
                '            "Name": "Schedule",'+
                '            "Type": "StringType",'+
                '            "StringValue": "SI01063"'+
                '          },'+
                '          {'+
                '            "DefinitionId": "2",'+
                '            "Name": "Your Ref",'+
                '            "Type": "StringType",'+
                '            "StringValue": "Sage CN 2112"'+
                '          },'+
                '          {'+
                '            "DefinitionId": "3",'+
                '            "Name": "Our Ref",'+
                '            "Type": "StringType",'+
                '            "StringValue": "18038"'+
                '          }'+
                '        ],'+
                '        "DocNumber": "1053",'+
                '        "TxnDate": "2018-03-31",'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "Line": ['+
                '          {'+
                '            "Id": "1",'+
                '            "LineNum": 1,'+
                '            "Description": "Commission re invoice 1052",'+
                '            "Amount": 989.54,'+
                '            "DetailType": "SalesItemLineDetail",'+
                '            "SalesItemLineDetail": {'+
                '              "ItemRef": {'+
                '                "value": "38",'+
                '                "name": "Opening Balances"'+
                '              },'+
                '              "TaxCodeRef": {'+
                '                "value": "46"'+
                '              }'+
                '            }'+
                '          },'+
                '          {'+
                '            "Amount": 989.54,'+
                '            "DetailType": "SubTotalLineDetail",'+
                '            "SubTotalLineDetail": {}'+
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
                '                  "value": "87"'+
                '                },'+
                '                "PercentBased": true,'+
                '                "TaxPercent": 0,'+
                '                "NetAmountTaxable": 989.54'+
                '              }'+
                '            }'+
                '          ]'+
                '        },'+
                '        "CustomerRef": {'+
                '          "value": "1327",'+
                '          "name": "18038 ESFA (Fire & Police) Employer Event"'+
                '        },'+
                '        "BillAddr": {'+
                '          "Id": "1090",'+
                '          "Line1": "Calders",'+
                '          "Line2": "4 Woodside Court",'+
                '          "Line3": "Clayton Wood Rise",'+
                '          "Line4": "Leeds",'+
                '          "Line5": "LS16 6RF"'+
                '        },'+
                '        "GlobalTaxCalculation": "TaxExcluded",'+
                '        "TotalAmt": 989.54,'+
                '        "PrintStatus": "NotSet",'+
                '        "EmailStatus": "NotSet",'+
                '        "BillEmail": {'+
                '          "Address": "tracy@calders.org.uk"'+
                '        },'+
                '        "Balance": 0'+
                '      },'+
                '      {'+
                '        "RemainingCredit": 0,'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "19068",'+
                '        "SyncToken": "1",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-04-25T07:01:24-07:00",'+
                '          "LastUpdatedTime": "2018-05-08T04:57:07-07:00"'+
                '        },'+
                '        "CustomField": ['+
                '          {'+
                '            "DefinitionId": "1",'+
                '            "Name": "Schedule",'+
                '            "Type": "StringType",'+
                '            "StringValue": "SI01035"'+
                '          },'+
                '          {'+
                '            "DefinitionId": "2",'+
                '            "Name": "Your Ref",'+
                '            "Type": "StringType",'+
                '            "StringValue": "Sage CN 2113"'+
                '          },'+
                '          {'+
                '            "DefinitionId": "3",'+
                '            "Name": "Our Ref",'+
                '            "Type": "StringType",'+
                '            "StringValue": "17640"'+
                '          }'+
                '        ],'+
                '        "DocNumber": "1051",'+
                '        "TxnDate": "2018-03-31",'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "Line": ['+
                '          {'+
                '            "Id": "1",'+
                '            "LineNum": 1,'+
                '            "Description": "Commission re invoice 1050",'+
                '            "Amount": 1804.32,'+
                '            "DetailType": "SalesItemLineDetail",'+
                '            "SalesItemLineDetail": {'+
                '              "ItemRef": {'+
                '                "value": "38",'+
                '                "name": "Opening Balances"'+
                '              },'+
                '              "TaxCodeRef": {'+
                '                "value": "46"'+
                '              }'+
                '            }'+
                '          },'+
                '          {'+
                '            "Amount": 1804.32,'+
                '            "DetailType": "SubTotalLineDetail",'+
                '            "SubTotalLineDetail": {}'+
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
                '                  "value": "87"'+
                '                },'+
                '                "PercentBased": true,'+
                '                "TaxPercent": 0,'+
                '                "NetAmountTaxable": 1804.32'+
                '              }'+
                '            }'+
                '          ]'+
                '        },'+
                '        "CustomerRef": {'+
                '          "value": "1326",'+
                '          "name": "17640 External Stakeholder Event, March 2018"'+
                '        },'+
                '        "BillAddr": {'+
                '          "Id": "1088",'+
                '          "Line1": "Calders",'+
                '          "Line2": "4 Woodside Court",'+
                '          "Line3": "Clayton Wood Rise",'+
                '          "Line4": "Leeds",'+
                '          "Line5": "LS16 6RF"'+
                '        },'+
                '        "GlobalTaxCalculation": "TaxExcluded",'+
                '        "TotalAmt": 1804.32,'+
                '        "PrintStatus": "NotSet",'+
                '        "EmailStatus": "NotSet",'+
                '        "BillEmail": {'+
                '          "Address": "tracy@calders.org.uk"'+
                '        },'+
                '        "Balance": 0'+
                '      },'+
                '      {'+
                '        "RemainingCredit": 0,'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "19066",'+
                '        "SyncToken": "3",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-04-25T06:12:37-07:00",'+
                '          "LastUpdatedTime": "2018-05-03T03:20:37-07:00"'+
                '        },'+
                '        "CustomField": ['+
                '          {'+
                '            "DefinitionId": "1",'+
                '            "Name": "Schedule",'+
                '            "Type": "StringType",'+
                '            "StringValue": "SI00875"'+
                '          },'+
                '          {'+
                '            "DefinitionId": "2",'+
                '            "Name": "Your Ref",'+
                '            "Type": "StringType",'+
                '            "StringValue": "Sage CN 2114"'+
                '          },'+
                '          {'+
                '            "DefinitionId": "3",'+
                '            "Name": "Our Ref",'+
                '            "Type": "StringType",'+
                '            "StringValue": "17294"'+
                '          }'+
                '        ],'+
                '        "DocNumber": "1049",'+
                '        "TxnDate": "2018-03-31",'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "Line": ['+
                '          {'+
                '            "Id": "3",'+
                '            "LineNum": 1,'+
                '            "Description": "Commision re invoice 1048",'+
                '            "Amount": 357.0,'+
                '            "DetailType": "SalesItemLineDetail",'+
                '            "SalesItemLineDetail": {'+
                '              "ItemRef": {'+
                '                "value": "38",'+
                '                "name": "Opening Balances"'+
                '              },'+
                '              "TaxCodeRef": {'+
                '                "value": "46"'+
                '              }'+
                '            }'+
                '          },'+
                '          {'+
                '            "Amount": 357.0,'+
                '            "DetailType": "SubTotalLineDetail",'+
                '            "SubTotalLineDetail": {}'+
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
                '                  "value": "87"'+
                '                },'+
                '                "PercentBased": true,'+
                '                "TaxPercent": 0,'+
                '                "NetAmountTaxable": 357.0'+
                '              }'+
                '            }'+
                '          ]'+
                '        },'+
                '        "CustomerRef": {'+
                '          "value": "1325",'+
                '          "name": "17294 MeetGREAT Event"'+
                '        },'+
                '        "BillAddr": {'+
                '          "Id": "1086",'+
                '          "Line1": "Calders",'+
                '          "Line2": "4 Woodside Court",'+
                '          "Line3": "Clayton Wood Rise",'+
                '          "Line4": "Leeds",'+
                '          "Line5": "LS16 6RF"'+
                '        },'+
                '        "GlobalTaxCalculation": "TaxExcluded",'+
                '        "TotalAmt": 357.0,'+
                '        "PrintStatus": "NotSet",'+
                '        "EmailStatus": "NotSet",'+
                '        "BillEmail": {'+
                '          "Address": "tracy@calders.org.uk"'+
                '        },'+
                '        "Balance": 0'+
                '      }'+
                '    ],'+
                '    "startPosition": 1,'+
                '    "maxResults": 39'+
                '  },'+
                '  "time": "2018-11-09T06:06:28.601-08:00"'+
                '}';
        JSONParserQBOCreditMemoFlow obj = JSONParserQBOCreditMemoFlow.parse(json);
        System.assert(obj != null);
    }

}