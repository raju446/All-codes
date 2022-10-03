/*
    Author      : Kim Noceda
    Date        : 27-Mar-2018
    Description : Custom code to validate duplicate SR
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_ValidateDuplicateSR implements HexaBPM.iCustomCodeExecutable { 
     global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        System.debug('@@SR: '+step.HexaBPM__SR__c);
        if(step.HexaBPM__SR__c != null){
            String isAllowed = ApexCodeUtility.SubmissionAllowed(step.HexaBPM__SR__r);
            System.debug('@@ALLOWED: '+isAllowed);
            strResult = isAllowed;
        }
        
        return strResult;
     }
}