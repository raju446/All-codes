/**
* @description       : Utility class to generate Journal Lines
* @author            : PwC
* @group             : 
* @last modified on  : 26-09-2021
* @last modified by  : Prateek Bansal
* Version History
* SR No.    Author                          Date of Change          Change
* 1.        anu.saxena@pwc.com              27 Sept'2021            Added method to create journal lines for invoice.
* 2.        prateek.b.bansal@pwc.com        27 Sept'2021            Added method to create journal lines for adjustment.
**/

public class BM_JournalEntryEngine {
    public static List<Journal_Entry__c> journalsToInsert;
    public static Map<String, Map<String,GL_Combination_Setting__c>> glCombinationMap;
    public static Map<String, Journal_Header__c> journalHeaderMap;
    public static Map<String, List<Journal_Entry__c>> journalEntryMap;
    
    @AuraEnabled
    public static ResponseWrapper fetchRecordDetails(String recId){
        ResponseWrapper resWrap = new ResponseWrapper();
        String objectType = (String.isNotEmpty(recId))?Id.valueOf(recId).getSobjectType().getDescribe().getName():'';
        String soqlQuery = 'SELECT Id,Name,Journal_Created__c,Status__c FROM '+objectType+' WHERE Id =: recId';
        if(objectType == 'Receipt__c'){
            Receipt__c rpt = database.query(soqlQuery);
            resWrap.objType = 'Receipt__c'; resWrap.isJournalAlreadyCreated = rpt.Journal_Created__c; resWrap.Status = rpt.Status__c; resWrap.recId = rpt.Id;}
        else if(objectType == 'Fund_Transfer__c'){
            Fund_Transfer__c ft = database.query(soqlQuery);
            resWrap.objType = 'Fund_Transfer__c'; resWrap.isJournalAlreadyCreated = ft.Journal_Created__c; resWrap.Status = ft.Status__c; resWrap.recId = ft.Id;}
        else if(objectType == 'Refund__c'){
            Refund__c ref = database.query(soqlQuery);
            resWrap.objType = 'Refund__c'; resWrap.isJournalAlreadyCreated = ref.Journal_Created__c; resWrap.Status = ref.Status__c; resWrap.recId = ref.Id;}
        else if(objectType == 'Invoice_Line_Item__c'){
            Invoice_Line_Item__c ilt = database.query(soqlQuery);
            resWrap.objType = 'Invoice_Line_Item__c'; resWrap.isJournalAlreadyCreated = ilt.Journal_Created__c; resWrap.Status = ilt.Status__c; resWrap.recId = ilt.Id;}
        else if(objectType == 'Related_Invoice_Receipt__c'){
            Related_Invoice_Receipt__c rir = database.query(soqlQuery); 
            resWrap.objType = 'Related_Invoice_Receipt__c'; resWrap.isJournalAlreadyCreated = rir.Journal_Created__c; resWrap.Status = rir.Status__c; resWrap.recId = rir.Id;}
        else if(objectType == 'Invoice__c'){
            Invoice__c inv = database.query(soqlQuery);
            resWrap.objType = 'Invoice__c'; resWrap.isJournalAlreadyCreated = inv.Journal_Created__c; resWrap.Status = inv.Status__c; resWrap.recId = inv.Id;}
        
        // return [select id,name,Status__c,Journal_Created__c,Sys_Oracle_Party_Id__c from Invoice__c where Id =: invoiceId];
        return resWrap;
    }
    @AuraEnabled
    public static String createJournalEntries(String recordId, String objectType){
        String str = null;
        if(objectType == 'Receipt__c'){
            receiptCreationJournal(new List<Id> {recordId});
        }
        else if(objectType == 'Fund_Transfer__c'){
            fundTransferJournalEntries(new List<Id> {recordId});
            }
        else if(objectType == 'Refund__c'){ 
            refundJournalLines(new List<Id> {recordId});
            }
        else if(objectType == 'Invoice_Line_Item__c'){ 
            }
        else if(objectType == 'Related_Invoice_Receipt__c'){
            }
        else if(objectType == 'Invoice__c'){
            List<Invoice__c> invoiceLst = new List<Invoice__c>();
            invoiceLst.add(new Invoice__c(Id = recordId, Journal_Created__c = true, Status__c = 'Invoiced'));
            UPDATE invoiceLst;
            invoiceCreationJournal(new List<Id>{recordId});
        }
        return str; 
    }
    
    
    public static set<Date> getActiveGLDates(){
        Map<String, Integer> monthMap = new Map<String, Integer>{'January'=>1, 'February'=>2, 'March'=>3, 'April'=>4, 'May'=>5, 'June'=>6, 'July'=>7, 
                                                                 'August'=>8, 'September'=>9, 'October'=>10, 'November'=>11, 'December'=>12 };
        set<Date> availableDates = new set<Date>();
        for(GL_Period_Configuration__c glConfig : [SELECT Id, Month__c, Year__c, Active__c FROM GL_Period_Configuration__c WHERE Active__c = true]){
            Date dt = Date.newInstance(Integer.valueOf(glConfig.Year__c), monthMap.get(glConfig.month__c), 1);
            Integer numberOfDays = Date.daysInMonth(dt.year(), dt.month());
            for(Integer i = 0; i < numberOfDays; i++){
                availableDates.add(dt.addDays(i));
            }
        }
        system.debug('availableDates==='+availableDates);
        return availableDates;
    }
    
    public static Integer getJournalRunningNumber(){
        Journal_Header_Running_Number__c headerRunningNumber = Journal_Header_Running_Number__c.getValues('Next Running Number');
        return Integer.valueOf(headerRunningNumber.running_Number__c);
        
    }
    
    public static void updateJournalRunningNumber(Integer runningNumber){
        Journal_Header_Running_Number__c headerRunningNumber = Journal_Header_Running_Number__c.getValues('Next Running Number');
        headerRunningNumber.running_Number__c = runningNumber;
        UPDATE headerRunningNumber;
    }
    
    public static void insertJournalRecords(){
        INSERT journalHeaderMap.values();
        
        List<Journal_Entry__c> insertJournalEntries = new List<Journal_Entry__c>();
        for(String key : journalEntryMap.keySet()){
            for(Journal_Entry__c jeObj : journalEntryMap.get(key)){
                jeObj.Journal_Header__c = journalHeaderMap.get(key).Id;
                insertJournalEntries.add(jeObj);
            }
        }
        INSERT insertJournalEntries;
    }
    
    /**
* @description : Insert Journal Lines on Invoice Creation
* @author Prateek Bansal | 26-09-2021 
* @param List<Id> invoiceLineIds 
* Testing Lines:
* List<Invoice_Line_Item__c> lineItemLst = [SELECT Id, Calculated_Amount_AED__c, Activity_Name__c, Is_From_Adjustment__c, Invoice__r.Id, Invoice__r.GL_Date__c, Invoice__r.Entity__r.Operating_unit__r.Entity_Code__c, Invoice__r.Total_Invoice_Amount_AED__c, Invoice__r.Entity__r.Operating_unit__r.Operating_Unit_Name__c, Invoice__r.Conversion_Rate__c FROM Invoice_Line_Item__c WHERE Id = 'a2O25000002SVN7EAO'];
* BM_JournalEntryEngine.invoiceAdjustmentCreationJournal(lineItemLst);
**/
    
