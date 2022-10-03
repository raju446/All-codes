/*
    Author      : Kim Noceda
    Date        : 20-Mar-2017
    Description : Custom code to clar value of Establishemnt card on Entity.
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_RemoveEstablishmentCardEntityCls implements HexaBPM.iCustomCodeExecutable { 
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.HexaBPM__SR__c !=null && step.HexaBPM__SR__r.HexaBPM__Customer__c !=null){
            List<Account> objAcct = [SELECT Id, Establishment_Card__c FROM Account WHERE Id = :step.HexaBPM__SR__r.HexaBPM__Customer__c LIMIT 1];
            
            if(!objAcct.isEmpty()){
                objAcct[0].Establishment_Card__c = null;
                try{
                    update objAcct[0];
                } catch(Exception e){
                    strResult = e.getMessage();
                }
            }
        }
        return strResult;
    }
}