@isTest
global class InvoiceMockCallout implements HttpCalloutMock {
	 // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        //res.setHeader('Content-Type', 'application/json');
        res.setBody('{"P_OP_LINE_ITEM_DETAILS":[{"X6_ITEM_REF":"test","X3_TAX_AMOUNT":0,"X2_ITEM_DESC":"FINANCIAL SERVICES","X9_LINE_NO":1,"X5_ITEM_SFID":"a2O25000001aAJnEAM","X8_INV_DISCOUNT_TAX_AMT":null,"X7_INV_DISCOUNT_AMT":null,"X4_AMOUNT":100}],"P_OP_RETURN_STS":"S","P_OP_RETURN_MSG":"Invoice Created: 980","P_OP_INV_NUM":"980","P_OP_ORG_ID":"103","P_OP_CONVERTED_AMT":"100","P_OP_CONVERTED_TAXAMT":"0","P_OP_CONVERTED_DISCOUNT":"0","P_OP_GL_DATE":"10-5-2020","P_OP_SFID":"a0Z2500000cqlvhEAA","P_OP_CUST_ID":"903078","P_OP_AMT_INV_BAL":"100","P_OP_CONV_DISCOUNT_TAX_AMOUNT":"0","P_OP_INV_AMOUNT":"100","P_OP_TAX_AMOUNT":"0","P_OP_DISCOUNT_AMOUNT":"0","P_OP_DISCOUNT_TAX_AMOUNT":"0","P_OP_CONV_AMT_INV_BAL":"100","P_OP_APPL_RECEIPT_NO":"1","P_OP_AMT_UNAPPLIED":"0","P_OP_CONV_AMT_APPLIED":"0","P_OP_CONV_AMT_UNAPPLIED":"0","P_OP_AMT_APPLIED":"0"}');
        res.setStatusCode(200);
        return res;
    }

}