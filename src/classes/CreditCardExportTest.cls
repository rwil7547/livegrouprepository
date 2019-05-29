/**
 * Created by Ronan Williams on 22/05/2019.
 */

@IsTest
public class CreditCardExportTest {

    @IsTest
    public static void testPostReport(){

        // insert employee record
        insert new Employee1__c(
            FirstName__c            = 'Test',
            LastName__c             = 'Test',
            Email__c                = 'test@test.com',
            ExpensifyUserID__c      = 'testId',
            ExpensifyUserSecret__c  = 'testSecret',
            PeopleHRId__c           = 'test'
        );

        // sample csv data passed from visualforce page
        String csvString =
                'ACC.FIRST NAME,ACC.LAST NAME,FIN.TRANSACTION DESCRIPTION,FIN.TRANSACTION AMOUNT,FIN.ORIGINAL CURRENCY AMOUNT,' +
                'MCH.CITY NAME,FIN.ORIGINAL ISO CURRENCY CODE SYMBOL,FIN.TRANSACTION DATE,FIN.POSTING DATE\n' +
                'T,TEST,SWTRAINS PETERSFIELD S,00000000000000042.80,00000000000000042.80,PETERSFIELD,GBP,12/03/2019,13/03/2019\n' +
                'T,TEST,BENUGO MINISTRY OF JUS,00000000000000015.00,00000000000000015.00,LONDON,GBP,12/03/2019,13/03/2019\n' +
                'T,TEST,TFL TRAVEL CH,00000000000000012.00,00000000000000012.00,TFL.GOV.UK/CP,GBP,12/03/2019,13/03/2019\n' +
                'T,TEST,WASABI WATERLOO STATIO,00000000000000013.40,00000000000000013.40,LONDON,GBP,12/03/2019,13/03/2019';


        Test.startTest();
        // set mock
        Test.setMock(HttpCalloutMock.class, new CreditCardExportMock());

        // test parsing the csv and returning objects to visualforce page
        List<CreditCardExportController.CreditCardReport> reports = CreditCardExportController.parseCSVString(csvString);

        System.debug(reports);

        // test posting report
        String response = CreditCardExportController.postReport(reports[0]);
        Test.stopTest();

    }

}