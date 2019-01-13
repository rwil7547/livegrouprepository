/**
 * Created by Ronan Williams on 28/11/2018.
 */

public class QueueAdjustments implements Queueable{

    public void execute(QueueableContext context) {

        // run final adjustment of all opportunities
        SalesDashboardUtils.adjustOpportunities();

        // when complete, intialise month end figures commit
        System.enqueueJob(new QueueMonthEndCommit());

    }
}