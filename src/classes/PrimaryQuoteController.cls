/**
 * Created by Ronan Williams on 23/11/2018.
 */

public with sharing class PrimaryQuoteController {

    @AuraEnabled
    public static List<SBQQ__Quote__c> getQuote(String oppId, String quoteId){

        String quoteQuery = (quoteId != 'default') ? ' AND Id = :quoteId ' : '';

        return (List<SBQQ__Quote__c>) Database.query('SELECT Id, Version__c, SBQQ__Status__c, SBQQ__NetAmount__c, ' +
                        'Cost_of_sale__c, Gross_Margin__c, Stage__c, Gross_Profit__c, SBQQ__Primary__c, Proposal_Introduction__c,' +
                        'Proposal_Conclusion__c, SBQQ__Opportunity2__r.Account.Name, ' +
                        'SBQQ__LineItemsGrouped__c, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.Name, Event_End__c, ' +
                        '(SELECT Id, SBQQ__OutputFormat__c FROM SBQQ__R00N70000001lX7YEAU__r ' +
                        'ORDER BY CreatedDate), ' +
                        '(SELECT Id FROM SBQQ__LineItems__r), ' +
                        '(SELECT Id FROM SBQQ__LineItemGroups__r) ' +
                        'FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :oppId ' + quoteQuery +
                        'ORDER BY SBQQ__Primary__c DESC, CreatedDate DESC LIMIT 1');

    }

    @AuraEnabled
    public static SBQQ__Quote__c getRefreshApex(String quoteId){

        return [SELECT Id, SBQQ__NetAmount__c, Gross_Profit__c, Gross_Margin__c
                FROM SBQQ__Quote__c WHERE Id = :quoteId];

    }

    @AuraEnabled
    public static List<Object> getQuoteGroups(String Id, Boolean custom){

        if (custom){
            return [SELECT Id, Name, SBQQ__NetTotal__c,
                        (SELECT Id, SBQQ__ProductFamily__c, SBQQ__Product__r.Name, SBQQ__Quantity__c,
                            SBQQ__UnitCost__c, Line_cost_total__c, Days__c, SBQQ__Optional__c,
                            SBQQ__Product__r.SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionTerm__c,
                            SBQQ__ListPrice__c, SBQQ__NetTotal__c, SBQQ__Description__c
                        FROM SBQQ__LineItems__r)
                    FROM SBQQ__QuoteLineGroup__c
                    WHERE SBQQ__Quote__c = :Id];
        } else {

            Map<String,List<SBQQ__QuoteLine__c>> groupMap = new Map<String,List<SBQQ__QuoteLine__c>>();

            for (SBQQ__QuoteLine__c line : [SELECT Id, SBQQ__ProductFamily__c, SBQQ__Product__r.Name, SBQQ__Quantity__c,
                                                    SBQQ__UnitCost__c, Line_cost_total__c, Days__c,
                                                    SBQQ__Product__r.SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionTerm__c,
                                                    SBQQ__ListPrice__c, SBQQ__NetTotal__c, SBQQ__Description__c
                                            FROM SBQQ__QuoteLine__c
                                            WHERE SBQQ__Quote__c = :Id]){

                String family = (line.SBQQ__ProductFamily__c == null) ? 'Unclassified products' : line.SBQQ__ProductFamily__c;

                if (!groupMap.containsKey(family)){
                    groupMap.put(family, new List<SBQQ__QuoteLine__c>());
                }

                groupMap.get(family).add(line);
            }

            List<Object> results = new List<Object>();

            for (String familyName : groupMap.keySet()){

                String objString = '{ "Name" : "' + familyName + '", "Id" : "' + familyName.replaceAll('\\s+', '') + '", "SBQQ__LineItems__r": ' +
                        JSON.serialize(groupMap.get(familyName), true) + '}';
                Object obj = JSON.deserializeUntyped(objString);

                System.debug(objString);

                results.add(obj);
            }

            return results;
        }
    }

    @AuraEnabled
    public static List<Product2> getProducts(){

        return [SELECT Id, Name, Description, Family,
                (SELECT SBQQ__UnitCost__c FROM SBQQ__Costs__r
                WHERE SBQQ__Active__c = TRUE LIMIT 1),
                (SELECT UnitPrice FROM PricebookEntries
                WHERE Pricebook2.Name = 'Default')
                FROM Product2
                WHERE IsActive = TRUE
                ORDER BY Family];

    }

    @AuraEnabled
    public static List<String> getFamilies(){

        List<String> families = new List<String>();

        Schema.DescribeFieldResult fieldResult =
                Product2.Family.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for( Schema.PicklistEntry f : ple) {
            families.add(f.getValue());
        }

        return families;
    }

    @AuraEnabled
    public static String changeLineApex(SBQQ__QuoteLine__c line, String operation){

        String result = 'error';

        SBQQ__QuoteLine__c lineLock = [SELECT Id, SBQQ__ProductFamily__c, SBQQ__Product__r.Name, SBQQ__Quantity__c,
                                            SBQQ__UnitCost__c, Line_cost_total__c, Days__c, SBQQ__Optional__c,
                                            SBQQ__Product__r.SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionTerm__c,
                                            SBQQ__ListPrice__c, SBQQ__NetTotal__c, SBQQ__Description__c, SBQQ__Quote__c
                                        FROM SBQQ__QuoteLine__c
                                        WHERE Id = :line.Id
                                        LIMIT 1 FOR UPDATE];

        if (operation == 'save'){
            Database.SaveResult saveResult = Database.update(line);
            if (saveResult.isSuccess()){
                result = line.Id;
            }
        } else if (operation == 'clone'){
            SBQQ__QuoteLine__c clone = lineLock.clone(false,true,false,false);
            Database.SaveResult saveResult = Database.insert(clone);
            if (saveResult.isSuccess()){
                result = clone.Id;
            }
        } else if (operation == 'optional') {
            line.SBQQ__Optional__c = (line.SBQQ__Optional__c) ? false : true;
            Database.SaveResult saveResult = Database.update(line);
            if (saveResult.isSuccess()){
                result = line.Id;
            }
        } else if (operation == 'delete'){
            Database.DeleteResult deleteResult = Database.delete(line.Id);
            if (deleteResult.isSuccess()){
                result = line.Id;
            }
        }

        return result;
    }

    @AuraEnabled
    public static Boolean saveAllLinesApex(List<SBQQ__QuoteLine__c> lines){

        Boolean success = true;

        Database.SaveResult[] saveResult = Database.update(lines, true);
        for (Database.SaveResult result : saveResult){
            if (!result.isSuccess()){
                success = false;
                break;
            }
        }

        return success;

    }


    @AuraEnabled
    public static Boolean changeGroupNameApex(String Id, String name){

        Boolean result = false;

        SBQQ__QuoteLineGroup__c lineGroup = new SBQQ__QuoteLineGroup__c();
        lineGroup.Id = Id;
        lineGroup.Name = name;

        Database.SaveResult saveResult = Database.update(lineGroup);
        if (saveResult.isSuccess()){
            result = true;
        }

        return result;
    }

    @AuraEnabled
    public static SBQQ__QuoteLineGroup__c cloneGroupApex(String quoteId, String groupId){

        Savepoint sp = Database.setSavepoint();

        SBQQ__QuoteLineGroup__c originalGroup = [SELECT Id, Name, SBQQ__NetTotal__c,
                                                (SELECT Id, SBQQ__ProductFamily__c, SBQQ__Product__r.Name, SBQQ__Quantity__c,
                                                        SBQQ__UnitCost__c, Line_cost_total__c, Days__c,
                                                        SBQQ__Product__r.SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionTerm__c,
                                                        SBQQ__ListPrice__c, SBQQ__NetTotal__c, SBQQ__Description__c
                                                FROM SBQQ__LineItems__r)
                                                FROM SBQQ__QuoteLineGroup__c
                                                WHERE Id = :groupId];


        SBQQ__QuoteLineGroup__c cloneGroup = new SBQQ__QuoteLineGroup__c();
        cloneGroup.Name             = originalGroup.Name + ' (clone)';
        cloneGroup.SBQQ__Quote__c   = quoteId;

        Database.SaveResult cloneInsert = Database.insert(cloneGroup);
        if (!cloneInsert.isSuccess()){
            return null;
        }

        List<SBQQ__QuoteLine__c> lineClones = originalGroup.SBQQ__LineItems__r.deepClone(false);
        for (SBQQ__QuoteLine__c line : lineClones){
            line.SBQQ__Group__c = cloneGroup.Id;
            line.SBQQ__Quote__c = quoteId;
        }

        Database.SaveResult[] lineInserts = Database.insert(lineClones, true);
        for (Database.SaveResult result : lineInserts){
            if (!result.isSuccess()){
                Database.rollback(sp);
                return null;
            }
        }

        return [SELECT Id, Name, SBQQ__NetTotal__c,
                (SELECT Id, SBQQ__ProductFamily__c, SBQQ__Product__r.Name, SBQQ__Quantity__c,
                        SBQQ__UnitCost__c, Line_cost_total__c, Days__c,
                        SBQQ__Product__r.SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionTerm__c,
                        SBQQ__ListPrice__c, SBQQ__NetTotal__c, SBQQ__Description__c
                FROM SBQQ__LineItems__r)
                FROM SBQQ__QuoteLineGroup__c
                WHERE Id = :cloneGroup.Id];

    }

    @AuraEnabled
    public static SBQQ__QuoteLineGroup__c insertNewGroupApex(String quoteId, Integer groupCount){

        SBQQ__QuoteLineGroup__c newGroup = new SBQQ__QuoteLineGroup__c();
        newGroup.SBQQ__Quote__c          = quoteId;
        newGroup.Name                    = 'Group' + String.valueOf(groupCount + 1);

        Database.SaveResult saveResult = Database.insert(newGroup);
        if (!saveResult.isSuccess()){
            return null;
        }

        return newGroup;
    }

    @AuraEnabled
    public static Boolean deleteGroupApex(String groupId){

        Boolean result = false;

        SBQQ__QuoteLineGroup__c lineGroup   = new SBQQ__QuoteLineGroup__c(Id = groupId);
        List<SBQQ__QuoteLine__c> lines  = [SELECT Id FROM SBQQ__QuoteLine__c
                                           WHERE SBQQ__Group__c = :groupId];

        Savepoint sp = Database.setSavepoint();

        Database.DeleteResult deleteGroupResult     = Database.delete(lineGroup);
        Database.DeleteResult[] deleteLinesResults  = Database.delete(lines, true);
        Boolean lineDeleteSuccess                   = true;


        for (Database.DeleteResult lineDelete : deleteLinesResults){
            if (!lineDelete.isSuccess()){
                lineDeleteSuccess = false;
            }
        }

        if (deleteGroupResult.isSuccess() && lineDeleteSuccess){
            result = true;
        } else {
            Database.rollback(sp);
        }

        return result;
    }

    @AuraEnabled
    public static Boolean ungroupLinesApex(String quoteId){

        Savepoint sp = Database.setSavepoint();

        Database.DeleteResult[] deleteResults = Database.delete(
                        [SELECT Id FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :quoteId], true);

        for (Database.DeleteResult deleteResult : deleteResults){
            if (!deleteResult.isSuccess()){
                Database.rollback(sp);
                return false;
            }
        }

        Database.SaveResult quoteUpdate = Database.update(
        new SBQQ__Quote__c(Id= quoteId, SBQQ__LineItemsGrouped__c = false));

        if (!quoteUpdate.isSuccess()){
            Database.rollback(sp);
            return false;
        }

        return true;

    }

    @AuraEnabled
    public static Boolean groupLinesApex(String quoteId){

        Database.SaveResult quoteUpdate = Database.update(
                new SBQQ__Quote__c(
                        Id = quoteId,
                        SBQQ__LineItemsGrouped__c = true
                )
        );

        if (!quoteUpdate.isSuccess()){
            return false;
        }

        return true;

    }


    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> insertGroupedLinesApex(String quoteId, String groupId, List<String> productIds){

        Set<String> productIdSet = new Set<String>();
        productIdSet.addAll(productIds);

        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>();

        for (Product2 product : [SELECT Id, Name, Description, Family, SBQQ__SubscriptionTerm__c,
                                    (SELECT SBQQ__UnitCost__c FROM SBQQ__Costs__r
                                    WHERE SBQQ__Active__c = TRUE LIMIT 1),
                                    (SELECT UnitPrice FROM PricebookEntries
                                    WHERE Pricebook2.Name = 'Default')
                                   FROM Product2 WHERE Id IN :productIdSet]){

            lines.add(
                new SBQQ__QuoteLine__c(
                    SBQQ__Product__c        = product.Id,
                    SBQQ__Description__c    = product.Description,
                    SBQQ__SubscriptionTerm__c = (product.SBQQ__SubscriptionTerm__c != null) ? 1 : null,
                    SBQQ__Quantity__c       = 1,
                    SBQQ__UnitCost__c       = product.SBQQ__Costs__r[0].SBQQ__UnitCost__c,
                    SBQQ__ListPrice__c      = product.PricebookEntries[0].UnitPrice,
                    SBQQ__Group__c          = groupId,
                    SBQQ__Quote__c          = quoteId
                )
            );
        }

        Database.SaveResult[] results = Database.insert(lines,true);
        Boolean success   = true;
        Set<Id> lineIdSet = new Set<Id>();

        for (Database.SaveResult result : results){
            if (!result.isSuccess()){
                success = false;
            }
        }

        if (success){
            for (SBQQ__QuoteLine__c line : lines){
                lineIdSet.add(line.Id);
            }

            return [SELECT Id, SBQQ__ProductFamily__c, SBQQ__Product__r.Name, SBQQ__Quantity__c,
                        SBQQ__UnitCost__c, Line_cost_total__c, Days__c, SBQQ__SubscriptionTerm__c,
                        SBQQ__Product__r.SBQQ__SubscriptionTerm__c,
                        SBQQ__ListPrice__c, SBQQ__NetTotal__c, SBQQ__Description__c
                    FROM SBQQ__QuoteLine__c
                    WHERE Id IN :lineIdSet];

        } else {
            return null;
        }
    }


    @AuraEnabled
    public static Boolean insertUngroupedLinesApex(String quoteId, List<String> productIds){

        Set<String> productIdSet = new Set<String>();
        productIdSet.addAll(productIds);

        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>();

        for (Product2 product : [SELECT Id, Name, Description, Family, SBQQ__SubscriptionTerm__c,
                                (SELECT SBQQ__UnitCost__c FROM SBQQ__Costs__r
                                WHERE SBQQ__Active__c = TRUE LIMIT 1),
                                (SELECT UnitPrice FROM PricebookEntries
                                WHERE Pricebook2.Name = 'Default')
                                FROM Product2 WHERE Id IN :productIdSet]){

            lines.add(
                    new SBQQ__QuoteLine__c(
                            SBQQ__Product__c        = product.Id,
                            SBQQ__Description__c    = product.Description,
                            SBQQ__SubscriptionTerm__c = (product.SBQQ__SubscriptionTerm__c != null) ? 1 : null,
                            SBQQ__Quantity__c       = 1,
                            SBQQ__UnitCost__c       = (product.SBQQ__Costs__r[0].SBQQ__UnitCost__c == null)? 0 : product.SBQQ__Costs__r[0].SBQQ__UnitCost__c,
                            SBQQ__ListPrice__c      = (product.PricebookEntries[0].UnitPrice == null) ? 0 : product.PricebookEntries[0].UnitPrice,
                            SBQQ__Quote__c          = quoteId
                    )
            );
        }

        Database.SaveResult[] results = Database.insert(lines,true);
        Boolean success   = true;

        for (Database.SaveResult result : results){
            if (!result.isSuccess()){
                success = false;
            }
        }

        if (success){
            return true;
        } else {
            return false;
        }
    }

    @AuraEnabled
    public static String cloneEstimateApex(SBQQ__Quote__c quote, String oppId){

        String result   = 'error';
        Savepoint sp    = Database.setSavepoint();

        List<SBQQ__Quote__c> count = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :oppId];


        SBQQ__Quote__c cloneQuote           = quote.clone(false,true);
        cloneQuote.SBQQ__Opportunity2__c    = oppId;
        cloneQuote.Stage__c                 = 'Estimate';
        cloneQuote.Version__c               = 'Estimate ' + (count.size() + 1);

        Database.SaveResult quoteInsert     = Database.insert(cloneQuote);
        if (!quoteInsert.isSuccess()){
            return result;
        }

        Map<String,SBQQ__QuoteLineGroup__c> cloneGroups = new Map<String,SBQQ__QuoteLineGroup__c>();

        if (quote.SBQQ__LineItemsGrouped__c){

            List<SBQQ__QuoteLineGroup__c> existingGroups = [SELECT Id, Name, SBQQ__NetTotal__c
                                                            FROM SBQQ__QuoteLineGroup__c
                                                            WHERE SBQQ__Quote__c = :quote.Id];

            for (SBQQ__QuoteLineGroup__c lineGroup : existingGroups){
                SBQQ__QuoteLineGroup__c newGroup = lineGroup.clone(false,true);
                newGroup.SBQQ__Quote__c = cloneQuote.Id;
                cloneGroups.put(lineGroup.Id, newGroup);
            }

            Database.SaveResult[] groupInserts = Database.insert(cloneGroups.values(), true);
            for (Database.SaveResult groupInsert : groupInserts){
                if (!groupInsert.isSuccess()){
                    Database.rollback(sp);
                    return result;
                }
            }
        }

        List<SBQQ__QuoteLine__c> originalLines =
                        [SELECT Id, SBQQ__ProductFamily__c, SBQQ__Product__r.Name, SBQQ__Quantity__c,
                                SBQQ__UnitCost__c, Line_cost_total__c, Days__c,
                                SBQQ__Product__r.SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionTerm__c,
                                SBQQ__ListPrice__c, SBQQ__NetTotal__c, SBQQ__Description__c
                        FROM SBQQ__QuoteLine__c
                        WHERE SBQQ__Quote__c = :quote.Id];

        Map<Id, SBQQ__QuoteLine__c> lineIdMap = new Map<Id, SBQQ__QuoteLine__c>();

        for (SBQQ__QuoteLine__c line : originalLines){
            SBQQ__QuoteLine__c cloneLine = line.clone();
            cloneLine.SBQQ__Quote__c = cloneQuote.Id;
            if (quote.SBQQ__LineItemsGrouped__c){
                if (cloneLine.SBQQ__Group__c != null) {
                    cloneLine.SBQQ__Group__c = cloneGroups.get(line.SBQQ__Group__c).Id;
                }
            }
            lineIdMap.put(line.Id, cloneLine);
        }

        Database.SaveResult[] lineInserts = Database.insert(lineIdMap.values(), true);
        for (Database.SaveResult lineInsert : lineInserts){
            if (!lineInsert.isSuccess()){
                Database.rollback(sp);
                return result;
            }
        }

        List<Expense__c> expenses = [SELECT Id, QuoteLine__c FROM Expense__c WHERE QuoteLine__c IN :lineIdMap.keySet()];

        if (!expenses.isEmpty()) {
            for (Expense__c ex : expenses) {
                ex.QuoteLine__c = lineIdMap.get(ex.QuoteLine__c).Id;
            }

            Database.SaveResult[] expenseUpdates = Database.update(expenses, true);
            for (Database.SaveResult expenseUpdate : expenseUpdates) {
                if (!expenseUpdate.isSuccess()) {
                    Database.rollback(sp);
                    return result;
                }
            }
        }

        return cloneQuote.Id;

    }

    @AuraEnabled
    public static Boolean deleteQuoteApex(String quoteId){

        Savepoint sp = Database.setSavepoint();

        Database.DeleteResult[] lineDeleteResults = Database.delete([SELECT Id FROM SBQQ__QuoteLine__c
                                                                    WHERE SBQQ__Quote__c = :quoteId],true);
        for (Database.DeleteResult result : lineDeleteResults){
            if (!result.isSuccess()){
                return false;
            }
        }

        Database.DeleteResult[] groupDeleteResults = Database.delete([SELECT Id FROM SBQQ__QuoteLineGroup__c
                                                                    WHERE SBQQ__Quote__c = :quoteId],true);

        for (Database.DeleteResult result : groupDeleteResults){
            if (!result.isSuccess()){
                Database.rollback(sp);
                return false;
            }
        }

        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c WHERE Id = :quoteId LIMIT 1];
        Database.DeleteResult quoteDeleteResult = Database.delete(quote);
        if (!quoteDeleteResult.isSuccess()){
            Database.rollback(sp);
            return false;
        }

        return true;
    }

    @AuraEnabled
    public static List<Expense__c> getExpensesApex(String oppId){

        return [SELECT Id, Name, Amount__c, Supplier__c, Paid__c, Description__c, Due_Date__c, CreatedDate, QuoteLine__c
                FROM Expense__c
                WHERE Opportunity__c = :oppId];

    }

    @AuraEnabled
    public static Map<String,List<Object>> getDocumentInfoApex(String oppId){

        Map<String,List<Object>> responseMap = new Map<String,List<Object>>();

        List<User> users = [SELECT Id, FirstName, LastName FROM User
                            WHERE Id = :UserInfo.getUserId()];

        users.addAll([SELECT Id, FirstName, LastName FROM User
                        WHERE IsActive = TRUE
                        AND Profile.UserLicense.Name = 'Salesforce'
                        AND Id != :UserInfo.getUserId()]);
        responseMap.put('users', users);

        List<OpportunityContactRole> oppContacts = [SELECT ContactId, Contact.Name, Role
                                                    FROM OpportunityContactRole
                                                    WHERE OpportunityId = :oppId];
        responseMap.put('oppContacts', oppContacts);

        String accountId = [SELECT Account.Id FROM Opportunity
                            WHERE Id = :oppId].Account.Id;
        Set<String> roleIds = new Set<String>();
        for (OpportunityContactRole role : oppContacts){
            roleIds.add(role.ContactId);
        }


        List<Contact> contacts = [SELECT Id, Name, Title FROM Contact
                                  WHERE Account.Id = :accountId
                                  AND Id NOT IN :roleIds];

        responseMap.put('accountContacts', contacts);

        return responseMap;
    }

    @AuraEnabled
    public static Boolean assignExpenseApex(String lineId, String expenseId){

        Boolean success = true;

        Expense__c expense = new Expense__c(
                Id = expenseId,
                QuoteLine__c = lineId
        );

        Database.SaveResult result = Database.update(expense);

        if (!result.isSuccess()){
            success = false;
        }

        return success;
    }

}