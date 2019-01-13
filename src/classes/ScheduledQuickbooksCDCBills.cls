public class ScheduledQuickbooksCDCBills implements Schedulable {

    public void execute(SchedulableContext ctx) {
		
		// call Quickbooks change data capture service for latest
		// bill records
		QuickbooksChangeDataCapture.getBills(); 

    }
}