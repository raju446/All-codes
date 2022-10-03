global without sharing class CC_ICA_VerifyNewDraftNumber implements HexaBPM.iCustomCodeExecutable 
{
     global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) 
     {
        string strResult = 'Success';
        if(step.Id!=null && step.HexaBPM__SR__c!=null)
        {
            list<HexaBPM__Service_Request__c> checkdraftno = [Select New_Draft_Number__c from HexaBPM__Service_Request__c where id=:step.HexaBPM__SR__c and New_Draft_Number__c != null];
            if(checkdraftno.isEmpty()){
                strResult = 'New Draft number is required to resubmit the request.Get New Draft Number and then try.';
                return strResult;
            }
        }
        return null;
     }
}