/**
* Author: Azmath
* Desc  : Mock class for payment service.
 */
@isTest
global class ICA_MockHttpResponsePaymentService implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req){
        string body='{"UD_Output":"doLSuCcyxTBXO3yl2HeZkpOmpO2B2NdF1YjobDDbCyYz1sgKcKgh33iel0kTTzgPYOHtU3\\/R16nvrKJhSXwDDD4PTt0eg8hsDAUL722m7MfcZomEK9AxBypF2R4xQzTLq7vC1+Djzb3RPpAjbhzSBB\\/aZ8kxF+UbxDteik1t\\/nA6lv0oaREZkpYGOrcsU7THBgomC4\\/QqgkS+wCjC5YEBL\\/qd+4WA+qj4jlk9TBz622MDY6ZvTvyDD8KcLumhCbQXnDum2GjGlLWWZ2vTKAgq618rW1SOttGq8qz0biHTS1m\\/AlHPdKiOcjBLtte9I2uXumZ\\/rKcqKmq5Jy0N0RZhwfDqZ8VDrOyDyY0E+h34E4OGjSqhWOnvdiLQ4HB3FehfXGMEZblXke7XpshOUDOBA=="}';	 	 
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type','application/json');
        resp.setBody(body);
        resp.setStatusCode(200);
        return resp;
    }
}