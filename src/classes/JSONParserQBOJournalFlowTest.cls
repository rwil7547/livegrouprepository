/**
 * Created by Ronan Williams on 26/06/2018.
 */

@IsTest
public class JSONParserQBOJournalFlowTest {

    static testMethod void testParse() {
        String json = '{' +
                '  "QueryResponse": {' +
                '    "JournalEntry": [' +
                '      {' +
                '        "Adjustment": false,' +
                '        "TotalAmt": 158978.2,' +
                '        "domain": "QBO",' +
                '        "sparse": false,' +
                '        "Id": "20276",' +
                '        "SyncToken": "1",' +
                '        "MetaData": {' +
                '          "CreateTime": "2018-06-22T07:28:53-07:00",' +
                '          "LastUpdatedTime": "2018-06-22T07:32:44-07:00"' +
                '        },' +
                '        "DocNumber": "Salary June 18",' +
                '        "TxnDate": "2018-06-22",' +
                '        "CurrencyRef": {' +
                '          "value": "GBP",' +
                '          "name": "British Pound Sterling"' +
                '        },' +
                '        "Line": [' +
                '          {' +
                '            "Id": "0",' +
                '            "Description": "Salary June 18",' +
                '            "Amount": 54095.73,' +
                '            "DetailType": "JournalEntryLineDetail",' +
                '            "JournalEntryLineDetail": {' +
                '              "PostingType": "Credit",' +
                '              "AccountRef": {' +
                '                "value": "694",' +
                '                "name": "2220 Net Wages"' +
                '              }' +
                '            }' +
                '          },' +
                '          {' +
                '            "Id": "1",' +
                '            "Description": "Salary June 18",' +
                '            "Amount": 496.0,' +
                '            "DetailType": "JournalEntryLineDetail",' +
                '            "JournalEntryLineDetail": {' +
                '              "PostingType": "Credit",' +
                '              "AccountRef": {' +
                '                "value": "695",' +
                '                "name": "2221 Benefits Control"' +
                '              }' +
                '            }' +
                '          },' +
                '          {' +
                '            "Id": "2",' +
                '            "Description": "Stuart B repay May c/cd",' +
                '            "Amount": 48.71,' +
                '            "DetailType": "JournalEntryLineDetail",' +
                '            "JournalEntryLineDetail": {' +
                '              "PostingType": "Credit",' +
                '              "AccountRef": {' +
                '                "value": "696",' +
                '                "name": "2222 Staff Receivables"' +
                '              }' +
                '            }' +
                '          },' +
                '          {' +
                '            "Id": "8",' +
                '            "Description": "Ronan W repay May c/cd",' +
                '            "Amount": 40.3,' +
                '            "DetailType": "JournalEntryLineDetail",' +
                '            "JournalEntryLineDetail": {' +
                '              "PostingType": "Credit",' +
                '              "AccountRef": {' +
                '                "value": "696",' +
                '                "name": "2222 Staff Receivables"' +
                '              }' +
                '            }' +
                '          },' +
                '          {' +
                '            "Id": "3",' +
                '            "Description": "Salary June 18",' +
                '            "Amount": 26000.43,' +
                '            "DetailType": "JournalEntryLineDetail",' +
                '            "JournalEntryLineDetail": {' +
                '              "PostingType": "Credit",' +
                '              "AccountRef": {' +
                '                "value": "692",' +
                '                "name": "2210 P.A.Y.E."' +
                '              }' +
                '            }' +
                '          },' +
                '          {' +
                '            "Id": "4",' +
                '            "Description": "Salary June 18",' +
                '            "Amount": 6003.71,' +
                '            "DetailType": "JournalEntryLineDetail",' +
                '            "JournalEntryLineDetail": {' +
                '              "PostingType": "Credit",' +
                '              "AccountRef": {' +
                '                "value": "697",' +
                '                "name": "2230 Pension Fund"' +
                '              }' +
                '            }' +
                '          },' +
                '          {' +
                '            "Id": "5",' +
                '            "Description": "Salary June 18",' +
                '            "Amount": 76060.02,' +
                '            "DetailType": "JournalEntryLineDetail",' +
                '            "JournalEntryLineDetail": {' +
                '              "PostingType": "Debit",' +
                '              "AccountRef": {' +
                '                "value": "711",' +
                '                "name": "6000 Payroll:Gross Salaries"' +
                '              }' +
                '            }' +
                '          },' +
                '          {' +
                '            "Id": "6",' +
                '            "Description": "Salary June 18",' +
                '            "Amount": 7851.55,' +
                '            "DetailType": "JournalEntryLineDetail",' +
                '            "JournalEntryLineDetail": {' +
                '              "PostingType": "Debit",' +
                '              "AccountRef": {' +
                '                "value": "712",' +
                '                "name": "6001 Payroll:Employers National Insurance"' +
                '              }' +
                '            }' +
                '          },' +
                '          {' +
                '            "Id": "7",' +
                '            "Description": "Salary June 18",' +
                '            "Amount": 2773.31,' +
                '            "DetailType": "JournalEntryLineDetail",' +
                '            "JournalEntryLineDetail": {' +
                '              "PostingType": "Debit",' +
                '              "AccountRef": {' +
                '                "value": "713",' +
                '                "name": "6002 Payroll:Pension Costs"' +
                '              }' +
                '            }' +
                '          }' +
                '        ],' +
                '        "TxnTaxDetail": {}' +
                '      },' +
                '      {' +
                '        "Adjustment": false,' +
                '        "TotalAmt": 53916.54,' +
                '        "domain": "QBO",' +
                '        "sparse": false,' +
                '        "Id": "19831",' +
                '        "SyncToken": "0",' +
                '        "MetaData": {' +
                '          "CreateTime": "2018-05-17T03:27:35-07:00",' +
                '          "LastUpdatedTime": "2018-05-17T03:27:35-07:00"' +
                '        },' +
                '        "DocNumber": "Salary Apr\'18", '+
                '        "TxnDate": "2018-04-30",'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "Line": ['+
                '          {'+
                '            "Id": "0",'+
                '            "Description": "Salary Apr\'18", '+
                '            "Amount": 42403.03,'+
                '            "DetailType": "JournalEntryLineDetail",'+
                '            "JournalEntryLineDetail": {'+
                '              "PostingType": "Credit",'+
                '              "AccountRef": {'+
                '                "value": "694",'+
                '                "name": "2220 Net Wages"'+
                '              }'+
                '            }'+
                '          },'+
                '          {'+
                '            "Id": "1",'+
                '            "Description": "Salary Apr\'18", '+
                '            "Amount": 124.0,'+
                '            "DetailType": "JournalEntryLineDetail",'+
                '            "JournalEntryLineDetail": {'+
                '              "PostingType": "Credit",'+
                '              "AccountRef": {'+
                '                "value": "695",'+
                '                "name": "2221 Benefits Control"'+
                '              }'+
                '            }'+
                '          },'+
                '          {'+
                '            "Id": "2",'+
                '            "Description": "Salary Apr\'18", '+
                '            "Amount": 119.57,'+
                '            "DetailType": "JournalEntryLineDetail",'+
                '            "JournalEntryLineDetail": {'+
                '              "PostingType": "Credit",'+
                '              "AccountRef": {'+
                '                "value": "696",'+
                '                "name": "2222 Staff Receivables"'+
                '              }'+
                '            }'+
                '          },'+
                '          {'+
                '            "Id": "3",'+
                '            "Description": "Salary Apr\'18",'+
                '            "Amount": 18584.64,'+
                '            "DetailType": "JournalEntryLineDetail",'+
                '            "JournalEntryLineDetail": {'+
                '              "PostingType": "Credit",'+
                '              "AccountRef": {'+
                '                "value": "692",'+
                '                "name": "2210 P.A.Y.E."'+
                '              }'+
                '            }'+
                '          },'+
                '          {'+
                '            "Id": "4",'+
                '            "Description": "Salary Apr\'18", '+
                '            "Amount": 5670.93,'+
                '            "DetailType": "JournalEntryLineDetail",'+
                '            "JournalEntryLineDetail": {'+
                '              "PostingType": "Credit",'+
                '              "AccountRef": {'+
                '                "value": "697",'+
                '                "name": "2230 Pension Fund"'+
                '              }'+
                '            }'+
                '          },'+
                '          {'+
                '            "Id": "5",'+
                '            "Description": "Salary Apr\'18", '+
                '            "Amount": 58595.57,'+
                '            "DetailType": "JournalEntryLineDetail",'+
                '            "JournalEntryLineDetail": {'+
                '              "PostingType": "Debit",'+
                '              "AccountRef": {'+
                '                "value": "711",'+
                '                "name": "6000 Payroll:Gross Salaries"'+
                '              }'+
                '            }'+
                '          },'+
                '          {'+
                '            "Id": "6",'+
                '            "Description": "Salary Apr\'18", '+
                '            "Amount": 5723.01,'+
                '            "DetailType": "JournalEntryLineDetail",'+
                '            "JournalEntryLineDetail": {'+
                '              "PostingType": "Debit",'+
                '              "AccountRef": {'+
                '                "value": "712",'+
                '                "name": "6001 Payroll:Employers National Insurance"'+
                '              }'+
                '            }'+
                '          },'+
                '          {'+
                '            "Id": "7",'+
                '            "Description": "Salary Apr\'18", '+
                '            "Amount": 2583.59,'+
                '            "DetailType": "JournalEntryLineDetail",'+
                '            "JournalEntryLineDetail": {'+
                '              "PostingType": "Debit",'+
                '              "AccountRef": {'+
                '                "value": "713",'+
                '                "name": "6002 Payroll:Pension Costs"'+
                '              }'+
                '            }'+
                '          }'+
                '        ],'+
                '        "TxnTaxDetail": {}'+
                '      }'+
                '    ],'+
                '    "startPosition": 1,'+
                '    "maxResults": 2,'+
                '    "totalCount": 2'+
                '  },'+
                '  "time": "2018-06-26T03:51:06.275-07:00"'+
                '}';
        JSONParserQBOJournalFlow obj = JSONParserQBOJournalFlow.parse(json);
        System.assert(obj != null);
    }
}