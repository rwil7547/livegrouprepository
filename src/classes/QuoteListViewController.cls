/**
 * Created by Ronan Williams on 22/11/2018.
 */

public class QuoteListViewController {

    @AuraEnabled
    public static List<SBQQ__Quote__c> getQuotes(String Id){

        return [SELECT Id, Version__c, SBQQ__Status__c, SBQQ__NetAmount__c, Gross_Profit__c,
                        Cost_of_sale__c, Gross_Margin__c, SBQQ__Primary__c, Locked__c, DocumentLocked__c, Stage__c,
                        (SELECT Id, Name, SBQQ__OutputFormat__c, SBQQ__DocumentId__c, CreatedDate,
                                CreatedBy.Name
                            FROM SBQQ__R00N70000001lX7YEAU__r
                            ORDER BY CreatedDate)
                FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :Id
                ORDER BY CreatedDate ASC];

    }
}
