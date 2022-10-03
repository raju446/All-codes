global with sharing class CreateCRMRegEntity 
{
    webservice static string createentity(Id accountid)
    {
    	Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CRM Registered Entity').getRecordTypeId();
    	list<Account> acclist = [Select Name,Entity_Id__c, Entity_Status__c, Category__c, Registration_Date__c, License_Expiry_Date__c from Account where Id=:accountid];
    	if(!acclist.isEmpty()){
    		list<Account> crmEntity = [Select id from Account where Recordtypeid=:accRecordTypeId and CRM_Entity_Id__c=:acclist[0].Entity_Id__c and CRM_Entity_Id__c!= null ];
    		if(!crmEntity.isEmpty()){
    			system.debug('======exisitng id==='+crmEntity[0].id);
    			return 'CRM entity already exists.';
    		}
    		else{
    			Account acc = new Account();
    			acc.Recordtypeid = accRecordTypeId;
    			acc.Name 				= acclist[0].Name;
    			acc.CRM_Entity_Id__c	= acclist[0].Entity_Id__c;
    			acc.Entity_Status__c 	= acclist[0].Entity_Status__c;
    			acc.Registration_Date__c = acclist[0].Registration_Date__c;
    			acc.License_Expiry_Date__c = acclist[0].License_Expiry_Date__c;
    			if(acclist[0].Category__c == 'Financial (Category A)'){
    				acc.Lead_Category__c = 'Financial';
    			}else{
    				acc.Lead_Category__c = 'Non Financial';
    			}
    			insert acc;
    			return 'CRM Entity created successfully';
    		}
    	}
    	return null;
    }
}