/*
@Author : Azmath.
@Description : These trigger actions are used to identify the DED services.
*/

trigger EntityOwnerTrigger on Entity_Owner__c (after insert, after update,before insert,before update) 
{
	if(system.label.RunEntityOwnerTrigger == 'True')
	{
	    if(trigger.isBefore)
	    {
	        if(trigger.isInsert){
	            EntityOwnerTriggerHandler.Execute_BI(trigger.new);
	        }
	        if(trigger.isUpdate){
	            EntityOwnerTriggerHandler.Execute_BU(trigger.new);
	        }
	    }
	    else
	    {
	        if(trigger.isInsert){
	            EntityOwnerTriggerHandler.Execute_AI(trigger.new,trigger.oldmap);
	        }
	        if(trigger.isUpdate){
	            EntityOwnerTriggerHandler.Execute_AU(trigger.new,trigger.oldmap,trigger.newmap);
	        }
	    }
	}
}