/**
 * Created by Ronan Williams on 23/11/2018.
 */

public with sharing class PrimaryQuoteController {

    @AuraEnabled
    public static List<SBQQ__Quote__c> getQuoteApex(String oppId, String quoteId){

        String quoteQuery = (quoteId != 'default') ? ' AND Id = :quoteId ' : '';

        return (List<SBQQ__Quote__c>) Database.query('SELECT Id, SBQQ__Opportunity2__r.Legacy__c, Version__c, ' +
                        'SBQQ__Status__c, SBQQ__NetAmount__c, ' +
                        'Cost_of_sale__c, Gross_Margin__c, Stage__c, Gross_Profit__c, SBQQ__Primary__c, CreatedDate,' +
                        'Proposal_Introduction__c, Proposal_Conclusion__c, SBQQ__PriceBook__c, HasDocument__c, Locked__c, ' +
                        'SBQQ__Opportunity2__r.Account.Name, SBQQ__Opportunity2__r.Account.SOWRecipient__c, SBQQ__Opportunity2__r.QuoteType__c, DocumentLocked__c,' +
                        'SBQQ__Opportunity2__r.Contracted__c, SBQQ__Opportunity2__r.Reconciling__c, ' +
                        'SBQQ__LineItemsGrouped__c, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.Name, ' +
                        'SBQQ__Opportunity2__r.StageName, SBQQ__Opportunity2__r.Committed__c, Event_End__c, ' +
                        'SBQQ__Opportunity2__r.Quickbooks_COS__c, SBQQ__Opportunity2__r.COSRemaining__c, ' +
                        'SBQQ__Opportunity2__r.UnassignedExpenses__c,SBQQ__Opportunity2__r.Quote_Status__c,' +
                        'SBQQ__Opportunity2__r.SBQQ__PrimaryQuote__c, SBQQ__LineItemCount__c,' +
                        'SBQQ__Opportunity2__r.Percent_Invoiced__c, SBQQ__Opportunity2__r.Invoice_Status__c,' +
                        'SOW_Entity_Name__c, SOW_Entity_Name_Caps__c, SOW_Service_Description__c, SOW_Services__c, SOWDate__c,' +
                        '(SELECT Id, SBQQ__OutputFormat__c FROM SBQQ__R00N70000001lX7YEAU__r ' +
                        'ORDER BY CreatedDate), ' +
                        '(SELECT Id FROM SBQQ__LineItems__r), ' +
                        '(SELECT Id, SBQQ__Number__c FROM SBQQ__LineItemGroups__r) ' +
                        'FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :oppId ' + quoteQuery +
                        'ORDER BY SBQQ__Primary__c DESC, CreatedDate DESC LIMIT 1');

    }

    @AuraEnabled
    public static Map<String,Object> getRefreshApex(String quoteId){

        Map<String,Object> responseMap = new Map<String,Object>();

        SBQQ__Quote__c quote = [SELECT Id, SBQQ__NetAmount__c, SBQQ__LineItemsGrouped__c, HasDocument__c,
                                        SBQQ__LineItemCount__c, Cost_of_sale__c, Gross_Profit__c, Gross_Margin__c, SBQQ__Primary__c,
                                        SBQQ__Opportunity2__r.UnassignedExpenses__c, SBQQ__Opportunity2__r.Quote_Status__c
                                FROM SBQQ__Quote__c WHERE Id = :quoteId];

        responseMap.put('SBQQ__NetAmount__c',quote.SBQQ__NetAmount__c);
        responseMap.put('Cost_of_sale__c',quote.Cost_of_sale__c);
        responseMap.put('Gross_Profit__c',quote.Gross_Profit__c);
        responseMap.put('Gross_Margin__c',quote.Gross_Margin__c);
        responseMap.put('SBQQ__Primary__c',quote.SBQQ__Primary__c);
        responseMap.put('HasDocument__c',quote.HasDocument__c);
        responseMap.put('SBQQ__LineItemCount__c',quote.SBQQ__LineItemCount__c);
        responseMap.put('SBQQ__Opportunity2__r.UnassignedExpenses__c',quote.SBQQ__Opportunity2__r.UnassignedExpenses__c);
        responseMap.put('SBQQ__Opportunity2__r.Quote_Status__c',quote.SBQQ__Opportunity2__r.Quote_Status__c);

        if (quote.SBQQ__LineItemsGrouped__c){
            for (AggregateResult groupAggregate : [SELECT SBQQ__Group__c, SUM(SBQQ__NetTotal__c) revTotal,
                                                            SUM(Line_total_cost__c) cosTotal
                                                     FROM SBQQ__QuoteLine__c
                                                     WHERE SBQQ__Quote__c = :quoteId
                                                     AND SBQQ__Optional__c = FALSE
                                                     GROUP BY SBQQ__Group__c]){
                responseMap.put('rev' + groupAggregate.get('SBQQ__Group__c'), groupAggregate.get('revTotal'));
                responseMap.put('cos' + groupAggregate.get('SBQQ__Group__c'), groupAggregate.get('cosTotal'));
            }
        } else {

            for (SBQQ__QuoteLine__c line : [SELECT Id, SBQQ__ProductFamily__c, Line_total_cost__c, SBQQ__NetTotal__c
                                            FROM SBQQ__QuoteLine__c
                                            WHERE SBQQ__Quote__c = :quoteId
                                            AND SBQQ__Optional__c = FALSE
                                            ORDER BY SBQQ__Number__c ASC]){

                String family = (line.SBQQ__ProductFamily__c == null) ? 'Unclassifiedproducts' : line.SBQQ__ProductFamily__c.replaceAll('\\s+', '');

                if (!responseMap.containsKey('rev' + family)){
                    responseMap.put('rev' + family, line.SBQQ__NetTotal__c);
                } else {
                    responseMap.put('rev' + family, (Decimal)responseMap.get('rev' + family) + line.SBQQ__NetTotal__c);
                }

                if (!responseMap.containsKey('cos' + family)){
                    responseMap.put('cos' + family, line.Line_total_cost__c);
                } else {
                    responseMap.put('cos' + family, (Decimal)responseMap.get('cos' + family) + line.Line_total_cost__c);
                }

            }
        }

        return responseMap;

    }

    @AuraEnabled
    public static List<Object> getQuoteGroups(String Id, Boolean custom){

        if (custom){
            return [SELECT Id, Name, SBQQ__NetTotal__c,CreatedDate, SBQQ__Number__c,
                        (SELECT Id, SBQQ__ProductFamily__c, SBQQ__Product__r.Name, SBQQ__Quantity__c,
                            SBQQ__UnitCost__c, Line_total_cost__c, Days__c, SBQQ__Optional__c, SBQQ__Group__c,
                            SBQQ__Product__r.SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionTerm__c,
                            SBQQ__ListPrice__c, SBQQ__NetTotal__c, SBQQ__Description__c, SBQQ__Number__c, SBQQ__Hidden__c,
                            SBQQ__AdditionalDiscountAmount__c
                        FROM SBQQ__LineItems__r
                        ORDER BY SBQQ__Number__c ASC)
                    FROM SBQQ__QuoteLineGroup__c
                    WHERE SBQQ__Quote__c = :Id
                    ORDER BY SBQQ__Number__c, CreatedDate ASC];
        } else {

            Map<String,List<SBQQ__QuoteLine__c>> groupMap = new Map<String,List<SBQQ__QuoteLine__c>>();

            Schema.DescribeFieldResult productFamilies = Product2.Family.getDescribe();
            List<Schema.PicklistEntry> picklistEntries = productFamilies.getPicklistValues();

            for (Schema.PicklistEntry entry : picklistEntries){
                groupMap.put(entry.getLabel(), new List<SBQQ__QuoteLine__c>());
            }

            for (SBQQ__QuoteLine__c line : [SELECT Id, SBQQ__ProductFamily__c, SBQQ__Product__r.Name, SBQQ__Quantity__c,
                                                    SBQQ__UnitCost__c, Line_total_cost__c, Days__c, SBQQ__Optional__c, SBQQ__Number__c, SBQQ__Group__c,
                                                    SBQQ__Product__r.SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionTerm__c,
                                                    SBQQ__ListPrice__c, SBQQ__NetTotal__c, SBQQ__Description__c, SBQQ__Hidden__c,
                                                    SBQQ__AdditionalDiscountAmount__c
                                            FROM SBQQ__QuoteLine__c
                                            WHERE SBQQ__Quote__c = :Id
                                            ORDER BY SBQQ__ProductFamily__c,SBQQ__Number__c ASC]){

                String family = (line.SBQQ__ProductFamily__c == null) ? 'Unclassified products' : line.SBQQ__ProductFamily__c;

                if (!groupMap.containsKey(family)){
                    groupMap.put(family, new List<SBQQ__QuoteLine__c>());
                }

                groupMap.get(family).add(line);
            }

            List<Object> results = new List<Object>();

            for (String familyName : groupMap.keySet()){

                if (!groupMap.get(familyName).isEmpty()){
                    String objString = '{ "Name" : "' + familyName + '", "Id" : "' + familyName.replaceAll('\\s+', '') + '", "SBQQ__LineItems__r": ' +
                                       JSON.serialize(groupMap.get(familyName), true) + '}';
                    Object obj          = JSON.deserializeUntyped(objString);
                    results.add(obj);
                }
            }

            return results;
        }
    }

    @AuraEnabled
    public static List<Product2> getProductsApex(){

        return [SELECT Id, Name, Description, Family, SBQQ__SubscriptionTerm__c,
                        SBQQ__SubscriptionPricing__c, SBQQ__Hidden__c,
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
    public static Boolean togglePrimaryApex(String quoteId, String oppId, Boolean isPrimary){

        Boolean success = true;

        List<SBQQ__Quote__c> quotes = [SELECT Id, SBQQ__Opportunity2__c
                                        FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :oppId];

        Opportunity parentOpp = new Opportunity();
        parentOpp.Id = oppId;

        for (SBQQ__Quote__c quote : quotes){
            if (quote.Id == quoteId){
                quote.SBQQ__Primary__c = isPrimary;
                if (isPrimary){
                    parentOpp.SBQQ__PrimaryQuote__c = quote.Id;
                } else {
                    parentOpp.SBQQ__PrimaryQuote__c = null;
                }
            } else {
                quote.SBQQ__Primary__c = false;
            }
        }

        Database.SaveResult[] saveResult = Database.update(quotes, true);
        for (Database.SaveResult result : saveResult){
            if (!result.isSuccess()){
                success = false;
                break;
            }
        }

        update parentOpp;

        return success;
    }


    @AuraEnabled
    public static String changeLineApex(SBQQ__QuoteLine__c line, String operation, Decimal days){

        String result = 'error';

        SBQQ__QuoteLine__c lineLock = [SELECT Id, SBQQ__ProductFamily__c, SBQQ__Product__r.Name, SBQQ__Number__c,
                                            SBQQ__Quantity__c, SBQQ__Group__c, SBQQ__Hidden__c,
                                            SBQQ__UnitCost__c, Line_total_cost__c, Days__c, SBQQ__Optional__c,
                                            SBQQ__Product__r.SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionTerm__c,
                                            SBQQ__ListPrice__c, SBQQ__NetTotal__c, SBQQ__Description__c, SBQQ__Quote__c,
                                            SBQQ__AdditionalDiscountAmount__c, SBQQ__SubscriptionPricing__c,
                                            SBQQ__DefaultSubscriptionTerm__c
                                        FROM SBQQ__QuoteLine__c
                                        WHERE Id = :line.Id
                                        LIMIT 1 FOR UPDATE];

        Decimal lineItemCount = [SELECT SBQQ__LineItemCount__c
                                FROM SBQQ__Quote__c WHERE Id = :lineLock.SBQQ__Quote__c].SBQQ__LineItemCount__c;

        if (operation == 'save'){
            line.SBQQ__SubscriptionTerm__c = days;
            Database.SaveResult saveResult = Database.update(line);
            if (saveResult.isSuccess()){
                result = line.Id;
            }
        } else if (operation == 'clone'){
            SBQQ__QuoteLine__c clone = lineLock.clone(false,true,false,false);
            clone.SBQQ__Number__c = lineItemCount + 1;
            Database.SaveResult saveResult = Database.insert(clone);
            if (saveResult.isSuccess()){
                result = clone.Id;
            }
        } else if (operation == 'optional') {

            line.SBQQ__Optional__c = (lineLock.SBQQ__Optional__c) ? false : true;
            Database.SaveResult saveResult = Database.update(line);

            if (saveResult.isSuccess()){
                result = line.Id;
            }
        } else if (operation == 'delete'){

            Database.DeleteResult deleteResult = Database.delete(line.Id);

            if (deleteResult.isSuccess()){

                List<SBQQ__QuoteLine__c> lines = [SELECT Id, SBQQ__Number__c FROM SBQQ__QuoteLine__c
                                                    WHERE SBQQ__Number__c > :line.SBQQ__Number__c
                                                    AND SBQQ__Quote__c = :lineLock.SBQQ__Quote__c];

                for (SBQQ__QuoteLine__c li : lines){
                    if (li.SBQQ__Number__c != null){
                        li.SBQQ__Number__c = li.SBQQ__Number__c - 1;
                    }
                }

                Database.SaveResult[] updateResults = Database.update(lines);

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

        Decimal lineItemCount   = [SELECT SBQQ__LineItemCount__c FROM SBQQ__Quote__c WHERE Id = :quoteId].SBQQ__LineItemCount__c;
        Integer groupCount      = [SELECT Id FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :quoteId].size();

        SBQQ__QuoteLineGroup__c originalGroup = [SELECT Id, Name, SBQQ__NetTotal__c, SBQQ__Number__c,
                                                (SELECT Id, SBQQ__ProductFamily__c, SBQQ__Product__r.Name, SBQQ__Quantity__c,
                                                        SBQQ__UnitCost__c, Line_total_cost__c, Days__c,
                                                        SBQQ__Product__r.SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionTerm__c,
                                                        SBQQ__SubscriptionPricing__c, SBQQ__DefaultSubscriptionTerm__c,
                                                        SBQQ__ListPrice__c, SBQQ__NetTotal__c, SBQQ__Description__c, SBQQ__Hidden__c,
                                                        SBQQ__Optional__c, SBQQ__AdditionalDiscountAmount__c
                                                FROM SBQQ__LineItems__r)
                                                FROM SBQQ__QuoteLineGroup__c
                                                WHERE Id = :groupId];


        SBQQ__QuoteLineGroup__c cloneGroup = new SBQQ__QuoteLineGroup__c();
        cloneGroup.Name             = originalGroup.Name + ' (clone)';
        cloneGroup.SBQQ__Quote__c   = quoteId;
        cloneGroup.SBQQ__Number__c  = groupCount + 1;

        Database.SaveResult cloneInsert = Database.insert(cloneGroup);
        if (!cloneInsert.isSuccess()){
            return null;
        }

        List<SBQQ__QuoteLine__c> lineClones = originalGroup.SBQQ__LineItems__r.deepClone(false);
        for (SBQQ__QuoteLine__c line : lineClones){
            line.SBQQ__Group__c     = cloneGroup.Id;
            line.SBQQ__Quote__c     = quoteId;
            line.SBQQ__Number__c    = lineItemCount + 1;
            lineItemCount++;
        }

        Database.SaveResult[] lineInserts = Database.insert(lineClones, true);
        for (Database.SaveResult result : lineInserts){
            if (!result.isSuccess()){
                Database.rollback(sp);
                return null;
            }
        }

        return [SELECT Id, Name, SBQQ__NetTotal__c, SBQQ__Number__c,
                (SELECT Id, SBQQ__ProductFamily__c, SBQQ__Product__r.Name, SBQQ__Quantity__c,
                        SBQQ__UnitCost__c, Line_total_cost__c, Days__c, SBQQ__Number__c,
                        SBQQ__Product__r.SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionTerm__c,
                        SBQQ__ListPrice__c, SBQQ__NetTotal__c, SBQQ__Description__c,
                        SBQQ__Optional__c, SBQQ__AdditionalDiscountAmount__c, SBQQ__Hidden__c
                FROM SBQQ__LineItems__r)
                FROM SBQQ__QuoteLineGroup__c
                WHERE Id = :cloneGroup.Id];

    }

    @AuraEnabled
    public static SBQQ__QuoteLineGroup__c insertNewGroupApex(String quoteId, Integer groupCount){

        Integer groupCountInt = [SELECT Id FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :quoteId].size();

        SBQQ__QuoteLineGroup__c newGroup = new SBQQ__QuoteLineGroup__c();
        newGroup.SBQQ__Quote__c          = quoteId;
        newGroup.Name                    = 'Group' + String.valueOf(groupCount + 1);
        newGroup.SBQQ__Number__c         = groupCountInt + 1;

        Database.SaveResult saveResult = Database.insert(newGroup);
        if (!saveResult.isSuccess()){
            return null;
        }

        return newGroup;
    }

    @AuraEnabled
    public static Boolean deleteGroupApex(String groupId, String quoteId){

        Boolean result = false;

        SBQQ__QuoteLineGroup__c lineGroup   = [SELECT Id FROM SBQQ__QuoteLineGroup__c
                                               WHERE Id = :groupId];
        List<SBQQ__QuoteLine__c> lines      = [SELECT Id FROM SBQQ__QuoteLine__c
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

            List<SBQQ__QuoteLine__c> remainingLines = [SELECT Id, SBQQ__Number__c FROM SBQQ__QuoteLine__c
                                                WHERE SBQQ__Quote__c = :quoteId
                                                AND SBQQ__Group__c != :groupId
                                                ORDER BY SBQQ__Number__c ASC];

            Decimal lineCount = 1;

            for (SBQQ__QuoteLine__c line : remainingLines){
                line.SBQQ__Number__c = lineCount;
                lineCount++;
            }

            Database.SaveResult[] updateLineResults = Database.update(remainingLines);

            List<SBQQ__QuoteLineGroup__c> remainingGroups = [SELECT Id, SBQQ__Number__c FROM SBQQ__QuoteLineGroup__c
                                                            WHERE SBQQ__Quote__c = :quoteId
                                                            ORDER BY SBQQ__Number__c ASC];

            Decimal groupCount = 1;

            for (SBQQ__QuoteLineGroup__c remainingGroup : remainingGroups){
                remainingGroup.SBQQ__Number__c = groupCount;
                groupCount++;
            }

            Database.SaveResult[] updateGroupResults = Database.update(remainingGroups);

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

        Decimal lineItemCount = [SELECT SBQQ__LineItemCount__c FROM SBQQ__Quote__c WHERE Id = :quoteId].SBQQ__LineItemCount__c;

        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>();

        for (Product2 product : [SELECT Id, Name, Description, Family, SBQQ__SubscriptionTerm__c,
                                        SBQQ__SubscriptionPricing__c, SBQQ__Hidden__c,
                                    (SELECT SBQQ__UnitCost__c FROM SBQQ__Costs__r
                                    WHERE SBQQ__Active__c = TRUE LIMIT 1),
                                    (SELECT UnitPrice FROM PricebookEntries
                                    WHERE Pricebook2.Name = 'Default')
                                   FROM Product2 WHERE Id IN :productIdSet]){

            Decimal unitCost    = product.SBQQ__Costs__r != null ? product.SBQQ__Costs__r[0].SBQQ__UnitCost__c : 0;
            Decimal unitPrice   = product.PricebookEntries != null ? product.PricebookEntries[0].UnitPrice : 0;

            lines.add(
                new SBQQ__QuoteLine__c(
                    SBQQ__Product__c        = product.Id,
                    SBQQ__Description__c    = product.Description.replace('\n','<br/>'),
                    SBQQ__SubscriptionTerm__c = product.SBQQ__SubscriptionTerm__c,
                    SBQQ__SubscriptionPricing__c = 'Fixed Price',
                    SBQQ__DefaultSubscriptionTerm__c = 1,
                    SBQQ__Quantity__c       = 1,
                    SBQQ__UnitCost__c       = unitCost,
                    SBQQ__ListPrice__c      = unitPrice,
                    SBQQ__NetPrice__c       = unitPrice,
                    SBQQ__Group__c          = groupId,
                    SBQQ__Quote__c          = quoteId,
                    SBQQ__Number__c         = lineItemCount + 1,
                    SBQQ__Hidden__c         = product.SBQQ__Hidden__c
                )
            );

            lineItemCount++;
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

            return [SELECT Id, SBQQ__ProductFamily__c, SBQQ__Product__r.Name, SBQQ__Quantity__c, SBQQ__Number__c,
                        SBQQ__Group__c, SBQQ__UnitCost__c, Line_total_cost__c, Days__c, SBQQ__SubscriptionTerm__c,
                        SBQQ__Product__r.SBQQ__SubscriptionTerm__c, SBQQ__Hidden__c,
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

        Decimal lineItemCount = [SELECT SBQQ__LineItemCount__c FROM SBQQ__Quote__c WHERE Id = :quoteId].SBQQ__LineItemCount__c;

        for (Product2 product : [SELECT Id, Name, Description, Family, SBQQ__SubscriptionTerm__c,
                                        SBQQ__SubscriptionPricing__c, SBQQ__Hidden__c,
                                (SELECT SBQQ__UnitCost__c FROM SBQQ__Costs__r
                                WHERE SBQQ__Active__c = TRUE LIMIT 1),
                                (SELECT UnitPrice FROM PricebookEntries
                                WHERE Pricebook2.Name = 'Default')
                                FROM Product2 WHERE Id IN :productIdSet]){

            Decimal unitCost    = product.SBQQ__Costs__r != null && product.SBQQ__Costs__r[0].SBQQ__UnitCost__c != null ?
                    product.SBQQ__Costs__r[0].SBQQ__UnitCost__c : 0;
            Decimal unitPrice   = product.PricebookEntries != null && product.PricebookEntries[0].UnitPrice != null ?
                    product.PricebookEntries[0].UnitPrice : 0;

            lines.add(
                    new SBQQ__QuoteLine__c(
                            SBQQ__Product__c        = product.Id,
                            SBQQ__Description__c    = product.Description.replace('\n','<br/>'),
                            SBQQ__SubscriptionTerm__c = product.SBQQ__SubscriptionTerm__c,
                            SBQQ__SubscriptionPricing__c = 'Fixed Price',
                            SBQQ__DefaultSubscriptionTerm__c = 1,
                            SBQQ__Quantity__c       = 1,
                            SBQQ__UnitCost__c       = unitCost,
                            SBQQ__ListPrice__c      = unitPrice,
                            SBQQ__NetPrice__c       = unitPrice,
                            SBQQ__Quote__c          = quoteId,
                            SBQQ__Number__c         = lineItemCount + 1,
                            SBQQ__Hidden__c         = product.SBQQ__Hidden__c
                    )
            );

            lineItemCount++;
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
    public static String changeSortOrderApex(String quoteId, String lineId, Integer oldPosition,
                                            Integer newPosition, String targetGroupId){

        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>();

        if (oldPosition > newPosition){
            lines = [SELECT Id, SBQQ__Number__c, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__LineItemsGrouped__c
                    FROM SBQQ__QuoteLine__c
                    WHERE SBQQ__Quote__c = :quoteId
                    AND (SBQQ__Number__c <= :oldPosition AND SBQQ__Number__c >= :newPosition)];
                    for (SBQQ__QuoteLine__c line : lines){
                if (line.Id == lineId){
                    line.SBQQ__Number__c = newPosition;
                    if(line.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c){
                        line.SBQQ__Group__c = targetGroupId;
                    }
                } else {
                    line.SBQQ__Number__c = line.SBQQ__Number__c + 1;
                }
            }
        } else if (oldPosition < newPosition){
            lines = [SELECT Id, SBQQ__Number__c, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__LineItemsGrouped__c
                    FROM SBQQ__QuoteLine__c
                    WHERE SBQQ__Quote__c = :quoteId
                    AND (SBQQ__Number__c <= :newPosition AND SBQQ__Number__c >= :oldPosition)];
            for (SBQQ__QuoteLine__c line : lines){
                if (line.Id == lineId){
                    line.SBQQ__Number__c = newPosition;
                    if(line.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c){
                        line.SBQQ__Group__c = targetGroupId;
                    }
                } else {
                    line.SBQQ__Number__c = line.SBQQ__Number__c - 1;
                }
            }
        } else if (newPosition == null){
            lines = [SELECT Id, SBQQ__Number__c FROM SBQQ__QuoteLine__c
                    WHERE Id = :lineId LIMIT 1];
            lines[0].SBQQ__Group__c = targetGroupId;
        }

        Database.SaveResult[] lineUpdates = Database.update(lines, true);
        for (Database.SaveResult lineUpdate : lineUpdates){
            if (!lineUpdate.isSuccess()){
                return 'error';
            }
        }

        return 'success';
    }

    @AuraEnabled
    public static String changeGroupSortOrderApex(String quoteId, String groupId, Integer oldPosition,
            Integer newPosition){

        List<SBQQ__QuoteLineGroup__c> groups = new List<SBQQ__QuoteLineGroup__c>();

        if (oldPosition > newPosition){
            groups = [SELECT Id, SBQQ__Number__c, SBQQ__Quote__c
                        FROM SBQQ__QuoteLineGroup__c
                        WHERE SBQQ__Quote__c = :quoteId
                        AND (SBQQ__Number__c <= :oldPosition AND SBQQ__Number__c >= :newPosition)];

            for (SBQQ__QuoteLineGroup__c lineGroup : groups){
                if (lineGroup.Id == groupId){
                    lineGroup.SBQQ__Number__c = newPosition;
                } else {
                    lineGroup.SBQQ__Number__c = lineGroup.SBQQ__Number__c + 1;
                }
            }
        } else if (oldPosition < newPosition) {
            groups = [
                    SELECT Id, SBQQ__Number__c, SBQQ__Quote__c
                    FROM SBQQ__QuoteLineGroup__c
                    WHERE SBQQ__Quote__c = :quoteId
                    AND (SBQQ__Number__c <= :newPosition AND SBQQ__Number__c >= :oldPosition)
            ];

            for (SBQQ__QuoteLineGroup__c lineGroup : groups) {
                if (lineGroup.Id == groupId) {
                    lineGroup.SBQQ__Number__c = newPosition;
                } else {
                    lineGroup.SBQQ__Number__c = lineGroup.SBQQ__Number__c - 1;
                }
            }
        }

        Database.SaveResult[] groupUpdates = Database.update(groups, true);
        for (Database.SaveResult groupUpdate : groupUpdates){
            if (!groupUpdate.isSuccess()){
                return 'error';
            }
        }

        return 'success';
    }

    @AuraEnabled
    public static String convertToContractApex(String quoteId){

        List<SBQQ__Quote__c> quotes = [SELECT Id, Version__c, SBQQ__Status__c, SBQQ__NetAmount__c, SBQQ__Opportunity2__c,
                                        Cost_of_sale__c, Gross_Margin__c, Stage__c, Gross_Profit__c, SBQQ__Primary__c,
                                        Proposal_Introduction__c, Proposal_Conclusion__c, SBQQ__LineItemsGrouped__c,
                                        SBQQ__Opportunity2__r.Name, SBQQ__Opportunity2__r.Filtered_Job_Number__c,
                                        SBQQ__Opportunity2__r.Account.SOWRecipient__c
                                        FROM SBQQ__Quote__c
                                        WHERE Id = :quoteId];

        return createContractsApex(quotes);
    }

    @AuraEnabled
    public static String createContractsApex(List<SBQQ__Quote__c> quotes){

        String result   = 'error';
        Savepoint sp    = Database.setSavepoint();

        Set<Id> quoteIds = new Set<Id>();
        Set<Id> oppIds   = new Set<Id>();

        Map<String,String> newPrimaryMap                = new Map<String,String>();
        Map<String, SBQQ__Quote__c> quoteMap            = new Map<String,SBQQ__Quote__c>();
        Map<String, SBQQ__QuoteLineGroup__c> groupMap   = new Map<String,SBQQ__QuoteLineGroup__c>();
        List<SBQQ__QuoteLine__c> linesToInsert          = new List<SBQQ__QuoteLine__c>();


        for (SBQQ__Quote__c quote : quotes){
            quoteIds.add(quote.Id);
            oppIds.add(quote.SBQQ__Opportunity2__c);

            SBQQ__Quote__c cloneQuote           = quote.clone(false,true);
            cloneQuote.SBQQ__Opportunity2__c    = quote.SBQQ__Opportunity2__c;
            cloneQuote.SBQQ__Primary__c         = true;
            cloneQuote.Stage__c                 = 'Contract';
            cloneQuote.Version__c               = 'Contract';
            cloneQuote.SBQQ__Status__c          = null;
            cloneQuote.Latest__c                = true;
            cloneQuote.Proposal_Introduction__c =
                            'You\'re ready. We\'re ready. Let\'s get this show on the road! ' +
                            'Here\'s the legal stuff for ' + quote.SBQQ__Opportunity2__r.Name + ', get it signed-off, ' +
                            'and we can get started. Don\'t worry, if things change, we\'ll get it all updated ' +
                            'and sent back to you for approval. ';

            quoteMap.put(quote.Id, cloneQuote);
        }

        // insert quotes
        Database.SaveResult[] quoteInserts      = Database.insert(quoteMap.values(), true);
        for (Database.SaveResult quoteInsert : quoteInserts){
            if (!quoteInsert.isSuccess()){
                return result;
            }
        }

        for (SBQQ__QuoteLineGroup__c lineGroup : [SELECT Id, Name, SBQQ__NetTotal__c, SBQQ__Quote__c, SBQQ__Number__c
                                            FROM SBQQ__QuoteLineGroup__c
                                            WHERE SBQQ__Quote__c IN :quoteIds]){
            SBQQ__QuoteLineGroup__c newGroup = lineGroup.clone(false,true);
            newGroup.SBQQ__Quote__c = quoteMap.get(lineGroup.SBQQ__Quote__c).Id;
            groupMap.put(lineGroup.Id, newGroup);
        }

        // insert new groups
        Database.SaveResult[] groupInserts      = Database.insert(groupMap.values(), true);
        for (Database.SaveResult groupInsert : groupInserts){
            if (!groupInsert.isSuccess()){
                Database.rollback(sp);
                return result;
            }
        }

        for (SBQQ__QuoteLine__c line : [SELECT Id, SBQQ__Quote__c, SBQQ__ProductFamily__c, SBQQ__Product__r.Name, SBQQ__Quantity__c,
                                                SBQQ__UnitCost__c, Line_total_cost__c, Days__c, SBQQ__Number__c,
                                                SBQQ__Product__r.SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionTerm__c,
                                                SBQQ__SubscriptionPricing__c, SBQQ__DefaultSubscriptionTerm__c, SBQQ__ListPrice__c,
                                                SBQQ__NetTotal__c, SBQQ__Description__c, SBQQ__Group__c, SBQQ__Optional__c,
                                                SBQQ__AdditionalDiscountAmount__c, SBQQ__Hidden__c
                                        FROM SBQQ__QuoteLine__c
                                        WHERE SBQQ__Quote__c IN :quoteIds]){

            SBQQ__QuoteLine__c cloneLine = line.clone();
            cloneLine.SBQQ__Quote__c = quoteMap.get(line.SBQQ__Quote__c).Id;
            if (line.SBQQ__Group__c != null){
                cloneLine.SBQQ__Group__c = groupMap.get(line.SBQQ__Group__c).Id;
            }
            linesToInsert.add(cloneLine);
        }

        Database.SaveResult[] lineInserts = Database.insert(linesToInsert, true);
        for (Database.SaveResult lineInsert : lineInserts){
            if (!lineInsert.isSuccess()){
                Database.rollback(sp);
                return result;
            }
        }

        for (SBQQ__Quote__c primary : quoteMap.values()){
            newPrimaryMap.put(primary.SBQQ__Opportunity2__c,primary.Id);
        }

        List<Opportunity> opps = [SELECT Id, SBQQ__PrimaryQuote__c FROM Opportunity WHERE Id IN : oppIds];
        for (Opportunity opp : opps){
            opp.Contracted__c = true;
            opp.SBQQ__PrimaryQuote__c = newPrimaryMap.get(opp.Id);
        }

        update opps;

        List<SBQQ__Quote__c> quotesToLock = [SELECT Id FROM SBQQ__Quote__c
                                             WHERE Stage__c = 'Estimate'
                                             AND SBQQ__Opportunity2__c IN : oppIds];
        for (SBQQ__Quote__c quote : quotesToLock){
            quote.Locked__c = true;
            quote.DocumentLocked__c = true;
        }

        update quotesToLock;

        return 'success';

    }


    @AuraEnabled
    public static String cloneEstimateApex(SBQQ__Quote__c quote, String oppId, String type){

        String result   = 'error';
        Savepoint sp    = Database.setSavepoint();

        Opportunity parentOpp = [SELECT Id, Event_end__c, Contracted__c, Reconciling__c, Name,
                                        Legacy__c, Pricebook2Id,
                                        (SELECT Version__c FROM SBQQ__Quotes2__r
                                        WHERE CreatedDate < :quote.CreatedDate LIMIT 1)
                                 FROM Opportunity WHERE Id = :oppId];
        List<SBQQ__Quote__c> count = [SELECT Id FROM SBQQ__Quote__c
                                        WHERE SBQQ__Opportunity2__c = :oppId
                                        AND Stage__c = :type];

        String version = (type == 'Contract') ? 'Contract Amendment' + ' ' + count.size() :
                type + ' ' + (count.size() + 1);

        SBQQ__Quote__c cloneQuote           = quote.clone(false,true);
        cloneQuote.SBQQ__Opportunity2__c    = oppId;
        cloneQuote.SBQQ__Primary__c         = false;
        cloneQuote.Stage__c                 = type;
        cloneQuote.Version__c               = version;
        cloneQuote.HasDocument__c           = false;
        cloneQuote.Locked__c                = false;
        cloneQuote.Latest__c                = true;
        cloneQuote.Ancestor__c              = quote.Id;
        cloneQuote.SBQQ__Status__c          = parentOpp.Legacy__c ? quote.SBQQ__Status__c : null;

        if (type == 'Estimate'){
            cloneQuote.Proposal_Introduction__c =
                    'We\'ve listened and changed things up for ' +
                    parentOpp.Name + '. Over the next few pages, you\'ll get the complete picture ' +
                    'of the costs above. Just let us know as soon as you\'re happy, and we can get fired up.';
        } else if (type == 'Contract'){
            cloneQuote.Proposal_Introduction__c =
                    'Don\'t panic, we\'ve got it all sorted. Here\'s your amended contract for ' +
                    parentOpp.Name + '. It\'s all here, anything we\'ve added, removed or changed. ' +
                    'Happy? Great! Get it signed-off and we\'ll take care of the rest.';
        } else if (type == 'Reconciliation'){
            cloneQuote.Proposal_Introduction__c =
                    'The show is over, the stress is done, and it\'s time for a moment to reflect ' +
                    'on what you\'ve accomplished. Here\'s your up-to-date reconciliation for ' +
                    parentOpp.Name + '. You\'ll find a full breakdown of the costs on the next few pages, ' +
                    'and we\'ve highlighted anything that\'s changed. We can\'t wait to get started on the next project.';
        }

        Database.SaveResult quoteInsert     = Database.insert(cloneQuote);
        if (!quoteInsert.isSuccess()){
            return result;
        }

        Map<String,SBQQ__QuoteLineGroup__c> cloneGroups = new Map<String,SBQQ__QuoteLineGroup__c>();

        if (quote.SBQQ__LineItemsGrouped__c){

            List<SBQQ__QuoteLineGroup__c> existingGroups = [SELECT Id, Name, SBQQ__NetTotal__c, SBQQ__Number__c
                                                            FROM SBQQ__QuoteLineGroup__c
                                                            WHERE SBQQ__Quote__c = :quote.Id];

            for (SBQQ__QuoteLineGroup__c lineGroup : existingGroups){
                SBQQ__QuoteLineGroup__c newGroup = lineGroup.clone(false,true);
                newGroup.SBQQ__Quote__c     = cloneQuote.Id;
                newGroup.AncestorName__c    = lineGroup.Name;
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
                        [SELECT Id, SBQQ__Quote__c, SBQQ__ProductFamily__c, SBQQ__Product__r.Name, SBQQ__Quantity__c,
                                SBQQ__UnitCost__c, Line_total_cost__c, Days__c, SBQQ__Number__c, SBQQ__Optional__c,
                                SBQQ__Product__r.SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionTerm__c,
                                SBQQ__SubscriptionPricing__c, SBQQ__DefaultSubscriptionTerm__c, SBQQ__ListPrice__c,
                                SBQQ__NetTotal__c, SBQQ__Description__c, SBQQ__Group__c,
                                SBQQ__AdditionalDiscountAmount__c, SBQQ__Hidden__c
                        FROM SBQQ__QuoteLine__c
                        WHERE SBQQ__Quote__c = :quote.Id];

        Map<Id, SBQQ__QuoteLine__c> lineIdMap = new Map<Id, SBQQ__QuoteLine__c>();

        for (SBQQ__QuoteLine__c line : originalLines){
            SBQQ__QuoteLine__c cloneLine = line.clone();
            cloneLine.SBQQ__Quote__c = cloneQuote.Id;

            if (quote.Stage__c != 'Estimate'){
                cloneLine.Ancestor__c = line.Id;
            }
            if (quote.SBQQ__LineItemsGrouped__c && line.SBQQ__Group__c != null){
                cloneLine.SBQQ__Group__c = cloneGroups.get(line.SBQQ__Group__c).Id;
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

        List<SBQQ__Quote__c> priorQuotes = [SELECT Id, HasDocument__c, Locked__c, DocumentLocked__c
                                            FROM SBQQ__Quote__c
                                            WHERE SBQQ__Opportunity2__c = :oppId
                                            AND Id != :cloneQuote.Id];

        // if the new quote is an estimate and not a legacy opportunity, lock the documents on any prior estimate
        // if it is a contract, lock the documents and the quote itself
        if (cloneQuote.Stage__c == 'Estimate' && !parentOpp.Legacy__c){
            for (SBQQ__Quote__c prior : priorQuotes){
                prior.Latest__c         = false;
                if (prior.HasDocument__c && !prior.DocumentLocked__c){
                    prior.DocumentLocked__c = true;
                }
            }
        } else {
            for (SBQQ__Quote__c prior : priorQuotes){
                prior.Locked__c         = prior.Id != quote.Id;
                prior.SBQQ__Primary__c  = prior.Id == quote.Id;
                prior.Latest__c         = false;

                if (prior.HasDocument__c && !prior.DocumentLocked__c) {
                    prior.DocumentLocked__c = true;
                }
            }
        }

        if (parentOpp.Pricebook2Id == null){
            parentOpp.Pricebook2Id = cloneQuote.SBQQ__PriceBook__c;
            parentOpp.SBQQ__QuotePricebookId__c = cloneQuote.SBQQ__PriceBook__c;
        }

        update parentOpp;

        update priorQuotes;

        return cloneQuote.Id;

    }

    @AuraEnabled
    public static String createNewEstimateApex(String oppId){

        String result   = 'error';

        Opportunity opp = [SELECT Id, Name, StageName FROM Opportunity WHERE Id = :oppId];
        List<SBQQ__Quote__c> count = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :oppId];

        SBQQ__Quote__c newQuote           = new SBQQ__Quote__c();
        newQuote.SBQQ__Opportunity2__c    = oppId;
        newQuote.SBQQ__PriceBook__c       = [SELECT Id FROM Pricebook2 WHERE Name = 'Default'].Id;
        newQuote.SBQQ__Status__c          = null;
        newQuote.Latest__c                = true;

        if (opp.StageName == 'Closed Won'){
            newQuote.Stage__c                 = 'Contract';
            newQuote.Version__c               = 'Contract';
            newQuote.SBQQ__Primary__c         = true;
            newQuote.Proposal_Introduction__c = 'You\'re ready. We\'re ready. Let\'s get this show on the road! ' +
                    'Here\'s the legal stuff for ' + opp.Name + ', get it signed-off, ' +
                    'and we can get started. Don\'t worry, if things change, we\'ll get it all updated ' +
                    'and sent back to you for approval. ';
        } else {
            newQuote.Stage__c                 = 'Estimate';
            newQuote.Version__c               = 'Estimate ' + (count.size() + 1);
            newQuote.SBQQ__Primary__c         = false;
            newQuote.Proposal_Introduction__c = 'We\'re ready and raring to get started work on ' +
                    opp.Name + '. Over the next few pages, you\'ll get the ' +
                    'complete picture of the costs above. Excited? Great! ' +
                    'We are too. Let\'s get to work.';
        }

        Database.SaveResult quoteInsert   = Database.insert(newQuote);

        if (quoteInsert.isSuccess()){

            Boolean contracted = opp.StageName == 'Closed Won';

            Database.SaveResult oppUpdate  = Database.update(
                    new Opportunity(
                        Id = oppId,
                        Pricebook2Id = newQuote.SBQQ__PriceBook__c,
                        SBQQ__QuotePricebookId__c = newQuote.SBQQ__PriceBook__c,
                        Contracted__c = contracted
                    )
            );

            if (oppUpdate.isSuccess()){
                result = newQuote.Id;
            }
        }

        return result;

    }

    @AuraEnabled
    public static String deleteQuoteApex(String quoteId){

        Savepoint sp = Database.setSavepoint();

        Database.DeleteResult[] lineDeleteResults = Database.delete([SELECT Id FROM SBQQ__QuoteLine__c
                                                                    WHERE SBQQ__Quote__c = :quoteId],true);
        for (Database.DeleteResult result : lineDeleteResults){
            if (!result.isSuccess()){
                return 'error';
            }
        }

        Database.DeleteResult[] groupDeleteResults = Database.delete([SELECT Id FROM SBQQ__QuoteLineGroup__c
                                                                    WHERE SBQQ__Quote__c = :quoteId],true);

        for (Database.DeleteResult result : groupDeleteResults){
            if (!result.isSuccess()){
                Database.rollback(sp);
                return 'error';
            }
        }

        SBQQ__Quote__c quote = [SELECT Id,Stage__c, SBQQ__Primary__c, SBQQ__Opportunity2__c
                                FROM SBQQ__Quote__c WHERE Id = :quoteId LIMIT 1];

        List<SBQQ__Quote__c> newPrimary;

        if (quote.Stage__c != 'Estimate' || quote.SBQQ__Primary__c){

            newPrimary = [SELECT Id FROM SBQQ__Quote__c
                            WHERE SBQQ__Opportunity2__c = :quote.SBQQ__Opportunity2__c
                            AND Id != :quote.Id
                            ORDER BY CreatedDate DESC LIMIT 1];
        }

        Database.DeleteResult quoteDeleteResult = Database.delete(quote);
        if (!quoteDeleteResult.isSuccess()){
            Database.rollback(sp);
            return 'error';
        }

        if (newPrimary != null && !newPrimary.isEmpty()){
            newPrimary[0].SBQQ__Primary__c = true;
            update newPrimary[0];
            return newPrimary[0].Id;
        } else {
            return 'default';
        }
    }

    @AuraEnabled
    public static List<Expense__c> getExpensesApex(String oppId){

        return [SELECT Id, Name, Amount__c, Supplier__c, Paid__c, Description__c, Due_Date__c,
                        CreatedDate, QuoteLine__c, Assigned__c
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
                QuoteLine__c = lineId,
                Assigned__c = (lineId != null)
        );

        Database.SaveResult result = Database.update(expense);

        if (!result.isSuccess()){
            success = false;
        }

        return success;
    }

    @AuraEnabled
    public static List <Opportunity> getOpportunitiesApex(String currentOppId) {

        return [SELECT Id, Name, Filtered_Job_Number__c
                FROM Opportunity
                WHERE (QuoteType__c = 'Estimate' OR
                (StageName = 'Closed Won ' AND SBQQ__PrimaryQuote__c = NULL))
                AND Id != :currentOppId
                AND Legacy__c = FALSE
                ORDER BY Filtered_Job_Number__c DESC];
    }


    @AuraEnabled
    public static Boolean saveDocumentApex(String quoteId, String oppId,
            String userId, String contactId, String text, String optionals, String optSummary,
            String breakPage, String invoices,
            String vat, String sla, String tnc, String signed, String isSOW, String SOWEntity,
            String SOWDate, String SOWServices) {

        Boolean result = false;

        SBQQ__Quote__c quote = [SELECT Id, Version__c, SBQQ__Opportunity2__r.Filtered_Job_Number__c,
                                        SBQQ__Opportunity2__r.Account.Name, Proposal_Introduction__c
                                FROM SBQQ__Quote__c WHERE Id = :quoteId];

        SBQQ__QuoteDocument__c document = new SBQQ__QuoteDocument__c();
        document.Name                   = quote.SBQQ__Opportunity2__r.Filtered_Job_Number__c + ' ' +
                                            quote.SBQQ__Opportunity2__r.Account.Name + ' ' + quote.Version__c;
        document.SBQQ__Quote__c         = quoteId;
        document.SBQQ__Opportunity__c   = oppId;
        document.SBQQ__OutputFormat__c  = 'PDF';

        insert document;

        PageReference pdf = Page.QuotePreview;

        // add parent id to the parameters for standardcontroller
        pdf.getParameters().put('Id',quoteId);
        pdf.getParameters().put('userId',userId);
        pdf.getParameters().put('contactId',contactId);
        pdf.getParameters().put('text',EncodingUtil.urlDecode(text,'UTF-8'));
        pdf.getParameters().put('optionals',optionals);
        pdf.getParameters().put('optSummary',optSummary);
        pdf.getParameters().put('breakPage',breakPage);
        pdf.getParameters().put('invoices',invoices);
        pdf.getParameters().put('vat',vat);
        pdf.getParameters().put('sla',sla);
        pdf.getParameters().put('signed',signed);
        pdf.getParameters().put('tnc',tnc);
        pdf.getParameters().put('isSOW',isSOW);
        pdf.getParameters().put('SOWEntity',SOWEntity);
        pdf.getParameters().put('SOWDate',SOWDate);
        pdf.getParameters().put('SOWServices',SOWServices);

        // create the new attachment
        Attachment attach = new Attachment();

        // the contents of the attachment from the pdf
        Blob body;
        if(Test.isRunningTest()){
            body = Blob.valueOf('Unit.Test');
        }else {
            body = pdf.getContent();
        }

        attach.Body = body;
        attach.Name = quote.SBQQ__Opportunity2__r.Filtered_Job_Number__c + ' ' +
                quote.SBQQ__Opportunity2__r.Account.Name + ' ' + quote.Version__c + '.pdf';
        attach.IsPrivate = false;
        attach.ContentType = 'application/pdf';

        // attach the pdf to the Quote document
        attach.ParentId = document.Id;
        insert attach;

        document.SBQQ__DocumentId__c  = attach.Id;
        update document;

        if (quote.Proposal_Introduction__c != EncodingUtil.urlDecode(text,'UTF-8')){
            quote.Proposal_Introduction__c = EncodingUtil.urlDecode(text,'UTF-8');
        }
        quote.HasDocument__c = true;
        update quote;

        // send the user to the account to view results
        return true;

    }

    @AuraEnabled
    public static Boolean recCompleteApex(String quoteId){

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Id = quoteId;
        quote.SBQQ__Status__c = 'Reconciliation - completed';
        quote.Locked__c = true;

        Database.SaveResult quoteSaveResult = Database.update(quote);
        if(quoteSaveResult.isSuccess()){
            return true;
        } else {
            return false;
        }
    }


}