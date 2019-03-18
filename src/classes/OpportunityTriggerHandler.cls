public class OpportunityTriggerHandler {

	// below static variable prevents conflict with Invoice_Schedule__c trigger
	// when a specific schedule is updated 
	public static boolean noConflict = true;

	// METHOD PURPOSE: Create invoice schedules for Opportunities when they are 
	// set to closed won 
	public static void createInvoiceSchedules(List<Opportunity> opps){

		// for each Opportunity in the list, create invoice schedules 
		List<Invoice_Schedule__c> newInvSchedules = new List<Invoice_Schedule__c>();		

		for (Opportunity opp : opps) {
			
			// the figure below are needed to avoid a 'divide by zero' math exception
			Integer reservedInvoices = Integer.valueOf(opp.Custom_Invoices__c + opp.ProcessedInvoices__c);
			Integer invoicesNeeded 	 = Integer.valueOf(opp.RequiredSchedules__c);
			Integer amountToCreate	 = (invoicesNeeded - reservedInvoices == 0) ? 1 : invoicesNeeded - reservedInvoices;
			Date endDate			 = opp.Event_end__c;
			Date today 				 = Date.today();

			if (!(reservedInvoices > 0) && invoicesNeeded > 0) {
				Invoice_Schedule__c is = new Invoice_Schedule__c();
				is.Name				= 'Invoice 1';
				is.Opportunity__c 	= opp.Id;
				is.Send_Date__c		= today + 3;
				is.Payment_Date__c 	= is.Send_Date__c + 30;
				is.Amount__c 		= opp.Amount_Remaining__c / amountToCreate;
				if (opp.Invoice_Schedule__c == 'Single post-event invoice') 
							is.Send_Date__c = (endDate + 1 < today) ? today + 3 : endDate + 1;
				if (is.Amount__c != 0) newInvSchedules.add(is);
			}								
			if (!(reservedInvoices > 1) && invoicesNeeded > 1) {
				Invoice_Schedule__c is2 = new Invoice_Schedule__c();
				is2.Name			= 'Invoice 2';
				is2.Opportunity__c 	= opp.Id;
				is2.Send_Date__c	= (endDate + 1 < today) ? today + 3 : endDate + 1;
				is2.Payment_Date__c = is2.Send_Date__c + 30;
				is2.Amount__c 		= opp.Amount_Remaining__c / amountToCreate;
				if (invoicesNeeded == 3) is2.Send_Date__c = (endDate - 30 < today) ? today + 3 : endDate - 30;				
				if (is2.Amount__c != 0) newInvSchedules.add(is2);	
			}								
			if (!(reservedInvoices > 2) && invoicesNeeded > 2) {
				Invoice_Schedule__c is3 = new Invoice_Schedule__c();
				is3.Name			= 'Invoice 3';
				is3.Opportunity__c 	= opp.Id;
				is3.Send_Date__c	= (endDate + 3 < today) ? today + 3 : endDate + 3;
				is3.Payment_Date__c	= is3.Send_Date__c + 30;
				is3.Amount__c 		= opp.Amount_Remaining__c / amountToCreate;
				if (is3.Amount__c != 0) newInvSchedules.add(is3);	
			}								
			if (reservedInvoices >= invoicesNeeded && opp.Amount_Remaining__c != 0) {
				Invoice_Schedule__c is = new Invoice_Schedule__c();
				is.Name				= 'Invoice ' + (opp.ScheduleCount__c + 1);
				is.Opportunity__c 	= opp.Id;
				is.Send_Date__c		= (endDate + 3 < today) ? today + 3 : endDate + 3;
				is.Payment_Date__c	= is.Send_Date__c + 30;
				is.Amount__c 		= opp.Amount_Remaining__c;
				if (is.Amount__c != 0) newInvSchedules.add(is);				
			}	
		}

		// insert new invoice schedules
		if (newInvSchedules.size() > 0) insert newInvSchedules;

	}


	// METHOD PURPOSE: Delete invoice schedules if Opportunity is deleted or 
	// changed from Closed Won to any other status 
	public static void deleteInvoiceSchedules(Map<Id,Opportunity> oppMap){

		// find all invoice schedules that should be deleted
		List<Invoice_Schedule__c> schedulesToDelete = [SELECT Id FROM Invoice_Schedule__c
														WHERE Invoice_Sent__c = False
														AND Custom_Value__c = False 
														AND Opportunity__c IN: oppMap.keySet()];

		// delete the list of invoice schedules 													
		if (schedulesToDelete.size() > 0) delete schedulesToDelete; 
	
	}


	// METHOD PURPOSE: Update invoice schedule amounts if the amount on the
	// opportunity changes and the invoices have not been sent  
	public static void updateScheduleAmounts(Map<Id,Opportunity> oppMap){

		// prevent the trigger on the Invoice_Schedule__c object from firing on update
		noConflict = false;
		
		List<Invoice_Schedule__c> schedulesToUpdate =  new List<Invoice_Schedule__c>();
		List<Invoice_Schedule__c> schedulesToDelete =  new List<Invoice_Schedule__c>();
		List<Opportunity> schedulestoCreate 		=  new List<Opportunity>();

		List<Opportunity> opps = [SELECT Amount_Remaining__c, ScheduleCount__c, 
										 RequiredSchedules__c, Custom_Invoices__c,
										 ProcessedInvoices__c, Event_end__c,
										 Invoice_Schedule__c,
										 (SELECT Id, Name, Invoice_Sent__c 
								 		 FROM Invoice_Schedules__r
								  		 WHERE Invoice_Sent__c = False
								  	 	 AND Custom_Value__c = False
								  		 ORDER BY Send_Date__c ASC)
								  FROM Opportunity WHERE Id IN: oppMap.keySet()];


		// for each opportunity, determine how the invoice schedules should be adjusted						  
		for (Opportunity opp : opps) {

			List<Invoice_Schedule__c> isList = opp.Invoice_Schedules__r;

			if (opp.Amount_Remaining__c == 0 && isList.size() > 0) {
				// if there is no more to be invoiced, delete the schedules
				schedulesToDelete.addAll(isList);
			} else if (isList.size() == 0) {
				// if there is more to be invoiced but no schedules, create some
				schedulestoCreate.add(opp);
			} else if (opp.ScheduleCount__c < opp.RequiredSchedules__c) {
				// if there are less schedules than the required amount, create them again
				schedulesToDelete.addAll(isList);
				schedulestoCreate.add(opp);
			} else if (isList.size() == 1) {
				// if the list only has one record, allocate the amount remaning to the record
				isList[0].Amount__c = opp.Amount_Remaining__c;
				schedulesToUpdate.add(isList[0]);
			} else {
				// work out if there are more open schedules than needed
				Integer reservedInvoices = Integer.valueOf(opp.ProcessedInvoices__c + opp.Custom_Invoices__c);
				Integer mimimumInvoices = (reservedInvoices >= opp.RequiredSchedules__c) 
										  ? reservedInvoices + 1 : Integer.valueOf(opp.RequiredSchedules__c);
				Integer excessInvoices = Integer.valueOf(opp.ScheduleCount__c) - mimimumInvoices;
				// if there are more than needed, delete the excess ones
				if (excessInvoices > 0) {
					for (Integer x = 0; x < excessInvoices; x++) {
						schedulesToDelete.add(isList[x]);
						isList.remove(x);
					}
				}
				// for the remaning schedules, update their amounts
				for (Invoice_Schedule__c is : isList) {
					is.Amount__c = opp.Amount_Remaining__c / isList.size();
					schedulesToUpdate.add(is);
				}							
			}
		}

		// Delete invoice schedules with zero value, and upsert those with non-zero value	
		if (schedulesToDelete.size() > 0 ) delete schedulesToDelete;
		if (schedulesToUpdate.size() > 0 ) update schedulesToUpdate;
		if (schedulestoCreate.size() > 0) createInvoiceSchedules(schedulestoCreate);

	}


	// METHOD PURPOSE: Update invoice schedule dates if the dates on the
	// opportunity change  
	public static void updateScheduleDates(Map<Id,Opportunity> oppMap, Map<Id,Opportunity> oldOppMap){	

		List<Invoice_Schedule__c> schedulesToUpdate =  new List<Invoice_Schedule__c>();

		// extract a list of all existing invoice schedules belonging to the opportunity
		List<Opportunity> opps = [SELECT Event_end__c,
								 		 (SELECT Send_Date__c 
								 		 FROM Invoice_Schedules__r
								  		 WHERE Invoice_Sent__c = False)
								  FROM Opportunity WHERE Id IN: oppMap.keySet()];

		// update the due dates and payment dates on the schedules if they have not already been sent
		for (Opportunity opp : opps) {

			//Integer dateDiff = opp.Event_end__c.daysBetween(oldOppMap.get(opp.Id).Event_end__c);
			Integer dateDiff = oldOppMap.get(opp.Id).Event_end__c.daysBetween(opp.Event_end__c);

			for (Invoice_Schedule__c is : opp.Invoice_Schedules__r) {
				is.Send_Date__c 	= (is.Send_Date__c.addDays(dateDiff) < Date.today().addDays(3)) ? Date.today().addDays(3) : is.Send_Date__c.addDays(dateDiff);
				is.Payment_Date__c 	= is.Send_Date__c + 30;
				schedulesToUpdate.add(is);
			}
		}

		if (schedulesToUpdate.size() > 0 ) update schedulesToUpdate;
	}

	// METHOD PURPOSE: Remove any existing equipment reservations for the Opportunity
	// if it is changed from Closed Won to any other status
	public static void removeReservations(Set<Id> oppIds){

		List<Reservation__c> reservations = [SELECT Id FROM Reservation__c
											WHERE Opportunity__c IN: oppIds];

		if (!reservations.isEmpty()){
			delete reservations;
		}

	}

	// METHOD PURPOSE: Update the dates on any existing equipment reservations when
	// the project dates on the Opportunity are changed
	public static void updateReservationDates(Map<Id,Integer> startChange, Map<Id,Integer> endChange){

		System.debug('method called');

		List<Reservation__c> reservations = [SELECT Id, Opportunity__c, Start_Date__c, End_Date__c
												FROM Reservation__c
												WHERE Opportunity__c IN: startChange.keySet()];

		for (Reservation__c r : reservations){
			r.Start_Date__c = r.Start_Date__c.addDays(startChange.get(r.Opportunity__c)*-1);
			r.End_Date__c = r.End_Date__c.addDays(endChange.get(r.Opportunity__c)*-1);
		}

		if (!reservations.isEmpty()){
			update reservations;
		}

	}

	// METHOD PURPOSE: Create a contract document when the Opportunity is set to closed won, if the
	// Opportunity does not already have a contract
	public static void createContracts(Set<Id> oppIds){

		List<SBQQ__Quote__c> quotesToConvert = new List<SBQQ__Quote__c>();

		List<Opportunity> oppsInTrigger = [SELECT Id, Legacy__c,
										(SELECT Id, Version__c, SBQQ__Status__c, SBQQ__NetAmount__c, SBQQ__Opportunity2__c,
												Cost_of_sale__c, Gross_Margin__c, Stage__c, Gross_Profit__c, SBQQ__Primary__c,
												Proposal_Introduction__c, Proposal_Conclusion__c, SBQQ__LineItemsGrouped__c,
												SBQQ__Opportunity2__r.Name, SBQQ__Opportunity2__r.Filtered_Job_Number__c,
												SBQQ__Opportunity2__r.Account.SOWRecipient__c
										FROM SBQQ__Quotes2__r
										WHERE SBQQ__Primary__c = TRUE)
										FROM Opportunity
										WHERE Id IN : oppIds];

			for (Opportunity opp : oppsInTrigger){
			if (!opp.Legacy__c && !opp.SBQQ__Quotes2__r.isEmpty()
					&& opp.SBQQ__Quotes2__r[0].Stage__c != 'Contract'
					&& opp.SBQQ__Quotes2__r[0].Stage__c != 'Reconciliation'){
				quotesToConvert.add(opp.SBQQ__Quotes2__r[0]);
			}
		}

		String result = PrimaryQuoteController.createContractsApex(quotesToConvert);
	}
}