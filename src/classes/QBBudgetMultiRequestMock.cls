/**
 * Created by Ronan Williams on 29/01/2019.
 */
@IsTest
public class QBBudgetMultiRequestMock implements HttpCalloutMock {
    Map<String, HttpCalloutMock> requests;

    public QBBudgetMultiRequestMock(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
    }

    public HTTPResponse respond(HTTPRequest req) {
        if (requests.containsKey(req.getEndpoint())){
            HttpCalloutMock mock = requests.get(req.getEndpoint());
            return mock.respond(req);
        } else {
            HttpCalloutMock mock = requests.get('pnl');
            return mock.respond(req);
        }
    }

    public void addRequestMock(String url, HttpCalloutMock mock) {
        requests.put(url, mock);
    }
}