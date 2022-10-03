global without sharing class Batch_CreateHistoricFTJVs implements Database.Batchable<sObject>{
    
    global List<sObject> start(Database.BatchableContext BC){
        List<Fund_Transfer__c> lstRecords = new List<Fund_Transfer__c>();
        for(Fund_Transfer__c objJH : [SELECT Name, From_Entity__c, To_Entity__c, Id, Reference_Receipt__c, From_Receipt__c, To_Receipt__c,
                                                      Reference_Receipt__r.conversion_rate__c, To_Receipt__r.conversion_rate__c, 
                                                      From_Currency__c, Amount__c, To_Currency__c, Scenario__c, Description__c, From_OU__c, To_OU__c, 
                                                      From_Source_System__c, To_Source_System__c, FromOU__c, ToOU__c, Amount_AED__c, GL_Date__c,
                                                      To_Entity__r.Operating_unit__r.Entity_Code__c, To_Entity__r.Operating_unit__r.Operating_Unit_Name__c,
                                                      From_Entity__r.Operating_unit__r.Entity_Code__c, From_Entity__r.Operating_unit__r.Operating_Unit_Name__c, 
                                                      From_Entity__r.Operating_unit__r.OU_Abbreviation__c, To_Entity__r.Operating_unit__r.OU_Abbreviation__c,From_Entity__r.Name 
                                                      FROM Fund_Transfer__c 
                                       				  WHERE Journal_Created__c = false AND reference_Receipt__r.is_Reversed__c = false AND To_Receipt__r.Oracle_Receipt_Id__c != null AND To_Receipt__r.is_reversed__c = false]){
            lstRecords.add(objJH);
        }
        return lstRecords;
    }
    global void execute(Database.BatchableContext BC,List<Fund_Transfer__c> lstRecords){
            
            List<Journal_Entry__c> journalsToInsert = new List<Journal_Entry__c>();
            Map<String, String> fundTransferJournalMapping = new Map<String, String>{'Unapplied-D'=> 'Debit', 'Unapplied-C'=> 'Credit'};
                
                Map<String, GL_Combination_Setting__c> glCombinationMap = new Map<String, GL_Combination_Setting__c>();
            for(GL_Combination_Setting__c eachGLCombinaton : [SELECT Id,Account_Type__c,Code__c,Journal_Entry_Account__c,Lookup_Code_Meaning__c,Payment_Currency__c FROM GL_Combination_Setting__c WHERE Journal_Entry_Account__c = 'Unapplied' AND Active__c = true]){
                glCombinationMap.put(eachGLCombinaton.Journal_Entry_Account__c, eachGLCombinaton);
            }
            
            Map<String, Journal_Header__c> journalHeaderMap = new Map<String, Journal_Header__c>();
            Map<String, List<Journal_Entry__c>> journalEntryMap = new Map<String, List<Journal_Entry__c>>();
            Journal_Header_Running_Number__c headerRunningNumber = Journal_Header_Running_Number__c.getValues('Next Running Number');
            Integer runningNumber = Integer.valueOf(headerRunningNumber.running_Number__c);
            
            List<Fund_Transfer__c> ftLst = new List<Fund_Transfer__c>();
            for (Fund_Transfer__c ftObj : lstRecords) {
                ftLst.add(new Fund_Transfer__c(Id = ftObj.Id, Journal_Created__c = true));
                Journal_Header__c jhObj = new Journal_Header__c();
                jhObj.Name = 'JV-' + runningNumber;
                jhObj.Transaction_Type__c = 'Fund Transfer';
                jhObj.Fund_Transfer__c = ftObj.Id;
                jhObj.Reference_Id__c = ftObj.Id;
                jhObj.Reference_Name__c = ftObj.Name;
                jhObj.Entity_Name__c = ftObj.From_Entity__r.Name;
                jhObj.Account__c = ftObj.From_Entity__c;
                jhObj.GL_Date__c = ftObj.GL_Date__c;
                jhObj.Sync_Not_Required__c = true;
                journalHeaderMap.put(jhObj.Name, jhObj);
                
                runningNumber++;
                Integer count = 1;
                
                for(String transactionType : fundTransferJournalMapping.keySet()){
                    
                    String splitTransactionType = transactionType.split('-')[0];
                    
                    Journal_Entry__c je = new Journal_Entry__c(Fund_Transfer__c = ftObj.Id, Receipt__c = ftObj.To_Receipt__c, Account__c = splitTransactionType, GL_Date__c = ftObj.GL_Date__c);
                    je.Account_Segment__c = glCombinationMap.get(splitTransactionType).Code__c;
                    je.Account_Segment_Description__c = glCombinationMap.get(splitTransactionType).Lookup_Code_Meaning__c;
                    je.conversion_rate__c = ftObj.Reference_Receipt__r.conversion_rate__c;
                    je.Name = jhObj.Name + '-' + count;
                    if(fundTransferJournalMapping.get(transactionType) == 'Debit'){
                        je.Entity__c = ftObj.From_Entity__r.Operating_unit__r.Entity_Code__c;
                        je.Entity_Description__c = ftObj.From_Entity__r.Operating_unit__r.Operating_Unit_Name__c;
                        je.currency__c = ftObj.From_Currency__c;
                        je.Debit_OC__c = ftObj.Amount__c;
                        je.Operating_Unit_Name__c = ftObj.From_Entity__r.Operating_Unit__r.OU_Abbreviation__c;
                    } else if(fundTransferJournalMapping.get(transactionType) == 'Credit'){
                        je.Entity__c = ftObj.To_Entity__r.Operating_unit__r.Entity_Code__c;
                        je.Entity_Description__c = ftObj.To_Entity__r.Operating_unit__r.Operating_Unit_Name__c;
                        je.currency__c = ftObj.To_Currency__c;
                        je.Operating_Unit_Name__c = ftObj.To_Entity__r.Operating_Unit__r.OU_Abbreviation__c;
                        if(ftObj.From_Currency__c == 'USD' && ftObj.To_Currency__c == 'AED'){je.Credit_OC__c = ftObj.Amount__c * ftObj.Reference_Receipt__r.conversion_rate__c;   
                        }else if(ftObj.From_Currency__c == 'AED' && ftObj.To_Currency__c == 'USD'){je.Credit_OC__c = ftObj.Amount__c / ftObj.Reference_Receipt__r.conversion_rate__c;  
                        }else{je.Credit_OC__c = ftObj.Amount__c;}
                        
                    } 
                    List<Journal_Entry__c> tempLst = journalEntryMap.get(jhObj.Name);
                    if(tempLst == NULL){tempLst = new List<Journal_Entry__c>();}
                    tempLst.add(je);journalEntryMap.put(jhObj.Name, tempLst);count++;
                }
            }
        
        if(!ftLst.isEmpty()){
            UPDATE ftLst;
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