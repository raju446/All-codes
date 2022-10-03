/**
 * @File Name          : BalanceTransferUtil.cls
 * @Description        :  
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 11-24-2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    3/23/2020   Jayanta Karmakar     Initial Version
**/
public class BalanceTransferUtil {
    @future(callout = true)
    public static void pushFundTransferToOracleFuture(List<string> balanceTransferIds){
        for(String eachBTId : balanceTransferIds){
            pushBalaceTransferToOracle(eachBTId);
        }
    } 
    
    public static void updateReceiptAndCreateJournalEntriesFuture(List<String> balanceTransferIds){
        for(String eachBTId : balanceTransferIds){
            updateReceiptAndCreateJournalEntries(eachBTId);
        }
    }
    public static void updateReceiptAndCreateJournalEntries(string balanceTransferId){
        if(!String.isBlank(balanceTransferId)){
            try{
                List<Fund_Transfer__c> listFund_Transfer = new List<Fund_Transfer__c>();
                listFund_Transfer = [select id, Amount__c,From_Receipt__c, Status__c,Description__c,From_Entity__r.Oracle_Site_Id__c,To_Receipt__r.Source_Receipt_Id__c,Reference_Receipt__r.Name,
                Reference_Receipt__r.GL_Date__c,Reference_Receipt__r.Receipt_Date__c, From_Currency__c, To_Currency__c, Scenario__c,To_Receipt__r.Name, To_Entity__c, To_Entity__r.Oracle_Party_Id__c, 
                From_Entity__r.Oracle_Party_Id__c, To_Entity__r.Oracle_Site_Id__c, Reference_Receipt__c, To_Receipt__r.Payment_Method__c,To_Receipt__r.Authorization_Code__c,To_Receipt__r.Payment_Currency__c,To_Receipt__r.Amount__c,
                Reference_Receipt__r.Source_Receipt_Id__c,To_Receipt__r.Receipt_Date__c,To_Receipt__r.GL_Date__c,To_Receipt__r.Transaction_Reference__c,Reference_Receipt__r.Transaction_Reference__c,To_Receipt__r.Conversion_Rate__c,
                Reference_Receipt__r.Payment_Method__c,Reference_Receipt__r.Authorization_Code__c,Reference_Receipt__r.Receipt_Reference__c,Reference_Receipt__r.EFT_Reference_No__c  from Fund_Transfer__c where id = :balanceTransferId limit 1]; 
                Set<Id> referenceReceiptIds = new Set<Id>();
                
                for(Fund_Transfer__c objFund_Transfer : listFund_Transfer){
                    referenceReceiptIds.add(objFund_Transfer.Reference_Receipt__c);
                    objFund_Transfer.Journal_Created__c = true;
                    objFund_Transfer.Status__c = 'Success';
                }
                Map<Id,Receipt__c> referenceReceiptsMap = new Map<Id,Receipt__c>([SELECT Id,Transferred_Amount__c FROM Receipt__c WHERE Id IN : referenceReceiptIds]);
                for(Fund_Transfer__c objFund_Transfer : listFund_Transfer) {
                    Decimal convertedAmount = objFund_Transfer.To_Receipt__r.Payment_Currency__c == 'USD' ? objFund_Transfer.To_Receipt__r.Amount__c * objFund_Transfer.To_Receipt__r.Conversion_Rate__c : objFund_Transfer.To_Receipt__r.Amount__c;
                    referenceReceiptsMap.put(objFund_Transfer.To_Receipt__c, new Receipt__c(Reference_Receipt__c = objFund_Transfer.Reference_Receipt__c,Status__c = 'Success', Converted_Amount__c = convertedAmount.setScale(2),Amount__c=(objFund_Transfer.To_Receipt__r.Amount__c).setScale(2), id = objFund_Transfer.To_Receipt__c, GL_Date__c =Date.Today(), Journal_Created__c = true));
                    if(referenceReceiptsMap.get(objFund_Transfer.Reference_Receipt__c).Transferred_Amount__c == null){referenceReceiptsMap.get(objFund_Transfer.Reference_Receipt__c).Transferred_Amount__c = (objFund_Transfer.Amount__c).setScale(2);
                    } else {
                        referenceReceiptsMap.get(objFund_Transfer.Reference_Receipt__c).Transferred_Amount__c = (objFund_Transfer.Amount__c + referenceReceiptsMap.get(objFund_Transfer.Reference_Receipt__c).Transferred_Amount__c).setScale(2);
                    }
                }
                FundTranferTriggerHandler.runUpdate = false;
                UPDATE listFund_Transfer;
                update referenceReceiptsMap.values();
                BM_JournalEntryEngine.fundTransferJournalEntries(new List<Id>{balanceTransferId});
            }catch(Exception ex){
                system.debug('ex.getMessage()==>>' + ex.getMessage());
                system.debug('ex.getLineNumber()==>>' + ex.getLineNumber());
            }
        }
    }
    
