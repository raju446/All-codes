/*
    Author      : Khushboo Agarwal
    Date        : 03-Dec-2017
    Description : Custom code to insert new document detail for Shisha/Alcohol
    -------------------------------------------------------------------------------------------
*/
global without sharing class  CC_ShishaAndAlcoholPermit implements HexaBPM.iCustomCodeExecutable { 
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.Id!=null && step.HexaBPM__SR__c!=null){
           
                
            try{
            
            
               Document_Details__c docs = new Document_Details__c();  
               docs.Account__c=step.HexaBPM__SR__r.HexaBPM__Customer__c;
                docs.Document_Status__c='Active';
                docs.Document_Type__c=step.HexaBPM__SR__r.Service_Request_Name__c;
                docs.Document_Issue_Date__c= step.HexaBPM__SR__r.Valid_From__c;
                docs.Document_Expiry_Date__c= step.HexaBPM__SR__r.Valid_To__c;
                
                insert docs; 
                
            }catch(DMLException e){
                strResult = e.getMessage();
            }
        }
        return strResult;
    }
    
    }