/*
    Author      : Durga Prasad
    Company		: PwC
    Date        : 17-Sep-2017
    Description : CaseTrigger
    -------------------------------------------------------------------------
*/
trigger CaseTrigger on Case(before insert,after insert,before update,after update) {
	if(trigger.isBefore){
	    if(trigger.isInsert)
	        CaseTriggerHandler.Execute_BI(Trigger.New);
	    if(trigger.isUpdate)
	        CaseTriggerHandler.Execute_BU(Trigger.New,Trigger.OldMap);
	}
	if(trigger.isAfter){
	    if(trigger.isInsert)
	        CaseTriggerHandler.Execute_AI(Trigger.New);
	    if(trigger.isUpdate)
	        CaseTriggerHandler.Execute_AU(Trigger.New,Trigger.OldMap);
	}
}