/*
    Author      : Kim Noceda
    Date        : 25-Mar-2018
    Description : Custom code to set POBox status to Allocated to the Entity of the Service request when approved.
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_SetPOBoxToAllocated implements HexaBPM.iCustomCodeExecutable { 
     global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.HexaBPM__SR__c != null){
            Account obAcct = [SELECT Id, PO_Box__c FROM Account WHERE Id = :step.HexaBPM__SR__r.HexaBPM__Customer__c];
            List<PO_Box__c> poBoxExist = [SELECT Id, Status__c, Start_Date__c, Expiry_Date__c, Account__c,P_O_Box_Selected_Bundle__c,  
                                            PO_Box_Number__c FROM PO_Box__c 
                                            WHERE Id = :obAcct.PO_Box__c];
            system.debug('####poBoxExist '+poBoxExist);
            try{
                if(!poBoxExist.isEmpty()){
                    
                    poBoxExist[0].Status__c = 'Allocated';
                    poBoxExist[0].Start_Date__c = System.Today();
                   	// poBoxExist[0].Expiry_Date__c = Date.newInstance(System.Today().year(),12,31);
                    poBoxExist[0].Expiry_Date__c =System.Today().addYears(1);
                    poBoxExist[0].Account__c = step.HexaBPM__SR__r.HexaBPM__Customer__c;
                    update poBoxExist[0];
                    
                    obAcct.PO_Box__c = null;
                    update obAcct;
                    
                    Document_Details__c docs = new Document_Details__c();  
                    docs.Document_Status__c='Active';
                    docs.Document_Type__c='P.O.Box';
                    docs.Document_Issue_Date__c= System.Today();
                    //docs.Document_Expiry_Date__c= Date.newInstance(System.Today().year(),12,31);
                    docs.Document_Expiry_Date__c= System.Today().addYears(1);
                    docs.Document_Number__c = poBoxExist[0].PO_Box_Number__c;
                    docs.Account__c = step.HexaBPM__SR__r.HexaBPM__Customer__c;
                    insert docs; 
                }
            } catch(Exception e){
                strResult = e.getMEssage();
            }
        }
        
        return strResult;
     }
}