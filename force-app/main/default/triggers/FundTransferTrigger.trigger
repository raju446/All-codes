trigger FundTransferTrigger on Fund_Transfer__c (after insert, after update) {
    if(Trigger.isUpdate){
        if(Trigger.isAfter){
            FundTranferTriggerHandler.handleAU(trigger.new,trigger.oldmap);
        }
    }
    
}