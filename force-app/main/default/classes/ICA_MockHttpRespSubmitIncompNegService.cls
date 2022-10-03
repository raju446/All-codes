/**
* Author: Azmath
* Desc  : Mock class for submit incomplete service.
 */
@isTest
global class ICA_MockHttpRespSubmitIncompNegService implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req)
    {
        string body='{"O_isSucess":"false","O_requestNumber":"0101036911622021300867541"}';
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type','application/json');
        resp.setBody(body);
        resp.setStatusCode(200);
        return resp;
    }
}