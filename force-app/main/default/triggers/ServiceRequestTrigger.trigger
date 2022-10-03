trigger ServiceRequestTrigger on HexaBPM__Service_Request__c(after insert,before insert,before update,after update) {
    if(trigger.isInsert && trigger.isBefore)
        ServiceRequestTriggerHandler.Execute_BI(trigger.new);
    
    if(trigger.isInsert && trigger.isAfter)
        ServiceRequestTriggerHandler.Execute_AI(trigger.new);
        
    if(trigger.isUpdate && trigger.isBefore){
        if(RecursionUtil.srTriggerCheck == false){
            RecursionUtil.srTriggerCheck = true;
            ServiceRequestTriggerHandler.Execute_BU(trigger.oldmap,trigger.new);
        }
    }
    if(trigger.isUpdate && trigger.isAfter){
        ServiceRequestTriggerHandler.Execute_AU(trigger.oldmap,trigger.new);
    }
}