@isTest
global class CreditMemoMockCallout implements HttpCalloutMock {
	 // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        //res.setHeader('Content-Type', 'application/json');
        res.setBody('{"P_OP_RETURN_MSG":"Credit Memo Successfully Created, CM Number: 982, ,  CM Successfully applied to Invoice: 981 ","P_OP_RETURN_STS":"S","P_OP_AMT_APPLIED":"10","P_OP_APPL_INV_NO":"981","P_OP_GL_DATE":"10-5-2020","P_OP_TAX_AMOUNT":"0","P_OP_INV_AMOUNT":"-10","P_OP_ORG_ID":"103","P_OP_CUST_ID":"903078","P_OP_CM_NUM":"982","P_OP_SFID":"a0Z2500000cqmneEAA","P_OP_LINE_TBL":[{"X9_ITEM_REF":"test","X6_TAX_AMOUNT":0,"X5_ITEM_DESC":"FINANCIAL SERVICES","X12_LINE_NO":1,"X8_ITEM_SFID":"a2O25000001aALeEAM","X7_AMOUNT":-10}],"P_AMT_INV_BAL":"90","P_CONV_INV_AMOUNT":"-10","P_CONV_AMT_APPLIED":"10","P_CONV_AMT_INV_BAL":"90","P_AMT_CM_INV_BAL":"0","P_CONV_AMT_CM_INV_BAL":"0"}');
        res.setStatusCode(200);
        return res;
    }
}