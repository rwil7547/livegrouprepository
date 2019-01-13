/**
 * Created by Ronan Williams on 23/07/2018.
 */

@IsTest
public class MATControllerTest {

    @TestSetup
    public static void doSetup(){

        List<Revenue_Summary__c> summaries = new List<Revenue_Summary__c>();

        for (Integer x = 0; x < 25; x++){
            Revenue_Summary__c rs = new Revenue_Summary__c(
                    Name = String.valueOf(x),
                    Month__c = Date.today().addMonths(-x),
                    Confirmed_Net_Amount__c = 500,
                    Confirmed_Gross_Profit__c = 250,
                    Operating_Cost__c = 200
            );
            summaries.add(rs);
        }

        insert summaries;
    }


    @IsTest
    public static void testController() {

        MATController matCont = new MATController();

        System.assertEquals(12,matCont.entries.size());

    }



}