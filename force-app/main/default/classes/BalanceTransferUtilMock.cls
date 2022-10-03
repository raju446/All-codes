@isTest
global class BalanceTransferUtilMock implements HttpCalloutMock{
	 global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('http://example.com/example/test', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"P_OP_STATUS":"S","P_OP_RCV_ORA_CONVERTED_AMT":"10","P_OP_RCV_ORA_AMT":"2"}');
        res.setStatusCode(200);
        return res;
    }
}