/**
 * Created by Ronan Williams on 11/12/2018.
 */

public with sharing class ProbabilityUtils {

    public static Map<String,List<Integer>> getStageSuccess(List<Opportunity> opps){

        Map<String,List<Integer>> weightingMap = new Map<String,List<Integer>>();

        Integer repeatTotal     = 0;
        Integer pipelineTotal   = 0;
        Integer costedTotal     = 0;
        Integer repeatWins      = 0;
        Integer pipelineWins    = 0;
        Integer costedWins      = 0;

        for (Opportunity opp : opps){
            for (OpportunityHistory history : opp.OpportunityHistories){
                if (history.StageName == 'Repeat Prospect'){
                    repeatTotal++;
                    if (opp.StageName == 'Closed Won') {
                        repeatWins++;
                    }
                } else if (history.StageName == 'Pipeline prospect'){
                    pipelineTotal ++;
                    if (opp.StageName == 'Closed Won') {
                        pipelineWins++;
                    }
                } else if (history.StageName == 'Costed prospect'){
                    costedTotal ++;
                    if (opp.StageName == 'Closed Won') {
                        costedWins++;
                    }
                }
            }
        }

        if (repeatTotal > 0){
            weightingMap.put('Repeat Prospect', calcWeighting(repeatTotal,repeatWins));
        }

        if (pipelineTotal > 0){
            weightingMap.put('Pipeline prospect', calcWeighting(pipelineTotal,pipelineWins));
        }

        if (costedTotal > 0){
            weightingMap.put('Costed prospect', calcWeighting(costedTotal,costedWins));
        }

        return weightingMap;

    }


    public static Map<String,List<Integer>> getValueSuccess(List<Opportunity> opps) {

        Map<String,List<Integer>> weightingMap = new Map<String,List<Integer>>();

        Integer less1KTotal      = 0;
        Integer less1KRate       = 0;
        Integer less5KTotal      = 0;
        Integer less5KRate       = 0;
        Integer less20KTotal     = 0;
        Integer less20KRate      = 0;
        Integer less50KTotal     = 0;
        Integer less50KRate      = 0;
        Integer less100KTotal    = 0;
        Integer less100KRate     = 0;
        Integer greater100KTotal = 0;
        Integer greater100KRate  = 0;

        for (Opportunity opp : opps){
            if (opp.Amount_Calder__c < 1000){
                less1KTotal++;
                if (opp.StageName == 'Closed Won'){
                    less1KRate++;
                }
            } else if (opp.Amount_Calder__c < 5000){
                less5KTotal++;
                if (opp.StageName == 'Closed Won'){
                    less5KRate++;
                }
            } else if (opp.Amount_Calder__c < 20000) {
                less20KTotal++;
                if (opp.StageName == 'Closed Won'){
                    less20KRate++;
                }
            } else if (opp.Amount_Calder__c < 50000) {
                less50KTotal++;
                if (opp.StageName == 'Closed Won'){
                    less50KRate++;
                }
            } else if (opp.Amount_Calder__c < 100000) {
                less100KTotal++;
                if (opp.StageName == 'Closed Won'){
                    less100KRate++;
                }
            } else if (opp.Amount_Calder__c >= 100000) {
                greater100KTotal++;
                if (opp.StageName == 'Closed Won'){
                    greater100KRate++;
                }
            }

            weightingMap.put('less1K', calcWeighting(less1KTotal,less1KRate));
            weightingMap.put('less5K', calcWeighting(less5KTotal,less5KRate));
            weightingMap.put('less20K', calcWeighting(less20KTotal,less20KRate));
            weightingMap.put('less50K', calcWeighting(less50KTotal,less50KRate));
            weightingMap.put('less100K', calcWeighting(less100KTotal,less100KRate));
            weightingMap.put('greater100K', calcWeighting(greater100KTotal,greater100KRate));

        }

        return weightingMap;

    }

    public static Map<Integer,List<Integer>> getMonthSuccess(List<Opportunity> opps){



        return null;
    }


    private static List<Integer> calcWeighting(Integer total, Integer rate){

        Integer successRate = (total / rate) * 100;
        Integer weighting   = 1;
        if (successRate < 50){
            weighting = (total / (50 - successRate));
        } else if (successRate > 50){
            weighting = (total / (50 - (successRate - 50)));
        }

        return new List<Integer>{successRate,weighting};
    }

    public static List<Opportunity> getOppHistoryData(){

        return [SELECT Id, StageName, Amount_Calder__c, Event_month__c,
                     (SELECT StageName FROM OpportunityHistories
                ORDER BY CreatedDate DESC LIMIT 1)
                FROM Opportunity
                WHERE (StageName = 'Closed Won'
                OR StageName = 'Closed Lost')];

    }



}