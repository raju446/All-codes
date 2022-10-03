global without sharing class Batch_CreDecAccessAppliAndJournalLine implements Database.Batchable<sObject>{
    global List<sObject> start(Database.BatchableContext BC){
        return [SELECT Id,Service_Request__c,Invoice_Balance__c,Name,Entity__r.Oracle_Site_Id__c,Description__c,Invoice_Type__c,Invoice_Date__c,GL_Date__c,Entity__r.Oracle_Party_Id__c,Invoice_Class__c,Oracle_Invoice_Type__c,Oracle_GL_Date__c, Converted_Invoice_Balance__c,Entity__c,
                                      Payment_Term__c,Payment_Currency__c,Status__c,Invoice_Amount__c,Tax_Amount__c,Discount_Amount__c,Discount_Tax_Amount__c,Converted_Discount_Amount__c,Converted_Discount_Tax_Amount__c,Converted_Invoice_Amount__c,Converted_Tax_Amount__c FROM Invoice__c WHERE Service_Request__c != '' AND (Invoice_Date__c = LAST_MONTH OR GL_Date__c = LAST_MONTH) AND Status__c = 'Invoiced' AND Invoice_Balance__c > 0];
        //return [SELECT Id, Service_Request__c, Entity__c, Description__c, Invoice_Date__c, GL_Date__c, RecordType.Name, Total_Invoice_Amount__c, Status__c FROM Invoice__c WHERE Service_Request__c != '' AND (Invoice_Date__c = LAST_MONTH OR GL_Date__c = LAST_MONTH) AND Status__c = 'Invoiced'];
    }
    
    global void execute(Database.BatchableContext BC,List<Invoice__c> invList){
        for(Invoice__c inv : invList){
            List<Related_Invoice_Receipt__c> recordsToInsert = new List<Related_Invoice_Receipt__c>();
            Decimal invoiceBalance = inv.Invoice_Balance__c;
            Map<Id, Receipt__c> updateReceiptMap = new Map<Id, Receipt__c>();
            
            List<Related_Invoice_Receipt__c> applicationLst = new List<Related_Invoice_Receipt__c>();
            for(Receipt__c eachReceipt : [SELECT Id, Receipt_Reference__c,Transaction_Reference__c,Authorization_Code__c,EFT_Reference_No__c, Receipt_Balance__c FROM Receipt__c
                                          WHERE Receipt_Balance__c > 0 AND Payment_Currency__c = 'AED' AND Entity__c = :inv.Entity__c AND Journal_Created__c = true]){
                                              
                                              if(invoiceBalance < eachReceipt.Receipt_Balance__c){
                                                  Related_Invoice_Receipt__c applicationObj = new Related_Invoice_Receipt__c(Applied__c = true); 
                                                  applicationObj.Invoice__c = inv.Id;
                                                  applicationObj.Receipt__c = eachReceipt.Id;
                                                  applicationObj.Applied_Date__c = System.today();
                                                  applicationObj.Amount_Applied__c = invoiceBalance; 
                                                  applicationObj.ORACLE_Applied_Amount__c = invoiceBalance;
                                                  applicationObj.ORACLE_Unapplied_Amount__c = eachReceipt.Receipt_Balance__c - invoiceBalance;
                                                  applicationObj.Oracle_Converted_Applied_Amount__c = invoiceBalance; 
                                                  applicationObj.Oracle_Converted_UnApplied_Amount__c = eachReceipt.Receipt_Balance__c - invoiceBalance;
                                                  applicationObj.Direction__c = 'From Invoice To Receipt';
                                                  invoiceBalance = 0; 
                                                  applicationLst.add(applicationObj);
                                                  break;
                                              }else if(invoiceBalance > eachReceipt.Receipt_Balance__c){ 
                                                  Related_Invoice_Receipt__c applicationObj = new Related_Invoice_Receipt__c(Applied__c = true);
                                                  applicationObj.Invoice__c = inv.Id;
                                                  applicationObj.Receipt__c = eachReceipt.Id;
                                                  applicationObj.Applied_Date__c = System.today();
                                                  applicationObj.Amount_Applied__c = eachReceipt.Receipt_Balance__c;
                                                  applicationObj.ORACLE_Applied_Amount__c = eachReceipt.Receipt_Balance__c;
                                                  applicationObj.ORACLE_Unapplied_Amount__c = 0; 
                                                  applicationObj.Oracle_Converted_Applied_Amount__c = eachReceipt.Receipt_Balance__c;
                                                  applicationObj.Oracle_Converted_UnApplied_Amount__c = 0;
                                                  applicationObj.Direction__c = 'From Invoice To Receipt';
                                                  invoiceBalance = invoiceBalance - eachReceipt.Receipt_Balance__c;
                                                  applicationLst.add(applicationObj);
                                              }                          
                                          }
            system.debug('--->'+applicationLst);
            if(applicationLst.size() > 0){
                inv.Invoice_Balance__c = invoiceBalance;
                inv.Oracle_Response_Message__c = 'Invoice Applied to Receipt Successfully';
                update inv;
                //BM_JournalEntryEngine.invoiceCreationJournal(new List<Id>{inv.Id});
                insert applicationLst;
                /*List<Id> applicationIds = new List<Id>(); 
                for(Related_Invoice_Receipt__c application : applicationLst){
                    applicationIds.add(application.Id);
                }*/
                //BM_JournalEntryEngine.receiptApplicationJournalLines(applicationIds);
            } else{
                inv.Oracle_Response_Message__c = 'Enough funds are not available';
                UPDATE inv;
                //BM_JournalEntryEngine.invoiceCreationJournal(new List<Id>{inv.Id});
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC){}
}