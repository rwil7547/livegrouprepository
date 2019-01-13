/**
 * Created by Ronan Williams on 04/12/2018.
 */

@IsTest
public class MonthEndCreditMemoJournalMock implements HttpCalloutMock {

    public String currentScheduleNumber;
    public String futureScheduleNumber;

    public HttpResponse respond(HttpRequest req) {

        // mock response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{' +
                '  "QueryResponse": {' +
                '    "CreditMemo": [' +

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
                '            "StringValue": "' + currentScheduleNumber + '"' +
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
                '        "TxnDate": "' + String.valueOf(Date.today().toStartOfMonth().addMonths(-1)).substring(0, 10) + '",' +
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
                '            "Amount": 100.0,' +
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
                '            "Amount": 100.0,' +
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
                '                  "value": "79"' +
                '                },' +
                '                "PercentBased": true,' +
                '                "TaxPercent": 20,' +
                '                "NetAmountTaxable": 0' +
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
                '        "TotalAmt": 100,' +
                '        "PrintStatus": "NotSet",' +
                '        "EmailStatus": "NeedToSend",' +
                '        "BillEmail": {' +
                '          "Address": "FSPAYMENTS1@highwaysengland.co.uk"' +
                '        },' +
                '        "Balance": 0,' +
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
                '            "StringValue": "' + futureScheduleNumber + '"' +
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
                '        "TxnDate": "' + String.valueOf(Date.today().toStartOfMonth().addMonths(-1)).substring(0, 10) + '",' +
                '        "CurrencyRef": {' +
                '          "value": "GBP",' +
                '          "name": "British Pound Sterling"' +
                '        },' +
                '        "LinkedTxn": [],' +
                '        "Line": [' +
                '          {' +
                '            "Id": "1",' +
                '            "LineNum": 1,' +
                '            "Description": "Request for payment for event services",' +
                '            "Amount": 1000.0,' +
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
                '                  "value": "79"' +
                '                },' +
                '                "PercentBased": true,' +
                '                "TaxPercent": 20,' +
                '                "NetAmountTaxable": 0' +
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
                '        "TotalAmt": 100,' +
                '        "PrintStatus": "NotSet",' +
                '        "EmailStatus": "NotSet",' +
                '        "BillEmail": {' +
                '          "Address": "Area6invoice@highwaysengland.co.uk"' +
                '        },' +
                '        "Balance": 0' +
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

    public MonthEndCreditMemoJournalMock(String currentScheduleNumber, String futureScheduleNumber){
        this.currentScheduleNumber  = currentScheduleNumber;
        this.futureScheduleNumber   = futureScheduleNumber;
    }
}