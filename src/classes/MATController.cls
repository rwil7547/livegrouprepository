public class MATController {

	public List<matEntry> entries {get; set;}

	public class matEntry {

		public String period {get; set;}
		public Decimal revenue {get; set;}
		public Decimal grossProfit {get; set;}
		public Decimal preTaxProfit {get; set;}
	}


	public MATController() {

		entries = new List<matEntry>();

		for (Integer x = 0; x < 12; x++){

			Date start = Date.today().addMonths(-x).toStartOfMonth();
			Date endDate = start.addMonths(-12).toStartOfMonth();

			List<Revenue_Summary__c> sums = [SELECT Confirmed_Net_Amount__c, Confirmed_Gross_Profit__c,
													Confirmed_Net_Profit__c, Calendar_Month__c
											FROM Revenue_Summary__c
											WHERE Month__c < :start
											AND Month__c >= :endDate
											ORDER BY Month__c DESC];

			matEntry entry = new matEntry();
			entry.period = sums[11].Calendar_Month__c + ' - ' + sums[0].Calendar_Month__c;
			entry.revenue = 0;
			entry.grossProfit = 0;
			entry.preTaxProfit = 0;

			for (Revenue_Summary__c rs : sums){
				entry.revenue += rs.Confirmed_Net_Amount__c;
				entry.grossProfit += rs.Confirmed_Gross_Profit__c;
				entry.preTaxProfit += rs.Confirmed_Net_Profit__c;
			}

			entries.add(entry);
		}
	}
}