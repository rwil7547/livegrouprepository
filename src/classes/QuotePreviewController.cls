/**
 * Created by Ronan Williams on 19/12/2018.
 */

public class QuotePreviewController {

    public SBQQ__Quote__c quote {get; set;}
    public Map<String,List<SBQQ__QuoteLine__c>> groupMap {get; set;}
    public String userId {get; set;}
    public String contactId {get; set;}


    public QuotePreviewController(){

        userId = ApexPages.currentPage().getParameters().get('userId');
        contactId = ApexPages.currentPage().getParameters().get('contactId');


        quote = [SELECT Id, Name, Version__c, SBQQ__LineItemsGrouped__c,
                    (SELECT Name, SBQQ__ProductFamily__c, SBQQ__ListPrice__c, SBQQ__NetTotal__c, SBQQ__Description__c,
                            SBQQ__Group__r.Name, SBQQ__Quantity__c, Days__c, SBQQ__SubscriptionTerm__c
                     FROM SBQQ__LineItems__r),
                    (SELECT Name, Id, SBQQ__NetTotal__c FROM SBQQ__LineItemGroups__r)
                FROM SBQQ__Quote__c
                WHERE Id = :ApexPages.currentPage().getParameters().get('id')];

        groupMap = new Map<String,List<SBQQ__QuoteLine__c>>();

        if (quote.SBQQ__LineItemsGrouped__c){
            for (SBQQ__QuoteLineGroup__c lineGroup : quote.SBQQ__LineItemGroups__r){
                groupMap.put(lineGroup.Name, new List<SBQQ__QuoteLine__c>());
            }

            for (SBQQ__QuoteLine__c line : quote.SBQQ__LineItems__r){
                if (line.SBQQ__Group__r.Name == null){
                    if (!groupMap.containsKey('Ungrouped')){
                        groupMap.put('Ungrouped', new List<SBQQ__QuoteLine__c>());
                    }
                    groupMap.get('Ungrouped').add(line);
                } else {
                    groupMap.get(line.SBQQ__Group__r.Name).add(line);
                }
            }

        } else {
            for (SBQQ__QuoteLine__c line : quote.SBQQ__LineItems__r){
                if (!groupMap.containsKey(line.SBQQ__ProductFamily__c)){
                    groupMap.put(line.SBQQ__ProductFamily__c, new List<SBQQ__QuoteLine__c>());
                }
                groupMap.get(line.SBQQ__ProductFamily__c).add(line);
            }

        }
    }

}