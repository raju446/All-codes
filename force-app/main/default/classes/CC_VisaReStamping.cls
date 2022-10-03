/*
Author      : Khushboo Agarwal
Date        : 15-Feb-2018
Description : Custom code to copy the amendment information, passport number, expiry date and issue date from service request to entity 
------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
global without sharing class  CC_VisaReStamping implements HexaBPM.iCustomCodeExecutable { 
global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
    string strResult = 'Success';
    if(step.Id!=null && step.HexaBPM__SR__c!=null){
               
       try{
       
            list<Document_Details__c> lstDocs;
            
            if(step.HexaBPM__SR__r.Dependent__c !=null) {
            
                Contact con = new Contact(Id=step.HexaBPM__SR__r.Dependent__c);
                       con.Passport_Issue_Date__c= step.HexaBPM__SR__r.Passport_Issue_Date__c ;
                       con.Passport_Expiry_Date__c = step.HexaBPM__SR__r.Passport_Expiry_Date__c ;
                       con.Passport_No__c = step.HexaBPM__SR__r.Passport_Number__c ;
                 //      con.Passport_Type__c = step.HexaBPM__SR__r.Passport_Type__c ;
                       con.Residence_Visa_Number__c = step.HexaBPM__SR__r.Residence_Visa_Number__c ;
                       con.Residence_Visa_Date_of_Issue__c = step.HexaBPM__SR__r.Residence_Visa_Date_of_Issue__c ;
                       con.Residence_Visa_Date_of_Expiry__c = step.HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c;

                       update con;
                           
                lstDocs = [select Id, Passport_No__c, Passport_Expiry_Date__c, Passport_Issue_Date__c from Document_Details__c where Account__c=:step.HexaBPM__SR__r.HexaBPM__Customer__c and Contact__c=: step.HexaBPM__SR__r.Dependent__c  and Document_Type__c='Residence Visa' and Document_Status__c='Active' limit 1];
                
            }else{
                       
                Contact con = new Contact(Id=step.HexaBPM__SR__r.HexaBPM__Contact__c);
                       con.Passport_Issue_Date__c= step.HexaBPM__SR__r.Passport_Issue_Date__c ;
                       con.Passport_Expiry_Date__c = step.HexaBPM__SR__r.Passport_Expiry_Date__c ;
                       con.Passport_No__c= step.HexaBPM__SR__r.Passport_Number__c ;
                //       con.Passport_Type__c = step.HexaBPM__SR__r.Passport_Type__c ;
                       con.Residence_Visa_Number__c = step.HexaBPM__SR__r.Residence_Visa_Number__c ;
                       con.Residence_Visa_Date_of_Issue__c = step.HexaBPM__SR__r.Residence_Visa_Date_of_Issue__c ;
                       con.Residence_Visa_Date_of_Expiry__c = step.HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c;
                       update con;
                
                lstDocs = [select Id, Passport_No__c, Passport_Expiry_Date__c, Passport_Issue_Date__c from Document_Details__c where Account__c=:step.HexaBPM__SR__r.HexaBPM__Customer__c and Contact__c=: step.HexaBPM__SR__r.HexaBPM__Contact__c  and Document_Type__c='Residence Visa' and Document_Status__c='Active' limit 1];
            }
           
                     
            if(lstDocs!=null && lstDocs.size()>0){
               lstDocs [0].Passport_No__c= step.HexaBPM__SR__r.Passport_Number__c;
               lstDocs [0].Passport_Expiry_Date__c = step.HexaBPM__SR__r.Passport_Expiry_Date__c;
               lstDocs [0].Passport_Issue_Date__c = step.HexaBPM__SR__r.Passport_Issue_Date__c;
               lstDocs[0].Document_Number__c = step.HexaBPM__SR__r.Residence_Visa_Number__c;
               lstDocs[0].Document_Issue_Date__c= step.HexaBPM__SR__r.Residence_Visa_Date_of_Issue__c;
               lstDocs[0].Document_Expiry_Date__c=step.HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c;
               update lstDocs ;
            }
            
           
            
        }catch(DMLException e){
            strResult = e.getMessage();
        }
    }
    return strResult;
}

}