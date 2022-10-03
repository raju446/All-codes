/**
* Author: Azmath
* Desc  : Mock class for payment service.
 */
@isTest
global class ICA_MockHttpResponseUploaddocService implements HttpCalloutMock{
   global HttpResponse respond(HttpRequest req)
   {
   		string body='{"UD_Output":{"id":6570630.0,"token":"408BA80ACC93D4A8B83D0C351F1A525B94754"}}';
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type','application/json');
        resp.setBody(body);
        resp.setStatusCode(200);
        return resp;
   }
}