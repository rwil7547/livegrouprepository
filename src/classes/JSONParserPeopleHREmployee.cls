/**
 * Created by Ronan Williams on 05/09/2018.
 */

public class JSONParserPeopleHREmployee{
    public boolean isError;
    public Integer Status;	//0
    public String Message;	//The request processed successfully.
    public cls_Result[] Result;
    public class cls_Result {
        public cls_EmployeeId EmployeeId;
        public cls_Title Title;
        public cls_FirstName FirstName;
        public cls_LastName LastName;
        public cls_OtherName OtherName;
        public cls_KnownAs KnownAs;
        public cls_EmailId EmailId;
        public cls_StartDate StartDate;
        public cls_DateOfBirth DateOfBirth;
        public cls_JobRole JobRole;
        public cls_Company Company;
        public cls_CompanyEffectiveDate CompanyEffectiveDate;
        public cls_Location Location;
        public cls_LocationEffectiveDate LocationEffectiveDate;
        public cls_Department Department;
        public cls_DepartmentEffectiveDate DepartmentEffectiveDate;
        public cls_JobRoleChangeDate JobRoleChangeDate;
        public cls_ReportsTo ReportsTo;
        public cls_ReportsToEffectiveDate ReportsToEffectiveDate;
        public cls_ReportsToEmployeeId ReportsToEmployeeId;
        public cls_ReportsToEmailAddress ReportsToEmailAddress;
        public cls_NISNumber NISNumber;
        public cls_Nationality Nationality;
        public cls_EmploymentType EmploymentType;
        public cls_EmploymentTypeEffectiveDate EmploymentTypeEffectiveDate;
        public cls_EmployeeStatus EmployeeStatus;
        public cls_HolidayAllowanceDays HolidayAllowanceDays;
        public cls_HolidayAllowanceMins HolidayAllowanceMins;
        public cls_NoticePeriod NoticePeriod;
        public cls_ProbationEndDate ProbationEndDate;
        public cls_Gender Gender;
        public cls_AnalysisCode1LabelText AnalysisCode1LabelText;
        public cls_AnalysisCode2LabelText AnalysisCode2LabelText;
        public cls_ContactDetail ContactDetail;
        public cls_OtherContact[] OtherContact;
        public cls_RightToWork[] RightToWork;
        public cls_BackgroundDetail[] BackgroundDetail;
        public cls_BankDetail BankDetail;
        public cls_EmploymentDetail EmploymentDetail;
        public String LeavingDate;	//
        public String ReasonForLeaving;	//
        public String EmployeeImage;	//https://livegroup.peoplehr.net/Files/Employee/114267/5013/c77f826dbdaf4fa894090c7545c30728.jpg
        public String APIColumn1;	//
        public String APIColumn2;	//
        public String APIColumn3;	//
        public String APIColumn4;	//
        public String APIColumn5;	//
        public cls_AdditionalreportsTo[] AdditionalreportsTo;
        public cls_lstFieldHistoryJobrole lstFieldHistoryJobrole;
    }
    public class cls_EmployeeId {
        public String DisplayValue;	//PW4
        public cls_FieldHistory[] FieldHistory;
    }
    public class cls_FieldHistory {
    }
    public class cls_Title {
        public String DisplayValue;	//Ms
        public cls_FieldHistory[] FieldHistory;
    }
    public class cls_FirstName {
        public String DisplayValue;	//Rosie
        public cls_FieldHistory[] FieldHistory;
    }
    public class cls_LastName {
        public String DisplayValue;	//Brymer
        public cls_FieldHistory[] FieldHistory;
    }
    public class cls_OtherName {
        public String DisplayValue;	//
        public cls_FieldHistory[] FieldHistory;
    }
    public class cls_KnownAs {
        public String DisplayValue;	//
        public cls_FieldHistory[] FieldHistory;
    }
    public class cls_EmailId {
        public String DisplayValue;	//Rosie.Ford@livegroup.co.uk
        public cls_FieldHistory[] FieldHistory;
    }
    public class cls_StartDate {
        public String DisplayValue;	//2005-03-08
        public cls_FieldHistory[] FieldHistory;
    }
    public class cls_DateOfBirth {
        public String DisplayValue;	//1957-04-26
        public cls_FieldHistory[] FieldHistory;
    }
    public class cls_JobRole {
        public String DisplayValue;	//Sales Manager
        public cls_FieldHistoryForJobRole[] FieldHistoryForJobRole;
    }
    public class cls_FieldHistoryForJobRole {
    }
    public  class cls_Company {
        public String DisplayValue;	//Live Group Ltd
        public cls_FieldHistoryForEffectiveDate[] FieldHistoryForEffectiveDate;
    }
    public class cls_FieldHistoryForEffectiveDate {
    }
    public  class cls_CompanyEffectiveDate {
        public String DisplayValue;	//
    }
    public  class cls_Location {
        public String DisplayValue;	//Head Office
        public cls_FieldHistoryForEffectiveDate[] FieldHistoryForEffectiveDate;
    }
    public  class cls_LocationEffectiveDate {
        public String DisplayValue;	//
    }
    public class cls_Department {
        public String DisplayValue;	//BID Response / Marketing
        public cls_FieldHistoryForEffectiveDate[] FieldHistoryForEffectiveDate;
    }
    public class cls_DepartmentEffectiveDate {
        public String DisplayValue;	//
    }
    public  class cls_JobRoleChangeDate {
        public String DisplayValue;	//
    }
    public class cls_ReportsTo {
        public String DisplayValue;	//Toby Lewis
        public cls_FieldHistoryForEffectiveDate[] FieldHistoryForEffectiveDate;
    }
    public class cls_ReportsToEffectiveDate {
        public String DisplayValue;	//
    }
    public  class cls_ReportsToEmployeeId {
        public String DisplayValue;	//PW6
    }
    public class cls_ReportsToEmailAddress {
        public String DisplayValue;	//Toby.Lewis@livegroup.co.uk
    }
    public class cls_NISNumber {
        public String DisplayValue;	//
        public cls_FieldHistory[] FieldHistory;
    }
    public class cls_Nationality {
        public String DisplayValue;	//British
        public cls_FieldHistory[] FieldHistory;
    }
    public  class cls_EmploymentType {
        public String DisplayValue;	//Part Time
        public cls_FieldHistoryForEffectiveDate[] FieldHistoryForEffectiveDate;
    }
    public   class cls_EmploymentTypeEffectiveDate {
        public String DisplayValue;	//
    }
    public  class cls_EmployeeStatus {
        public String DisplayValue;	//1
    }
    public   class cls_HolidayAllowanceDays {
        public String DisplayValue;	//19.50
    }
    public   class cls_HolidayAllowanceMins {
        public String DisplayValue;	//7740
    }
    public   class cls_NoticePeriod {
        public String DisplayValue;	//
        public cls_FieldHistory[] FieldHistory;
    }
    public   class cls_ProbationEndDate {
        public String DisplayValue;	//2005-06-10
        public cls_FieldHistory[] FieldHistory;
    }
    public    class cls_Gender {
        public String DisplayValue;	//Female
        public cls_FieldHistory[] FieldHistory;
    }
    public   class cls_AnalysisCode1LabelText {
        public String DisplayValue;	//
        public cls_FieldHistory[] FieldHistory;
    }
    public   class cls_AnalysisCode2LabelText {
        public String DisplayValue;	//
        public cls_FieldHistory[] FieldHistory;
    }
    public   class cls_ContactDetail {
        public cls_Address Address;
        public cls_WorkPhoneNumber WorkPhoneNumber;
        public cls_PersonalPhoneNumber PersonalPhoneNumber;
        public cls_PersonalEmail PersonalEmail;
        public cls_Mobile Mobile;
    }
    public    class cls_Address {
        public String DisplayValue;	//Dragon<br />Usk Road<br />Llanvaches<br />Caldicot<br />Monmouthshire<br />NP26 3AZ
        public cls_FieldHistory[] FieldHistory;
    }
    public   class cls_WorkPhoneNumber {
        public String DisplayValue;	// 441633400605
        public cls_FieldHistory[] FieldHistory;
    }
    public   class cls_PersonalPhoneNumber {
        public String DisplayValue;	// 441633400605
        public cls_FieldHistory[] FieldHistory;
    }
    public class cls_PersonalEmail {
        public String DisplayValue;	//rosiebrymer@gmail.com
        public cls_FieldHistory[] FieldHistory;
    }
    class cls_Mobile {
        public String DisplayValue;	//07944 172604
        public cls_FieldHistory[] FieldHistory;
    }
    public  class cls_OtherContact {
    }
    public  class cls_RightToWork {
    }
    public  class cls_BackgroundDetail {
    }
    public  class cls_BankDetail {
        public cls_BankName BankName;
        public cls_BankAddress BankAddress;
        public cls_BankCode BankCode;
        public cls_AccountNumber AccountNumber;
        public cls_AccountName AccountName;
    }
    public  class cls_BankName {
        public String DisplayValue;	//
        public cls_FieldHistory[] FieldHistory;
    }
    public  class cls_BankAddress {
        public String DisplayValue;	//
        public cls_FieldHistory[] FieldHistory;
    }
    public  class cls_BankCode {
        public String DisplayValue;	//
        public cls_FieldHistory[] FieldHistory;
    }
    class cls_AccountNumber {
        public String DisplayValue;	//
        public cls_FieldHistory[] FieldHistory;
    }
    class cls_AccountName {
        public String DisplayValue;	//
        public cls_FieldHistory[] FieldHistory;
    }
    class cls_EmploymentDetail {
        public cls_PayrollCompany PayrollCompany;
        public cls_PayrollID PayrollID;
        public cls_TimeAndAttendanceID TimeAndAttendanceID;
        public cls_RotaID RotaID;
        public cls_CRMID CRMID;
        public cls_ATSID ATSID;
        public cls_PerformanceID PerformanceID;
        public cls_BenefitsID BenefitsID;
        public cls_System1ID System1ID;
        public cls_System2ID System2ID;
        public cls_System3ID System3ID;
        public cls_MethodOfRecruitment MethodOfRecruitment;
    }
    class cls_PayrollCompany {
        public String DisplayValue;	//
        public cls_FieldHistory[] FieldHistory;
    }
    class cls_PayrollID {
        public String DisplayValue;	//
        public cls_FieldHistory[] FieldHistory;
    }
    class cls_TimeAndAttendanceID {
        public String DisplayValue;	//
        public cls_FieldHistory[] FieldHistory;
    }
    class cls_RotaID {
        public String DisplayValue;	//
        public cls_FieldHistory[] FieldHistory;
    }
    class cls_CRMID {
        public String DisplayValue;	//
        public cls_FieldHistory[] FieldHistory;
    }
    class cls_ATSID {
        public String DisplayValue;	//
        public cls_FieldHistory[] FieldHistory;
    }
    class cls_PerformanceID {
        public String DisplayValue;	//
        public cls_FieldHistory[] FieldHistory;
    }
    class cls_BenefitsID {
        public String DisplayValue;	//
        public cls_FieldHistory[] FieldHistory;
    }
    class cls_System1ID {
        public String DisplayValue;	//
        public cls_FieldHistory[] FieldHistory;
    }
    class cls_System2ID {
        public String DisplayValue;	//
        public cls_FieldHistory[] FieldHistory;
    }
    class cls_System3ID {
        public String DisplayValue;	//
        public cls_FieldHistory[] FieldHistory;
    }
    class cls_MethodOfRecruitment {
        public String DisplayValue;	//
        public cls_FieldHistory[] FieldHistory;
    }
    class cls_AdditionalreportsTo {
    }
    class cls_lstFieldHistoryJobrole {
    }
    public static JSONParserPeopleHREmployee parse(String json){
        return (JSONParserPeopleHREmployee) System.JSON.deserialize(json, JSONParserPeopleHREmployee.class);
    }


}