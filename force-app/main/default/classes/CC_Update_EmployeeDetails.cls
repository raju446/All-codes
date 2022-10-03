/*
    Author      : Durga Prasad
    Date        : 18-Oct-2017
    Description : Custom code to update the salary, position and marital status of employee
    ----------------------------------------------------------------------------------------
*/
global without sharing class CC_Update_EmployeeDetails implements HexaBPM.iCustomCodeExecutable {
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c stp) {
        string strResult = 'Success';
        if(stp.HexaBPM__SR__c!=null && stp.HexaBPM__SR__r.HexaBPM__Contact__c!=null){
            Contact objEmployee = new Contact(Id=stp.HexaBPM__SR__r.HexaBPM__Contact__c);
            
            if(stp.HexaBPM__SR__r.Gross_Monthly_Salary__c!=null)
                objEmployee.Gross_Monthly_Salary__c = stp.HexaBPM__SR__r.Gross_Monthly_Salary__c;
            if(stp.HexaBPM__SR__r.Marital_Status__c!=null)
                objEmployee.Marital_Status__c = stp.HexaBPM__SR__r.Marital_Status__c;
            if(stp.HexaBPM__SR__r.Marital_Status__c!=null)
                objEmployee.Marital_Status__c = stp.HexaBPM__SR__r.Marital_Status__c;
            if(stp.HexaBPM__SR__r.Job_Title__c!=null)
                objEmployee.Job_Code__c = stp.HexaBPM__SR__r.Job_Title__c;
            
            if(stp.HexaBPM__SR__r.Passport_Number__c != null)
                objEmployee.Passport_No__c = stp.HexaBPM__SR__r.Passport_Number__c;         
            
            if(stp.HexaBPM__SR__r.Passport_Expiry_Date__c != null)
                objEmployee.Passport_Expiry_Date__c = stp.HexaBPM__SR__r.Passport_Expiry_Date__c;   
                
            if(stp.HexaBPM__SR__r.Passport_Place_of_Issue__c != null)
                objEmployee.Passport_Place_of_Issue__c = stp.HexaBPM__SR__r.Passport_Place_of_Issue__c;
            
            if(stp.HexaBPM__SR__r.Passport_Issue_Date__c!= null)
                objEmployee.Passport_Issue_Date__c= stp.HexaBPM__SR__r.Passport_Issue_Date__c;  
            
            if(stp.HexaBPM__SR__r.Nationality__c  != null)
            {
                objEmployee.Nationality__c = stp.HexaBPM__SR__r.Nationality__c  ; 
                for(Lookup__c lk : [Select id FROM Lookup__c where Name=:stp.HexaBPM__SR__r.Nationality__c and Type__c='Nationality' limit 1])
                {
                    objEmployee.Nationality_Lookup__c = lk.id;
                }
            }
            try{
                update objEmployee;
            }catch(Exception e){
                strResult = e.getmessage()+'';
            }
        }
        return strResult;
    }
}