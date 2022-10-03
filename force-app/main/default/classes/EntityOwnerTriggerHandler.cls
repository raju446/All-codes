public without sharing class EntityOwnerTriggerHandler 
{
	public static void Execute_BI(list<Entity_Owner__c> TriggerNew)
	{
		mapAccountids(TriggerNew);
	}
	public static void Execute_BU(list<Entity_Owner__c> TriggerNew)
	{
		mapAccountids(TriggerNew);
	}
	public static void mapAccountids(list<Entity_Owner__c> TriggerNew)
	{
		set<string> acctids = new set<string>();
		map<string,id> mapaccids = new map<string,id>();
		Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company').getRecordTypeId();
		for(Entity_Owner__c eo : TriggerNew)
    	{
    		if(eo.Entity__c == null)
    			acctids.add(eo.EntityIdentifier__c);
    	}
    	system.debug('==acctids=='+acctids.size());
    	for(Account acc: [Select id,Entity_Id__c from Account where Entity_Id__c IN:acctids and Recordtypeid=:accRecordTypeId]){
    		mapaccids.put(acc.Entity_Id__c,acc.id);
    	}
    	
    	if(!mapaccids.isEmpty())
    	{
	    	for(Entity_Owner__c eo : TriggerNew)
	    	{
	    		if(mapaccids.containsKey(eo.EntityIdentifier__c)){
	    			eo.Entity__c = mapaccids.get(eo.EntityIdentifier__c);
	    		}
	    	}
    	}
	}
    public static void Execute_AI(list<Entity_Owner__c> TriggerNew,map<Id,Entity_Owner__c> TriggerOldMap)
    {
    	map<id,Account> acclist = new map<id,Account>();
    	for(Entity_Owner__c eo : TriggerNew)
    	{
    		if(eo.Data_Pushed_to_DED__c == true){
    			Account acc = new Account(Id=eo.Entity__c);
    			acc.ModifyBLFZED__c = true;
    			acclist.put(eo.Entity__c, acc);
    		}
    	}
    	if(!acclist.isEmpty()){
    		update acclist.values();
    	}
    }
    public static void Execute_AU(list<Entity_Owner__c> TriggerNew,map<Id,Entity_Owner__c> TriggerOldMap,map<Id,Entity_Owner__c> TriggerNewMap)
    {
    	map<id,Account> acclist = new map<id,Account>();
    	for(Entity_Owner__c eo : TriggerNew)
    	{
    		system.debug('========='+eo);
    		if(eo.Data_Pushed_to_DED__c == true && 
    		(eo.Owner_Full_Name_En__c != TriggerOldMap.get(eo.id).Owner_Full_Name_En__c ||
    		eo.Relationship_Status__c != TriggerOldMap.get(eo.id).Relationship_Status__c || 
    		eo.Relationship_Type__c != TriggerOldMap.get(eo.id).Relationship_Type__c
    		))
    		{
    			Account acc = new Account(Id=eo.Entity__c); 
    			acc.ModifyBLFZED__c = true;
    			acclist.put(eo.Entity__c, acc);
    		}
    	}
    	if(!acclist.isEmpty()){
    		update acclist.values();
    	} 
    }
    
}