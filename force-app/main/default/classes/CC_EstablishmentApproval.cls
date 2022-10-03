/*
    Author      : Durga Prasad
    Date        : 01-Nov-2017
    Description : Custom code to calculate the Expiry date of Establishment Card.
    --------------------------------------------------------------------------------------
*/
global without sharing class  CC_EstablishmentApproval implements HexaBPM.iCustomCodeExecutable { 
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.Id!=null && step.HexaBPM__SR__c!=null){
            //HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c(Id=step.HexaBPM__SR__c);
            //objSR.Establishment_Card_Issue_Date__c = system.today();
            //objSR.Establishment_Card_Expiry_Date__c = step.HexaBPM__SR__r.Establishment_Card_Issue_Date__c.addYears(3);
            try{
                //update objSR;
                
                Account acc = new Account(Id=step.HexaBPM__SR__r.HexaBPM__Customer__c);
               // acc.Establishment_Card_No__c = step.HexaBPM__SR__r.Establishment_Card_Number__c;
               system.debug('-----English name--'+step.HexaBPM__SR__r.Establishment_English_Name__c+'--step id---'+step.id);
                acc.Establishment_Arabic_Name__c=step.HexaBPM__SR__r.Establishment_Arabic_Name__c;
                acc.Establishment_Card_Status__c='Active';
                acc.Establishment_English_Name__c  =step.HexaBPM__SR__r.Establishment_English_Name__c  ;
                acc.Establishment_Card_Expiry_Date__c = step.HexaBPM__SR__r.Establishment_Card_Expiry_Date__c;
                acc.Establishment_Card_Issue_Date__c = step.HexaBPM__SR__r.Establishment_Card_Issue_Date__c;
                
                update acc;
       /*
                Document_Details__c docs = new Document_Details__c();  
                docs.RecordTypeId='01226000000577h';
                docs.Document_Status__c='Active';
                docs.Document_Type__c='Establishment Card';
                docs.Document_Issue_Date__c= objSR.Establishment_Card_Issue_Date__c;
                docs.Document_Expiry_Date__c= objSR.Establishment_Card_Expiry_Date__c;
                docs.Account__c=acc.Id;
                insert docs;
            */    
            
            }catch(DMLException e){
                strResult = e.getMessage();
            }
        }
        return strResult;
    }
    
}