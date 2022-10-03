@isTest
global class JEsStatusHttpCalloutMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"RequestId": "0000000","InstanceId": "0000000","Status": "Success"}');
        response.setStatusCode(200);
        return response; 
    }
}