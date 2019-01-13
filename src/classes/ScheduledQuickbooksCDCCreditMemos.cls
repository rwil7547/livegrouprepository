public class ScheduledQuickbooksCDCCreditMemos implements Schedulable {

    public void execute(SchedulableContext ctx) {
		
		// call Quickbooks change data capture service for latest
		// credit memo records
		QuickbooksChangeDataCapture.getCreditMemos(); 

    }
}