/**
 * Created by Ronan Williams on 14/11/2018.
 */

global with sharing class QuickbooksClassQueryMock implements HttpCalloutMock{

    global  HttpResponse respond(HttpRequest req) {
        // mock response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{'+
                '  "QueryResponse": {'+
                '    "Class": ['+
                '      {'+
                '        "Name": "12345 Test Opp",'+
                '        "SubClass": false,'+
                '        "FullyQualifiedName": "12345 Test Opp",'+
                '        "Active": true,'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "5000000000000089619",'+
                '        "SyncToken": "0",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-11-14T09:19:02-08:00",'+
                '          "LastUpdatedTime": "2018-11-14T09:19:02-08:00"'+
                '        }'+
                '      },'+
                '      {'+
                '        "Name": "54321 Test Opp",'+
                '        "SubClass": false,'+
                '        "FullyQualifiedName": "54321 Test Opp",'+
                '        "Active": true,'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "5000000000000089080",'+
                '        "SyncToken": "0",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-11-12T03:12:18-08:00",'+
                '          "LastUpdatedTime": "2018-11-12T03:12:18-08:00"'+
                '        }'+
                '      }'+
                '    ],'+
                '    "startPosition": 1,'+
                '    "maxResults": 2,'+
                '    "totalCount": 2'+
                '  },'+
                '  "time": "2018-11-14T09:20:45.129-08:00"'+
                '}');

        res.setStatusCode(200);

        return res;

    }

}