/**
 * Created by Ronan Williams on 25/09/2018.
 */

global class JSONParserPeopleHREmployeeMock implements HttpCalloutMock{

    global HTTPResponse respond(HTTPRequest req) {

        // mock response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"isError":false,"Status":0,"Message":"The request processed successfully.","Result"' +
                ':[{"EmployeeId":{"DisplayValue":"PW4","FieldHistory":[]},"Title":' +
                '{"DisplayValue":"Ms","FieldHistory":[]},"FirstName":{"DisplayValue":"Rosie","FieldHistory":[]},' +
                '"LastName":{"DisplayValue":"Brymer","FieldHistory":[]},"OtherName":' + '' +
                '{"DisplayValue":"","FieldHistory":[]},"KnownAs":{"DisplayValue":"","FieldHistory":[]},"EmailId":' +
                '{"DisplayValue":"Rosie.Ford@livegroup.co.uk","FieldHistory":[]},"StartDate":' + '' +
                '{"DisplayValue":"2005-03-08","FieldHistory":[]},"DateOfBirth":{"DisplayValue":"1957-04-26",' +
                '"FieldHistory":[]},"JobRole":{"DisplayValue":"Sales Manager",' +
                '"FieldHistoryForJobRole":[]},"Company":{"DisplayValue":"Live Group Ltd","FieldHistoryForEffectiveDate"' +
                ':[]},"CompanyEffectiveDate":{"DisplayValue":""}' +
                ',"Location":{"DisplayValue":"Head Office","FieldHistoryForEffectiveDate":[]},"LocationEffectiveDate"' +
                ':{"DisplayValue":""},"Department":{"DisplayValue":"BID' +
                ' Response / Marketing","FieldHistoryForEffectiveDate":[]},"DepartmentEffectiveDate' +
                '":{"DisplayValue":""},"JobRoleChangeDate":{"DisplayValue":""},"ReportsTo":' +
                '{"DisplayValue":"Toby Lewis","FieldHistoryForEffectiveDate":[]},"ReportsToEffectiveDate"' +
                ':{"DisplayValue":""},"ReportsToEmployeeId":{"DisplayValue":"PW6"},' +
                '"ReportsToEmailAddress":{"DisplayValue":"Toby.Lewis@livegroup.co.uk"},"NISNumber":' +
                '{"DisplayValue":"","FieldHistory":[]},"Nationality":{"DisplayValue":"British",' +
                '"FieldHistory":[]},"EmploymentType":{"DisplayValue":"Part Time","FieldHistoryForEffectiveDate":[]}' +
                ',"EmploymentTypeEffectiveDate":{"DisplayValue":""},"EmployeeStatus"' +
                ':{"DisplayValue":"1"},"HolidayAllowanceDays":{"DisplayValue":"19.50"},"HolidayAllowanceMins":' +
                '{"DisplayValue":"7740"},"NoticePeriod":{"DisplayValue":"","FieldHistory":' +
                '[]},"ProbationEndDate":{"DisplayValue":"2005-06-10","FieldHistory":[]},"Gender":{"DisplayValue":' +
                '"Female","FieldHistory":[]},"AnalysisCode1LabelText":{"DisplayValue":""' +
                ',"FieldHistory":[]},"AnalysisCode2LabelText":{"DisplayValue":"","FieldHistory":[]},"ContactDetail"' +
                ':{"Address":{"DisplayValue":' +
                '"Dragon\u003cbr /\u003eUsk Road\u003cbr /\u003eLlanvaches\u003cbr /\u003eCaldicot\u003cb' +
                'r /\u003eMonmouthshire\u003cbr /\u003eNP26 3AZ","FieldHistory":[]},' +
                '"WorkPhoneNumber":{"DisplayValue":" 441633400605","FieldHistory":[]},"PersonalPhoneNumber":{' +
                '"DisplayValue":" 441633400605","FieldHistory":[]},"PersonalEmail":' +
                '{"DisplayValue":"rosiebrymer@gmail.com","FieldHistory":[]},"Mobile":{"DisplayValue":"07944 172604",' +
                '"FieldHistory":[]}},"OtherContact":[],"RightToWork":[],"BackgroundDetail"' +
                ':[],"BankDetail":{"BankName":{"DisplayValue":"","FieldHistory":[]},"BankAddress":' +
                '{"DisplayValue":"","FieldHistory":[]},"BankCode":{"DisplayValue":"","FieldHistory":[]},' +
                '"AccountNumber":{"DisplayValue":"","FieldHistory":[]},"AccountName":{"DisplayValue":' +
                '"","FieldHistory":[]}},"EmploymentDetail":{"PayrollCompany":{"DisplayValue":"' +
                '","FieldHistory":[]},"PayrollID":{"DisplayValue":"","FieldHistory":[]},"TimeAndAttendanceID":' +
                '{"DisplayValue":"","FieldHistory":[]},"RotaID":{"DisplayValue":"",' +
                '"FieldHistory":[]},"CRMID":{"DisplayValue":"","FieldHistory":[]},"ATSID":{"DisplayValue":' +
                '"","FieldHistory":[]},"PerformanceID":{"DisplayValue":"","FieldHistory":' +
                '[]},"BenefitsID":{"DisplayValue":"","FieldHistory":[]},"System1ID":{"DisplayValue":"",' +
                '"FieldHistory":[]},"System2ID":{"DisplayValue":"","FieldHistory":[]},' +
                '"System3ID":{"DisplayValue":"","FieldHistory":[]},"MethodOfRecruitment":{"DisplayValue":' +
                '"","FieldHistory":[]}},"LeavingDate":"","ReasonForLeaving":"",' +
                '"EmployeeImage":"https://livegroup.peoplehr.net/Files/Employee/114267/5013/c77f826dbdaf4fa894090c7545c30728.jpg",' +
                '"APIColumn1":"","APIColumn2":"","APIColumn3":"' +
                '","APIColumn4":"","APIColumn5":"","AdditionalreportsTo":[],"lstFieldHistoryJobrole":null}]}');
        res.setStatusCode(200);
        return res;
    }
}