global without sharing class ICA_UpdateIANumber implements HexaBPM.iCustomCodeExecutable 
{
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) 
    {
        string strResult = 'Success';
        if(step.Id!=null && step.HexaBPM__SR__c!=null)
        {
        	string IANumber ='';
            list<HexaBPM__Service_Request__c> currentSR = [Select id, ADP_Status__c,HexaBPM__Parent_SR__c, TransactionRef__c,HexaBPM__Customer__c, Initial_Approval_Issue_Date__c,Initial_Approval_Expiry_Date__c FROM HexaBPM__Service_Request__c where id=:step.HexaBPM__SR__c LIMIT 1];
            if(!currentSR.isEmpty())
            {
            	system.debug('===='+currentSR[0].HexaBPM__Parent_SR__c);
            	//Update IA on Account leavel.
	            if(currentSR[0].ADP_Status__c == 'Approved') 
	            {
	            	IANumber = currentSR[0].TransactionRef__c;
	            	Account acc = new Account(id=currentSR[0].HexaBPM__Customer__c, Initial_Approval_Issue_Date__c=currentSR[0].Initial_Approval_Issue_Date__c,
	            		Initial_Approval_Expiry_Date__c=currentSR[0].Initial_Approval_Expiry_Date__c);
	            		update acc;
	            }
	            //Update child SR status if IA is triggered as SUB SR.
	            list<HexaBPM__Service_Request__c> parentSR = [Select id FROM HexaBPM__Service_Request__c where id=:currentSR[0].HexaBPM__Parent_SR__c LIMIT 1];
	            if(!parentSR.isEmpty())
	            {
	            	list<HexaBPM__Step__c> IAStep = [Select id from HexaBPM__Step__c where HexaBPM__Summary__c = 'Initial Approval' and HexaBPM__SR__c=:parentSR[0].id];
            		if(!IAStep.isEmpty())
            		{
            			if(currentSR[0].ADP_Status__c == 'Approved')
            				IAStep[0].HexaBPM__Status__c = system.label.Approved_step_status;
            			else
            				IAStep[0].HexaBPM__Status__c = system.label.Rejected_step_status;
            			update IAStep;
            		}
            		parentSR[0].Initial_Approval_Number__c = currentSR[0].TransactionRef__c;
            		update parentSR;
            		
            		list<Initial_Approval_List__c> iarec = [Select id,Assigned_To__c from Initial_Approval_List__c where Initial_Approval_Number__c=:currentSR[0].TransactionRef__c and Assigned_To__c=null limit 1];
            		if(!iarec.isEmpty()){
            			iarec[0].Assigned_To__c = parentSR[0].id;
            			update iarec;
            		}
	            }
            }
	            
            if(IANumber != null && IANumber != ''){
            	list<HexaBPM__Service_Request__c> amendmentSR = [Select id FROM HexaBPM__Service_Request__c where HexaBPM__Linked_SR__c=:step.HexaBPM__SR__c LIMIT 1];
            	if(!amendmentSR.isEmpty()){
            		amendmentSR[0].Initial_Approval_Number__c = IANumber;
            		update amendmentSR;
            		
            		list<Initial_Approval_List__c> iarec = [Select id,Assigned_To__c from Initial_Approval_List__c where Initial_Approval_Number__c=:IANumber and Assigned_To__c=null limit 1];
            		if(!iarec.isEmpty()){
            			iarec[0].Assigned_To__c = amendmentSR[0].id;
            			update iarec;
            		}
            	}
            }
            //change the internal and external statuses.
            if(currentSR[0].ADP_Status__c == 'Rejected')
            {
            	currentSR[0].HexaBPM__Internal_SR_Status__c = system.Label.Request_Rejected;
            	currentSR[0].HexaBPM__External_SR_Status__c = system.Label.CompletedStatus;
            }else{
            	currentSR[0].HexaBPM__Internal_SR_Status__c = system.Label.ICA_Awaiting_IA_Copy_download;
            	currentSR[0].HexaBPM__External_SR_Status__c = system.Label.ICA_Awaiting_IA_Copy_download;
            }
            update currentSR;
        }
        return null; 
    } 
}