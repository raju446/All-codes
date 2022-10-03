/*
    Author      : Azmath
    Date        : 02-Oct-2019
    Description : Custom code to update Document Details of Alcohol Permit.
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_UpdateDocDetail implements HexaBPM.iCustomCodeExecutable { 
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.HexaBPM__SR__c!=null && step.HexaBPM__SR__r.HexaBPM__Customer__c!=null)
        {
            SR = [Select Permit_Number__c,Valid_To__c from HexaBPM__Service_Request__c where id=:step.HexaBPM__SR__c];
            for(Document_Details__c dd : [select id from Document_Details__c where Account__c=:step.HexaBPM__SR__r.HexaBPM__Customer__c and Document_Type__c='Alcohol Permit' and Document_Number__c=: SR.Permit_Number__c limit 1])
            {
                dd.Document_Last_Renewed_Date__c = Date.today();
                dd.Document_Expiry_Date__c = SR.Valid_To__c;
                update dd;
                return strResult;
            }
        }
        return 'Error';
    }
}