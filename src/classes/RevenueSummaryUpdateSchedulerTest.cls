@isTest
private class RevenueSummaryUpdateSchedulerTest {

	public static String CRON_EXP = '0 0 0 15 3 ? 2022';

	@isTest static void testScheduledJob() {

		Integer Year = Integer.valueOf(Label.RevenueSummaryYears.substring(0,4));

		Date recordDate = Date.newInstance(Year,08,01);

		Account acc = (Account)SmartFactory.createSOBject('Account');
		insert acc;
		
		// figures should appear in revenue summary confirmed and pipeline fields
		Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
		opp.AccountId = acc.Id;
		opp.Amount = 5000;
		opp.Forecast_COS__c = 2500;
		opp.StageName = 'Closed Won';
		opp.Invoice_Schedule__c = 'Single post-event invoice';
		opp.Event_Start__c = recordDate;
		opp.Event_End__c = recordDate;
		insert opp;

		// figures should appear in revenue summary pipeline fields
		Opportunity opp2 = (Opportunity)SmartFactory.createSOBject('Opportunity');
		opp2.AccountId = acc.Id;
		opp2.Amount = 5000;
		opp2.Forecast_COS__c = 2500;
		opp2.StageName = 'Pipeline Prospect';
		opp2.Probability = 50;
		opp2.Event_Start__c = recordDate;
		opp2.Event_End__c = recordDate;
		insert opp2;

		// figures should NOT appear in revenue summary confirmed or pipeline fields
		Opportunity opp3 = (Opportunity)SmartFactory.createSOBject('Opportunity');
		opp3.AccountId = acc.Id;
		opp3.Amount = 5000;
		opp3.Forecast_COS__c = 2500;
		opp3.StageName = 'Closed Lost';
		opp3.Event_Start__c = recordDate;
		opp3.Event_End__c = recordDate;
		insert opp3;

		// create revenue summary for the months in the opportunity
		Revenue_Summary__c rc = (Revenue_Summary__c)SmartFactory.createSOBject('Revenue_Summary__c');
		rc.Month__c = recordDate;
		insert rc;

		// create revenue summary for month with no opps, and with prior field values
		Revenue_Summary__c rc2 = (Revenue_Summary__c)SmartFactory.createSOBject('Revenue_Summary__c');
		rc2.Month__c = Date.newInstance(Year,09,01);
		rc2.Confirmed_Net_Amount__c = 100;
		rc2.Confirmed_Gross_Profit__c = 100;
		rc2.Pipeline_Net_Amount__c = 100;
		rc2.Pipeline_Gross_Profit__c = 100;
		insert rc2;

		Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP, 
            new RevenueSummaryUpdateScheduler());		
        Test.stopTest();

        // assert that the revenue summary with the opp dates now has the right summary figures
        System.assertEquals(5000, [SELECT Confirmed_Net_Amount__c FROM Revenue_Summary__c WHERE Id = :rc.id].Confirmed_Net_Amount__c);
        System.assertEquals(2500, [SELECT Confirmed_Gross_Profit__c FROM Revenue_Summary__c WHERE Id = :rc.id].Confirmed_Gross_Profit__c);
        System.assertEquals(10000, [SELECT Pipeline_Net_Amount__c FROM Revenue_Summary__c WHERE Id = :rc.id].Pipeline_Net_Amount__c);
        System.assertEquals(5000, [SELECT Pipeline_Gross_Profit__c FROM Revenue_Summary__c WHERE Id = :rc.id].Pipeline_Gross_Profit__c);
        System.assertEquals(7500, [SELECT Weighted_Pipeline_Net_Amount__c FROM Revenue_Summary__c WHERE Id = :rc.id].Weighted_Pipeline_Net_Amount__c);
        System.assertEquals(3750, [SELECT Weighted_Pipeline_Gross_Profit__c FROM Revenue_Summary__c WHERE Id = :rc.id].Weighted_Pipeline_Gross_Profit__c);

        // assert that the revenue summary with no opps in month has all figures reduced to zero
        System.assertEquals(0, [SELECT Confirmed_Net_Amount__c FROM Revenue_Summary__c WHERE Id = :rc2.id].Confirmed_Net_Amount__c);
        System.assertEquals(0, [SELECT Confirmed_Gross_Profit__c FROM Revenue_Summary__c WHERE Id = :rc2.id].Confirmed_Gross_Profit__c);
        System.assertEquals(0, [SELECT Pipeline_Net_Amount__c FROM Revenue_Summary__c WHERE Id = :rc2.id].Pipeline_Net_Amount__c);
        System.assertEquals(0, [SELECT Pipeline_Gross_Profit__c FROM Revenue_Summary__c WHERE Id = :rc2.id].Pipeline_Gross_Profit__c);
        System.assertEquals(0, [SELECT Weighted_Pipeline_Net_Amount__c FROM Revenue_Summary__c WHERE Id = :rc2.id].Weighted_Pipeline_Net_Amount__c);
        System.assertEquals(0, [SELECT Weighted_Pipeline_Gross_Profit__c FROM Revenue_Summary__c WHERE Id = :rc2.id].Weighted_Pipeline_Gross_Profit__c);

	}
}