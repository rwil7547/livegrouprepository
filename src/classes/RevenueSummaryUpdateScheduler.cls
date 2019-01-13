global class RevenueSummaryUpdateScheduler implements Schedulable{

	global void execute(SchedulableContext ctx) {

		RevenueSummaryUpdate.UpdateSummaries();

	}

}