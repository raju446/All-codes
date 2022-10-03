/**
* Author: Azmath
* Desc  : Mock class for createupdate estb. service.
 */
@isTest
global class ICA_MockHttpRespEstbServiceUtil implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req)
    {
        string body='{"O_isSucess":"true","O_Status":"APPROVED","O_AdministrativeRegion":"ABU DHABI","O_ServiceName":"test","O_Number":"111","O_Date":"2021-06-24T15:35:31","O_ReceiptNumber":"111","O_PaidAmount":"54.55","O_statusId":"6.0"}';
        
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type','application/json');
        resp.setBody(body);
        resp.setStatusCode(200);
        return resp;
    }
}