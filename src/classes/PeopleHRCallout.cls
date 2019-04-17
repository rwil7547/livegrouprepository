/**
 * Created by Ronan Williams on 05/09/2018.
 */

public class PeopleHRCallout {

    @Future(Callout=True)
    public static void getEmployees(){

        Http http = new Http();

        HttpRequest request = new HttpRequest();
        request.setBody('{' +
                '"APIKey": "d5a8306e-9c56-4404-bc4d-91cb4c869e34",' +
                '"Action": "GetAllEmployeeDetail",' +
                '"IncludeLeavers":"true"}');
        request.setEndpoint('https://api.peoplehr.net/Employee');
        request.setMethod('POST');

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {

            List<Employee1__c> employees = new List<Employee1__c>();

            JSONParserPeopleHREmployee parsedResults = JSONParserPeopleHREmployee.parse(response.getBody());

            for (JSONParserPeopleHREmployee.cls_Result result : parsedResults.Result) {

                Boolean active = (result.EmployeeStatus.DisplayValue == '3') ? false : true;

                employees.add(new Employee1__c(
                        FirstName__c    = result.FirstName.DisplayValue,
                        LastName__c     = result.LastName.DisplayValue,
                        Position__c     = result.JobRole.DisplayValue,
                        ImageLink__c    = result.EmployeeImage,
                        PeopleHRId__c   = result.EmployeeId.DisplayValue,
                        Email__c        = result.EmailId.DisplayValue,
                        Active__c       = active
                ));

            }

            Schema.SObjectField key = Employee1__c.Fields.PeopleHRId__c;

            if (!employees.isEmpty()){
                Database.upsert(employees, key, false);
            }
        }
    }

    @Future(Callout=True)
    public static void getHolidays() {

        List<Employee1__c> activeEmployees = [
                SELECT PeopleHRId__c, Id
                FROM Employee1__c
                WHERE PeopleHRId__c != NULL
                AND Active__c = TRUE
                AND Onsite__c = TRUE
        ];

        List<Holiday__c> holidays = new List<Holiday__c>();

        String fallBack       = String.valueOf(Date.today().addDays(-30));
        String futureLimit    = String.valueOf(Date.today().addDays(365));

        Set<String> existingHolidayIds      = getHolidayIds(Date.today().addDays(-30));

        for (Employee1__c emp : activeEmployees) {

            Http http = new Http();

            HttpRequest request = new HttpRequest();
            request.setBody('{ ' +
                    '"APIKey" : "d5a8306e-9c56-4404-bc4d-91cb4c869e34", ' +
                    '"Action" : "GetHolidayDetail",' +
                    '"EmployeeId" : "' + emp.PeopleHRId__c + '", ' +
                    '"StartDate": "' + fallBack + '", ' +
                    '"' + futureLimit + '": "2020-04-01" }');
            request.setEndpoint('https://api.peoplehr.net/Holiday');
            request.setMethod('POST');

            HttpResponse response = http.send(request);

            system.debug(response.getBody());

            if (response.getStatusCode() == 200) {

                JSONParserPeopleHRHoliday parsedResults = JSONParserPeopleHRHoliday.parse(response.getBody());

                for (JSONParserPeopleHRHoliday.cls_Result result : parsedResults.Result) {

                    system.debug(result);

                    holidays.add(new Holiday__c(
                            Employee__c     = emp.Id,
                            PeopleHRId__c   = result.AnnualLeaveTxnId,
                            Start__c        = Date.valueOf(result.StartDate),
                            End__c          = Date.valueOf(result.EndDate)
                    ));

                    existingHolidayIds.remove(result.AnnualLeaveTxnId);
                }
            }
        }
        Schema.SObjectField key = Holiday__c.Fields.PeopleHRId__c;

        if (!existingHolidayIds.isEmpty()){
            system.debug('deleting the following ' + existingHolidayIds);
            delete [SELECT Id FROM Holiday__c WHERE PeopleHRId__c IN :existingHolidayIds];
        }

        if (!holidays.isEmpty()) {
            Database.upsert(holidays, key, false);
        }
    }

    public static Set<String> getHolidayIds(Date fallback){

        Set<String> holidayIds = new Set<String>();

        for (Holiday__c holiday : [SELECT Id, PeopleHRId__c, Employee__r.FirstName__c, Start__c FROM Holiday__c
                                    WHERE End__c >=: fallback]){
            system.debug('existing holiday id of ' + holiday.Id + ' for ' +  holiday.Employee__r.FirstName__c + ' on ' + holiday.Start__c);
            holidayIds.add(holiday.PeopleHRId__c);
        }

        return holidayIds;
    }

}