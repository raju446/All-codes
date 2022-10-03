/**
* Author: Azmath
* Desc  : Mock class for Initial approval service.
 */
@isTest
global class ICA_MockHttpResponseIAServiceNeg2 implements HttpCalloutMock
{
    global HttpResponse respond(HttpRequest req)
    {
        string body = '{"UD_Output":{"isSuccess":false}}';
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type','application/json');
        resp.setBody(body);
        resp.setStatusCode(400);
        return resp;
    }
}