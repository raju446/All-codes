/*
    Author      : Khushboo Agarwal
    Date        : 29-Nov-2017
    Description : Custom code to calculate the Cancel date of Work Permit and copy fields to Document Detail
    ----------------------------------------------------------------------------------------------------------------------------------------
*/
global without sharing class  CC_WorkPermitCancellation implements HexaBPM.iCustomCodeExecutable { 
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.Id!=null && step.HexaBPM__SR__c!=null){
           
            try{
               //update objSR;
               list<Document_Details__c> lstWorkPermit = [select Id,Document_Expiry_Date__c,Document_Last_Renewed_Date__c from Document_Details__c where Account__c=:step.HexaBPM__SR__r.HexaBPM__Customer__c and Contact__c=:step.HexaBPM__SR__r.HexaBPM__Contact__c and Document_Type__c='Temporary Employee Work Permit' and Document_Status__c='Active' limit 1];
               if(lstWorkPermit!=null && lstWorkPermit.size()>0){
                   lstWorkPermit[0].Document_Cancel_Date__c = system.today();
                   update lstWorkPermit;
               }
            }catch(DMLException e){
                strResult = e.getMessage();
            }
        }
        return strResult;
    }
    
}