/**
* Author: Azmath
* Desc  : Mock class for create incomplete service.
 */
@isTest
global class ICA_MockHttpRespCreateIncompServiceNeg implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req)
    {
        string body='{"O_isSucess":"false","O_draftNumber":""}  ';
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type','application/json');
        resp.setBody(body);
        resp.setStatusCode(200);
        return resp;
    }
}