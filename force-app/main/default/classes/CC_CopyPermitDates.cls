/*
    Author      : Durga Prasad
    Date        : 06-June-2018
    Description : Custom code to Close the open Step on approval of customer cancellation step
    -------------------------------------------------------------------------------------------
*/
global with sharing class CC_CopyPermitDates implements hexabpm.iCustomCodeExecutable{
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c stp) {
        string strResult = 'Success';
        if(stp.HexaBPM__SR__r.Start_Date__c!=null && stp.HexaBPM__SR__r.End_Date__c!=null && stp.HexaBPM__SR__r.Valid_From__c==null && stp.HexaBPM__SR__r.Valid_To__c==null){
        	try{
        		HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c(Id=stp.HexaBPM__SR__c);
        		objSR.Valid_From__c = stp.HexaBPM__SR__r.Start_Date__c;
        		objSR.Valid_To__c = stp.HexaBPM__SR__r.End_Date__c;
        		update objSR;
        	}catch(DMLException e){
        		string DMLError = e.getdmlMessage(0)+'';
                if(DMLError==null){
                    DMLError = e.getMessage()+'';
                }
                strResult = DMLError;
        	}
        }
        return strResult;
    }
}