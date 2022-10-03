/*
    Author      : Durga Prasad
    Company     : PwC
    Date        : 28-Feb-2018
    Description : Custom code to delete the Refund Line on Rejection of Cancellation Step.
    -------------------------------------------------------------------------------------------
*/
global without sharing class CC_DeleteRefundLineItem implements HexaBPM.iCustomCodeExecutable {
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.Id!=null && step.HexaBPM__SR__c!=null){
            list<HexaBPM__SR_Price_Item__c> lstRefundLine = [select Id from HexaBPM__SR_Price_Item__c where HexaBPM__ServiceRequest__c=:step.HexaBPM__SR__c and Is_Refund_Line__c=true];
            try{
                if(lstRefundLine!=null && lstRefundLine.size()>0)
                    delete lstRefundLine;
            }catch(Exception e){
                strResult = e.getMessage()+'';
            }
        }
        return strResult;   
    }
}