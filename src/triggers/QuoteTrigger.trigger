trigger QuoteTrigger on SBQQ__Quote__c (before insert, before update) {

    if (Test.isRunningTest() || TriggerSwitch__c.getInstance('Quote').Active__c) {

    	// 1. shipment lists to be sent to helper method  
    	List<SBQQ__Quote__c> updateOpportunityContacts 		= new List<SBQQ__Quote__c>();
    	List<SBQQ__Quote__c> resetClonedQuoteValues 		= new List<SBQQ__Quote__c>();


    	// 2. trigger filter to assign records to lists 
        for (SBQQ__Quote__c quote : Trigger.new) {

    	    if (Trigger.IsBefore) {   

                if (Trigger.isInsert) {
                    // quote is inserted with primary contact and parent opportunity
                	if (quote.SBQQ__PrimaryContact__c != null && quote.SBQQ__Opportunity2__c != null) {
                		updateOpportunityContacts.add(quote);
                	}
                }

                if (Trigger.isUpdate) {
                    // primary contact on the quote is changed
                	if ((quote.SBQQ__PrimaryContact__c != Trigger.oldMap.get(quote.Id).SBQQ__PrimaryContact__c) 
                		&& quote.SBQQ__Opportunity2__c != null && quote.SBQQ__PrimaryContact__c != null) {
                		updateOpportunityContacts.add(quote);
                	}
                    // parent opportunity is changed 
                	if(quote.SBQQ__Opportunity2__c != Trigger.oldMap.get(quote.Id).SBQQ__Opportunity2__c) {
                		resetClonedQuoteValues.add(quote);
                	}                
                }

    	    }

    	    
    	    //if (Trigger.isAfter) {

    	    //	if (Trigger.isInsert) {

    	    //	}

    	    //	if (Trigger.isUpdate) {

    	    //	}

         //       if (Trigger.isDelete) {

         //       }
    	    //}

    	}


        // 3. trigger helper methods invoked for lists with records to process  
        if (updateOpportunityContacts.size() > 0) 		QuoteTriggerHandler.updateOpportunityContacts(updateOpportunityContacts);
        if (resetClonedQuoteValues.size() > 0) 			QuoteTriggerHandler.resetClonedQuoteValues(resetClonedQuoteValues);

    }
}