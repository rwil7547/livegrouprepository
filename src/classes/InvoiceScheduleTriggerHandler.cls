public class InvoiceScheduleTriggerHandler {

	public static Boolean noConflict = true;

	// METHOD PURPOSE: update invoice schedule amounts when one schedule changed  
	public static void updateAmounts(Map<Id,Decimal> oppIds, Set<Id> triggerIds){

		noConflict = false;

        system.debug('oppIds ' + oppIds + ' triggerIds ' + triggerIds);

		List<Invoice_Schedule__c> toUpsert = new List<Invoice_Schedule__c>();
		List<Invoice_Schedule__c> toDelete = new List<Invoice_Schedule__c>();

		// query all related invoice schedules which are available for recalculation
		List<Opportunity> oppSchedules = [SELECT Id, Event_end__c, Amount_Calder__c, Amount_Remaining__c, 
												Custom_Values__c, Amount_Invoiced2__c, ScheduleCount__c,
												ProcessedInvoices__c, Custom_Invoices__c, RequiredSchedules__c,
												(SELECT Id, Amount__c, Invoice_Sent__c, Opportunity__c
												FROM Invoice_Schedules__r
                                               WHERE Id NOT IN: triggerIds
												AND Invoice_Sent__c = FALSE
												AND Custom_Value__c = FALSE
												ORDER BY Name DESC)
											FROM Opportunity 
											WHERE Id IN: oppIds.keySet()];

		// reassign the remaining amount to the other schedules, or if none available 
		// create a new schedule
		for (Opportunity opp : oppSchedules) {

            if (oppIds.get(opp.Id) != 0){
                List<Invoice_Schedule__c> isList    = opp.Invoice_Schedules__r;
                Decimal reservedAmount              = opp.Amount_Invoiced2__c + opp.Custom_Values__c + oppIds.get(opp.Id);
                Decimal amountRemaining             = opp.Amount_Calder__c - reservedAmount;

                System.debug('three amts are opp.Amount_Invoiced2__c ' + opp.Amount_Invoiced2__c + ' opp.Custom_Values__c ' +
                        opp.Custom_Values__c + ' oppIds.get(opp.Id) ' + oppIds.get(opp.Id));

                if (isList.size() == 0 && (amountRemaining <= -0.01 || amountRemaining >= 0.01)) { // if amountRemaining < -0.01 || amountRemaining > 0.01
                    Invoice_Schedule__c is = new Invoice_Schedule__c();
                    is.Name				= 'Invoice ' + (opp.ScheduleCount__c + 1);
                    is.Opportunity__c 	= opp.Id;
                    is.Send_Date__c		= (opp.Event_end__c < Date.today()) ? Date.today() + 3 : opp.Event_end__c + 3;
                    is.Payment_Date__c 	= is.Send_Date__c + 30;
                    is.Amount__c 		= opp.Amount_Calder__c - reservedAmount;
                    toUpsert.add(is);
                } else if (isList.size() == 1) {
                    if (amountRemaining > -0.01 && amountRemaining < 0.01) { // if amountRemaining > 0.01 && amountRemaining < 0.01
                        toDelete.add(isList[0]);
                    } else {
                        isList[0].Amount__c = amountRemaining;
                        toUpsert.add(isList[0]);
                    }
                } else {
                    // work out if there are more open schedules than needed

                    // Integer reservedInvoices = Integer.valueOf(opp.ProcessedInvoices__c + opp.Custom_Invoices__c) + something;
                    Integer reservedInvoices    = Integer.valueOf(opp.ScheduleCount__c) - isList.size();
                    Integer mimimumInvoices     = (reservedInvoices >= opp.RequiredSchedules__c)
                            ? reservedInvoices + 1 : Integer.valueOf(opp.RequiredSchedules__c);
                    Integer excessInvoices      = Integer.valueOf(opp.ScheduleCount__c) - mimimumInvoices;
                    // if there are more than needed, delete the excess ones
                    if (excessInvoices > 0) {
                        for (Integer x = 0; x < excessInvoices; x++) {
                            toDelete.add(isList[x]);
                            isList.remove(x);
                        }
                    }
                    // for the remaning schedules, update their amounts
                    for (Invoice_Schedule__c is : isList) {
                        is.Amount__c = amountRemaining / isList.size();
                        toUpsert.add(is);
                    }
                }
			}
		}

		System.debug('to delete' + toDelete);
		System.debug('to upsert' + toUpsert);

		if (toDelete.size() > 0 ) 			delete toDelete;
		if (toUpsert.size() > 0) 			upsert toUpsert;

	}


	// METHOD PURPOSE: update invoice schedule payment date when the send date is changed  
	public static void updatePaymentDates(List<Invoice_Schedule__c> isList){
		for (Invoice_Schedule__c is : isList) is.Payment_Date__c = is.Send_Date__c + 30;
	}	
}