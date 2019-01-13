/**
 * Created by Ronan Williams on 22/11/2018.
 */
@IsTest
public class MultiRequestMock implements HttpCalloutMock {

    Map<String, HttpCalloutMock> requests;

    public MultiRequestMock(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
    }

    public HttpResponse respond(HttpRequest req) {
        HttpCalloutMock mock = requests.get(req.getEndpoint());
        return mock.respond(req);
    }

    public void addRequestMock(String url, HttpCalloutMock mock) {
        requests.put(url, mock);
    }
}
