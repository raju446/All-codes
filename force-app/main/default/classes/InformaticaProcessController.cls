/**********************************************************************
    Author      :   Durga Prasad
    Company     :   PwC
    Description :   Controller to create the Guest Customer in Oracle
 --------------------------------------------------------------------------------------
    * @Change History
    * Author            Date            Description
    * Yogesh Mahajan	26jan2020		Added new webservice call
***********************************************************************/
public class InformaticaProcessController{
    
    public string AccountId{get;set;}
    public string AccountName{get;set;}
    public Account objAcc{get;set;}
    public string TRNNumber{get;set;}
    public boolean hasOracleId{get;set;}
    public InformaticaProcessController(ApexPages.StandardController controller) {
        objAcc = new Account();
        hasOracleId = false;
        if(ApexPages.currentPage().getParameters().get('Id')!=null){
            for(Account acc:[Select Id,Name,Company_Name__c,Tax_Registration_Number__c,Oracle_Party_Id__c,Oracle_Status__c from Account where Id=:ApexPages.currentPage().getParameters().get('Id')]){
                AccountId = acc.Id;
                AccountName = acc.Name;
                TRNNumber = acc.Tax_Registration_Number__c;
                if(acc.Oracle_Party_Id__c!=null){
                    hasOracleId = true;
                    objAcc.Oracle_Party_Id__c = acc.Oracle_Party_Id__c;
                    objAcc.Oracle_Status__c = acc.Oracle_Status__c;
                }
            }
        }
    }
    public void InvokeProcess(){
        if(!hasOracleId && AccountId!=null && AccountName!=null){
            if(System.Label.BM_Use_New_Entity_Oracle_Service == 'Yes'){
                EntityUtil.PushEntityToOracle(AccountId, true);
                List<Account> listAccount = new List<Account>();
                listAccount = [Select Id,Name,Company_Name__c,Tax_Registration_Number__c,Oracle_Party_Id__c,Oracle_Status__c from Account where Id=:AccountId];
                if(listAccount <> null && listAccount.size() > 0) {
                   objAcc =  listAccount[0];
                }
            } else {
                //PRODUCTION Webservice
               /* WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERP_Service objReqWrap = new WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERP_Service ();
                WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERPResponse_element objRespWrap = new WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERPResponse_element();
                WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERPHeader_element objHeaderElement = new WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERPHeader_element();
                WS_ERP_CreateGuestCustomer.GuestCustomerResponseType objRespType = new WS_ERP_CreateGuestCustomer.GuestCustomerResponseType();
                
                objHeaderElement.ObjectId = objRespType;
                
                objReqWrap.header = objHeaderElement;
                //objRespWrap = objReqWrap.CreateGuestCustomerUAT(AccountId,AccountName,TRNNumber);
                objRespWrap = objReqWrap.CreateGuestCustomer_ERP(AccountId,AccountName,TRNNumber);
                system.debug('objRespWrap=====>'+objRespWrap);
                system.debug('Party Id=====>'+objRespWrap.P_OP_PARTY_ID);
                system.debug('Status=====>'+objRespWrap.P_OP_STATUS);
                system.debug('SFID=====>'+objRespWrap.P_OP_AccountId);
                
                if(objRespWrap.P_OP_AccountId!=null){
                    objAcc.Id = objRespWrap.P_OP_AccountId;
                    if(objRespWrap.P_OP_PARTY_ID!=null)
                        objAcc.Oracle_Party_Id__c = objRespWrap.P_OP_PARTY_ID;
                    objAcc.Oracle_Status__c = objRespWrap.P_OP_Status;
                    try{
                        update objAcc;
                    }catch(Exception e){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
                    }
                }else{
                    objAcc.Oracle_Status__c = objRespWrap.P_OP_STATUS;
                } */
             }
            
  /*
            //UAT Webservice
            // comments by yogesh on 26jan2020
            WS_Inf_CreateGuestEntity.CreateGuestCustomerUAT_Service  objReqWrap = new WS_Inf_CreateGuestEntity.CreateGuestCustomerUAT_Service ();
            WS_Inf_CreateGuestEntity.CreateGuestCustomerUATResponse_element objRespWrap = new WS_Inf_CreateGuestEntity.CreateGuestCustomerUATResponse_element();
            WS_Inf_CreateGuestEntity.CreateGuestCustomerUATHeader_element objHeaderElement = new WS_Inf_CreateGuestEntity.CreateGuestCustomerUATHeader_element();
            WS_Inf_CreateGuestEntity.UAT_GuestCustomerResponseType objRespType = new WS_Inf_CreateGuestEntity.UAT_GuestCustomerResponseType();
          */
            //PRODUCTION Webservice
            /*WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERP_Service objReqWrap = new WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERP_Service ();
            WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERPResponse_element objRespWrap = new WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERPResponse_element();
            WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERPHeader_element objHeaderElement = new WS_ERP_CreateGuestCustomer.CreateGuestCustomer_ERPHeader_element();
            WS_ERP_CreateGuestCustomer.GuestCustomerResponseType objRespType = new WS_ERP_CreateGuestCustomer.GuestCustomerResponseType();*/
            // Call new Web service
            
            
            /* comments by yogesh on 26jan2020
            objHeaderElement.ObjectId = objRespType;
            
            objReqWrap.header = objHeaderElement;
            try{
            objRespWrap = objReqWrap.CreateGuestCustomerUAT(AccountId,AccountName,TRNNumber);
            //objRespWrap = objReqWrap.CreateGuestCustomer_ERP(AccountId,AccountName,TRNNumber);
            system.debug('objRespWrap=====>'+objRespWrap);
            system.debug('Party Id=====>'+objRespWrap.P_OP_PARTY_ID);
            system.debug('Status=====>'+objRespWrap.P_OP_STATUS);
            system.debug('SFID=====>'+objRespWrap.P_OP_AccountId);
            
            if(objRespWrap.P_OP_AccountId!=null){
                objAcc.Id = objRespWrap.P_OP_AccountId;
                if(objRespWrap.P_OP_PARTY_ID!=null)
                    objAcc.Oracle_Party_Id__c = objRespWrap.P_OP_PARTY_ID;
                objAcc.Oracle_Status__c = objRespWrap.P_OP_Status;
                //try{
                    update objAcc;
                //}catch(Exception e){
                    //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
                //}
            }else{
                objAcc.Oracle_Status__c = objRespWrap.P_OP_STATUS;
            }
            }
            catch(exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
            }
            */
        }

    }
    
    public pagereference ViewAccount(){
        Pagereference pg = new Pagereference('/'+AccountId);
        pg.setRedirect(true);
        return pg;
    }
}