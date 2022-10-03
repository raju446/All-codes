/*
    Author      : Khushboo Agarwal
    Date        : 12-Nov-2017
    Description : Custom code to copy the amendment information, passport number, expiry date and issue date from service request to entity on name amendment
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
global without sharing class  CC_NameAmendment implements HexaBPM.iCustomCodeExecutable { 
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.Id!=null && step.HexaBPM__SR__c!=null){
                   
           try{
           
           
                if(step.HexaBPM__SR__r.Dependent__c !=null) {
                
                    Contact con = new Contact(Id=step.HexaBPM__SR__r.Dependent__c);
                       con.First_Name__c= step.HexaBPM__SR__r.First_Name__c ;
                       con.Middle_Name__c = step.HexaBPM__SR__r.Middle_Name__c ;
                       con.Last_Name__c = step.HexaBPM__SR__r.Last_Name__c ;
                       con.FirstName = step.HexaBPM__SR__r.First_Name__c ;
                       con.LastName = step.HexaBPM__SR__r.Last_Name__c ;
                       con.First_Name_Arabic__c = step.HexaBPM__SR__r.First_Name_Arabic__c ;
                       con.Middle_Name_Arabic__c = step.HexaBPM__SR__r.Middle_Name_Arabic__c ;
                       con.Last_Name_Arabic__c = step.HexaBPM__SR__r.Last_Name_Arabic__c ;
                       update con;
                
                }else{
                           
                    Contact con = new Contact(Id=step.HexaBPM__SR__r.HexaBPM__Contact__c);
                
                       con.First_Name__c= step.HexaBPM__SR__r.First_Name__c ;
                       con.Middle_Name__c = step.HexaBPM__SR__r.Middle_Name__c ;
                       con.Last_Name__c = step.HexaBPM__SR__r.Last_Name__c ;
                       con.FirstName = step.HexaBPM__SR__r.First_Name__c ;
                       con.LastName = step.HexaBPM__SR__r.Last_Name__c ;
                       con.First_Name_Arabic__c = step.HexaBPM__SR__r.First_Name_Arabic__c ;
                       con.Middle_Name_Arabic__c = step.HexaBPM__SR__r.Middle_Name_Arabic__c ;
                       con.Last_Name_Arabic__c = step.HexaBPM__SR__r.Last_Name_Arabic__c ;
                       update con;
                       
                }
               /*
                
                list<Document_Details__c> lstDocs = [select Id, Passport_No__c, Passport_Expiry_Date__c, Passport_Issue_Date__c from Document_Details__c where Account__c=:step.HexaBPM__SR__r.HexaBPM__Customer__c and Contact__c=: step.HexaBPM__SR__r.HexaBPM__Contact__c  and Document_Type__c='Residence Visa' and Document_Status__c='Active' limit 1];
                if(lstDocs!=null && lstDocs.size()>0){
                   lstDocs [0].Passport_No__c= step.HexaBPM__SR__r.Passport_Number__c;
                   lstDocs [0].Passport_Expiry_Date__c = step.HexaBPM__SR__r.Passport_Expiry_Date__c;
                   lstDocs [0].Passport_Issue_Date__c = step.HexaBPM__SR__r.Passport_Issue_Date__c;

                   update lstDocs ;
                }
                
               */
                
            }catch(DMLException e){
                strResult = e.getMessage();
            }
        }
        return strResult;
    }
    
}