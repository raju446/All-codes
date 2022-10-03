/**
* Author: Azmath
* Desc  : Mock class for createupdate estb. service.
 */
@isTest
global class ICA_MockHttpRespCreateUpdEstbServiceErr implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req)
    {
        string body='{"UD_Output":{"isSuccess":false,"errors":[{"errorMessage":"ArabicEstablishmentName-wrongArabicField"}],"data":{"requestFees":{}}}}';
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type','application/json');
        resp.setBody(body);
        resp.setStatusCode(400);
        return resp;
    }
}