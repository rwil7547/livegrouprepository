/**
 * Created by Ronan Williams on 19/12/2018.
 */

public class QuotePreviewController {

    public SBQQ__Quote__c quote {get; set;}
    public String docType {get; set;}
    public Map<String,Map<String,List<SBQQ__QuoteLine__c>>> groupMap {get; set;}
    public Map<String,Decimal> groupSummary {get; set;}
    public Map<String,Integer> groupLineCount {get; set;}

    public Map<String,Map<String,List<SBQQ__QuoteLine__c>>> optionalGroupMap {get; set;}
    public Map<String,Decimal> optionalGroupSummary {get; set;}

    public List<Invoice_Schedule__c> invoices {get; set;}

    public User user {get; set;}
    public String userSignature {get; set;}
    public Contact contact {get; set;}

    public String theme {get; set;}
    public String theme2 {get; set;}
    public String theme3 {get; set;}

    public Boolean showOptionals {get; set;}


    public QuotePreviewController(){

        System.debug(ApexPages.currentPage().getParameters());

        showOptionals = (ApexPages.currentPage().getParameters().get('optionals') == 'true') ? true : false;

        user = [SELECT Id, Name, FirstName, LastName, Phone, MobilePhone, Email
                FROM User
                WHERE Id = :ApexPages.currentPage().getParameters().get('userId')];
        contact = [SELECT Id, Name, FirstName, LastName, Account.Name, MailingStreet, MailingCity, MailingCountry, MailingPostalCode,
                            Email, Phone, MobilePhone
                    FROM Contact
                    WHERE Id = :ApexPages.currentPage().getParameters().get('contactId')];

        String signatureName = user.FirstName + user.LastName;
        List<StaticResource> sr = [SELECT Id, Body FROM StaticResource WHERE Name = :signatureName LIMIT 1];
        if (!sr.isEmpty()){

            String myUrl = PageReference.forResource(signatureName).getUrl();
            userSignature = myUrl.subString(0, myUrl.indexOf('?'));
//            userSignature = '$Resource.' + user.FirstName + user.LastName;
        }


        quote = [SELECT Id, Name, Version__c, SBQQ__LineItemsGrouped__c, SBQQ__Opportunity2__r.Name,
                        SBQQ__Opportunity2__r.Filtered_Job_Number__c, Stage__c, Ancestor__c, Proposal_Introduction__c,
                        SBQQ__NetAmount__c, SBQQ__Opportunity2__r.Venue__c, SBQQ__Opportunity2__r.Location__c,
                        SBQQ__Opportunity2__r.Event_start__c, SBQQ__Opportunity2__r.Event_end__c,
                    (SELECT Name, SBQQ__ProductFamily__c, SBQQ__ListPrice__c, SBQQ__NetTotal__c, SBQQ__Description__c,
                            SBQQ__Group__r.Name, SBQQ__Quantity__c, Days__c, SBQQ__SubscriptionTerm__c, Ancestor__c
                     FROM SBQQ__LineItems__r),
                    (SELECT Name, Id, SBQQ__NetTotal__c FROM SBQQ__LineItemGroups__r)
                FROM SBQQ__Quote__c
                WHERE Id = :ApexPages.currentPage().getParameters().get('id')];

        docType = quote.Stage__c;

        groupMap        = new Map<String,Map<String,List<SBQQ__QuoteLine__c>>>();
        groupSummary    = new Map<String,Decimal>();
        groupLineCount  = new Map<String,Integer>();

                Set<Id> currentIds = new Set<Id>();
        Set<Id> ancestorIds = new Set<Id>();

        // establish maps
        if (quote.SBQQ__LineItemsGrouped__c) {
            for (SBQQ__QuoteLineGroup__c lineGroup : [SELECT Name
                                                    FROM SBQQ__QuoteLineGroup__c
                                                    WHERE SBQQ__Quote__c = :quote.Id]) {
                Map<String, List<SBQQ__QuoteLine__c>> changeMap = new Map<String, List<SBQQ__QuoteLine__c>>();
                changeMap.put('Default', new List<SBQQ__QuoteLine__c>());
                changeMap.put('Added', new List<SBQQ__QuoteLine__c>());
                changeMap.put('Removed', new List<SBQQ__QuoteLine__c>());

                groupMap.put(lineGroup.Name, changeMap);
                groupSummary.put(lineGroup.Name, 0);
                groupLineCount.put(lineGroup.Name, 0);
            }

        } else {
            for (SBQQ__QuoteLine__c line : quote.SBQQ__LineItems__r) {
                if (!groupMap.containsKey(line.SBQQ__ProductFamily__c)) {
                    Map<String, List<SBQQ__QuoteLine__c>> changeMap = new Map<String, List<SBQQ__QuoteLine__c>>();
                    changeMap.put('Default', new List<SBQQ__QuoteLine__c>());
                    changeMap.put('Added', new List<SBQQ__QuoteLine__c>());
                    changeMap.put('Removed', new List<SBQQ__QuoteLine__c>());
                    groupMap.put(line.SBQQ__ProductFamily__c, changeMap);
                }
                if (!groupSummary.containsKey(line.SBQQ__ProductFamily__c)) {
                    groupSummary.put(line.SBQQ__ProductFamily__c, 0);
                    groupLineCount.put(line.SBQQ__ProductFamily__c, 0);
                }
            }


        }

        Map<String, List<SBQQ__QuoteLine__c>> changeMap = new Map<String, List<SBQQ__QuoteLine__c>>();
        changeMap.put('Default', new List<SBQQ__QuoteLine__c>());
        changeMap.put('Added', new List<SBQQ__QuoteLine__c>());
        changeMap.put('Removed', new List<SBQQ__QuoteLine__c>());
        groupMap.put('Ungrouped', changeMap);
        groupSummary.put('Ungrouped', 0);
        groupLineCount.put('Ungrouped', 0);

        if (quote.SBQQ__LineItemsGrouped__c) {

            for (SBQQ__QuoteLine__c line : quote.SBQQ__LineItems__r){

                if (line.SBQQ__Group__c == null || line.SBQQ__Group__r.Name == null){
                    if (line.Ancestor__c == null){
                        groupMap.get('Ungrouped').get('Added').add(line);
                    } else {
                        groupMap.get('Ungrouped').get('Default').add(line);
                        ancestorIds.add(line.Ancestor__c);
                    }
                    groupSummary.put('Ungrouped', groupSummary.get('Ungrouped') + line.SBQQ__NetTotal__c);
                    groupLineCount.put('Ungrouped', groupLineCount.get('Ungrouped') + 1);
                } else {
                    if (line.Ancestor__c == null){
                        groupMap.get(line.SBQQ__Group__r.Name).get('Added').add(line);
                    } else {
                        groupMap.get(line.SBQQ__Group__r.Name).get('Default').add(line);
                        ancestorIds.add(line.Ancestor__c);
                    }
                    groupSummary.put(line.SBQQ__Group__r.Name, groupSummary.get(line.SBQQ__Group__r.Name) + line.SBQQ__NetTotal__c);
                    groupLineCount.put(line.SBQQ__Group__r.Name, groupLineCount.get(line.SBQQ__Group__r.Name) + 1);
                }
            }




        } else {
            for (SBQQ__QuoteLine__c line : quote.SBQQ__LineItems__r){
                if (line.Ancestor__c == null){
                    groupMap.get(line.SBQQ__ProductFamily__c).get('Added').add(line);
                } else {
                    groupMap.get(line.SBQQ__ProductFamily__c).get('Default').add(line);
                    ancestorIds.add(line.Ancestor__c);
                }
                groupSummary.put(line.SBQQ__ProductFamily__c, groupSummary.get(line.SBQQ__ProductFamily__c) + line.SBQQ__NetTotal__c);
                groupLineCount.put(line.SBQQ__ProductFamily__c, groupLineCount.get(line.SBQQ__ProductFamily__c) + 1);

            }
        }


        if (quote.Ancestor__c  != null){

            for (SBQQ__QuoteLine__c line : [SELECT Name, SBQQ__ProductFamily__c, SBQQ__ListPrice__c, SBQQ__NetTotal__c,
                                                    SBQQ__Description__c, SBQQ__Group__r.Name, SBQQ__Quantity__c, Days__c,
                                                    SBQQ__SubscriptionTerm__c, Ancestor__c
                                            FROM SBQQ__QuoteLine__c
                                            WHERE SBQQ__Quote__c = :quote.Ancestor__c
                                            AND Id NOT IN :ancestorIds]){
                if (quote.SBQQ__LineItemsGrouped__c) {
                    if (line.SBQQ__Group__r.Name == null || line.SBQQ__Group__c == null) {
                        groupMap.get('Ungrouped').get('Removed').add(line);

                    } else {
                        groupMap.get(line.SBQQ__Group__r.Name).get('Removed').add(line);

                    }
                } else {
                    groupMap.get(line.SBQQ__ProductFamily__c).get('Removed').add(line);
                }


            }


        }

        if (ApexPages.currentPage().getParameters().get('invoices') == 'true'){
            invoices = [SELECT Id, Amount__c, Send_Date__c, Invoice_Sent__c, Invoice_Paid__c, Status2__c
                        FROM Invoice_Schedule__c WHERE Opportunity__c = :quote.SBQQ__Opportunity2__c
                        ORDER BY Invoice_Id__c ASC];
        }


        if (quote.Stage__c == 'Estimate'){
            theme = '#4b9a99';
            theme2 = '#d43b8f';
        } else if (quote.Stage__c == 'Contract'){
            theme = '#2c7495';
            theme2 = '#d43b8f';
        } else {
            theme = '#d43b8f';
            theme2 = '#4b9a99';
        }

    }

}