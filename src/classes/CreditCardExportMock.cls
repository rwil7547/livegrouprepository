/**
 * Created by Ronan Williams on 22/05/2019.
 */

@IsTest
global class CreditCardExportMock implements HttpCalloutMock{

    global HttpResponse respond(HttpRequest req) {
        // mock response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"reportID":"45586039","reportName":"CC Statement R. Williams 26/05/2019 ","responseCode":200}');
        res.setStatusCode(200);
        return res;
    }
}