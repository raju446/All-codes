/*
    Author      : Kim Noceda
    Date        : 25-Feb-2018
    Description : Custom code to generate Work Permit Number.
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_GenerateWorkPermitNumberCls implements HexaBPM.iCustomCodeExecutable { 
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.HexaBPM__SR__c != null){
            Integer adgmPermanentWorkPermit;
            Integer adgmTemporaryWorkPermit;
            
            Work_Permit_Running_Number__c tempWorkPermit = Work_Permit_Running_Number__c.getInstance('Temporary Work Permit');
            Work_Permit_Running_Number__c permaWorkPermit = Work_Permit_Running_Number__c.getInstance('Permanent Work Permit');
            
            adgmPermanentWorkPermit = Integer.valueOf(permaWorkPermit.Work_Permit_Running_Number__c);
            adgmTemporaryWorkPermit = Integer.valueOf(tempWorkPermit.Work_Permit_Running_Number__c);
            
            List<Work_Permit_Running_Number__c> workPermitList = new List<Work_Permit_Running_Number__c>();
            
            HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c(Id = step.HexaBPM__SR__c);
            if(step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Employee_Work_Permit_UAE_GCC_National_New' || 
                step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Employment_Visa_New' ||
                step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'New_Work_Permit_Full_Time_Non_Sponsored_Employee' ||
                step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Long_Term_Residence_Visa_New' || 
                step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Visa_Transfer'){
                objSR.Work_Permit_Card_Number__c = permaWorkPermit.Work_Permit_Number_Prefix__c + String.valueOf(++adgmPermanentWorkPermit).leftpad(7).replace(' ', '0');
                permaWorkPermit.Work_Permit_Running_Number__c = adgmPermanentWorkPermit;
                workPermitList.add(permaWorkPermit);
            }else if(step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Temporary_Work_Permit_New'){
                objSR.Work_Permit_Card_Number__c = tempWorkPermit.Work_Permit_Number_Prefix__c + String.valueOf(++adgmTemporaryWorkPermit).leftpad(7).replace(' ', '0');
                tempWorkPermit.Work_Permit_Running_Number__c = adgmTemporaryWorkPermit;
                workPermitList.add(tempWorkPermit);
            }
            
            if(!workPermitList.isEmpty()){
                try{
                    update objSR;
                    update workPermitList;
                } catch(Exception e){
                    strResult = e.getMessage();
                }
            }
        }
        
        return strResult;
    }
}