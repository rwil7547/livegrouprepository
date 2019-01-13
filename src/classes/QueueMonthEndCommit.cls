/**
 * Created by Ronan Williams on 28/11/2018.
 */

public class QueueMonthEndCommit implements Queueable{

    public void execute(QueueableContext context){

        // commit the figures on all Opportunites and adjustments
        SalesDashboardUtils.commitOpportunites();

        // intilise final class sync of Opportunities with Quickbooks
        System.enqueueJob(new QueueClassSync());

    }

}