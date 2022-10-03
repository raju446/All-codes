/*
    Author      : Durga Prasad
    Date        : 02-Jan-2018
    Description : Custom code to populate CID Approval Date
    -------------------------------------------------------------------------------------------
*/
global without sharing class CC_VisaQuotaCheck implements HexaBPM.iCustomCodeExecutable{
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step!=null && step.HexaBPM__SR__c!=null && step.HexaBPM__SR__r.HexaBPM__Customer__c!=null){
        	integer TotalVisasAllowed = 0;
        	integer TotalVisasUsed = 0;
        	for(Account acc:[Select Total_Visas_Allowed__c from Account where Id=:step.HexaBPM__SR__r.HexaBPM__Customer__c and Total_Visas_Allowed__c!=null]){
        		TotalVisasAllowed = integer.valueof(acc.Total_Visas_Allowed__c);
        	}
        	list<string> lstDocumentTypes = new list<string>{'Temporary Employee Work Permit','Residence Visa','Employee Work Permit(UAE/GCC National)'};
        	//Existing Employees
        	for(Document_Details__c doc:[select id from Document_Details__c where Account__c=:step.HexaBPM__SR__r.HexaBPM__Customer__c and Document_Type__c IN:lstDocumentTypes and Document_Status__c='Active']){
        		TotalVisasUsed++;
        	}
        	system.debug('TotalVisasAllowed==>'+TotalVisasAllowed);
        	system.debug('Active Employees Count==>'+TotalVisasUsed);
        	list<string> lstSRTypes = new list<string>{'Employment_Visa_New','Employee_Work_Permit_UAE_GCC_National_New','Temporary_Work_Permit_New'};
        	//Open SR's 
        	for(HexaBPM__Service_Request__c doc:[select Id from HexaBPM__Service_Request__c where HexaBPM__Customer__c=:step.HexaBPM__SR__r.HexaBPM__Customer__c and Id!=:step.HexaBPM__SR__c and HexaBPM__Record_Type_Name__c IN:lstSRTypes and HexaBPM__Internal_Status_Name__c!='Draft' and HexaBPM__IsClosedStatus__c=false and HexaBPM__Is_Rejected__c=false and HexaBPM__IsCancelled__c=false]){
        		TotalVisasUsed++;
        	}
        	system.debug('Active Employees Count Including Open SRs==>'+TotalVisasUsed);
        	if(TotalVisasUsed >= TotalVisasAllowed)
        		strResult = 'Visa Quota limit exceeded.';
        }
		return strResult;
    }
}