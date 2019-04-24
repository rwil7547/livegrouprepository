trigger OpportunityTrigger on Opportunity (after insert, after update) {

	if (Test.isRunningTest() || TriggerSwitch__c.getInstance('Opportunity').Active__c) {

		// 1. shipment lists to be sent to trigger handler methods  
		List<Opportunity> createInvoiceSchedules 		= new List<Opportunity>();
		Set<Id> createContracts 						= new Set<Id>();
		Map<Id,Opportunity> deleteInvoiceSchedules 		= new Map<Id,Opportunity>();
		Map<Id,Opportunity> updateScheduleAmounts		= new Map<Id,Opportunity>();
		Map<Id,Opportunity> updateScheduleDates			= new Map<Id,Opportunity>();
		Set<Id> accountsToQuickbooks					= new Set<Id>();
		Set<Id> quickbooksClasses						= new Set<Id>();
		Set<Id> reservationChecks 						= new Set<Id>();
		Map<Id,Integer> reservationStartChange			= new Map<Id,Integer>();
		Map<Id,Integer> reservationEndChange			= new Map<Id,Integer>();

		// 2. trigger filter to assign records to shipment lists 
	    for (Opportunity opp : Trigger.new) {

		    if (Trigger.isAfter) {

		    	if (Trigger.isInsert) {
		    		// Opportunity set to closed won on insert
	            	if (opp.StageName == 'Closed Won' && opp.Invoice_Schedule__c != null) {
	            		createInvoiceSchedules.add(opp);
	            	}
		    		// Opportunity set to closed won on insert and parent account does not have Quickbooks Id            	
	            	if (opp.StageName == 'Closed Won' && opp.AccountQuickbooksId__c == null && 
	            		!System.isFuture() && !System.isBatch() && opp.Calder_Opportunity__c == false &&
	            		TestHelper.allowCallout()) {
//	            		accountsToQuickbooks.add(opp.AccountId);
	            	}
					// Opportunity set to closed won on insert and does not have Quickbooks Class Id
					if (opp.StageName == 'Closed Won' && opp.QuickbooksClassId__c == null &&
							!System.isFuture() && !System.isBatch() && TestHelper.allowCallout()) {
//						quickbooksClasses.add(opp.Id);
					}
				}

		    	if (Trigger.isUpdate) {
		    		// Opportunity set to closed won on update
	            	if (opp.StageName == 'Closed Won' && opp.StageName != Trigger.oldMap.get(opp.Id).StageName &&
	            		opp.Invoice_Schedule__c != null) {
	            		createInvoiceSchedules.add(opp);
						createContracts.add(opp.Id);
	            	}
		    		// Opportunity set to closed won on update and parent account does not have Quickbooks Id            	
	            	if (opp.StageName == 'Closed Won' && opp.StageName != Trigger.oldMap.get(opp.Id).StageName &&
	            		opp.AccountQuickbooksId__c == null && !System.isFuture() && !System.isBatch() && opp.Calder_Opportunity__c == false &&
	            		TestHelper.allowCallout()) {
//	            		accountsToQuickbooks.add(opp.AccountId);
	            	}
					// Opportunity set to closed won on update and parent account does not have Quickbooks Id
					if (opp.StageName == 'Closed Won' && opp.StageName != Trigger.oldMap.get(opp.Id).StageName &&
							opp.QuickbooksClassId__c == null && !System.isFuture() && !System.isBatch() &&
							TestHelper.allowCallout()) {
//						quickbooksClasses.add(opp.Id);
					}
	            	// Opportunity changed from closed won to any other status, and has child invoice schedules
	            	if (opp.StageName != 'Closed Won' && Trigger.oldMap.get(opp.Id).StageName == 'Closed Won' &&
	            		opp.ScheduleCount__c > 0) {
	            		deleteInvoiceSchedules.put(opp.Id,opp);
	            	}
	            	// Opportunity amount changed 
	            	if (opp.StageName == 'Closed Won' && 
	            		opp.Amount_Calder__c != Trigger.oldMap.get(opp.Id).Amount_Calder__c &&
	            		opp.Quote_Count__c == Trigger.oldMap.get(opp.id).Quote_Count__c) {
	            		updateScheduleAmounts.put(opp.Id,opp);            	            	
	                }
	                // Event dates changed and Opportunity still not fully invoiced
	            	if (opp.StageName == 'Closed Won' && opp.Event_End__c != Trigger.oldMap.get(opp.Id).Event_End__c &&
	            		opp.ProcessedInvoices__c < opp.RequiredSchedules__c) {
	            		updateScheduleDates.put(opp.Id,opp);            	            	
	                }
	                // Invoice schedule changed and opportunity status unchanged
	            	if (opp.StageName == 'Closed Won' && opp.StageName == Trigger.oldMap.get(opp.Id).StageName &&
	            		opp.Invoice_Schedule__c != Trigger.oldMap.get(opp.Id).Invoice_Schedule__c &&
	            		opp.Invoice_Schedule__c != null) {
	            		deleteInvoiceSchedules.put(opp.Id,opp);
	            		createInvoiceSchedules.add(opp);            	            	
	                }
	                // Primary quote is added
	               	if (opp.StageName == 'Closed Won' && opp.SBQQ__PrimaryQuote__c !=  null 
	               		&& Trigger.oldMap.get(opp.Id).SBQQ__PrimaryQuote__c == null) {
	            		updateScheduleAmounts.put(opp.Id,opp);
	            	} 
	                //Primary quote is changed 
	               	if (opp.StageName == 'Closed Won' && opp.SBQQ__PrimaryQuote__c != null 
	               		&& Trigger.oldMap.get(opp.Id).SBQQ__PrimaryQuote__c != null 
	               		&& Trigger.oldMap.get(opp.Id).SBQQ__PrimaryQuote__c != opp.SBQQ__PrimaryQuote__c) {
	            		updateScheduleAmounts.put(opp.Id,opp);          		
	            	}
	                // Primary quote is removed
	               	if (opp.StageName == 'Closed Won' && opp.SBQQ__PrimaryQuote__c == null 
	               		&& Trigger.oldMap.get(opp.Id).SBQQ__PrimaryQuote__c != null) {
	            		updateScheduleAmounts.put(opp.Id,opp);
	            	}
					// Opportunity changed from closed won to any other status
					if (opp.StageName != 'Closed Won' && Trigger.oldMap.get(opp.Id).StageName == 'Closed Won') {
						reservationChecks.add(opp.Id);
					}
					// Opportunity is closed won and the project dates are changed
					if (opp.StageName == 'Closed Won' && (opp.Project_Start__c != Trigger.oldMap.get(opp.Id).Project_Start__c ||
							opp.Project_End__c != Trigger.oldMap.get(opp.Id).Project_End__c)){
						reservationStartChange.put(opp.Id,opp.Project_Start__c.daysBetween(Trigger.oldMap.get(opp.Id).Project_Start__c));
						reservationEndChange.put(opp.Id,opp.Project_End__c.daysBetween(Trigger.oldMap.get(opp.Id).Project_End__c));
					}
		    	}
		    }
		}

	    // 3. trigger helper methods invoked for lists with records to process 
	    if (!deleteInvoiceSchedules.isEmpty()) {
	    	OpportunityTriggerHandler.deleteInvoiceSchedules(deleteInvoiceSchedules);
	    }		
	    if (!createInvoiceSchedules.isEmpty()) {
	    	OpportunityTriggerHandler.createInvoiceSchedules(createInvoiceSchedules);
	    }		
	    if (!updateScheduleAmounts.isEmpty()) {
	    	OpportunityTriggerHandler.updateScheduleAmounts(updateScheduleAmounts);	
	    } 		
	    if (!updateScheduleDates.isEmpty()) {
			OpportunityTriggerHandler.updateScheduleDates(updateScheduleDates,Trigger.oldMap);
	    }		
	    if (!accountsToQuickbooks.isEmpty()) {
			QuickbooksCustomerBatch.createCustomers(accountsToQuickbooks);
	    }
		if (!quickbooksClasses.isEmpty()){
			QuickbooksClassSync.postQuickbooksClass(quickbooksClasses);
		}
		if (!reservationChecks.isEmpty()) {
			OpportunityTriggerHandler.removeReservations(reservationChecks);
		}
		if (!reservationStartChange.isEmpty()){
			OpportunityTriggerHandler.updateReservationDates(reservationStartChange, reservationEndChange);
		}
		if (!createContracts.isEmpty()){
			OpportunityTriggerHandler.createContracts(createContracts);
		}

	}

}