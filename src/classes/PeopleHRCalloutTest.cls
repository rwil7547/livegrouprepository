/**
 * Created by Ronan Williams on 25/09/2018.
 */
@IsTest
public class PeopleHRCalloutTest {

    @IsTest
    public static void testEmployeeCallout(){

        Test.startTest();
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new JSONParserPeopleHREmployeeMock());

        // Call method to test
        PeopleHRCallout.getEmployees();
        Test.stopTest();

    }

    @IsTest
    public static void testHolidayCallout(){

        Employee1__c emp = new Employee1__c(
                FirstName__c    = 'Test',
                LastName__c     = 'Test',
                PeopleHRId__c   = '12344',
                Active__c       = true,
                Onsite__c       = true
        );

        insert emp;

        Test.startTest();
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new JSONParserPeopleHRHolidayMock());

        // Call method to test
        PeopleHRCallout.getHolidays();
        Test.stopTest();

    }

}