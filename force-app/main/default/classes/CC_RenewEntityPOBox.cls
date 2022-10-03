/*
    Author      : Kim Noceda
    Date        : 04-Feb-2018
    Description : Custom code to update PO Box Expiry from Renewal.
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_RenewEntityPOBox implements HexaBPM.iCustomCodeExecutable { 
     global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.HexaBPM__SR__c != null && step.HexaBPM__SR__r.PO_Box__c != null){
        
            List<PO_Box__c> poBoxExist = [SELECT Id, Status__c, Start_Date__c, Expiry_Date__c 
                                            FROM PO_Box__c 
                                            WHERE Id = : step.HexaBPM__SR__r.PO_Box__c LIMIT 1];
        
            try{
                if(!poBoxExist.isEmpty()){
                    poBoxExist[0].Start_Date__c = step.HexaBPM__SR__r.Issue_Date__c;
                    poBoxExist[0].Expiry_Date__c = step.HexaBPM__SR__r.Expiry_Date__c;                    
                    poBoxExist[0].Type__c = step.HexaBPM__SR__r.P_O_Box_Type__c;
                    poBoxExist[0].P_O_Box_Selected_Bundle__c = step.HexaBPM__SR__r.P_O_Box_Type__c;
                    poBoxExist[0].Sys_Type__c = step.HexaBPM__SR__r.P_O_Box_Type__c;
                    poBoxExist[0].Account__c = step.HexaBPM__SR__r.HexaBPM__Customer__c;
                    poBoxExist[0].cancelled_date__c = null;
                    poBoxExist[0].Status__c = 'Allocated';
                    update poBoxExist[0];
                }
            } catch(Exception e){
                strResult = e.getMEssage();
            }
        }
        
        return strResult;
     }
}