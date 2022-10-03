/*
    Author      : Khushboo Agarwal
    Date        : 03-Dec-2017
    Description : Custom code to insert new document detail for Shisha/Alcohol
    -------------------------------------------------------------------------------------------
*/
global without sharing class  CC_ShishaAndAlcoholPermitUpdate implements HexaBPM.iCustomCodeExecutable { 
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.Id!=null && step.HexaBPM__SR__c!=null){
           
                
            try{
            
             list<Document_Details__c> lstPermit = [select Id,Document_Expiry_Date__c,Document_Last_Renewed_Date__c, Document_Issue_Date__c from Document_Details__c where Account__c=:step.HexaBPM__SR__r.HexaBPM__Customer__c and Document_Type__c='step.HexaBPM__SR__r.Service_Request_Name__c' and Document_Status__c='Active' limit 1];
               if(lstPermit!=null && lstPermit.size()>0){
                   lstPermit[0].Document_Last_Renewed_Date__c = system.today();
                  // lstWorkPermit[0].Document_Expiry_Date__c = system.today().addDays(3);
                   update lstPermit;
               }
                        
              
                
            }catch(DMLException e){
                strResult = e.getMessage();
            }
        }
        return strResult;
    }
    
    }