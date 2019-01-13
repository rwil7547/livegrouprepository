/**
 * Created by Ronan Williams on 18/06/2018.
 */

@isTest
global class QBOBudgetMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {

        // mock response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{'+
            '  "QueryResponse": {'+
            '    "Budget": ['+
            '      {'+
            '        "Name": "FY18/19 Control Budget",'+
            '        "StartDate": "2018-04-01",'+
            '        "EndDate": "2019-03-31",'+
            '        "BudgetType": "ProfitAndLoss",'+
            '        "BudgetEntryType": "Monthly",'+
            '        "Active": true,'+
            '        "BudgetDetail": ['+
            '          {'+
            '            "BudgetDate": "2018-04-01",'+
            '            "Amount": 468520.44,'+
            '            "AccountRef": {'+
            '              "value": "645",'+
            '              "name": "Events Revenue"'+
            '            }'+
            '          },'+
            '          {'+
            '            "BudgetDate": "2018-05-01",'+
            '            "Amount": 100,'+
            '            "AccountRef": {'+
            '              "value": "712",'+
            '              "name": "Employers National Insurance"'+
            '            }'+
            '          },'+
            '          {'+
            '            "BudgetDate": "2018-06-01",'+
            '            "Amount": 100,'+
            '            "AccountRef": {'+
            '              "value": "716",'+
            '              "name": "Private Health Insurance & Staff Healthcare"'+
            '            }'+
            '          },'+
            '          {'+
            '            "BudgetDate": "2019-06-01",'+
            '            "Amount": 100,'+
            '            "AccountRef": {'+
            '              "value": "727",'+
            '              "name": "Property insurance"'+
            '            }'+
            '          }'+
            '        ],'+
            '        "domain": "QBO",'+
            '        "sparse": false,'+
            '        "Id": "7",'+
            '        "SyncToken": "434",'+
            '        "MetaData": {'+
            '          "CreateTime": "2018-06-13T03:55:40-07:00",'+
            '          "LastUpdatedTime": "2018-06-13T06:25:51-07:00"'+
            '        }'+
            '      }'+
            '    ],'+
            '    "startPosition": 1,'+
            '    "maxResults": 1,'+
            '    "totalCount": 1'+
            '  },'+
            '  "time": "2018-06-18T05:48:59.034-07:00"'+
            '}'+
            '');
            res.setStatusCode(200);
            return res;
        }

}