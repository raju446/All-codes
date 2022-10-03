@isTest
global class WS_BalaneCheckMock implements HttpCalloutMock {
	global HTTPResponse respond(HTTPRequest req) {
        WS_BalanceCheck.BalanceCurrency bc1 = new WS_BalanceCheck.BalanceCurrency();
        bc1.X_CONVERTED_AMOUNT = '1';
        bc1.X_ORIGINAL_AMOUNT = '1';
        bc1.X_CURRENCY = 'USD';
        WS_BalanceCheck.BalanceCurrency bc2 = new WS_BalanceCheck.BalanceCurrency();
        bc2.X_CONVERTED_AMOUNT = '1';
        bc2.X_ORIGINAL_AMOUNT = '1';
        bc2.X_CURRENCY = 'AED';
        WS_BalanceCheck.balanceResponse br = new WS_BalanceCheck.balanceResponse();
        br.P_OP_STATUS = 'S';
        br.P_OP_ERROR_MSG = 'MSG';
        br.P_OP_ORG_ID = '101';
        br.P_OP_CUST_BAL_AMT = '1';
        br.P_OP_CURRENCY_TBL_ITEM = new List<WS_BalanceCheck.BalanceCurrency>();
        br.P_OP_CURRENCY_TBL_ITEM.add(bc1);
        br.P_OP_CURRENCY_TBL_ITEM.add(bc2);
        String s = JSON.serialize(br);
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json'); 
        res.setBody(s);
        res.setStatusCode(200);
        return res;
    }
}