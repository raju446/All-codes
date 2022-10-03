@isTest
global class AdjustmentMockCallout  implements HttpCalloutMock {
	 // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        //res.setHeader('Content-Type', 'application/json');
        res.setBody('{"P_OP_ADJUSTMENT_NO":"103","P_OP_ERROR_MSG":"Test ","P_OP_STATUS":"S"}');
        res.setStatusCode(200);
        return res;
    }

}