    /*
        Method Name     :   pushBalaceTransferToOracle
        Description     :   Http Callout to Informatica Cloud to create balance transfer in Oracle
        Input Params    :   balance transfer Record Id
    */
    public static String pushBalaceTransferToOracle(string balanceTransferId){
        String resp = '';
        if(balanceTransferId <> null && balanceTransferId <> ''){
            try{
                List<Fund_Transfer__c> listFund_Transfer = new List<Fund_Transfer__c>();
                listFund_Transfer = [select id, Amount__c,From_Receipt__c, Status__c,Description__c,From_Entity__r.Oracle_Site_Id__c,To_Receipt__r.Source_Receipt_Id__c,Reference_Receipt__r.Name,
                Reference_Receipt__r.GL_Date__c,Reference_Receipt__r.Receipt_Date__c, From_Currency__c, To_Currency__c, Scenario__c,To_Receipt__r.Name, To_Entity__c, To_Entity__r.Oracle_Party_Id__c, 
                From_Entity__r.Oracle_Party_Id__c, To_Entity__r.Oracle_Site_Id__c, Reference_Receipt__c, To_Receipt__r.Payment_Method__c,To_Receipt__r.Authorization_Code__c,
                Reference_Receipt__r.Source_Receipt_Id__c,To_Receipt__r.Receipt_Date__c,To_Receipt__r.GL_Date__c,To_Receipt__r.Transaction_Reference__c,Reference_Receipt__r.Transaction_Reference__c,
                Reference_Receipt__r.Payment_Method__c,Reference_Receipt__r.Authorization_Code__c,Reference_Receipt__r.Receipt_Reference__c,Reference_Receipt__r.EFT_Reference_No__c  from Fund_Transfer__c where id = :balanceTransferId limit 1]; 
                Set<Id> referenceReceiptIds = new Set<Id>();
                for(Fund_Transfer__c objFund_Transfer : listFund_Transfer){
                    referenceReceiptIds.add(objFund_Transfer.Reference_Receipt__c);
                }
                system.debug(listFund_Transfer[0]);
                system.debug(listFund_Transfer[0].To_Receipt__r.Source_Receipt_Id__c);
                Map<Id,Receipt__c> referenceReceiptsMap = new Map<Id,Receipt__c>([SELECT Id,Transferred_Amount__c FROM Receipt__c WHERE Id IN : referenceReceiptIds]);
                
                for(Fund_Transfer__c objFund_Transfer : listFund_Transfer) {
                    BalanceTransferWrapper objBalanceTransferWrapper = new BalanceTransferWrapper();
                    objBalanceTransferWrapper.IN_P_PARTY_ID = objFund_Transfer.To_Entity__r.Oracle_Party_Id__c;
                    objBalanceTransferWrapper.IN_P_TRF_ORG_ID = objFund_Transfer.From_Entity__r.Oracle_Site_Id__c;
                    objBalanceTransferWrapper.IN_P_AMOUNT = String.valueOf(objFund_Transfer.Amount__c);
                    
                    String transRef = '';
                    if(objFund_Transfer.Reference_Receipt__r.Payment_Method__c.contains('Card') && objFund_Transfer.Reference_Receipt__r.Authorization_Code__c != null){transRef = objFund_Transfer.Reference_Receipt__r.Authorization_Code__c;
                        if([SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox){Integer randomNumber = Integer.valueof((Math.random() * 10000));transRef = transRef+objFund_Transfer.Reference_Receipt__r.Receipt_Reference__c;}
                    } else if(objFund_Transfer.Reference_Receipt__r.Payment_Method__c == 'Electronic Funds Transfer' && objFund_Transfer.Reference_Receipt__r.EFT_Reference_No__c != null){transRef = objFund_Transfer.Reference_Receipt__r.EFT_Reference_No__c;
                    }else {
                        transRef = objFund_Transfer.Reference_Receipt__r.Transaction_Reference__c;
                    }
                    
                    objBalanceTransferWrapper.IN_P_RECEIPT_NUM = transRef;//objFund_Transfer.Reference_Receipt__r.Source_Receipt_Id__c;
                    objBalanceTransferWrapper.IN_P_SFID = objFund_Transfer.id;
                    objBalanceTransferWrapper.IN_P_DESCRIPTION = objFund_Transfer.Description__c;
                    objBalanceTransferWrapper.IN_P_FRM_CURR = objFund_Transfer.From_Currency__c;
                    objBalanceTransferWrapper.IN_P_TO_CURR = objFund_Transfer.To_Currency__c;
                    objBalanceTransferWrapper.IN_P_SCENARIO = objFund_Transfer.Scenario__c;
                    
                    system.debug('======>'+ objFund_Transfer.To_Receipt__r.Payment_Method__c);
                    String transRef1 = '';
                    if(objFund_Transfer.To_Receipt__r.Payment_Method__c.contains('Card') && objFund_Transfer.To_Receipt__r.Authorization_Code__c != null){transRef1 = objFund_Transfer.To_Receipt__r.Authorization_Code__c;
                        if([SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox){Integer randomNumber = Integer.valueof((Math.random() * 10000));transRef1 = transRef1+objFund_Transfer.To_Receipt__r.Receipt_Reference__c;}
                    } else if(objFund_Transfer.To_Receipt__r.Payment_Method__c == 'Electronic Funds Transfer' && objFund_Transfer.To_Receipt__r.EFT_Reference_No__c != null){transRef1 = objFund_Transfer.To_Receipt__r.EFT_Reference_No__c;
                    }else {
                        transRef1 = objFund_Transfer.To_Receipt__r.Transaction_Reference__c;
                    }
                   // objBalanceTransferWrapper.IN_P_RECEIPT_REF = objFund_Transfer.To_Receipt__r.Source_Receipt_Id__c;
                    objBalanceTransferWrapper.IN_P_RECEIPT_REF = transRef1;//objFund_Transfer.To_Receipt__r.Transaction_Reference__c;
                    objBalanceTransferWrapper.IN_P_RECEIPT_DATE = objFund_Transfer.Reference_Receipt__r.Receipt_Date__c != null ? objFund_Transfer.Reference_Receipt__r.Receipt_Date__c.DAY()+'-'+objFund_Transfer.Reference_Receipt__r.Receipt_Date__c.Month()+'-'+objFund_Transfer.Reference_Receipt__r.Receipt_Date__c.Year() : '';
                    objBalanceTransferWrapper.IN_P_GL_DATE = objFund_Transfer.To_Receipt__r.GL_Date__c != null ? objFund_Transfer.To_Receipt__r.GL_Date__c.DAY()+'-'+objFund_Transfer.To_Receipt__r.GL_Date__c.Month()+'-'+objFund_Transfer.To_Receipt__r.GL_Date__c.Year() : objFund_Transfer.To_Receipt__r.Receipt_Date__c.DAY()+'-'+objFund_Transfer.To_Receipt__r.Receipt_Date__c.Month()+'-'+objFund_Transfer.To_Receipt__r.Receipt_Date__c.Year();
                    objBalanceTransferWrapper.IN_P_RCV_ORG_ID = objFund_Transfer.To_Entity__r.Oracle_Site_Id__c;
                    
                    String sInputValue = JSON.serialize(objBalanceTransferWrapper);
                    system.debug('--->'+sInputValue);
                    HTTPResponse response = new HTTPResponse();
                    // get endpoint details
                    List<ERP_Endpoint_Details__mdt> listERPEndpointDetails = new List<ERP_Endpoint_Details__mdt>();
                    listERPEndpointDetails = [SELECT ID,Endpoint_URL__c, Password__c, Username__c,HTTP_Method__c  FROM ERP_Endpoint_Details__mdt WHERE Is_Active__c = true AND DeveloperName =: 'Balance_Transfer_Creation' LIMIT 10];
                    if(listERPEndpointDetails <> null && listERPEndpointDetails.size() > 0 ) {
                        response = HTTPRestUtil.callWebservice(listERPEndpointDetails[0].Endpoint_URL__c, listERPEndpointDetails[0].HTTP_Method__c,sInputValue);  
                    }
                    system.debug('Response Body---->'+response.getBody());                                                                    
                    BalanceTransferWrapperResponse respObj = (BalanceTransferWrapperResponse)JSON.deserialize(response.getBody() , BalanceTransferWrapperResponse.class);
                    system.debug(respObj);
                    objFund_Transfer.Oracle_Response_Status__c = respObj.P_OP_STATUS;
                    if(respObj.P_OP_STATUS == 'S' ){objFund_Transfer.Status__c = 'Success';objFund_Transfer.Pushed_To_Oracle__c = true;objFund_Transfer.Oracle_Response_Message__c = respObj.P_OP_ERROR_MSG;
                        referenceReceiptsMap.put(objFund_Transfer.To_Receipt__c, new Receipt__c(Reference_Receipt__c = objFund_Transfer.Reference_Receipt__c,Status__c = 'Success',Oracle_Receipt_Id__c=respObj.P_OP_RCV_ORACLE_ID,Pushed_to_Oracle__c=true, Converted_Amount__c = Decimal.valueOf(respObj.P_OP_RCV_ORA_CONVERTED_AMT),Amount__c=Decimal.valueOf(respObj.P_OP_RCV_ORA_AMT), id = objFund_Transfer.To_Receipt__c, GL_Date__c =Date.Today()));
                        //referenceReceiptsMap.put(objFund_Transfer.From_Receipt__c, new Receipt__c(Status__c = 'Transferred', Converted_Amount__c = (Decimal.valueOf(respObj.P_OP_RCV_ORA_CONVERTED_AMT) * -1), id = objFund_Transfer.From_Receipt__c));
                        if(referenceReceiptsMap.get(objFund_Transfer.Reference_Receipt__c).Transferred_Amount__c == null){referenceReceiptsMap.get(objFund_Transfer.Reference_Receipt__c).Transferred_Amount__c = objFund_Transfer.Amount__c;} 
                        else { referenceReceiptsMap.get(objFund_Transfer.Reference_Receipt__c).Transferred_Amount__c = objFund_Transfer.Amount__c + referenceReceiptsMap.get(objFund_Transfer.Reference_Receipt__c).Transferred_Amount__c;}                       
                        //update objReceipt;
                        //referenceReceiptsMap.values();
                        update referenceReceiptsMap.values();resp = 'Success';
                    } else {                       
                        objFund_Transfer.Oracle_Response_Message__c = respObj.P_OP_ERROR_MSG;resp = respObj.P_OP_ERROR_MSG;
                        //referenceReceiptsMap.get(objFund_Transfer.Reference_Receipt__c).Oracle_Response_Message__c = respObj.P_OP_ERROR_MSG;
                    }
                    //save Payload on fail for reference purpose
                    ApexCodeUtility.savePayload(listERPEndpointDetails[0].Endpoint_URL__c,sInputValue,objFund_Transfer.ID,response.getBody());
                    FundTranferTriggerHandler.runUpdate = false;
                    update objFund_Transfer;
                }
                
                
            } catch(Exception ex){
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
                //return ex.getMessage();
                resp = ex.getMessage();
            }
        }
        
        return resp;
    }
    
    public class BalanceTransferWrapper {
        public string IN_P_PARTY_ID;
        public string IN_P_TRF_ORG_ID;
        public string IN_P_AMOUNT;
        public string IN_P_RECEIPT_NUM;
        public string IN_P_SFID;
        public string IN_P_DESCRIPTION;
        public string IN_P_FRM_CURR;
        public string IN_P_TO_CURR;
        public string IN_P_SCENARIO;
        public string IN_P_RECEIPT_REF;
        public string IN_P_RECEIPT_DATE;
        public string IN_P_GL_DATE;
        public string IN_P_RCV_ORG_ID;
    }
    
    public class BalanceTransferWrapperResponse {
        public string P_OP_RCV_ORG_ID;
        public string P_OP_RCV_ORA_RCPT_NUM;
        public string P_OP_RCV_ORA_CONVERTED_AMT;
        public string P_OP_SFID;
        public string P_OP_STATUS;
        public string P_OP_ERROR_MSG;
        public string P_OP_RCV_ORACLE_ID;
        public string P_OP_RCV_ORA_AMT;
    }
}