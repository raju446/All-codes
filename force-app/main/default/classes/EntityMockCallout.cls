@isTest
global class EntityMockCallout implements HttpCalloutMock {
	 // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        //res.setHeader('Content-Type', 'application/json');
        res.setBody('{"P_OP_ORG_ID":"103","P_OP_PARTY_ID":"903078","P_OP_SFID":"0012500001LsifMAAR","P_OP_STATUS":"S"}');
        res.setStatusCode(200);
        return res;
    }
}