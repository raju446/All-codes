/**
* Author: Azmath
* Desc  : Mock class for Print card. service.
 */
@isTest
global class ICA_MockHttpRespPrintCardcopyExcep implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req)
    {
        Blob b = Blob.valueOf('Test Data');
        string baseval = EncodingUtil.base64Encode(b);
        
        string body='{"O_isSucess":"false","O_byteArrayBase64String":"'+baseval +'","O_noDataFound":"false","O_totalRecord":"0"}';
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type','application/json');
        resp.setBody(body);
        resp.setStatusCode(400);
        return resp;
    }
}