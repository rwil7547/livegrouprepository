/**
 * Created by Ronan Williams on 20/06/2018.
 */

@IsTest
public class JSONParserQBOCurrentAccountTest {

    static testMethod void testParse() {
        String json = '{' +
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
                '}';
        JSONParserQBOCurrentAccount obj = JSONParserQBOCurrentAccount.parse(json);
        System.assert(obj != null);
    }
}