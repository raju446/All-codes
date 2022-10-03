/*
    Author      : Kim Noceda
    Date        : 25-Mar-2018
    Description : Custom code to set cancelledNotAllowed checkbox on SR.
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_SetCancelledNotAllowed implements HexaBPM.iCustomCodeExecutable { 
     global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.HexaBPM__SR__c != null){
            HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c(Id=step.HexaBPM__SR__c);
            objSR.is_Cancelled_not_Allowed__c = true;
            try{
                update objSR;
            } catch(Exception e){
                strResult = e.getMEssage();
            }
        }
        
        return strResult;
     }
}