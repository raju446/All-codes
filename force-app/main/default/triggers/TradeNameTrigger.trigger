/*
    Author      : Kim Noceda
    Date        : 08-Jan-2018
    Description : Trigger for Trade_Name__c
    --------------------------------------------------------------------------------------
*/
trigger TradeNameTrigger on Trade_Name__c (after insert, after update) {
    if(trigger.isAfter){
        if(trigger.isInsert){
            TradeNameTriggerHandler.SetPrimaryAsUnchecked(trigger.new, null, true);
            if(Label.Allow_CID_Approval_Trade == 'true'){
                TradeNameTriggerHandler.InitiateCIDApproval(trigger.new, null, true);
            }
        }else if(trigger.isUpdate){
            TradeNameTriggerHandler.SetPrimaryAsUnchecked(trigger.new, trigger.oldMap, false);
            if(Label.Allow_CID_Approval_Trade == 'true'){
                TradeNameTriggerHandler.InitiateCIDApproval(trigger.new, trigger.oldMap, false);
            }
        }
    }
}