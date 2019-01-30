/**
 * Created by Ronan Williams on 20/06/2018.
 */
@isTest
global class JSONParserQBOCurrentAccountMock implements HttpCalloutMock {

    Integer statusCode;

    global HTTPResponse respond(HTTPRequest req) {

        if (statusCode == null){
            statusCode = 200;
        }

        // mock response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{' +
                '  "QueryResponse": {' +
                '    "Account": [' +
                '      {' +
                '        "Name": "Bank Current Account",' +
                '        "SubAccount": false,' +
                '        "FullyQualifiedName": "Bank Current Account",' +
                '        "Active": true,' +
                '        "Classification": "Asset",' +
                '        "AccountType": "Bank",' +
                '        "AccountSubType": "CashOnHand",' +
                '        "AcctNum": "1200",' +
                '        "CurrentBalance": 170314.55,' +
                '        "CurrentBalanceWithSubAccounts": 170314.55,' +
                '        "CurrencyRef": {' +
                '          "value": "GBP",' +
                '          "name": "British Pound Sterling"' +
                '        },' +
                '        "domain": "QBO",' +
                '        "sparse": false,' +
                '        "Id": "678",' +
                '        "SyncToken": "0",' +
                '        "MetaData": {' +
                '          "CreateTime": "2018-04-25T05:06:29-07:00",' +
                '          "LastUpdatedTime": "2018-06-20T02:41:22-07:00"' +
                '        }' +
                '      }' +
                '    ],' +
                '    "startPosition": 1,' +
                '    "maxResults": 1' +
                '  },' +
                '  "time": "2018-06-20T03:27:56.746-07:00"' +
                '}');
        res.setStatusCode(statusCode);
        return res;
    }

    global JSONParserQBOCurrentAccountMock(Integer statusCode){
        this.statusCode = statusCode;
    }

    global JSONParserQBOCurrentAccountMock(){
    }

}