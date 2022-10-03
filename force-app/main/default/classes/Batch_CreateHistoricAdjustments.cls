global without sharing class Batch_CreateHistoricAdjustments implements Database.Batchable<sObject>{
    global List<sObject> start(Database.BatchableContext BC){
        List<Invoice_Line_Item__c> listInvoiceLineItem = new List<Invoice_Line_Item__c>();
        listInvoiceLineItem = [SELECT Id, Name, Amount__c, Calculated_Amount_AED__c, Activity_Name__c, Is_From_Adjustment__c, Invoice__r.Id, Invoice__r.GL_Date__c,Tax__c, 
                                                      Invoice__r.Entity__r.Operating_unit__r.Entity_Code__c, Invoice__r.Entity__r.Operating_unit__r.OU_Abbreviation__c, Invoice__r.Total_Invoice_Amount_AED__c, 
                                                      Invoice__r.Entity__r.Operating_unit__r.Operating_Unit_Name__c, Invoice__r.Entity__r.Name, Invoice__r.Conversion_Rate__c, Invoice__r.Payment_Currency__c 
                                                      FROM Invoice_Line_Item__c WHERE RecordType.Name = 'Adjustment' AND Oracle_Adjustment_No__c != '' AND Journal_Created__c = false AND Activity_Name__c != 'Fee Waiver' 
                               AND Activity_Name__c != 'Invoice Cancellation' AND Activity_Name__c != 'RA Invoice Cancellation' AND Activity_Name__c != 'RA Invoice Cancellation - Tax' 
                               AND Activity_name__c != 'FSRA Invoice Cancellation' AND Activity_Name__c != 'ACAD Invoice Cancellation' AND Activity_Name__c != 'ACAD Invoice Cancel - Tax' 
                               AND Activity_Name__c != 'ADGM Invoice Cancellation' AND Activity_Name__c != 'ADGM Invoice Cancel - Tax' AND Activity_Name__c != 'FSRA Invoice Cancell. - Tax' 
                               AND Activity_Name__c != 'Courts Invoice Cancellation' AND Activity_Name__c != 'BPM Invoice Cancellation'];
        return listInvoiceLineItem;
    }
    
    global void execute(Database.BatchableContext BC,List<Invoice_Line_Item__c> discountedLines){
        discountedLines[0].Journal_Created__c = true;
        UPDATE discountedLines;
        Map<String, Map<String,GL_Combination_Setting__c>> glCombinationMap = new Map<String, Map<String,GL_Combination_Setting__c>>{'Receivable' => new Map<String,GL_Combination_Setting__c>(), 'Expense' => new Map<String,GL_Combination_Setting__c>(), 'Tax' => new Map<String,GL_Combination_Setting__c>(), 'Cost_Centre' => new Map<String,GL_Combination_Setting__c>(), 'Program' => new Map<String,GL_Combination_Setting__c>(), 'Project' => new Map<String,GL_Combination_Setting__c>()};
            
            for(GL_Combination_Setting__c eachGLCombinaton : [SELECT Id,Account_Type__c,Code__c,Journal_Entry_Account__c,Lookup_Code_Meaning__c,Payment_Currency__c,
                                                              Related_Service_Type__c,Recordtype.DeveloperName 
                                                              FROM GL_Combination_Setting__c 
                                                              WHERE Related_Object__c INCLUDES('Invoice') 
                                                              AND Active__c = true]){
                                                                  
                                                                  if(eachGLCombinaton.Recordtype.DeveloperName == 'Cost_Centre'){glCombinationMap.get('Cost_Centre').put(eachGLCombinaton.Lookup_Code_Meaning__c, eachGLCombinaton);}
                                                                  else if(eachGLCombinaton.Recordtype.DeveloperName == 'Program'){glCombinationMap.get('Program').put(eachGLCombinaton.Lookup_Code_Meaning__c, eachGLCombinaton);}
                                                                  else if(eachGLCombinaton.Recordtype.DeveloperName == 'Project'){glCombinationMap.get('Project').put(eachGLCombinaton.Lookup_Code_Meaning__c, eachGLCombinaton);}
                                                                  else if(eachGLCombinaton.Recordtype.DeveloperName == 'Account'){
                                                                      if(eachGLCombinaton.Journal_Entry_Account__c == 'Receivable'){glCombinationMap.get('Receivable').put(eachGLCombinaton.Lookup_Code_Meaning__c, eachGLCombinaton);}
                                                                      else if(eachGLCombinaton.Journal_Entry_Account__c == 'Expense'){glCombinationMap.get('Expense').put(eachGLCombinaton.Lookup_Code_Meaning__c, eachGLCombinaton);}
                                                                      else if(eachGLCombinaton.Journal_Entry_Account__c == 'Tax'){glCombinationMap.get('Tax').put('Tax', eachGLCombinaton);}
                                                                  }
                                                              }
        Map<String, Journal_Header__c> journalHeaderMap = new Map<String, Journal_Header__c>();
        List<Journal_Entry__c> journalsToInsert = new List<Journal_Entry__c>();
        Map<String, List<Journal_Entry__c>> journalEntryMap = new Map<String, List<Journal_Entry__c>>();
        Journal_Header_Running_Number__c headerRunningNumber = Journal_Header_Running_Number__c.getValues('Next Running Number');
        Integer runningNumber = Integer.valueOf(headerRunningNumber.running_Number__c);
        
        
        Journal_Header__c jhObj = new Journal_Header__c();
        jhObj.Name = 'JV' + '-' + runningNumber;
        jhObj.Transaction_Type__c = 'Adjustment';
        jhObj.Invoice__c = discountedLines[0].Invoice__r.Id;
        jhObj.Invoice_Line_Item__c = discountedLines[0].Id;
        jhObj.Reference_Id__c = discountedLines[0].Id;
        jhObj.Reference_Name__c = discountedLines[0].Name;
        jhObj.Entity_Name__c = discountedLines[0].Invoice__r.Entity__r.Name;
        jhObj.Account__c = discountedLines[0].Invoice__r.Entity__c;
        jhObj.GL_Date__c = discountedLines[0].Invoice__r.GL_Date__c.date();
        jhObj.Sync_Not_Required__c = true;
        INSERT jhObj;
        Integer count = 1;
        for(Invoice_Line_Item__c lineItem : discountedLines){
            Journal_Entry__c je = new Journal_Entry__c(Invoice__c = lineItem.Invoice__r.Id, Account__c = 'Receivable', GL_Date__c = lineItem.Invoice__r.GL_Date__c.date());
            je.Name = jhObj.Name + '-' + count;
            je.Journal_Header__c = jhObj.Id;
            je.Currency__c = lineItem.Invoice__r.Payment_Currency__c;
            je.Conversion_Rate__c = lineItem.Invoice__r.Conversion_Rate__c;
            je.Entity__c = lineItem.Invoice__r.Entity__r.Operating_unit__r.Entity_Code__c;
            je.Entity_Description__c = lineItem.Invoice__r.Entity__r.Operating_unit__r.Operating_Unit_Name__c;
            je.Operating_Unit_Name__c = lineItem.Invoice__r.Entity__r.Operating_unit__r.OU_Abbreviation__c;
            je.Account_Segment__c = glCombinationMap.get('Receivable').get('Accounts Receivables').Code__c;
            je.Account_Segment_Description__c = glCombinationMap.get('Receivable').get('Accounts Receivables').Lookup_Code_Meaning__c;
            je.Invoice__c = lineItem.Invoice__r.Id;
            je.Credit_OC__c = lineItem.Amount__c;
            je.Tax_Rate_Code__c = lineItem.Tax__c;
            journalsToInsert.add(je);
            count++;
            
            je = new Journal_Entry__c(Invoice__c = lineItem.Invoice__r.Id, Account__c = 'Expense', GL_Date__c = lineItem.Invoice__r.GL_Date__c.date());
            je.Name = jhObj.Name + '-' + count;
            je.Journal_Header__c = jhObj.Id;
            je.Currency__c = lineItem.Invoice__r.Payment_Currency__c;
            je.Conversion_Rate__c = lineItem.Invoice__r.Conversion_Rate__c;
            je.Entity__c = lineItem.Invoice__r.Entity__r.Operating_unit__r.Entity_Code__c;
            je.Entity_Description__c = lineItem.Invoice__r.Entity__r.Operating_unit__r.Operating_Unit_Name__c;
            je.Operating_Unit_Name__c = lineItem.Invoice__r.Entity__r.Operating_unit__r.OU_Abbreviation__c;
            je.Account_Segment__c = glCombinationMap.get('Expense').get(lineItem.Activity_Name__c).Code__c;
            je.Account_Segment_Description__c = glCombinationMap.get('Expense').get(lineItem.Activity_Name__c).Lookup_Code_Meaning__c;
            je.Cost_center__c = glCombinationMap.get('Cost_Centre').get('Corporate Allcoations').Code__c;
            je.Cost_center_Description__c = glCombinationMap.get('Cost_Centre').get('Corporate Allcoations').Lookup_Code_Meaning__c;
            je.Invoice__c = lineItem.Invoice__r.Id;
            je.Debit_OC__c = lineItem.Amount__c;
            je.Tax_Rate_Code__c = lineItem.Tax__c;
            journalsToInsert.add(je);
            count++;
        }
        
        
        system.debug('journalsToInsert==>>' + journalsToInsert);
        if(!journalsToInsert.isEmpty()){ 
            insert journalsToInsert; 
            Journal_Header_Running_Number__c headerRunningNumber1 = Journal_Header_Running_Number__c.getValues('Next Running Number');
            headerRunningNumber1.running_Number__c = runningNumber;
            UPDATE headerRunningNumber1;
        }
    }
    
    global void finish(Database.BatchableContext BC){ 
    }
}