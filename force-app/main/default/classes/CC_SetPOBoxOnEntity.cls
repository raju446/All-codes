/*
    Author      : Kim Noceda
    Date        : 14-Nov-2017
    Description : Custom code to assign PO Box to the Entity of the Service request when approved.
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_SetPOBoxOnEntity implements HexaBPM.iCustomCodeExecutable { 
     global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.HexaBPM__SR__c != null){
            List<PO_Box__c> poBoxExist = [SELECT Id, Name, Status__c, Start_Date__c, Expiry_Date__c, Account__c,P_O_Box_Selected_Bundle__c  
                                            FROM PO_Box__c 
                                            WHERE Status__c = 'Available' 
                                            AND Type__c INCLUDES (:step.HexaBPM__SR__r.P_O_Box_Type__c) 
                                            ORDER BY PO_Box_Number__c ASC LIMIT 1];
            //List<Account> srEntity = [SELECT Id, PO_Box__c FROM Account WHERE Id = :step.HexaBPM__SR__r.HexaBPM__Customer__c];
            system.debug('####poBoxExist '+poBoxExist);
            //system.debug('####srEntity '+srEntity);
            try{
                //if(!srEntity.isEmpty()){
                    if(!poBoxExist.isEmpty()){
                        /*srEntity[0].PO_Box__c = poBoxExist[0].Id;
                        update srEntity[0];*/
                        
                        poBoxExist[0].Status__c = 'Blocked';
                        poBoxExist[0].P_O_Box_Selected_Bundle__c = step.HexaBPM__SR__r.P_O_Box_Type__c;
                        poBoxExist[0].Start_Date__c = System.Today();
                        //poBoxExist[0].Expiry_Date__c = Date.newInstance(System.Today().year(),12,31);
                        poBoxExist[0].Expiry_Date__c =System.Today().addYears(1);
                        poBoxExist[0].Account__c = step.HexaBPM__SR__r.HexaBPM__Customer__c;
                        update poBoxExist[0];
                        
                        HexaBPM__Service_Request__c srequest = new HexaBPM__Service_Request__c(id=step.HexaBPM__SR__c);
                        srequest.PO_Box__c = poBoxExist[0].id;
                        srequest.P_O_Box_Number__c = poBoxExist[0].Name;
                        update srequest;
                        
                        Account objAcct = new Account(Id=step.HexaBPM__SR__r.HexaBPM__Customer__c);
                        objAcct.PO_Box__c = poBoxExist[0].Id;
                        update objAcct;
                    }
                //}
            } catch(Exception e){
                strResult = e.getMEssage();
            }
        }
        
        return strResult;
     }
}