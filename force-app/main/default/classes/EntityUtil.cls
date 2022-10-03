/*
    Author      : Yogesh Mahajan    
    Date        : 08-Jan-2020
    Description : Entity Utility Class to push the entity to Oracle
    ------------------------------------------------------------------
*/ 
public without sharing class EntityUtil {
     /*
        Method Name     :   PushEntityToOracle
        Description     :   Http Callout to Informatica Cloud to create Entity in Oracle
        Input Params    :   Entity Record Id
    */
    public static void PushEntityToOracle(string entityId, Boolean isPageMSGRequired){
        string sitdIddetails = '';
        if(entityId!=null && entityId!=''){
            try{
                entityWrapper objEntityWrapper = new entityWrapper();
                Account objAcc = new Account(Id=entityId);
                boolean hasPartyId = true;
                for(Account acc:[Select Id,Name,Company_Name__c,Tax_Registration_Number__c, Oracle_Site_Id__c, Source_System_Id__c, Source_System_Name__c, BillingCountry, BillingStreet, BillingCity, BillingState, BillingPostalCode,New_Oracle_Party_Id__c, (select Building_Name__c, Country__c, Floor__c, Emirates__c, County__c, Office_Number__c, State__c, Street_Name_of_Cluster_on_the_Island__c from Addresses__r where Type__c = 'Physical')  from Account where Id=:entityId and Oracle_Party_Id__c=null and From_Data_Migration__c = false]){ 
                    system.debug(acc.Addresses__r);
                    string accountname = acc.Name;
                  /* if(acc.Guest_Auto_Number__c != null){
                   		accountname = accountname + '-'+acc.Guest_Auto_Number__c;
                   } */
                    hasPartyId = false;
                    objEntityWrapper.P_IN_SFID = acc.Id;
                    objEntityWrapper.P_IN_CustomerName = accountname;
                    objEntityWrapper.P_IN_VAT_REG_NO = acc.Tax_Registration_Number__c;
                    objEntityWrapper.P_IN_ORG_ID = acc.Oracle_Site_Id__c;
                    objEntityWrapper.P_IN_SOURCE_SYS_ID = acc.Source_System_Name__c;
                    if(acc.Addresses__r <> null && acc.Addresses__r.size() > 0) {
                        objEntityWrapper.P_IN_COUNTRY = acc.Addresses__r[0].Country__c == '' || acc.Addresses__r[0].Country__c == null || acc.Addresses__r[0].Country__c.length() != 3? 'ARE' : acc.Addresses__r[0].Country__c; //'United Arab Emirates'
                        
                        string addressLine = 'Abu Dhabi, United Arab Emirates';
                        string addressLine2 = '';
                        string addressLine3 = '';
                        if(acc.Addresses__r[0].Floor__c <> '' && acc.Addresses__r[0].Floor__c <> null && acc.Addresses__r[0].Building_Name__c <> '' && acc.Addresses__r[0].Building_Name__c <> null &&
                           acc.Addresses__r[0].Street_Name_of_Cluster_on_the_Island__c <> '' && acc.Addresses__r[0].Street_Name_of_Cluster_on_the_Island__c <> null){
                            addressLine = acc.Addresses__r[0].Floor__c;// +' '+ acc.Addresses__r[0].Building_Name__c + ' '+acc.Addresses__r[0].Street_Name_of_Cluster_on_the_Island__c;
                            addressLine2 = acc.Addresses__r[0].Building_Name__c;
                            addressLine3 = acc.Addresses__r[0].Street_Name_of_Cluster_on_the_Island__c;
                            addressLine = addressLine.replaceAll('"', '');
                            addressLine2 = addressLine2.replaceAll('"', '');
                            addressLine3 = addressLine3.replaceAll('"', '');
                        }
                        objEntityWrapper.P_IN_ADDRESS_LINE1 = addressLine;
                        objEntityWrapper.P_IN_ADDRESS_LINE2 = '';
                        objEntityWrapper.P_IN_ADDRESS_LINE3 = '';
                        objEntityWrapper.P_IN_ADDRESS_LINE4 = '';
                        objEntityWrapper.P_IN_CITY = acc.Addresses__r[0].Emirates__c;
                        objEntityWrapper.P_IN_COUNTY = acc.Addresses__r[0].County__c;
                        objEntityWrapper.P_IN_STATE = acc.Addresses__r[0].State__c;
                        objEntityWrapper.P_IN_PROVINCE = acc.Addresses__r[0].State__c;
                       // objEntityWrapper.P_IN_POSTAL_CODE = acc.Zip_Postal_Code_PO_Box__c;    
                    } else {
                        objEntityWrapper.P_IN_COUNTRY = 'ARE'; // 'United Arab Emirates'
                        objEntityWrapper.P_IN_ADDRESS_LINE1 = acc.BillingStreet == null || acc.BillingStreet == '' ? 'Abu Dhabi, United Arab Emirates' : acc.BillingStreet;
                        objEntityWrapper.P_IN_ADDRESS_LINE2 = '';
                        objEntityWrapper.P_IN_ADDRESS_LINE3 = '';
                        objEntityWrapper.P_IN_ADDRESS_LINE4 = '';
                        objEntityWrapper.P_IN_CITY = acc.BillingCity;
                        objEntityWrapper.P_IN_COUNTY ='';
                        objEntityWrapper.P_IN_STATE = acc.BillingState;
                        objEntityWrapper.P_IN_PROVINCE = acc.BillingState;
                        objEntityWrapper.P_IN_POSTAL_CODE = acc.BillingPostalCode;    
                    }
                    
                    sitdIddetails = acc.Oracle_Site_Id__c +'-'+acc.Source_System_Name__c;
                }//end for
                
                //check
                if(!hasPartyId){
	                String sInputValue = JSON.serialize(objEntityWrapper);
	                system.debug('--->'+sInputValue);
	                // get endpoint details
	                List<ERP_Endpoint_Details__mdt> listERPEndpointDetails = new List<ERP_Endpoint_Details__mdt>();
	                listERPEndpointDetails = [SELECT ID,Endpoint_URL__c, Password__c, Username__c,HTTP_Method__c  FROM ERP_Endpoint_Details__mdt WHERE Is_Active__c = true AND DeveloperName =: 'Entity_Creation' LIMIT 10];
	                System.debug(listERPEndpointDetails);
	                if(listERPEndpointDetails <> null && listERPEndpointDetails.size() > 0 ){
	                    HTTPResponse objHTTPResponse = new HTTPResponse();
	                    objHTTPResponse = HTTPRestUtil.callWebservice(listERPEndpointDetails[0].Endpoint_URL__c, listERPEndpointDetails[0].HTTP_Method__c, sInputValue);
	                    
	                    system.debug('=response=='+objHTTPResponse);
	                    EntityWrapperResponse objentityWrapperResponse = new EntityWrapperResponse();
	                    objentityWrapperResponse = (EntityWrapperResponse)JSON.deserialize(objHTTPResponse.getBody(), EntityWrapperResponse.class);
	                   
                        
                        //save Payload on fail for reference purpose
                        ApexCodeUtility.savePayload(listERPEndpointDetails[0].Endpoint_URL__c,sInputValue,entityId,objHTTPResponse.getBody());
                        
	                    system.debug('objHTTPResponse=====>'+objentityWrapperResponse);
	                    system.debug('Party Id=====>'+objentityWrapperResponse.P_OP_PARTY_ID);
	                    system.debug('Status=====>'+objentityWrapperResponse.P_OP_STATUS);
	                    system.debug('SFID=====>'+objentityWrapperResponse.P_OP_SFID);
	                    system.debug('Message=====>'+objentityWrapperResponse.P_OP_Message);
	                    
	                    if(objentityWrapperResponse.P_OP_PARTY_ID!=null){
	                        objAcc.Oracle_Party_Id__c = objentityWrapperResponse.P_OP_PARTY_ID;
	                        objAcc.Oracle_Status__c = objentityWrapperResponse.P_OP_STATUS;
	                        objAcc.Oracle_Response_Message__c = objentityWrapperResponse.P_OP_Message;
	                        objAcc.New_Oracle_Party_Id__c = objentityWrapperResponse.P_OP_PARTY_ID +'-'+ sitdIddetails;
	                    }else{
	                        objAcc.Oracle_Response_Message__c = objentityWrapperResponse.P_OP_Message;
	                        objAcc.Oracle_Status__c = objentityWrapperResponse.P_OP_STATUS;
	                    }
	                    
	                    update objAcc; 
	                }
            	}
            }catch(Exception ex){
                //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
                String sMessage = ex.getMessage();
                Log__c objLog = new Log__c();
                if(sMessage .length() > 240) {
                    objLog.Message__c = sMessage.subString(0,240);
                } else {
                    objLog.Message__c = sMessage;
                }//end if
                
                objLog.Line_Number__c = ex.getLineNumber();
                objLog.Stack_Trace__c =  ex.getStackTraceString();
                objLog.Type_Name__c = ex.getTypeName();
                //objLog.User_Email__c = UserInfo.getUserEmail();
                insert objLog;
                if(isPageMSGRequired){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,ex.getMessage()));
                }
            }
    
        }
    }
    
    /*
        Method Name     :   PushEntityToOracle
        Description     :   Http Callout to Informatica Cloud to create Entity in Oracle
        Input Params    :   Entity Record Id
    */
    @Future(callout=true)
    public static void PushEntityToOracle_Future(List<string> listEntityId){
       if(listEntityId <> null && listEntityId.size() > 0){
            try{
                
               List<Account> listAccountToUpdate = new List<Account>();
                entityWrapper objEntityWrapper = new entityWrapper();
                //Account objAcc = new Account(Id=entityId);
                for(Account acc:[Select Id,Source_System__c,Name,Company_Name__c,Tax_Registration_Number__c, Oracle_Site_Id__c, Source_System_Id__c, Source_System_Name__c, BillingCountry, BillingStreet, BillingCity, BillingState, BillingPostalCode,New_Oracle_Party_Id__c, 
                                (select Building_Name__c, Country__c, Floor__c,County__c, Emirates__c, Office_Number__c, State__c, Street_Name_of_Cluster_on_the_Island__c from Addresses__r where Type__c = 'Physical')  from Account where Id IN:listEntityId and From_Data_Migration__c = false]){ 
                   system.debug(acc.Addresses__r);
                   string accountname = acc.Name;
                   /*if(acc.Guest_Auto_Number__c != null){
                   	accountname = accountname + '-'+acc.Guest_Auto_Number__c;
                   }*/
                    objEntityWrapper.P_IN_SFID = acc.Id;
                    objEntityWrapper.P_IN_CustomerName = accountname;
                    objEntityWrapper.P_IN_VAT_REG_NO = acc.Tax_Registration_Number__c;
                    objEntityWrapper.P_IN_ORG_ID = acc.Oracle_Site_Id__c;
                    objEntityWrapper.P_IN_SOURCE_SYS_ID = acc.Source_System_Name__c;
                    if(acc.Addresses__r <> null && acc.Addresses__r.size() > 0) {
                        objEntityWrapper.P_IN_COUNTRY = acc.Addresses__r[0].Country__c == '' || acc.Addresses__r[0].Country__c == null || acc.Addresses__r[0].Country__c.length() != 3? 'ARE' : acc.Addresses__r[0].Country__c; //'United Arab Emirates'
                        
                        string addressLine = 'Abu Dhabi, United Arab Emirates';
                        string addressLine2 = '';
                        string addressLine3 = '';
                        if(acc.Addresses__r[0].Floor__c <> '' && acc.Addresses__r[0].Floor__c <> null && acc.Addresses__r[0].Building_Name__c <> '' && acc.Addresses__r[0].Building_Name__c <> null &&
                           acc.Addresses__r[0].Street_Name_of_Cluster_on_the_Island__c <> '' && acc.Addresses__r[0].Street_Name_of_Cluster_on_the_Island__c <> null){
                            addressLine = acc.Addresses__r[0].Floor__c;// +' '+ acc.Addresses__r[0].Building_Name__c + ' '+acc.Addresses__r[0].Street_Name_of_Cluster_on_the_Island__c;
                            addressLine2 = acc.Addresses__r[0].Building_Name__c;
                            addressLine3 = acc.Addresses__r[0].Street_Name_of_Cluster_on_the_Island__c;
                            addressLine = addressLine.replaceAll('"', '');
                            addressLine2 = addressLine2.replaceAll('"', '');
                            addressLine3 = addressLine3.replaceAll('"', '');
                        }
                        objEntityWrapper.P_IN_ADDRESS_LINE1 = addressLine;
                        objEntityWrapper.P_IN_ADDRESS_LINE2 = '';
                        objEntityWrapper.P_IN_ADDRESS_LINE3 = '';
                        objEntityWrapper.P_IN_ADDRESS_LINE4 = '';
                        objEntityWrapper.P_IN_CITY = acc.Addresses__r[0].Emirates__c;
                        objEntityWrapper.P_IN_COUNTY = acc.Addresses__r[0].County__c;
                        objEntityWrapper.P_IN_STATE = acc.Addresses__r[0].State__c;
                        objEntityWrapper.P_IN_PROVINCE = acc.Addresses__r[0].State__c;
                       // objEntityWrapper.P_IN_POSTAL_CODE = acc.Zip_Postal_Code_PO_Box__c;    
                    } else {
                        objEntityWrapper.P_IN_COUNTRY = 'ARE'; // 'United Arab Emirates'
                        objEntityWrapper.P_IN_ADDRESS_LINE1 = acc.BillingStreet == null || acc.BillingStreet == '' ? 'Abu Dhabi, United Arab Emirates' : acc.BillingStreet;
                        objEntityWrapper.P_IN_ADDRESS_LINE2 = '';
                        objEntityWrapper.P_IN_ADDRESS_LINE3 = '';
                        objEntityWrapper.P_IN_ADDRESS_LINE4 = '';
                        objEntityWrapper.P_IN_CITY = acc.BillingCity;
                        objEntityWrapper.P_IN_COUNTY ='';
                        objEntityWrapper.P_IN_STATE = acc.BillingState;
                        objEntityWrapper.P_IN_PROVINCE = acc.BillingState;
                        objEntityWrapper.P_IN_POSTAL_CODE = acc.BillingPostalCode;    
                    }

                    
                    String sInputValue = JSON.serialize(objEntityWrapper);
                    system.debug('--->'+sInputValue);
                    // get endpoint details
                    List<ERP_Endpoint_Details__mdt> listERPEndpointDetails = new List<ERP_Endpoint_Details__mdt>();
                    listERPEndpointDetails = [SELECT ID,Endpoint_URL__c, Password__c, Username__c,HTTP_Method__c  FROM ERP_Endpoint_Details__mdt WHERE Is_Active__c = true AND DeveloperName =: 'Entity_Creation' LIMIT 10];
                    if(listERPEndpointDetails <> null && listERPEndpointDetails.size() > 0 ){
                        HTTPResponse objHTTPResponse = new HTTPResponse();
                        objHTTPResponse = HTTPRestUtil.callWebservice(listERPEndpointDetails[0].Endpoint_URL__c, listERPEndpointDetails[0].HTTP_Method__c, sInputValue);
                        
                        system.debug('=response=='+objHTTPResponse);
                        EntityWrapperResponse objentityWrapperResponse = new EntityWrapperResponse();
                        objentityWrapperResponse = (EntityWrapperResponse)JSON.deserialize(objHTTPResponse.getBody(), EntityWrapperResponse.class);
                        
                        
                        //save Payload on fail for reference purpose
                        ApexCodeUtility.savePayload(listERPEndpointDetails[0].Endpoint_URL__c,sInputValue,acc.Id,objHTTPResponse.getBody());
                        
                        system.debug('objRespWrap=====>'+objentityWrapperResponse);
                        system.debug('Party Id=====>'+objentityWrapperResponse.P_OP_PARTY_ID);
                        system.debug('Status=====>'+objentityWrapperResponse.P_OP_STATUS);
                        system.debug('SFID=====>'+objentityWrapperResponse.P_OP_SFID);
                        system.debug('Message=====>'+objentityWrapperResponse.P_OP_Message);
                        
                        if(objentityWrapperResponse.P_OP_PARTY_ID!=null){
                            acc.Oracle_Party_Id__c = objentityWrapperResponse.P_OP_PARTY_ID;
                            acc.Oracle_Status__c = objentityWrapperResponse.P_OP_STATUS;
                            acc.Oracle_Response_Message__c = objentityWrapperResponse.P_OP_Message;
                            acc.New_Oracle_Party_Id__c = objentityWrapperResponse.P_OP_PARTY_ID +'-'+ acc.Oracle_Site_Id__c+'-'+ acc.Source_System__c;
                        }else{
                            acc.Oracle_Response_Message__c = objentityWrapperResponse.P_OP_Message;
                            acc.Oracle_Status__c = objentityWrapperResponse.P_OP_STATUS;
                        }
                        listAccountToUpdate.add(acc);
                    }//end for
                    
                }
                if(listAccountToUpdate <> null && listAccountToUpdate.size() > 0) {
                    update listAccountToUpdate; 
                }
                 
            }catch(Exception ex){
                //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
                String sMessage = ex.getMessage();
                Log__c objLog = new Log__c();
                if(sMessage .length() > 240) {
                    objLog.Message__c = sMessage.subString(0,240);
                } else {
                    objLog.Message__c = sMessage;
                }//end if
                
                objLog.Line_Number__c = ex.getLineNumber();
                objLog.Stack_Trace__c =  ex.getStackTraceString();
                objLog.Type_Name__c = ex.getTypeName();
                objLog.User_Email__c = UserInfo.getUserEmail();
                insert objLog;
            }
    
        }
    }
    
    
    
    public class entityWrapper {
        public string P_IN_CustomerName;
        public string P_IN_SFID;
        public string P_IN_VAT_REG_NO;
        public string P_IN_ORG_ID;
        public string P_IN_SOURCE_SYS_ID;
        public string P_IN_COUNTRY;
        public string P_IN_ADDRESS_LINE1;
        public string P_IN_ADDRESS_LINE2;
        public string P_IN_ADDRESS_LINE3;
        public string P_IN_ADDRESS_LINE4;
        public string P_IN_CITY;
        public string P_IN_COUNTY;
        public string P_IN_STATE;
        public string P_IN_PROVINCE;
        public string P_IN_POSTAL_CODE;
    }
    
    public class EntityWrapperResponse {
        public string P_OP_PARTY_ID;
        public string P_OP_STATUS;
        public string P_OP_SFID;
        public string P_OP_MESSAGE;
        public string P_OP_ORG_ID;
        public string P_OP_Response;
    }
    
}