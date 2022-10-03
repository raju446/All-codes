/*
    Author      : Khushboo Agarwal
    Date        : 29-Nov-2017
    Description : Custom code to calculate the Expiry date of Temporary Work Permit and copy fields to Document Detail
    ----------------------------------------------------------------------------------------------------------------------
*/
global without sharing class  CC_WorkPermitTemporary implements HexaBPM.iCustomCodeExecutable { 
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        
        if(step.Id!=null && step.HexaBPM__SR__c!=null){
            
            HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c(Id=step.HexaBPM__SR__c);
            
            objSR.Work_Permit_Issue_Date__c  = system.today();
            
            integer PermitDays = 0;
            
            if(step.HexaBPM__SR__r.Work_Permit_Validity__c == '3'){
                PermitDays=90;
            }
            if(step.HexaBPM__SR__r.Work_Permit_Validity__c == '6'){
                PermitDays=180;
            }
            if(step.HexaBPM__SR__r.Work_Permit_Validity__c == '12'){
                PermitDays=365;
            }
            
            system.debug(' Permit Days : ' + PermitDays);
            
            //if((objSR.Residence_Visa_Date_of_Expiry__c - system.today()) < PermitDays){
            
           
            
            if(system.today().daysBetween(step.HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c) < PermitDays)    
            {
            objSR.Work_Permit_Expiry_Date__c = step.HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c;
            }else{ 
            objSR.Work_Permit_Expiry_Date__c = Date.valueOf(system.today().addDays(PermitDays));
             system.debug('@@WorkPermitExpiryDate: '+objSR.Work_Permit_Expiry_Date__c);
           } 
            
            try{
              
                update objSR;
                
                
                system.debug('@@CONTACT1: '+step.HexaBPM__SR__r.HexaBPM__Customer__c);
                system.debug('@@CONTACT2: '+objSR.Passport_Number__c);
                system.debug('@@CONTACT3: '+objSR.Nationality__c);
         
                list<Contact> lstCont = [select Id, Name, Nationality__c, Passport_No__c from Contact where  
                					AccountID=:step.HexaBPM__SR__r.HexaBPM__Customer__c and 
                					Passport_No__c=:step.HexaBPM__SR__r.Passport_Number__c and 
                					(Dependent_Status__c = 'Active' OR Employment_Status__c = 'Active') and 
                					Nationality__c=:step.HexaBPM__SR__r.Nationality__c limit 1];                        
                system.debug('@@CONTACT: '+lstCont);
                if(lstCont!=null && lstCont.size()==1){
                    strResult = 'Contact already exists in the system';
                    return strResult;
                
                }
               /* 
                else {
         
                    
                    Contact c = new Contact();
                    c.FirstName=step.HexaBPM__SR__r.First_Name__c;
                    c.LastName=step.HexaBPM__SR__r.Last_Name__c;
                    c.Nationality__c=step.HexaBPM__SR__r.Nationality__c;
                    c.Passport_No__c=step.HexaBPM__SR__r.Passport_Number__c;
                    c.Email=step.HexaBPM__SR__r.Employee_Email_ID__c;
                    c.Gender__c=step.HexaBPM__SR__r.Gender__c;
                    c.Passport_Issue_Date__c=step.HexaBPM__SR__r.Passport_Issue_Date__c;
                    c.Passport_Expiry_Date__c=step.HexaBPM__SR__r.Passport_Expiry_Date__c;
                    c.Birthdate=step.HexaBPM__SR__r.Date_of_Birth__c;
                    c.UAE_Visa_Number__c=step.HexaBPM__SR__r.Residence_Visa_Number__c;
                    c.Work_Permit_Card_Number__c=step.HexaBPM__SR__r.Work_Permit_Card_Number__c;
                    c.Work_Permit_Expiry_Date__c=step.HexaBPM__SR__r.Work_Permit_Expiry_Date__c;
                    c.AccountId = step.HexaBPM__SR__r.HexaBPM__Customer__c;
                    insert c;
      
                    Document_Details__c docs = new Document_Details__c();  
                    //docs.RecordTypeId='01226000000577h';
                    docs.Document_Status__c='Active';
                    docs.Document_Type__c='Temporary Employee Work Permit';
                    docs.Document_Issue_Date__c= objSR.Work_Permit_Issue_Date__c;
                    docs.Document_Expiry_Date__c= objSR.Work_Permit_Expiry_Date__c;
                    docs.Work_Permit__c =objSR.Work_Permit_Card_Number__c;
                    docs.Account__c=step.HexaBPM__SR__r.HexaBPM__Customer__c;
                    docs.Contact__c=c.Id;
                    insert docs; 
                
            }
            
            */
            }catch(DMLException e){
                strResult = e.getMessage();
            }
        }
        return strResult;
    }
}