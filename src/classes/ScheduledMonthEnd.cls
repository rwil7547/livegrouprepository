/**
 * Created by Ronan Williams on 28/11/2018.
 */

public class ScheduledMonthEnd implements Schedulable {


    public void execute(SchedulableContext ctx) {

        // begin monthend sequence by initialising final adjustment
        System.enqueueJob(new QueueAdjustments());

    }
}