@isTest
global class WS_ERP_CreateGuestCustomerMockTest implements WebServiceMock {
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
        
        WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERPResponse_element responseElement = new WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERPResponse_element();
        responseElement.P_OP_AccountId = '123758135';
        responseElement.P_OP_PARTY_ID = '00000001';
        responseElement.P_OP_Status = 'S';
        responseElement.P_OP_Message = 'test';
        response.put('response_x', responseElement);
   }
}