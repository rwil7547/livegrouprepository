/**
 * Created by Ronan Williams on 22/11/2018.
 */

public class QuoteListViewController {

    @AuraEnabled
    public static List<SBQQ__Quote__c> getQuotes(String Id){

        return [SELECT Id, Version__c, SBQQ__Status__c, SBQQ__NetAmount__c, Gross_Profit__c,
                        Cost_of_sale__c, Gross_Margin__c, SBQQ__Primary__c, Locked__c, DocumentLocked__c, Stage__c,
                        SBQQ__Opportunity2__r.Quote_Status__c,
                        (SELECT Id, Name, SBQQ__OutputFormat__c, SBQQ__DocumentId__c, CreatedDate,
                                CreatedBy.Name
                            FROM SBQQ__R00N70000001lX7YEAU__r
                            ORDER BY CreatedDate)
                FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :Id
                ORDER BY CreatedDate ASC];

    }

    @AuraEnabled
    public static Boolean deleteDocumentApex(String docId){

        Boolean success = false;

        Savepoint sp = Database.setSavepoint();

        Attachment attach = [SELECT Id, ParentId FROM Attachment WHERE Id = :docId];
        SBQQ__QuoteDocument__c document = [SELECT Id, SBQQ__Quote__c
                                           FROM SBQQ__QuoteDocument__c
                                           WHERE Id = :attach.ParentId];

        Database.DeleteResult attachDeleteResult = Database.delete(attach);

        if (attachDeleteResult.isSuccess()){

            Database.SaveResult quoteUpdate  = Database.update(
                                                new SBQQ__Quote__c(
                                                        Id = document.SBQQ__Quote__c,
                                                        HasDocument__c = false)
                                                );
            Database.DeleteResult docDeleteResult  = Database.delete(document);

            if (quoteUpdate.isSuccess() && docDeleteResult.isSuccess()){
                success = true;
            } else {
                Database.rollback(sp);
            }
        }

        return success;
    }
}
