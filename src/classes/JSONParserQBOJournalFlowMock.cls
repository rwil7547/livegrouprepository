/**
 * Created by Ronan Williams on 20/06/2018.
 */
@IsTest
global class JSONParserQBOJournalFlowMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {

// mock response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{' +
                '  "QueryResponse": {' +
                '    "JournalEntry": [' +
                '      {' +
                '        "Adjustment": false,' +
                '        "TotalAmt": 158978.2,' +
                '        "domain": "QBO",' +
                '        "sparse": false,' +
                '        "Id": "22607",' + // id used in callout
                '        "SyncToken": "1",' +
                '        "MetaData": {' +
                '          "CreateTime": "2018-06-22T07:28:53-07:00",' +
                '          "LastUpdatedTime": "2018-06-22T07:32:44-07:00"' +
                '        },' +
                '        "DocNumber": "P07 Oct 18 Sales AcR",' +
                '        "TxnDate": "2018-06-22",' +
                '        "CurrencyRef": {' +
                '          "value": "GBP",' +
                '          "name": "British Pound Sterling"' +
                '        },' +
                '        "Line": [' +
                '          {' +
                '            "Id": "0",' +
                '            "Description": "P07 Oct 18 Sales AcR",' +
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
                '      }' +
                '    ],'+
                '    "startPosition": 1,'+
                '    "maxResults": 2,'+
                '    "totalCount": 2'+
                '  },'+
                '  "time": "2018-06-26T03:51:06.275-07:00"'+
                '}');
        res.setStatusCode(200);
        return res;
    }
}