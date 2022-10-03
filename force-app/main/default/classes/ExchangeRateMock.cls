@isTest
global class ExchangeRateMock implements HttpCalloutMock{
	 global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('http://example.com/example/test', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        system.debug(req.getBody());
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
         if(req.getBody().contains('Error')){
             res.setBody('');
         } else {
             res.setBody('{"P_OP_STS":"S","P_OP_RATES":[{"X6_CONVERSION_RATE":0.272294078,"X2_FROM_CURRENCY":"AED","X5_CONV_TYPE":"Corporate","X4_CONV_DATE":"01-07-2020","X3_TO_CURRENCY":"USD"},{"X6_CONVERSION_RATE":3.814697266,"X2_FROM_CURRENCY":"AED","X5_CONV_TYPE":"Corporate","X4_CONV_DATE":"01-07-2020","X3_TO_CURRENCY":"ZAR"},{"X6_CONVERSION_RATE":0.262144,"X2_FROM_CURRENCY":"ZAR","X5_CONV_TYPE":"Corporate","X4_CONV_DATE":"01-07-2020","X3_TO_CURRENCY":"AED"},{"X6_CONVERSION_RATE":3.6725,"X2_FROM_CURRENCY":"USD","X5_CONV_TYPE":"Corporate","X4_CONV_DATE":"01-07-2020","X3_TO_CURRENCY":"AED"}]}');
         }
        
        res.setStatusCode(200);
        return res;
    }
}