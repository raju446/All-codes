global class UpdateAllInvoicesBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        
        String query = '';
        if(!test.isRunningTest()){
            query = 'SELECT Id FROM Invoice__c WHERE Due_Days__c = null';    
        }else{
            query = 'SELECT Id FROM Invoice__c WHERE Due_Days__c != null';
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Invoice__c> invLst) {
        UPDATE invLst;
    }   
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}