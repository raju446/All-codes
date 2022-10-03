public without sharing class WS_ERP_CreateGuestCustomerHelper{
    @Future(callout=true)
    public static void SendEntityToOracle(Id EntityId){
         if(EntityId!=null){
            string AccountId;
            string AccountName;
            string VAT_Reg_Number;
            Account objAcc = new Account(Id=EntityId);
            for(Account acc:[Select Id,Name,Company_Name__c,Tax_Registration_Number__c from Account where Id=:EntityId]){
                AccountId = acc.Id;
                AccountName = acc.Name;
                VAT_Reg_Number = acc.Tax_Registration_Number__c;
            }
            WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERP_Service objReqWrap = new WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERP_Service();
            WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERPResponse_element objRespWrap = new WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERPResponse_element();
            
            WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERPHeader_element objHeaderElement = new WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERPHeader_element();
            
            WS_ERP_CreateGuestCustomer.GuestCustomerResponseType objRespType = new WS_ERP_CreateGuestCustomer.GuestCustomerResponseType();
            objHeaderElement.ObjectId = objRespType;
            
            objReqWrap.header = objHeaderElement;
            objRespWrap = objReqWrap.CreateGuestCustomer_ERP(AccountId,AccountName,VAT_Reg_Number);
            system.debug('objRespWrap=====>'+objRespWrap);
            system.debug('Party Id=====>'+objRespWrap.P_OP_PARTY_ID);
            system.debug('Status=====>'+objRespWrap.P_OP_STATUS);
            system.debug('SFID=====>'+objRespWrap.P_OP_AccountId);
            system.debug('Message=====>'+objRespWrap.P_OP_Message);
            
            if(objRespWrap.P_OP_PARTY_ID!=null){
                objAcc.Oracle_Party_Id__c = objRespWrap.P_OP_PARTY_ID;
                objAcc.Oracle_Status__c = objRespWrap.P_OP_STATUS;
                objAcc.Oracle_Response_Message__c = objRespWrap.P_OP_Message;
            }else{
                objAcc.Oracle_Response_Message__c = objRespWrap.P_OP_Message;
                objAcc.Oracle_Status__c = objRespWrap.P_OP_STATUS;
            }
            try{
                update objAcc;
            }catch(Exception e){

            }
        }
    }
}