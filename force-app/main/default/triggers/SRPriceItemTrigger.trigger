/*
    Author      : Kim Noceda
    Date        : 14-Jan-2018
    Description : Trigger for HexaBPM__SR_Price_Item__c
    --------------------------------------------------------------------------------------
*/
trigger SRPriceItemTrigger on HexaBPM__SR_Price_Item__c (before insert,before update, after insert, after update, before delete) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            SRPriceItemTriggerHandler.Execute_BI(trigger.new);
        }
        if(trigger.isUpdate){
            SRPriceItemTriggerHandler.Execute_BU(trigger.newmap,trigger.oldmap);
        }
        
    }
    if(trigger.isAfter){
        if(trigger.isInsert){
            SRPriceItemTriggerHandler.Execute_AI(trigger.new);
        }
        //------------------Code added during BM Development--------------------------
        if(trigger.isUpdate){
            SRPriceItemTriggerHandler.Execute_AU(trigger.newmap,trigger.oldmap);
        }
    }
}