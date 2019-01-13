public class ScheduledQuickbooksCDCInvoices implements Schedulable {

    public void execute(SchedulableContext ctx) {
		
		// call Quickbooks change data capture service for latest
		// invoice records
		QuickbooksChangeDataCapture.getInvoices();

    }
}