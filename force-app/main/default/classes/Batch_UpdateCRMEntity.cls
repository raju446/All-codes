/*
* Author : Azmath
* Description : This batch class is used to udpate the CRM Entity fields based on the License number populated in the Pre application Number.
*				This class will take care of those entities which has the licnese numbers (Not starting with "P"), for the licneses which starts with "P", 
				there is another batch called "Batch_UpdateLicenseNumber".
*/
global class Batch_UpdateCRMEntity implements Database.Batchable<sObject>,Schedulable
{
	global void execute(SchedulableContext sc) {
        database.executebatch(this,1); 
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator
        	([SELECT Id, CRM_Entity_Id__c,CRM_Pre_Approval_Id__c FROM Account WHERE  
        		CRM_Entity_Id__c = null and ( NOT CRM_Pre_Approval_Id__c like 'P%') and CRM_Pre_Approval_Id__c  != null and Record_Type_Name__c = 'ADGM_CRM']);
    }
    global void execute(Database.BatchableContext bc, List<Account> records) 
    {
    	set<string> entityIds = new set<string>();
    	map<string,string> actualEntieis = new map<string,string>();
    	for(Account acc : records)
    	{
    		string eid = acc.CRM_Pre_Approval_Id__c;
    		if(!eid.startsWith('P')){
    			eid = eid.replace('(','');
    			eid = eid.replace(')','');
    			entityIds.add(eid);
    			actualEntieis.put(acc.CRM_Pre_Approval_Id__c,eid);
    		}
    	}
    	if(!entityIds.isEmpty())
    	{
    		map<string,Account> adgmEntityesMap = new map<string,Account>();
    		list<Account> updateAccounts = new list<Account>();
    		for(Account acc : [Select Name, Entity_Id__c, Entity_Status__c, Registration_Date__c, License_Expiry_Date__c from Account where Entity_Id__c IN:entityIds  and Record_Type_Name__c = 'ADGM_Registered_Company'])
    		{
    			adgmEntityesMap.put(acc.Entity_Id__c,acc);
    		}
    		if(!adgmEntityesMap.isEmpty())
    		{
    			for(Account acc : records)
    			{
    				string eid = actualEntieis.get(acc.CRM_Pre_Approval_Id__c);
    				if(eid != null && eid != '')
    				{
    					Account a = adgmEntityesMap.get(eid);
    					if(a!=null)
    					{
    						acc.Name 					= a.Name;
	    					acc.Entity_Status__c 		= a.Entity_Status__c;
	    					acc.Registration_Date__c 	= a.Registration_Date__c;
	    					acc.License_Expiry_Date__c 	= a.License_Expiry_Date__c;
	    					acc.CRM_Entity_Id__c 		= a.Entity_Id__c;
	    					updateAccounts.add(acc);
    					}
    				}
    			}
    			if(!updateAccounts.isEmpty()){
    				update updateAccounts;
    			}
    		}
    	}
    }
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }  
}