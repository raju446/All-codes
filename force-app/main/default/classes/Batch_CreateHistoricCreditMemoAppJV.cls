global without sharing class Batch_CreateHistoricCreditMemoAppJV implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global List<sObject> start(Database.BatchableContext BC){
        return [SELECT Id,Name,Amount__c,Tax_Amount__c,Service_Type__c,Revenue_Type__c,Department__c,Amount_AED__c,Tax_Amount_AED__c,Tax__c,Is_Discount__c,GL_Date__c ,
                                                          Invoice__r.Entity__r.Operating_unit__r.Entity_Code__c, Invoice__r.Entity__r.Operating_unit__r.Operating_Unit_Name__c, Invoice__r.payment_currency__c,
                                                          Invoice__r.conversion_rate__c, Invoice__r.Entity__r.Operating_unit__r.OU_Abbreviation__c,Invoice__r.Entity__r.Name,Invoice__r.Id 
                                                          FROM Invoice_Line_Item__c WHERE Related_Credit_Memo__c != '' AND Is_CM_Application__c = true AND Journal_Created__c= false];
        
    }
    global void execute(Database.BatchableContext BC,List<Invoice_Line_Item__c> applicationList){
        Invoice_Line_Item__c invLineObj = applicationList[0];
        invLineObj.Journal_Created__c = true;
        UPDATE invLineObj;
        
        Map<String,String> jeAccountsReceiptApplication;
            
        jeAccountsReceiptApplication = new Map<String,String>{'Unapplied'=> 'Debit','Receivable'=> 'Credit'};
            
        set<String> jeAccountsKeyset = jeAccountsReceiptApplication.keySet();
        Map<String, GL_Combination_Setting__c> glCombinationMap = new Map<String, GL_Combination_Setting__c>();
        for(GL_Combination_Setting__c eachGLCombinaton : [SELECT Id,Account_Type__c,Code__c,Journal_Entry_Account__c,Lookup_Code_Meaning__c,Payment_Currency__c FROM GL_Combination_Setting__c WHERE Journal_Entry_Account__c IN : jeAccountsKeyset AND Active__c = true]){
            glCombinationMap.put(eachGLCombinaton.Journal_Entry_Account__c, eachGLCombinaton);
        }
            
        Map<String, Journal_Header__c> journalHeaderMap = new Map<String, Journal_Header__c>();
        Map<String, List<Journal_Entry__c>> journalEntryMap = new Map<String, List<Journal_Entry__c>>();
        Journal_Header_Running_Number__c headerRunningNumber = Journal_Header_Running_Number__c.getValues('Next Running Number');
        Integer runningNumber = Integer.valueOf(headerRunningNumber.running_Number__c);
        
        for(Invoice_Line_Item__c applicationItem : applicationList){
            Journal_Header__c jhObj = new Journal_Header__c();
            jhObj.Name = 'JV-' + runningNumber;
            jhObj.Transaction_Type__c = 'Apply CreditMemo';
            jhObj.Invoice__c = applicationItem.Invoice__r.Id;
            jhObj.Invoice_Line_Item__c = applicationItem.Id;
            jhObj.Reference_Id__c = applicationItem.Id;
            jhObj.Reference_Name__c = applicationItem.Name;
            jhObj.Entity_Name__c = applicationItem.Invoice__r.Entity__r.Name;
            jhObj.Account__c = applicationItem.Invoice__r.Entity__c;
            jhObj.GL_Date__c = applicationItem.GL_Date__c;
            jhObj.Sync_Not_Required__c = true;
            journalHeaderMap.put(jhObj.Name, jhObj);
            
            runningNumber++;
            Integer count = 1;
            for (String transactionType : jeAccountsReceiptApplication.keySet()) {
                
                Journal_Entry__c je = new Journal_Entry__c(Credit_Memo_Application__c = applicationItem.Id, Account__c = transactionType, GL_Date__c = applicationItem.GL_Date__c);
                je.Name = jhObj.Name + '-' + count;
                je.Entity__c = applicationItem.Invoice__r.Entity__r.Operating_unit__r.Entity_Code__c;
                je.Entity_Description__c = applicationItem.Invoice__r.Entity__r.Operating_unit__r.Operating_Unit_Name__c;
                je.Operating_Unit_Name__c = applicationItem.Invoice__r.Entity__r.Operating_unit__r.OU_Abbreviation__c;
                je.Account_Segment__c = glCombinationMap.get(transactionType).Code__c;
                je.Account_Segment_Description__c = glCombinationMap.get(transactionType).Lookup_Code_Meaning__c;
                je.currency__c = applicationItem.Invoice__r.payment_currency__c;
                je.conversion_rate__c = applicationItem.Invoice__r.conversion_rate__c;
                je.Tax_Rate_Code__c = applicationItem.Tax__c;
                if(jeAccountsReceiptApplication.get(transactionType) == 'Debit'){
                    je.Debit_OC__c = (applicationItem.Amount__c * -1);je.Credit_OC__c = 0;
                } else if(jeAccountsReceiptApplication.get(transactionType) == 'Credit'){
                    je.Credit_OC__c = (applicationItem.Amount__c * -1);je.Debit_OC__c = 0;
                } 
                List<Journal_Entry__c> tempLst = journalEntryMap.get(jhObj.Name);
                if(tempLst == NULL){tempLst = new List<Journal_Entry__c>(); }
                tempLst.add(je);journalEntryMap.put(jhObj.Name, tempLst);count++;
            }
        }
        if(!journalHeaderMap.keySet().isEmpty()){
            INSERT journalHeaderMap.values();
            
            List<Journal_Entry__c> insertJournalEntries = new List<Journal_Entry__c>();
            for(String key : journalEntryMap.keySet()){
                for(Journal_Entry__c jeObj : journalEntryMap.get(key)){
                    jeObj.Journal_Header__c = journalHeaderMap.get(key).Id;
                    insertJournalEntries.add(jeObj);
                }
            }
            INSERT insertJournalEntries;
            
            Journal_Header_Running_Number__c headerRunningNumber1 = Journal_Header_Running_Number__c.getValues('Next Running Number');
            headerRunningNumber1.running_Number__c = runningNumber;
            UPDATE headerRunningNumber1;
        }
        
    }
    
    global void finish(Database.BatchableContext BC){ 
    }
}