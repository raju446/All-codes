/*
    Author      : Kim Noceda
    Date        : 27-Mar-2018
    Description : Custom code to validate duplicate SR for Visa Services
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_ValidateDuplicateVisaSR implements HexaBPM.iCustomCodeExecutable { 
     global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.HexaBPM__SR__c != null){
            if(step.HexaBPM__SR__r.Passport_Number__c != null && step.HexaBPM__SR__r.Passport_Number__c != ''){
                List<Contact> objCon = [SELECT Id FROM COntact WHERE Passport_Number__c = :step.HexaBPM__SR__r.Passport_Number__c];
                if(objCon.size() > 0){
                    strResult = 'You are not allowed to submit this request. Applicant is already existing in the system.';
                }
            }
        }
        
        return strResult;
     }
}