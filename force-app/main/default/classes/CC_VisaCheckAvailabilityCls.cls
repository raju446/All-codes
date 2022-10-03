/*
    Author      : Kim Noceda
    Date        : 28-Dec-2017
    Description : Custom code to create check Visa Availability on submit of SR.
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_VisaCheckAvailabilityCls implements HexaBPM.iCustomCodeExecutable {
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        System.debug('@@STRRESULT: '+strResult);
        System.debug('@@OBJSR: '+step.HexaBPM__SR__c);
        if(step.HexaBPM__SR__c!=null){
            if(step.HexaBPM__SR__r.HexaBPM__Customer__c != null){
                Account objAcct = [SELECT Id, Total_Visas_Allowed__c, Total_Visas_Used__c, Visas_Available__c FROM Account WHERE Id = :step.HexaBPM__SR__r.HexaBPM__Customer__c];
                
                Set<String> visaAPIs = new Set<String>();
                for(Visa_Check_Availability_API__c csVisa : Visa_Check_Availability_API__c.getAll().values()){
                    visaAPIs.add(csVisa.API_Name__c);
                }
                
                Decimal srCtr = 0;
                for(HexaBPM__Service_Request__c objSR : [SELECT Id FROM HexaBPM__Service_Request__c 
                                                            WHERE HexaBPM__Customer__c = :objAcct.Id 
                                                            AND HexaBPM__IsClosedStatus__c <> true 
                                                            AND HexaBPM__External_SR_Status__r.HexaBPM__Code__c <> 'DRAFT' 
                                                            AND ID !=:step.HexaBPM__SR__c
                                                            AND Work_Permit_Issue_Date__c = null 
                                                            AND Recordtype.DeveloperName IN :visaAPIs]){
                    srCtr = srCtr + 1;
                    System.debug('@@SR: '+objSR.Id);
                }
                
                System.debug('@@COUNTER: '+srCtr);
                Decimal totalVisasUsed = 0;
                if(objAcct.Total_Visas_Used__c != null){
                    totalVisasUsed = objAcct.Total_Visas_Used__c;
                }
                Decimal totalCount = totalVisasUsed + srCtr + 1;
                if(totalCount > objAcct.Total_Visas_Allowed__c){
                    strResult = 'The service request cannot be submitted. You have reached the limit of Visas allowed.';
                }
            }
        }
        return strResult;
    }
    
}