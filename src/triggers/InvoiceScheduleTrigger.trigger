Trigger InvoiceScheduleTrigger on Invoice_Schedule__c (before insert, before update) {

	if ((Test.isRunningTest() || TriggerSwitch__c.getInstance('InvoiceSchedule').Active__c)
		&& OpportunityTriggerHandler.noConflict && InvoiceScheduleTriggerHandler.noConflict) {

		// 1. shipment lists to be sent to helper method  
		Set<String> isIds 							 	= new Set<String>();
		List<Invoice_Schedule__c> updatePaymentDates 	= new List<Invoice_Schedule__c>();
		Map<Id,Decimal> oppIds							= new Map<Id,Decimal>();
		Map<Id,Decimal> changeReferences				= new Map<Id,Decimal>();	

		// 2. trigger filter to assign records to lists 
	    for (Invoice_Schedule__c is : Trigger.new) {

		   	oppIds.put(is.Opportunity__c, 0);

		    if (Trigger.isBefore) {   

	            //if (Trigger.isInsert) {

	            //}

	            if (Trigger.isUpdate) {

	            	// the amount on the schedule has been updated, and the prior value on the 
	            	// schedule needs to be preserved when calculating the remaning invoice amounts 
	            	if (is.Amount__c != Trigger.oldMap.get(is.Id).Amount__c 
	            		&& ((!is.Custom_Value__c && is.Custom_Value__c != Trigger.oldMap.get(is.Id).Custom_Value__c)
						|| (is.Custom_Value__c && is.Custom_Value__c == Trigger.oldMap.get(is.Id).Custom_Value__c)
	            		|| (!is.Invoice_Sent__c && is.Invoice_Sent__c != Trigger.oldMap.get(is.Id).Invoice_Sent__c)
						|| (is.Invoice_Sent__c && is.Invoice_Sent__c == Trigger.oldMap.get(is.Id).Invoice_Sent__c))) {
	            		isIds.add(is.Id);
	            		oppIds.put(is.Opportunity__c, oppIds.get(is.Opportunity__c) + is.Amount__c - Trigger.oldMap.get(is.Id).Amount__c);
	            		System.debug('prior amount preserved');
	            	}

	            	// the amount on the schedule has been updated, and the prior value on the 
	            	// schedule does not need to be preserved when calculating the remaning invoice amounts 
	            	else if (is.Amount__c != Trigger.oldMap.get(is.Id).Amount__c
	            		&& ((is.Custom_Value__c && is.Custom_Value__c != Trigger.oldMap.get(is.Id).Custom_Value__c)
						|| (!is.Custom_Value__c && is.Custom_Value__c == Trigger.oldMap.get(is.Id).Custom_Value__c)
	            		|| (is.Invoice_Sent__c && is.Invoice_Sent__c != Trigger.oldMap.get(is.Id).Invoice_Sent__c)
						|| (!is.Invoice_Sent__c && is.Invoice_Sent__c == Trigger.oldMap.get(is.Id).Invoice_Sent__c))) {
	            		isIds.add(is.Id);
	            		oppIds.put(is.Opportunity__c, oppIds.get(is.Opportunity__c) + is.Amount__c);
	            		System.debug('prior amount disgarded');            		
	            	}

		           	// the send date on the schedule has been changed, but not by 
	            	// the results returned through the Quickbooks data capture 
	            	if (!System.isFuture() && is.Send_Date__c != Trigger.oldMap.get(is.Id).Send_Date__c 
	            		&& is.Payment_Date__c == Trigger.oldMap.get(is.Id).Payment_Date__c) {
	            		updatePaymentDates.add(is);
	            	}

	            }

	            //if (Trigger.isDelete) {
	            	
	            //}            
		    }
		   
		    //if (Trigger.isAfter) {

		    //	if (Trigger.isInsert) {

		    //	}

		    //	if (Trigger.isUpdate) {

		    //	}

		    //	if (Trigger.isDelete) {

		    //	}
		    //}
	    }

	    // 3. trigger helper methods invoked for lists with records to process 
	    if (isIds.size() > 0) {
	    	InvoiceScheduleTriggerHandler.updateAmounts(isIds, oppIds);
	    }
	    if (updatePaymentDates.size() > 0) {
			InvoiceScheduleTriggerHandler.updatePaymentDates(updatePaymentDates);
	    } 		    
	}    
}