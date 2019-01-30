
    /**
 * Created by Ronan Williams on 20/06/2018.
 */
@isTest
global class QBBudgetListMock implements HttpCalloutMock {

    global HttpResponse respond(HttpRequest req) {

// mock response
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setBody('{' +
    '  "QueryResponse": {' +
    '    "Budget": [' +
    '      {' +
    '        "Name": "FirstBudget",' +
    '        "StartDate": "2018-05-10",' +
    '        "EndDate": 995.0,' +
    '        "domain": "QBO",' +
    '        "sparse": false,' +
    '        "Id": "19748",' +
    '        "MetaData": {' +
    '          "CreateTime": "2018-05-16T05:22:38-07:00",' +
    '          "LastUpdatedTime": "2018-05-16T05:22:38-07:00"' +
    '        },' +
    '      }' +
    '    ],' +
    '    "startPosition": 1,' +
    '    "maxResults": 28,' +
    '    "totalCount": 28' +
    '  },' +
    '  "time": "2018-06-20T04:21:40.128-07:00"' +
    '}');
    res.setStatusCode(200);
    return res;
}
}