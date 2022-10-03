/*
    Author      : Kim Noceda
    Date        : 28-Jan-2017
    Description : Custom code to Check if all the participants of the SR has Arabic Names
                   v1.2 - Removed logic for Arabic Passport Number
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_ParticipantsArabicNameValidation implements HexaBPM.iCustomCodeExecutable { 
     global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.HexaBPM__SR__c != null){
            for(Amendment__c objAmm : [SELECT Id, Full_Name_Arabic__c, Passport_Number_Arabic__c FROM Amendment__c WHERE Service_Request__c = :step.HexaBPM__SR__c]){
                if(objAmm.Full_Name_Arabic__c == null || objAmm.Full_Name_Arabic__c == ''){
                    //strResult = 'Please make sure to add the Arabic names of all participants.';
                    strResult = 'Please make sure to populate all the Arabic fields of all participants.';
                }
            }
        }
        
        return strResult;
     }
}