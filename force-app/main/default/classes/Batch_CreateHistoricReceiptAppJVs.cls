global without sharing class Batch_CreateHistoricReceiptAppJVs implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global List<sObject> start(Database.BatchableContext BC){
        List<Related_Invoice_Receipt__c> lstRecords = new List<Related_Invoice_Receipt__c>();
        for(Related_Invoice_Receipt__c objJH : [SELECT Id, Name,Invoice__c, Receipt__c, Receipt__r.Receipt_Balance__c, Receipt__r.Entity__r.Operating_unit__r.Entity_Code__c, GL_Date__c,
                                                Oracle_Applied_Amount__c, Receipt__r.Entity__r.Operating_unit__r.Operating_Unit_Name__c, Receipt__r.Entity__r.Operating_unit__r.OU_Abbreviation__c, 
                                                Receipt__r.Payment_Currency__c, receipt__r.Conversion_Rate__c,Receipt__r.Entity__r.Name FROM Related_Invoice_Receipt__c 
                                                WHERE Journal_Created__c = false AND Receipt__r.Is_Reversed__c = false AND Receipt__r.Oracle_Receipt_Id__c != '' LIMIT 10000]){
                                                    lstRecords.add(objJH);    
                                                }
        return lstRecords;
    }
    global void execute(Database.BatchableContext BC,List<Related_Invoice_Receipt__c> lstRecords){
        //BM_JournalEntryEngine.receiptApplicationJournalLines(new List<Id>{objJH.Id});
        
        List<Journal_Entry__c> journalsToInsert = new List<Journal_Entry__c>();
        List<Related_Invoice_Receipt__c> applicationList = lstRecords;
        
        Map<String,String> jeAccountsReceiptApplication;
        
        jeAccountsReceiptApplication = new Map<String,String>{'Unapplied'=> 'Debit','Receivable'=> 'Credit'};
            
            set<String> jeAccountsKeyset = jeAccountsReceiptApplication.keySet();
        Map<String, GL_Combination_Setting__c> glCombinationMap = new Map<String, GL_Combination_Setting__c>();
        for(GL_Combination_Setting__c eachGLCombinaton : [SELECT Id,Account_Type__c,Code__c,Journal_Entry_Account__c,Lookup_Code_Meaning__c,Payment_Currency__c FROM GL_Combination_Setting__c WHERE Journal_Entry_Account__c IN : jeAccountsKeyset AND Active__c = true]){
            glCombinationMap.put(eachGLCombinaton.Journal_Entry_Account__c, eachGLCombinaton);
        }
        
        if(!applicationList.isEmpty()){
            
            Map<String, Journal_Header__c> journalHeaderMap = new Map<String, Journal_Header__c>();
            Map<String, List<Journal_Entry__c>> journalEntryMap = new Map<String, List<Journal_Entry__c>>();
            Journal_Header_Running_Number__c headerRunningNumber = Journal_Header_Running_Number__c.getValues('Next Running Number');
            Integer runningNumber = Integer.valueOf(headerRunningNumber.running_Number__c);
            List<Related_Invoice_Receipt__c> receptApplicaLst = new List<Related_Invoice_Receipt__c>();
            for(Related_Invoice_Receipt__c applicationItem : applicationList){
                receptApplicaLst.add(new Related_Invoice_Receipt__c(Id = applicationItem.Id, Journal_Created__c = true));
                
                Journal_Header__c jhObj = new Journal_Header__c();
                jhObj.Name = 'JV-' + runningNumber;
                jhObj.Transaction_Type__c = 'Apply Receipt';
                jhObj.related_Invoice_Receipt__c = applicationItem.Id;
                jhObj.Reference_Id__c = applicationItem.Id;
                jhObj.Reference_Name__c = applicationItem.Name;
                jhObj.Entity_Name__c = applicationItem.Receipt__r.Entity__r.Name;
                jhObj.Account__c = applicationItem.Receipt__r.Entity__c;
                jhObj.GL_Date__c = applicationItem.GL_Date__c;
                jhObj.Sync_Not_Required__c = true;
                journalHeaderMap.put(jhObj.Name, jhObj);
                
                runningNumber++;
                Integer count = 1;
                for (String transactionType : jeAccountsReceiptApplication.keySet()) {
                    
                    Journal_Entry__c je = new Journal_Entry__c(Related_Invoice_Receipt__c = applicationItem.Id, Account__c = transactionType, GL_Date__c = applicationItem.GL_Date__c);
                    je.Name = jhObj.Name + '-' + count;
                    je.Entity__c = applicationItem.Receipt__r.Entity__r.Operating_unit__r.Entity_Code__c;
                    je.Entity_Description__c = applicationItem.Receipt__r.Entity__r.Operating_unit__r.Operating_Unit_Name__c;
                    je.Account_Segment__c = glCombinationMap.get(transactionType).Code__c;
                    je.Account_Segment_Description__c = glCombinationMap.get(transactionType).Lookup_Code_Meaning__c;
                    je.Operating_Unit_Name__c = applicationItem.Receipt__r.Entity__r.Operating_unit__r.OU_Abbreviation__c;
                    je.currency__c = applicationItem.receipt__r.payment_currency__c;
                    je.conversion_rate__c = applicationItem.receipt__r.conversion_rate__c;
                    if(jeAccountsReceiptApplication.get(transactionType) == 'Debit'){je.Debit_OC__c = applicationItem.Oracle_Applied_Amount__c;} 
                    else if(jeAccountsReceiptApplication.get(transactionType) == 'Credit'){je.Credit_OC__c = applicationItem.Oracle_Applied_Amount__c;} 
                    List<Journal_Entry__c> tempLst = journalEntryMap.get(jhObj.Name);
                    if(tempLst == NULL){tempLst = new List<Journal_Entry__c>();}
                    tempLst.add(je); journalEntryMap.put(jhObj.Name, tempLst);count++;
                }
            }
            if(!receptApplicaLst.isEmpty()){
                UPDATE receptApplicaLst;
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
    }
    global void finish(Database.BatchableContext BC){ 
    }
    
}