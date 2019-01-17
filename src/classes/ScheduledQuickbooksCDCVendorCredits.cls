/**
 * Created by Ronan Williams on 17/01/2019.
 */
public class ScheduledQuickbooksCDCVendorCredits implements Schedulable {

    public void execute(SchedulableContext ctx) {

        // call Quickbooks change data capture service for latest
        // bill records
        QuickbooksChangeDataCapture.getVendorCredits();

    }
}
