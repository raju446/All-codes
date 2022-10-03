/****
Name: RelatedInvoiceReceiptTrigger
Description: Trigger on application

****/

trigger RelatedInvoiceReceiptTrigger on Related_Invoice_Receipt__c (Before UPDATE, After INSERT, After UPDATE) {

    if(trigger.isAfter){
        if(trigger.isInsert){
            Map<Id, Related_Invoice_Receipt__c>  applicationMap = new Map<Id, Related_Invoice_Receipt__c>();
            List<String> appIds = new List<String>();
            for(Related_Invoice_Receipt__c appObj : Trigger.New){
                if(!appObj.Journal_Created__c && appObj.Amount_Applied__c > 0 && !appObj.Applied__c){ 
                    applicationMap.put(appObj.Id, appObj);
                }
            }
            RelatedInvoiceReceiptTriggerHelper.updateAmountANDCreateJournalEntries(applicationMap);
        }
    }
    if(trigger.isAfter){
        if(trigger.isUpdate){
            RelatedInvoiceReceiptTriggerHelper.Execute_AU(trigger.new,trigger.oldmap);
        }
    }
}