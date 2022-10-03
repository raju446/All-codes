global without sharing class Batch_CreateDecApplicationJVs implements Database.Batchable<sObject>{

    global List<sObject> start(Database.BatchableContext BC){
        
        //return [SELECT Id,Invoice__c,Invoice__r.Source_Invoice_Id__c,Receipt__r.Payment_Currency__c, Receipt__r.Conversion_Rate__c, Applied_Date__c,Invoice__r.GL_DAte__c, Receipt__r.GL_Date__c, Amount_Applied__c,Invoice__r.Invoice_Balance__c, Invoice__r.Converted_Invoice_Balance__c FROM Related_Invoice_Receipt__c WHERE Direction__c = 'From Receipt To Invoice' AND Invoice__r.Journal_Created__c = true AND Receipt__r.Journal_Created__c = true AND Journal_Created__c = false AND Invoice__r.GL_DAte__c = LAST_MONTH AND Receipt__r.GL_Date__c = LAST_MONTH ORDER BY Invoice__r.Source_Invoice_Id__c ASC ];
        //return [SELECT Id,Invoice__c,Invoice__r.Source_Invoice_Id__c,Receipt__r.Payment_Currency__c, Receipt__r.Conversion_Rate__c, Applied_Date__c,Invoice__r.GL_DAte__c, Receipt__r.GL_Date__c, Amount_Applied__c,Invoice__r.Invoice_Balance__c, Invoice__r.Converted_Invoice_Balance__c FROM Related_Invoice_Receipt__c WHERE Direction__c = 'From Invoice To Receipt' AND Invoice__r.Journal_Created__c = true AND Receipt__r.Journal_Created__c = true AND Journal_Created__c = false AND (Invoice__r.GL_DAte__c = LAST_MONTH OR Receipt__r.GL_Date__c = LAST_MONTH ) ORDER BY Invoice__r.Source_Invoice_Id__c ASC];
        //return [SELECT Id,Invoice__c,Invoice__r.Source_Invoice_Id__c,Receipt__r.Payment_Currency__c, Receipt__r.Conversion_Rate__c, Applied_Date__c,Invoice__r.GL_DAte__c, Receipt__r.GL_Date__c, Amount_Applied__c,Invoice__r.Invoice_Balance__c, Invoice__r.Converted_Invoice_Balance__c FROM Related_Invoice_Receipt__c WHERE Direction__c = 'From Receipt To Invoice' AND Invoice__r.Journal_Created__c = true AND Receipt__r.Journal_Created__c = true AND Journal_Created__c = true AND (Invoice__r.GL_DAte__c = LAST_MONTH OR Receipt__r.GL_Date__c = LAST_MONTH ) ORDER BY Invoice__r.Source_Invoice_Id__c ASC];
        Date startDate = Date.newInstance(2021, 12, 1);
        Date endDate = Date.newInstance(2021, 12, 31);
        return [SELECT Id,Invoice__c,Invoice__r.Source_Invoice_Id__c,Receipt__r.Payment_Currency__c, Receipt__r.Conversion_Rate__c, Applied_Date__c,Invoice__r.GL_DAte__c, Receipt__r.GL_Date__c, Invoice__r.Converted_Invoice_Balance__c, Amount_Applied__c, Invoice__r.Name, Receipt__r.Name, Invoice__r.Invoice_Balance__c, Receipt__r.Remaning_Amount__c, Invoice__r.Operating_Unit__c, CreatedDate FROM Related_Invoice_Receipt__c WHERE Amount_Applied__c > 0 AND (Invoice__r.GL_Date__c = LAST_YEAR OR Receipt__r.GL_Date__c = LAST_YEAR) AND Oracle_Applied_Amount__c = null AND Receipt__r.is_Reversed__c = false AND CreatedDate >= :StartDate AND CreatedDate <= :EndDate ORDER BY Invoice__r.Operating_Unit__c ];
    }
    
    global void execute(Database.BatchableContext BC,List<Related_Invoice_Receipt__c> applicatnLst){
        
        
        List<Related_Invoice_Receipt__c> relatedReceipts = new List<Related_Invoice_Receipt__c>();
        List<Invoice__c> invoiceLst = new List<Invoice__c>();
        List<Id> applicationIds = new List<Id>();
        List<String> invoiceNos = new List<String>();
        List<String> amntApplied = new List<String>();
        List<String> amountAppliedDates = new List<String>();
        system.debug('rp.Related_Invoices__r==>>' + applicatnLst);
        
        if(!applicatnLst.isEmpty()){
            relatedReceipts = applicatnLst;
            //relatedReceipts = [SELECT Id,Invoice__c, Invoice__r.Oracle_Invoice_Id__c, Invoice__r.Invoice_Balance__c, Invoice__r.Converted_Invoice_Balance__c FROM Related_Invoice_Receipt__c WHERE Receipt__c =: rp.id AND Invoice__r.Oracle_Invoice_Id__c IN: invoiceNos1];
            
            for(Related_Invoice_Receipt__c obj : relatedReceipts){
                system.debug('obj.Amount_Applied__c==>>' + obj.Amount_Applied__c);
                obj.GL_Date__c = obj.CreatedDate.Date(); obj.Applied__c = true;
                obj.Amount_Applied__c = obj.Amount_Applied__c; 
                obj.Journal_Created__c = true;
                obj.ORACLE_Applied_Amount__c = obj.Amount_Applied__c;
                obj.Oracle_Converted_Applied_Amount__c =  obj.Receipt__r.Payment_Currency__c == 'USD' ? obj.Amount_Applied__c * obj.Receipt__r.Conversion_Rate__c : obj.Amount_Applied__c;
                applicationIds.add(obj.Id);
                invoiceLst.add(new Invoice__c(id = obj.Invoice__c, Invoice_Balance__c = obj.Invoice__r.Invoice_Balance__c == obj.Amount_Applied__c ? 0 : obj.Invoice__r.Invoice_Balance__c - obj.Amount_Applied__c, Converted_Invoice_Balance__c = obj.Invoice__r.Converted_Invoice_Balance__c == obj.Oracle_Converted_Applied_Amount__c ? 0 : obj.Invoice__r.Converted_Invoice_Balance__c - obj.Oracle_Converted_Applied_Amount__c));
                
            }
        }
        
        if(invoiceLst.size() > 0){ update invoiceLst;}
               
        if(relatedReceipts.size() > 0){update relatedReceipts;}       
        
        List<Journal_Entry__c> journalsToInsert = new List<Journal_Entry__c>();
        List<Related_Invoice_Receipt__c> applicationList = [SELECT Id, Applied_Date__c, Name,Invoice__c, Receipt__c, Receipt__r.Receipt_Balance__c, Receipt__r.Entity__r.Operating_unit__r.Entity_Code__c, GL_Date__c,
                                                Oracle_Applied_Amount__c, Receipt__r.Entity__r.Operating_unit__r.Operating_Unit_Name__c, Receipt__r.Entity__r.Operating_unit__r.OU_Abbreviation__c, 
                                                Receipt__r.Payment_Currency__c, receipt__r.Conversion_Rate__c,Receipt__r.Entity__r.Name FROM Related_Invoice_Receipt__c WHERE Id = :applicatnLst[0].Id];
        
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
                jhObj.GL_Date__c = applicationItem.Applied_Date__c;
                //jhObj.Sync_Not_Required__c = true;
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
    
    global void finish(Database.BatchableContext BC){}
    
}