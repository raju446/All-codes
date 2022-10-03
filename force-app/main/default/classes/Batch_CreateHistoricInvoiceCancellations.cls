global without sharing class Batch_CreateHistoricInvoiceCancellations implements Database.Batchable<sObject>{
    global List<sObject> start(Database.BatchableContext BC){
        
        
        /*List<Invoice_Line_Item__c> invLineLst = [SELECT Id, Name, Amount__c, Calculated_Amount_AED__c, Activity_Name__c, Is_From_Adjustment__c, Invoice__r.Id, Invoice__r.GL_Date__c,Tax__c, 
                                                      Invoice__r.Entity__r.Operating_unit__r.Entity_Code__c, Invoice__r.Entity__r.Operating_unit__r.OU_Abbreviation__c, Invoice__r.Total_Invoice_Amount_AED__c, 
                                                      Invoice__r.Entity__r.Operating_unit__r.Operating_Unit_Name__c, Invoice__r.Entity__r.Name, Invoice__r.Conversion_Rate__c, Invoice__r.Payment_Currency__c 
                                                      FROM Invoice_Line_Item__c WHERE RecordType.Name = 'Adjustment' AND Oracle_Adjustment_No__c != '' AND Journal_Created__c = false
                               AND (Activity_Name__c = 'Invoice Cancellation' OR Activity_Name__c = 'RA Invoice Cancellation' OR Activity_Name__c = 'RA Invoice Cancellation - Tax' 
                               OR Activity_name__c = 'FSRA Invoice Cancellation' OR Activity_Name__c = 'ACAD Invoice Cancellation' OR Activity_Name__c = 'ACAD Invoice Cancel - Tax' 
                               OR Activity_Name__c = 'ADGM Invoice Cancellation' OR Activity_Name__c = 'ADGM Invoice Cancel - Tax' OR Activity_Name__c = 'FSRA Invoice Cancell. - Tax' 
                               OR Activity_Name__c = 'Courts Invoice Cancellation' OR Activity_Name__c = 'BPM Invoice Cancellation') AND Oracle_Adjustment_No__c !=''];
        set<Id> invoiceSet = new set<Id>();
        for(Invoice_Line_Item__c iliObj : invLineLst){
            invoiceSet.add(iliObj.invoice__c);
        }*/
        List<Invoice_Line_Item__c> invLineLst = [SELECT Id, Invoice__c FROM Invoice_Line_Item__c WHERE Activity_Name__c LIKE '%Fee%' AND RecordType.Name = 'Adjustment' AND Invoice__r.Total_Invoice_Amount_AED__c > 0 ];
        set<Id> invoiceSet = new set<Id>();
        for(Invoice_Line_Item__c iliObj : invLineLst){
            invoiceSet.add(iliObj.invoice__c);
        }
        return [SELECT Id FROM Invoice__c WHERE Id IN :invoiceSet];
        
    }
    
    global void execute(Database.BatchableContext BC,List<Invoice__c> invLst){
        
        List<Invoice_Line_Item__c> invLineLst = [SELECT Id, Invoice__c FROM Invoice_Line_Item__c WHERE Activity_Name__c LIKE '%Fee%' AND RecordType.Name = 'Adjustment' AND Invoice__r.Total_Invoice_Amount_AED__c > 0 
                               AND Journal_Created__c = false AND Invoice__c = :invLst[0].Id];
        
        if(invLineLst.size() == 1){
            invLineLst[0].Journal_Created__c = true;
            UPDATE invLineLst;
            List<Journal_Header__c> journalHeaderLst = [SELECT Id, Name, Invoice__c, Receipt__c, Fund_Transfer__c, Invoice_Line_Item__c, Related_Invoice_Receipt__c, 
                                                        Refund__c,Entity_Name__c,Reference_Id__c,Reference_Name__c, 
                                                        (SELECT Id, Account__c, Receipt__c, GL_Date__c, Entity__c, Account_Segment__c, Inter_company__c, Project__c, 
                                                         Cost_center__c, Program__c, Future2__c, Account_Segment_Description__c, Cost_center_Description__c, 
                                                         Entity_Description__c, Future2_Description__c, Inter_company_Description__c, Program_Description__c, 
                                                         Project_Description__c, Code_Combination__c, Code_Combination_Description__c, Invoice__c, Related_Invoice_Receipt__c, 
                                                         Refund__c, Credit_Memo_Application__c, Fund_Transfer__c, Journal_Header__c, Conversion_Rate__c, Currency__c, 
                                                         Credit_OC__c, Credit_AED__c, Debit_OC__c, Debit_AED__c,Operating_Unit_Name__c,Tax_Rate_Code__c  FROM Journal_Entries__r) 
                                                        FROM Journal_Header__c WHERE Invoice__c = :invLst[0].Id AND Transaction_Type__c IN ('Sales Invoices', 'Credit Memos')];
            Map<String, Journal_Header__c> journalHeaderMap = new Map<String, Journal_Header__c>();
            List<Journal_Entry__c> journalsToInsert = new List<Journal_Entry__c>();
            Map<String, List<Journal_Entry__c>> journalEntryMap = new Map<String, List<Journal_Entry__c>>();
            Journal_Header_Running_Number__c headerRunningNumber = Journal_Header_Running_Number__c.getValues('Next Running Number');
            Integer runningNumber = Integer.valueOf(headerRunningNumber.running_Number__c);
            
            for(Journal_Header__c jhObj : journalHeaderLst){
                Journal_Header__c tempHeader = jhObj;
                tempHeader.Id = null;
                tempHeader.Transaction_Type__c = 'Adjustment';
                tempHeader.Name = 'JV-' + runningNumber;
                system.debug('tempHeader==>>' + tempHeader);
                journalHeaderMap.put(tempHeader.Name, tempHeader);
                
                runningNumber++;
                Integer count = 1;
                for(Journal_Entry__c tempJE : jhObj.Journal_Entries__r){
                    Journal_Entry__c je = new Journal_Entry__c();
                    Decimal credit = 0;
                    Decimal debit = 0;
                    if(tempJE.Credit_OC__c != 0){debit = tempJE.Credit_OC__c;}
                    if(tempJE.Debit_OC__c != 0){
                        credit = tempJE.Debit_OC__c;
                    }
                    system.debug('credit==>>' + credit);
                    system.debug('debit==>>' + debit);
                    je = tempJE;
                    je.Id = null;
                    je.Credit_OC__c = credit;
                    je.Debit_OC__c = debit;
                    je.Operating_Unit_Name__c = tempJE.Operating_Unit_Name__c;
                    system.debug('Credit_OC__c==>>' + je.Credit_OC__c) ;
                    system.debug('Debit_OC__c==>>' + je.Debit_OC__c) ;
                    je.Name = tempHeader.Name + '-' + count;
                    List<Journal_Entry__c> tempLst = journalEntryMap.get(tempHeader.Name);
                    if(tempLst == NULL){
                        tempLst = new List<Journal_Entry__c>();
                    }
                    system.debug('je==>>' + je);
                    tempLst.add(je);
                    journalEntryMap.put(tempHeader.Name, tempLst);
                    count++;
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
        
        
        
    }
    
    global void finish(Database.BatchableContext BC){ 
    }
}