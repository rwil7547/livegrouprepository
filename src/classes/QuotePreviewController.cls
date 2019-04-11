/**
 * Created by Ronan Williams on 19/12/2018.
 */

public class QuotePreviewController {

    public SBQQ__Quote__c quote {get; set;}
    public List<SBQQ__QuoteLine__c> lines {get;set;}
    public String docType {get; set;}
    public String amendment {get; set;}
    public String ancestorName {get; set;}

    public List<String> groups {get;set;}
    public Map<String,Map<String,List<SBQQ__QuoteLine__c>>> groupMap {get; set;}
    public Map<String,Decimal> groupSummary {get; set;}
    public Map<String,Integer> groupLineCount {get; set;}

    public Map<String,SBQQ__QuoteLine__c> changeMap {get; set;}
    public Map<String,String> groupAncestorMap {get;set;}

    public List<String> optionalGroups {get;set;}
    public Map<String,Map<String,List<SBQQ__QuoteLine__c>>> optionalGroupMap {get; set;}
    public Map<String,Decimal> optionalGroupSummary {get; set;}
    public Map<String,Integer> optionalLineCount {get; set;}

    public List<Invoice_Schedule__c> invoices {get; set;}

    public User user {get; set;}
    public String userSignature {get; set;}
    public Contact contact {get; set;}
    public Boolean contactSign {get;set;}

    public String theme {get; set;}
    public String theme2 {get; set;}
    public String theme3 {get; set;}

    public Boolean showOptionals {get; set;}
    public Boolean showOptionalsSummary {get; set;}
    public Boolean breakPage {get; set;}
    public Boolean showVAT {get; set;}
    public Boolean showSLA {get; set;}
    public Boolean showTnCs {get; set;}

    public Boolean isSOW {get; set;}
    public Boolean trackChanges {get; set;}
    public Boolean draft {get; set;}

