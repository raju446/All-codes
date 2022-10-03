global without sharing class Batch_CreateDecFundTransferJVs implements Database.Batchable<sObject>{

    global List<sObject> start(Database.BatchableContext BC){
        
        
        List<Fund_Transfer__c> listFund_Transfer = new List<Fund_Transfer__c>();
        listFund_Transfer = [select id, Amount__c,From_Receipt__c, Status__c,Description__c,From_Entity__r.Oracle_Site_Id__c,To_Receipt__r.Source_Receipt_Id__c,Reference_Receipt__r.Name,
                                 Reference_Receipt__r.GL_Date__c,Reference_Receipt__r.Receipt_Date__c, From_Currency__c, To_Currency__c, Scenario__c,To_Receipt__r.Name, To_Entity__c, To_Entity__r.Oracle_Party_Id__c, 
                                 From_Entity__r.Oracle_Party_Id__c, To_Entity__r.Oracle_Site_Id__c, Reference_Receipt__c, To_Receipt__r.Payment_Method__c,To_Receipt__r.Authorization_Code__c,To_Receipt__r.Payment_Currency__c,To_Receipt__r.Amount__c,
                                 Reference_Receipt__r.Source_Receipt_Id__c,To_Receipt__r.Receipt_Date__c,To_Receipt__r.GL_Date__c,To_Receipt__r.Transaction_Reference__c,Reference_Receipt__r.Transaction_Reference__c,To_Receipt__r.Conversion_Rate__c,
                                 Reference_Receipt__r.Payment_Method__c,Reference_Receipt__r.Authorization_Code__c,Reference_Receipt__r.Receipt_Reference__c,Reference_Receipt__r.EFT_Reference_No__c  
                             from Fund_Transfer__c 
                             WHERE GL_Date__c = LAST_MONTH AND To_Receipt__r.Oracle_Receipt_Id__c = '' AND Status__c = 'Approved' AND To_Receipt__c != '' AND Journal_Created__c = false];
        
        
        
       
        return listFund_Transfer;
    }
    
    global void execute(Database.BatchableContext BC,List<Fund_Transfer__c> listFund_Transfer){
        
        Set<Id> referenceReceiptIds = new Set<Id>();
        
        for(Fund_Transfer__c objFund_Transfer : listFund_Transfer){
            referenceReceiptIds.add(objFund_Transfer.Reference_Receipt__c);
            objFund_Transfer.Journal_Created__c = true;
            objFund_Transfer.Status__c = 'Success';
        }
        
        Map<Id,Receipt__c> referenceReceiptsMap = new Map<Id,Receipt__c>([SELECT Id,Transferred_Amount__c FROM Receipt__c WHERE Id IN : referenceReceiptIds]);
        for(Fund_Transfer__c objFund_Transfer : listFund_Transfer) {
            Decimal convertedAmount = objFund_Transfer.To_Receipt__r.Payment_Currency__c == 'USD' ? objFund_Transfer.To_Receipt__r.Amount__c * objFund_Transfer.To_Receipt__r.Conversion_Rate__c : objFund_Transfer.To_Receipt__r.Amount__c;
            referenceReceiptsMap.put(objFund_Transfer.To_Receipt__c, new Receipt__c(Reference_Receipt__c = objFund_Transfer.Reference_Receipt__c,Status__c = 'Success', Converted_Amount__c = convertedAmount.setScale(2),Amount__c=(objFund_Transfer.To_Receipt__r.Amount__c).setScale(2), id = objFund_Transfer.To_Receipt__c, GL_Date__c =Date.Today(), Journal_Created__c = true));
            if(referenceReceiptsMap.get(objFund_Transfer.Reference_Receipt__c).Transferred_Amount__c == null){referenceReceiptsMap.get(objFund_Transfer.Reference_Receipt__c).Transferred_Amount__c = (objFund_Transfer.Amount__c).setScale(2);
                                                                                                             } else {
                                                                                                                 referenceReceiptsMap.get(objFund_Transfer.Reference_Receipt__c).Transferred_Amount__c = (objFund_Transfer.Amount__c + referenceReceiptsMap.get(objFund_Transfer.Reference_Receipt__c).Transferred_Amount__c).setScale(2);
                                                                                                             }
        }     
        UPDATE listFund_Transfer;
        update referenceReceiptsMap.values();
        
        createJEs(listFund_Transfer[0].Id);
        
    }
    
    static void createJEs(Id ftId){
        
        List<Fund_Transfer__c> lstRecords = new List<Fund_Transfer__c>();
        for(Fund_Transfer__c objJH : [SELECT Name, From_Entity__c, To_Entity__c, Id, Reference_Receipt__c, From_Receipt__c, To_Receipt__c,
                                                      Reference_Receipt__r.conversion_rate__c, To_Receipt__r.conversion_rate__c, 
                                                      From_Currency__c, Amount__c, To_Currency__c, Scenario__c, Description__c, From_OU__c, To_OU__c, 
                                                      From_Source_System__c, To_Source_System__c, FromOU__c, ToOU__c, Amount_AED__c, GL_Date__c,
                                                      To_Entity__r.Operating_unit__r.Entity_Code__c, To_Entity__r.Operating_unit__r.Operating_Unit_Name__c,
                                                      From_Entity__r.Operating_unit__r.Entity_Code__c, From_Entity__r.Operating_unit__r.Operating_Unit_Name__c, 
                                                      From_Entity__r.Operating_unit__r.OU_Abbreviation__c, To_Entity__r.Operating_unit__r.OU_Abbreviation__c,From_Entity__r.Name 
                                                      FROM Fund_Transfer__c 
                                                      WHERE Id = :ftId]){
            lstRecords.add(objJH);
        }
        
        
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
        
        for (Fund_Transfer__c ftObj : lstRecords) {
            Journal_Header__c jhObj = new Journal_Header__c();
            jhObj.Name = 'JV-' + runningNumber;
            jhObj.Transaction_Type__c = 'Fund Transfer';
            jhObj.Fund_Transfer__c = ftObj.Id;
            jhObj.Reference_Id__c = ftObj.Id;
            jhObj.Reference_Name__c = ftObj.Name;
            jhObj.Entity_Name__c = ftObj.From_Entity__r.Name;
            jhObj.Account__c = ftObj.From_Entity__c;
            jhObj.GL_Date__c = ftObj.GL_Date__c;
            //jhObj.Sync_Not_Required__c = true;
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