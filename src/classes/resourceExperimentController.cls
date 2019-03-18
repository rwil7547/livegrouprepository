/**
 * Created by Ronan Williams on 13/03/2019.
 */

public with sharing class resourceExperimentController {

    @RemoteAction
    public static List<Opportunity> getOpps(){

        List<Opportunity> opportunities = [SELECT Id, Name, Event_start__c, Event_end__c, StageName, Length__c
                                            FROM Opportunity
                                            WHERE Event_end__c = THIS_YEAR
                                            AND Event_end__c < :Date.today().addDays(190)
                                            AND StageName != 'Closed Lost'
                                            ORDER BY IsClosed DESC
                                            LIMIT 155];

        List<Opportunity> clones = new List<Opportunity>();

        for (Opportunity opp : opportunities){

            if (opp.Event_start__c < Date.newInstance(2019,01,01)){
                opp.Event_start__c = Date.newInstance(2019,01,01);
            }

            if (opp.Event_start__c.month() != opp.Event_end__c.month()){

                Integer months = opp.Event_start__c.monthsBetween(opp.Event_end__c);

                for (Integer x = 0; x < months; x++){


                    Opportunity cloneOpp    = opp.clone(true,true);

                    cloneOpp.Event_start__c = opp.Event_start__c.addMonths(x + 1).toStartOfMonth();
                    cloneOpp.Event_end__c   = (x == (months -1)) ? opp.Event_end__c : cloneOpp.Event_start__c.addMonths(1).toStartOfMonth().addDays(-1);
                    cloneOpp.Lengthjs__c    = cloneOpp.Event_start__c.daysBetween(cloneOpp.Event_end__c) + 1;
                    clones.add(cloneOpp);
                }

                opp.Event_end__c    = opp.Event_start__c.addMonths(1).toStartOfMonth().addDays(-1);
                opp.Lengthjs__c     = opp.Event_start__c.daysBetween(opp.Event_end__c) + 1;

                system.debug('final opp has val of ' + opp.Event_start__c + '  ' + opp.Event_end__c);


            } else {
                opp.Lengthjs__c     = opp.Length__c + 1;
            }

        }

        opportunities.addAll(clones);


        return opportunities;

    }

}