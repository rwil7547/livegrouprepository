/**
 * Created by Ronan Williams on 19/10/2018.
 */

@IsTest
public with sharing class QBProfitAndLossCalloutTest {

    @IsTest
    public static void testProfilAndLossCallout(){

        Test.setMock(HttpCalloutMock.class, new QuickbooksProfitAndLossCalloutMock());

        Test.startTest();
        QuickbooksProfitAndLossCallout.getProfitAndLoss();
        Test.stopTest();


    }
}