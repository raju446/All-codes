trigger SRDocTrigger on HexaBPM__SR_Doc__c (before insert,after update) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            SRDocTriggerHandler.generateRunningNumber(trigger.new); // passes the list of sr docs to the trigger handler
        }
    }
    if(trigger.isUpdate && trigger.isAfter)
    {
        SRDocTriggerHandler.sendEmailofIAApprovalorRejection(trigger.new,trigger.oldmap);
    }
}