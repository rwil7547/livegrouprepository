public class RevenueSummaryUpdate {

	public static void UpdateSummaries() {

		String yearsLabel = Label.RevenueSummaryYears;
		Set<Integer> calendarYears = new Set<Integer>();

		if (YearsLabel != null) {
			
			List<String> yearsInLabel = yearsLabel.split(',');
			
			for (String s : YearsInLabel) {
				calendarYears.add(Integer.valueOf(s));
			}
		}

		if (calendarYears.size() > 0) {

			for (Integer calendarYear : calendarYears) {

				// get a list of all summary objects
				List<Revenue_Summary__c> rcs = [SELECT Id, Month__c FROM Revenue_Summary__c
												WHERE CALENDAR_YEAR(Month__c) = :calendarYear];

				System.Debug('Size of list of summaries found is ' + rcs.size());

				if (rcs.size() > 0) {	

					// get a map of aggregate results of all confirmed opportunities
					// in time this will also need to include operating cost objects
					List<AggregateResult> confirmedFigures =  [SELECT CALENDAR_MONTH(Event_End__c) Month, SUM(Amount_Calder__c) Revenue, 
																	 SUM(Gross_profit_2__c) GrossProfit
																FROM Opportunity 
																WHERE StageName = 'Closed Won'
																AND CALENDAR_YEAR(Event_End__c) = :calendarYear 
																GROUP BY CALENDAR_MONTH(Event_End__c)];

					Map<Integer,Decimal> confirmedRevenue = new Map<Integer,Decimal>();
					Map<Integer,Decimal> confirmedGrossProfit = new Map<Integer,Decimal>();

					for (AggregateResult ar : confirmedFigures) {
						confirmedRevenue.put((Integer)ar.get('Month'),((Decimal)ar.get('Revenue')));
						confirmedGrossProfit.put((Integer)ar.get('Month'),((Decimal)ar.get('GrossProfit')));
					}

					// get a map of aggregate results of all pipeline and confirmed opportunities
					// in time this will also need to include operating cost objects
					List<AggregateResult> pipelineFigures =  [SELECT CALENDAR_MONTH(Event_End__c) Month, 
																	 SUM(Amount_Calder__c) Revenue, 
																	 SUM(Gross_profit_2__c) GrossProfit
																FROM Opportunity 
																WHERE StageName != 'Closed Lost'
																AND CALENDAR_YEAR(Event_End__c) = :calendarYear 
																GROUP BY CALENDAR_MONTH(Event_End__c)];

					Map<Integer,Decimal> pipelineRevenue = new Map<Integer,Decimal>();
					Map<Integer,Decimal> pipelineGrossProfit = new Map<Integer,Decimal>();

					for (AggregateResult ar : pipelineFigures) {
						pipelineRevenue.put((Integer)ar.get('Month'),((Decimal)ar.get('Revenue')));
						pipelineGrossProfit.put((Integer)ar.get('Month'),((Decimal)ar.get('GrossProfit')));
					}


					// get a map of weighted aggregate results of all pipeline and confirmed opportunities
					// in time this will also need to include operating cost objects
					List<AggregateResult> weightedPipelineFigures =  [SELECT CALENDAR_MONTH(Event_End__c) Month, 
																	 SUM(Weighted_Revenue__c) WeightedRevenue, 
																	 SUM(Weighted_Profit__c) WeightedGrossProfit
																FROM Opportunity 
																WHERE StageName != 'Closed Lost'
																AND CALENDAR_YEAR(Event_End__c) = :calendarYear 
																GROUP BY CALENDAR_MONTH(Event_End__c)];

					Map<Integer,Decimal> weightedPipelineRevenue = new Map<Integer,Decimal>();
					Map<Integer,Decimal> weightedPipelineGrossProfit = new Map<Integer,Decimal>();

					for (AggregateResult ar : weightedPipelineFigures) {
						weightedPipelineRevenue.put((Integer)ar.get('Month'),((Decimal)ar.get('WeightedRevenue')));
						weightedPipelineGrossProfit.put((Integer)ar.get('Month'),((Decimal)ar.get('WeightedGrossProfit')));
					}


					// assign each summary object the values it finds in the aggregate results
					for (Revenue_Summary__c rc : rcs) {
						if (confirmedRevenue.keySet().contains(Integer.valueOf(rc.Month__c.month()))) {
							rc.Confirmed_Net_Amount__c = confirmedRevenue.get(Integer.valueOf(rc.Month__c.month()));
						} else {
							rc.Confirmed_Net_Amount__c = 0;
						}
						if (confirmedGrossProfit.keySet().contains(Integer.valueOf(rc.Month__c.month()))) {
							rc.Confirmed_Gross_Profit__c = confirmedGrossProfit.get(Integer.valueOf(rc.Month__c.month()));
						} else {
							rc.Confirmed_Gross_Profit__c = 0;
						}
						if (pipelineRevenue.keySet().contains(Integer.valueOf(rc.Month__c.month()))) {
							rc.Pipeline_Net_Amount__c = pipelineRevenue.get(Integer.valueOf(rc.Month__c.month()));
						} else {
							rc.Pipeline_Net_Amount__c = 0;
						}
						if (pipelineGrossProfit.keySet().contains(Integer.valueOf(rc.Month__c.month()))) {
							rc.Pipeline_Gross_Profit__c = pipelineGrossProfit.get(Integer.valueOf(rc.Month__c.month()));
						} else {
							rc.Pipeline_Gross_Profit__c = 0;
						}
						if (weightedPipelineRevenue.keySet().contains(Integer.valueOf(rc.Month__c.month()))) {
							rc.Weighted_Pipeline_Net_Amount__c = weightedPipelineRevenue.get(Integer.valueOf(rc.Month__c.month()));
						} else {
							rc.Weighted_Pipeline_Net_Amount__c = 0;
						}
						if (weightedPipelineGrossProfit.keySet().contains(Integer.valueOf(rc.Month__c.month()))) {
							rc.Weighted_Pipeline_Gross_Profit__c = weightedPipelineGrossProfit.get(Integer.valueOf(rc.Month__c.month()));
						} else {
							rc.Weighted_Pipeline_Gross_Profit__c = 0;
						}
					}

					// update the list of summary objects
					update rcs;
				}
			}
		}
	}
}