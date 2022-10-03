/*
    Author      : Durga Prasad
    Date        : 30-Jan-2018
    Description : Trigger Handler for Receipt Object
    --------------------------------------------------------------------------------------
	 * @Change History
     * Author       	Date            Description
     * Yogesh Mahajan	22/01/2020		Added logic to set Transaction Type value
                                        POSTPAID: Invoice First Receipt Later
                                        PREPAID: Receipt First Invoice Later
	 * Yogesh Mahajan	26jan2020		Added new webservice call

*/
public without sharing class ReceiptTriggerHandler {
    // Recursive trigger issue
    public static Set<Id> receiptsId = new Set<Id>();
    public static boolean isRunTrigger = true;
    //public ReceiptTriggerHandler(){
        //receiptsId = new Set<Id>();
    //}
    public static void Execute_BI(list<Receipt__c> TriggerNew){
        populateBankDetails(TriggerNew);
        if(System.Label.BM_ReceiptTriggerHandler == 'Yes'){
            
            setTransactionType(TriggerNew);
            ReceiptTriggerHelper.GenerateReceiptReference(TriggerNew,null);
            ReceiptTriggerHelper.populateExchangeRate(TriggerNew);
            ReceiptTriggerHelper.generateReceiptRunningNumber(TriggerNew,null);
            populateDocumentMaster(TriggerNew, null);
            ReceiptTriggerHelper.populateGLDate(TriggerNew);
            populateOriginalAmount(TriggerNew);
            
        } else {
            ReceiptTriggerHelper.GenerateReceiptReference(TriggerNew,null);
        }
    }
    public static void Execute_AI(list<Receipt__c> TriggerNew){
        list<Receipt__c> lstReceiptsTBP = new list<Receipt__c>();
        list<Id> lstReceiptsId = new list<Id>();
        for(Receipt__c rp:TriggerNew){
            if(System.Label.BM_ReceiptTriggerHandler == 'Yes'){
            	system.debug('===='+rp.Status__c+'=='+rp.Is_Created_Manually__c+'=='+rp.Receipt_Type__c+'=='+!receiptsId.contains(rp.id));
                if(rp.Status__c=='Success' && !rp.Is_Created_Manually__c && rp.Receipt_Type__c != 'Fund Transfer' && !receiptsId.contains(rp.id) && !rp.Journal_Created__c){
                    lstReceiptsTBP.add(rp);
                    receiptsId.add(rp.id);
                    lstReceiptsId.add(rp.Id);
                }   	
            } else {
                if(rp.Status__c=='Success')
                	lstReceiptsTBP.add(rp);
                 lstReceiptsId.add(rp.Id);
            }  
        }
        if(lstReceiptsTBP.size()>0){
            //comments by yogesh on 26jan2020
            //ReceiptTriggerHelper.PustToOracle(lstReceiptsTBP);
            // Added new web service call
           // ReceiptTriggerHelper.pushReceiptToOracle(lstReceiptsTBP);
            
            /*if(System.Label.BM_Stop_Receipt_Integeration == 'No'){
               if(System.Label.Use_New_Receipt_Oracle_Service == 'Yes'){
                    ReceiptTriggerHelper.pushReceiptToOracle(lstReceiptsTBP);
                } else {
                    ReceiptTriggerHelper.PustToOracle(lstReceiptsTBP);
                } 
            }*/
            ReceiptTriggerHelper.createReceiptJournalEntries(lstReceiptsTBP);
        }
        //if(lstReceiptsId.size()>0){BM_JournalEntryEngine.receiptCreationJournal(lstReceiptsId);}
        if(System.Label.BM_ReceiptTriggerHandler == 'Yes'){
           ReceiptTriggerHelper.createCustomerInvoiceReceipt(TriggerNew, null);
        }
    }
    public static void Execute_BU(list<Receipt__c> TriggerNew,map<Id,Receipt__c> TriggerOldMap){
        populateBankDetails(TriggerNew);
        if(System.Label.BM_ReceiptTriggerHandler == 'Yes'){
            populateVersionNumber(TriggerNew,TriggerOldMap);
            setTransactionType(TriggerNew);
            ReceiptTriggerHelper.RejectionCommentsValidation(TriggerNew,TriggerOldMap);
            ReceiptTriggerHelper.GenerateReceiptReference(TriggerNew,TriggerOldMap);
           //ReceiptTriggerHelper.generateReceiptRunningNumber(TriggerNew,TriggerOldMap);
           populateDocumentMaster(TriggerNew, TriggerOldMap);
        } else {
            populateVersionNumber(TriggerNew,TriggerOldMap);
            ReceiptTriggerHelper.RejectionCommentsValidation(TriggerNew,TriggerOldMap);
       		ReceiptTriggerHelper.GenerateReceiptReference(TriggerNew,TriggerOldMap);
        } 
    }
    public static void Execute_AU(list<Receipt__c> TriggerNew,map<Id,Receipt__c> TriggerOldMap){
        //updateIs_ReadyToPushToOreacleOnInvoice(TriggerNew);
        list<Receipt__c> lstReceiptsTBP = new list<Receipt__c>();
        Set<Receipt__c> lstReceiptswithGLError = new Set<Receipt__c>();
        list<Id> lstReceiptsId = new list<Id>();
        for(Receipt__c rp:TriggerNew){
        system.debug('====old status===='+TriggerOldMap.get(rp.Id).Status__c+'===current sttaus===='+rp.Status__c);
        //|| (rp.Status__c=='Rejected' && rp.Payment_Status__c == 'Payment Received from Incorrect Source')
            if(System.Label.BM_ReceiptTriggerHandler == 'Yes'){
                if((TriggerOldMap.get(rp.Id).Status__c!=rp.Status__c || rp.Is_ReadyToPushToOreacle__c) && (rp.Status__c=='Approved' || rp.Status__c=='Success' ) && rp.Generate_Receipt__c == true && rp.Receipt_Type__c != 'Fund Transfer' && !rp.Journal_Created__c)
                	lstReceiptsTBP.add(rp);
                lstReceiptsId.add(rp.Id);
            } else {
                if(TriggerOldMap.get(rp.Id).Status__c!=rp.Status__c && rp.Status__c=='Approved' && rp.Generate_Receipt__c == true && !rp.Journal_Created__c)
                	lstReceiptsTBP.add(rp);
                lstReceiptsId.add(rp.Id);
            }
            if(TriggerOldMap.get(rp.Id).GL_Date__c != rp.GL_Date__c){
                lstReceiptswithGLError.add(rp);
            }
            
        }
        if(lstReceiptswithGLError.size()>0)
            ReceiptTriggerHelper.updateCloseDateErrorJVs(lstReceiptswithGLError);
        
        if(lstReceiptsTBP.size()>0) {
            //comments by yogesh on 26jan2020
            //ReceiptTriggerHelper.PustToOracle(lstReceiptsTBP);
            // Added new web service call
            //ReceiptTriggerHelper.pushReceiptToOracle(lstReceiptsTBP);
            /*if(System.Label.BM_Stop_Receipt_Integeration == 'No'){
                if(System.Label.Use_New_Receipt_Oracle_Service == 'Yes'){
                    ReceiptTriggerHelper.pushReceiptToOracle(lstReceiptsTBP);
                } else {
                    ReceiptTriggerHelper.PustToOracle(lstReceiptsTBP);
                }
            }*/
            ReceiptTriggerHelper.createReceiptJournalEntries(lstReceiptsTBP);
        }
        //if(lstReceiptsId.size()>0){BM_JournalEntryEngine.receiptCreationJournal(lstReceiptsId);}
        
        //ReceiptTriggerHelper.createCustomerInvoiceReceipt(TriggerNew, TriggerOldMap);    
    }
    
    /*
	Method Name : setTransactionType
	Description : Transaction Type value
				  POSTPAID: Invoice First Receipt Later
				  PREPAID: Receipt First Invoice Later
	*/
    public static void setTransactionType (List<Receipt__c> listReceipt){
        Set<Id> entityIds = new Set<Id>();
        for(Receipt__c objReceipt : listReceipt) {
            entityIds.add(objReceipt.Entity__c);
        }
        System.debug(entityIds);
        if(entityIds <> null && entityIds.size() > 0){
            Map<Id,Account> entityMap = new Map<Id,Account>([SELECT id,recordtype.name,Source_System_Name__c FROM Account WHERE Id in : entityIds]);
            System.debug(entityMap);
            for(Receipt__c objReceipt : listReceipt) {
                if(entityMap <> null && entityMap.values().size() > 0 && (entityMap.get(objReceipt.Entity__c).recordtype.name == 'ADGM Registered Company' || entityMap.get(objReceipt.Entity__c).recordtype.name == 'ADGM Guest') && objReceipt.Payment_Currency__c == 'AED'){
                    objReceipt.Transaction_Type__c = 'Wallet';
                }
                if(string.isBlank(objReceipt.Entity_Authority__c) && entityMap.get(objReceipt.Entity__c) != null){
                    objReceipt.Entity_Authority__c = entityMap.get(objReceipt.Entity__c).Source_System_Name__c;
                }
            }
        }        
    }
    
    public static void populateDocumentMaster(list<Receipt__c> lstReceipts, map<Id, Receipt__c> mapOldReceipts){
        map<string, HexaBPM__Document_Master__c> mapDocCodes = new map<string,  HexaBPM__Document_Master__c>();
        
        set<string> setInvStatus = new set<string>{
            //Constants.STR_Under_Review,
            //Constants.STR_Approved
        };
	        
        for(Receipt__c objRec : lstReceipts){
            if(objRec.Document_Master_Code__c == null)
                continue;
            Receipt__c objOldRec = (mapOldReceipts != null && mapOldReceipts.containsKey(objRec.id)) ? mapOldReceipts.get(objRec.Id) : new Receipt__c();
            if(objRec.Document_Master__c == null && string.isNotEmpty(objRec.Document_Master_Code__c) ){
                mapDocCodes.put(objRec.Document_Master_Code__c, null);
            }
            if( objRec.Document_Master__c != null && setInvStatus.contains(objRec.Status__c) && objRec.Status__c != objOldRec.Status__c ){
            	
            }            
        }
        if(!mapDocCodes.isEmpty()){
            for(HexaBPM__Document_Master__c objDM : [select Id,HexaBPM__Code__c from HexaBPM__Document_Master__c where HexaBPM__Code__c IN : mapDocCodes.keySet() ]){
                mapDocCodes.put(objDM.HexaBPM__Code__c, objDM);
            }
        }
        
        for(Receipt__c objRec : lstReceipts){
            if(mapDocCodes.get(objRec.Document_Master_Code__c) != null && mapDocCodes.get(objRec.Document_Master_Code__c).Id != objRec.Document_Master__c ){
                objRec.Document_Master__c = mapDocCodes.get(objRec.Document_Master_Code__c).Id;                
            	objRec.Generate_Receipt__c = true;
            }
        }
        
        
    }
    public static Map<Id,Decimal> receiptDocVersion;

    public static void populateVersionNumber(list<Receipt__c> lstRec, map<Id, Receipt__c> mapOldRec){
        if(receiptDocVersion == null){
            receiptDocVersion = new Map<Id,Decimal>();
        }
        for(Receipt__c rec: lstRec){
            if(!receiptDocVersion.containsKey(rec.Id) && !mapOldRec.get(rec.Id).Generate_Receipt__c && rec.Generate_Receipt__c){
                integer counter = (mapOldRec.get(rec.Id).Document_Version__c != null)?Integer.valueOf(mapOldRec.get(rec.Id).Document_Version__c):0;
                rec.Document_Version__c = counter + 1;
                receiptDocVersion.put(rec.Id,rec.Document_Version__c );
            }
        }
    }
    
    // New Change to Populate the original receipt amount
    public static void populateOriginalAmount(list<Receipt__c> lstRec){
        for(Receipt__c eachReceipt : lstRec){
            eachReceipt.Original_Receipt_Amount__c = eachReceipt.Amount__c;
        }
    }
    
    public static void populateBankDetails(list<Receipt__c> lstRec){
        set<String> entitySet = new set<String>();
        set<String> paymentMethods = new set<String>();
        set<String> currencySet = new set<String>();
        set<String> ouSet = new set<String>();
        for(Receipt__c recObj : lstRec){
            entitySet.add(recObj.Entity__c);
            if(recObj.Payment_Method__c.contains('Card')){
                paymentMethods.add('Credit Card');
            }else{
                paymentMethods.add(recObj.Payment_Method__c);
            }
            currencySet.add(recObj.Payment_Currency__c);
        }
        
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Operating_Unit__c, Operating_Unit__r.Operating_Unit_Name__c FROM Account WHERE Id IN : entitySet]);
        for(String key : accountMap.keySet()){
            ouSet.add((accountMap.get(key)).Operating_Unit__r.Operating_Unit_Name__c);
        }
        Map<String, Bank_Detail_Configuration__c> bankDetailMap = new Map<String, Bank_Detail_Configuration__c>();
        for(Bank_Detail_Configuration__c bankDetail : [SELECT Id, OU_Currency_PM__c FROM Bank_Detail_Configuration__c WHERE Payment_Method__c IN : paymentMethods OR Currency__c IN : currencySet OR Operating_Unit__r.Operating_Unit_Name__c IN :ouSet]){
            bankDetailMap.put(bankDetail.OU_Currency_PM__c, bankDetail);
        }
        for(Receipt__c recObj : lstRec){
            String paymentMethod= (recObj.Payment_Method__c).contains('Credit Card') ? 'Credit Card' : recObj.Payment_Method__c;
            String uniqueKey = accountMap.get(recObj.Entity__c).Operating_Unit__r.Operating_Unit_Name__c + '-' + recObj.Payment_Currency__c + '-' + paymentMethod;
            if(bankDetailMap.containsKey(uniqueKey)){
                recObj.Bank_Detail_Configuration__c = bankDetailMap.get(uniqueKey).Id;
            }
        }
    }

