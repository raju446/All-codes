global without sharing class Batch_CreateHistoricInvoiceJVs implements Database.Batchable<sObject>{
    
    global List<sObject> start(Database.BatchableContext BC){
        /*List<Invoice__c> lstInvoice = new List<Invoice__c>();
        for(Invoice__c objJH : [SELECT Id,Name,Entity__c,GL_Date__c,Total_Invoice_Amount_OC__c,Entity__r.Operating_unit__r.Entity_Code__c,Entity__r.Operating_unit__r.Operating_Unit_Name__c,Source_Invoice_Id__c,  Entity__r.Intercompany_OU__c, Entity__r.Intercompany_OU__r.Entity_Code__c,
                                Entity__r.Operating_unit__r.OU_Abbreviation__c,Entity__r.Name,Total_Invoice_Amount_Rollup__c,Total_Invoice_Amount_AED__c,Conversion_Rate__c,Payment_Currency__c,Entity__r.Is_Intercompany__c,Entity__r.Intercompany_OU__r.OU_Abbreviation__c,
                                (SELECT Id,Amount__c,Tax_Amount__c,Line_Amount__c,Service_Type__c,Revenue_Type__c,Department__c,Amount_AED__c,Tax_Amount_AED__c,Tax__c,Is_Discount__c FROM Invoice_Line_Items__r 
                                 WHERE Related_Credit_Memo__c = '' AND Amount__c != null AND Line_Amount__c != null AND RecordType.Name != 'Adjustment' AND IS_From_Adjustment__c = FALSE AND (Status__c != 'Cancelled' OR (Status__c = 'Cancelled' AND Is_Discount__c = true))) FROM Invoice__c WHERE RecordType.Name != 'Credit Memo' AND Status__c != 'Cancelled' AND Oracle_Invoice_Id__c != null AND Journal_Created__c = true AND Is_Synced__c = false AND Total_Invoice_Amount_OC__c > 0 LIMIT 20000]){
                                     lstInvoice.add(objJH);    
                                 }
        return lstInvoice;*/
        
        return [SELECT Id, Name, Entity__c, GL_Date__c, Total_Invoice_Amount_OC__c, Entity__r.Operating_unit__r.Entity_Code__c, Entity__r.Operating_unit__r.Operating_Unit_Name__c, Source_Invoice_Id__c, Entity__r.Intercompany_OU__c, Entity__r.Intercompany_OU__r.Entity_Code__c, Entity__r.Operating_unit__r.OU_Abbreviation__c, Entity__r.Name, Total_Invoice_Amount_Rollup__c, Total_Invoice_Amount_AED__c, Conversion_Rate__c, Payment_Currency__c, Entity__r.Is_Intercompany__c, Entity__r.Intercompany_OU__r.OU_Abbreviation__c, (SELECT Id, Amount__c, Tax_Amount__c, Line_Amount__c, Service_Type__c, Revenue_Type__c, Department__c, Amount_AED__c, Tax_Amount_AED__c, Tax__c, Is_Discount__c FROM Invoice_Line_Items__r WHERE Related_Credit_Memo__c = '' AND Amount__c != null AND Line_Amount__c != null AND RecordType.Name != 'Adjustment' AND IS_From_Adjustment__c = FALSE AND IS_CM_Application__c = FALSE AND (Status__c != 'Cancelled' OR (Status__c = 'Cancelled' AND Is_Discount__c = true))) FROM Invoice__c WHERE RecordType.Name != 'Credit Memo' AND Status__c != 'Cancelled' AND Oracle_Invoice_Id__c != null AND Journal_Created__c = true AND Is_Synced__c = false AND Total_Invoice_Amount_OC__c > 0];
    }
    global void execute(Database.BatchableContext BC,List<Invoice__c> lstInvoice){
            //BM_JournalEntryEngine.invoiceCreationJournal(new List<Id>{objJH.Id});
            
            List<Journal_Entry__c> journalsToInsert = new List<Journal_Entry__c>();
            //List<Journal_Entry__c> jeCreationList = new List<Journal_Entry__c>();
            Map<String,String> jeAccounts = new Map<String,String>{'Receivable' => 'Debit','Revenue'=> 'Credit', 'Tax'=> 'Credit'};
                Map<String, Map<String,GL_Combination_Setting__c>> glCombinationMap = new Map<String, Map<String,GL_Combination_Setting__c>>{'Receivable' => new Map<String,GL_Combination_Setting__c>(), 'Revenue' => new Map<String,GL_Combination_Setting__c>(), 'Tax' => new Map<String,GL_Combination_Setting__c>(), 'Cost_Centre' => new Map<String,GL_Combination_Setting__c>(), 'Program' => new Map<String,GL_Combination_Setting__c>(), 'Project' => new Map<String,GL_Combination_Setting__c>()};
                    for(GL_Combination_Setting__c eachGLCombinaton : [SELECT Id,Account_Type__c,Code__c,Journal_Entry_Account__c,Lookup_Code_Meaning__c,Payment_Currency__c,Related_Service_Type__c,Recordtype.DeveloperName FROM GL_Combination_Setting__c WHERE Related_Object__c INCLUDES('Invoice') AND Active__c = true]){
                        if(eachGLCombinaton.Recordtype.DeveloperName == 'Account'){
                            if(eachGLCombinaton.Journal_Entry_Account__c == 'Receivable'){glCombinationMap.get('Receivable').put('Receivable', eachGLCombinaton);
                                                                                         }else if(eachGLCombinaton.Journal_Entry_Account__c == 'Revenue'){glCombinationMap.get('Revenue').put(eachGLCombinaton.Related_Service_Type__c, eachGLCombinaton);
                                                                                                                                                         }else if(eachGLCombinaton.Journal_Entry_Account__c == 'Tax'){glCombinationMap.get('Tax').put('Tax', eachGLCombinaton);
                                                                                                                                                                                                                     }
                        }else if(eachGLCombinaton.Recordtype.DeveloperName == 'Cost_Centre'){glCombinationMap.get('Cost_Centre').put(eachGLCombinaton.Lookup_Code_Meaning__c, eachGLCombinaton);
                                                                                            }else if(eachGLCombinaton.Recordtype.DeveloperName == 'Program'){glCombinationMap.get('Program').put(eachGLCombinaton.Lookup_Code_Meaning__c, eachGLCombinaton);
                                                                                                                                                            }else if(eachGLCombinaton.Recordtype.DeveloperName == 'Project'){glCombinationMap.get('Project').put(eachGLCombinaton.Lookup_Code_Meaning__c, eachGLCombinaton);
                                                                                                                                                                                                                            }
                    }
            System.debug('glCombinationMap===='+glCombinationMap); 
            //sp = Database.setSavepoint();
            
            Map<String, Journal_Header__c> journalHeaderMap = new Map<String, Journal_Header__c>();
            Map<String, List<Journal_Entry__c>> journalEntryMap = new Map<String, List<Journal_Entry__c>>();
            Journal_Header_Running_Number__c headerRunningNumber = Journal_Header_Running_Number__c.getValues('Next Running Number');
            Integer runningNumber = Integer.valueOf(headerRunningNumber.running_Number__c);
            
            List<Invoice__c> invoiceLst = new List<Invoice__c>();
            for(Invoice__c eachInvoice : lstInvoice){
                
                Journal_Header__c jhObj = new Journal_Header__c();
                jhObj.Name = 'JV' + '-' + runningNumber;
                jhObj.Transaction_Type__c = 'Sales Invoices';
                jhObj.Invoice__c = eachInvoice.Id;
                jhObj.Reference_Id__c = eachInvoice.Id;
                jhObj.Reference_Name__c = eachInvoice.Source_Invoice_Id__c;
                jhObj.Entity_Name__c = eachInvoice.Entity__r.Name;
                jhObj.Account__c = eachInvoice.Entity__c;
                jhObj.GL_Date__c = eachInvoice.GL_Date__c.date();
                jhObj.Sync_Not_Required__c = true;
                journalHeaderMap.put(jhObj.Name, jhObj);
                
                runningNumber++;
                Integer count = 1;
                Journal_Entry__c je = new Journal_Entry__c(Invoice__c=eachInvoice.Id,Account__c='Receivable',GL_Date__c=eachInvoice.GL_Date__c.date(),
                                                           Entity__c=eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c,
                                                           Entity_Description__c=eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c,
                                                           Account_Segment__c=glCombinationMap.get('Receivable').get('Receivable').Code__c,
                                                           Account_Segment_Description__c=glCombinationMap.get('Receivable').get('Receivable').Lookup_Code_Meaning__c,
                                                           Debit_OC__c = eachInvoice.Total_Invoice_Amount_OC__c,
                                                           currency__c = eachInvoice.Payment_Currency__c,
                                                           conversion_rate__c = eachInvoice.Conversion_Rate__c,
                                                           Name = jhObj.Name + '-' + count);
                je.journal_header__c = jhObj.Id;
                je.Operating_Unit_Name__c = eachInvoice.Entity__r.Operating_unit__r.OU_Abbreviation__c;
                List<Journal_Entry__c> tempLst = journalEntryMap.get(jhObj.Name);
                if(tempLst == NULL){tempLst = new List<Journal_Entry__c>();}
                tempLst.add(je);
                journalEntryMap.put(jhObj.Name, tempLst);
                count++;
                invoiceLst.add(new Invoice__c(Id = eachInvoice.Id, Journal_Created__c = true, Is_Synced__c = true));
                for(Invoice_Line_Item__c eachLine : eachInvoice.Invoice_Line_Items__r){
                    
                    system.debug('eachLine.Revenue_Type__c==>>' + eachLine.Revenue_Type__c);
                    if(glCombinationMap.containsKey('Revenue') && !glCombinationMap.get('Revenue').containsKey(eachLine.Revenue_Type__c)){
                        journalHeaderMap.remove(jhObj.Name);runningNumber--;
                       // invoiceLst.add(new Invoice__c(Id = eachInvoice.Id, Journal_Created__c = false, Status__c = 'Error', Oracle_Response_Message__c = 'Revenue Mapping ' + eachLine.Revenue_Type__c + ' missing in classification for ' + eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c));
                        break;
                    }
                    if(eachLine.Is_Discount__c){
                        //Journal_Entry__c jeSub1 =  createJournalLines('Invoice', eachInvoice.Id, 'Revenue', eachInvoice.GL_Date__c.date(), eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c, eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c, glCombinationMap.get('Revenue').get(eachLine.Revenue_Type__c).Code__c,  glCombinationMap.get('Revenue').get(eachLine.Revenue_Type__c).Lookup_Code_Meaning__c, eachLine.Amount__c, null, glCombinationMap.get('Cost_Centre').get(eachLine.Department__c).Code__c, glCombinationMap.get('Cost_Centre').get(eachLine.Department__c).Lookup_Code_Meaning__c,eachInvoice.Payment_Currency__c,eachInvoice.Conversion_Rate__c,jhObj.Name + '-' + count,eachLine.Tax__c);
                        Journal_Entry__c jeSub1 =  new Journal_Entry__c(Invoice__c=eachInvoice.Id, 
                                                                        Account__c =  'Revenue', 
                                                                        GL_Date__c = eachInvoice.GL_Date__c.date(), 
                                                                        Entity__c = eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c, 
                                                                        Entity_Description__c = eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c, 
                                                                        Account_Segment__c = glCombinationMap.get('Revenue').get(eachLine.Revenue_Type__c).Code__c,  
                                                                        Account_Segment_Description__c = glCombinationMap.get('Revenue').get(eachLine.Revenue_Type__c).Lookup_Code_Meaning__c, 
                                                                        Debit_OC__c =  eachLine.Line_Amount__c,
                                                                        Cost_center__c = string.isNotBlank(eachLine.Department__c) ? glCombinationMap.get('Cost_Centre').get(eachLine.Department__c).Code__c : '000', 
                                                                        Cost_center_Description__c = string.isNotBlank(eachLine.Department__c) ? glCombinationMap.get('Cost_Centre').get(eachLine.Department__c).Lookup_Code_Meaning__c : 'None',
                                                                        currency__c = eachInvoice.Payment_Currency__c,
                                                                        conversion_rate__c = eachInvoice.Conversion_Rate__c,
                                                                        Name = jhObj.Name + '-' + count,
                                                                        Tax_Rate_Code__c = eachLine.Tax__c);
                        system.debug('eachInvoice.Entity__r.Is_Intercompany__c==>>' + eachInvoice.Entity__r.Is_Intercompany__c);
                        system.debug('eachInvoice.Entity__r.Intercompany_OU__r.Entity_Code__c==>>' + eachInvoice.Entity__r.Intercompany_OU__r.Entity_Code__c);
                        if(eachInvoice.Entity__r.Is_Intercompany__c){
                            jeSub1.Inter_company__c = eachInvoice.Entity__r.Intercompany_OU__r.Entity_Code__c;
                            jeSub1.Inter_company_Description__c = eachInvoice.Entity__r.Intercompany_OU__r.OU_Abbreviation__c;
                        }
                        jeSub1.journal_header__c = jhObj.Id;
                        jeSub1.Operating_Unit_Name__c = eachInvoice.Entity__r.Operating_unit__r.OU_Abbreviation__c;
                        tempLst = journalEntryMap.get(jhObj.Name);
                        if(tempLst == NULL){tempLst = new List<Journal_Entry__c>();}
                        tempLst.add(jeSub1);
                        journalEntryMap.put(jhObj.Name, tempLst);
                        count++;
                        if(eachLine.Tax__c != 'Out of scope 0%' || eachLine.Tax__c != 'Exempt 0%'){
                            //Journal_Entry__c jeSub2 = createJournalLines('Invoice', eachInvoice.Id, 'Tax', eachInvoice.GL_Date__c.date(), eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c, eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c, '20225', 'Output VAT', eachLine.Tax_Amount__c,null, null, null,eachInvoice.Payment_Currency__c,eachInvoice.Conversion_Rate__c,jhObj.Name + '-' + count,eachLine.Tax__c);
                            Journal_Entry__c jeSub2 = new Journal_Entry__c(Invoice__c = eachInvoice.Id, 
                                                                           Account__c = 'Tax', 
                                                                           GL_Date__c = eachInvoice.GL_Date__c.date(), 
                                                                           Entity__c = eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c, 
                                                                           Entity_Description__c = eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c, 
                                                                           Account_Segment__c = '20225', 
                                                                           Account_Segment_Description__c = 'Output VAT', 
                                                                           Debit_OC__c =  eachLine.Tax_Amount__c,
                                                                           currency__c = eachInvoice.Payment_Currency__c,
                                                                           conversion_rate__c = eachInvoice.Conversion_Rate__c,
                                                                           Name = jhObj.Name + '-' + count,
                                                                           Tax_Rate_Code__c = eachLine.Tax__c);
                            jeSub2.journal_header__c = jhObj.Id;
                            jeSub2.Operating_Unit_Name__c = eachInvoice.Entity__r.Operating_unit__r.OU_Abbreviation__c;
                            tempLst = journalEntryMap.get(jhObj.Name);
                            if(tempLst == NULL){tempLst = new List<Journal_Entry__c>();}
                            tempLst.add(jeSub2);journalEntryMap.put(jhObj.Name, tempLst);count++;
                        }
                    }else{
                        //Journal_Entry__c jeSub1 =  createJournalLines('Invoice', eachInvoice.Id, 'Revenue', eachInvoice.GL_Date__c.date(), eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c, eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c, glCombinationMap.get('Revenue').get(eachLine.Revenue_Type__c).Code__c, glCombinationMap.get('Revenue').get(eachLine.Revenue_Type__c).Lookup_Code_Meaning__c, null, eachLine.Amount__c, glCombinationMap.get('Cost_Centre').get(eachLine.Department__c).Code__c, glCombinationMap.get('Cost_Centre').get(eachLine.Department__c).Lookup_Code_Meaning__c,eachInvoice.Payment_Currency__c,eachInvoice.Conversion_Rate__c,jhObj.Name + '-' + count,eachLine.Tax__c);
                        Journal_Entry__c jeSub1 =  new Journal_Entry__c(Invoice__c = eachInvoice.Id,
                                                                        Account__c = 'Revenue',
                                                                        GL_Date__c = eachInvoice.GL_Date__c.date(),
                                                                        Entity__c = eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c,
                                                                        Entity_Description__c = eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c, 
                                                                        Account_Segment__c = glCombinationMap.get('Revenue').get(eachLine.Revenue_Type__c).Code__c, 
                                                                        Account_Segment_Description__c = glCombinationMap.get('Revenue').get(eachLine.Revenue_Type__c).Lookup_Code_Meaning__c,
                                                                        Credit_OC__c = eachLine.Line_Amount__c, 
                                                                        Cost_center__c = string.isNotBlank(eachLine.Department__c) ? glCombinationMap.get('Cost_Centre').get(eachLine.Department__c).Code__c : '000', 
                                                                        Cost_center_Description__c = string.isNotBlank(eachLine.Department__c) ? glCombinationMap.get('Cost_Centre').get(eachLine.Department__c).Lookup_Code_Meaning__c : 'None',
                                                                        currency__c = eachInvoice.Payment_Currency__c,
                                                                        conversion_rate__c =eachInvoice.Conversion_Rate__c,
                                                                        Name = jhObj.Name + '-' + count,
                                                                        Tax_Rate_Code__c = eachLine.Tax__c);
                        system.debug('eachInvoice.Entity__r.Is_Intercompany__c==>>' + eachInvoice.Entity__r.Is_Intercompany__c);
                        system.debug('eachInvoice.Entity__r.Intercompany_OU__r.Entity_Code__c==>>' + eachInvoice.Entity__r.Intercompany_OU__r.Entity_Code__c);
                        if(eachInvoice.Entity__r.Is_Intercompany__c){
                            jeSub1.Inter_company__c = eachInvoice.Entity__r.Intercompany_OU__r.Entity_Code__c;
                            jeSub1.Inter_company_Description__c = eachInvoice.Entity__r.Intercompany_OU__r.OU_Abbreviation__c;
                        }
                        jeSub1.journal_header__c = jhObj.Id;
                        jeSub1.Operating_Unit_Name__c = eachInvoice.Entity__r.Operating_unit__r.OU_Abbreviation__c;
                        tempLst = journalEntryMap.get(jhObj.Name);
                        if(tempLst == NULL){tempLst = new List<Journal_Entry__c>();}
                        tempLst.add(jeSub1);journalEntryMap.put(jhObj.Name, tempLst);count++;
                        if(eachLine.Tax__c != 'Out of scope 0%'){
                            //Journal_Entry__c jeSub2 = createJournalLines('Invoice', eachInvoice.Id, 'Tax', eachInvoice.GL_Date__c.date(), eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c, eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c, glCombinationMap.get('Tax').get('Tax').Code__c,glCombinationMap.get('Tax').get('Tax').Lookup_Code_Meaning__c, null, eachLine.Tax_Amount__c, null, null,eachInvoice.Payment_Currency__c,eachInvoice.Conversion_Rate__c,jhObj.Name + '-' + count,eachLine.Tax__c);
                            Journal_Entry__c jeSub2 = new Journal_Entry__c(Invoice__c = eachInvoice.Id, 
                                                                           Account__c = 'Tax', 
                                                                           GL_Date__c = eachInvoice.GL_Date__c.date(), 
                                                                           Entity__c = eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c, 
                                                                           Entity_Description__c = eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c, 
                                                                           Account_Segment__c = glCombinationMap.get('Tax').get('Tax').Code__c,
                                                                           Account_Segment_Description__c = glCombinationMap.get('Tax').get('Tax').Lookup_Code_Meaning__c,  
                                                                           Credit_OC__c = eachLine.Tax_Amount__c,
                                                                           currency__c = eachInvoice.Payment_Currency__c,
                                                                           conversion_rate__c = eachInvoice.Conversion_Rate__c,
                                                                           Name = jhObj.Name + '-' + count,
                                                                           Tax_Rate_Code__c = eachLine.Tax__c);
                            jeSub2.journal_header__c = jhObj.Id;
                            jeSub2.Operating_Unit_Name__c = eachInvoice.Entity__r.Operating_unit__r.OU_Abbreviation__c;
                            tempLst = journalEntryMap.get(jhObj.Name);
                            if(tempLst == NULL){tempLst = new List<Journal_Entry__c>();}
                            tempLst.add(jeSub2);journalEntryMap.put(jhObj.Name, tempLst);count++;
                        }
                    }
                }
            }
            if(!invoiceLst.isEmpty()){UPDATE invoiceLst;}
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
        
        List<Invoice__c> invLst = [SELECT Id FROM Invoice__c WHERE RecordType.Name != 'Credit Memo' AND Status__c != 'Cancelled' AND Oracle_Invoice_Id__c != null AND Journal_Created__c = true AND Is_Synced__c = false AND Total_Invoice_Amount__c > 0 LIMIT 20000];
        
        if(invLst.size() == 20000){
            Database.executeBatch(new Batch_CreateHistoricInvoiceJVs(), 1);
        }
    }
    
}