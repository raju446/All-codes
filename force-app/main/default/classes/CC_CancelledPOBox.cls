/*
    Author      : Kim Noceda
    Date        : 20-Mar-2018
    Description : Custom code to set PO Box as cancelled and remove from the Entity level.
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_CancelledPOBox implements HexaBPM.iCustomCodeExecutable { 
     global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.HexaBPM__SR__c != null && step.HexaBPM__SR__r.HexaBPM__Customer__c != null){
            if(step.HexaBPM__SR__r.PO_Box__c != null){
            
                List<PO_Box__c> poBoxExist = [SELECT Id, Status__c, Start_Date__c, Expiry_Date__c,PO_Box_Number__c  
                                            FROM PO_Box__c 
                                            WHERE Id = : step.HexaBPM__SR__r.PO_Box__c LIMIT 1];
                                            
                try{
                    if(!poBoxExist.isEmpty()){
                        poBoxExist[0].Status__c = 'Cancelled';
                        poBoxExist[0].Start_Date__c = null;
                        poBoxExist[0].Expiry_Date__c = null;
                        poBoxExist[0].Cancelled_Date__c = System.Today();
                        //poBoxExist[0].Account__c = null;
                        update poBoxExist[0];
                        
                        list<Document_Details__c> docs = [Select id FROM Document_Details__c 
                                    WHERE Document_Type__c='P.O.Box' and Document_Number__c = :poBoxExist[0].PO_Box_Number__c];
                        
                        if(!docs.isEmpty())
                            delete docs;
                    }
                } catch(Exception e){
                    strResult = e.getMEssage();
                }
            }
        }
        
        return strResult;
     }
}