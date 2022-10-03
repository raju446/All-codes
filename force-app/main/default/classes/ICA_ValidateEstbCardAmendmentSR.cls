global without sharing class ICA_ValidateEstbCardAmendmentSR implements HexaBPM.iCustomCodeExecutable 
{
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) 
    {
    	string strResult = 'Success';
    	if(step.Id!=null && step.HexaBPM__SR__c!=null)
    	{
    		list<HexaBPM__Service_Request__c> existingSR = [Select id, HexaBPM__Linked_SR__c from HexaBPM__Service_Request__c where id=:step.HexaBPM__SR__c];
    		if(!existingSR.isEmpty() && existingSR[0].HexaBPM__Linked_SR__c != null){
    			list<HexaBPM__Service_Request__c> checkIAStatus = [Select id, HexaBPM__IsClosedStatus__c FROM HexaBPM__Service_Request__c where id=:existingSR[0].HexaBPM__Linked_SR__c];
    			if(!checkIAStatus.isEmpty() && checkIAStatus[0].HexaBPM__IsClosedStatus__c == false){
    				strResult = 'Kindly close the linked Initial approval SR first and then close the verification step.';
    				return strResult;
    			}
    		}
    	}
    	return null;
    }
}