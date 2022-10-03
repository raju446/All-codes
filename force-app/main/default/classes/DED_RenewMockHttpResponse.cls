@isTest
global class DED_RenewMockHttpResponse implements HttpCalloutMock
{
    global HttpResponse respond(HttpRequest req)
    {
    	string respb = '{"UD_Output":{"renewBLFZEDResult":{"CBLSSubmissionID":"CBLS9942518","FCRNumber":"11431981","message":{"CBLSResponseMessage":[{"MessageCode":1001.0,"MessageTextAR":"تم بنجاح","MessageTextEN":"Success","MessageType":1.0},{"MessageCode":1011.0,"MessageTextAR":"تم تجديد الرخصة الإقتصادية","MessageTextEN":"Renewal Successful","MessageType":1.0}]}}}}';
    	HttpResponse resp = new HttpResponse();
	  	resp.setHeader('Content-Type','application/json');
	  	resp.setBody(respb);
	  	resp.setStatusCode(200);
	  	return resp;
    }
}