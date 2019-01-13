/**
 * Created by Ronan Williams on 18/06/2018.
 */
@isTest
public class JSONParserQBOBudgetTest {

    static testMethod void testParse() {
        String json=		'{'+
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
            '            "BudgetDate": "2018-11-01",'+
            '            "Amount": 100,'+
            '            "AccountRef": {'+
            '              "value": "716",'+
            '              "name": "Private Health Insurance & Staff Healthcare"'+
            '            }'+
            '          },'+
            '          {'+
            '            "BudgetDate": "2019-01-01",'+
            '            "Amount": 100,'+
            '            "AccountRef": {'+
            '              "value": "727",'+
            '              "name": "Property insurance"'+
            '            }'+
            '          },'+
            '          {'+
            '            "BudgetDate": "2019-02-01",'+
            '            "Amount": 100,'+
            '            "AccountRef": {'+
            '              "value": "727",'+
            '              "name": "Property insurance"'+
            '            }'+
            '          },'+
            '          {'+
            '            "BudgetDate": "2018-10-01",'+
            '            "Amount": 0,'+
            '            "AccountRef": {'+
            '              "value": "797",'+
            '              "name": "Exchange Rate Variance"'+
            '            }'+
            '          },'+
            '          {'+
            '            "BudgetDate": "2018-11-01",'+
            '            "Amount": 100,'+
            '            "AccountRef": {'+
            '              "value": "797",'+
            '              "name": "Exchange Rate Variance"'+
            '            }'+
            '          },'+
            '          {'+
            '            "BudgetDate": "2018-12-01",'+
            '            "Amount": 0,'+
            '            "AccountRef": {'+
            '              "value": "797",'+
            '              "name": "Exchange Rate Variance"'+
            '            }'+
            '          },'+
            '          {'+
            '            "BudgetDate": "2018-08-01",'+
            '            "Amount": 100,'+
            '            "AccountRef": {'+
            '              "unexpectedField": "unexpectedValue",'+
            '              "value": "798",'+
            '              "name": "Bank Charges - Current Account"'+
            '            }'+
            '          },'+
            '          {'+
            '            "unexpectedField": "unexpectedValue",'+
            '            "BudgetDate": "2019-02-01",'+
            '            "Amount": 0,'+
            '            "AccountRef": {'+
            '              "value": "798",'+
            '              "name": "Bank Charges - Current Account"'+
            '            }'+
            '          },'+
            '          {'+
            '            "BudgetDate": "2019-03-01",'+
            '            "Amount": 0,'+
            '            "AccountRef": {'+
            '              "value": "798",'+
            '              "name": "Bank Charges - Current Account"'+
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
            '';
        JSONParserQBOBudget obj = JSONParserQBOBudget.parse(json);
        System.assert(obj != null);

    }


}