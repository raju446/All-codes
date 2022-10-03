/**
* Author: Azmath
* Desc  : Mock class for submit incomplete service.
 */
@isTest
global class ICA_MockHttpRespSubmitIncompErrService implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req)
    {
        string body='{"O_isSucess":"false","O_requestNumber":"0101036911622021300867541"}';
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type','application/json');
        resp.setBody(body);
        resp.setStatusCode(400);
        return resp;
    }
}