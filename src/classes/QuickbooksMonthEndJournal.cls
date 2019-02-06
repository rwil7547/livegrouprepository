/**
 * Created by Ronan Williams on 14/11/2018.
 */

public class QuickbooksMonthEndJournal {

    public static void postRevenueJournal(){

        // ensure one and only one journal exists
        if ([SELECT Id FROM QBJournal__c WHERE TxnDate__c = :Date.today().toStartOfMonth().addMonths(-1)
            AND QuickbooksId__c = NULL AND Target__c = '4000 Revenue'].size() == 1) {

            QBJournal__c journal = [
                    SELECT Id, DocNumber__c, TxnDate__c,
                        (SELECT Id, Description__c, PostingType__c, AccountRefId__c,
                        ClassRefId__c, Amount__c, CallbackId__c
                        FROM QBJournalEntries__r)
                    FROM QBJournal__c
                    WHERE Target__c = '4000 Revenue'
                    AND TxnDate__c = :Date.today().toStartOfMonth().addMonths(-1)
            ];

            // generate string
            String journalString = generateJournalString(journal);

            // post to Quickbooks
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:QuickBooksOnline/journalentry?minorversion=4');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('Accept', 'application/json');
            request.setBody(journalString);
            HttpResponse response = http.send(request);

            // handle response
            if (response.getStatusCode() == 200) {
                handleCalloutResponse(response, journal);
            } else {
                Integration_Error__c error = new Integration_Error__c();
                error.Class__c = 'QuickbooksMonthEndJournal';
                error.sObject__c = '';
                error.Action__c = 'Attempt to insert new month end journals';
                error.Outcome__c = 'The status code returned was not expected: ' +
                        response.getStatusCode() + ' ' + response.getStatus();
                insert error;

                System.debug(response.getBody());
            }
        }
    }

    public static void postCOSJournals(){

        // ensure one and only one journal exists
        if ([SELECT Id FROM QBJournal__c WHERE TxnDate__c = :Date.today().toStartOfMonth().addMonths(-1)
            AND QuickbooksId__c = NULL AND Target__c = '5000 Cost of sales'].size() == 2) {

            List<QBJournal__c> journals = [
                    SELECT Id, DocNumber__c, TxnDate__c, (
                            SELECT Id, Description__c, PostingType__c, AccountRefId__c,
                                    ClassRefId__c, Amount__c, CallbackId__c
                            FROM QBJournalEntries__r)
                    FROM QBJournal__c
                    WHERE Target__c = '5000 Cost of sales'
                    AND TxnDate__c = :Date.today().toStartOfMonth().addMonths(-1)
            ];

            Map<HttpResponse, QBJournal__c> responseMap = new Map<HttpResponse, QBJournal__c>();

            for (QBJournal__c journal : journals) {

                // generate string
                String journalString = generateJournalString(journal);

                // post to Quickbooks
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint('callout:QuickBooksOnline/journalentry?minorversion=4');
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                request.setHeader('Accept', 'application/json');
                request.setBody(journalString);
                HttpResponse response = http.send(request);

                // handle response
                if (response.getStatusCode() == 200) {

                    responseMap.put(response, journal);
                } else {
                    Integration_Error__c error = new Integration_Error__c();
                    error.Class__c = 'QuickbooksMonthEndJournal';
                    error.sObject__c = '';
                    error.Action__c = 'Attempt to insert new month end journals';
                    error.Outcome__c = 'The status code returned was not expected: ' +
                            response.getStatusCode() + ' ' + response.getStatus();
                    insert error;

                    System.debug(response.getBody());
                }
            }

            for (HttpResponse response : responseMap.keySet()){
                handleCalloutResponse(response, responseMap.get(response));
            }
        }
    }


    private static String generateJournalString(QBJournal__c journal){

        String journalLines = '';

        // create a string JSON entry for each journal to post
        for (Integer x = 0; x < journal.QBJournalEntries__r.size(); x++){

            QBJournalEntry__c entry = journal.QBJournalEntries__r[x];

            journalLines +=
                    '   {' +
                    '       "Id": "' + x + '",' +
                    '       "Description": "' + entry.Description__c + '",' +
                    '       "Amount": ' + entry.Amount__c + ',' +
                    '       "DetailType": "JournalEntryLineDetail",' +
                    '       "JournalEntryLineDetail": {' +
                    '       "PostingType": "' + entry.PostingType__c + '",' +
                    '       "AccountRef": {' +
                    '           "value": "' + entry.AccountRefId__c + '"' +
                    '       }';

            if (entry.ClassRefId__c != null){
                journalLines +=
                    '       ,' +
                    '       "ClassRef": {' +
                    '           "value": "' + entry.ClassRefId__c + '"' +
                    '       }';
            }
            journalLines +=
                    '   }' +
                    '}';

            if (x+1 < journal.QBJournalEntries__r.size()){
                journalLines += ',';
            }
        }

        String journalString =
                '   {' +
                '   "DocNumber": "' + journal.DocNumber__c + '",' +
                '   "TxnDate": "' + String.valueOf(journal.TxnDate__c).substring(0,10) + '",' +
                '   "Line": [' +
                journalLines +
                '       ]' +
                '   }';

        System.debug(journalString);

        return journalString;
    }

    private static void handleCalloutResponse(HttpResponse response, QBJournal__c journal){

        Map<String,Object> responseMap      = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
        Map<String,Object> journalResponse  = (Map<String,Object>)responseMap.get('JournalEntry');

        // create SB Journal entry map
//        Map<String,QBJournalEntry__c> entryMap = new Map<String,QBJournalEntry__c>();
//
//        for (QBJournalEntry__c entry : journal.QBJournalEntries__r){
//            entryMap.put(entry.CallbackId__c, entry);
//        }

//        System.debug('the id returned from Quickbooks is ' + (String)journalResponse.get('Id'));
        System.debug('the id returned from Quickbooks is ' + journalResponse);

        // populate journal Id with Quickbooks entry Id
//        journal.QuickbooksId__c = (String)journalResponse.get('Id');

        update journal;
    }

}