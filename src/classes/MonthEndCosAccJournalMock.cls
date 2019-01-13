/**
 * Created by Ronan Williams on 07/12/2018.
 */

@IsTest
global class MonthEndCosAccJournalMock implements HttpCalloutMock {

    global HttpResponse respond(HttpRequest req) {

        // mock response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{' +
                '  "QueryResponse": {' +
                '    "JournalEntry": [' +
                '      {' +
                '        "Adjustment": false,' +
                '        "TotalAmt": 1000,' +
                '        "domain": "QBO",' +
                '        "sparse": false,' +
                '        "Id": "22844",' +
                '        "SyncToken": "1",' +
                '        "MetaData": {' +
                '          "CreateTime": "2018-06-22T07:28:53-07:00",' +
                '          "LastUpdatedTime": "2018-06-22T07:32:44-07:00"' +
                '        },' +
                '        "DocNumber": "P0xx xx Cos acc R",' +
                '        "TxnDate": "' + String.valueOf(Date.today().toStartOfMonth().addMonths(-1)).substring(0, 10) + '",' +
                '        "CurrencyRef": {' +
                '          "value": "GBP",' +
                '          "name": "British Pound Sterling"' +
                '        },' +
                '        "Line": [' +
                '          {' +
                '            "Id": "0",' +
                '            "Description": "COS CREDIT",' +
                '            "Amount": 500,' +
                '            "DetailType": "JournalEntryLineDetail",' +
                '            "JournalEntryLineDetail": {' +
                '              "PostingType": "Debit",' +
                '              "AccountRef": {' +
                '                "value": "645",' +
                '                "name": "5000 Cost of sales:Events COS"' +
                '              },' +
                '              "ClassRef": {' +
                '                "value": "1111",' +
                '                "name": "TEST JOB NO"' +
                '              }' +
                '            }' +
                '          },' +
                '          {' +
                '            "Id": "1",' +
                '            "Description": "BAL SHEET DEBIT",' +
                '            "Amount": 1000,' +
                '            "DetailType": "JournalEntryLineDetail",' +
                '            "JournalEntryLineDetail": {' +
                '              "PostingType": "Credit",' +
                '              "AccountRef": {' +
                '                "value": "685",' +
                '                "name": "2112 COS Accrual"' +
                '              },' +
                '              "ClassRef": {' +
                '                "value": "1111",' +
                '                "name": "TEST JOB NO"' +
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