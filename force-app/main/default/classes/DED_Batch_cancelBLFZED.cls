global without sharing class DED_Batch_cancelBLFZED implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
    	string restricttype = System.Label.DED_DNOT_Allow_Type;//'Restricted Scope Company';
    	string addresstype = 'Physical';
    	string query = 'SELECT ID, Cancellation_Date__c, Entity_Id__c, License_Expiry_Date__c, Entity_Type__c, Entity_Status__c  '; 
    	query += ' From Account where CancelBLFZED__c=true and Entity_Type__c !=:restricttype';
    	return database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,list<Account> accounts)
    {
			//Note: This batch will run with the batch size "1".
    		Account updateacc = new Account();    		
    		for(Account acc : accounts)
    		{
    			list<DED_Sub_Log__c> logs = DED_RestServicesHelper.cancelBLFZEDServiceRequest(acc);
    			for(DED_Sub_Log__c sl : logs)
    			{
    				if(sl.Message_Text__c == 'Success'){
    					updateacc.id = acc.id;
    					updateacc.CancelBLFZED__c = false;
    					break;
    				}
    			}
    		}
    		if(updateacc.id != null)
    			update updateacc;
    }
    global void finish(Database.BatchableContext BC){ 
        
    }
}