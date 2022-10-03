@isTest
global class IBANCheckMock implements HttpCalloutMock{
	 global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('http://example.com/example/test', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"P_OP_RETURN_STS":"S"}');
        res.setStatusCode(200);
        return res;
    }
}