/**
* Author: Azmath
* Desc  : Mock class for Initial approval service.
 */
@isTest
global class ICA_MockHttpResponseIAServiceNeg implements HttpCalloutMock
{
    global HttpResponse respond(HttpRequest req)
    {
        string body = '{"UD_Output":{"isSuccess":false,"responseDate":"2021-06-28T17:53:53Z","errors":[{"errorCode":"EnglishEstablishmentName-wrongEnglishField","errorDetail":null,"errorMessage":" EnglishEstablishmentName-wrongEnglishField","errorRefNumber":null}],"data":{"requestFees":{}}}}';
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type','application/json');
        resp.setBody(body);
        resp.setStatusCode(200);
        return resp;
    }
}