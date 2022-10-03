public without sharing class BusinessActivityTriggerHandler 
{
	public static void Trigger_AI(list<Business_Activity__c> triggernew)
	{
		set<id> acclist = new set<id>();
	    for(Business_Activity__c ba : triggernew)
	    {
	    	if(ba.Data_Pushed_to_DED__c == true && ba.DED_Status__c == 'Current'){
	    		acclist.add(ba.Entity__c);
	    	}
	    }
	    if(!acclist.isEmpty()){
	    	updateAccounts(acclist);
	    }
	}
	@future
	public static void updateAccounts(set<id> accids)
	{
		list<Account> aclist = new list<Account>();
		for(Id ids : accids){
			Account ac = new Account(id=ids,ModifyBLFZED__c=true);
			aclist.add(ac);
		}
		if(!aclist.isEmpty()){
	    	update aclist;
	    }
	}
}