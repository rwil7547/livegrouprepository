/**
 * Created by Ronan Williams on 14/11/2018.
 */

public with sharing class ScheduledOpportunityAdjustments implements Schedulable {

    public void execute(SchedulableContext ctx) {
        SalesDashboardUtils.adjustOpportunities();
//        SalesDashboardUtils.adjustCalderCommissions();
    }
}