/*
    Author      : Durga Prasad
    Date        : 30-Jan-2018
    Description : Trigger handler class that is being invoked from ReceiptTriggerHandler.
 --------------------------------------------------------------------------------------
	 * @Change History
     * Author       	Date            Description
	 * Yogesh Mahajan	26jan2020		Added new webservice call
*/
public without sharing class ReceiptTriggerHelper {
    
    public static void updateCloseDateErrorJVs(Set<Receipt__c> lstReceipts){
        List<Journal_Header__c> jvsToUpdate = new List<Journal_Header__c>();
        Map<Receipt__c,list<Journal_Header__c>> jvMap = new Map<Receipt__c,list<Journal_Header__c>>();
        for(Receipt__c rp : lstReceipts){
            List<Journal_Header__c> jvLst = [Select Id, GL_Date__c,Oracle_Status__c,Error_Message__c from Journal_Header__c where Receipt__c=:rp.Id AND Oracle_Status__c = 'Error' 
                                         AND Error_Message__c LIKE 'GL Period is not open%'];
            System.debug('jvLst with close GL Date error: '+jvLst);
            System.debug('rp: '+rp);
            jvMap.put(rp,jvLst);
        }
        for(Receipt__c rp : jvMap.keyset()){
            for(Journal_Header__c jh : jvMap.get(rp)){
                jh.GL_Date__c = rp.GL_Date__c;jh.Oracle_Status__c = 'Draft';jh.Error_Message__c = '';
                jvsToUpdate.add(jh);
            }
        }
        if(jvsToUpdate.size()>0){ update jvsToUpdate;}
        
    }
    
    public static void createReceiptJournalEntries(list<Receipt__c> lstReceipts){
        List<String> listReceiptsFirst = new List<String>();
        List<String> listReceiptsSecound = new List<String>();
        Integer recordCount = 1;
        for(Receipt__c objReceipt : lstReceipts) {
            if(recordCount <= 100){
                listReceiptsFirst.add(objReceipt.id);
            }
            
            if(recordCount > 100 && recordCount <= 200){listReceiptsSecound.add(objReceipt.id);}
            
            recordCount++;
            if(recordCount == 201){ break;}                
        }
		
		if(listReceiptsFirst <> null && listReceiptsFirst.size() > 0) {
            ReceiptUtil.UpdateAmountAndCreateJournalEntries(listReceiptsFirst);   
        }
        
        // send from 100 - 200 accounts to oracle 
        if(listReceiptsSecound <> null && listReceiptsSecound.size() > 0) {ReceiptUtil.UpdateAmountAndCreateJournalEntries(listReceiptsSecound);    } 
    }
    
    /*public static void PustToOracle(list<Receipt__c> lstReceipts){
        for(Receipt__c rp:lstReceipts){
            //------------------USE THIS METHOD IN UAT----------------------------
               ReceiptUtil.PushReceiptToOracle_Future(rp.Id);
            //------------------USE THIS METHOD IN PROD---------------------------
           // ReceiptUtil.Prod_PushReceiptToOracle_Future(rp.Id);
        }
    }
    
    public static void pushReceiptToOracle(List<Receipt__c> listReceipt) {
        List<String> listReceiptsFirst = new List<String>();
        List<String> listReceiptsSecound = new List<String>();
        Integer recordCount = 1;
        for(Receipt__c objReceipt : listReceipt) {
            if(recordCount <= 100){
                listReceiptsFirst.add(objReceipt.id);
            }
            
            if(recordCount > 100 && recordCount <= 200){
                listReceiptsSecound.add(objReceipt.id);
            }
            
            recordCount++;
            if(recordCount == 201){
                break;
            }
                
        }//end for
        // send first 100 accounts to oracle 
        if(listReceiptsFirst <> null && listReceiptsFirst.size() > 0) {
            ReceiptUtil.PushReceiptToOracle_Future_New(listReceiptsFirst);   
        }
        
        // send from 100 - 200 accounts to oracle 
        if(listReceiptsSecound <> null && listReceiptsSecound.size() > 0) {
            ReceiptUtil.PushReceiptToOracle_Future_New(listReceiptsSecound);    
        }
    }*/
    
    /*
        Method Name :   GenerateReceiptReference
        Description :   Method to populate the Receipt Reference of receipts.
    */
    public static void GenerateReceiptReference(list<Receipt__c> lstReceipts, Map<Id, Receipt__c> oldReceiptMap){
        
        List<Receipt_Running_Number__c> receiptRefList = Receipt_Running_Number__c.getall().values();
        Receipt_Running_Number__c receiptRef = new Receipt_Running_Number__c();
        if(!receiptRefList.isEmpty()){
            receiptRef = receiptRefList[0];
        } else{
            receiptRef.Name = 'Receipt_Reference_Number';
            receiptRef.Receipt_Prefix__c = 'R-';
            receiptRef.Running_Number__c = 1;
            insert receiptRef;
        }
          
        //Receipt_Running_Number__c receiptRef = Receipt_Running_Number__c.getInstance('Receipt_Reference_Number');
        
        Integer receiptRunningNumber = 0;
        if(receiptRef != null){
            if(receiptRef.Running_Number__c != null){
                receiptRunningNumber = Integer.valueOf(receiptRef.Running_Number__c);
            }
            if(System.Label.BM_ReceiptTriggerHandler == 'Yes'){
            	map<string,Receipt_Running_Number__c> receiptRunNum = new map<string,Receipt_Running_Number__c>();
                for(Receipt__c objRec : lstReceipts){
                    system.debug(objRec.Receipt_Reference__c);
                    if((objRec.Status__c == 'Success' || objRec.Status__c == 'Approved') && 
                        (objRec.Receipt_Reference__c == '' || objRec.Receipt_Reference__c == null) && objRec.Status__c != null){
                            System.debug('-------INSIDE IF CONDITION--------');
                            objRec.Receipt_Reference__c = receiptRef.Receipt_Prefix__c + String.valueOf(++receiptRunningNumber).leftpad(7).replace(' ', '0');
                            receiptRunningNumber = receiptRunningNumber+1;
                            receiptRef.Running_Number__c = receiptRunningNumber;
                            receiptRunNum.put(receiptRef.Id,receiptRef);
                    }
                }
                
                if(receiptRunNum.size()>0){
                    update receiptRunNum.values();
           		}    
            } else {
                List<Receipt_Running_Number__c> receiptRunNum = new List<Receipt_Running_Number__c>();
                for(Receipt__c objRec : lstReceipts){
                    if((objRec.Status__c == 'Success' || objRec.Status__c == 'Approved') && 
                        (objRec.Receipt_Reference__c == '' || objRec.Receipt_Reference__c == null) && objRec.Status__c != null){
                            objRec.Receipt_Reference__c = receiptRef.Receipt_Prefix__c + String.valueOf(++receiptRunningNumber).leftpad(7).replace(' ', '0');
                            receiptRef.Running_Number__c = receiptRunningNumber;
                            receiptRunNum.add(receiptRef);
                    }
                }
                
                if(!receiptRunNum.isEmpty()){update receiptRunNum;}
            } 
        }
    }
    
    /*
        Method Name :   RejectionCommentsValidation
        Description :   Method to check if th user provided reason on process rejection.
    */
    
    public static void RejectionCommentsValidation(list<Receipt__c> lstReceipts, Map<Id, Receipt__c> oldReceiptMap){
    
        Map<Id,Receipt__c> rejectedReceiptMap = new Map<Id,Receipt__c>();
        Set<Id> approvedReceiptIds = new Set<Id>();
        
        system.debug('##BEFOREUPDATE: ');
        
        for(Receipt__c objRec : lstReceipts){
            if(objRec.Status__c != oldReceiptMap.get(objRec.Id).Status__c){
                if(objRec.Status__c == 'Rejected'){rejectedReceiptMap.put(objRec.Id, objRec);}
                else if(objRec.Status__c == 'Approved'){
                    approvedReceiptIds.add(objRec.Id);
                }
            }
        }
        
        system.debug('##APPROVED: '+approvedReceiptIds);
        
        Map<Id,String> processInstanceMap = new Map<Id,String>();
        for(Receipt__c objR : [SELECT Id, Comments__c, 
                                    (SELECT Id 
                                    FROM ProcessInstances 
                                    ORDER BY CreatedDate DESC 
                                    LIMIT 1)
                                FROM Receipt__c 
                                WHERE (Id IN :rejectedReceiptMap.keyset() 
                                OR Id IN :approvedReceiptIds)]){
            if(objR.ProcessInstances.size() > 0){
                if(rejectedReceiptMap.containskey(objR.Id)){processInstanceMap.put(objR.ProcessInstances[0].Id, 'REJECTED');}
                else if(approvedReceiptIds.contains(objR.Id)){processInstanceMap.put(objR.ProcessInstances[0].Id, 'APPROVED');}
            }
        }
        
        system.debug('##APPROVEDPIMAP: '+processInstanceMap);
        
        Map<Id, String> receiptCommentsMap = new Map<Id,String>();
        for(ProcessInstance pi : [SELECT Id, TargetObjectId,
                                    (SELECT Id, StepStatus, Comments 
                                    FROM Steps 
                                    ORDER BY CreatedDate DESC)
                               FROM ProcessInstance
                               WHERE Id IN :processInstanceMap.keyset()
                               ORDER BY CreatedDate DESC]){
            system.debug('##COMMENTS: '+pi.Steps[0].Comments);
            system.debug('##STEPS: '+pi.Steps);
            if(processInstanceMap.get(pi.Id) == 'APPROVED'){
                system.debug('##APPROVED: ');system.debug('##NOW: '+System.now());receiptCommentsMap.put(pi.TargetObjectId, pi.Steps[0].Comments);
            } else{
                if(pi.Steps[0].Comments == null || pi.Steps[0].Comments.trim().length() == 0){rejectedReceiptMap.get(pi.TargetObjectId).addError('Please provide a rejection reason.');}
                else{system.debug('##NOW: '+System.now());receiptCommentsMap.put(pi.TargetObjectId, pi.Steps[0].Comments);}
            }
        }
        
        system.debug('##INSTANCEMAP: '+receiptCommentsMap);
        
        for(Receipt__c objRec : lstReceipts){
            system.debug('##NEWSTATUS: '+objRec.Status__c);
            system.debug('##OLDSTATUS: '+oldReceiptMap.get(objRec.Id).Status__c);
            if(objRec.Status__c != oldReceiptMap.get(objRec.Id).Status__c){
                if(receiptCommentsMap.containskey(objRec.Id)){objRec.Comments__c = receiptCommentsMap.get(objRec.Id);}
            }
        }
    }
    
    public static void createCustomerInvoiceReceipt(list<Receipt__c> lstReceipts, Map<Id, Receipt__c> oldReceiptMap){
        Set<Id> receiptIds = new Set<Id>();
        for(Receipt__c rec : lstReceipts){
            if(rec.Oracle_Receipt_Id__c != null){receiptIds.add(rec.Id);}
        }
        Set<Id> alreadyPresentIds = new Set<Id>();
        for(Customer_Invoice_Receipt__c eachRec : [SELECT Id,Receipt__c FROM Customer_Invoice_Receipt__c where Receipt__c IN : receiptIds]){alreadyPresentIds.add(eachRec.Receipt__c);}
        
        List<Customer_Invoice_Receipt__c> listToInsert = new List<Customer_Invoice_Receipt__c>();
        for(Receipt__c rec : lstReceipts){
            if(! alreadyPresentIds.contains(rec.Id)){
                listToInsert.add(new Customer_Invoice_Receipt__c(Receipt__c = rec.Id, Entity__c = rec.Entity__c));
            }
        }
        
        if(listToInsert.size() > 0){
            insert listToInsert;
        }
    }
    
    public static void populateExchangeRate(list<Receipt__c> lstReceipts){
        List<Date> receiptDates = new List<Date>();
        for(Receipt__c rec : lstReceipts){
            if(rec.GL_Date__c != null){receiptDates.add(rec.GL_Date__c);} 
            else {receiptDates.add(date.valueof(rec.Receipt_Date__c));}
        }
        
        Map<Date,Exchange_Rate__c> dateVsExRateMap = new Map<Date,Exchange_Rate__c>();
        for(Exchange_Rate__c exRate : [SELECT Id,Conversion_Date__c,USD_To_AED_Conversion_Rate__c FROM Exchange_Rate__c WHERE Conversion_Date__c IN: receiptDates]){dateVsExRateMap.put(exRate.Conversion_Date__c, exRate);}
        
        for(Receipt__c rec : lstReceipts){
            if(rec.GL_Date__c != null){
                if(dateVsExRateMap.containskey(rec.GL_Date__c)){ rec.Conversion_Rate__c = dateVsExRateMap.get(rec.GL_Date__c).USD_To_AED_Conversion_Rate__c;}
            } else {
                if(dateVsExRateMap.containskey(date.valueOf(rec.Receipt_Date__c))){rec.Conversion_Rate__c = dateVsExRateMap.get(date.valueOf(rec.Receipt_Date__c)).USD_To_AED_Conversion_Rate__c;}
            }
        }
    }
    
    public static void populateGLDate(list<Receipt__c> lstReceipts){
        for(Receipt__c rec : lstReceipts){
            if(rec.GL_Date__c == null){
                rec.GL_Date__c = Date.valueof(rec.Receipt_Date__c);
            }
        }
    }
      
    
    public static void generateReceiptRunningNumber(list<Receipt__c> lstRec, map<Id, Receipt__c> mapOldInv){
        List<OU_Basd_Invoice_Running_Number__c> receiptRefLst = OU_Basd_Invoice_Running_Number__c.getall().values();
        Map<String,OU_Basd_Invoice_Running_Number__c> OUvsCSMap = new Map<String,OU_Basd_Invoice_Running_Number__c>();
        for(OU_Basd_Invoice_Running_Number__c eachRecord : receiptRefLst){
            if(eachRecord.Operating_Unit__c != null && eachRecord.Operating_Unit__c != '101' && eachRecord.Type__c == 'Receipt'){
                OUvsCSMap.put(eachRecord.Operating_Unit__c.trim(), eachRecord);
            } 
            else if(eachRecord.Type__c == 'Receipt' && eachRecord.Operating_Unit__c == '101') {OUvsCSMap.put(eachRecord.Source_System__c.trim(), eachRecord);} 
        }
        Set<Id> entityIds = new Set<Id>();
        for(Receipt__c eachReceipt : lstRec){
            entityIds.add(eachReceipt.Entity__c);
        }
        
        Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id,Oracle_Site_Id__c,Source_System__c FROM Account WHERE Id IN : entityIds]);
        Map<String,List<Receipt__c>> receiptMap = new Map<String,List<Receipt__c>>();
        for(Receipt__c eachReceipt : lstRec){
            if(  (mapOldInv == null || mapOldInv.get(eachReceipt.id).Status__c <> 'Approved' || mapOldInv.get(eachReceipt.id).Status__c <> 'Success' ) ){
                if(accountMap.get(eachReceipt.Entity__c).Oracle_Site_Id__c != '101'){
                    if(receiptMap.containskey(accountMap.get(eachReceipt.Entity__c).Oracle_Site_Id__c)){receiptMap.get(accountMap.get(eachReceipt.Entity__c).Oracle_Site_Id__c).add(eachReceipt);} 
                    else {receiptMap.put(accountMap.get(eachReceipt.Entity__c).Oracle_Site_Id__c, new List<Receipt__c>{eachReceipt});}
                } else {
                    if(receiptMap.containskey(accountMap.get(eachReceipt.Entity__c).Source_System__c)){receiptMap.get(accountMap.get(eachReceipt.Entity__c).Source_System__c).add(eachReceipt);} else { receiptMap.put(accountMap.get(eachReceipt.Entity__c).Source_System__c, new List<Receipt__c>{eachReceipt});}
                }
            } 
        }
        
        List<OU_Basd_Invoice_Running_Number__c> customSettingToUpdate = new List<OU_Basd_Invoice_Running_Number__c>();
        // update Receipt number
        system.debug(receiptMap.keyset());
        system.debug(OUvsCSMap);
        for(String eachOU : receiptMap.keyset()){
            if(OUvsCSMap.containskey(eachOU)){
                OU_Basd_Invoice_Running_Number__c currentSetting = OUvsCSMap.get(eachOU);
                for(Receipt__c eachRec : receiptMap.get(eachOU)){
                    if(eachRec.Source_Receipt_Id__c == null) {
                        currentSetting.Running_Number__c = currentSetting.Running_Number__c+1;
                        String crrentNumber = String.valueOf(Integer.valueof(currentSetting.Running_Number__c));
                        String leadingZeros = '';
                        if(crrentNumber.length() < 6){
                            for(Integer i = 6; i > crrentNumber.length(); i--){
                                leadingZeros += '0';
                            }
                        }
                        
                        eachRec.Source_Receipt_Id__c = currentSetting.Prefix__c+leadingZeros+crrentNumber;
                    }
                    
                }
                customSettingToUpdate.add(currentSetting);
            } else {
                for(Receipt__c eachRec : receiptMap.get(eachOU)){ eachRec.Source_Receipt_Id__c = eachRec.Name;}
            }
        }
        
        
        if(customSettingToUpdate.size() > 0){
            update customSettingToUpdate;
        }
    }
}