/**
* Author: Azmath
* Desc  : Mock class for ADP service.
 */
@isTest
global class ADP_MockHttpRespSubmitRequest implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req)
    {
        string body='{"UD_Output":{"return":{"transId":"1234"}}}';
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type','application/json');
        resp.setBody(body);
        resp.setStatusCode(200);
        return resp;
    }
}