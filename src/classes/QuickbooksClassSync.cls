/**
 * Created by Ronan Williams on 09/11/2018.
 */

public class QuickbooksClassSync {

    public static void refreshClassSync(Map<String,String> idMap){

        // if no Ids have been passed to the method, do callout to Quickbooks to get latest set of Ids
        if (idMap.isEmpty()) {
            String query1 = 'query?query=select%20%2a%20from%20class%20order%20by%20' +
                    'MetaData.CreateTime%20desc%20maxresults%201000&minorversion=4';

            // do callout
            Http http1 = new Http();
            HttpRequest request1    = CashFlowUtils.doCallout(query1);
            HttpResponse response1  = http1.send(request1);

            if (response1.getStatusCode() == 200) {

                Map<String, Object> response        = (Map<String, Object>) JSON.deserializeUntyped(response1.getBody());
                Map<String, Object> responseBody    = (Map<String, Object>) response.get('QueryResponse');
                List<Object> classes                = (List<Object>) responseBody.get('Class');

                for (Object QBclass : classes) {
                    Map<String, Object> fields  = (Map<String, Object>) QBclass;
                    String name                 = ((String) fields.get('Name')).substring(0, 5);
                    String classId              = (String) fields.get('Id');
                    idMap.put(name, classId);
                }
            }
        }

        List<Opportunity> opps = [SELECT Id, Filtered_Job_Number__c, Name FROM Opportunity
                                    WHERE StageName = 'Closed Won'
                                    AND QuickbooksClassId__c = NULL
                                    AND Event_end__c >= :Date.newInstance(2018,04,01)];

        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        Set<Id> missingIds = new Set<Id>();

        for (Opportunity opp : opps){
            if (idMap.containsKey(opp.Filtered_Job_Number__c)){
                opp.QuickbooksClassId__c = idMap.get(opp.Filtered_Job_Number__c);
                oppsToUpdate.add(opp);
            } else {
                missingIds.add(opp.Id);
            }
        }

        if (!missingIds.isEmpty()){
            postQuickbooksClass(missingIds);
        }

        update oppsToUpdate;
    }


//    @Future(Callout=true)
    public static void postQuickbooksClass(Set<Id> oppIds){

        List<Opportunity> opps              = new List<Opportunity>();
        List<Integration_Error__c> errors   = new List<Integration_Error__c>();

        while (oppIds.size() > 0) {

            opps = [SELECT Id, Name, Filtered_Job_Number__c
                    FROM Opportunity
                    WHERE Id IN :oppIds
                    LIMIT 30];

            String classString = '';

            for (Integer x = 0; x < opps.size(); x++) {
                classString += '      {  ' +
                        '         "bId":"bid' + String.valueOf(x + 1) + '",' +
                        '         "operation":"create",' +
                        '         "Class":{  ' +
                        '            "Name": "' + opps[x].Filtered_Job_Number__c + ' ' + opps[x].Name + '"' +
                        '            }' +
                        '         }';

                // add comma to json string if there are still accounts to add to the string
                if ((x + 1) < opps.size()) {
                    classString += ',';
                }

                oppIds.remove(opps[x].Id);
            }

            String batchString = '{  ' +
                    '   "BatchItemRequest":[  ' +
                    classString +
                    '   ]' +
                    '}';

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:QuickBooksOnline/batch?minorversion=4');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('Accept', 'application/json');
            request.setBody(batchString);
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                opps = updateOpportunityQuickbooksClassId(response.getBody(), opps);
            } else {
                Integration_Error__c error = new Integration_Error__c();
                error.Class__c = 'QuickbooksCustomerBatch';
                error.sObject__c = '';
                error.Action__c = 'Attempt to insert new Classes';
                error.Outcome__c = 'The status code returned was not expected: ' +
                        response.getStatusCode() + ' ' + response.getStatus();
                errors.add(error);
            }
        }

        insert errors;
        update opps;
    }

    public static List<Opportunity> updateOpportunityQuickbooksClassId(String queryResponse, List<Opportunity> opps){

        Map<String,String> nameIdMap 		= new Map<String,String>();
        List<Opportunity> oppsToUpdate 		= new List<Opportunity>();
        List<Integration_Error__c> errors 	= new List<Integration_Error__c>();
        Map<String,Object> response         = (Map<String,Object>)JSON.deserializeUntyped(queryResponse);
        List<Object> classes                = (List<Object>)response.get('BatchItemResponse');

        for (Object QBclass : classes){

            Map<String,Object> fieldsMap = (Map<String,Object>)QBclass;
            Map<String,Object> fields = (Map<String,Object>)fieldsMap.get('Class');

            if (fields.containsKey('Name') && fields.containsKey('Id')){
                String name     = ((String)fields.get('Name')).substring(0,5);
                String classId  = (String)fields.get('Id');
                nameIdMap.put(name, classId);
            }
        }

        for (Opportunity opp : opps) {
            if (nameIdMap.containsKey(opp.Filtered_Job_Number__c)){
                opp.QuickbooksClassId__c = nameIdMap.get(opp.Filtered_Job_Number__c);
                oppsToUpdate.add(opp);
            } else {
                Integration_Error__c error  = new Integration_Error__c();
                error.Class__c 				= 'QuickbooksClassSync';
                error.sObject__c 			= opp.Id;
                error.Action__c 			= 'Attempt to retrieve Class Id from Quickbooks';
                error.Outcome__c			= 'No Id for the record returned';
                errors.add(error);
            }
        }

        insert errors;

        return oppsToUpdate;
    }

}