/*
    public static void updateIs_ReadyToPushToOreacleOnInvoice(List<Receipt__c> newList){
        if(isRunTrigger){
            List<Related_Invoice_Receipt__c> relatedRecords = [SELECT Id,Invoice__c from Related_Invoice_Receipt__c WHERE Receipt__c IN : newList];
            Set<Id> invoiceIds = new Set<Id>();
            for(Related_Invoice_Receipt__c rr : relatedRecords){
                invoiceIds.add(rr.Invoice__c);
            }

            Map<Id,List<Id>> invoiceVsReceiptsMap = new Map<Id,List<Id>>();
            Map<Id,Boolean> receiptVSOracleMap = new Map<Id,Boolean>();
            for(Related_Invoice_Receipt__c eachRelatedRec : [SELECT Id, Invoice__c,Receipt__c,Receipt__r.Oracle_Receipt_Id__c from Related_Invoice_Receipt__c WHERE Invoice__c In : invoiceIds]){
                if(eachRelatedRec.Receipt__r.Oracle_Receipt_Id__c != null && eachRelatedRec.Receipt__r.Oracle_Receipt_Id__c != ''){
                    receiptVSOracleMap.put(eachRelatedRec.Receipt__c,true);
                } else {
                    receiptVSOracleMap.put(eachRelatedRec.Receipt__c,false);
                }
                
                if(invoiceVsReceiptsMap.containsKey(eachRelatedRec.Invoice__c)){
                    invoiceVsReceiptsMap.get(eachRelatedRec.Invoice__c).add(eachRelatedRec.Receipt__c);
                } else {
                    invoiceVsReceiptsMap.put(eachRelatedRec.Invoice__c, new List<Id>{eachRelatedRec.Receipt__c});
                }
            }  

            List<Invoice__c> invoicesToUpdate = new List<Invoice__c>();
            for(Id eachInvoice : invoiceVsReceiptsMap.keySet()){
                boolean isInvoiceReady = true;
                for(Id eacReceipt : invoiceVsReceiptsMap.get(eachInvoice)){
                    if(! receiptVSOracleMap.get(eacReceipt)){
                        isInvoiceReady = false;
                        break;
                    }
                }
                if(isInvoiceReady){
                    invoicesToUpdate.add(new Invoice__c(Id = eachInvoice, Is_ReadyToPushToOreacle__c = true));
                }
            }

            if(invoicesToUpdate.size() > 0){
                InvoiceTriggerHandler.isRunTrigger = false;
                update invoicesToUpdate;
            }
        }
    }
    */
}