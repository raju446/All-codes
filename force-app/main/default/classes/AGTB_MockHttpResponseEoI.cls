@isTest
global class AGTB_MockHttpResponseEoI implements HttpCalloutMock
{
    global HttpResponse respond(HttpRequest req)
    {
    	HttpResponse resp = new HttpResponse();
    	resp.setHeader('Content-Type','application/json');
    	resp.setBody('{"Unique_CaseId":"24324324324324","Correlation_Id":"ewryuweruiewouwiureo"}');
    	resp.setStatusCode(200);
    	return resp;
    }
}