/**
 * Created by Ronan Williams on 04/07/2018.
 */
@IsTest
public class calderPipelineControllerTest {

    @IsTest
    public static void testController(){

        Account acc = (Account)SmartFactory.createSObject('Account');
        insert acc;

        // three opportunities which should appear in VF page
        Opportunity opp = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp.AccountId = acc.Id;
        opp.Amount = 6000;
        opp.Calder_Opportunity__c = true;
        opp.StageName = 'Closed Won';
        opp.Invoice_Schedule__c = 'Three stage invoice';
        opp.Event_start__c = Date.today();
        opp.Event_end__c = Date.today();
        insert opp;

        Opportunity opp2 = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp2.AccountId = acc.Id;
        opp2.Amount = 6000;
        opp2.Calder_Opportunity__c = true;
        opp2.StageName = 'Costed prospect';
        opp2.Invoice_Schedule__c = 'Three stage invoice';
        opp2.Event_start__c = Date.today().addMonths(1);
        opp2.Event_end__c = Date.today().addMonths(1);
        insert opp2;

        Opportunity opp3 = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp3.AccountId = acc.Id;
        opp3.Amount = 6000;
        opp3.StageName = 'Closed Won';
        opp3.Calder_Opportunity__c = true;
        opp3.Invoice_Schedule__c = 'Three stage invoice';
        opp3.Event_start__c = Date.today().addYears(-2);
        opp3.Event_end__c = Date.today().addYears(-2);
        insert opp3;

        // non-calder opportunity, should not appear in VF page
        Opportunity opp4 = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp4.AccountId = acc.Id;
        opp4.Amount = 6000;
        opp4.Calder_Opportunity__c = false;
        opp4.StageName = 'Closed Won';
        opp4.Invoice_Schedule__c = 'Three stage invoice';
        opp4.Event_start__c = Date.today().addMonths(2);
        opp4.Event_end__c = Date.today().addMonths(2);
        insert opp4;

        // Lost opportunity, should not appear in VF page
        Opportunity opp5 = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp5.AccountId = acc.Id;
        opp5.Amount = 6000;
        opp5.StageName = 'Closed Lost';
        opp5.Calder_Opportunity__c = true;
        opp5.Invoice_Schedule__c = 'Three stage invoice';
        opp5.Event_start__c = Date.today().addMonths(2);
        opp5.Event_end__c = Date.today().addMonths(2);
        insert opp5;

        // intialise controller
        calderPipelineController controller = new calderPipelineController();

        // assert returned values
        System.assertEquals(3, controller.oppMap.size());
        System.assertEquals(2,controller.currentOppMap.size());
        System.assertEquals(1,controller.previousOppMap.size());
        System.assertEquals(2,controller.currentMonthGroupings.size());
        System.assertEquals(1,controller.previousMonthGroupings.size());

        // add page parameters
//        System.currentPageReference().getParameters().put('opportunityId', opp.Id);
        PageReference myVfPage = new PageReference('/apex/calderPipeline3');
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('opportunityId',Opp.Id);
        String id = ApexPages.currentPage().getParameters().get('opportunityId');
        System.assertEquals(opp.Id,id);

        Test.startTest();
        // update Opportunity
        controller.oppMap.get(opp.Id).Calder_GPS_Ref__c = 'Test ref';
        controller.saveOpportunity();
        controller.newCommentMap.get(opp.Id).Comment__c = 'Test comment';
        controller.saveComment();
        Test.stopTest();

        // assert returned values
        System.assertEquals('Test comment',[SELECT Comment__c FROM Calder_Comment__c WHERE Opportunity__c = :opp.Id].Comment__c);
        System.assertEquals('Test ref',[SELECT Calder_GPS_Ref__c FROM Opportunity WHERE Id = :opp.Id].Calder_GPS_Ref__c);


    }

}