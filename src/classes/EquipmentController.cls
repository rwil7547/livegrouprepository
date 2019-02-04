/**
 * Created by Ronan Williams on 01/02/2019.
 */

public with sharing class EquipmentController {


    @AuraEnabled
    public static List<Equipment__c> getEquipmentApex(){

        List<Equipment__c> equipment = [SELECT Id, Name__c, Name, Model__c, Active__c, Onsite__c,
                                        (SELECT Id, Opportunity__r.Filtered_Job_Number__c
                                        FROM Reservations__r
                                        WHERE Start__c <= :Date.today()
                                        AND End__c >= :Date.today() LIMIT 1)
                                        FROM Equipment__c
                                        ORDER BY Name__c];

        return equipment;
    }



}