public class QuoteTriggerHandler {

	// METHOD PURPOSE: Update Opportunity contact roles with the quote 
    // contact if the quote primary contact is not already present on the Opportunity
	public static void updateOpportunityContacts(List<SBQQ__Quote__c> quotes){

		// find all existing opportunity contact roles using the opp Id from each quote
		Set<Id> oppIds = new Set<Id>();

		for (SBQQ__Quote__c quote : quotes) {
			oppIds.add(quote.SBQQ__Opportunity2__c);
		}

        List<OpportunityContactRole> rolesInTrigger = [SELECT ContactId, OpportunityId, IsPrimary
                                                      FROM OpportunityContactRole 
                                                      WHERE Opportunityid IN :oppIds];

        // place all contact roles in a map with opp Id as key. create additional set of ids 
        // for opps which have a primary contact 
        Map<Id,Set<String>> oppContRoles = new Map<Id,Set<String>>();
        Set<Id> oppsWithPrimaryContact = new Set<Id>();
       
        if (rolesInTrigger.size() > 0){
            for(OpportunityContactRole ocr : rolesInTrigger) {
            	if (ocr.isPrimary) {
            		oppsWithPrimaryContact.add(ocr.OpportunityId);
            	}
                if (!oppContRoles.containsKey(ocr.OpportunityId)){
                     oppContRoles.put(ocr.OpportunityId, new Set<String>{ocr.ContactId});     
                }else{
                     oppContRoles.get(ocr.OpportunityId).add(ocr.ContactId);
                }
            }
        }

        // check each quote against the map of contact roles. if the contact role doesn't exist, 
        // create it, and assing it as primary contact if none exists on the opportunity
        List<OpportunityContactRole> toInsert = new List<OpportunityContactRole>();
        for (SBQQ__Quote__c quote : quotes){
            if (!oppContRoles.containsKey(quote.SBQQ__Opportunity2__c) || 
                !oppContRoles.get(quote.SBQQ__Opportunity2__c).contains(quote.SBQQ__PrimaryContact__c)){
                OpportunityContactRole toAdd = new OpportunityContactRole(
                    OpportunityId = quote.SBQQ__Opportunity2__c,
                    ContactId = quote.SBQQ__PrimaryContact__c,
                    Role = 'Business User',
                    IsPrimary = false);
				if (!oppsWithPrimaryContact.contains(quote.SBQQ__Opportunity2__c)){
					toAdd.IsPrimary = true;
					oppsWithPrimaryContact.add(quote.SBQQ__Opportunity2__c);                    
            	}
            	toInsert.add(toAdd);
            }
        }
        
        if (toInsert.size() > 0){
            insert toInsert;
        }   

	}


    // METHOD PURPOSE: reset default field values on quotes when cloned. DISCLAIMER: when
    // quotes are cloned their opportunity Id field is preserved, so it cannot be determined
    // whether the quote was reparented after being cloned. For this reason method is based on 
    // the quote opportunity Id field changing 
    public static void resetClonedQuoteValues(List<SBQQ__Quote__c> quotes){

        string proposalIntroduction         = String.valueOf((Object)SBQQ__Quote__c.Proposal_Introduction__c.getDescribe().getDefaultValueFormula());        
        string proposalConclusion           = String.valueOf((Object)SBQQ__Quote__c.Proposal_Conclusion__c.getDescribe().getDefaultValueFormula());
        string reconciliationIntroduction   = String.valueOf((Object)SBQQ__Quote__c.Reconciliation_Introduction__c.getDescribe().getDefaultValueFormula());        
        string reconciliationConclusion     = String.valueOf((Object)SBQQ__Quote__c.Reconciliation_Conclusion__c.getDescribe().getDefaultValueFormula());

        for (SBQQ__Quote__c quote : quotes) {
            quote.Proposal_Introduction__c          = proposalIntroduction;
            quote.Proposal_Conclusion__c            = proposalConclusion;
            quote.Reconciliation_Introduction__c    = reconciliationIntroduction;
            quote.Reconciliation_Conclusion__c      = reconciliationConclusion;
        }

    }    

}