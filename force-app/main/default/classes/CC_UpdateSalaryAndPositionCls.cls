/*
    Author      : Kim Noceda
    Date        : 04-Jan-2018
    Description : Custom code to create update details of the contact.
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_UpdateSalaryAndPositionCls implements HexaBPM.iCustomCodeExecutable { 
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.HexaBPM__SR__c!=null){
            if(step.HexaBPM__SR__r.HexaBPM__Contact__c != null){
                //Contact objCon = [SELECT Id, Job_Code__c, Job_Title__c, Gross_Monthly_Salary__c FROM Contact WHERE Id = :step.HexaBPM__SR__r.HexaBPM__Contact__c LIMIT 1];
                Contact objCon = [SELECT Id, Job_Code__c, Job_Title__c, Gross_Monthly_Salary__c FROM Contact WHERE Id = :step.HexaBPM__SR__r.HexaBPM__Contact__c LIMIT 1];
                objCon.Job_Code__c =  step.HexaBPM__SR__r.Job_Title__c;
                /*System.debug('@@JOBECODE: '+objCon.Job_Code__c);
                if(objCon.Job_Code__c != null){
                    Lookup__c objLookup = [SELECT Id, Name FROM Lookup__c WHERE Id = :objCon.Job_Code__c LIMIT 1];
                    System.debug('@@JLOOKUP: '+objLookup.Name);
                    objCon.Job_Title__c = objLookup.Name;
                }*/
                objCon.Gross_Monthly_Salary__c = step.HexaBPM__SR__r.Gross_Monthly_Salary__c;
                try{
                    update objCon;
                } catch(Exception e){
                    strResult = e.getMessage();
                }
            }
        }
        return strResult;
    }
}