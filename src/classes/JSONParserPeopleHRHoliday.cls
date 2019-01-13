/**
 * Created by Ronan Williams on 06/09/2018.
 */

public class JSONParserPeopleHRHoliday{
    public Boolean isError;
    public Integer Status;	//0
    public String Message;	//The requested processed successfully.
    public cls_Result[] Result;
    public class cls_Result {
        public String AnnualLeaveTxnId;	//6749190
        public String StartDate;	//2015-05-22
        public String EndDate;	//2015-05-22
        public Integer DurationType;	//1
        public Decimal DurationInDays;	//1
        public Decimal DurationInMinutes;	//450
        public Decimal DurationInDaysThisPeriod;	//1
        public Decimal DurationInMinutesThisPeriod;	//450
        public String PartOfDay;	//
        public String StartDatePartOfTheDay;	//
        public String EndDatePartOfTheDay;	//
        public String RequesterComments;	//Hi Andrew, I have 4 days.
        public String ApproverComments;	//
        public String Approver;	//Andrew Willson (X)
        public String Status;	//Approved
        public String LastActionDateTime;	//2015-05-18 11:52:43
        public Boolean IsToilHoliday;
        public String ReferenceId;	//
    }
    public static JSONParserPeopleHRHoliday parse(String json){
        return (JSONParserPeopleHRHoliday) System.JSON.deserialize(json, JSONParserPeopleHRHoliday.class);
    }
}