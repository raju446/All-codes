/*********************************************
Author : Azmath
Description : This class will check if there are 
                any active work permits.
**********************************************/
global without sharing class CC_CheckIfWorkPermitExists implements HexaBPM.iCustomCodeExecutable 
{
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step)
    {
        string strResult = 'False';
        
        if(step.HexaBPM__SR__c != null)
        {
            list<string> docTypes = new list<string>{'Employee Work Permit(UAE/GCC National)','Temporary Employee Work Permit','Employee Work Permit'};
            list<Document_Details__c> docDetails = [SELECT Id FROM Document_Details__c WHERE Document_Type__c IN:docTypes 
                                                    AND Document_Status__c='Active' 
                                                    AND Account__c=:step.HexaBPM__SR__r.HexaBPM__Customer__c 
                                                    AND Contact__c = :step.HexaBPM__SR__r.HexaBPM__Contact__c LIMIT 1];
            if(!docDetails.isEmpty())
                strResult =  'True';
        }
        return strResult;
    }
}