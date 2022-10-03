/**
* Author: Azmath
* Desc  : Mock class for create incomplete service.
 */
@isTest
global class ICA_MockHttpRespCreateIncompServiceErr implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req)
    {
        string body='{"O_isSucess":"false","O_draftNumber":""}  ';
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type','application/json');
        resp.setBody(body);
        resp.setStatusCode(400);
        return resp;
    }
}