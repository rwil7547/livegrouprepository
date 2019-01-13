public class OpportunityBannerController {

	public Opportunity opp {get;set;}
	public List<invoiceSchedule> schedules {get;set;}
	public String listView {get; set;}

	public class invoiceSchedule {
		public String name {get;set;}
		public Decimal amount {get;set;}
		public String invoiceStatus {get;set;}
		public String paymentStatus {get; set;}

		public invoiceSchedule(String name, Decimal amount, Date sendDate, 
								Boolean sent, Date payDate, Boolean paid) {
			this.name 	= name.toUpperCase();
			this.amount = amount;
			if (sent) {
				this.invoiceStatus = 'Invoice sent';
			} else if (sendDate == Date.today()) {
				this.invoiceStatus = 'Invoice due today';
			} else if (sendDate > Date.today()) {
				this.invoiceStatus = 'Invoice due in ' + 
									 Date.today().daysBetween(sendDate) + ' days';
			} else {
				this.invoiceStatus = 'Invoice due ' + 
									 sendDate.daysBetween(Date.today()) + ' days ago';
			}

			if (!sent) {
				this.paymentStatus = '';
			} else if (paid) {
				this.paymentStatus = 'Payment recieved';
			} else if (payDate == Date.today()) {
				this.paymentStatus = 'Payment due today';
			} else if (payDate > Date.today()) {
				this.paymentStatus = 'Payment due in ' + 
									  Date.today().daysBetween(payDate) + ' days';
			} else {
				this.paymentStatus = 'Payment due ' + 
									  payDate.daysBetween(Date.today()) + ' days ago';
			}
		}	
	}

	public OpportunityBannerController() {

		opp = 	[SELECT Id, Name, StageName, AccountId,
						(SELECT Id, Name, Invoice_Sent__c, Invoice_Paid__c, 
								Amount__c, Send_Date__c, Payment_Date__c, 
								Status2__c 
						FROM Invoice_Schedules__r
						ORDER BY Name ASC) 
				FROM Opportunity
				WHERE Id =: ApexPages.currentPage().getParameters().get('id')];

		schedules = new List<invoiceSchedule>(); 		

		for (Invoice_Schedule__c is : opp.Invoice_Schedules__r) {
			invoiceSchedule iss = new invoiceSchedule(
				is.Name, 
				is.Amount__c,
				is.Send_Date__c,
				is.Invoice_Sent__c,
				is.Payment_Date__c,
				is.Invoice_Paid__c
				);
			schedules.add(iss);
		}

		String shortId = String.valueOf(opp.Id).substring(0, 15);
		listView = System.URL.getSalesforceBaseURL().toExternalForm() + '/apex/InvoiceSchedulesRelatedList?id=' + shortId;

	}
}