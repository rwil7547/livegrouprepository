/**
 * Created by Ronan Williams on 19/12/2018.
 */

public class QuotePreviewController {

    public SBQQ__Quote__c quote {get; set;}
    public Map<String,List<SBQQ__QuoteLine__c>> groupMap {get; set;}
    public Map<String,Decimal> groupSummary {get; set;}
    public User user {get; set;}
    public Contact contact {get; set;}

    public QuotePreviewController(){

        System.debug(ApexPages.currentPage().getParameters());

        user = [SELECT Id, Name FROM User WHERE Id = :ApexPages.currentPage().getParameters().get('userId')];
        contact = [SELECT Id, Name FROM Contact WHERE Id = :ApexPages.currentPage().getParameters().get('contactId')];


        quote = [SELECT Id, Name, Version__c, SBQQ__LineItemsGrouped__c, SBQQ__Opportunity2__r.Name,
                    (SELECT Name, SBQQ__ProductFamily__c, SBQQ__ListPrice__c, SBQQ__NetTotal__c, SBQQ__Description__c,
                            SBQQ__Group__r.Name, SBQQ__Quantity__c, Days__c, SBQQ__SubscriptionTerm__c
                     FROM SBQQ__LineItems__r
                     WHERE SBQQ__Optional__c = false),
                    (SELECT Name, Id, SBQQ__NetTotal__c FROM SBQQ__LineItemGroups__r)
                FROM SBQQ__Quote__c
                WHERE Id = :ApexPages.currentPage().getParameters().get('id')];

        groupMap = new Map<String,List<SBQQ__QuoteLine__c>>();

        groupSummary = new Map<String,Decimal>();


        if (quote.SBQQ__LineItemsGrouped__c){
//            for (SBQQ__QuoteLineGroup__c lineGroup : quote.SBQQ__LineItemGroups__r){
//                groupMap.put(lineGroup.Name, new List<SBQQ__QuoteLine__c>());
//            }

            for (SBQQ__QuoteLineGroup__c lineGroup : [SELECT Name FROM SBQQ__QuoteLineGroup__c
                                                      WHERE SBQQ__Quote__c = :quote.Id]){
                groupMap.put(lineGroup.Name, new List<SBQQ__QuoteLine__c>());
                groupSummary.put(lineGroup.Name, 0);
            }


            for (SBQQ__QuoteLine__c line : quote.SBQQ__LineItems__r){
                if (line.SBQQ__Group__r.Name == null || line.SBQQ__Group__c == null){
                    if (!groupMap.containsKey('Ungrouped')){
                        groupMap.put('Ungrouped', new List<SBQQ__QuoteLine__c>());
                    }
                    groupMap.get('Ungrouped').add(line);

                    if (!groupSummary.containsKey('Ungrouped')){
                        groupSummary.put('Ungrouped', 0);
                    }
                    groupSummary.put('Ungrouped', groupSummary.get('Ungrouped') + line.SBQQ__NetTotal__c);

                } else {
                    groupMap.get(line.SBQQ__Group__r.Name).add(line);
//
//                    if (!groupSummary.containsKey(line.SBQQ__Group__r.Name)){
//                        groupSummary.put(line.SBQQ__Group__r.Name, 0);
//                    }
                    groupSummary.put(line.SBQQ__Group__r.Name, groupSummary.get(line.SBQQ__Group__r.Name) + line.SBQQ__NetTotal__c);
                }
            }

        } else {
            for (SBQQ__QuoteLine__c line : quote.SBQQ__LineItems__r){
                if (!groupMap.containsKey(line.SBQQ__ProductFamily__c)){
                    groupMap.put(line.SBQQ__ProductFamily__c, new List<SBQQ__QuoteLine__c>());
                }
                groupMap.get(line.SBQQ__ProductFamily__c).add(line);
                if (!groupSummary.containsKey(line.SBQQ__ProductFamily__c)){
                    groupSummary.put(line.SBQQ__ProductFamily__c, 0);
                }
                groupSummary.put(line.SBQQ__ProductFamily__c, groupSummary.get(line.SBQQ__ProductFamily__c) + line.SBQQ__NetTotal__c);
            }
        }

    }

}