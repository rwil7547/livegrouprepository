/**
 * Created by Ronan Williams on 20/06/2018.
 */
@isTest
global class JSONParserQBOInvoiceFlowMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {

        // mock response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{' +
                '  "QueryResponse": {' +
                '    "Invoice": [' +
                '      {' +
                '        "Deposit": 0,' +
                '        "AllowIPNPayment": false,' +
                '        "AllowOnlinePayment": false,' +
                '        "AllowOnlineCreditCardPayment": true,' +
                '        "AllowOnlineACHPayment": true,' +
                '        "domain": "QBO",' +
                '        "sparse": false,' +
                '        "Id": "19958",' +
                '        "SyncToken": "2",' +
                '        "MetaData": {' +
                '          "CreateTime": "2018-05-24T03:58:28-07:00",' +
                '          "LastUpdatedTime": "2018-05-24T04:04:09-07:00"' +
                '        },' +
                '        "CustomField": [' +
                '          {' +
                '            "DefinitionId": "1",' +
                '            "Name": "Schedule",' +
                '            "Type": "StringType",' +
                '            "StringValue": "SI01134"' +
                '          },' +
                '          {' +
                '            "DefinitionId": "2",' +
                '            "Name": "Your Ref",' +
                '            "Type": "StringType",' +
                '            "StringValue": "PO3001045"' +
                '          },' +
                '          {' +
                '            "DefinitionId": "3",' +
                '            "Name": "Our Ref",' +
                '            "Type": "StringType",' +
                '            "StringValue": "18151"' +
                '          }' +
                '        ],' +
                '        "DocNumber": "1110",' +
                '        "TxnDate": "2018-05-23",' +
                '        "CurrencyRef": {' +
                '          "value": "GBP",' +
                '          "name": "British Pound Sterling"' +
                '        },' +
                '        "LinkedTxn": [],' +
                '        "Line": [' +
                '          {' +
                '            "Id": "1",' +
                '            "LineNum": 1,' +
                '            "Description": "Request for payment for event servicesPO3001045FAO: Lisa Wand",' +
                '            "Amount": 210.0,' +
                '            "DetailType": "SalesItemLineDetail",' +
                '            "SalesItemLineDetail": {' +
                '              "ItemRef": {' +
                '                "value": "36",' +
                '                "name": "Events Income"' +
                '              },' +
                '              "TaxCodeRef": {' +
                '                "value": "42"' +
                '              }' +
                '            }' +
                '          },' +
                '          {' +
                '            "Amount": 210.0,' +
                '            "DetailType": "SubTotalLineDetail",' +
                '            "SubTotalLineDetail": {}' +
                '          }' +
                '        ],' +
                '        "TxnTaxDetail": {' +
                '          "TotalTax": 42.0,' +
                '          "TaxLine": [' +
                '            {' +
                '              "Amount": 42.0,' +
                '              "DetailType": "TaxLineDetail",' +
                '              "TaxLineDetail": {' +
                '                "TaxRateRef": {' +
                '                  "value": "79"' +
                '                },' +
                '                "PercentBased": true,' +
                '                "TaxPercent": 20,' +
                '                "NetAmountTaxable": 210.0' +
                '              }' +
                '            }' +
                '          ]' +
                '        },' +
                '        "CustomerRef": {' +
                '          "value": "1518",' +
                '          "name": "18151 Additional Award"' +
                '        },' +
                '        "CustomerMemo": {' +
                '          "value": "Additional AwardJob no 18151Event 30th April 2018"' +
                '        },' +
                '        "BillAddr": {' +
                '          "Id": "1262",' +
                '          "Line1": "Highways England",' +
                '          "Line2": "Bridge House",' +
                '          "Line3": "Walnut Tree Close",' +
                '          "Line4": "Guildford",' +
                '          "Line5": "GU1 4GA"' +
                '        },' +
                '        "SalesTermRef": {' +
                '          "value": "9"' +
                '        },' +
                '        "DueDate": "2018-05-23",' +
                '        "GlobalTaxCalculation": "TaxExcluded",' +
                '        "TotalAmt": 252.0,' +
                '        "PrintStatus": "NotSet",' +
                '        "EmailStatus": "NeedToSend",' +
                '        "BillEmail": {' +
                '          "Address": "FSPAYMENTS1@highwaysengland.co.uk"' +
                '        },' +
                '        "Balance": 252.0,' +
                '        "DeliveryInfo": {' +
                '          "DeliveryType": "Email"' +
                '        }' +
                '      },' +
                '      {' +
                '        "Deposit": 0,' +
                '        "AllowIPNPayment": false,' +
                '        "AllowOnlinePayment": false,' +
                '        "AllowOnlineCreditCardPayment": true,' +
                '        "AllowOnlineACHPayment": true,' +
                '        "domain": "QBO",' +
                '        "sparse": false,' +
                '        "Id": "19293",' +
                '        "SyncToken": "1",' +
                '        "MetaData": {' +
                '          "CreateTime": "2018-05-08T08:04:31-07:00",' +
                '          "LastUpdatedTime": "2018-05-08T08:05:31-07:00"' +
                '        },' +
                '        "CustomField": [' +
                '          {' +
                '            "DefinitionId": "1",' +
                '            "Name": "Schedule",' +
                '            "Type": "StringType",' +
                '            "StringValue": "SI01078"' +
                '          },' +
                '          {' +
                '            "DefinitionId": "2",' +
                '            "Name": "Your Ref",' +
                '            "Type": "StringType",' +
                '            "StringValue": "agreement number 4099834"' +
                '          },' +
                '          {' +
                '            "DefinitionId": "3",' +
                '            "Name": "Our Ref",' +
                '            "Type": "StringType",' +
                '            "StringValue": "18083"' +
                '          }' +
                '        ],' +
                '        "DocNumber": "1101",' +
                '        "TxnDate": "2018-05-08",' +
                '        "CurrencyRef": {' +
                '          "value": "GBP",' +
                '          "name": "British Pound Sterling"' +
                '        },' +
                '        "LinkedTxn": [],' +
                '        "Line": [' +
                '          {' +
                '            "Id": "1",' +
                '            "LineNum": 1,' +
                '            "Description": "Request for payment for event servicesagreement number 4099834FAO: Lorranine Willis",' +
                '            "Amount": 2450.0,' +
                '            "DetailType": "SalesItemLineDetail",' +
                '            "SalesItemLineDetail": {' +
                '              "ItemRef": {' +
                '                "value": "36",' +
                '                "name": "Events Income"' +
                '              },' +
                '              "TaxCodeRef": {' +
                '                "value": "42"' +
                '              }' +
                '            }' +
                '          },' +
                '          {' +
                '            "Amount": 2450.0,' +
                '            "DetailType": "SubTotalLineDetail",' +
                '            "SubTotalLineDetail": {}' +
                '          }' +
                '        ],' +
                '        "TxnTaxDetail": {' +
                '          "TotalTax": 490.0,' +
                '          "TaxLine": [' +
                '            {' +
                '              "Amount": 490.0,' +
                '              "DetailType": "TaxLineDetail",' +
                '              "TaxLineDetail": {' +
                '                "TaxRateRef": {' +
                '                  "value": "79"' +
                '                },' +
                '                "PercentBased": true,' +
                '                "TaxPercent": 20,' +
                '                "NetAmountTaxable": 2450.0' +
                '              }' +
                '            }' +
                '          ]' +
                '        },' +
                '        "CustomerRef": {' +
                '          "value": "1429",' +
                '          "name": "18083 Mobile Visitor Unit Branded materials"' +
                '        },' +
                '        "CustomerMemo": {' +
                '          "value": "Mobile Visitor Unit Branded materialsJob no 18083Event 16th  March 2018"' +
                '        },' +
                '        "BillAddr": {' +
                '          "Id": "1187",' +
                '          "Line1": "Highways England",' +
                '          "Line2": "Bridge House",' +
                '          "Line3": "Walnut Tree Close",' +
                '          "Line4": "Guildford",' +
                '          "Line5": "GU1 4GA"' +
                '        },' +
                '        "SalesTermRef": {' +
                '          "value": "9"' +
                '        },' +
                '        "DueDate": "2018-05-08",' +
                '        "GlobalTaxCalculation": "TaxExcluded",' +
                '        "TotalAmt": 2940.0,' +
                '        "PrintStatus": "NotSet",' +
                '        "EmailStatus": "NotSet",' +
                '        "BillEmail": {' +
                '          "Address": "Area6invoice@highwaysengland.co.uk"' +
                '        },' +
                '        "Balance": 2940.0' +
                '      },' +
                '      {' +
                '        "Deposit": 0,' +
                '        "AllowIPNPayment": false,' +
                '        "AllowOnlinePayment": false,' +
                '        "AllowOnlineCreditCardPayment": true,' +
                '        "AllowOnlineACHPayment": true,' +
                '        "domain": "QBO",' +
                '        "sparse": false,' +
                '        "Id": "19085",' +
                '        "SyncToken": "2",' +
                '        "MetaData": {' +
                '          "CreateTime": "2018-04-25T08:28:00-07:00",' +
                '          "LastUpdatedTime": "2018-04-25T08:28:15-07:00"' +
                '        },' +
                '        "CustomField": [' +
                '          {' +
                '            "DefinitionId": "1",' +
                '            "Name": "Schedule",' +
                '            "Type": "StringType",' +
                '            "StringValue": "SI01086"' +
                '          },' +
                '          {' +
                '            "DefinitionId": "2",' +
                '            "Name": "Your Ref",' +
                '            "Type": "StringType",' +
                '            "StringValue": "Sage inv 16452"' +
                '          },' +
                '          {' +
                '            "DefinitionId": "3",' +
                '            "Name": "Our Ref",' +
                '            "Type": "StringType",' +
                '            "StringValue": "18097"' +
                '          }' +
                '        ],' +
                '        "DocNumber": "1068",' +
                '        "TxnDate": "2018-03-31",' +
                '        "CurrencyRef": {' +
                '          "value": "GBP",' +
                '          "name": "British Pound Sterling"' +
                '        },' +
                '        "LinkedTxn": [],' +
                '        "Line": [' +
                '          {' +
                '            "Id": "1",' +
                '            "LineNum": 1,' +
                '            "Description": "Payment for event services",' +
                '            "Amount": 1818.0,' +
                '            "DetailType": "SalesItemLineDetail",' +
                '            "SalesItemLineDetail": {' +
                '              "ItemRef": {' +
                '                "value": "38",' +
                '                "name": "Opening Balances"' +
                '              },' +
                '              "TaxCodeRef": {' +
                '                "value": "46"' +
                '              }' +
                '            }' +
                '          },' +
                '          {' +
                '            "Amount": 1818.0,' +
                '            "DetailType": "SubTotalLineDetail",' +
                '            "SubTotalLineDetail": {}' +
                '          }' +
                '        ],' +
                '        "TxnTaxDetail": {' +
                '          "TotalTax": 0,' +
                '          "TaxLine": [' +
                '            {' +
                '              "Amount": 0,' +
                '              "DetailType": "TaxLineDetail",' +
                '              "TaxLineDetail": {' +
                '                "TaxRateRef": {' +
                '                  "value": "87"' +
                '                },' +
                '                "PercentBased": true,' +
                '                "TaxPercent": 0,' +
                '                "NetAmountTaxable": 1818.0' +
                '              }' +
                '            }' +
                '          ]' +
                '        },' +
                '        "CustomerRef": {' +
                '          "value": "1339",' +
                '          "name": "18097 Replacement Frame"' +
                '        },' +
                '        "BillAddr": {' +
                '          "Id": "1107",' +
                '          "Line1": "Highways England",' +
                '          "Line2": "Bridge House",' +
                '          "Line3": "Walnut Tree Close",' +
                '          "Line4": "Guildford",' +
                '          "Line5": "GU1 4GA"' +
                '        },' +
                '        "SalesTermRef": {' +
                '          "value": "9"' +
                '        },' +
                '        "DueDate": "2018-03-31",' +
                '        "GlobalTaxCalculation": "TaxExcluded",' +
                '        "TotalAmt": 1818.0,' +
                '        "PrintStatus": "NotSet",' +
                '        "EmailStatus": "NotSet",' +
                '        "BillEmail": {' +
                '          "Address": "INVOICES@highwaysengland.co.uk"' +
                '        },' +
                '        "Balance": 1818.0' +
                '      },' +
                '      {' +
                '        "Deposit": 0,' +
                '        "AllowIPNPayment": false,' +
                '        "AllowOnlinePayment": false,' +
                '        "AllowOnlineCreditCardPayment": true,' +
                '        "AllowOnlineACHPayment": true,' +
                '        "domain": "QBO",' +
                '        "sparse": false,' +
                '        "Id": "19073",' +
                '        "SyncToken": "0",' +
                '        "MetaData": {' +
                '          "CreateTime": "2018-04-25T07:30:01-07:00",' +
                '          "LastUpdatedTime": "2018-04-25T07:30:01-07:00"' +
                '        },' +
                '        "CustomField": [' +
                '          {' +
                '            "DefinitionId": "1",' +
                '            "Name": "Schedule",' +
                '            "Type": "StringType",' +
                '            "StringValue": "SI01029"' +
                '          },' +
                '          {' +
                '            "DefinitionId": "2",' +
                '            "Name": "Your Ref",' +
                '            "Type": "StringType",' +
                '            "StringValue": "Sage inv 16456"' +
                '          },' +
                '          {' +
                '            "DefinitionId": "3",' +
                '            "Name": "Our Ref",' +
                '            "Type": "StringType",' +
                '            "StringValue": "17619"' +
                '          }' +
                '        ],' +
                '        "DocNumber": "1056",' +
                '        "TxnDate": "2018-03-31",' +
                '        "CurrencyRef": {' +
                '          "value": "GBP",' +
                '          "name": "British Pound Sterling"' +
                '        },' +
                '        "LinkedTxn": [],' +
                '        "Line": [' +
                '          {' +
                '            "Id": "1",' +
                '            "LineNum": 1,' +
                '            "Description": "Request for payment",' +
                '            "Amount": 7704.0,' +
                '            "DetailType": "SalesItemLineDetail",' +
                '            "SalesItemLineDetail": {' +
                '              "ItemRef": {' +
                '                "value": "38",' +
                '                "name": "Opening Balances"' +
                '              },' +
                '              "TaxCodeRef": {' +
                '                "value": "46"' +
                '              }' +
                '            }' +
                '          },' +
                '          {' +
                '            "Amount": 7704.0,' +
                '            "DetailType": "SubTotalLineDetail",' +
                '            "SubTotalLineDetail": {}' +
                '          }' +
                '        ],' +
                '        "TxnTaxDetail": {' +
                '          "TotalTax": 0,' +
                '          "TaxLine": [' +
                '            {' +
                '              "Amount": 0,' +
                '              "DetailType": "TaxLineDetail",' +
                '              "TaxLineDetail": {' +
                '                "TaxRateRef": {' +
                '                  "value": "87"' +
                '                },' +
                '                "PercentBased": true,' +
                '                "TaxPercent": 0,' +
                '                "NetAmountTaxable": 7704.0' +
                '              }' +
                '            }' +
                '          ]' +
                '        },' +
                '        "CustomerRef": {' +
                '          "value": "1329",' +
                '          "name": "17619 Annual Stakeholder Conference 2018"' +
                '        },' +
                '        "BillAddr": {' +
                '          "Id": "1094",' +
                '          "Line1": "Calders",' +
                '          "Line2": "4 Woodside Court",' +
                '          "Line3": "Clayton Wood Rise",' +
                '          "Line4": "Leeds",' +
                '          "Line5": "LS16 6RF"' +
                '        },' +
                '        "SalesTermRef": {' +
                '          "value": "9"' +
                '        },' +
                '        "DueDate": "2018-03-31",' +
                '        "GlobalTaxCalculation": "TaxExcluded",' +
                '        "TotalAmt": 7704.0,' +
                '        "PrintStatus": "NotSet",' +
                '        "EmailStatus": "NotSet",' +
                '        "BillEmail": {' +
                '          "Address": "tracy@calders.org.uk"' +
                '        },' +
                '        "Balance": 7704.0' +
                '      }' +
                '    ],' +
                '    "startPosition": 1,' +
                '    "maxResults": 25,' +
                '    "totalCount": 25' +
                '  },' +
                '  "time": "2018-06-20T03:15:49.682-07:00"' +
                '}');
        res.setStatusCode(200);
        return res;
    }

}