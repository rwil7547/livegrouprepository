/**
 * Created by Ronan Williams on 25/09/2018.
 */
@IsTest
global class JSONParserPeopleHRHolidayMock implements HttpCalloutMock{

    global HTTPResponse respond(HTTPRequest req) {

        // mock response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"isError":false,"Status":0,"Message":"The requested processed successfully.","Result"' +
                ':[{"AnnualLeaveTxnId":6749190,"StartDate":"2015-05-22","EndDate":"2015-05-22","DurationType":' +
                '1,"DurationInDays":1.00,"DurationInMinutes":450,"DurationInDaysThisPeriod":1.00,' +
                '"DurationInMinutesThisPeriod":450,"PartOfDay":"","StartDatePartOfTheDay":"","EndDatePartOfTheDay"' +
                ':"","RequesterComments":"Hi Andrew, I have 4 days I need to use before the end of June. Im ' +
                'going to Brighton this weekend and was hoping to use this Friday to take one of the ' +
                'days.RegardsRonan","ApproverComments":"","Approver":"Andrew Willson (X)",' +
                '"Status":"Approved","LastActionDateTime":"2015-05-18 11:52:43","IsToilHoliday":false' +
                ',"ReferenceId":""},{"AnnualLeaveTxnId":7023700,"StartDate":"2015-06-12","EndDate":"2015-06-15"' +
                ',"DurationType":1,"DurationInDays":2.00,"DurationInMinutes":900,"DurationInDaysThisPeriod":2.00' +
                ',"DurationInMinutesThisPeriod":900,"PartOfDay":"","StartDatePartOfTheDay":"","EndDatePartOfTheDay"' +
                ':"","RequesterComments":"","ApproverComments":"","Approver":"Aurelie Konter","Status":"Approved"' +
                ',"LastActionDateTime":"2015-06-09 10:04:19","IsToilHoliday":false,"ReferenceId":""},' +
                '{"AnnualLeaveTxnId":7292670,"StartDate":"2015-06-26","EndDate":"2015-06-26","DurationType"' +
                ':1,"DurationInDays":1.00,"DurationInMinutes":450,"DurationInDaysThisPeriod":1.00,' +
                '"DurationInMinutesThisPeriod":450,"PartOfDay":"","StartDatePartOfTheDay":"","EndDatePartOfTheDay":' +
                '"","RequesterComments":"Last remaining day carried over which I need to use before end of June",' +
                '"ApproverComments":"Approved from email","Approver":"Toby Lewis","Status":"Approved",' +
                '"LastActionDateTime":"2015-06-23 14:06:30","IsToilHoliday":false,"ReferenceId":""},' +
                '{"AnnualLeaveTxnId":7380846,"StartDate":"2015-07-03","EndDate":"2015-07-03","DurationType":' +
                '1,"DurationInDays":1.00,"DurationInMinutes":450,"DurationInDaysThisPeriod":1.00,' +
                '"DurationInMinutesThisPeriod":450,"PartOfDay":"","StartDatePartOfTheDay":"",' +
                '"EndDatePartOfTheDay":"","RequesterComments":"Im going to a wedding in North Wales on ' +
                'Saturday and completely forgot until now to book off the Friday for our travel.","ApproverComments":' +
                '"Approved from email","Approver":"Toby Lewis","Status":"Approved","LastActionDateTime":' +
                '"2015-06-29 10:30:37","IsToilHoliday":false,"ReferenceId":""},{"AnnualLeaveTxnId":8547197,' +
                '"StartDate":"2015-08-26","EndDate":"2015-09-15","DurationType":1,"DurationInDays":14.00,' +
                '"DurationInMinutes":6300,"DurationInDaysThisPeriod":14.00,"DurationInMinutesThisPeriod":' +
                '6300,"PartOfDay":"","StartDatePartOfTheDay":"","EndDatePartOfTheDay":"","RequesterComments":' +
                '"","ApproverComments":"","Approver":"Aurelie Konter","Status":"Approved","LastActionDateTime"' +
                ':"2015-09-01 09:33:15","IsToilHoliday":false,"ReferenceId":""},{"AnnualLeaveTxnId":11982166,' +
                '"StartDate":"2015-12-04","EndDate":"2015-12-07","DurationType":1,"DurationInDays":2.00,' +
                '"DurationInMinutes":900,"DurationInDaysThisPeriod":2.00,"DurationInMinutesThisPeriod":900,' +
                '"PartOfDay":"","StartDatePartOfTheDay":"","EndDatePartOfTheDay":"","RequesterComments":"",' +
                '"ApproverComments":"Approved from email","Approver":"Rosie Brymer","Status":"Approved",' +
                '"LastActionDateTime":"2015-11-18 12:01:05","IsToilHoliday":false,"ReferenceId":""}]}');
        res.setStatusCode(200);
        return res;
    }

}