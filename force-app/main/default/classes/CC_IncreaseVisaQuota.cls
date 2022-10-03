/*
    Author      : Kim Noceda
    Date        : 26-Nov-2017
    Description : Custom code to increase visa quota for permanent work permits - cancellation.
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_IncreaseVisaQuota implements HexaBPM.iCustomCodeExecutable { 
     global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.HexaBPM__SR__r.HexaBPM__Customer__c != null){
            List<Account> acct = [SELECT Id, Total_Visas_Allowed__c, Total_Visas_Used__c, Visas_Available__c FROM Account WHERE Id = :step.HexaBPM__SR__r.HexaBPM__Customer__c LIMIT 1];
            Decimal totalVisaAllowed = 0;
            if(acct[0].Total_Visas_Allowed__c != null){
                totalVisaAllowed = acct[0].Total_Visas_Allowed__c;
            }
            Decimal totalVisaUsed = 0;
            if(acct[0].Total_Visas_Used__c != null){
                totalVisaUsed = acct[0].Total_Visas_Used__c;
            }
            
            acct[0].Total_Visas_Used__c = totalVisaUsed + 1;
            acct[0].Visas_Available__c = totalVisaAllowed - acct[0].Total_Visas_Used__c;
            
            try{
                update acct;
            } catch(Exception e){
                strResult = e.getMessage();
            }
        }
        
        return strResult;
     }
}