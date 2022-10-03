@isTest
global  class DED_CancelMockHttpResponse implements HttpCalloutMock
{
    global HttpResponse respond(HttpRequest req)
    {
    	string respb = '{"UD_Output":{"cancelBLFZEDResult":{"CBLSSubmissionID":"CBLS9942519","FCRNumber":"11431981","message":{"CBLSResponseMessage":[{"MessageCode":1001.0,"MessageTextAR":"تم بنجاح","MessageTextEN":"Success","MessageType":1.0},{"MessageCode":1005.0,"MessageTextAR":"تم الالغاء","MessageTextEN":"Cancellation Complete","MessageType":1.0}]}}}}';
    	HttpResponse resp = new HttpResponse();
	  	resp.setHeader('Content-Type','application/json');
	  	resp.setBody(respb);
	  	resp.setStatusCode(200);
	  	return resp;
    }
}