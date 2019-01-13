public class AccountQuickbooksStatusController {

	public boolean rendered {public get; private set;}

	// method purpose: make post request callout to Quickbooks 
	public PageReference createCustomer(){

		String accountId = ApexPages.currentPage().getParameters().get('Id');

		Set<Id> ids = new Set<Id>{accountId};

		QuickbooksCustomerBatch.createCustomers(ids);

		rendered = false;

        return null;

	}

	public AccountQuickbooksStatusController(ApexPages.StandardController stdController) {
		rendered = true;
	}
}