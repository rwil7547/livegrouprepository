/**
 * Created by Ronan Williams on 12/11/2018.
 */

public class ScheduledQuickbooksClassSync implements Schedulable {

    public void execute(SchedulableContext ctx) {

        // call Quickbooks to query for any class Ids which have not been synced with opps
        QuickbooksClassSync.refreshClassSync();

    }

}