/**
* Author: Azmath
* Desc  : Mock class for create incomplete service.
 */
@isTest
global class ICA_MockHttpRespCreateIncompleteService implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req)
    {
        string body='{"O_isSucess":"true","O_draftNumber":"0001036911622021300867577"}  ';
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type','application/json');
        resp.setBody(body);
        resp.setStatusCode(200);
        return resp;
    }
}