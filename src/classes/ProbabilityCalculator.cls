/**
 * Created by Ronan Williams on 06/12/2018.
 */

public with sharing class ProbabilityCalculator {

    // STEP 1: initialise global probaility variables
    // opp stage
    // value range

    public static void doInit(){

        List<Opportunity> oppHistories = ProbabilityUtils.getOppHistoryData();

        Map<String,List<Integer>> stageSuccess = ProbabilityUtils.getStageSuccess(oppHistories);
        Map<String,List<Integer>> valueSuccess = ProbabilityUtils.getValueSuccess(oppHistories);


    }


    public static Map<Id,Account> getAccountConversion(Set<Id> accIds){

        return new Map<Id,Account>([
                SELECT Id, TotalClosedOpportunities__c, TotalConfirmedOpportunities__c
                FROM Account WHERE Id IN :accIds]);

    }

    public static Map<Id,List<Object>> getUserConversion(Set<Id> userIds){

        List<AggregateResult> totals = [SELECT COUNT(Id) total, OwnerId
                                        FROM Opportunity
                                        WHERE OwnerId IN :userIds
                                        AND (StageName = 'Closed Won'
                                        OR StageName = 'Closed Lost')
                                        GROUP BY OwnerId];

        List<AggregateResult> won = [SELECT COUNT(Id) won, OwnerId
                                        FROM Opportunity
                                        WHERE OwnerId IN :userIds
                                        AND StageName = 'Closed Won'
                                        GROUP BY OwnerId];

        Map<Id,List<Object>> userSuccessMap = new Map<Id,List<Object>>();

        for (Id id : userIds){
            userSuccessMap.put(id, new List<Object>());
        }

        for (AggregateResult ar : totals){
            userSuccessMap.get((Id)ar.get('OwnerId')).add(ar.get('total'));
        }

        for (AggregateResult ar : won){
            userSuccessMap.get((Id)ar.get('OwnerId')).add(ar.get('won'));
        }

        return userSuccessMap;

    }

    public static Map<Id,List<Object>> getContactConversion(Set<Id> contactIds){

        List<AggregateResult> totals = [SELECT COUNT(Id) total, ContactId
                                        FROM OpportunityContactRole
                                        WHERE ContactId IN :contactIds
                                        AND Opportunity.StageName = 'Closed Won'
                                        GROUP BY ContactId];

        List<AggregateResult> won = [SELECT COUNT(Id) won, ContactId
                                        FROM OpportunityContactRole
                                        WHERE ContactId IN :contactIds
                                        AND (Opportunity.StageName = 'Closed Won'
                                        OR Opportunity.StageName = 'Closed Lost')
                                        GROUP BY ContactId];

        Map<Id,List<Object>> contactSuccessMap = new Map<Id,List<Object>>();

        for (Id id : contactIds){
            contactSuccessMap.put(id, new List<Object>());
        }

        for (AggregateResult ar : totals){
            contactSuccessMap.get((Id)ar.get('ContactId')).add(ar.get('total'));
        }

        for (AggregateResult ar : won){
            contactSuccessMap.get((Id)ar.get('ContactId')).add(ar.get('won'));
        }

        return contactSuccessMap;

    }

    public static Map<Id,Decimal> getLeadTimeVariance(){

        List<Opportunity> opps = [SELECT Id, LeadTime__c
                                  FROM Opportunity
                                  WHERE StageName = 'Closed Won'];

        Decimal oppCount        = opps.size();
        Decimal leadTimeTotal   = 0;

        for (Opportunity opp : opps){
            leadTimeTotal += opp.LeadTime__c;
        }

        Decimal mean = leadTimeTotal / oppCount;
        Decimal varianceTotal = 0;

        for (Opportunity opp : opps){
            varianceTotal += ((opp.LeadTime__c - mean) * (opp.LeadTime__c - mean));
        }

        Decimal standardDeviation = varianceTotal / oppCount;

        Map<Id,Decimal> varianceMap = new Map<Id,Decimal>();

        for (Opportunity opp : opps){
            varianceMap.put(opp.Id, (opp.LeadTime__c / standardDeviation));
            System.debug(opp.LeadTime__c + '  ' + mean + '   ' + opp.LeadTime__c / standardDeviation);
        }

        return varianceMap;

    }



}