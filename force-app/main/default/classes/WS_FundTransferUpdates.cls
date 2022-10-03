/**
 * @File Name          : WS_FundTransferUpdates.cls
 * @Description        : Webservice class to record responses for Refund status.
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 5/7/2020, 12:03:13 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    3/8/2020   Jayanta Karmakar     Initial Version
**/
global class WS_FundTransferUpdates {
    webservice static ResponseDetails ProcessRequest(ReqestDetails reqDetails){
        try{
            System.debug(reqDetails);
            if(reqDetails.SFID != null && reqDetails.SFID != null){
               // Refund__c refundObj = new Refund__c(Id=reqDetails.SFID);
                Refund__c refundObj = [SELECT id,Credit_Memo__c,Receipt__c,Scenario__c,Amount__c from Refund__c WHERE Id =: reqDetails.SFID];
                if(reqDetails.Ref_Status == 'S' || reqDetails.Payment_Status == 'S'){
                    refundObj.Oracle_Message__c = reqDetails.Ref_Message;
                    if(reqDetails.Ref_Status == 'S'){
                        refundObj.AP_Invoice_No__c = reqDetails.AP_Invoice_No;
                    }
                    if(reqDetails.Payment_Status == 'S'){
                        refundObj.Payment_Number__c = reqDetails.Payment_Number;
                        //refundObj.Status__c = reqDetails.Ref_Status;
                        refundObj.Payment_Status__c = reqDetails.Payment_Status; //refundObj.Scenario__c == 'Receipt and Invoice are generated' ||
                        if(refundObj.Scenario__c == 'Receipt generated but invoice not generated'){
                            update new Receipt__c(Id = refundObj.Receipt__c, Refund_Amount__c = refundObj.Amount__c);
                        } else if(refundObj.Scenario__c == 'Credit Memo'){
                            system.debug('---->'+ refundObj.Credit_Memo__c);
                            Invoice__c cmObj= new Invoice__c();
                            for(Invoice__c inv:[SELECT Id,Invoice_Balance__c FROM Invoice__c WHERE Id =: refundObj.Credit_Memo__c]){
                            	cmObj = inv;
                            }
                            system.debug('---->'+ cmObj.Invoice_Balance__c);
                            system.debug('---->'+ refundObj.Amount__c);
                            cmObj.Invoice_Balance__c = cmObj.Invoice_Balance__c + refundObj.Amount__c;
                            cmObj.Credit_Memo_Refund_Amount__c = refundObj.Amount__c;
                            if(cmObj!=null && cmObj.Id!=null)
                           		update cmObj;
                        }
                    }
                } else {
                    refundObj.Oracle_Message__c = reqDetails.Ref_Message;
                }         
                system.debug('refundObj : '+refundObj);                         
                update refundObj;
                return new ResponseDetails(true, 'Successfully updated the record.');
            } else {
            	/*ResponseDetails responseObj = new ResponseDetails();
            	responseObj.isSuccess = true;
            	responseObj.Messages = 'Successfully updated the record.'; */
                return new ResponseDetails(false, 'Salesforce Id Not Present.');
            }
        }catch(Exception ex){
            System.debug(ex.getMessage());
            System.debug(ex.getLineNumber());
            Log__c objLog = new Log__c(Line_Number__c = ex.getLineNumber(),Stack_Trace__c =  ex.getStackTraceString(),Type_Name__c = ex.getTypeName(),User_Email__c = UserInfo.getUserEmail());
            objLog.Message__c = ex.getMessage().length() > 250 ? ex.getMessage().substring(0,250) : ex.getMessage();
            insert objLog;
            return new ResponseDetails(false, ex.getMessage());
        }
    }  
    
    global class ReqestDetails{
        webservice string SFID; 
        webservice string Ref_Ref;
        webservice string Ref_Status; 
        webservice string Ref_Message; 
        webservice string AP_Invoice_No; 
        webservice string Payment_Status; 
        webservice string Payment_Number; 
    }

    global class ResponseDetails{
        webservice boolean isSuccess;
        webservice string Messages; 
        global ResponseDetails(Boolean isS, String msg){
            isSuccess = isS;
            Messages = msg;
        }
    }
}