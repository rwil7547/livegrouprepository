/**
 * Created by Ronan Williams on 19/05/2019.
 */
@IsTest
public class JSONParserQBOAccountTest {
    static testMethod void testParse() {
        String json=		'{'+
                '  "QueryResponse": {'+
                '    "Account": ['+
                '      {'+
                '        "Name": "Accrued Income",'+
                '        "SubAccount": false,'+
                '        "FullyQualifiedName": "Accrued Income",'+
                '        "Active": true,'+
                '        "Classification": "Asset",'+
                '        "AccountType": "Other Current Asset",'+
                '        "AccountSubType": "AllowanceForBadDebts",'+
                '        "AcctNum": "2110",'+
                '        "CurrentBalance": 48075.48,'+
                '        "CurrentBalanceWithSubAccounts": 48075.48,'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "687",'+
                '        "SyncToken": "1",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-04-25T05:06:30-07:00",'+
                '          "LastUpdatedTime": "2019-05-14T01:50:15-07:00"'+
                '        }'+
                '      },'+
                '      {'+
                '        "Name": "Office Equipment Depreciation",'+
                '        "SubAccount": true,'+
                '        "ParentRef": {'+
                '          "value": "786"'+
                '        },'+
                '        "FullyQualifiedName": "Depreciation / Amortisation:Office Equipment Depreciation",'+
                '        "Active": true,'+
                '        "Classification": "Expense",'+
                '        "AccountType": "Other Expense",'+
                '        "AccountSubType": "OtherMiscellaneousExpense",'+
                '        "AcctNum": "8104",'+
                '        "CurrentBalance": 0,'+
                '        "CurrentBalanceWithSubAccounts": 0,'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "790",'+
                '        "SyncToken": "1",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-04-25T05:06:40-07:00",'+
                '          "LastUpdatedTime": "2018-10-12T21:59:40-07:00"'+
                '        }'+
                '      },'+
                '      {'+
                '        "Name": "Property Depreciation",'+
                '        "SubAccount": true,'+
                '        "ParentRef": {'+
                '          "value": "786"'+
                '        },'+
                '        "FullyQualifiedName": "Depreciation / Amortisation:Property Depreciation",'+
                '        "Active": true,'+
                '        "Classification": "Expense",'+
                '        "AccountType": "Other Expense",'+
                '        "AccountSubType": "OtherMiscellaneousExpense",'+
                '        "AcctNum": "8100",'+
                '        "CurrentBalance": 0,'+
                '        "CurrentBalanceWithSubAccounts": 0,'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "800",'+
                '        "SyncToken": "0",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-04-25T07:19:55-07:00",'+
                '          "LastUpdatedTime": "2018-10-12T21:59:40-07:00"'+
                '        }'+
                '      },'+
                '      {'+
                '        "Name": "Vehicle Depreciation",'+
                '        "SubAccount": true,'+
                '        "ParentRef": {'+
                '          "value": "786"'+
                '        },'+
                '        "FullyQualifiedName": "Depreciation / Amortisation:Vehicle Depreciation",'+
                '        "Active": true,'+
                '        "Classification": "Expense",'+
                '        "AccountType": "Other Expense",'+
                '        "AccountSubType": "OtherMiscellaneousExpense",'+
                '        "AcctNum": "8103",'+
                '        "CurrentBalance": 0,'+
                '        "CurrentBalanceWithSubAccounts": 0,'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "789",'+
                '        "SyncToken": "1",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-04-25T05:06:40-07:00",'+
                '          "LastUpdatedTime": "2018-10-12T21:59:40-07:00"'+
                '        }'+
                '      },'+
                '      {'+
                '        "Name": "Legal Fees",'+
                '        "SubAccount": true,'+
                '        "ParentRef": {'+
                '          "value": "771"'+
                '        },'+
                '        "FullyQualifiedName": "Legal & Professional Fees:Legal Fees",'+
                '        "Active": true,'+
                '        "Classification": "Expense",'+
                '        "AccountType": "Expense",'+
                '        "AccountSubType": "LegalProfessionalFees",'+
                '        "AcctNum": "7800",'+
                '        "CurrentBalance": 0,'+
                '        "CurrentBalanceWithSubAccounts": 0,'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "772",'+
                '        "SyncToken": "1",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-04-25T05:06:38-07:00",'+
                '          "LastUpdatedTime": "2018-10-12T21:59:40-07:00"'+
                '        }'+
                '      },'+
                '      {'+
                '        "Name": "Maintenance and Development of IP",'+
                '        "SubAccount": false,'+
                '        "FullyQualifiedName": "Maintenance and Development of IP",'+
                '        "Active": true,'+
                '        "Classification": "Expense",'+
                '        "AccountType": "Expense",'+
                '        "AccountSubType": "OfficeGeneralAdministrativeExpenses",'+
                '        "AcctNum": "7.7",'+
                '        "CurrentBalance": 0,'+
                '        "CurrentBalanceWithSubAccounts": 0,'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "769",'+
                '        "SyncToken": "2",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-04-25T05:06:38-07:00",'+
                '          "LastUpdatedTime": "2019-01-15T05:33:23-08:00"'+
                '        }'+
                '      },'+
                '      {'+
                '        "Name": "Maintenance of IP",'+
                '        "SubAccount": true,'+
                '        "ParentRef": {'+
                '          "value": "769"'+
                '        },'+
                '        "FullyQualifiedName": "Maintenance and Development of IP:Maintenance of IP",'+
                '        "Active": true,'+
                '        "Classification": "Expense",'+
                '        "AccountType": "Expense",'+
                '        "AccountSubType": "OfficeGeneralAdministrativeExpenses",'+
                '        "AcctNum": "7701",'+
                '        "CurrentBalance": 0,'+
                '        "CurrentBalanceWithSubAccounts": 0,'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "770",'+
                '        "SyncToken": "2",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-04-25T05:06:38-07:00",'+
                '          "LastUpdatedTime": "2019-01-15T05:30:42-08:00"'+
                '        }'+
                '      },'+
                '      {'+
                '        "Name": "Research & Development of IP",'+
                '        "SubAccount": true,'+
                '        "ParentRef": {'+
                '          "value": "769"'+
                '        },'+
                '        "Description": "Research & Development of IP",'+
                '        "FullyQualifiedName": "Maintenance and Development of IP:Research & Development of IP",'+
                '        "Active": true,'+
                '        "Classification": "Expense",'+
                '        "AccountType": "Expense",'+
                '        "AccountSubType": "OfficeGeneralAdministrativeExpenses",'+
                '        "AcctNum": "7702",'+
                '        "CurrentBalance": 0,'+
                '        "CurrentBalanceWithSubAccounts": 0,'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "828",'+
                '        "SyncToken": "0",'+
                '        "MetaData": {'+
                '          "CreateTime": "2019-01-15T05:33:23-08:00",'+
                '          "LastUpdatedTime": "2019-01-15T05:33:23-08:00"'+
                '        }'+
                '      },'+
                '      {'+
                '        "Name": "Management Fees",'+
                '        "SubAccount": false,'+
                '        "FullyQualifiedName": "Management Fees",'+
                '        "Active": true,'+
                '        "Classification": "Expense",'+
                '        "AccountType": "Expense",'+
                '        "AccountSubType": "OtherMiscellaneousServiceCost",'+
                '        "AcctNum": "6.1",'+
                '        "CurrentBalance": 0,'+
                '        "CurrentBalanceWithSubAccounts": 0,'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "720",'+
                '        "SyncToken": "2",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-04-25T05:06:33-07:00",'+
                '          "LastUpdatedTime": "2018-10-12T07:59:41-07:00"'+
                '        }'+
                '      },'+
                '      {'+
                '        "Name": "Management Fee Live Group",'+
                '        "SubAccount": true,'+
                '        "ParentRef": {'+
                '          "value": "720"'+
                '        },'+
                '        "FullyQualifiedName": "Management Fees:Management Fee Live Group",'+
                '        "Active": true,'+
                '        "Classification": "Expense",'+
                '        "AccountType": "Expense",'+
                '        "AccountSubType": "OtherMiscellaneousServiceCost",'+
                '        "AcctNum": "6100",'+
                '        "CurrentBalance": 0,'+
                '        "CurrentBalanceWithSubAccounts": 0,'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "795",'+
                '        "SyncToken": "1",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-04-25T05:16:54-07:00",'+
                '          "LastUpdatedTime": "2018-10-12T21:59:41-07:00"'+
                '        }'+
                '      },'+
                '      {'+
                '        "Name": "Payroll",'+
                '        "SubAccount": false,'+
                '        "FullyQualifiedName": "Payroll",'+
                '        "Active": true,'+
                '        "Classification": "Expense",'+
                '        "AccountType": "Expense",'+
                '        "AccountSubType": "PayrollExpenses",'+
                '        "AcctNum": "6.0",'+
                '        "CurrentBalance": 0,'+
                '        "CurrentBalanceWithSubAccounts": 0,'+
                '        "CurrencyRef": {'+
                '          "value": "GBP",'+
                '          "name": "British Pound Sterling"'+
                '        },'+
                '        "domain": "QBO",'+
                '        "sparse": false,'+
                '        "Id": "710",'+
                '        "SyncToken": "1",'+
                '        "MetaData": {'+
                '          "CreateTime": "2018-04-25T05:06:32-07:00",'+
                '          "LastUpdatedTime": "2018-10-17T04:11:34-07:00"'+
                '        }'+
                '      }'+
                '    ],'+
                '    "startPosition": 1,'+
                '    "maxResults": 100'+
                '  },'+
                '  "time": "2019-05-19T14:41:34.858-07:00"'+
                '}';
        JSONParserQBOAccount obj = JSONParserQBOAccount.parse(json);
        System.assert(obj != null);
    }


}