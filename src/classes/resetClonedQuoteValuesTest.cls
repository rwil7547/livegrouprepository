@isTest
private class resetClonedQuoteValuesTest {
	
	@isTest static void changeParentOpportunity() {
		Account acc = (Account)SmartFactory.createSOBject('Account');
		insert acc;
		
		Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
		opp.AccountId = acc.Id;
		insert opp;

		Opportunity oppTwo = (Opportunity)SmartFactory.createSOBject('Opportunity');
		oppTwo.AccountId = acc.Id;
		insert oppTwo;

		SBQQ__Quote__c quote = (SBQQ__Quote__c)SmartFactory.createSOBject('SBQQ__Quote__c');
		quote.SBQQ__Opportunity2__c = opp.Id;
		quote.Proposal_Introduction__c = null;
		quote.Proposal_Conclusion__c = 'Replaced content';
		quote.Reconciliation_Introduction__c = null;
		quote.Reconciliation_Conclusion__c = 'Replaced content';				
		insert quote;

		quote.SBQQ__Opportunity2__c = oppTwo.Id;
		update quote;

		System.assertEquals(String.valueOf((Object)SBQQ__Quote__c.Proposal_Introduction__c.getDescribe().getDefaultValueFormula()),
			[SELECT Proposal_Introduction__c FROM SBQQ__Quote__c].Proposal_Introduction__c);		
		System.assertEquals(String.valueOf((Object)SBQQ__Quote__c.Proposal_Conclusion__c.getDescribe().getDefaultValueFormula()),
			[SELECT Proposal_Conclusion__c FROM SBQQ__Quote__c].Proposal_Conclusion__c);	
		System.assertEquals(String.valueOf((Object)SBQQ__Quote__c.Reconciliation_Introduction__c.getDescribe().getDefaultValueFormula()),
			[SELECT Reconciliation_Introduction__c FROM SBQQ__Quote__c].Reconciliation_Introduction__c);	
		System.assertEquals(String.valueOf((Object)SBQQ__Quote__c.Reconciliation_Conclusion__c.getDescribe().getDefaultValueFormula()),
			[SELECT Reconciliation_Conclusion__c FROM SBQQ__Quote__c].Reconciliation_Conclusion__c);			

	}
	
}