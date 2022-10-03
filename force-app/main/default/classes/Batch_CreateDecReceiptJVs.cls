global without sharing class Batch_CreateDecReceiptJVs implements Database.Batchable<sObject>{
    
    global List<sObject> start(Database.BatchableContext BC){
        
        
        List<Receipt__c> lstRecords = new List<Receipt__c>();
        for(Receipt__c objJH : [SELECT Id,Name,Payment_Currency__c,Amount__c,GL_Date__c,Entity__r.Operating_unit__r.OU_Abbreviation__c, Entity__r.Operating_unit__r.Entity_Code__c,Entity__c, 
                               Entity__r.Operating_unit__r.Operating_Unit_Name__c,Conversion_Rate__c,Entity__r.Name FROM Receipt__c 
                                WHERE GL_Date__c = LAST_MONTH AND Oracle_Receipt_Id__c = '' AND Receipt_Type__c != 'Fund Transfer' AND Status__c IN ('Success', 'Approved') AND Journal_Created__c = false]){
            lstRecords.add(objJH);    
        }
        return lstRecords;
    }
    
    global void execute(Database.BatchableContext BC,List<Receipt__c> lstRecords){
        for(Receipt__c objJH : lstRecords){
            
            //BM_JournalEntryEngine.receiptCreationJournal(new List<Id>{objJH.Id});
            List<Journal_Entry__c> journalsToInsert = new List<Journal_Entry__c>();
            Map<String,String> jeAccounts = new Map<String,String>{'Cash' => 'Debit','Unapplied'=> 'Credit'};
                Map<String, Map<String,GL_Combination_Setting__c>> glCombinationMap = new Map<String, Map<String,GL_Combination_Setting__c>>{'AED' => new Map<String,GL_Combination_Setting__c>(), 'USD' => new Map<String,GL_Combination_Setting__c>()};
                    for(GL_Combination_Setting__c eachGLCombinaton : [SELECT Id,Account_Type__c,Code__c,Journal_Entry_Account__c,Lookup_Code_Meaning__c,Payment_Currency__c FROM GL_Combination_Setting__c WHERE Related_Object__c INCLUDES('Receipt') AND Active__c = true AND Journal_Entry_Account__c IN : jeAccounts.keySet()]){
                        if(eachGLCombinaton.Payment_Currency__c.contains('AED')){glCombinationMap.get('AED').put(eachGLCombinaton.Journal_Entry_Account__c, eachGLCombinaton);
                                                                                }
                        if(eachGLCombinaton.Payment_Currency__c.contains('USD')){glCombinationMap.get('USD').put(eachGLCombinaton.Journal_Entry_Account__c, eachGLCombinaton);
                                                                                }
                    }
            //sp = Database.setSavepoint();
            Map<String, Journal_Header__c> journalHeaderMap = new Map<String, Journal_Header__c>();
            Map<String, List<Journal_Entry__c>> journalEntryMap = new Map<String, List<Journal_Entry__c>>();
            Journal_Header_Running_Number__c headerRunningNumber = Journal_Header_Running_Number__c.getValues('Next Running Number');
            Integer runningNumber = Integer.valueOf(headerRunningNumber.running_Number__c);
            
            for(Receipt__c eachReceipt : lstRecords){
                                              
                                              Journal_Header__c jhObj = new Journal_Header__c();
                                              jhObj.Name = 'JV' + '-' + runningNumber;
                                              jhObj.Transaction_Type__c = 'Receipts';
                                              jhObj.Receipt__c = eachReceipt.Id;
                                              jhObj.Reference_Id__c = eachReceipt.Id;
                                              jhObj.Reference_Name__c = eachReceipt.Name;
                                              jhObj.Entity_Name__c = eachReceipt.Entity__r.Name;
                                              jhObj.Account__c = eachReceipt.Entity__c;
                                              jhObj.GL_Date__c = eachReceipt.GL_Date__c;
                                              jhObj.Sync_Not_Required__c = true;
                                              journalHeaderMap.put(jhObj.Name, jhObj);
                                              
                                              runningNumber++;
                                              Integer count = 1;
                                              
                                              for(String eachAcc : jeAccounts.keyset()){                    
                                                  Journal_Entry__c je = new Journal_Entry__c(Receipt__c = eachReceipt.Id, Account__c = eachAcc, GL_Date__c = eachReceipt.GL_Date__c);
                                                  je.Name = jhObj.Name + '-' + count;
                                                  je.Entity__c = eachReceipt.Entity__r.Operating_unit__r.Entity_Code__c;
                                                  je.Entity_Description__c = eachReceipt.Entity__r.Operating_unit__r.Operating_Unit_Name__c;
                                                  je.Account_Segment__c = glCombinationMap.get(eachReceipt.Payment_Currency__c).get(eachAcc).Code__c;
                                                  je.Account_Segment_Description__c = glCombinationMap.get(eachReceipt.Payment_Currency__c).get(eachAcc).Lookup_Code_Meaning__c;
                                                  je.Operating_Unit_Name__c = eachReceipt.Entity__r.Operating_unit__r.OU_Abbreviation__c;
                                                  je.currency__c = eachReceipt.Payment_Currency__c;
                                                  je.conversion_rate__c = eachReceipt.conversion_rate__c;
                                                  if(jeAccounts.get(eachAcc) == 'Debit'){je.Debit_OC__c = eachReceipt.Amount__c;} 
                                                  else if(jeAccounts.get(eachAcc) == 'Credit'){je.Credit_OC__c = eachReceipt.Amount__c;} 
                                                  List<Journal_Entry__c> tempLst = journalEntryMap.get(jhObj.Name);
                                                  if(tempLst == NULL){tempLst = new List<Journal_Entry__c>();}
                                                  tempLst.add(je);journalEntryMap.put(jhObj.Name, tempLst);count++;
                                              }
                                          }
            if(!journalHeaderMap.keySet().isEmpty()){
                INSERT journalHeaderMap.values();
                
                objJH.Journal_Created__c = true;
                UPDATE objJH;
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