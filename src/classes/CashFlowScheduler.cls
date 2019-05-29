/**
 * Created by Ronan Williams on 04/07/2018.
 */

global class CashFlowScheduler implements Schedulable {

    global void execute(SchedulableContext sc){

        Boolean isRunningTest = Test.isRunningTest();

        if (!isRunningTest){
            CashflowGenerator.buildFlowFuture(false,false);
        }
    }
}