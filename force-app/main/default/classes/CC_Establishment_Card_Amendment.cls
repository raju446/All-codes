/*
    Author      : Azmath
    Date        : 16-Dec-2018
    Description : Custom code to populate Establishment Card English & Arabic Name
    				and to create new document detail of EC.
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_Establishment_Card_Amendment implements HexaBPM.iCustomCodeExecutable
{
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step)
    {
    	string strResult = 'Success';
    	 if(step.HexaBPM__SR__c != null && step.HexaBPM__SR__r.HexaBPM__Customer__c != null)
    	 {
    	 	try{
	    	 	Account acc = new Account(Id=step.HexaBPM__SR__r.HexaBPM__Customer__c);
	    	 	acc.Establishment_English_Name__c = step.HexaBPM__SR__r.Establishment_English_Name__c;
	    	 	acc.Establishment_Arabic_Name__c = step.HexaBPM__SR__r.Establishment_Arabic_Name__c;
	    	 	acc.IsEntityChanged__c = false;
	    	 	update acc;
	    	 	
	    	 	list<Document_Details__c> docs = [Select Id,Document_Issue_Date__c,Document_Expiry_Date__c,Document_Number__c,Account__c FROM Document_Details__c 
	    	 							WHERE Document_Status__c = 'Active' and Document_Type__c='Establishment Card' and 
	    	 							Account__c =:step.HexaBPM__SR__r.HexaBPM__Customer__c];
	    	 	if(!docs.isEmpty())
	    	 	{
	    	 		docs[0].Document_Status__c = 'Inactive';
	    	 		update docs[0];
	    	 		
	    	 		Document_Details__c newDocDetail = docs[0];
	    	 		newDocDetail.id = null;
	    	 		newDocDetail.Document_Status__c = 'Active';
	    	 		
		            insert newDocDetail;
	    	 	}
	    	 	
	    	 	
	    	 	//Inactivate the alert which was created when entity name change is triggered.
	    	 	string alertText = 'Your companies name has been changed, Please update your establishment card.';
	    	 	list<Notice__c> alerts = new list<Notice__c>();
	    	 	for(Notice__c nt : [SELECT Id,Alert_Text__c FROM Notice__c WHERE Entity__c=:step.HexaBPM__SR__r.HexaBPM__Customer__c and Status__c='Active'])
	    	 	{
	    	 		if(nt.Alert_Text__c == alertText)
	    	 		{
		    	 		nt.Status__c = 'Inactive';
		    	 		alerts.add(nt);
	    	 		}
	    	 	}
	    	 	update alerts;
	    	 	
	    	 	
    	 	}catch(Exception e){
    	 		strResult = e.getMessage();
    	 	}
    	 }
    	 return strResult;
    }
}