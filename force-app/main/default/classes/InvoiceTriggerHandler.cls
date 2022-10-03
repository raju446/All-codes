/*
    Author      : Yogesh Mahajan
    Date        : 30-Jan-2018
    Description : Trigger Handler for Invoice Object
    Version History
    Prachi      31/3/2021    Mapped the payment term days on the due days field on invoice
*/
public without sharing class InvoiceTriggerHandler {
    public static boolean isRunTrigger = true;
    public static void Execute_BI(list<Invoice__c> TriggerNew){
        System.debug('ITH Execute_BI Limit SOQL===='+Limits.getQueries());
        calculateDueDays(TriggerNew, null);
        populateDocumentMaster(TriggerNew, null);
        populateAuthority(TriggerNew);
        generateInvoiceRunningNumber(TriggerNew,null);
        populateExchangeRate(TriggerNew);      
    }
    
    public static void Execute_AI(list<Invoice__c> TriggerNew){
        System.debug('ITH Execute_AI Limit SOQL===='+Limits.getQueries());
        list<Invoice__c> lstInvoice = new list<Invoice__c>();
        List<Id> invoiceIdlist = new List<Id>();
        for(Invoice__c objInvoice:TriggerNew){
            if(objInvoice.Status__c=='Success' && !objInvoice.Is_Created_Manually__c && !objInvoice.From_Data_Migration__c && !objInvoice.Journal_Created__c){lstInvoice.add(objInvoice);}
            invoiceIdlist.add(objInvoice.id);
        }
        if(lstInvoice.size()>0){  pushInvoiceToOracle(lstInvoice);}
        // function to add to journal Entries
        //if(lstInvoice.size()>0)
            //BM_JournalEntryEngine.invoiceCreationJournal(invoiceIdlist);
        
        createCustomerInvoiceReceipt(TriggerNew, null);
    }

    //calculate business days if the payment term is in days or map the net days
    public static void calculateDueDays(list<Invoice__c> TriggerNew, map<Id,Invoice__c> TriggerOldMap){
        List<Invoice__c> invoiceRecordsToProcess = new List<Invoice__c>();
        for(Invoice__c objInv : TriggerNew){
            if(TriggerOldMap == null || (TriggerOldMap != null && TriggerOldMap.get(objInv.Id).Payment_Term__c != objInv.Payment_Term__c) || objInv.Due_Days__c == null){
                invoiceRecordsToProcess.add(objInv);
            }
        }

        for(Invoice__c objInv : invoiceRecordsToProcess){
            String paymentTerm = objInv.Payment_Term__c != null ? objInv.Payment_Term__c : '';
            Integer dueDays = 0;

            if(paymentTerm.containsIgnoreCase('days') || paymentTerm.containsIgnoreCase('net')){
                List<String> paymentTermList = paymentTerm.split(' ');
                if(paymentTermList.size() > 0){
                    if(paymentTermList[0].isNumeric()){dueDays = Integer.valueOf(paymentTermList[0]);}
                }
            }

            //business days
            if(paymentTerm.containsIgnoreCase('days')){
                //BusinessHours bHours = [SELECT Id FROM BusinessHours WHERE Name = 'FSRA'];

                List<Operating_Unit__c> operatingUnitList = [select id, Business_Hour__c, Operating_Unit_Name__c from Operating_Unit__c where Operating_Unit_Name__c =: objInv.Operating_Unit__c LIMIT 1];

                if(operatingUnitList.size() > 0){
                    if(operatingUnitList[0].Business_Hour__c != null){Date invoiceDate;
                                                                      if(objInv.Invoice_Date__c != null){invoiceDate = Date.valueOf(objInv.Invoice_Date__c);}
                        DateTime dueDateTime = CalculateBusinessDays.addDays(objInv.Invoice_Date__c, dueDays, operatingUnitList[0].Business_Hour__c);
                        if(dueDateTime != null){dueDays = invoiceDate.daysBetween(Date.valueOf(dueDateTime));}
                    }
                }
            }
            if(dueDays != null){
                objInv.Due_Days__c = dueDays;
            }
        }
        System.debug('ITH calculateDueDays Limit SOQL===='+Limits.getQueries());
    }
    
    public static void populateAuthority(list<Invoice__c> TriggerNew){
        map<Id, Account> mapAccounts = new map<Id, Account>();
        for(Invoice__c objInv : TriggerNew){
            if(string.isBlank(objInv.Entity_Authority__c) && objInv.Entity__c != null ){
                mapAccounts.put(objInv.Entity__c, null);
            }
        }
        if(!mapAccounts.isEmpty()){
            mapAccounts = new map<Id, Account>([select Id,Source_System_Name__c from Account where Id IN : mapAccounts.keySet() ]);
            for(Invoice__c objInv : TriggerNew){
                if(string.isBlank(objInv.Entity_Authority__c) && mapAccounts.get(objInv.Entity__c) != null ){
                    objInv.Entity_Authority__c = mapAccounts.get(objInv.Entity__c).Source_System_Name__c;
                }
            }   
        }
        System.debug('ITH populateAuthority Limit SOQL===='+Limits.getQueries());
    }
    
    public static void Execute_BU(list<Invoice__c> TriggerNew,map<Id,Invoice__c> TriggerOldMap){   
        calculateDueDays(TriggerNew, TriggerOldMap);    
        populateVersionNumber(TriggerNew, TriggerOldMap);
        populateDocumentMaster(TriggerNew, TriggerOldMap);
        populateAuthority(TriggerNew);
        //generateInvoiceRunningNumber(TriggerNew,TriggerOldMap);
    }
    
    public static void Execute_AU(list<Invoice__c> TriggerNew,map<Id,Invoice__c> TriggerOldMap){
        System.debug('inside Execute_AU');
        //updateIs_ReadyToPushToOreacleOnReceipt(TriggerNew);
        list<Invoice__c> lstInvoice = new list<Invoice__c>();
        Set<Invoice__c> lstInvoicewithGLUpdate = new Set<Invoice__c>();
        list<Id> lstJeInvoice = new list<Id>();
        for(Invoice__c objInvoice:TriggerNew){
        
            if((TriggerOldMap.get(objInvoice.Id).Status__c!=objInvoice.Status__c /*|| objInvoice.Is_ReadyToPushToOreacle__c*/) && objInvoice.Status__c=='Approved' && !objInvoice.From_Data_Migration__c && !objInvoice.Journal_Created__c)
                lstInvoice.add(objInvoice);
            if(TriggerOldMap.get(objInvoice.Id).GL_Date__c != objInvoice.GL_Date__c)
                lstInvoicewithGLUpdate.add(objInvoice);
        }
        System.debug('lstJeInvoice===='+lstJeInvoice);
        if(lstInvoice.size()>0) {
            // Added new web service call
            pushInvoiceToOracle(lstInvoice);
        }
        if(lstInvoicewithGLUpdate.size()>0) {InvoiceUtil_New.updateCloseDateErrorJVs(lstInvoicewithGLUpdate);}
        //if(lstJeInvoice.size()>0)
            //BM_JournalEntryEngine.invoiceCreationJournal(lstJeInvoice);
        
        //createCustomerInvoiceReceipt(TriggerNew, TriggerOldMap);
    }
    
    
    /*
        Method Name     :   pushInvoiceToOracle
        Description     :   Http Callout to Informatica Cloud to create Invoice in Oracle
    */
    public static void pushInvoiceToOracle(List<Invoice__c> listInvoice) {
        List<String> listInvoiceFirst = new List<String>();
        List<String> listInvoiceSecound = new List<String>();
        List<String> listCreditMemoFirst = new List<String>();
        List<String> listCreditMemoSecound = new List<String>();
        Map<Id,String> mapofInvoiceRecordTypeIdAndName = new Map<Id,String>();
        mapofInvoiceRecordTypeIdAndName = ApexCodeUtility.getRecordTypeDetails('Invoice__c');
        system.debug('mapofInvoiceRecordTypeIdAndName==>>' + mapofInvoiceRecordTypeIdAndName);
        Integer recordCount = 1, creditMemoCount = 1;
        for(Invoice__c objInvoice : listInvoice) {
            if(mapofInvoiceRecordTypeIdAndName <> null && objInvoice.RecordTypeId <> null &&  mapofInvoiceRecordTypeIdAndName.get(objInvoice.RecordTypeId) <> null
               &&  mapofInvoiceRecordTypeIdAndName.get(objInvoice.RecordTypeId) == 'Invoice') {
                   if(recordCount == 201){break;}
                   if(recordCount <= 100){listInvoiceFirst.add(objInvoice.id);}
                   if(recordCount > 100 && recordCount <= 200){listInvoiceSecound.add(objInvoice.id);}
                   recordCount++; 
               } else if(mapofInvoiceRecordTypeIdAndName <> null && objInvoice.RecordTypeId <> null &&  mapofInvoiceRecordTypeIdAndName.get(objInvoice.RecordTypeId) <> null
               &&  mapofInvoiceRecordTypeIdAndName.get(objInvoice.RecordTypeId) == 'Credit_Memo'){
                   if(creditMemoCount == 201){break;}
                   if(creditMemoCount <= 100){
                       listCreditMemoFirst.add(objInvoice.id);
                   }
                   
                   if(creditMemoCount > 100 && creditMemoCount <= 200){listCreditMemoSecound.add(objInvoice.id);}
                   system.debug('listCreditMemoFirst==>>' + listCreditMemoFirst);
                   creditMemoCount++;
               }
            
                
        }//end for
        system.debug('listInvoiceFirst==>>' + listInvoiceFirst);
        // send first 100 Invoice to oracle 
        if(listInvoiceFirst <> null && listInvoiceFirst.size() > 0) {InvoiceUtil_New.updateInvoiceAndCreateJournalEntries(listInvoiceFirst); }
        
        // send from 100 - 200 Invoice to oracle 
        if(listInvoiceSecound <> null && listInvoiceSecound.size() > 0) {InvoiceUtil_New.updateInvoiceAndCreateJournalEntries(listInvoiceSecound);    }
        system.debug('listCreditMemoFirst==>>' + listCreditMemoFirst);
        // send first 100 Credit Memo to oracle 
        if(listCreditMemoFirst <> null && listCreditMemoFirst.size() > 0) {
            //BM_JournalEntryEngine.creditMemoCreationJournal(listCreditMemoFirst);
            CreditMemoUtil_New.updateCreditMemoAndCreateJVs(listCreditMemoFirst);   
        }
        
        // send from 100 - 200 Credit Memo to oracle 
        if(listCreditMemoSecound <> null && listCreditMemoSecound.size() > 0) { CreditMemoUtil_New.updateCreditMemoAndCreateJVs(listCreditMemoSecound);    }
    }
/*
    public static void updateIs_ReadyToPushToOreacleOnReceipt(List<Invoice__c> newList){
        if(isRunTrigger){
            List<Related_Invoice_Receipt__c> relatedRecords = [SELECT Id,Receipt__c from Related_Invoice_Receipt__c WHERE Invoice__c IN : newList];
            Set<Id> receiptIds = new Set<Id>();
            for(Related_Invoice_Receipt__c rr : relatedRecords){
                receiptIds.add(rr.Receipt__c);
            }

            Map<Id,List<Id>> receiptVsInvoicesMap = new Map<Id,List<Id>>();
            Map<Id,Boolean> invoiceVSOracleMap = new Map<Id,Boolean>();
            for(Related_Invoice_Receipt__c eachRelatedRec : [SELECT Id, Invoice__c,Receipt__c,Invoice__r.Oracle_Invoice_Id__c from Related_Invoice_Receipt__c WHERE Receipt__c In : receiptIds]){
                if(eachRelatedRec.Invoice__r.Oracle_Invoice_Id__c != null && eachRelatedRec.Invoice__r.Oracle_Invoice_Id__c != ''){
                    invoiceVSOracleMap.put(eachRelatedRec.Invoice__c,true);
                } else {
                    invoiceVSOracleMap.put(eachRelatedRec.Invoice__c,false);
                }
                
                if(receiptVsInvoicesMap.containsKey(eachRelatedRec.Receipt__c)){
                    receiptVsInvoicesMap.get(eachRelatedRec.Receipt__c).add(eachRelatedRec.Invoice__c);
                } else {
                    receiptVsInvoicesMap.put(eachRelatedRec.Receipt__c, new List<Id>{eachRelatedRec.Invoice__c});
                }
            }  


            List<Receipt__c> receiptsToUpdate = new List<Receipt__c>();
            for(Id eachReceipt : receiptVsInvoicesMap.keySet()){
                boolean isReceiptReady = true;
                for(Id eachInvoice : receiptVsInvoicesMap.get(eachReceipt)){
                    if(! invoiceVSOracleMap.get(eachInvoice)){
                        isReceiptReady = false;
                        break;
                    }
                }
                if(isReceiptReady){
                    receiptsToUpdate.add(new Receipt__c(Id = eachReceipt, Is_ReadyToPushToOreacle__c = true));
                }
            }

            if(receiptsToUpdate.size() > 0){
                ReceiptTriggerHandler.isRunTrigger = false;
                update receiptsToUpdate;
            }
        }
    }
    */
    public static void populateDocumentMaster(list<Invoice__c> lstInv, map<Id, Invoice__c> mapOldInv){
        map<string, HexaBPM__Document_Master__c> mapDocCodes = new map<string,  HexaBPM__Document_Master__c>();
        map<string, string> mapRecordDocMasters = new map<string, string>();
        
        set<string> setInvStatus = new set<string>{
            //Constants.STR_Under_Review,
            //Constants.STR_Approved
        };
            
            set<string> setSourceSystemToCreateDocuments = new set<string>
            {
               // 'BM', 'BM - Arbitration','BM - ADGM' 
            }   ; 
            
        for(Invoice__c objInv : lstInv){
            //if(!setSourceSystemToCreateDocuments.contains(objInv.Source_System__c) )//if(objInv.Source_System__c != 'BM')
              //  continue;
            Invoice__c objOldInv = (mapOldInv != null && mapOldInv.containsKey(objInv.id)) ? mapOldInv.get(objInv.Id) : new Invoice__c();
            if(objInv.Document_Master__c == null && string.isNotEmpty(objInv.Document_Master_Code__c) ){
                mapDocCodes.put(objInv.Document_Master_Code__c, null);
            }
            if( objInv.Document_Master__c != null && setInvStatus.contains(objInv.Status__c) && objInv.Status__c != objOldInv.Status__c && objInv.Source_System__c != 'Catalyst'){objInv.Generate_Document__c = true;
                /*mapRecordDocMasters.put(objInv.Id, objInv.Document_Master__c);*/
            }
            if(objInv.Payment_Currency__c != objOldInv.Payment_Currency__c || (objInv.Document_Master_Code__c != null && objInv.Document_Master_Code__c != objOldInv.Document_Master_Code__c)){
                mapDocCodes.put(objInv.Document_Master_Code__c, null);
            }
        }
        if(!mapDocCodes.isEmpty()){
            for(HexaBPM__Document_Master__c objDM : [select Id,HexaBPM__Code__c from HexaBPM__Document_Master__c where HexaBPM__Code__c IN : mapDocCodes.keySet() ]){mapDocCodes.put(objDM.HexaBPM__Code__c, objDM);}
        }
        
        for(Invoice__c objInv : lstInv){
            if(mapDocCodes.get(objInv.Document_Master_Code__c) != null && mapDocCodes.get(objInv.Document_Master_Code__c).Id != objInv.Document_Master__c){
                objInv.Document_Master__c = mapDocCodes.get(objInv.Document_Master_Code__c).Id;   if(objInv.Source_System__c != 'Catalyst'){objInv.Generate_Document__c = true;  }
            }
        }
        
        if(!mapRecordDocMasters.isEmpty()){
            for(string recordId : mapRecordDocMasters.keySet()){QueueableUtils objQueueableUtils = new QueueableUtils();objQueueableUtils.recordId = recordId;objQueueableUtils.DocumentMasterId = mapRecordDocMasters.get(recordId);system.enqueueJob(objQueueableUtils);}
        }
        System.debug('ITH populateDocumentMaster Limit SOQL===='+Limits.getQueries());
    }
    
    public static void generateInvoiceRunningNumber(list<Invoice__c> lstInv, map<Id, Invoice__c> mapOldInv){
        List<OU_Basd_Invoice_Running_Number__c> invoiceRefLst = OU_Basd_Invoice_Running_Number__c.getall().values();
        Map<String,OU_Basd_Invoice_Running_Number__c> OUvsCSMap = new Map<String,OU_Basd_Invoice_Running_Number__c>();
        Map<String,OU_Basd_Invoice_Running_Number__c> OUvsCSCreditMemoMap = new Map<String,OU_Basd_Invoice_Running_Number__c>();
        for(OU_Basd_Invoice_Running_Number__c eachRecord : invoiceRefLst){
            if(eachRecord.Operating_Unit__c != null && eachRecord.Operating_Unit__c != '101' && eachRecord.Type__c == 'Invoice'){OUvsCSMap.put(eachRecord.Operating_Unit__c.trim(), eachRecord);
            } else if(eachRecord.Type__c == 'Invoice' && eachRecord.Operating_Unit__c == '101'){OUvsCSMap.put(eachRecord.Source_System__c.trim(), eachRecord);
            } else if(eachRecord.Operating_Unit__c != null && eachRecord.Operating_Unit__c != '101' && eachRecord.Type__c == 'Credit Memo'){
                OUvsCSCreditMemoMap.put(eachRecord.Operating_Unit__c.trim(), eachRecord);
            } else if(eachRecord.Type__c == 'Credit Memo' && eachRecord.Operating_Unit__c == '101'){OUvsCSCreditMemoMap.put(eachRecord.Source_System__c.trim(), eachRecord);}
        }
        Set<Id> entityIds = new Set<Id>();
        for(Invoice__c eachInvoice : lstInv){
            entityIds.add(eachInvoice.Entity__c);
        }
        
        Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id,Oracle_Site_Id__c,Sys_Site_Id__c,Source_System__c FROM Account WHERE Id IN : entityIds]);
        Map<String,List<Invoice__c>> invoiceMap = new Map<String,List<Invoice__c>>();
        Map<String,List<Invoice__c>> CreditMemoMap = new Map<String,List<Invoice__c>>();
        Id invRecTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
        Id creditRecTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Credit Memo').getRecordTypeId();
        system.debug(invRecTypeId);
        for(Invoice__c eachInvoice : lstInv){
            //(eachInvoice.Status__c == 'Approved' || eachInvoice.Status__c == 'Success') && 
            if(accountMap.get(eachInvoice.Entity__c)!=null && eachInvoice.recordtypeId == invRecTypeId && (mapOldInv == null || mapOldInv.get(eachInvoice.id).Status__c <> 'Approved' || mapOldInv.get(eachInvoice.id).Status__c <> 'Success' ) ){
                if(accountMap.get(eachInvoice.Entity__c).Sys_Site_Id__c != '101'){
                    if(invoiceMap.containskey(accountMap.get(eachInvoice.Entity__c).Sys_Site_Id__c)){invoiceMap.get(accountMap.get(eachInvoice.Entity__c).Sys_Site_Id__c).add(eachInvoice);}
                    else {invoiceMap.put(accountMap.get(eachInvoice.Entity__c).Sys_Site_Id__c, new List<Invoice__c>{eachInvoice});}
                } else {
                    if(invoiceMap.containskey(accountMap.get(eachInvoice.Entity__c).Source_System__c)){invoiceMap.get(accountMap.get(eachInvoice.Entity__c).Source_System__c).add(eachInvoice);} 
                    else {invoiceMap.put(accountMap.get(eachInvoice.Entity__c).Source_System__c, new List<Invoice__c>{eachInvoice});}
                }
            } 
            
            //(eachInvoice.Status__c == 'Approved' || eachInvoice.Status__c == 'Success') &&
            if(accountMap.get(eachInvoice.Entity__c)!=null && eachInvoice.recordtypeId == creditRecTypeId && (mapOldInv == null || mapOldInv.get(eachInvoice.id).Status__c <> 'Approved' || mapOldInv.get(eachInvoice.id).Status__c <> 'Success' ) ){
                if(accountMap.get(eachInvoice.Entity__c).Sys_Site_Id__c != '101'){
                    if(CreditMemoMap.containskey(accountMap.get(eachInvoice.Entity__c).Sys_Site_Id__c)){CreditMemoMap.get(accountMap.get(eachInvoice.Entity__c).Sys_Site_Id__c).add(eachInvoice);
                    } else {
                        CreditMemoMap.put(accountMap.get(eachInvoice.Entity__c).Sys_Site_Id__c, new List<Invoice__c>{eachInvoice});
                    }
                } else {
                    if(CreditMemoMap.containskey(accountMap.get(eachInvoice.Entity__c).Source_System__c)){CreditMemoMap.get(accountMap.get(eachInvoice.Entity__c).Source_System__c).add(eachInvoice);}
                    else{CreditMemoMap.put(accountMap.get(eachInvoice.Entity__c).Source_System__c, new List<Invoice__c>{eachInvoice});}
                }
            }
        }
        system.debug('--->'+invoiceMap);
        system.debug('--->'+invoiceMap.keyset());
        system.debug('--->'+OUvsCSMap);
        system.debug('--->'+OUvsCSMap.keyset());
        List<OU_Basd_Invoice_Running_Number__c> customSettingToUpdate = new List<OU_Basd_Invoice_Running_Number__c>();
        // update invoice nymber
        for(String eachOU : invoiceMap.keyset()){
            if(OUvsCSMap.containskey(eachOU)){OU_Basd_Invoice_Running_Number__c currentSetting = OUvsCSMap.get(eachOU);
                for(Invoice__c eachInv : invoiceMap.get(eachOU)){
                       // currentSetting.Running_Number__c = currentSetting.Running_Number__c+1;
                    if(eachInv.Source_Invoice_Id__c == null) {currentSetting.Running_Number__c = currentSetting.Running_Number__c+1;String crrentNumber = String.valueOf(Integer.valueof(currentSetting.Running_Number__c));String leadingZeros = '';
                        if(crrentNumber.length() < 6){for(Integer i = 6; i > crrentNumber.length(); i--){leadingZeros += '0';}}
						eachInv.Source_Invoice_Id__c = currentSetting.Prefix__c+leadingZeros+crrentNumber;}}
                customSettingToUpdate.add(currentSetting);
            } else {for(Invoice__c eachInv : invoiceMap.get(eachOU)){eachInv.Source_Invoice_Id__c = eachInv.Name;}
            }
        }
        // update credit memo number
        for(String eachOU : CreditMemoMap.keyset()){
            if(OUvsCSCreditMemoMap.containskey(eachOU)){
                OU_Basd_Invoice_Running_Number__c currentSetting = OUvsCSCreditMemoMap.get(eachOU);
                for(Invoice__c eachInv : CreditMemoMap.get(eachOU)){
                    if(eachInv.Source_Invoice_Id__c == null) {
                        currentSetting.Running_Number__c = currentSetting.Running_Number__c+1;String crrentNumber = String.valueOf(Integer.valueof(currentSetting.Running_Number__c));String leadingZeros = '';
                        if(crrentNumber.length() < 6){for(Integer i = 6; i > crrentNumber.length(); i--){leadingZeros += '0';}}
                        eachInv.Source_Invoice_Id__c = currentSetting.Prefix__c+leadingZeros+crrentNumber;
                    } 
                }
                customSettingToUpdate.add(currentSetting);
            } else {
                for(Invoice__c eachInv : CreditMemoMap.get(eachOU)){
                    eachInv.Source_Invoice_Id__c = eachInv.Name;
                }
            }
        }
        
        if(customSettingToUpdate.size() > 0){update customSettingToUpdate;}
        System.debug('ITH generateInvoiceRunningNumber Limit SOQL===='+Limits.getQueries());
    }
    
    
    public static void createCustomerInvoiceReceipt(list<Invoice__c> lstInv, map<Id, Invoice__c> mapOldInv){
        Set<Id> invoiceIds = new Set<Id>();
        
        for(Invoice__c inv : lstInv){
            if(inv.Oracle_Invoice_Id__c != null){invoiceIds.add(inv.Id);}
        }
        Set<Id> alreadyPresentIds = new Set<Id>();
        for(Customer_Invoice_Receipt__c eachRec : [SELECT Id,Invoice__c FROM Customer_Invoice_Receipt__c where Invoice__c IN : invoiceIds]){alreadyPresentIds.add(eachRec.Invoice__c);}
        
        List<Customer_Invoice_Receipt__c> listToInsert = new List<Customer_Invoice_Receipt__c>();
        for(Invoice__c inv : lstInv){
            system.debug(alreadyPresentIds.contains(inv.Id));
            system.debug('inside loop');
            if(! alreadyPresentIds.contains(inv.Id)){
                listToInsert.add(new Customer_Invoice_Receipt__c(Invoice__c = inv.Id, Entity__c = inv.Entity__c));
            }
        }
        
        if(listToInsert.size() > 0){
            insert listToInsert;
        }
        
        System.debug('ITH createCustomerInvoiceReceipt Limit SOQL===='+Limits.getQueries());
    }
    
    public static void populateExchangeRate(list<Invoice__c> lstInv){
        List<Date> invoiceDates = new List<Date>();
        for(Invoice__c inv : lstInv){
            if(inv.GL_Date__c != null){invoiceDates.add(Date.valueof(inv.GL_Date__c));
            } else {
                invoiceDates.add(date.valueof(inv.Invoice_Date__c));
            }
        }
        
        Map<Date,Exchange_Rate__c> dateVsExRateMap = new Map<Date,Exchange_Rate__c>();
        for(Exchange_Rate__c exRate : [SELECT Id,Conversion_Date__c,USD_To_AED_Conversion_Rate__c FROM Exchange_Rate__c WHERE Conversion_Date__c IN: invoiceDates]){dateVsExRateMap.put(exRate.Conversion_Date__c, exRate);}
        
        for(Invoice__c inv : lstInv){
            if(inv.GL_Date__c != null){
                if(dateVsExRateMap.containskey(date.valueOf(inv.GL_Date__c))){inv.Conversion_Rate__c = dateVsExRateMap.get(date.valueOf(inv.GL_Date__c)).USD_To_AED_Conversion_Rate__c;}
            } else {
                if(dateVsExRateMap.containskey(date.valueOf(inv.Invoice_Date__c))){inv.Conversion_Rate__c = dateVsExRateMap.get(date.valueOf(inv.Invoice_Date__c)).USD_To_AED_Conversion_Rate__c;}
            }
        }
        System.debug('ITH populateExchangeRate Limit SOQL===='+Limits.getQueries());
    }
    public static Map<Id,Decimal> invoiceDocVersion;

    public static void populateVersionNumber(list<Invoice__c> lstInv, map<Id, Invoice__c> mapOldInv){
        if(invoiceDocVersion == null){
            invoiceDocVersion = new Map<Id,Decimal>();
        }
        for(Invoice__c inv: lstInv){
            if(!invoiceDocVersion.containsKey(inv.Id) && !mapOldInv.get(inv.Id).Generate_Document__c && inv.Generate_Document__c){ integer counter = (mapOldInv.get(inv.Id).Document_Version__c != null)?Integer.valueOf(mapOldInv.get(inv.Id).Document_Version__c):0;inv.Document_Version__c = counter + 1;invoiceDocVersion.put(inv.Id,inv.Document_Version__c );}
        }
    }
}