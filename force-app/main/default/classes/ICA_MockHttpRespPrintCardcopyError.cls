/**
* Author: Azmath
* Desc  : Mock class for Print card. service.
 */
@isTest
global class ICA_MockHttpRespPrintCardcopyError implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req)
    {
        Blob b = Blob.valueOf('Test Data');
        string baseval = EncodingUtil.base64Encode(b);
        
        string body='{"O_isSucess":"false"}';
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type','application/json');
        resp.setBody(body);
        resp.setStatusCode(200);
        return resp;
    }
}