/*
    Author      : Yogesh Mahajan
    Date        : 30-Jan-2018
    Description : Trigger Handler for Invoice line item Object
    Version History 
    Prachi Sinha            02-August-2021          Once the Adjustment Invoice line item status changes to 'Invoiced', 
                                                    it will be pushed to the corresponding source system
*/
public without sharing class  InvoiceLineItemTriggerHandler {
    public static boolean isCreateDiscount = true;
    public static void Execute_BI(list<Invoice_Line_Item__c> TriggerNew){
        validateInvoiceLineBeforeInsert(TriggerNew);
        populateRevenueTypeField(TriggerNew,null);
        chnageAmountValueofAdjustment(TriggerNew);
        populateRevenueForAccess(TriggerNew);
        populateTaxAmount(TriggerNew);
        checkIsCMApplication(TriggerNew);
        populateLineGLDate(TriggerNew);

    }
    
    public static void Execute_AI(list<Invoice_Line_Item__c> TriggerNew){
        updateCMAppliedAmount(TriggerNew);
        Map<Id,String> mapofILIRecordTypeIdAndName = new Map<Id,String>();
        mapofILIRecordTypeIdAndName = ApexCodeUtility.getRecordTypeDetails('Invoice_Line_Item__c');
        list<Id> listInvoiceLineItemIds = new list<Id>();
        for(Invoice_Line_Item__c objInvoiceLineItem : TriggerNew) {
            if(mapofILIRecordTypeIdAndName.get(objInvoiceLineItem.RecordtypeId) == 'Adjustment' && objInvoiceLineItem.Status__c == 'Success') {
                listInvoiceLineItemIds.add(objInvoiceLineItem.id);
                break;
            }
        }
        if(listInvoiceLineItemIds <> null && listInvoiceLineItemIds.size() > 0) {
            //InvoiceUtil.PushAdjToOracle_Future(listInvoiceLineItemIds[0]);
           // BM_JournalEntryEngine.invoiceAdjustmentCreationJournal(listInvoiceLineItemIds);
        }
        
        Map<Id, Invoice_Line_Item__c> mapInvoicelineItem = new Map<Id, Invoice_Line_Item__c>();
        for(Invoice_Line_Item__c objInvoice_Line_Item : TriggerNew) {
            if(objInvoice_Line_Item.Discount_Amount__c > 0 && !objInvoice_Line_Item.Is_Discount__c) {
                mapInvoicelineItem.put(objInvoice_Line_Item.id, objInvoice_Line_Item);
            }
        }
        if(isCreateDiscount)
        createDiscount(mapInvoicelineItem);
    }
    
    
    
    public static void Execute_BU(list<Invoice_Line_Item__c> TriggerNew,map<Id,Invoice_Line_Item__c> TriggerOldMap){
        populateRevenueTypeField(TriggerNew,TriggerOldMap);
        chnageAmountValueofAdjustment(TriggerNew);
        populateRevenueForAccess(TriggerNew);
        populateTaxAmount(TriggerNew);
        checkIsCMApplication(TriggerNew);
        populateLineGLDate(TriggerNew);
    }
    
    public static void Execute_AU(list<Invoice_Line_Item__c> TriggerNew,map<Id,Invoice_Line_Item__c> TriggerOldMap){
        updateCMAppliedAmount(TriggerNew);
        Map<Id,String> mapofILIRecordTypeIdAndName = new Map<Id,String>();
        mapofILIRecordTypeIdAndName = ApexCodeUtility.getRecordTypeDetails('Invoice_Line_Item__c');
        list<Id> listInvoiceLineItemIds = new list<Id>();
        list<Id> listInvoiceLineInvoicedIds = new list<Id>();
        Set<Invoice_Line_Item__c> lstILIwithGLError = new Set<Invoice_Line_Item__c>();
        for(Invoice_Line_Item__c objInvoiceLineItem : TriggerNew) {
            if(mapofILIRecordTypeIdAndName.get(objInvoiceLineItem.RecordtypeId) == 'Adjustment' && (objInvoiceLineItem.Status__c == 'Success' || objInvoiceLineItem.Status__c == 'Approved') && !objInvoiceLineItem.From_Data_Load__c) {
                listInvoiceLineItemIds.add(objInvoiceLineItem.id);
                break;
            }
            if(mapofILIRecordTypeIdAndName.get(objInvoiceLineItem.RecordtypeId) == 'Adjustment' && objInvoiceLineItem.Status__c == 'Invoiced' && !objInvoiceLineItem.From_Data_Load__c) {
                listInvoiceLineInvoicedIds.add(objInvoiceLineItem.id);
                break;
            }
            if(TriggerOldMap.get(objInvoiceLineItem.Id).GL_Date__c != objInvoiceLineItem.GL_Date__c){
                lstILIwithGLError.add(objInvoiceLineItem);
            }
        }


        if(listInvoiceLineInvoicedIds <> null && listInvoiceLineInvoicedIds.size() > 0) {System.enqueueJob(new WS_InvoiceAdjustmentAsync(listInvoiceLineInvoicedIds[0]));}

        if(listInvoiceLineItemIds <> null && listInvoiceLineItemIds.size() > 0) {InvoiceUtil.PushAdjToOracle_Future(listInvoiceLineItemIds[0]);}
        
        if(lstILIwithGLError <> null && lstILIwithGLError.size() > 0) {updateCloseDateErrorJVs(lstILIwithGLError);}
        
        Map<Id, Invoice_Line_Item__c> mapInvoicelineItem = new Map<Id, Invoice_Line_Item__c>();
        List<Id> listCancelLineId = new List<Id>();
        for(Invoice_Line_Item__c objInvoice_Line_Item : TriggerNew) {
            if(objInvoice_Line_Item.Status__c == 'Cancelled') {listCancelLineId.add(objInvoice_Line_Item.id);}
            
            if(objInvoice_Line_Item.Discount_Amount__c > 0 && !objInvoice_Line_Item.Is_Discount__c &&  TriggerOldMap.get(objInvoice_Line_Item.id).Discount_Amount__c <> objInvoice_Line_Item.Discount_Amount__c) {
                mapInvoicelineItem.put(objInvoice_Line_Item.id, objInvoice_Line_Item);
            }
        }
        if(mapInvoicelineItem <> null && mapInvoicelineItem.values().size() > 0 && isCreateDiscount){createDiscount(mapInvoicelineItem);}
            
        if(listCancelLineId <> null && listCancelLineId.size() > 0){deleteDiscountLine(listCancelLineId);}
            
        
    }
    
    public static void updateCloseDateErrorJVs(Set<Invoice_Line_Item__c> ILIRecLst){
        List<Journal_Header__c> jvsToUpdate = new List<Journal_Header__c>();
        Map<Invoice_Line_Item__c,list<Journal_Header__c>> jvMap = new Map<Invoice_Line_Item__c,list<Journal_Header__c>>();
        for(Invoice_Line_Item__c inv : ILIRecLst){
            List<Journal_Header__c> jvLst = [Select Id, GL_Date__c,Oracle_Status__c,Error_Message__c from Journal_Header__c where Invoice_Line_Item__c=:inv.Id AND Oracle_Status__c = 'Error' 
                                         AND Error_Message__c LIKE 'GL Period is not open%'];
            System.debug('jvLst with close GL Date error: '+jvLst);
            System.debug('inv: '+inv);
            jvMap.put(inv,jvLst);
        }
        for(Invoice_Line_Item__c inv : jvMap.keyset()){
            for(Journal_Header__c jh : jvMap.get(inv)){jh.GL_Date__c = inv.GL_Date__c;jh.Oracle_Status__c = 'Draft';jh.Error_Message__c = '';jvsToUpdate.add(jh);}
        }
        if(jvsToUpdate.size()>0){update jvsToUpdate;}
        
    }
    
    // ------------------------Populate GL Date for Invoice line item and Credit Memo Line----------------------------------
    public static void populateLineGLDate(list<Invoice_Line_Item__c> newList){
        Id recTypeId = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Adjustment').getRecordTypeId();
        Set<Id> invIds = new Set<Id>();
        for(Invoice_Line_Item__c ili : newList){
            if(ili.RecordTypeId != recTypeId && ! ili.Is_Credit_Memo_Application__c){
                invIds.add(ili.Invoice__c);
            } else if(ili.RecordTypeId == recTypeId){
                ili.GL_Date__c = ili.Date_Of_Adjustment__c;
            } else if(ili.RecordTypeId != recTypeId && ili.Is_Credit_Memo_Application__c){
                ili.GL_Date__c = Date.today();
            }
        }
        Map<Id,Invoice__c> invoiceMap = new Map<Id, Invoice__c>([Select id,GL_date__c,Invoice_Date__c from Invoice__c where Id in : invIds]);
        for(Invoice_Line_Item__c ili : newList){
            if(ili.RecordTypeId != recTypeId && ! ili.Is_Credit_Memo_Application__c){
                if(invoiceMap.containskey(ili.Invoice__c)){
                    if(invoiceMap.get(ili.Invoice__c).GL_Date__c != null){ili.GL_Date__c = Date.valueof(invoiceMap.get(ili.Invoice__c).GL_Date__c);} 
                    else {ili.GL_Date__c = Date.valueof(invoiceMap.get(ili.Invoice__c).Invoice_Date__c);}
                }
            }
        }
    }
    
    //--------------Populate Is Credit Memo Application Line checkbox -------------
    public static void checkIsCMApplication(list<Invoice_Line_Item__c> newList){
        for(Invoice_Line_Item__c eachLine : newList){
            if(eachLine.Related_Credit_Memo__c != null){eachLine.Is_CM_Application__c = true;} 
            else {eachLine.Is_CM_Application__c = false;}
        }
    }
    
    //----------- Calculate CM Applied amount -----------------------
    public static void updateCMAppliedAmount(list<Invoice_Line_Item__c> newList){
        Set<Id> invoiceIds = new Set<Id>();
        for(Invoice_Line_Item__c ili : newList){
            if(ili.Related_Credit_Memo__c != null){invoiceIds.add(ili.Related_Credit_Memo__c);}
        }
        
        List<Invoice__c> invoices = [SELECT id,CM_Applied_Amount_OC__c,(SELECT Id,Amount__c,Tax_Amount__c FROM Invoice_Line_Items1__r) from Invoice__c where Id IN : invoiceIds];
        
        for(Invoice__c inv : invoices){
            Decimal totalAmt = 0;
            for(Invoice_Line_Item__c ili : inv.Invoice_Line_Items1__r){
                if(ili.Tax_Amount__c!=null){totalAmt += ili.Amount__c + ili.Tax_Amount__c;}
                else{ totalAmt += ili.Amount__c;}
            }
            inv.CM_Applied_Amount_OC__c  = totalAmt;
        }
        
        //update invoices;
    }
    
    //--------------- Populate Tax Amount --------------------------
    public static void populateTaxAmount(list<Invoice_Line_Item__c> newList){
        Id recTypeId = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Invoice_Line_Item').getRecordTypeId();
        Id cmrecTypeId = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Credit_Memo_Line').getRecordTypeId();
        for(Invoice_Line_Item__c newlineItem : newList){
            if((newlineItem.RecordTypeId == recTypeId || newlineItem.RecordTypeId == cmrecTypeId) && ! newlineItem.Is_Discount__c){
                system.debug('===========>'+ newlineItem.Tax__c);
                if(newlineItem.Tax__c == '5%'){
                    Decimal qty = newlineItem.Quantity__c != null && newlineItem.Quantity__c != 0 ? newlineItem.Quantity__c : 1; 
                    Decimal disc = newlineItem.Discount_Amount__c != null ? newlineItem.Discount_Amount__c : 0; 
                    system.debug('===========>'+ qty);
                    system.debug('===========>'+ newlineItem.Amount__c);
                    system.debug('===========>'+ newlineItem.Discount_Amount__c);
                    //newlineItem.Tax_Amount__c = ((newlineItem.Amount__c * qty) - disc)/20;
                    newlineItem.Tax_Amount__c = (newlineItem.Amount__c * qty)/20;
                }    
            }
        }
    }
    //------------- Populate Revenue Mapping from SR Price Item -------
    public static void populateRevenueForAccess(list<Invoice_Line_Item__c> newList){
        Set<Id> srPriceItemIds = new Set<Id>();
        for(Invoice_Line_Item__c ili : newList){
            if(ili.SR_Price_Item__c != null){
                srPriceItemIds.add(ili.SR_Price_Item__c);
            }
        }
        
        Map<Id,HexaBPM__SR_Price_Item__c> pricingItemMap = new Map<Id,HexaBPM__SR_Price_Item__c>([SELECT Id,Department__c,Service_Class__c,Service_Type__c,Revenue_Type__c from HexaBPM__SR_Price_Item__c where id in : srPriceItemIds]);
        for(Invoice_Line_Item__c ili : newList){
            if(ili.SR_Price_Item__c != null){
                if(pricingItemMap.containsKey(ili.SR_Price_Item__c)){
                    ili.Department__c = pricingItemMap.get(ili.SR_Price_Item__c).Department__c;
                    ili.Service_Type__c = pricingItemMap.get(ili.SR_Price_Item__c).Service_Type__c;
                    ili.Service_Class__c = pricingItemMap.get(ili.SR_Price_Item__c).Service_Class__c;
                    ili.Revenue_Type__c = pricingItemMap.get(ili.SR_Price_Item__c).Revenue_Type__c;
                }
            }
        }
    }
    
    //delete line 
    public static void deleteDiscountLine(list<Id> listLineItemID){
        List<Invoice_Line_Item__c> listDiscountToDetele = new List<Invoice_Line_Item__c>();
        listDiscountToDetele = [select id from Invoice_Line_Item__c where Invoice_Line_Item__c IN:listLineItemID and Is_Discount__c=true];
        if(listDiscountToDetele <> null && listDiscountToDetele.size() > 0) {
            delete listDiscountToDetele;
        }
        
    }
    
    // Call this function after insert 
    public static void createDiscount (map<Id, Invoice_Line_Item__c> mapInvoiceLineItem) {
        Map<Id, Invoice_Line_Item__c> mapOldInvoicelineItem = new Map<Id, Invoice_Line_Item__c>();
        for(Invoice_Line_Item__c objInvoice_Line_Item : [select id, Amount__c,Tax__c, Invoice_Line_Item__c from Invoice_Line_Item__c where Is_Discount__c = true and Invoice_Line_Item__c IN:mapInvoiceLineItem.keySet()]) {
           mapOldInvoicelineItem.put(objInvoice_Line_Item.Invoice_Line_Item__c, objInvoice_Line_Item);
        }
        
        List<Invoice_Line_Item__c> listItemToUpsert = new List<Invoice_Line_Item__c>();       
        for(Invoice_Line_Item__c objInvoice_Line_Item : mapInvoiceLineItem.values()) {
            Invoice_Line_Item__c newlineItem = new Invoice_Line_Item__c();
            
            if(mapOldInvoicelineItem <> null && mapOldInvoicelineItem.get(objInvoice_Line_Item.id) <> null) {
                newlineItem = mapOldInvoicelineItem.get(objInvoice_Line_Item.id);
                newlineItem.Amount__c = objInvoice_Line_Item.Discount_Amount__c * -1;
                //newlineItem.Tax__c = '0%';
                newlineItem.Is_Discount__c = true;
                newlineItem.Quantity__c = 1;
            } else {
                newlineItem = objInvoice_Line_Item.clone();
                newlineItem.Amount__c = objInvoice_Line_Item.Discount_Amount__c * -1;
                //newlineItem.Tax__c = '0%';
                newlineItem.Is_Discount__c = true;
                //newlineItem.Service_Type__c = 'Discount-' + objInvoice_Line_Item.Service_Type__c;
                newlineItem.Revenue_Type__c = 'Discount-' + objInvoice_Line_Item.Revenue_Type__c;
                newlineItem.Quantity__c = 1;
            }
            newlineItem.Invoice_Line_Item__c = objInvoice_Line_Item.id;
            newlineItem.Discount_Amount__c = 0;
            //newlineItem.Item_Description__c = objInvoice_Line_Item.Discount_Description__c;
            newlineItem.Line_Description__c = objInvoice_Line_Item.Discount_Description__c;
            if(newlineItem.Tax__c == '5%'){
                newlineItem.Tax_Amount__c = (newlineItem.Amount__c * 5)/100;
            }
            
            listItemToUpsert.add(newlineItem);
        }
        
        //upsert line item for discount
        if(listItemToUpsert <> null && listItemToUpsert.size() > 0) {
            upsert listItemToUpsert;
        }        
    }
    public static void validateInvoiceLineBeforeInsert(list<Invoice_Line_Item__c> TriggerNew){
        List<Id> invoiceIds = new List<Id>();
        for(Invoice_Line_Item__c eachLine : TriggerNew){
            invoiceIds.add(eachLine.Invoice__c);
        }
        Id recTypeId = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Adjustment').getRecordTypeId();
        Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>([SELECT Id, Oracle_Invoice_Id__c FROM Invoice__c WHERE Id IN : invoiceIds]);
        
        for(Invoice_Line_Item__c eachLine : TriggerNew){
            if(eachLine.recordtypeid == recTypeId && invoiceMap <> null && invoiceMap.get(eachLine.id) <> null && invoiceMap.get(eachLine.id).Oracle_Invoice_Id__c == null){
                eachLine.addError('Adjustment can not be created as Invoice Oracle id is not present');
            }
        }
    }
    
    public static void chnageAmountValueofAdjustment(list<Invoice_Line_Item__c> TriggerNew){
        Set<String> activityTypes = new Set<String>{'Bank Charges','Invoice Cancellation - Tax','Invoice Cancellation','Rounding Off','Others','Fee Waiver'};
        Id adjLineRecTypeId = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Adjustment').getRecordTypeId();
        for(Invoice_Line_Item__c eachLine : TriggerNew){
            if(eachLine.RecordTypeId == adjLineRecTypeId && activityTypes.contains(eachLine.Activity_Name__c)){
                if(eachLine.Amount__c > 0){
                    eachLine.Amount__c = eachLine.Amount__c * -1;                    
                }
            }   
        }
        
        // ------- Populate Amount and Tax amount if the Activity type is Invoice Cancellation and Tax is there ---------
        Set<Id> invoiceIds = new Set<Id>();
        for(Invoice_Line_Item__c eachLine : TriggerNew){
            if(eachLine.RecordTypeId == adjLineRecTypeId && eachLine.Activity_Name__c == 'Invoice Cancellation' && eachLine.Tax__c == '5%'){
                if(eachLine.Amount__c == null){
                    invoiceIds.add(eachLine.Invoice__c);
                }
            }   
        }  
        
        if(invoiceIds.size() > 0){
            Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>([select Id,(SELECT Id,Amount__c,Tax_Amount__c FROM Invoice_Line_Items__r WHERE recordtype.name != 'Adjustment' AND Is_CM_Application__c = false) FROM Invoice__c where Id IN : invoiceIds]);
            for(Invoice_Line_Item__c eachLine : TriggerNew){
                if(eachLine.RecordTypeId == adjLineRecTypeId && eachLine.Activity_Name__c == 'Invoice Cancellation' && eachLine.Tax__c == '5%'){
                    if(eachLine.Amount__c == null){
                        if(invoiceMap.containsKey(eachLine.Invoice__c)){
                            Decimal totAmount = 0;
                            Decimal totTaxAmount = 0;
                            for(Invoice_Line_Item__c ili : invoiceMap.get(eachLine.Invoice__c).Invoice_Line_Items__r){
                                totAmount += ili.Amount__c;
                                totTaxAmount += ili.Tax_Amount__c;
                            }
                            eachLine.Amount__c = totAmount * -1;
                            eachLine.Tax_Amount__c = totTaxAmount * -1;
                        }
                    }
                }   
            }  
        }
        //--------------------------------------------------------
    }
    
    //---------------------------------Populate Revenue Type field--------------------------------------------
    
    public static void populateRevenueTypeField(list<Invoice_Line_Item__c> TriggerNew, map<Id,Invoice_Line_Item__c> TriggerOldMap){
        Id cmLineRecTypeId = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Credit_Memo_Line').getRecordTypeId();
        Id invLineRecTypeId = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Invoice_Line_Item').getRecordTypeId();
        Set<Id> invoiceIdSet = new Set<Id>(); 
        Set<String> serviceTypes = new Set<String>();
        Set<String> lineItemTypes = new Set<String>();
        Set<String> invoiceTypes = new Set<String>(); 
        for(Invoice_Line_Item__c ili : TriggerNew){
            if(ili.recordtypeid == cmLineRecTypeId || ili.recordtypeid == invLineRecTypeId){
                invoiceIdSet.add(ili.Invoice__c);
                serviceTypes.add(ili.Service_Type__c);
                lineItemTypes.add(ili.Item_Description__c);
            }
        }
        
        Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>([SELECT Id,Oracle_Invoice_Type__c From Invoice__c WHERE Id IN : invoiceIdSet]);
        for(Invoice__c eachInv : invoiceMap.values()){
            invoiceTypes.add(eachInv.Oracle_Invoice_Type__c);
        }
        
        //Populate Service Type as None if OU is not RA
        for(Invoice_Line_Item__c ili : TriggerNew){
            if(ili.recordtypeid == cmLineRecTypeId || ili.recordtypeid == invLineRecTypeId){
                if(invoiceMap.containskey(ili.Invoice__c)){
                    if(invoiceMap.get(ili.Invoice__c).Oracle_Invoice_Type__c != 'RA Invoice' && invoiceMap.get(ili.Invoice__c).Oracle_Invoice_Type__c != 'RA CM'){
                        ili.Service_Class__c = 'None';
                    }
                }
                
                if(ili.Item_Description__c == null){
                    ili.Item_Description__c = 'None';
                }
            }
        }
        
       // AND Line_Item_Type__c IN: lineItemTypes
        List<Revenue_Classification__c> revenueClassificationList = [SELECT Id,Service_Type__c,Revenue_Type__c,Line_Item_Type__c,Operating_Unit__r.Invoice_Type__c,Operating_Unit__r.Credit_Memo_Type__c FROM Revenue_Classification__c WHERE 
        Service_Type__c IN : serviceTypes  AND (Operating_Unit__r.Invoice_Type__c IN : invoiceTypes OR Operating_Unit__r.Credit_Memo_Type__c IN : invoiceTypes)];
        
        //Map<eachRC.Operating_Unit__r.Invoice_Type__c,Map<eachRC.Service_Type__c,eachRC.Revenue_Type__c>>
        //OLd Master Map --- >Map<String,Map<String,Map<String,String>>> masterMap = new Map<String,Map<String,Map<String,String>>>();
        Map<String,Map<String,String>> masterMap = new Map<String,Map<String,String>>();
        
        for(Revenue_Classification__c eachRC : revenueClassificationList){
            if(eachRC.Operating_Unit__r.Invoice_Type__c != null){
                if(masterMap.containskey(eachRC.Operating_Unit__r.Invoice_Type__c)){
                    if(! masterMap.get(eachRC.Operating_Unit__r.Invoice_Type__c).containskey(eachRC.Service_Type__c)){
                        /*if(! masterMap.get(eachRC.Operating_Unit__r.Invoice_Type__c).get(eachRC.Service_Type__c).containskey(eachRC.Line_Item_Type__c)){
                            masterMap.get(eachRC.Operating_Unit__r.Invoice_Type__c).get(eachRC.Service_Type__c).put(eachRC.Line_Item_Type__c, eachRC.Revenue_Type__c);
                        }*/
                        masterMap.get(eachRC.Operating_Unit__r.Invoice_Type__c).put(eachRC.Service_Type__c, eachRC.Revenue_Type__c);
                    } /*else {
                        Map<String,String> aMap = new Map<String,String>{eachRC.Line_Item_Type__c => eachRC.Revenue_Type__c};
                        masterMap.get(eachRC.Operating_Unit__r.Invoice_Type__c).put(eachRC.Service_Type__c, aMap);
                    }*/
                } else {
                    Map<String,String> aMap = new Map<String,String>{eachRC.Service_Type__c => eachRC.Revenue_Type__c};
                    //Map<String,Map<String,String>> bMap = new Map<String,Map<String,String>>{eachRC.Service_Type__c => aMap};
                    masterMap.put(eachRC.Operating_Unit__r.Invoice_Type__c, aMap);
                }
            }
            
            if(eachRC.Operating_Unit__r.Credit_Memo_Type__c != null){
                if(masterMap.containskey(eachRC.Operating_Unit__r.Credit_Memo_Type__c)){
                    if(! masterMap.get(eachRC.Operating_Unit__r.Credit_Memo_Type__c).containskey(eachRC.Service_Type__c)){
                        /*if(! masterMap.get(eachRC.Operating_Unit__r.Credit_Memo_Type__c).get(eachRC.Service_Type__c).containskey(eachRC.Line_Item_Type__c)){
                            masterMap.get(eachRC.Operating_Unit__r.Credit_Memo_Type__c).get(eachRC.Service_Type__c).put(eachRC.Line_Item_Type__c, eachRC.Revenue_Type__c);
                        }*/
                        masterMap.get(eachRC.Operating_Unit__r.Credit_Memo_Type__c).put(eachRC.Service_Type__c, eachRC.Revenue_Type__c);
                    } /*else {
                        Map<String,String> aMap = new Map<String,String>{eachRC.Line_Item_Type__c => eachRC.Revenue_Type__c};
                        masterMap.get(eachRC.Operating_Unit__r.Credit_Memo_Type__c).put(eachRC.Service_Type__c, aMap);
                    }*/
                } else {
                    Map<String,String> aMap = new Map<String,String>{eachRC.Line_Item_Type__c => eachRC.Revenue_Type__c};
                   // Map<String,Map<String,String>> bMap = new Map<String,Map<String,String>>{eachRC.Service_Type__c => aMap};
                    masterMap.put(eachRC.Operating_Unit__r.Credit_Memo_Type__c, aMap);
                }
            }
        }
        
        for(Invoice_Line_Item__c ili : TriggerNew){
            if(ili.Invoice__c!=null && ili.Service_Type__c!=null){//Null checks added by durga to avoid attempt to de-reference null object error
                if((ili.recordtypeid == cmLineRecTypeId || ili.recordtypeid == invLineRecTypeId) && ili.Revenue_Type__c == null){
                    if(invoiceMap.containskey(ili.Invoice__c)){
                        if(masterMap.containskey(invoiceMap.get(ili.Invoice__c).Oracle_Invoice_Type__c)){
                            if(masterMap.get(invoiceMap.get(ili.Invoice__c).Oracle_Invoice_Type__c).containskey(ili.Service_Type__c)){
                                ili.Revenue_Type__c = masterMap.get(invoiceMap.get(ili.Invoice__c).Oracle_Invoice_Type__c).get(ili.Service_Type__c);
                            }
                        }
                    }
                }
            }
        }
    }
    
    //----------------------- Send Notification if Revenue Type or Service Type not found ----------------------
    
/*    public static void sendEmailNotificaionIfRevenueNotFound(list<Invoice_Line_Item__c> TriggerNew){
        Set<String> selectedServiceTypes = new Set<String>();
        Set<String> selectedRevenueTypes = new Set<String>();
        Set<Id> invoiceIds = new Set<Id>();
        for(Invoice_Line_Item__c ili : TriggerNew){
            selectedServiceTypes.add(ili.Service_Type__c);
            selectedRevenueTypes.add(ili.Revenue_Type__c);
            invoiceIds.add(ili.Invoice__c);
        }
        Set<Id> ouIds = new Set<Id>();
        for(Invoice__c inv : [Select id,Entity__r.Operating_Unit__c from Invoice__c where Id in : invoiceIds]){
            ouIds.add(inv.Entity__r.Operating_Unit__c);
        }
        
        List<Revenue_Classification__c> revenueClasses = [Select id,Service_Type__c,Revenue_Type__c from Revenue_Classification__c];
    } */
}