    public QuotePreviewController(){

        System.debug(ApexPages.currentPage().getParameters());

        showOptionals           = (ApexPages.currentPage().getParameters().get('optionals') == 'true') ? true : false;
        showOptionalsSummary    = (ApexPages.currentPage().getParameters().get('optSummary') == 'true') ? true : false;
        breakPage               = (ApexPages.currentPage().getParameters().get('breakPage') == 'true') ? true : false;
        showVAT                 = (ApexPages.currentPage().getParameters().get('vat') == 'true') ? true : false;
        showSLA                 = (ApexPages.currentPage().getParameters().get('sla') == 'true') ? true : false;
        showTnCs                = (ApexPages.currentPage().getParameters().get('tnc') == 'true') ? true : false;
        draft                   = (ApexPages.currentPage().getParameters().get('draft') == 'true') ? true : false;
        isSOW                   = (ApexPages.currentPage().getParameters().get('isSOW') == 'true') ? true : false;
        contactSign             = (ApexPages.currentPage().getParameters().get('signed') == 'true') ? true : false;

        user = [SELECT Id, Name, Title, FirstName, LastName, Phone, MobilePhone, Email
                FROM User
                WHERE Id = :ApexPages.currentPage().getParameters().get('userId')];

        if (!Test.isRunningTest()){
            String signatureName = user.FirstName + user.LastName;
            List<StaticResource> sr = [SELECT Id, Body FROM StaticResource WHERE Name = :signatureName LIMIT 1];
            if (!sr.isEmpty()){
                String myUrl = PageReference.forResource(signatureName).getUrl();
                userSignature = myUrl.subString(0, myUrl.indexOf('?'));
            }
        }

        contact = [SELECT Id, Name, FirstName, LastName, Account.Name, MailingStreet, MailingCity, MailingCountry, MailingPostalCode,
                            Email, Phone, MobilePhone, Title
                    FROM Contact
                    WHERE Id = :ApexPages.currentPage().getParameters().get('contactId')];

        // split contact email string if too long to fit in right hand panel of page
        if (contact.Email != null && contact.Email.length() > 28){
            String startString  = contact.Email.substring(0,28);
            String endString    = contact.Email.substring(28);
            contact.Email       = startString + '-\n' + endString;
        }

        quote = [SELECT Id, Name, Version__c, SBQQ__LineItemsGrouped__c, SBQQ__Opportunity2__r.Name,
                        SBQQ__Opportunity2__r.Filtered_Job_Number__c, Stage__c, Ancestor__c, Proposal_Introduction__c,
                        SBQQ__NetAmount__c, Optional_total__c, SBQQ__Opportunity2__r.Venue__c, SBQQ__Opportunity2__r.Location__c,
                        SBQQ__Opportunity2__r.Event_start__c, SBQQ__Opportunity2__r.Event_end__c,
                        SOW_Entity_Name__c, SOW_Entity_Name_Caps__c, SOWDate__c, SOW_Services__c,
                        SBQQ__Opportunity2__r.Project_Manager__r.Name,
                    (SELECT Name, Id, SBQQ__NetTotal__c FROM SBQQ__LineItemGroups__r ORDER BY SBQQ__Number__c ASC)
                FROM SBQQ__Quote__c
                WHERE Id = :ApexPages.currentPage().getParameters().get('id')];

        lines = [SELECT Name, SBQQ__ProductFamily__c, SBQQ__ListPrice__c, SBQQ__NetTotal__c, SBQQ__Description__c,
                SBQQ__Group__r.Name, SBQQ__Quantity__c, Days__c, SBQQ__SubscriptionTerm__c, Ancestor__c,
                AncestorDescription__c, AncestorQuantity__c, AncestorDays__c, AncestorPrice__c, AncestorTotal__c,
                Changed__c, FiguresChanged__c, Added__c, SBQQ__Optional__c,SBQQ__AdditionalDiscountAmount__c
                FROM SBQQ__QuoteLine__c
                WHERE SBQQ__Quote__c = :quote.Id
                AND SBQQ__Hidden__c != TRUE
                ORDER BY SBQQ__Number__c ASC];

        quote.Proposal_Introduction__c = ApexPages.currentPage().getParameters().get('text');

        docType = quote.Stage__c;

        groups          = new List<String>();
        groupMap        = new Map<String,Map<String,List<SBQQ__QuoteLine__c>>>();
        groupSummary    = new Map<String,Decimal>();
        groupLineCount  = new Map<String,Integer>();

        if (showOptionals || showOptionalsSummary){
            optionalGroups        = new List<String>();
            optionalGroupMap      = new Map<String,Map<String,List<SBQQ__QuoteLine__c>>>();
            optionalGroupSummary  = new Map<String,Decimal>();
            optionalLineCount     = new Map<String,Integer>();
        }

        if (isSOW){
            quote.SOW_Entity_Name__c = ApexPages.currentPage().getParameters().get('SOWEntity');
            quote.SOWDate__c         = Date.valueOf(ApexPages.currentPage().getParameters().get('SOWDate'));
            quote.SOW_Services__c    = ApexPages.currentPage().getParameters().get('SOWServices');
            amendment = '& Statement of Work for ' + quote.SOW_Entity_Name__c;

        }

        if (quote.Stage__c != 'Estimate' && quote.Version__c !=  'Contract'){

            trackChanges = true;

            system.debug('Setting tracked changes to true');

            if (quote.Stage__c == 'Contract' && quote.Version__c !=  'Contract'){
                amendment = (amendment != null) ? quote.Version__c.replace('Contract ','') + ' ' + amendment
                            : quote.Version__c.replace('Contract ','');
                quote.Version__c = 'Contract';
            }

            changeMap = new Map<String,SBQQ__QuoteLine__c>();
            groupAncestorMap = new Map<String,String>();

            for (SBQQ__QuoteLine__c line : [SELECT Name, SBQQ__ProductFamily__c, SBQQ__ListPrice__c, SBQQ__NetTotal__c,
                                                    SBQQ__Description__c, SBQQ__Group__r.Name, SBQQ__Quantity__c, Days__c,
                                                    SBQQ__SubscriptionTerm__c, Ancestor__c, SBQQ__Optional__c
                                            FROM SBQQ__QuoteLine__c
                                            WHERE SBQQ__Quote__c = :quote.Ancestor__c
                                            AND SBQQ__Optional__c = FALSE
                                            AND SBQQ__Hidden__c = FALSE]){
                changeMap.put(line.Id, line);
            }

            if (quote.Ancestor__c != null){
                ancestorName = [SELECT Version__c FROM SBQQ__Quote__c WHERE Id = :quote.Ancestor__c].Version__c;
                if (ancestorName == 'Contract'){
                    ancestorName = 'initial Contract';
                }
            }
        } else {
            trackChanges = false;
        }

        Set<Id> ancestorIds = new Set<Id>();

        // establish maps to hold values for line items, line item count and group total values
        if (quote.SBQQ__LineItemsGrouped__c) {
            for (SBQQ__QuoteLineGroup__c lineGroup : [SELECT Name, AncestorName__c
                                                    FROM SBQQ__QuoteLineGroup__c
                                                    WHERE SBQQ__Quote__c = :quote.Id
                                                    ORDER BY SBQQ__Number__c ASC]) {
                groups.add(lineGroup.Name);
                Map<String, List<SBQQ__QuoteLine__c>> changeMap = new Map<String, List<SBQQ__QuoteLine__c>>();
                changeMap.put('Removed', new List<SBQQ__QuoteLine__c>());
                changeMap.put('Default', new List<SBQQ__QuoteLine__c>());
                groupMap.put(lineGroup.Name, changeMap);
                groupSummary.put(lineGroup.Name, 0);
                groupLineCount.put(lineGroup.Name, 0);

                if (trackChanges && lineGroup.AncestorName__c != null){
                    groupAncestorMap.put(lineGroup.AncestorName__c, lineGroup.Name);
                }

                if (showOptionals || showOptionalsSummary){
                    optionalGroups.add(lineGroup.Name);
                    Map<String, List<SBQQ__QuoteLine__c>> optionalChangeMap = new Map<String, List<SBQQ__QuoteLine__c>>();
                    optionalChangeMap.put('Removed', new List<SBQQ__QuoteLine__c>());
                    optionalChangeMap.put('Default', new List<SBQQ__QuoteLine__c>());
                    optionalGroupMap.put(lineGroup.Name, optionalChangeMap);
                    optionalGroupSummary.put(lineGroup.Name, 0);
                    optionalLineCount.put(lineGroup.Name, 0);
                }
            }
        } else {

            Schema.DescribeFieldResult productFamilies = Product2.Family.getDescribe();
            List<Schema.PicklistEntry> picklistEntries = productFamilies.getPicklistValues();

            for (Schema.PicklistEntry entry : picklistEntries){
                groups.add(entry.getLabel());
                Map<String, List<SBQQ__QuoteLine__c>> changeMap = new Map<String, List<SBQQ__QuoteLine__c>>();
                changeMap.put('Default', new List<SBQQ__QuoteLine__c>());
                changeMap.put('Removed', new List<SBQQ__QuoteLine__c>());
                groupMap.put(entry.getLabel(), changeMap);
                groupSummary.put(entry.getLabel(), 0);
                groupLineCount.put(entry.getLabel(), 0);
                if (showOptionals || showOptionalsSummary){
                    optionalGroups.add(entry.getLabel());
                    Map<String, List<SBQQ__QuoteLine__c>> optionalChangeMap = new Map<String, List<SBQQ__QuoteLine__c>>();
                    optionalChangeMap.put('Default', new List<SBQQ__QuoteLine__c>());
                    optionalGroupMap.put(entry.getLabel(), optionalChangeMap);
                    optionalGroupSummary.put(entry.getLabel(), 0);
                    optionalLineCount.put(entry.getLabel(), 0);
                }
            }
        }

        Map<String, List<SBQQ__QuoteLine__c>> ungroupedMap = new Map<String, List<SBQQ__QuoteLine__c>>();
        ungroupedMap.put('Default', new List<SBQQ__QuoteLine__c>());
        ungroupedMap.put('Removed', new List<SBQQ__QuoteLine__c>());

        groupMap.put('Ungrouped', ungroupedMap);
        groupSummary.put('Ungrouped', 0);
        groupLineCount.put('Ungrouped', 0);

        if (showOptionals){
            optionalGroupMap.put('Ungrouped', ungroupedMap.clone());
            optionalGroupSummary.put('Ungrouped', 0);
            optionalLineCount.put('Ungrouped', 0);
        }


        // assign all lines and their values to the relevant maps
        if (quote.SBQQ__LineItemsGrouped__c) {
//            for (SBQQ__QuoteLine__c line : quote.SBQQ__LineItems__r){
            for (SBQQ__QuoteLine__c line : lines){
                if (!line.SBQQ__Optional__c){

                    if (line.SBQQ__Group__c == null || line.SBQQ__Group__r.Name == null){
                        if (line.Ancestor__c == null && trackChanges){
                            line.Added__c = true;
                            groupMap.get('Ungrouped').get('Default').add(line);
                        } else {
                            groupMap.get('Ungrouped').get('Default').add(line);
                            ancestorIds.add(line.Ancestor__c);
                        }
                        groupSummary.put('Ungrouped', groupSummary.get('Ungrouped') + line.SBQQ__NetTotal__c);
                        groupLineCount.put('Ungrouped', groupLineCount.get('Ungrouped') + 1);
                    } else {

                        if (changeMap != null && changeMap.containsKey(line.Ancestor__c)){

                            system.debug('found a line which has changed');

                            SBQQ__QuoteLine__c oldLine = changeMap.get(line.Ancestor__c);
                            if (oldLine.SBQQ__Description__c != line.SBQQ__Description__c){
                                line.AncestorDescription__c = oldLine.SBQQ__Description__c;
                                line.Changed__c             = true;
                            }
                            if (oldLine.SBQQ__SubscriptionTerm__c != line.SBQQ__SubscriptionTerm__c ||
                                    oldLine.SBQQ__Quantity__c != line.SBQQ__Quantity__c ||
                                    oldLine.SBQQ__ListPrice__c != line.SBQQ__ListPrice__c){
                                line.Changed__c             = true;
                                line.FiguresChanged__c      = true;
                                line.AncestorDays__c        = oldLine.SBQQ__SubscriptionTerm__c;
                                line.AncestorQuantity__c    = oldLine.SBQQ__Quantity__c;
                                line.AncestorPrice__c       = oldLine.SBQQ__ListPrice__c;
                                line.AncestorTotal__c       = oldLine.SBQQ__NetTotal__c;
                            }
                        }

                        if (line.Ancestor__c == null && trackChanges){
                            line.Added__c = true;
                            groupMap.get(line.SBQQ__Group__r.Name).get('Default').add(line);
                        } else {
                            groupMap.get(line.SBQQ__Group__r.Name).get('Default').add(line);
                            ancestorIds.add(line.Ancestor__c);
                        }
                        groupSummary.put(line.SBQQ__Group__r.Name, groupSummary.get(line.SBQQ__Group__r.Name) + line.SBQQ__NetTotal__c);
                        groupLineCount.put(line.SBQQ__Group__r.Name, groupLineCount.get(line.SBQQ__Group__r.Name) + 1);
                    }
                } else if (showOptionals || showOptionalsSummary){
                    if (line.SBQQ__Group__c == null || line.SBQQ__Group__r.Name == null){
                        optionalGroupMap.get('Ungrouped').get('Default').add(line);
                        optionalGroupSummary.put('Ungrouped', optionalGroupSummary.get('Ungrouped') + line.SBQQ__NetTotal__c);
                        optionalLineCount.put('Ungrouped', optionalLineCount.get('Ungrouped') + 1);
                    } else {
                        optionalGroupMap.get(line.SBQQ__Group__r.Name).get('Default').add(line);
                        optionalGroupSummary.put(line.SBQQ__Group__r.Name, optionalGroupSummary.get(line.SBQQ__Group__r.Name) + line.SBQQ__NetTotal__c);
                        optionalLineCount.put(line.SBQQ__Group__r.Name, optionalLineCount.get(line.SBQQ__Group__r.Name) + 1);
                    }
                }
            }

        } else {
//            for (SBQQ__QuoteLine__c line : quote.SBQQ__LineItems__r){
            for (SBQQ__QuoteLine__c line : lines){
                if (!line.SBQQ__Optional__c) {
                    if (line.Ancestor__c == null && trackChanges) {
                        line.Added__c = true;
                        groupMap.get(line.SBQQ__ProductFamily__c).get('Default').add(line);
                    } else {

                        if (changeMap != null && changeMap.containsKey(line.Ancestor__c)) {
                            SBQQ__QuoteLine__c oldLine = changeMap.get(line.Ancestor__c);
                            if (oldLine.SBQQ__Description__c != line.SBQQ__Description__c) {
                                line.AncestorDescription__c = oldLine.SBQQ__Description__c;
                                line.Changed__c = true;
                            }
                            if (oldLine.SBQQ__SubscriptionTerm__c != line.SBQQ__SubscriptionTerm__c ||
                                    oldLine.SBQQ__Quantity__c != line.SBQQ__Quantity__c ||
                                    oldLine.SBQQ__ListPrice__c != line.SBQQ__ListPrice__c) {
                                line.Changed__c = true;
                                line.FiguresChanged__c = true;
                                line.AncestorDays__c = oldLine.SBQQ__SubscriptionTerm__c;
                                line.AncestorQuantity__c = oldLine.SBQQ__Quantity__c;
                                line.AncestorPrice__c = oldLine.SBQQ__ListPrice__c;
                                line.AncestorTotal__c = oldLine.SBQQ__NetTotal__c;
                            }
                        }

                        groupMap.get(line.SBQQ__ProductFamily__c).get('Default').add(line);
                        ancestorIds.add(line.Ancestor__c);
                    }
                    groupSummary.put(line.SBQQ__ProductFamily__c, groupSummary.get(line.SBQQ__ProductFamily__c) + line.SBQQ__NetTotal__c);
                    groupLineCount.put(line.SBQQ__ProductFamily__c, groupLineCount.get(line.SBQQ__ProductFamily__c) + 1);
                } else if (showOptionals || showOptionalsSummary) {
                    optionalGroupMap.get(line.SBQQ__ProductFamily__c).get('Default').add(line);
                    optionalGroupSummary.put(line.SBQQ__ProductFamily__c, optionalGroupSummary.get(line.SBQQ__ProductFamily__c) + line.SBQQ__NetTotal__c);
                    optionalLineCount.put(line.SBQQ__ProductFamily__c, optionalLineCount.get(line.SBQQ__ProductFamily__c) + 1);
                }
            }
        }

        if (quote.Stage__c != 'Estimate' && trackChanges) {
            for (SBQQ__QuoteLine__c line : changeMap.values()){
                if (!ancestorIds.contains(line.Id)){
                    if (quote.SBQQ__LineItemsGrouped__c) {
                        if (line.SBQQ__Group__r.Name == null || line.SBQQ__Group__c == null) {
                            groupMap.get('Ungrouped').get('Removed').add(line);
                        } else if (groupMap.containsKey(line.SBQQ__Group__r.Name)){
                            groupMap.get(line.SBQQ__Group__r.Name).get('Removed').add(line);
                        } else if (groupAncestorMap.containsKey(line.SBQQ__Group__r.Name)) {
                            String currentGroupName = groupAncestorMap.get(line.SBQQ__Group__r.Name);
                            groupMap.get(currentGroupName).get('Removed').add(line);
                        } else {
                            Map<String, List<SBQQ__QuoteLine__c>> deletedGroupedMap = new Map<String, List<SBQQ__QuoteLine__c>>();
                            deletedGroupedMap.put('Default', new List<SBQQ__QuoteLine__c>());
                            deletedGroupedMap.put('Removed', new List<SBQQ__QuoteLine__c>());
                            groupMap.put(line.SBQQ__Group__r.Name, deletedGroupedMap);
                            groupSummary.put(line.SBQQ__Group__r.Name, 0);
                            groupLineCount.put(line.SBQQ__Group__r.Name, 0);
                            groupMap.get(line.SBQQ__Group__r.Name).get('Removed').add(line);
                        }
                    } else {
                        if (groupMap.containsKey(line.SBQQ__ProductFamily__c)){
                            groupMap.get(line.SBQQ__ProductFamily__c).get('Removed').add(line);
                        } else {
                            Map<String, List<SBQQ__QuoteLine__c>> deletedFamilyMap = new Map<String, List<SBQQ__QuoteLine__c>>();
                            deletedFamilyMap.put('Default', new List<SBQQ__QuoteLine__c>());
                            deletedFamilyMap.put('Removed', new List<SBQQ__QuoteLine__c>());
                            groupMap.put(line.SBQQ__ProductFamily__c, deletedFamilyMap);
                            groupSummary.put(line.SBQQ__ProductFamily__c, 0);
                            groupLineCount.put(line.SBQQ__ProductFamily__c, 0);
                            groupMap.get(line.SBQQ__ProductFamily__c).get('Removed').add(line);
                        }
                    }
                }
            }
        }

        for (String groupKey : groupMap.keySet()){
            if (groupMap.get(groupKey).get('Default').isEmpty()){
                groupMap.get(groupKey).remove('Default');
            }
            if (groupMap.get(groupKey).get('Removed').isEmpty()){
                groupMap.get(groupKey).remove('Removed');
            }
            if (groupMap.get(groupKey).isEmpty()){
                groupMap.remove(groupKey);
                groupSummary.remove(groupKey);
                groupLineCount.remove(groupKey);
            }
        }

        Integer groupCount = groups.size();
        for (Integer x = 0;x < groupCount; x++){
            if(!groupMap.containsKey(groups[x])){
                groups.set(x,null);
            }
        }

        if (showOptionals || showOptionalsSummary){
            for (String optionalKey : optionalGroupMap.keySet()){
                if (optionalGroupMap.get(optionalKey).get('Default').isEmpty()){
                    optionalGroupMap.remove(optionalKey);
                    optionalGroupSummary.remove(optionalKey);
                    optionalLineCount.remove(optionalKey);
                }
            }
            for (Integer x = 0;x < groupCount; x++){
                if(!optionalGroupMap.containsKey(optionalGroups[x])){
                    optionalGroups.set(x,null);
                }
            }
        }

        if (ApexPages.currentPage().getParameters().get('invoices') == 'true'){
            invoices = [SELECT Id, Amount__c, Send_Date__c, Invoice_Sent__c, Invoice_Paid__c, Status2__c
                        FROM Invoice_Schedule__c WHERE Opportunity__c = :quote.SBQQ__Opportunity2__c
                        ORDER BY Invoice_Id__c ASC];

        }

        if (quote.Stage__c == 'Estimate'){
            theme = '#66C1BF';
            theme2 = '#d43b8f';
            theme3 = '#2c7495';
        } else if (quote.Stage__c == 'Contract'){
            theme = '#2c7495';
            theme2 = '#d43b8f';
            theme3 = '#66C1BF';
        } else {
            theme = '#d43b8f';
            theme2 = '#66C1BF';
            theme3 = '#2c7495';
        }

    }

}