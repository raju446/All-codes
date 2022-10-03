/*
    Author      : Khushboo Agarwal
    Date        : 12-Nov-2017
    Description : Custom code to copy the passport number, expiry date and issue date from service request to entity on amendments
    -------------------------------------------------------------------------------------------------------------------------------------
*/
global without sharing class  CC_VisaAmendmentsEntity implements HexaBPM.iCustomCodeExecutable { 
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.Id!=null && step.HexaBPM__SR__c!=null){
                   try{
                           
               Contact con = new Contact(Id=step.HexaBPM__SR__r.HexaBPM__Contact__c);
                con.Passport_No__c = step.HexaBPM__SR__r.Passport_Number__c;
                con.Passport_Expiry_Date__c=step.HexaBPM__SR__r.Passport_Expiry_Date__c;
                con.Passport_Issue_Date__c=step.HexaBPM__SR__r.Passport_Issue_Date__c;
                update con;
                
            }catch(DMLException e){
                strResult = e.getMessage();
            }
        }
        return strResult;
    }
    
}