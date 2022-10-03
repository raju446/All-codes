/*
    Author      : Kim Noceda
    Date        : 3-Dec-2017
    Description : Custom code to populate Rejection reason of SR from Step
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_PopulateSRRejectionReason implements HexaBPM.iCustomCodeExecutable {
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';

        if(step.HexaBPM__SR__c !=null){
            HexaBPM__Service_Request__c objSR = [SELECT Id, HexaBPM__Rejection_Reason__c FROM HexaBPM__Service_Request__c WHERE Id = :step.HexaBPM__SR__c];
            objSR.HexaBPM__Rejection_Reason__c = step.HexaBPM__Rejection_Reason__c;
            
            try{
                update objSR;
            } catch(Exception e){
                strResult = e.getMessage();
            }
        }
        
        return strResult;
    }
}