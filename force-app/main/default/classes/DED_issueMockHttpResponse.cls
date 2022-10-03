@isTest
global class DED_issueMockHttpResponse implements HttpCalloutMock
{
	global HttpResponse respond(HttpRequest req)
    {
    	string respb = '{"UD_Output":{"issueBLFZEDResult":{"CBLSSubmissionID":"CBLS9942500","FCRNumber":"true","message":{"CBLSResponseMessage":[{"MessageCode":3139.0,"MessageTextAR":"test","MessageTextEN":"Licese added to CBLS","MessageType":3.0},{"MessageCode":9999.0,"MessageTextAR":"test","MessageTextEN":"Success","MessageType":3.0}]}}}}';
    	HttpResponse resp = new HttpResponse();
	  	resp.setHeader('Content-Type','application/json');
	  	resp.setBody(respb);
	  	resp.setStatusCode(200);
	  	return resp;
    }
    
}