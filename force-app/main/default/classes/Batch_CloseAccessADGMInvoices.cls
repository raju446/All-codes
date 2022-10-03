global without sharing class Batch_CloseAccessADGMInvoices implements Database.Batchable<sObject>{
    
    global List<sObject> start(Database.BatchableContext BC){
        if(!test.isRunningTest()){
        	return [SELECT Id, Entity__c, Total_Invoice_Amount_Oc__c, Invoice_Balance__c, GL_Date__c FROM Invoice__c WHERE Service_Request__c != '' AND GL_Date__c != THIS_YEAR AND Invoice_Balance__c > 0 AND Oracle_Invoice_Id__c != ''];    
        }else{
            return [SELECT Id, Entity__c, Total_Invoice_Amount_Oc__c, GL_Date__c, Invoice_Balance__c FROM Invoice__c];
        }
        
    }
    
    global void execute(Database.BatchableContext BC,List<Invoice__c> invLst){
        Invoice__c invObj = invLst[0];
        List<Receipt__c> rctLst = [SELECT Id, Remaning_Amount__c FROM Receipt__c WHERE GL_Date__c != THIS_YEAR AND Entity__c = :invObj.Entity__c AND Remaning_Amount__c > 0 AND Oracle_Receipt_Id__c != '' AND Payment_Currency__c = 'AED' AND Status__c = 'Success' AND Is_Reversed__c = False];
        List<Related_Invoice_Receipt__c> appLst = new List<Related_Invoice_Receipt__c>();
        Decimal invoiceBalance = invObj.Invoice_Balance__c;
        for(Receipt__c rctObj : rctLst){
            if(rctObj.Remaning_Amount__c >= invObj.Invoice_Balance__c){
                Related_Invoice_Receipt__c applicationObj = new Related_Invoice_Receipt__c(Applied__c = true);applicationObj.Journal_Created__c = true;applicationObj.Invoice__c = invObj.Id;applicationObj.GL_Date__c = Date.newInstance(2021, 12, 31);applicationObj.Receipt__c = rctObj.Id;applicationObj.Applied_Date__c = Date.newInstance(2021, 12, 31);applicationObj.Amount_Applied__c = invoiceBalance; applicationObj.ORACLE_Applied_Amount__c = invoiceBalance;applicationObj.Direction__c = 'From Invoice To Receipt';appLst.add(applicationObj);
                invoiceBalance = 0;
                break;
            }else if(rctObj.Remaning_Amount__c < invObj.Invoice_Balance__c){
                Related_Invoice_Receipt__c applicationObj = new Related_Invoice_Receipt__c(Applied__c = true);
                applicationObj.Journal_Created__c = true;
                applicationObj.Invoice__c = invObj.Id;
                applicationObj.Receipt__c = rctObj.Id;
                applicationObj.Applied_Date__c = Date.newInstance(2021, 12, 31);
                applicationObj.GL_Date__c = Date.newInstance(2021, 12, 31);
                applicationObj.Amount_Applied__c = rctObj.Remaning_Amount__c;
                applicationObj.ORACLE_Applied_Amount__c = rctObj.Remaning_Amount__c;
                applicationObj.Direction__c = 'From Invoice To Receipt';
                invoiceBalance = invoiceBalance - rctObj.Remaning_Amount__c;
                appLst.add(applicationObj);
            }
        }
        system.debug('invoiceBalance==>>' + invoiceBalance);
        system.debug('appLst==>>' + appLst.size());
        system.debug('appLst==>>' + appLst);
        if(appLst.size() > 0){
            invObj.Invoice_Balance__c = invoiceBalance;
            update invObj;
            insert appLst;
            List<Id> applicationIds = new List<Id>(); 
            for(Related_Invoice_Receipt__c application : appLst){
                applicationIds.add(application.Id);
            }
            BM_JournalEntryEngine.receiptApplicationJournalLines(applicationIds);
        }else{
            /*inv.Oracle_Response_Message__c = 'Enough funds are not available';
            UPDATE inv;*/
        }
    }
    
    global void finish(Database.BatchableContext BC){ 
        
    }
}