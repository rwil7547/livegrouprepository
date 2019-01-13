/**
 * Created by Ronan Williams on 20/06/2018.
 */

@IsTest
public class CashFlowMultiRequestMock implements HttpCalloutMock {
    Map<String, HttpCalloutMock> requests;

    public CashFlowMultiRequestMock(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpCalloutMock mock = requests.get(req.getEndpoint());
        return mock.respond(req);
    }

    public void addRequestMock(String url, HttpCalloutMock mock) {
        requests.put(url, mock);
    }
}