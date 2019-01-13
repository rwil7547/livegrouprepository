/**
 * Created by Ronan Williams on 11/10/2018.
 */

//global class SalesDashboardScheduler implements Schedulable, Database.AllowsCallouts {
global class SalesDashboardScheduler implements Schedulable {


    global void execute(SchedulableContext ctx) {

        // get current balance
        SalesDashboardUtils.getCurrentBalance();

        // create snapshots
        SalesDashboardUtils.createSnapshots();

    }

}