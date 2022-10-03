@isTest
global class ReceiptMockCallout implements HttpCalloutMock {
	 // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        //res.setHeader('Content-Type', 'application/json');
        res.setBody('{"P_OP_STATUS":"S","P_OP_SFID":"a1c25000002zUzOAAU","P_OP_ORACLE_RECEIPT_NO":"200200238","P_OP_ERROR_MSG":"Successfully created Receipt in Oracle","P_OP_CUSTOMER_ID":"903078","P_OP_SITE_ID":"103","P_OP_CONVERTED_AMT":"100","P_OP_GL_DATE":"10-05-2020","OP_AMT_UNAPPLIED":"100","P_OP_CONV_AMOUNT":"100","P_OP_CONV_RCPT_AMT_UNAPP":"100","OP_APPL_INV_NO":"1", "OP_AMT_APPLIED": "0","P_OP_CONV_AMT_INV_BAL": "0", "P_OP_CONV_AMT_APPLIED":"0","OP_AMT_INV_BAL":"0"}');
        res.setStatusCode(200);
        return res;
    }

}