    public static void invoiceAdjustmentCreationJournal(List<Id> invoiceLineItemIds){
        journalsToInsert = new List<Journal_Entry__c>();
        List<Invoice_Line_Item__c> discountedLines = [SELECT Id, Line_Description__c, Name, Amount__c, Calculated_Amount_AED__c, Activity_Name__c, Is_From_Adjustment__c, Invoice__r.Id, Invoice__r.GL_Date__c,Tax__c, 
                                                      Invoice__r.Entity__r.Operating_unit__r.Entity_Code__c, Invoice__r.Entity__r.Operating_unit__r.OU_Abbreviation__c, Invoice__r.Total_Invoice_Amount_AED__c, 
                                                      Invoice__r.Entity__r.Operating_unit__r.Operating_Unit_Name__c, Invoice__r.Entity__r.Name, Invoice__r.Conversion_Rate__c, Invoice__r.Payment_Currency__c 
                                                      FROM Invoice_Line_Item__c WHERE Id IN :  invoiceLineItemIds];
        if(!discountedLines.isEmpty()){
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
            
            Savepoint sp;
            sp = Database.setSavepoint();
            Integer runningNumber = getJournalRunningNumber();
            try{
                
                
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
                INSERT jhObj;
                Integer count = 1;
                for(Invoice_Line_Item__c lineItem : discountedLines){
                    Journal_Entry__c je = new Journal_Entry__c(Invoice__c = lineItem.Invoice__r.Id, Account__c = 'Receivable', GL_Date__c = lineItem.Invoice__r.GL_Date__c.date());
                    je.Name = jhObj.Name + '-' + count;
                    je.Journal_Header__c = jhObj.Id;
                    je.Currency__c = lineItem.Invoice__r.Payment_Currency__c;
                    je.Journal_Entry_Line_Description__c = lineItem.Line_Description__c;
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
                    je.Journal_Entry_Line_Description__c = lineItem.Line_Description__c;
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
                if(!journalsToInsert.isEmpty()){ insert journalsToInsert; updateJournalRunningNumber(runningNumber);}
            }catch(Exception ex){
                String sMessage = ex.getMessage();
                Log__c objLog = new Log__c();
                if(sMessage .length() > 240) {
                    objLog.Message__c = sMessage.subString(0,240);
                } else {
                    objLog.Message__c = sMessage;
                }//end if
                
                objLog.Line_Number__c = ex.getLineNumber();
                objLog.Stack_Trace__c =  ex.getStackTraceString();
                objLog.Type_Name__c = ex.getTypeName();
                insert objLog;
                Database.rollback(sp);
            }
        }
    }
    
    /**
* @description : Insert Journal Lines on Credit Memo Creation
* @author Anu Saxena | 26-09-2021 
* @param List<Id> invoiceIds 
**/
    public static void discountAdjustmentCreationJournal(List<Id> invoiceLineItemIds){
        journalsToInsert = new List<Journal_Entry__c>();
        List<Invoice_Line_Item__c> discountedLines = [SELECT Id, Name, Line_Description__c, Amount__c, Calculated_Amount_AED__c, Activity_Name__c, Is_From_Adjustment__c, Invoice__r.Id, Invoice__r.GL_Date__c,Department__c,Tax__c, 
                                                      Invoice__r.Entity__r.Operating_unit__r.Entity_Code__c, Invoice__r.Total_Invoice_Amount_AED__c, Invoice__r.Entity__r.Operating_unit__r.OU_Abbreviation__c,
                                                      Invoice__r.Entity__r.Operating_unit__r.Operating_Unit_Name__c, Invoice__r.Entity__r.Name, Invoice__r.Conversion_Rate__c, Invoice__r.Payment_Currency__c,
                                                      Revenue_Type__c FROM Invoice_Line_Item__c WHERE Id IN :  invoiceLineItemIds];
        if(!discountedLines.isEmpty()){
            Map<String, Map<String,GL_Combination_Setting__c>> glCombinationMap = new Map<String, Map<String,GL_Combination_Setting__c>>{'Receivable' => new Map<String,GL_Combination_Setting__c>(), 'Expense' => new Map<String,GL_Combination_Setting__c>(), 'Tax' => new Map<String,GL_Combination_Setting__c>(), 'Cost_Centre' => new Map<String,GL_Combination_Setting__c>(), 'Program' => new Map<String,GL_Combination_Setting__c>(), 'Project' => new Map<String,GL_Combination_Setting__c>(), 'Revenue' => new Map<String,GL_Combination_Setting__c>()};
                
                for(GL_Combination_Setting__c eachGLCombinaton : [SELECT Id,Account_Type__c,Code__c,Journal_Entry_Account__c,Lookup_Code_Meaning__c,Payment_Currency__c,
                                                                  Related_Service_Type__c,Recordtype.DeveloperName 
                                                                  FROM GL_Combination_Setting__c 
                                                                  WHERE Related_Object__c INCLUDES('Invoice') 
                                                                  AND Active__c = true]){
                                                                      if(eachGLCombinaton.Recordtype.DeveloperName == 'Cost_Centre'){glCombinationMap.get('Cost_Centre').put(eachGLCombinaton.Lookup_Code_Meaning__c, eachGLCombinaton); }
                                                                      else if(eachGLCombinaton.Recordtype.DeveloperName == 'Program'){glCombinationMap.get('Program').put(eachGLCombinaton.Lookup_Code_Meaning__c, eachGLCombinaton);}
                                                                      else if(eachGLCombinaton.Recordtype.DeveloperName == 'Project'){glCombinationMap.get('Project').put(eachGLCombinaton.Lookup_Code_Meaning__c, eachGLCombinaton);}
                                                                      else if(eachGLCombinaton.Recordtype.DeveloperName == 'Account'){
                                                                          if(eachGLCombinaton.Journal_Entry_Account__c == 'Receivable'){glCombinationMap.get('Receivable').put(eachGLCombinaton.Lookup_Code_Meaning__c, eachGLCombinaton);}
                                                                          else if(eachGLCombinaton.Journal_Entry_Account__c == 'Expense'){glCombinationMap.get('Expense').put(eachGLCombinaton.Lookup_Code_Meaning__c, eachGLCombinaton);}
                                                                          else if(eachGLCombinaton.Journal_Entry_Account__c == 'Tax'){ glCombinationMap.get('Tax').put('Tax', eachGLCombinaton);}
                                                                          else if(eachGLCombinaton.Journal_Entry_Account__c == 'Revenue'){glCombinationMap.get('Revenue').put(eachGLCombinaton.Lookup_Code_Meaning__c, eachGLCombinaton); }
                                                                      }
                                                                  }
            
            Savepoint sp;
            sp = Database.setSavepoint();
            Integer runningNumber = getJournalRunningNumber();
            try{
                
                
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
                INSERT jhObj;
                Integer count = 1;
                for(Invoice_Line_Item__c lineItem : discountedLines){
                    Journal_Entry__c je = new Journal_Entry__c(Invoice__c = lineItem.Invoice__r.Id, Account__c = 'Receivable', GL_Date__c = lineItem.Invoice__r.GL_Date__c.date());
                    je.Name = jhObj.Name + '-' + count;
                    je.Journal_Header__c = jhObj.Id;
                    je.Journal_Entry_Line_Description__c = lineItem.Line_Description__c;
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
                    
                    je = new Journal_Entry__c(Invoice__c = lineItem.Invoice__r.Id, Account__c = 'Revenue', GL_Date__c = lineItem.Invoice__r.GL_Date__c.date());
                    je.Name = jhObj.Name + '-' + count;
                    je.Journal_Header__c = jhObj.Id;
                    je.Journal_Entry_Line_Description__c = lineItem.Line_Description__c;
                    je.Currency__c = lineItem.Invoice__r.Payment_Currency__c;
                    je.Conversion_Rate__c = lineItem.Invoice__r.Conversion_Rate__c;
                    je.Entity__c = lineItem.Invoice__r.Entity__r.Operating_unit__r.Entity_Code__c;
                    je.Entity_Description__c = lineItem.Invoice__r.Entity__r.Operating_unit__r.Operating_Unit_Name__c;
                    je.Operating_Unit_Name__c = lineItem.Invoice__r.Entity__r.Operating_unit__r.OU_Abbreviation__c;
                    system.debug('lineItem.Revenue_Type__c==>>' + lineItem.Revenue_Type__c);
                    system.debug('map output==>>' + glCombinationMap.get('Revenue').get(lineItem.Revenue_Type__c).Code__c);
                    je.Account_Segment__c = glCombinationMap.get('Revenue').get(lineItem.Revenue_Type__c).Code__c;
                    je.Account_Segment_Description__c = glCombinationMap.get('Revenue').get(lineItem.Revenue_Type__c).Lookup_Code_Meaning__c;
                    je.Cost_center__c = glCombinationMap.get('Cost_Centre').get(lineItem.Department__c).Code__c;
                    je.Cost_center_Description__c = glCombinationMap.get('Cost_Centre').get(lineItem.Department__c).Lookup_Code_Meaning__c;
                    je.Invoice__c = lineItem.Invoice__r.Id;
                    je.Debit_OC__c = lineItem.Amount__c;
                    je.Tax_Rate_Code__c = lineItem.Tax__c;
                    journalsToInsert.add(je);
                    count++;
                }
                system.debug('journalsToInsert==>>' + journalsToInsert);
                if(!journalsToInsert.isEmpty()){insert journalsToInsert; updateJournalRunningNumber(runningNumber);
                }
            }catch(Exception ex){
                String sMessage = ex.getMessage();
                Log__c objLog = new Log__c();
                if(sMessage .length() > 240) {
                    objLog.Message__c = sMessage.subString(0,240);
                } else {
                    objLog.Message__c = sMessage;
                }//end if
                
                objLog.Line_Number__c = ex.getLineNumber();
                objLog.Stack_Trace__c =  ex.getStackTraceString();
                objLog.Type_Name__c = ex.getTypeName();
                insert objLog;
                Database.rollback(sp);
            }
        }
    }
    
    /**
* @description : Insert Journal Lines on Credit Memo Creation
* @author Anu Saxena | 26-09-2021 
* @param List<Id> invoiceIds 
**/
    public static void creditMemoCreationJournal(List<Id> invoiceIds){
        Savepoint sp;
        try{
            
            journalsToInsert = new List<Journal_Entry__c>();
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
            sp = Database.setSavepoint();
            System.debug('glCombinationMap===='+glCombinationMap);
            journalHeaderMap = new Map<String, Journal_Header__c>();
            journalEntryMap = new Map<String, List<Journal_Entry__c>>();
            Integer runningNumber = getJournalRunningNumber();
            
            List<Invoice__c> invoiceLst = new List<Invoice__c>();
            for(Invoice__c eachInvoice : [SELECT Id,Name,Total_Invoice_Amount_OC__c,GL_Date__c,Entity__r.Operating_unit__r.Entity_Code__c,Entity__r.Operating_unit__r.OU_Abbreviation__c,  Entity__r.Intercompany_OU__c, Entity__r.Intercompany_OU__r.Entity_Code__c,
                                          Entity__r.Operating_unit__r.Operating_Unit_Name__c,Entity__r.Name,Total_Invoice_Amount_Rollup__c,Total_Invoice_Amount_AED__c,Conversion_Rate__c,Payment_Currency__c, Entity__r.Is_Intercompany__c,Entity__r.Intercompany_OU__r.OU_Abbreviation__c,
                                          (SELECT Id,Line_Description__c, Amount__c,Tax_Amount__c,Service_Type__c,Service_Class__c,Revenue_Type__c,Department__c,Amount_AED__c,Tax_Amount_AED__c,Tax__c FROM Invoice_Line_Items__r
                                           WHERE Recordtype.DeveloperName = 'Invoice_Line_Item') FROM Invoice__c WHERE Id IN : invoiceIds LIMIT 1]){
                
                Journal_Header__c jhObj = new Journal_Header__c();
                jhObj.Name = 'JV' + '-' + runningNumber;
                jhObj.Transaction_Type__c = 'Credit Memos';
                jhObj.Invoice__c = eachInvoice.Id;
                jhObj.Reference_Id__c = eachInvoice.Id;
                jhObj.Reference_Name__c = eachInvoice.Name;
                jhObj.Entity_Name__c = eachInvoice.Entity__r.Name;
                jhObj.Account__c = eachInvoice.Entity__c;
                jhObj.GL_Date__c = eachInvoice.GL_Date__c.date();
                journalHeaderMap.put(jhObj.Name, jhObj);
                
                runningNumber++;
                Integer count = 1;
                
                Journal_Entry__c je = createJournalLines(/*obj*/'Invoice',/*Object Lookup*/String.valueOf(eachInvoice.Id),/*Account*/'Unapplied',/*GL Date*/eachInvoice.GL_Date__c.date(),/*entity Code*/eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c,/*entity Description*/eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c,/*AccountSeg Code*/glCombinationMap.get('Unapplied').get('Unapplied').Code__c,/*AccountSeg Desc*/glCombinationMap.get('Unapplied').get('Unapplied').Lookup_Code_Meaning__c,/*debitOC*/0,/*creditOC*/(eachInvoice.Total_Invoice_Amount_OC__c * -1).setScale(2),/*csCode*/null,/*csDesc*/null,eachInvoice.payment_currency__c,eachInvoice.conversion_rate__c,jhObj.Name + '-' + count,'');
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
                        invoiceLst.add(new Invoice__c(Id = eachInvoice.Id, Journal_Created__c = false, Oracle_Response_Message__c = 'Revenue Mapping ' + eachLine.Revenue_Type__c + ' missing in classification for ' + eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c));
                        break;
                    }
                    
                    Journal_Entry__c jeSub1 = createJournalLines(/*obj*/'Invoice',/*Object Lookup*/String.valueOf(eachInvoice.Id),/*Account*/'Revenue',/*GL Date*/eachInvoice.GL_Date__c.date(),/*entity Code*/eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c,/*entity Description*/eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c,/*AccountSeg Code*/glCombinationMap.get('Revenue').get(eachLine.Revenue_Type__c).Code__c,/*AccountSeg Desc*/glCombinationMap.get('Revenue').get(eachLine.Revenue_Type__c).Lookup_Code_Meaning__c,/*debitOC*/(eachLine.Amount__c * -1).setScale(2),/*creditOC*/0,/*csCode*/glCombinationMap.get('Cost_Centre').get(eachLine.Department__c).Code__c,/*csDesc*/glCombinationMap.get('Cost_Centre').get(eachLine.Department__c).Lookup_Code_Meaning__c,eachInvoice.payment_currency__c,eachInvoice.conversion_rate__c,jhObj.Name + '-' + count,eachLine.Tax__c);
                    if(eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c == '03' && eachLine.Revenue_Type__c == 'Data Protection Fee'){
                        jeSub1.Cost_center__c = '205';
                    }
                    system.debug('eachInvoice.Entity__r.Is_Intercompany__c==>>' + eachInvoice.Entity__r.Is_Intercompany__c);
                    system.debug('eachInvoice.Entity__r.Intercompany_OU__r.Entity_Code__c==>>' + eachInvoice.Entity__r.Intercompany_OU__r.Entity_Code__c);
                    if(eachInvoice.Entity__r.Is_Intercompany__c){
                        jeSub1.Inter_company__c = eachInvoice.Entity__r.Intercompany_OU__r.Entity_Code__c;jeSub1.Inter_company_Description__c = eachInvoice.Entity__r.Intercompany_OU__r.OU_Abbreviation__c;
                    }
                    jeSub1.Journal_Entry_Line_Description__c = eachLine.Service_Type__c + ' | ' + eachLine.Service_Class__c + ' | ' + eachLine.Line_Description__c;
                    jeSub1.journal_header__c = jhObj.Id;
                    jeSub1.Operating_Unit_Name__c = eachInvoice.Entity__r.Operating_unit__r.OU_Abbreviation__c;
                    
                    tempLst = journalEntryMap.get(jhObj.Name);
                    if(tempLst == NULL){tempLst = new List<Journal_Entry__c>();}
                    tempLst.add(jeSub1);journalEntryMap.put(jhObj.Name, tempLst);count++;
                    if(eachLine.Tax__c != 'Out of scope 0%'){
                        Journal_Entry__c jeSub2 = createJournalLines('Invoice', eachInvoice.Id, 'Tax', eachInvoice.GL_Date__c.date(), eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c, eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c, glCombinationMap.get('Tax').get('Tax').Code__c,glCombinationMap.get('Tax').get('Tax').Lookup_Code_Meaning__c, eachLine.Tax_Amount__c != null ? (eachLine.Tax_Amount__c * -1).setScale(2) : 0, 0, null, null,eachInvoice.payment_currency__c,eachInvoice.conversion_rate__c,jhObj.Name + '-' + count,eachLine.Tax__c);
                        jeSub2.journal_header__c = jhObj.Id;
                        jeSub2.Operating_Unit_Name__c = eachInvoice.Entity__r.Operating_unit__r.OU_Abbreviation__c;
                        jeSub2.Journal_Entry_Line_Description__c = eachLine.Service_Type__c + ' | ' + eachLine.Service_Class__c + ' | ' + eachLine.Line_Description__c;
                        tempLst = journalEntryMap.get(jhObj.Name);
                        if(tempLst == NULL){tempLst = new List<Journal_Entry__c>();}
                        tempLst.add(jeSub2);journalEntryMap.put(jhObj.Name, tempLst);count++;
                    }
                }
            }
            if(!invoiceLst.isEmpty()){ UPDATE invoiceLst;}
            
            if(!journalHeaderMap.keySet().isEmpty()){insertJournalRecords();updateJournalRunningNumber(runningNumber);}
        } catch(Exception ex){
            system.debug('====>'+ex.getMessage());   
            system.debug('====>'+ex.getLineNumber());
            String sMessage = ex.getMessage();
            Log__c objLog = new Log__c();
            if(sMessage .length() > 240) {
                objLog.Message__c = sMessage.subString(0,240);
            } else {
                objLog.Message__c = sMessage;
            }//end if
            
            objLog.Line_Number__c = ex.getLineNumber();
            objLog.Stack_Trace__c =  ex.getStackTraceString();
            objLog.Type_Name__c = ex.getTypeName();
            insert objLog;
            Database.rollback(sp);
        }
    }
    
    
    
    /**
* @description : Insert Journal Lines on Invoice Creation
* @author Anu Saxena | 26-09-2021 
* @param List<Id> invoiceIds 
**/
    public static void invoiceCreationJournal(List<Id> invoiceIds){
        Savepoint sp;
        try{
            journalsToInsert = new List<Journal_Entry__c>();
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
            sp = Database.setSavepoint();
            
            journalHeaderMap = new Map<String, Journal_Header__c>();
            journalEntryMap = new Map<String, List<Journal_Entry__c>>();
            Integer runningNumber = getJournalRunningNumber();
            
            List<Invoice__c> invoiceLst = new List<Invoice__c>();
            for(Invoice__c eachInvoice : [SELECT Id,Name,GL_Date__c,Total_Invoice_Amount_OC__c,Entity__r.Operating_unit__r.Entity_Code__c,Entity__r.Operating_unit__r.Operating_Unit_Name__c,Source_Invoice_Id__c,  Entity__r.Intercompany_OU__c, Entity__r.Intercompany_OU__r.Entity_Code__c,
                                          Entity__r.Operating_unit__r.OU_Abbreviation__c,Entity__r.Name,Total_Invoice_Amount_Rollup__c,Total_Invoice_Amount_AED__c,Conversion_Rate__c,Payment_Currency__c,Entity__r.Is_Intercompany__c,Entity__r.Intercompany_OU__r.OU_Abbreviation__c,
                                          (SELECT Id,Amount__c,Line_Description__c,Tax_Amount__c,Service_Type__c,Service_Class__c, Revenue_Type__c,Department__c,Amount_AED__c,Tax_Amount_AED__c,Tax__c,Is_Discount__c FROM Invoice_Line_Items__r 
                                           WHERE Recordtype.DeveloperName = 'Invoice_Line_Item') FROM Invoice__c WHERE Id IN : invoiceIds]){
                
                Journal_Header__c jhObj = new Journal_Header__c();
                jhObj.Name = 'JV' + '-' + runningNumber;
                jhObj.Transaction_Type__c = 'Sales Invoices';
                jhObj.Invoice__c = eachInvoice.Id;
                jhObj.Reference_Id__c = eachInvoice.Id;
                jhObj.Reference_Name__c = eachInvoice.Source_Invoice_Id__c;
                jhObj.Entity_Name__c = eachInvoice.Entity__r.Name;
                jhObj.Account__c = eachInvoice.Entity__c;
                jhObj.GL_Date__c = eachInvoice.GL_Date__c.date();
                journalHeaderMap.put(jhObj.Name, jhObj);
                
                runningNumber++;
                Integer count = 1;
                Journal_Entry__c je = createJournalLines('Invoice',
                                                         /*Object Lookup*/String.valueOf(eachInvoice.Id),
                                                         /*Account*/'Receivable',
                                                         /*GL Date*/eachInvoice.GL_Date__c.date(),
                                                         /*entity Code*/eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c,
                                                         /*entity Description*/eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c,
                                                         /*AccountSeg Code*/glCombinationMap.get('Receivable').get('Receivable').Code__c,
                                                         /*AccountSeg Desc*/glCombinationMap.get('Receivable').get('Receivable').Lookup_Code_Meaning__c,
                                                         /*debitOC*/(eachInvoice.Total_Invoice_Amount_OC__c).setScale(2),
                                                         /*creditOC*/null,
                                                         /*csCode*/null,
                                                         /*csDesc*/null,
                                                         eachInvoice.Payment_Currency__c,
                                                         eachInvoice.Conversion_Rate__c,
                                                         jhObj.Name + '-' + count,
                                                         '');
                je.journal_header__c = jhObj.Id;
                je.Operating_Unit_Name__c = eachInvoice.Entity__r.Operating_unit__r.OU_Abbreviation__c;
                                               
                List<Journal_Entry__c> tempLst = journalEntryMap.get(jhObj.Name);
                if(tempLst == NULL){tempLst = new List<Journal_Entry__c>();}
                tempLst.add(je);
                journalEntryMap.put(jhObj.Name, tempLst);
                count++;
                for(Invoice_Line_Item__c eachLine : eachInvoice.Invoice_Line_Items__r){
                    system.debug('eachLine.Revenue_Type__c==>>' + eachLine.Revenue_Type__c);
                    if(glCombinationMap.containsKey('Revenue') && !glCombinationMap.get('Revenue').containsKey(eachLine.Revenue_Type__c)){
                        journalHeaderMap.remove(jhObj.Name);runningNumber--;
                        invoiceLst.add(new Invoice__c(Id = eachInvoice.Id, Journal_Created__c = false, Status__c = 'Error', Oracle_Response_Message__c = 'Revenue Mapping ' + eachLine.Revenue_Type__c + ' missing in classification for ' + eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c));
                        break;
                    }
                    if(eachLine.Is_Discount__c){
                        Journal_Entry__c jeSub1 =  createJournalLines('Invoice', 
                                                                      eachInvoice.Id, 
                                                                      'Revenue', 
                                                                      eachInvoice.GL_Date__c.date(), 
                                                                      eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c, 
                                                                      eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c, 
                                                                      glCombinationMap.get('Revenue').get(eachLine.Revenue_Type__c).Code__c,  
                                                                      glCombinationMap.get('Revenue').get(eachLine.Revenue_Type__c).Lookup_Code_Meaning__c, 
                                                                      (eachLine.Amount__c).setScale(2), 
                                                                      null, 
                                                                      glCombinationMap.get('Cost_Centre').get(eachLine.Department__c).Code__c, 
                                                                      glCombinationMap.get('Cost_Centre').get(eachLine.Department__c).Lookup_Code_Meaning__c,
                                                                      eachInvoice.Payment_Currency__c,
                                                                      eachInvoice.Conversion_Rate__c,
                                                                      jhObj.Name + '-' + count,
                                                                      eachLine.Tax__c);
                        if(eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c == '03' && eachLine.Revenue_Type__c == 'Data Protection Fee'){
                            jeSub1.Cost_center__c = '205';
                        }
                        system.debug('eachInvoice.Entity__r.Is_Intercompany__c==>>' + eachInvoice.Entity__r.Is_Intercompany__c);
                        system.debug('eachInvoice.Entity__r.Intercompany_OU__r.Entity_Code__c==>>' + eachInvoice.Entity__r.Intercompany_OU__r.Entity_Code__c);
                        if(eachInvoice.Entity__r.Is_Intercompany__c){
                            jeSub1.Inter_company__c = eachInvoice.Entity__r.Intercompany_OU__r.Entity_Code__c;
                            jeSub1.Inter_company_Description__c = eachInvoice.Entity__r.Intercompany_OU__r.OU_Abbreviation__c;
                        }
                        jeSub1.journal_header__c = jhObj.Id;
                        jeSub1.Journal_Entry_Line_Description__c = eachLine.Service_Type__c + ' | ' + eachLine.Service_Class__c + ' | ' + eachLine.Line_Description__c;
                        jeSub1.Operating_Unit_Name__c = eachInvoice.Entity__r.Operating_unit__r.OU_Abbreviation__c;
                        tempLst = journalEntryMap.get(jhObj.Name);
                        if(tempLst == NULL){tempLst = new List<Journal_Entry__c>();}
                        tempLst.add(jeSub1);
                        journalEntryMap.put(jhObj.Name, tempLst);
                        count++;
                        if(eachLine.Tax__c != 'Out of scope 0%' || eachLine.Tax__c != 'Exempt 0%'){
                            Journal_Entry__c jeSub2 = createJournalLines('Invoice', eachInvoice.Id, 'Tax', eachInvoice.GL_Date__c.date(), eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c, eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c, '20225', 'Output VAT', eachLine.Tax_Amount__c,null, null, null,eachInvoice.Payment_Currency__c,eachInvoice.Conversion_Rate__c,jhObj.Name + '-' + count,eachLine.Tax__c);
                            jeSub2.journal_header__c = jhObj.Id;
                            jeSub2.Operating_Unit_Name__c = eachInvoice.Entity__r.Operating_unit__r.OU_Abbreviation__c;
                            jeSub2.Journal_Entry_Line_Description__c = eachLine.Service_Type__c + ' | ' + eachLine.Service_Class__c + ' | ' + eachLine.Line_Description__c;
                            tempLst = journalEntryMap.get(jhObj.Name);
                            if(tempLst == NULL){tempLst = new List<Journal_Entry__c>();}
                            tempLst.add(jeSub2);journalEntryMap.put(jhObj.Name, tempLst);count++;
                        }
                    }else{
                        Journal_Entry__c jeSub1 =  createJournalLines('Invoice', eachInvoice.Id, 'Revenue', eachInvoice.GL_Date__c.date(), eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c, eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c, glCombinationMap.get('Revenue').get(eachLine.Revenue_Type__c).Code__c, glCombinationMap.get('Revenue').get(eachLine.Revenue_Type__c).Lookup_Code_Meaning__c, null, (eachLine.Amount__c).setScale(2), glCombinationMap.get('Cost_Centre').get(eachLine.Department__c).Code__c, glCombinationMap.get('Cost_Centre').get(eachLine.Department__c).Lookup_Code_Meaning__c,eachInvoice.Payment_Currency__c,eachInvoice.Conversion_Rate__c,jhObj.Name + '-' + count,eachLine.Tax__c);
                        system.debug('eachInvoice.Entity__r.Is_Intercompany__c==>>' + eachInvoice.Entity__r.Is_Intercompany__c);
                        system.debug('eachInvoice.Entity__r.Intercompany_OU__r.Entity_Code__c==>>' + eachInvoice.Entity__r.Intercompany_OU__r.Entity_Code__c);
                        if(eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c == '03' && eachLine.Revenue_Type__c == 'Data Protection Fee'){
                            jeSub1.Cost_center__c = '205';
                        }
                        if(eachInvoice.Entity__r.Is_Intercompany__c){
                            jeSub1.Inter_company__c = eachInvoice.Entity__r.Intercompany_OU__r.Entity_Code__c;
                            jeSub1.Inter_company_Description__c = eachInvoice.Entity__r.Intercompany_OU__r.OU_Abbreviation__c;
                        }
                        jeSub1.journal_header__c = jhObj.Id;
                        jeSub1.Operating_Unit_Name__c = eachInvoice.Entity__r.Operating_unit__r.OU_Abbreviation__c;
                        jeSub1.Journal_Entry_Line_Description__c = eachLine.Service_Type__c + ' | ' + eachLine.Service_Class__c + ' | ' + eachLine.Line_Description__c;
                        tempLst = journalEntryMap.get(jhObj.Name);
                        if(tempLst == NULL){tempLst = new List<Journal_Entry__c>();}
                        tempLst.add(jeSub1);journalEntryMap.put(jhObj.Name, tempLst);count++;
                        if(eachLine.Tax__c != 'Out of scope 0%'){
                            Journal_Entry__c jeSub2 = createJournalLines('Invoice', eachInvoice.Id, 'Tax', eachInvoice.GL_Date__c.date(), eachInvoice.Entity__r.Operating_unit__r.Entity_Code__c, eachInvoice.Entity__r.Operating_unit__r.Operating_Unit_Name__c, glCombinationMap.get('Tax').get('Tax').Code__c,glCombinationMap.get('Tax').get('Tax').Lookup_Code_Meaning__c, null, eachLine.Tax_Amount__c != null ? (eachLine.Tax_Amount__c).setScale(2) : 0, null, null,eachInvoice.Payment_Currency__c,eachInvoice.Conversion_Rate__c,jhObj.Name + '-' + count,eachLine.Tax__c);
                            jeSub2.journal_header__c = jhObj.Id;
                            jeSub2.Operating_Unit_Name__c = eachInvoice.Entity__r.Operating_unit__r.OU_Abbreviation__c;
                            jeSub2.Journal_Entry_Line_Description__c = eachLine.Service_Type__c + ' | ' + eachLine.Service_Class__c + ' | ' + eachLine.Line_Description__c;
                            tempLst = journalEntryMap.get(jhObj.Name);
                            if(tempLst == NULL){tempLst = new List<Journal_Entry__c>();}
                            tempLst.add(jeSub2);journalEntryMap.put(jhObj.Name, tempLst);count++;
                        }
                    }
                }
            }
            if(!invoiceLst.isEmpty()){UPDATE invoiceLst;}
            if(!journalHeaderMap.keySet().isEmpty()){insertJournalRecords();updateJournalRunningNumber(runningNumber);}
            
        } catch(Exception ex){
            system.debug('====>'+ex.getMessage());  
            String sMessage = ex.getMessage();Log__c objLog = new Log__c();
            if(sMessage .length() > 240) {objLog.Message__c = sMessage.subString(0,240);} 
            else {objLog.Message__c = sMessage;}//end if            
            objLog.Line_Number__c = ex.getLineNumber();objLog.Stack_Trace__c =  ex.getStackTraceString();objLog.Type_Name__c = ex.getTypeName();insert objLog;Database.rollback(sp); 
        }
    }
    
    /**
    * @description : Insert Journal Lines on credit Memo Application
    * @author Anu Saxena | 26-09-2021 
    * @param List<Id> applicationIds 
    **/    
    public static void creditMemoApplicationJournalLines(List<Id> applicationIds){
        Savepoint sp;
        try{
            sp = Database.setSavepoint();
            journalsToInsert = new List<Journal_Entry__c>();
            List<Invoice_Line_Item__c> applicationList = [SELECT Id,Related_Credit_Memo__c, Related_Credit_Memo__r.Source_Invoice_Id__c, Related_Credit_Memo__r.Description__c, Name,Amount__c,Tax_Amount__c,Service_Type__c,Revenue_Type__c,Department__c,Amount_AED__c,Tax_Amount_AED__c,Tax__c,Is_Discount__c,GL_Date__c ,
                                                          Invoice__r.Entity__r.Operating_unit__r.Entity_Code__c, Invoice__r.Entity__r.Operating_unit__r.Operating_Unit_Name__c, Invoice__r.payment_currency__c,
                                                          Invoice__r.conversion_rate__c, Invoice__r.Entity__r.Operating_unit__r.OU_Abbreviation__c,Invoice__r.Entity__r.Name,Invoice__r.Id 
                                                          FROM Invoice_Line_Item__c WHERE Id IN : applicationIds];
            
            Map<String,String> jeAccountsReceiptApplication;
            
            jeAccountsReceiptApplication = new Map<String,String>{'Unapplied'=> 'Debit','Receivable'=> 'Credit'};
                
                set<String> jeAccountsKeyset = jeAccountsReceiptApplication.keySet();
            Map<String, GL_Combination_Setting__c> glCombinationMap = new Map<String, GL_Combination_Setting__c>();
            for(GL_Combination_Setting__c eachGLCombinaton : [SELECT Id,Account_Type__c,Code__c,Journal_Entry_Account__c,Lookup_Code_Meaning__c,Payment_Currency__c FROM GL_Combination_Setting__c WHERE Journal_Entry_Account__c IN : jeAccountsKeyset AND Active__c = true]){
                glCombinationMap.put(eachGLCombinaton.Journal_Entry_Account__c, eachGLCombinaton);
            }
            
            if(!applicationList.isEmpty()){
                
                journalHeaderMap = new Map<String, Journal_Header__c>();
                journalEntryMap = new Map<String, List<Journal_Entry__c>>();
                Integer runningNumber = getJournalRunningNumber();
                
                for(Invoice_Line_Item__c applicationItem : applicationList){
                    Journal_Header__c jhObj = new Journal_Header__c();
                    jhObj.Name = 'JV-' + runningNumber;
                    jhObj.Transaction_Type__c = 'Apply CreditMemo';
                    jhObj.Invoice__c = applicationItem.Related_Credit_Memo__c;
                    jhObj.Invoice_Line_Item__c = applicationItem.Id;
                    jhObj.Reference_Id__c = applicationItem.Id;
                    jhObj.Reference_Name__c = applicationItem.Name;
                    jhObj.Entity_Name__c = applicationItem.Invoice__r.Entity__r.Name;
                    jhObj.Account__c = applicationItem.Invoice__r.Entity__c;
                    jhObj.GL_Date__c = applicationItem.GL_Date__c;
                    journalHeaderMap.put(jhObj.Name, jhObj);
                    
                    runningNumber++;
                    Integer count = 1;
                    for (String transactionType : jeAccountsReceiptApplication.keySet()) {
                        
                        Journal_Entry__c je = new Journal_Entry__c(Credit_Memo_Application__c = applicationItem.Id, Account__c = transactionType, GL_Date__c = applicationItem.GL_Date__c);
                        je.Name = jhObj.Name + '-' + count;
                        je.Entity__c = applicationItem.Invoice__r.Entity__r.Operating_unit__r.Entity_Code__c;
                        je.Entity_Description__c = applicationItem.Invoice__r.Entity__r.Operating_unit__r.Operating_Unit_Name__c;
                        je.Operating_Unit_Name__c = applicationItem.Invoice__r.Entity__r.Operating_unit__r.OU_Abbreviation__c;
                        je.Account_Segment__c = glCombinationMap.get(transactionType).Code__c;
                        je.Account_Segment_Description__c = glCombinationMap.get(transactionType).Lookup_Code_Meaning__c;
                        je.currency__c = applicationItem.Invoice__r.payment_currency__c;
                        je.conversion_rate__c = applicationItem.Invoice__r.conversion_rate__c;
                        je.Tax_Rate_Code__c = applicationItem.Tax__c;
                        je.Journal_Entry_Line_Description__c = applicationItem.Related_Credit_Memo__r.Source_Invoice_Id__c + ' | ' + applicationItem.Related_Credit_Memo__r.Description__c;
                        if(jeAccountsReceiptApplication.get(transactionType) == 'Debit'){
                            je.Debit_OC__c = (applicationItem.Amount__c * -1);je.Credit_OC__c = 0;
                        } else if(jeAccountsReceiptApplication.get(transactionType) == 'Credit'){
                            je.Credit_OC__c = (applicationItem.Amount__c * -1);je.Debit_OC__c = 0;
                        } 
                        List<Journal_Entry__c> tempLst = journalEntryMap.get(jhObj.Name);
                        if(tempLst == NULL){tempLst = new List<Journal_Entry__c>(); }
                        tempLst.add(je);journalEntryMap.put(jhObj.Name, tempLst);count++;
                    }
                }
                if(!journalHeaderMap.keySet().isEmpty()){insertJournalRecords();updateJournalRunningNumber(runningNumber);}
            }
        }catch(Exception ex){
            system.debug(ex.getMessage());
            String sMessage = ex.getMessage();Log__c objLog = new Log__c();
            if(sMessage .length() > 240) {objLog.Message__c = sMessage.subString(0,240);} 
            else {objLog.Message__c = sMessage;}//end if
            objLog.Line_Number__c = ex.getLineNumber();objLog.Stack_Trace__c =  ex.getStackTraceString();objLog.Type_Name__c = ex.getTypeName();insert objLog;
            Database.rollback(sp);
        }
        
    }
    
    /**
    * @description : Insert Journal Lines on Receipt Creation
    * @author Jayanta Karmakar | 25-09-2021 
    * @param List<Id> receiptIds 
    **/
    public static void receiptCreationJournal(List<Id> receiptIds){
        Savepoint sp;
        try{
            
            journalsToInsert = new List<Journal_Entry__c>();
            Map<String,String> jeAccounts = new Map<String,String>{'Cash' => 'Debit','Unapplied'=> 'Credit'};
                Map<String, Map<String,GL_Combination_Setting__c>> glCombinationMap = new Map<String, Map<String,GL_Combination_Setting__c>>{'AED' => new Map<String,GL_Combination_Setting__c>(), 'USD' => new Map<String,GL_Combination_Setting__c>()};
                    for(GL_Combination_Setting__c eachGLCombinaton : [SELECT Id,Account_Type__c,Code__c,Journal_Entry_Account__c,Lookup_Code_Meaning__c,Payment_Currency__c FROM GL_Combination_Setting__c WHERE Related_Object__c INCLUDES('Receipt') AND Active__c = true AND Journal_Entry_Account__c IN : jeAccounts.keySet()]){
                        if(eachGLCombinaton.Payment_Currency__c.contains('AED')){glCombinationMap.get('AED').put(eachGLCombinaton.Journal_Entry_Account__c, eachGLCombinaton);
                        }
                        if(eachGLCombinaton.Payment_Currency__c.contains('USD')){glCombinationMap.get('USD').put(eachGLCombinaton.Journal_Entry_Account__c, eachGLCombinaton);
                        }
                    }
            sp = Database.setSavepoint();
            journalHeaderMap = new Map<String, Journal_Header__c>();
            journalEntryMap = new Map<String, List<Journal_Entry__c>>();
            Integer runningNumber = getJournalRunningNumber();
            
            for(Receipt__c eachReceipt : [SELECT Id,Name,Receipt_Reference__c, Description__c, Payment_Currency__c,Amount__c,GL_Date__c,Entity__r.Operating_unit__r.OU_Abbreviation__c, Entity__r.Operating_unit__r.Entity_Code__c,
                                          Entity__r.Operating_unit__r.Operating_Unit_Name__c,Conversion_Rate__c,Entity__r.Name FROM Receipt__c WHERE Id IN : receiptIds]){
                
                                              Journal_Header__c jhObj = new Journal_Header__c();
                                              jhObj.Name = 'JV' + '-' + runningNumber;
                                              jhObj.Transaction_Type__c = 'Receipts';
                                              jhObj.Receipt__c = eachReceipt.Id;
                                              jhObj.Reference_Id__c = eachReceipt.Id;
                                              jhObj.Reference_Name__c = eachReceipt.Name;
                                              jhObj.Entity_Name__c = eachReceipt.Entity__r.Name;
                                              jhObj.Account__c = eachReceipt.Entity__c;
                                              jhObj.GL_Date__c = eachReceipt.GL_Date__c;
                journalHeaderMap.put(jhObj.Name, jhObj);
                
                runningNumber++;
                Integer count = 1;
                
                for(String eachAcc : jeAccounts.keyset()){                    
                    Journal_Entry__c je = new Journal_Entry__c(Receipt__c = eachReceipt.Id, Account__c = eachAcc, GL_Date__c = eachReceipt.GL_Date__c);
                    je.Name = jhObj.Name + '-' + count;
                    je.Journal_Entry_Line_Description__c = eachReceipt.Receipt_Reference__c + ' | ' + eachReceipt.Description__c; 
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
            if(!journalHeaderMap.keySet().isEmpty()){insertJournalRecords();updateJournalRunningNumber(runningNumber);}
            
        } catch(Exception ex){
            system.debug('====>'+ex.getMessage());  
            String sMessage = ex.getMessage();Log__c objLog = new Log__c();
            if(sMessage .length() > 240) {objLog.Message__c = sMessage.subString(0,240);} 
            else {objLog.Message__c = sMessage;}//end if
            objLog.Line_Number__c = ex.getLineNumber();objLog.Stack_Trace__c =  ex.getStackTraceString();objLog.Type_Name__c = ex.getTypeName();insert objLog;
            Database.rollback(sp);
        }
    }
    
    
    /**
* @description : Method to rollback journal header
* @author Prateek Bansal | 07-10-2021
* @param List<Id> journalHeaderId 
**/
    public static void journalEntryCreationForHeaderReversal(List<Id> journalHeaderId, String type){
        Savepoint sp;
        try{
            sp = Database.setSavepoint();
            List<Journal_Header__c> journalHeaderLst = [SELECT Id, Name,GL_Date__c, Account__c, Invoice__c, Receipt__c, Fund_Transfer__c, Invoice_Line_Item__c, Related_Invoice_Receipt__c, 
                                                        Refund__c,Entity_Name__c,Reference_Id__c,Reference_Name__c, 
                                                        (SELECT Id, Journal_Entry_Line_Description__c, Account__c, Receipt__c, GL_Date__c, Entity__c, Account_Segment__c, Inter_company__c, Project__c, 
                                                         Cost_center__c, Program__c, Future2__c, Account_Segment_Description__c, Cost_center_Description__c, 
                                                         Entity_Description__c, Future2_Description__c, Inter_company_Description__c, Program_Description__c, 
                                                         Project_Description__c, Code_Combination__c, Code_Combination_Description__c, Invoice__c, Related_Invoice_Receipt__c, 
                                                         Refund__c, Credit_Memo_Application__c, Fund_Transfer__c, Journal_Header__c, Conversion_Rate__c, Currency__c, 
                                                         Credit_OC__c, Credit_AED__c, Debit_OC__c, Debit_AED__c,Operating_Unit_Name__c,Tax_Rate_Code__c  FROM Journal_Entries__r) 
                                                        FROM Journal_Header__c
                                                        WHERE Id IN: journalHeaderId];
            
            journalHeaderMap = new Map<String, Journal_Header__c>();
            journalEntryMap = new Map<String, List<Journal_Entry__c>>();
            Integer runningNumber = getJournalRunningNumber();
            for(Journal_Header__c jhObj : journalHeaderLst){
                Journal_Header__c tempHeader = jhObj;
                tempHeader.Id = null;
                tempHeader.GL_Date__c = System.today();
                tempHeader.Transaction_Type__c = type;
                tempHeader.Name = 'JV-' + runningNumber;
                system.debug('tempHeader==>>' + tempHeader);
                journalHeaderMap.put(tempHeader.Name, tempHeader);
                
                runningNumber++;
                Integer count = 1;
                for(Journal_Entry__c tempJE : jhObj.Journal_Entries__r){
                    Journal_Entry__c je = new Journal_Entry__c();
                    Decimal credit = 0;
                    Decimal debit = 0;
                    system.debug('tempJE.Credit_OC__c==>>' + tempJE.Credit_OC__c);
                    system.debug('tempJE.Debit_OC__c==>>' + tempJE.Debit_OC__c);
                    system.debug('tempJE.Credit_OC__c != 0==>' + (tempJE.Credit_OC__c != 0));
                    system.debug('tempJE.Debit_OC__c != 0==>' + (tempJE.Debit_OC__c != 0));
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
                if(!journalHeaderMap.keySet().isEmpty()){insertJournalRecords();updateJournalRunningNumber(runningNumber);}
            }
        }catch(Exception Ex){
            system.debug(ex.getMessage());
            String sMessage = ex.getMessage();Log__c objLog = new Log__c();
            if(sMessage .length() > 240) { objLog.Message__c = sMessage.subString(0,240);} 
            else {objLog.Message__c = sMessage;}//end if
            
            objLog.Line_Number__c = ex.getLineNumber();objLog.Stack_Trace__c =  ex.getStackTraceString();objLog.Type_Name__c = ex.getTypeName();insert objLog;
            Database.rollback(sp);
        }
    }
    
    /**
* @description : Insert Journal Lines on Reversal Creation
* @author Anu Saxena | 30-09-2021 
* @param List<Id> receiptIds , Type of reversal
**/
    /*public static void journalEntryCreationForReversal(List<Id> Ids, String ObjApiName){
        Savepoint sp;
        try{
            
            journalsToInsert = new List<Journal_Entry__c>();
            sp = Database.setSavepoint();
            
            Integer runningNumber = getJournalRunningNumber();
            
            Journal_Header__c jhObj = new Journal_Header__c();
            jhObj.Name = 'JV' + '-' + runningNumber;
            runningNumber++;
            Integer count = 1;
            
            List<Journal_Entry__c> initJEList = Database.query('Select Id,' + ObjApiName + ' ,Account__c,GL_Date__c,Entity__c,Entity_Description__c, Account_Segment__c, Account_Segment_Description__c, Debit_OC__c,Credit_OC__c, Currency__c, Conversion_Rate__c FROM Journal_Entry__c WHERE '+ ObjApiName+' IN : Ids');
            system.debug('initJEList ====>'+initJEList);
            for(Journal_Entry__c jeVal : initJEList){
                //Id objVal =  jeVal.get(ObjApiName);
                Journal_Entry__c je = new Journal_Entry__c();
                je.journal_header__c = jhObj.Id;
                je.Name = jhObj.Name + '-' + count;
                je.put(ObjApiName,jeVal.get(ObjApiName));
                //ObjApiName = jeVal.ObjApiName, 
                je.Account__c = jeVal.Account__c; 
                je.GL_Date__c = jeVal.GL_Date__c;
                je.Entity__c = jeVal.Entity__c;
                je.Entity_Description__c = jeVal.Entity_Description__c;
                je.Account_Segment__c = jeVal.Account_Segment__c;
                je.Account_Segment_Description__c = jeVal.Account_Segment_Description__c;
                if(jeVal.Debit_OC__c > 0){
                    je.Credit_OC__c = jeVal.Debit_OC__c;
                }
                if(jeVal.Credit_OC__c > 0){
                    je.Credit_OC__c = jeVal.Debit_OC__c;
                }
                je.Currency__c = jeVal.Currency__c;
                je.Conversion_Rate__c = jeVal.Conversion_Rate__c;
                journalsToInsert.add(je);
                count++;
            }
            system.debug('journalsToInsert ====>'+journalsToInsert); 
            insert jhObj; 
            insert journalsToInsert; 
            updateJournalRunningNumber(runningNumber);
        } catch(Exception ex){
            system.debug('====>'+ex.getMessage());  
            String sMessage = ex.getMessage();
            Log__c objLog = new Log__c();
            if(sMessage .length() > 240) {
                objLog.Message__c = sMessage.subString(0,240);
            } else {
                objLog.Message__c = sMessage;
            }//end if
            
            objLog.Line_Number__c = ex.getLineNumber();
            objLog.Stack_Trace__c =  ex.getStackTraceString();
            objLog.Type_Name__c = ex.getTypeName();
            insert objLog;
            Database.rollback(sp); 
        }
    }*/
    
    /**
* @description : Insert Journal Lines on receipt Application
* @author Prateek Bansal | 26-09-2021 
* @param List<Id> applicationIds 
**/ 
    public static void receiptApplicationJournalLines(List<Id> applicationIds){
        Savepoint sp;
        try{
            sp = Database.setSavepoint();
            journalsToInsert = new List<Journal_Entry__c>();
            List<Related_Invoice_Receipt__c> applicationList = [SELECT Id, Name,Invoice__c, Receipt__c, Receipt__r.Description__c, Receipt__r.Receipt_Reference__c, Receipt__r.Receipt_Balance__c, Receipt__r.Entity__r.Operating_unit__r.Entity_Code__c, GL_Date__c,
                                                                Amount_Applied__c, Receipt__r.Entity__r.Operating_unit__r.Operating_Unit_Name__c, Receipt__r.Entity__r.Operating_unit__r.OU_Abbreviation__c, 
                                                                Receipt__r.Payment_Currency__c, receipt__r.Conversion_Rate__c,Receipt__r.Entity__r.Name FROM Related_Invoice_Receipt__c 
                                                                WHERE Id IN : applicationIds];
            journalsToInsert = new List<Journal_Entry__c>();
            
            Map<String,String> jeAccountsReceiptApplication;
            
            jeAccountsReceiptApplication = new Map<String,String>{'Unapplied'=> 'Debit','Receivable'=> 'Credit'};
                
                set<String> jeAccountsKeyset = jeAccountsReceiptApplication.keySet();
            Map<String, GL_Combination_Setting__c> glCombinationMap = new Map<String, GL_Combination_Setting__c>();
            for(GL_Combination_Setting__c eachGLCombinaton : [SELECT Id,Account_Type__c,Code__c,Journal_Entry_Account__c,Lookup_Code_Meaning__c,Payment_Currency__c FROM GL_Combination_Setting__c WHERE Journal_Entry_Account__c IN : jeAccountsKeyset AND Active__c = true]){
                glCombinationMap.put(eachGLCombinaton.Journal_Entry_Account__c, eachGLCombinaton);
            }
            
            if(!applicationList.isEmpty()){
                
                journalHeaderMap = new Map<String, Journal_Header__c>();
                journalEntryMap = new Map<String, List<Journal_Entry__c>>();
                Integer runningNumber = getJournalRunningNumber();
                
                for(Related_Invoice_Receipt__c applicationItem : applicationList){
                    Journal_Header__c jhObj = new Journal_Header__c();
                    jhObj.Name = 'JV-' + runningNumber;
                    jhObj.Transaction_Type__c = 'Apply Receipt';
                    jhObj.related_Invoice_Receipt__c = applicationItem.Id;
                    jhObj.Reference_Id__c = applicationItem.Id;
                    jhObj.Reference_Name__c = applicationItem.Name;
                    jhObj.Entity_Name__c = applicationItem.Receipt__r.Entity__r.Name;
                    jhObj.Account__c = applicationItem.Receipt__r.Entity__c;
                    jhObj.GL_Date__c = applicationItem.GL_Date__c;
                    journalHeaderMap.put(jhObj.Name, jhObj);
                    
                    runningNumber++;
                    Integer count = 1;
                    for (String transactionType : jeAccountsReceiptApplication.keySet()) {
                        
                        Journal_Entry__c je = new Journal_Entry__c(Related_Invoice_Receipt__c = applicationItem.Id, Account__c = transactionType, GL_Date__c = applicationItem.GL_Date__c);
                        je.Name = jhObj.Name + '-' + count;
                        je.Entity__c = applicationItem.Receipt__r.Entity__r.Operating_unit__r.Entity_Code__c;
                        je.Journal_Entry_Line_Description__c = applicationItem.Receipt__r.Description__c + ' | ' + applicationItem.Receipt__r.Receipt_Reference__c;
                        je.Entity_Description__c = applicationItem.Receipt__r.Entity__r.Operating_unit__r.Operating_Unit_Name__c;
                        je.Account_Segment__c = glCombinationMap.get(transactionType).Code__c;
                        je.Account_Segment_Description__c = glCombinationMap.get(transactionType).Lookup_Code_Meaning__c;
                        je.Operating_Unit_Name__c = applicationItem.Receipt__r.Entity__r.Operating_unit__r.OU_Abbreviation__c;
                        je.currency__c = applicationItem.receipt__r.payment_currency__c;
                        je.conversion_rate__c = applicationItem.receipt__r.conversion_rate__c;
                        if(jeAccountsReceiptApplication.get(transactionType) == 'Debit'){je.Debit_OC__c = applicationItem.Amount_Applied__c;} 
                        else if(jeAccountsReceiptApplication.get(transactionType) == 'Credit'){je.Credit_OC__c = applicationItem.Amount_Applied__c;} 
                        List<Journal_Entry__c> tempLst = journalEntryMap.get(jhObj.Name);
                        if(tempLst == NULL){tempLst = new List<Journal_Entry__c>();}
                        tempLst.add(je); journalEntryMap.put(jhObj.Name, tempLst);count++;
                    }
                }
                if(!journalHeaderMap.keySet().isEmpty()){insertJournalRecords();updateJournalRunningNumber(runningNumber);}
            }
        }catch(Exception ex){
            system.debug(ex.getMessage());
            String sMessage = ex.getMessage();
            Log__c objLog = new Log__c();
            if(sMessage .length() > 240) {
                objLog.Message__c = sMessage.subString(0,240);
            } else {
                objLog.Message__c = sMessage;
            }//end if
            
            objLog.Line_Number__c = ex.getLineNumber();
            objLog.Stack_Trace__c =  ex.getStackTraceString();
            objLog.Type_Name__c = ex.getTypeName();
            insert objLog;
            Database.rollback(sp);
        }
        
    }
    /**
* @description : Insert Journal Lines on refund
* @author Prateek Bansal | 26-09-2021 
* @param List<Id> refundIds 
**/ 
    public static void refundJournalLines(List<Id> refundIds){
        Savepoint sp;
        try{
            journalsToInsert = new List<Journal_Entry__c>();
            List<Refund__c> refundList = [SELECT Id, Name, Description__c, Entity__c, Amount__c, Currency__c, Entity__r.Operating_unit__r.Entity_Code__c, Entity__r.Operating_unit__r.Operating_Unit_Name__c, 
                                          Entity__r.Operating_unit__r.OU_Abbreviation__c,Scenario__c, Receipt__c, Receipt__r.conversion_rate__c, Receipt__r.GL_Date__c, Credit_Memo__c, 
                                          Credit_Memo__r.conversion_rate__c, Credit_Memo__r.GL_Date__c,Entity__r.Name, Payment_Method__c FROM Refund__c WHERE Id IN : refundIds];
            Map<String, Map<String, String>> refundJournaMapping = new  Map<String, Map<String, String>>{'Credit Memo' => new Map<String, String>{'Unapplied'=> 'Debit', 'Refund'=> 'Credit'}, 
                'Receipt generated but invoice not generated' => new Map<String, String>{'Unapplied'=> 'Debit', 'Refund'=> 'Credit'}};
                    
                    set<String> jeAccountsKeyset = new set<String>{'Unapplied','Refund'};
                        Map<String, GL_Combination_Setting__c> glCombinationMap = new Map<String, GL_Combination_Setting__c>();
            for(GL_Combination_Setting__c eachGLCombinaton : [SELECT Id,Account_Type__c,Code__c,Journal_Entry_Account__c,Lookup_Code_Meaning__c,Payment_Currency__c FROM GL_Combination_Setting__c WHERE Journal_Entry_Account__c IN : jeAccountsKeyset AND Active__c = true]){
                glCombinationMap.put(eachGLCombinaton.Journal_Entry_Account__c, eachGLCombinaton);
            }
            
            sp = Database.setSavepoint();
            
            if(!refundList.isEmpty()){
                
                journalHeaderMap = new Map<String, Journal_Header__c>();
                journalEntryMap = new Map<String, List<Journal_Entry__c>>();
                Integer runningNumber = getJournalRunningNumber();
                
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
                            je.Journal_Entry_Line_Description__c = refundObj.Description__c;
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
                if(!journalHeaderMap.keySet().isEmpty()){insertJournalRecords();updateJournalRunningNumber(runningNumber);}
            }
            
        }catch(Exception ex){
            system.debug(ex.getMessage());
            String sMessage = ex.getMessage();
            Log__c objLog = new Log__c();
            if(sMessage .length() > 240) {
                objLog.Message__c = sMessage.subString(0,240);
            } else {
                objLog.Message__c = sMessage;
            }//end if
            
            objLog.Line_Number__c = ex.getLineNumber();
            objLog.Stack_Trace__c =  ex.getStackTraceString();
            objLog.Type_Name__c = ex.getTypeName();
            insert objLog;
            Database.rollback(sp);
        }
        
    }
    /**
* @description : Insert Journal Lines on fund transfer
* @author Prateek Bansal | 26-09-2021 
* @param List<Id> refundIds 
**/ 
    public static void fundTransferJournalEntries(List<Id> fundTransferIds){
        Savepoint sp;
        try{
            journalsToInsert = new List<Journal_Entry__c>();
            List<Fund_Transfer__c> fundTransferLst = [SELECT Name, From_Entity__c, To_Entity__c, Id, Reference_Receipt__c, From_Receipt__c, To_Receipt__c,
                                                      Reference_Receipt__r.conversion_rate__c, To_Receipt__r.conversion_rate__c, To_Entity__r.Name,
                                                      From_Currency__c, Amount__c, To_Currency__c, Scenario__c, Description__c, From_OU__c, To_OU__c, 
                                                      From_Source_System__c, To_Source_System__c, FromOU__c, ToOU__c, Amount_AED__c, GL_Date__c,
                                                      To_Entity__r.Operating_unit__r.Entity_Code__c, To_Entity__r.Operating_unit__r.Operating_Unit_Name__c,
                                                      From_Entity__r.Operating_unit__r.Entity_Code__c, From_Entity__r.Operating_unit__r.Operating_Unit_Name__c, 
                                                      From_Entity__r.Operating_unit__r.OU_Abbreviation__c, To_Entity__r.Operating_unit__r.OU_Abbreviation__c,From_Entity__r.Name 
                                                      FROM Fund_Transfer__c
                                                      WHERE Id IN : fundTransferIds];
            
            Map<String,Map<String, String>> fundTransferJournalMapping = new Map<String,Map<String, String>>{'JV1' => new Map<String, String>{'Unapplied'=>'Debit','Refund'=>'Credit'}, 'JV2' => new Map<String, String>{'Refund'=>'Debit','Unapplied'=>'Credit'}};
            set<String> journalAccountSet = new set<String>{'Refund', 'Unapplied'};
            Map<String, GL_Combination_Setting__c> glCombinationMap = new Map<String, GL_Combination_Setting__c>();
            for(GL_Combination_Setting__c eachGLCombinaton : [SELECT Id,Account_Type__c,Code__c,Journal_Entry_Account__c,Lookup_Code_Meaning__c,Payment_Currency__c FROM GL_Combination_Setting__c WHERE Journal_Entry_Account__c IN :journalAccountSet AND Active__c = true]){
                glCombinationMap.put(eachGLCombinaton.Journal_Entry_Account__c, eachGLCombinaton);
            }    
			
            sp = Database.setSavepoint();
            
            journalHeaderMap = new Map<String, Journal_Header__c>();
            journalEntryMap = new Map<String, List<Journal_Entry__c>>();
            Integer runningNumber = getJournalRunningNumber();
            
            for (Fund_Transfer__c ftObj : fundTransferLst) {
                for(String journalCount : fundTransferJournalMapping.keySet()){
                    Journal_Header__c jhObj = new Journal_Header__c();
                    jhObj.Name = 'JV-' + runningNumber;
                    if(ftObj.From_Currency__c != ftObj.To_Currency__c){
                    	jhObj.Transaction_Type__c = 'Fund Transfer - DC';    
                    }else{
                        jhObj.Transaction_Type__c = 'Fund Transfer';
                    }
                    
                    jhObj.Fund_Transfer__c = ftObj.Id;
                    jhObj.Reference_Id__c = ftObj.Id;
                    jhObj.Reference_Name__c = ftObj.Name;
                    
                    //
                    jhObj.GL_Date__c = ftObj.GL_Date__c;
                    journalHeaderMap.put(jhObj.Name, jhObj);
                    
                    runningNumber++;
                    Integer count = 1;
                    for(String transactionType : fundTransferJournalMapping.get(journalCount).keySet()){
                    	Journal_Entry__c je = new Journal_Entry__c(Fund_Transfer__c = ftObj.Id, Receipt__c = ftObj.To_Receipt__c, Account__c = transactionType, GL_Date__c = ftObj.GL_Date__c);
                        je.Account_Segment__c = glCombinationMap.get(transactionType).Code__c;
                        je.Account_Segment_Description__c = glCombinationMap.get(transactionType).Lookup_Code_Meaning__c;
                        je.conversion_rate__c = ftObj.Reference_Receipt__r.conversion_rate__c;
                        je.Name = jhObj.Name + '-' + count;
                        
                        
                        if(journalCount == 'JV1'){
                            jhObj.Account__c = ftObj.From_Entity__c;
                            jhObj.Entity_Name__c = ftObj.From_Entity__r.Name;
                            je.Journal_Entry_Line_Description__c = 'FT-' + ftObj.From_Entity__r.Operating_unit__r.Entity_Code__c + ' to ' + ftObj.To_Entity__r.Operating_unit__r.Entity_Code__c + '-' + ftObj.To_Entity__r.Name;
                            if(fundTransferJournalMapping.get(journalCount).get(transactionType) == 'Debit'){
                                je.Entity__c = ftObj.From_Entity__r.Operating_unit__r.Entity_Code__c;
                                je.Entity_Description__c = ftObj.From_Entity__r.Operating_unit__r.Operating_Unit_Name__c;
                                je.currency__c = ftObj.From_Currency__c;
                                je.Debit_OC__c = ftObj.Amount__c;
                                je.Operating_Unit_Name__c = ftObj.From_Entity__r.Operating_Unit__r.OU_Abbreviation__c;
                            } else if(fundTransferJournalMapping.get(journalCount).get(transactionType) == 'Credit'){
                                je.Entity__c = ftObj.To_Entity__r.Operating_unit__r.Entity_Code__c;
                                je.Entity_Description__c = ftObj.To_Entity__r.Operating_unit__r.Operating_Unit_Name__c;
                                je.currency__c = ftObj.From_Currency__c;
                                je.Operating_Unit_Name__c = ftObj.To_Entity__r.Operating_Unit__r.OU_Abbreviation__c;
                                je.Credit_OC__c = ftObj.Amount__c;
                            } 
                        }else if(journalCount == 'JV2'){
                            jhObj.Account__c = ftObj.To_Entity__c;
                            jhObj.Entity_Name__c = ftObj.To_Entity__r.Name;
                            je.Journal_Entry_Line_Description__c = 'FT-' + ftObj.From_Entity__r.Operating_unit__r.Entity_Code__c + ' from ' + ftObj.To_Entity__r.Operating_unit__r.Entity_Code__c + '-' + ftObj.From_Entity__r.Name;
                            if(fundTransferJournalMapping.get(journalCount).get(transactionType) == 'Debit'){
                                je.Entity__c = ftObj.To_Entity__r.Operating_unit__r.Entity_Code__c;
                                je.Entity_Description__c = ftObj.To_Entity__r.Operating_unit__r.Operating_Unit_Name__c;
                                je.Operating_Unit_Name__c = ftObj.To_Entity__r.Operating_Unit__r.OU_Abbreviation__c;
                                je.currency__c = ftObj.To_Currency__c;
                                
                                if(ftObj.From_Currency__c == 'USD' && ftObj.To_Currency__c == 'AED'){
                                    je.Debit_OC__c = ftObj.Amount__c * ftObj.Reference_Receipt__r.conversion_rate__c;   
                                }else if(ftObj.From_Currency__c == 'AED' && ftObj.To_Currency__c == 'USD'){
                                    je.Debit_OC__c = ftObj.Amount__c / ftObj.Reference_Receipt__r.conversion_rate__c;  
                                }else{
                                    je.Debit_OC__c = ftObj.Amount__c;
                                }
                                
                            } else if(fundTransferJournalMapping.get(journalCount).get(transactionType) == 'Credit'){
                                if(ftObj.From_OU__c != ftObj.To_OU__c){
                                    je.Entity__c = ftObj.To_Entity__r.Operating_unit__r.Entity_Code__c;
                                    je.Entity_Description__c = ftObj.To_Entity__r.Operating_unit__r.Operating_Unit_Name__c;
                                    je.Operating_Unit_Name__c = ftObj.To_Entity__r.Operating_Unit__r.OU_Abbreviation__c;
                                }else{
                                    je.Entity__c = ftObj.From_Entity__r.Operating_unit__r.Entity_Code__c;
                                    je.Entity_Description__c = ftObj.From_Entity__r.Operating_unit__r.Operating_Unit_Name__c;
                                    je.Operating_Unit_Name__c = ftObj.From_Entity__r.Operating_Unit__r.OU_Abbreviation__c;
                                }
                                
                                je.currency__c = ftObj.To_Currency__c;
                                if(ftObj.From_Currency__c == 'USD' && ftObj.To_Currency__c == 'AED'){
                                    je.Credit_Oc__c = ftObj.Amount__c * ftObj.Reference_Receipt__r.conversion_rate__c;   
                                }else if(ftObj.From_Currency__c == 'AED' && ftObj.To_Currency__c == 'USD'){
                                    je.Credit_Oc__c = ftObj.Amount__c / ftObj.Reference_Receipt__r.conversion_rate__c;  
                                }else{
                                    je.Credit_Oc__c = ftObj.Amount__c;
                                }
                            } 
                        }
                        
                        List<Journal_Entry__c> tempLst = journalEntryMap.get(jhObj.Name);
                        if(tempLst == NULL){tempLst = new List<Journal_Entry__c>();}
                        tempLst.add(je);journalEntryMap.put(jhObj.Name, tempLst);count++;
                    }
                }
            }
            if(!journalHeaderMap.keySet().isEmpty()){
                insertJournalRecords();
                updateJournalRunningNumber(runningNumber);
            }
            /*Map<String, String> fundTransferJournalMapping = new Map<String, String>{'Unapplied-D'=> 'Debit', 'Unapplied-C'=> 'Credit'};
            Map<String, GL_Combination_Setting__c> glCombinationMap = new Map<String, GL_Combination_Setting__c>();
            for(GL_Combination_Setting__c eachGLCombinaton : [SELECT Id,Account_Type__c,Code__c,Journal_Entry_Account__c,Lookup_Code_Meaning__c,Payment_Currency__c FROM GL_Combination_Setting__c WHERE Journal_Entry_Account__c = 'Unapplied' AND Active__c = true]){
                glCombinationMap.put(eachGLCombinaton.Journal_Entry_Account__c, eachGLCombinaton);
            }
            sp = Database.setSavepoint();
            
            
            journalHeaderMap = new Map<String, Journal_Header__c>();
            journalEntryMap = new Map<String, List<Journal_Entry__c>>();
            Integer runningNumber = getJournalRunningNumber();
            
            for (Fund_Transfer__c ftObj : fundTransferLst) {
                Journal_Header__c jhObj = new Journal_Header__c();
                jhObj.Name = 'JV-' + runningNumber;
                jhObj.Transaction_Type__c = 'Fund Transfer';
                jhObj.Fund_Transfer__c = ftObj.Id;
                jhObj.Reference_Id__c = ftObj.Id;
                jhObj.Reference_Name__c = ftObj.Name;
                jhObj.Entity_Name__c = ftObj.From_Entity__r.Name;
                jhObj.Account__c = ftObj.From_Entity__c;
                jhObj.GL_Date__c = ftObj.GL_Date__c;
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
            if(!journalHeaderMap.keySet().isEmpty()){insertJournalRecords();updateJournalRunningNumber(runningNumber);}*/
        }catch(Exception ex){
            system.debug(ex.getMessage());
            String sMessage = ex.getMessage();
            Log__c objLog = new Log__c();
            if(sMessage .length() > 240) {
                objLog.Message__c = sMessage.subString(0,240);
            } else {
                objLog.Message__c = sMessage;
            }//end if
            
            objLog.Line_Number__c = ex.getLineNumber();
            objLog.Stack_Trace__c =  ex.getStackTraceString();
            objLog.Type_Name__c = ex.getTypeName();
            insert objLog;
            Database.rollback(sp);
        }
        
        
    }
    
    public static Journal_Entry__c createJournalLines(String obj, String lookupFld, String acc, Date glDate, String eCode, String eDesc, String asCode, String asDesc, Decimal debitOC, Decimal creditOC, 
                                                      String csCode, String csDesc, String currencyCode, Decimal conversionRate, String jeName, String taxRateCode){
        Journal_Entry__c je = new Journal_Entry__c(Receipt__c = (obj == 'Receipt')?lookupFld:null,
                                                   Invoice__c = (obj == 'Invoice')?lookupFld:null,
                                                   Account__c = acc, 
                                                   GL_Date__c = glDate,
                                                   Entity__c = eCode,
                                                   Entity_Description__c = eDesc,
                                                   Account_Segment__c = asCode,
                                                   Account_Segment_Description__c = asDesc,
                                                   Cost_center__c = csCode != null? csCode : '000',
                                                   Cost_center_Description__c = csDesc != null? csDesc :'None',
                                                   Debit_OC__c = debitOC,
                                                   Credit_OC__c = creditOC,
                                                   currency__c = currencyCode,
                                                   conversion_rate__c = conversionRate,
                                                   Name = jeName,
                                                   Tax_Rate_Code__c = taxRateCode
                                                  );
        return je;
    }
    
    public class ResponseWrapper {
        @AuraEnabled public String objType {get;set;}
        @AuraEnabled public Boolean isJournalAlreadyCreated {get;set;}
        @AuraEnabled public String Status {get;set;}
        @AuraEnabled public String recId {get;set;}
    }
}