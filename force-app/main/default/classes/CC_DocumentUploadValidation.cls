/*
    Author      : Durga Prasad
    Date        : 18-Oct-2017
    Description : Custom code to check the documents which are to be uploaded at a specific step.
    ----------------------------------------------------------------------------------------------
*/
global without sharing class CC_DocumentUploadValidation implements HexaBPM.iCustomCodeExecutable {
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c stp) {
    	string strResult = 'Success';
    	if(stp!=null && stp.Id!=null){
    		string DocumentNames = '';
    		for(HexaBPM__SR_Doc__c doc:[Select Id,Name,HexaBPM__Status__c,HexaBPM__Doc_ID__c from HexaBPM__SR_Doc__c where HexaBPM__Step__c=:stp.Id]){
    			if(doc.HexaBPM__Status__c!='Uploaded' || doc.HexaBPM__Doc_ID__c==null){
    				if(DocumentNames=='')
    					DocumentNames = doc.Name;
    				else
    					DocumentNames = DocumentNames+','+doc.Name;
    			}
    		}
    		if(DocumentNames!='')
    			strResult = DocumentNames+' to be uploaded to proceed.';
    	}
    	return strResult;
    }
}