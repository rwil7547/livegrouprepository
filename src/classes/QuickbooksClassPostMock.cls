/**
 * Created by Ronan Williams on 14/11/2018.
 */

global with sharing class QuickbooksClassPostMock implements HttpCalloutMock{

    global  HTTPResponse respond(HTTPRequest req) {
    // mock response
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setBody('{'+
            '  "BatchItemResponse": ['+
            '    {'+
            '    "Class": {'+
            '       "Name": "11111 Test Opp",'+
            '       "SubClass": false,'+
            '       "FullyQualifiedName": "France",'+
            '       "Active": true,'+
            '       "domain": "QBO",'+
            '       "sparse": false,'+
            '       "Id": "5000000000000089619",'+
            '       "SyncToken": "0",'+
            '       "MetaData": {'+
            '           "CreateTime": "2018-11-14T09:19:02-08:00",'+
            '           "LastUpdatedTime": "2018-11-14T09:19:02-08:00"'+
            '       }'+
            '       },'+
            '      "bId": "bid2"'+
            '    }'+
            '  ],'+
            '  "time": "2018-04-24T09:20:12.374-07:00"'+
            '}');

    res.setStatusCode(200);

    return res;

    }
}