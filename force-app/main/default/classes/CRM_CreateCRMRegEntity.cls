public without sharing class CRM_CreateCRMRegEntity
{
	/* Author : Azmath
	* Description : This method will gets called from Accounttriggerhandler and the pupose of this method is to create the CRM Registered entity 
	* 				whenever the ADGM Registered entity's status is changed to "Registered" and the category is "Category C(Retail)".
	*/
	
	@future
    public static void createCategoryCEntities(set<string> eids)
    {
    	set<string> existingCRMEntities = new set<string>();
    	set<string> customentityIds = new set<string>();
    	
    	for(Account ac : [Select id,CRM_Entity_Id__c from Account where CRM_Entity_Id__c IN:eids and Record_Type_Name__c = 'ADGM_CRM']){
    		existingCRMEntities.add(ac.CRM_Entity_Id__c);
    	}
    	
    	list<Account> crmEntities = new list<Account>();
    	Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CRM Registered Entity').getRecordTypeId();
    	for(Account acc : [Select id, Name, Entity_Id__c, Entity_Status__c, Registration_Date__c, License_Expiry_Date__c, Category__c from Account 
    				where Entity_Id__c IN:eids and Entity_Id__c NOT IN:existingCRMEntities and Record_Type_Name__c = 'ADGM_Registered_Company'])
    	{
    		Account ac = new Account();
    		ac.Name 					= acc.Name;
    		ac.CRM_Entity_Id__c 		= acc.Entity_Id__c;
    		ac.Entity_Status__c 		= acc.Entity_Status__c;
    		ac.Registration_Date__c 	= acc.Registration_Date__c;
    		ac.License_Expiry_Date__c 	= acc.License_Expiry_Date__c;
    		ac.AccountSource			= 'Client Approaching Mubadala/Business Centre';
    		ac.Lead_Category__c 		= 'Retail';
    		ac.Main_Sector__c			= 'Retail';
    		//ac.Sector__c				= 'test'; // TBD
    		ac.Recordtypeid				= accRecordTypeId;
    		
    		crmEntities.add(ac);
    	}
    	if(!crmEntities.isEmpty()){
    		insert crmEntities;
    	}
    }
    
    @future
    public static void updateCRMRegEntityStatus(set<string> accids)
    {
        map<string,Account> crmRegEntities = new map<string,Account>();
        list<Account> updateacclist = new list<Account>();
        for(Account acc : [Select id,CRM_Entity_Id__c from Account where CRM_Entity_Id__c IN:accids and Record_Type_Name__c = 'ADGM_CRM']){
            crmRegEntities.put(acc.CRM_Entity_Id__c, acc);
        }
        
        for(Account acc : [Select id,Entity_Id__c,Name,/*Previous_Name__c,*/Entity_Status__c,License_Expiry_Date__c,Registration_Date__c  from Account where Entity_Id__c IN:accids ]){
            if(crmRegEntities.containsKey(acc.Entity_Id__c)){
                Account a           = crmRegEntities.get(acc.Entity_Id__c);
                a.Name              		= acc.Name;
                //a.Previous_Name__c  		= acc.Previous_Name__c;
                a.Entity_Status__c  		= acc.Entity_Status__c;
                a.Registration_Date__c  	= acc.Registration_Date__c;
                a.License_Expiry_Date__c  	= acc.License_Expiry_Date__c;
                updateacclist.add(a);
            }
        }
        if(!updateacclist.isEmpty()){
            update updateacclist;
        } 
    }
}