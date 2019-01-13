@isTest
private class updateOpportunityContactsTest {

	@isTest static void onQuoteInsertNoPrimary() {

		Account acc = (Account)SmartFactory.createSOBject('Account');
		insert acc;
		
		Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
		opp.AccountId = acc.Id;
		insert opp;

		Contact contact = (Contact)SmartFactory.createSOBject('Contact');
		contact.AccountId = opp.AccountId;
		insert contact;

		SBQQ__Quote__c quote = (SBQQ__Quote__c)SmartFactory.createSOBject('SBQQ__Quote__c');
		quote.SBQQ__Opportunity2__c = opp.Id;
		quote.SBQQ__PrimaryContact__c = contact.Id;
		insert quote;

		System.assertEquals(1,[SELECT id FROM OpportunityContactRole 
								WHERE OpportunityId = :opp.Id AND IsPrimary = true].size());

	}

	@isTest static void onQuoteInsertWithPrimary() {

		Account acc = (Account)SmartFactory.createSOBject('Account');
		insert acc;
		
		Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
		opp.AccountId = acc.Id;
		insert opp;

		Contact firstContact = (Contact)SmartFactory.createSOBject('Contact');
		firstContact.AccountId = opp.AccountId;
		firstContact.LastName = 'firstContact';
		insert firstContact;

		Contact secondContact = (Contact)SmartFactory.createSOBject('Contact');
		secondContact.AccountId = opp.AccountId;
		secondContact.LastName = 'secondContact';
		insert secondContact;

		OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = opp.Id, 
																	IsPrimary = true, ContactId = firstContact.id);
		insert ocr;

		SBQQ__Quote__c quote = (SBQQ__Quote__c)SmartFactory.createSOBject('SBQQ__Quote__c');
		quote.SBQQ__Opportunity2__c = opp.Id;
		quote.SBQQ__PrimaryContact__c = secondContact.Id;
		insert quote;

		System.assertEquals(1,[SELECT id FROM OpportunityContactRole 
								WHERE OpportunityId = :opp.Id AND IsPrimary = true
								AND ContactId = :firstContact.Id].size());

		System.assertEquals(1,[SELECT id FROM OpportunityContactRole 
								WHERE OpportunityId = :opp.Id AND IsPrimary = false
								AND ContactId = :secondContact.Id].size());

	}
	
	@isTest static void onQuoteUpdateNoPrimary() {

		Account acc = (Account)SmartFactory.createSOBject('Account');
		insert acc;
		
		Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
		opp.AccountId = acc.Id;
		insert opp;

		Contact contact = (Contact)SmartFactory.createSOBject('Contact');
		contact.AccountId = opp.AccountId;
		insert contact;

		SBQQ__Quote__c quote = (SBQQ__Quote__c)SmartFactory.createSOBject('SBQQ__Quote__c');
		quote.SBQQ__Opportunity2__c = opp.Id;	
		insert quote;

		quote.SBQQ__PrimaryContact__c = contact.id;
		update quote;

		System.assertEquals(1,[SELECT id FROM OpportunityContactRole 
								WHERE OpportunityId = :opp.Id AND IsPrimary = true].size());

	}

	@isTest static void onQuoteUpdateWithPrimary() {

		Account acc = (Account)SmartFactory.createSOBject('Account');
		insert acc;
		
		Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
		opp.AccountId = acc.Id;
		insert opp;

		Contact firstContact = (Contact)SmartFactory.createSOBject('Contact');
		firstContact.AccountId = opp.AccountId;
		firstContact.LastName = 'firstContact';
		insert firstContact;

		Contact secondContact = (Contact)SmartFactory.createSOBject('Contact');
		secondContact.AccountId = opp.AccountId;
		secondContact.LastName = 'secondContact';
		insert secondContact;

		OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = opp.Id, 
																	IsPrimary = true, ContactId = firstContact.id);
		insert ocr;

		SBQQ__Quote__c quote = (SBQQ__Quote__c)SmartFactory.createSOBject('SBQQ__Quote__c');
		quote.SBQQ__Opportunity2__c = opp.Id;	
		insert quote;

		quote.SBQQ__PrimaryContact__c = secondContact.id;
		update quote;

		System.assertEquals(1,[SELECT id FROM OpportunityContactRole 
								WHERE OpportunityId = :opp.Id AND IsPrimary = true
								AND ContactId = :firstContact.Id].size());

		System.assertEquals(1,[SELECT id FROM OpportunityContactRole 
								WHERE OpportunityId = :opp.Id AND IsPrimary = false
								AND ContactId = :secondContact.Id].size());

	}

}