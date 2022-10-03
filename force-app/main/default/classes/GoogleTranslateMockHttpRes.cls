/*
    Author      :   Yogesh Mahajan 
    Class Name  :   GoogleTranslateMockHttpRes
    Description :   It is used as a Mock Http Response for Google Translate
    Date        :   02/20/2019
*/
@isTest
global class GoogleTranslateMockHttpRes implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {      
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"data": {"Translations": [{"translatedText": "test"}]}}');
        res.setStatusCode(200);
        return res;
    }
}