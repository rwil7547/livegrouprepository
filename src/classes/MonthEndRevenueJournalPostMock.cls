/**
 * Created by Ronan Williams on 04/12/2018.
 */

@IsTest
global class MonthEndRevenueJournalPostMock implements HttpCalloutMock{

    global HttpResponse respond(HttpRequest req) {

        // mock response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{}');
        res.setStatusCode(400);
        return res;
    }

}