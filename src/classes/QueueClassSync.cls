/**
 * Created by Ronan Williams on 28/11/2018.
 */

public class QueueClassSync implements Queueable, Database.AllowsCallouts {

    public void execute(QueueableContext context){

        // refresh the Opportunity sync with Quickbooks classes
        QuickbooksClassSync.refreshClassSync(new Map<String,String>());

    }

}