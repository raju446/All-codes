@isTest
global class WS_ERP_CreateReceiptMockTest implements WebServiceMock {
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
        
        WS_ERP_CreateReceipt.CreateReceipt_ERPResponse_element responseElement = new WS_ERP_CreateReceipt.CreateReceipt_ERPResponse_element();
        responseElement.P_OP_STATUS = 'E';
        responseElement.P_OP_SFID = '00000001';
        responseElement.P_OP_ORACLE_RECEIPT_NO = '8615424';
        responseElement.P_OP_ERROR_MSG = 'Test';
        response.put('response_x', responseElement);
   }
}