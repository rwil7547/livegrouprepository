/**
 * Created by Ronan Williams on 11/06/2018.
 */

public class calderPipelineController {

    public Map<Id,Opportunity> oppMap {get; set;}
    public Map<String, List<String>> currentOppMap {get; set;}
    public Map<String, List<String>> previousOppMap {get; set;}
    public Set<String> currentMonthGroupings {get;set;}
    public Set<String> previousMonthGroupings {get;set;}
    public String selectedOppId {get;set;}
    public Map<Id,Calder_Comment__c> newCommentMap {get; set;}


    public void loadData() {

        newCommentMap = new Map<Id,Calder_Comment__c>();

        oppMap = new Map<Id, Opportunity>([
                SELECT Id, Name, Filtered_Job_Number__c, Event_start__c, Event_End_Text__c,
                        Event_end__c, Location__c, Venue__c, QuoteContact__c, QuoteContactEmail__c,
                        QuoteContactPhone__c, Calder_Comments__c, Calder_GPS_Ref__c, Other_Information__c,
                        Document_Requested__c,
                        Owner.Name, StageName, Account.Name, Primary_Service__c, Amount, CreatedDate,
                        (SELECT Invoice_Number__c, Credit_Note_Number__c FROM Invoice_Schedules__r
                        WHERE Invoice_Sent__c = TRUE),
                        (SELECT Comment__c, CreatedDate, CreatedBy.Name FROM Calder_Comments__r
                        ORDER BY CreatedDate ASC),
                        (SELECT SBQQ__DocumentId__c FROM R00N700000029COgEAM
                        WHERE SBQQ__Quote__r.SBQQ__Primary__c = TRUE)
                FROM Opportunity
                WHERE Calder_Opportunity__c = TRUE
                AND Event_end__c != NULL
                AND Event_start__c != NULL
                AND StageName != 'Closed Lost'
                ORDER BY Event_end__c DESC
        ]);

        currentOppMap = new Map<String, List<String>>();
        previousOppMap = new Map<String, List<String>>();

        for (Opportunity opp : oppMap.values()) {

            Calder_Comment__c  newComment = new Calder_Comment__c();
            newComment.Opportunity__c = opp.Id;
            newCommentMap.put(opp.Id, newComment);

            if (opp.Event_end__c.year() >= Date.today().year()) {
                if (!currentOppMap.containsKey(opp.Event_End_Text__c)) {
                    currentOppMap.put(opp.Event_End_Text__c, new List<String>());
                    currentOppMap.get(opp.Event_End_Text__c).add(opp.Id);
                } else {
                    currentOppMap.get(opp.Event_End_Text__c).add(opp.Id);
                }
            } else {
                if (!previousOppMap.containsKey(opp.Event_End_Text__c)) {
                    previousOppMap.put(opp.Event_End_Text__c, new List<String>());
                    previousOppMap.get(opp.Event_End_Text__c).add(opp.Id);
                } else {
                    previousOppMap.get(opp.Event_End_Text__c).add(opp.Id);
                }
            }
        }

        currentMonthGroupings = currentOppMap.keySet();
        previousMonthGroupings = previousOppMap.keySet();

    }

    public PageReference saveOpportunity(){

        List<Opportunity> toUpdate = new List<Opportunity>();
        String theId = ApexPages.currentPage().getParameters().get('opportunityId');

        System.debug('Id is ' + theId + ' values are ' + oppMap.get(theId).Calder_GPS_Ref__c );

        toUpdate.add(oppMap.get(theId));

        update toUpdate;

        return null;
    }

    public PageReference requestDocument(){

        String theId = ApexPages.currentPage().getParameters().get('opportunityId');

        Opportunity opp = oppMap.get(theId);

        opp.Document_Requested__c = true;

        update opp;

        return null;
    }


    public PageReference saveComment(){

        String theId = ApexPages.currentPage().getParameters().get('opportunityId');

        Calder_Comment__c newComment = newCommentMap.get(theId);

        insert newComment;

        loadData();

        return null;
    }

    public calderPipelineController(){

        loadData();

    }

}