global without sharing class Batch_CreateHistoricRefundJVs implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global List<sObject> start(Database.BatchableContext BC){
        return [SELECT Id, Name, Entity__c, Amount__c, Currency__c, Entity__r.Operating_unit__r.Entity_Code__c, Entity__r.Operating_unit__r.Operating_Unit_Name__c, 
                                          Entity__r.Operating_unit__r.OU_Abbreviation__c,Scenario__c, Receipt__c, Receipt__r.conversion_rate__c, Receipt__r.GL_Date__c, Credit_Memo__c, 
                                          Credit_Memo__r.conversion_rate__c, Credit_Memo__r.GL_Date__c,Entity__r.Name, Payment_Method__c FROM Refund__c WHERE Status__c = 'Processed' AND Journal_Created__c = false];
        
    }
    global void execute(Database.BatchableContext BC,List<Refund__c> refundList){
        Refund__c rfndObj = refundList[0];
        rfndObj.Journal_Created__c = true;
        UPDATE rfndObj;
        Map<String, Map<String, String>> refundJournaMapping = new  Map<String, Map<String, String>>{'Credit Memo' => new Map<String, String>{'Unapplied'=> 'Debit', 'Refund'=> 'Credit'}, 
                'Receipt generated but invoice not generated' => new Map<String, String>{'Unapplied'=> 'Debit', 'Refund'=> 'Credit'}};
                    
        set<String> jeAccountsKeyset = new set<String>{'Unapplied','Refund'};
        Map<String, GL_Combination_Setting__c> glCombinationMap = new Map<String, GL_Combination_Setting__c>();
        for(GL_Combination_Setting__c eachGLCombinaton : [SELECT Id,Account_Type__c,Code__c,Journal_Entry_Account__c,Lookup_Code_Meaning__c,Payment_Currency__c FROM GL_Combination_Setting__c WHERE Journal_Entry_Account__c IN : jeAccountsKeyset AND Active__c = true]){
            glCombinationMap.put(eachGLCombinaton.Journal_Entry_Account__c, eachGLCombinaton);
        }
        
        
        Map<String, Journal_Header__c> journalHeaderMap = new Map<String, Journal_Header__c>();
        Map<String, List<Journal_Entry__c>> journalEntryMap = new Map<String, List<Journal_Entry__c>>();
        Journal_Header_Running_Number__c headerRunningNumber = Journal_Header_Running_Number__c.getValues('Next Running Number');
        Integer runningNumber = Integer.valueOf(headerRunningNumber.running_Number__c);
        
        for(Refund__c refundObj : refundList){
            
            Journal_Header__c jhObj = new Journal_Header__c();
            jhObj.Name = 'JV-' + runningNumber;
            jhObj.Transaction_Type__c = 'Refund';
            jhObj.refund__c = refundObj.Id;
            jhObj.Reference_Id__c = refundObj.Id;
            jhObj.Reference_Name__c = refundObj.Name;
            jhObj.Entity_Name__c = refundObj.Entity__r.Name;
            jhObj.Account__c = refundObj.Entity__c;
            jhObj.GL_Date__c = refundObj.Receipt__c != null ? refundObj.Receipt__r.GL_Date__c : refundObj.Credit_Memo__r.GL_Date__c.date();
            if(refundObj.Payment_Method__c == 'Bank Transfer'){ jhObj.Sync_Not_Required__c = true; }
            
            journalHeaderMap.put(jhObj.Name, jhObj);
            
            runningNumber++;
            Integer count = 1;
            
            if(String.isNotBlank(refundObj.Scenario__c) && refundJournaMapping.containsKey(refundObj.Scenario__c)){
                for(String transactionType : refundJournaMapping.get(refundObj.Scenario__c).keySet()){
                    Journal_Entry__c je = new Journal_Entry__c(Refund__c = refundObj.Id, Account__c = transactionType, GL_Date__c = refundObj.Receipt__c != null ? refundObj.Receipt__r.GL_Date__c : refundObj.Credit_Memo__r.GL_Date__c.date());
                    je.Name = jhObj.Name + '-' + count;
                    je.Entity__c = refundObj.Entity__r.Operating_unit__r.Entity_Code__c;
                    je.Entity_Description__c = refundObj.Entity__r.Operating_unit__r.Operating_Unit_Name__c;
                    je.Account_Segment__c = glCombinationMap.get(transactionType).Code__c;
                    je.Account_Segment_Description__c = glCombinationMap.get(transactionType).Lookup_Code_Meaning__c;
                    je.currency__c = refundObj.currency__c;
                    je.Operating_Unit_Name__c = refundObj.Entity__r.Operating_unit__r.OU_Abbreviation__c;
                    je.conversion_rate__c = refundObj.Receipt__c != null ? refundObj.Receipt__r.Conversion_Rate__c : refundObj.Credit_Memo__r.Conversion_Rate__c;
                    if(refundJournaMapping.get(refundObj.Scenario__c).get(transactionType) == 'Debit'){je.Debit_OC__c = refundObj.Amount__c;
                                                                                                      } else if(refundJournaMapping.get(refundObj.Scenario__c).get(transactionType) == 'Credit'){je.Credit_OC__c = refundObj.Amount__c;
                                                                                                                                                                                                } 
                    List<Journal_Entry__c> tempLst = journalEntryMap.get(jhObj.Name);
                    if(tempLst == NULL){tempLst = new List<Journal_Entry__c>();}
                    tempLst.add(je);journalEntryMap.put(jhObj.Name, tempLst);count++;
                }
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