global without sharing class Batch_CreateHistoricCreditMemoJVs implements Database.Batchable<sObject>{
    
    global List<sObject> start(Database.BatchableContext BC){
        List<Invoice__c> lstInvoice = new List<Invoice__c>();
        for(Invoice__c objJH : [SELECT Id,Name,Total_Invoice_Amount_OC__c,GL_Date__c,Entity__r.Operating_unit__r.Entity_Code__c,Entity__r.Operating_unit__r.OU_Abbreviation__c,  Entity__r.Intercompany_OU__c, 
                                Entity__r.Intercompany_OU__r.Entity_Code__c,Entity__r.Operating_unit__r.Operating_Unit_Name__c,Entity__r.Name,Total_Invoice_Amount_Rollup__c,Total_Invoice_Amount_AED__c,
                                Conversion_Rate__c,Payment_Currency__c, Entity__r.Is_Intercompany__c,Entity__r.Intercompany_OU__r.OU_Abbreviation__c,
                                (SELECT Id,Amount__c,Tax_Amount__c,Service_Type__c,Revenue_Type__c,Department__c,Amount_AED__c,Tax_Amount_AED__c,Tax__c FROM Invoice_Line_Items__r WHERE Is_From_Adjustment__c = false AND RecordType.Name != 'Adjustment') FROM Invoice__c 
                                WHERE RecordType.Name = 'Credit Memo' AND Oracle_Invoice_Id__c != null AND Journal_Created__c = false AND Status__c != 'Cancelled' AND Total_Invoice_Amount_OC__c != 0]){
                                     lstInvoice.add(objJH);    
                                 }
        return lstInvoice;
    }
    global void execute(Database.BatchableContext BC,List<Invoice__c> lstInvoice){
            
            //BM_JournalEntryEngine.creditMemoCreationJournal(new List<Id>{objJH.Id});
            
            List<Journal_Entry__c> journalsToInsert = new List<Journal_Entry__c>();
            //List<Journal_Entry__c> jeCreationList = new List<Journal_Entry__c>();
            Map<String,String> jeAccounts = new Map<String,String>{'Unapplied' => 'Credit','Revenue'=> 'Debit', 'Tax'=> 'Debit'};
                Map<String, Map<String,GL_Combination_Setting__c>> glCombinationMap = new Map<String, Map<String,GL_Combination_Setting__c>>{'Unapplied' => new Map<String,GL_Combination_Setting__c>(), 'Revenue' => new Map<String,GL_Combination_Setting__c>(), 'Tax' => new Map<String,GL_Combination_Setting__c>(), 'Cost_Centre' => new Map<String,GL_Combination_Setting__c>(), 'Program' => new Map<String,GL_Combination_Setting__c>(), 'Project' => new Map<String,GL_Combination_Setting__c>()};
                    for(GL_Combination_Setting__c eachGLCombinaton : [SELECT Id,Account_Type__c,Code__c,Journal_Entry_Account__c,Lookup_Code_Meaning__c,Payment_Currency__c,Related_Service_Type__c,Recordtype.DeveloperName FROM GL_Combination_Setting__c WHERE Related_Object__c INCLUDES('Invoice') AND Active__c = true]){
                        if(eachGLCombinaton.Recordtype.DeveloperName == 'Account'){
                            if(eachGLCombinaton.Journal_Entry_Account__c == 'Unapplied'){glCombinationMap.get('Unapplied').put('Unapplied', eachGLCombinaton);
                                                                                        }else if(eachGLCombinaton.Journal_Entry_Account__c == 'Revenue'){glCombinationMap.get('Revenue').put(eachGLCombinaton.Related_Service_Type__c, eachGLCombinaton);
                                                                                                                                                        }else if(eachGLCombinaton.Journal_Entry_Account__c == 'Tax'){glCombinationMap.get('Tax').put('Tax', eachGLCombinaton);
                                                                                                                                                                                                                    }
                        }else if(eachGLCombinaton.Recordtype.DeveloperName == 'Cost_Centre'){glCombinationMap.get('Cost_Centre').put(eachGLCombinaton.Lookup_Code_Meaning__c, eachGLCombinaton);
                                                                                            }else if(eachGLCombinaton.Recordtype.DeveloperName == 'Program'){glCombinationMap.get('Program').put(eachGLCombinaton.Lookup_Code_Meaning__c, eachGLCombinaton);
                                                                                                                                                            }else if(eachGLCombinaton.Recordtype.DeveloperName == 'Project'){glCombinationMap.get('Project').put(eachGLCombinaton.Lookup_Code_Meaning__c, eachGLCombinaton);
                                                                                                                                                                                                                            }
                    }
            System.debug('glCombinationMap===='+glCombinationMap);
            Map<String, Journal_Header__c> journalHeaderMap = new Map<String, Journal_Header__c>();
            Map<String, List<Journal_Entry__c>> journalEntryMap = new Map<String, List<Journal_Entry__c>>();
            Journal_Header_Running_Number__c headerRunningNumber = Journal_Header_Running_Number__c.getValues('Next Running Number');
            Integer runningNumber = Integer.valueOf(headerRunningNumber.running_Number__c);
            
            List<Invoice__c> invoiceLst = new List<Invoice__c>();
            for(Invoice__c eachInvoice : lstInvoice){
                invoiceLst.add(new Invoice__c(Id = eachInvoice.Id, Journal_Created__c = true));
                Journal_Header__c jhObj = new Journal_Header__c();
                jhObj.Name = 'JV' + '-' + runningNumber;
                jhObj.Transaction_Type__c = 'Credit Memos';
                jhObj.Invoice__c = eachInvoice.Id;
                jhObj.Reference_Id__c = eachInvoice.Id;
                jhObj.Reference_Name__c = eachInvoice.Name;
                jhObj.Entity_Name__c = eachInvoice.Entity__r.Name;
                jhObj.Account__c = eachInvoice.Entity__c;
                jhObj.GL_Date__c = eachInvoice.GL_Date__c.date();
                jhObj.Sync_Not_Required__c = true;
                journalHeaderMap.put(jhObj.Name, jhObj);
                
                runningNumber++;
                Integer count = 1;
                
                Journal_Entry__c je = new Journal_Entry__c(Invoice__c = String.valueOf(eachInvoice.Id),
                                                           Account__c = 'Unapplied',
                                                           GL_Date__c = eachInvoice.GL_Date__c.date(),
                                                           Entity__c = eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c,
                                                           Entity_Description__c = eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c,
                                                           Account_Segment__c = glCombinationMap.get('Unapplied').get('Unapplied').Code__c,
                                                           Account_Segment_Description__c = glCombinationMap.get('Unapplied').get('Unapplied').Lookup_Code_Meaning__c,
                                                           Credit_OC__c = (eachInvoice.Total_Invoice_Amount_OC__c * -1),
                                                           currency__c = eachInvoice.payment_currency__c,
                                                           conversion_rate__c = eachInvoice.conversion_rate__c,
                                                           Name = jhObj.Name + '-' + count,
                                                           Tax_Rate_Code__c = '');
                je.journal_header__c = jhObj.Id;
                je.Operating_Unit_Name__c = eachInvoice.Entity__r.Operating_unit__r.OU_Abbreviation__c;
                List<Journal_Entry__c> tempLst = journalEntryMap.get(jhObj.Name);
                if(tempLst == NULL){tempLst = new List<Journal_Entry__c>();}
                tempLst.add(je);journalEntryMap.put(jhObj.Name, tempLst);count++;
                for(Invoice_Line_Item__c eachLine : eachInvoice.Invoice_Line_Items__r){
                    system.debug('eachLine.Revenue_Type__c==>>' + eachLine.Revenue_Type__c);
                    if(glCombinationMap.containsKey('Revenue') && !glCombinationMap.get('Revenue').containsKey(eachLine.Revenue_Type__c)){
                        journalHeaderMap.remove(jhObj.Name);
                        runningNumber--;
                        //invoiceLst.add(new Invoice__c(Id = eachInvoice.Id, Journal_Created__c = false, Oracle_Response_Message__c = 'Revenue Mapping ' + eachLine.Revenue_Type__c + ' missing in classification for ' + eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c));
                        break;
                    }
                    
                    //Journal_Entry__c jeSub1 = createJournalLines(/*obj*/'Invoice',/*Object Lookup*/String.valueOf(eachInvoice.Id),/*Account*/'Revenue',/*GL Date*/eachInvoice.GL_Date__c.date(),/*entity Code*/eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c,/*entity Description*/eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c,/*AccountSeg Code*/glCombinationMap.get('Revenue').get(eachLine.Revenue_Type__c).Code__c,/*AccountSeg Desc*/glCombinationMap.get('Revenue').get(eachLine.Revenue_Type__c).Lookup_Code_Meaning__c,/*debitOC*/(eachLine.Amount__c * -1),/*creditOC*/0,/*csCode*/glCombinationMap.get('Cost_Centre').get(eachLine.Department__c).Code__c,/*csDesc*/glCombinationMap.get('Cost_Centre').get(eachLine.Department__c).Lookup_Code_Meaning__c,eachInvoice.payment_currency__c,eachInvoice.conversion_rate__c,jhObj.Name + '-' + count,eachLine.Tax__c);
                    Journal_Entry__c jeSub1 = new Journal_Entry__c(Invoice__c = eachInvoice.Id,
                                                                   Account__c = 'Revenue',
                                                                   GL_Date__c = eachInvoice.GL_Date__c.date(),
                                                                   Entity__c = eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c,
                                                                   Entity_Description__c = eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c,
                                                                   Account_Segment__c = glCombinationMap.get('Revenue').get(eachLine.Revenue_Type__c).Code__c,
                                                                   Account_Segment_Description__c = glCombinationMap.get('Revenue').get(eachLine.Revenue_Type__c).Lookup_Code_Meaning__c,
                                                                   Debit_OC__c = (eachLine.Amount__c * -1),
                                                                   Cost_center__c = String.isNotBlank(eachLine.Department__c) ? glCombinationMap.get('Cost_Centre').get(eachLine.Department__c).Code__c : '000',
                                                                   Cost_center_Description__c = String.isNotBlank(eachLine.Department__c) ? glCombinationMap.get('Cost_Centre').get(eachLine.Department__c).Lookup_Code_Meaning__c : 'None',
                                                                   currency__c = eachInvoice.payment_currency__c,
                                                                   conversion_rate__c = eachInvoice.conversion_rate__c,
                                                                   Name = jhObj.Name + '-' + count,
                                                                   Tax_Rate_Code__c = eachLine.Tax__c);
                    system.debug('eachInvoice.Entity__r.Is_Intercompany__c==>>' + eachInvoice.Entity__r.Is_Intercompany__c);
                    system.debug('eachInvoice.Entity__r.Intercompany_OU__r.Entity_Code__c==>>' + eachInvoice.Entity__r.Intercompany_OU__r.Entity_Code__c);
                    if(eachInvoice.Entity__r.Is_Intercompany__c){
                        jeSub1.Inter_company__c = eachInvoice.Entity__r.Intercompany_OU__r.Entity_Code__c;jeSub1.Inter_company_Description__c = eachInvoice.Entity__r.Intercompany_OU__r.OU_Abbreviation__c;
                    }
                    
                    jeSub1.journal_header__c = jhObj.Id;
                    jeSub1.Operating_Unit_Name__c = eachInvoice.Entity__r.Operating_unit__r.OU_Abbreviation__c;
                    
                    tempLst = journalEntryMap.get(jhObj.Name);
                    if(tempLst == NULL){tempLst = new List<Journal_Entry__c>();}
                    tempLst.add(jeSub1);journalEntryMap.put(jhObj.Name, tempLst);count++;
                    if(eachLine.Tax__c != 'Out of scope 0%'){
                        //Journal_Entry__c jeSub2 = createJournalLines('Invoice', eachInvoice.Id, 'Tax', eachInvoice.GL_Date__c.date(), eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c, eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c, glCombinationMap.get('Tax').get('Tax').Code__c,glCombinationMap.get('Tax').get('Tax').Lookup_Code_Meaning__c, (eachLine.Tax_Amount__c * -1), 0, null, null,eachInvoice.payment_currency__c,eachInvoice.conversion_rate__c,jhObj.Name + '-' + count,eachLine.Tax__c);
                        Journal_Entry__c jeSub2 = new Journal_Entry__c(Invoice__c = eachInvoice.Id,
                                                                       Account__c = 'Tax',
                                                                       GL_Date__c = eachInvoice.GL_Date__c.date(),
                                                                       Entity__c = eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c,
                                                                       Entity_Description__c = eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c,
                                                                       Account_Segment__c = glCombinationMap.get('Tax').get('Tax').Code__c,
                                                                       Account_Segment_Description__c = glCombinationMap.get('Tax').get('Tax').Lookup_Code_Meaning__c,
                                                                       Debit_OC__c = (eachLine.Tax_Amount__c * -1),
                                                                       currency__c = eachInvoice.payment_currency__c,
                                                                       conversion_rate__c = eachInvoice.conversion_rate__c,
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
            if(!invoiceLst.isEmpty()){ UPDATE invoiceLst;}
            
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