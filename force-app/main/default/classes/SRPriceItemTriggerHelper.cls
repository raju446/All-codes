/*
    Author      : Yogesh Mahajan
    Date        : 01-Aug-2019
    Description : Trigger helper class that is being referenced in the SRPriceItemTriggerHelper.
                  All DML methods are being handled in this handler class.
    --------------------------------------------------------------------------------------
*/
public without sharing class SRPriceItemTriggerHelper {
    /*
        Method Name :   linkInvoiceToSRPriceIteam
        Description :   Method to link price item to invoice and add amount in it.
    */
    public static void linkInvoiceToSRPriceIteam (list<HexaBPM__SR_Price_Item__c> srPriceItemList, Boolean isUpdate) {
        Set<Id> setSRID = new Set<ID>();       
        
        try {
            for(HexaBPM__SR_Price_Item__c objPriceItem : srPriceItemList) {
                setSRID.add(objPriceItem.HexaBPM__ServiceRequest__c);
            }
            
            Map<Id, HexaBPM__Service_Request__c> mapSRValues = new Map<Id, HexaBPM__Service_Request__c> ([select id, RecordType.Name, HexaBPM__SR_Template__r.Invoice_Transaction_Type__c from HexaBPM__Service_Request__c where id IN: setSRID]);
            //mapSRValues = ;
            
            Map<Id, Invoice__c> mapOfSRIdWithInvoice = new Map<Id, Invoice__c>();
            for(Invoice__c objInvoice : [SELECT ID, Service_Request__c, Markup_Amount__c, Tax_Amount__c, Cost__c, Entity__c
                                         FROM Invoice__c 
                                         WHERE Service_Request__c IN : setSRID]) {
                mapOfSRIdWithInvoice.put(objInvoice.Service_Request__c, objInvoice);
            }
            system.debug('mapOfSRIdWithInvoice---->'+mapOfSRIdWithInvoice);        
            Invoice__c objInvoice;

            Map<Id, Invoice__c> mapOfSRIDWithNewInvoice = new Map<Id, Invoice__c>();
            for(HexaBPM__SR_Price_Item__c objPriceItem : srPriceItemList) {
                if(mapOfSRIdWithInvoice <> null && mapOfSRIdWithInvoice.get(objPriceItem.HexaBPM__ServiceRequest__c) == null) {
                    objInvoice = new Invoice__c();
                    objInvoice.Entity__c = objPriceItem.Entity__c;
                    objInvoice.Oracle_Invoice_Type__c = objPriceItem.Invoice_Type1__c;
                    objInvoice.Service_Request__c = objPriceItem.HexaBPM__ServiceRequest__c;
                    objInvoice.Payment_Currency__c = 'AED';
                    if(mapSRValues <> null && mapSRValues.get(objPriceItem.HexaBPM__ServiceRequest__c) <> null && mapSRValues.get(objPriceItem.HexaBPM__ServiceRequest__c).RecordTypeId <> null ) {
                        objInvoice.Description__c = (mapSRValues.get(objPriceItem.HexaBPM__ServiceRequest__c)).RecordType.Name;
                        if(mapSRValues.get(objPriceItem.HexaBPM__ServiceRequest__c).HexaBPM__SR_Template__c <> null )
                            objInvoice.Oracle_Invoice_Type__c = (mapSRValues.get(objPriceItem.HexaBPM__ServiceRequest__c)).HexaBPM__SR_Template__r.Invoice_Transaction_Type__c;
                        
                    }
                    objInvoice.Invoice_Class__c = 'Invoice';
                    objInvoice.Payment_Term__c = 'Immediate';//'IMMEDIATE';
                    objInvoice.Transaction_Type__c = 'WALLET';
                    objInvoice.Invoice_Date__c = Date.today();
                    objInvoice.GL_Date__c = Date.today();
                    //objInvoice.OwnerId = Label.Data_Flow_Integration_User;
                    mapOfSRIDWithNewInvoice.put(objPriceItem.HexaBPM__ServiceRequest__c, objInvoice);
                }
            }
           
            system.debug('mapOfSRIDWithNewInvoice---->'+mapOfSRIDWithNewInvoice);          
            if(mapOfSRIDWithNewInvoice <> null && mapOfSRIDWithNewInvoice.values().size() > 0) {
                Insert mapOfSRIDWithNewInvoice.values();       
            }
        } catch (exception ex) {
            system.debug('Exception------------>'+ex.getMessage());
        }
        
    }
    
    
    
    /**
    * @description Populte Revenue Mapping on SR Price item from Metadata
    * @author Jayanta Karmakar | 6/20/2020 
    * @param list<HexaBPM__SR_Price_Item__c> newList 
    * @return void 
    **/
    public static void populateRevenueMapping(list<HexaBPM__SR_Price_Item__c> newList){
        List<String> templateNames = new List<String>();
        for(HexaBPM__SR_Price_Item__c eachLine : newList){
            templateNames.add(eachLine.Template__c);
        }
        
        Map<String,Access_Adgm_Revenue_Mapping__mdt> metaDataMap = new Map<String,Access_Adgm_Revenue_Mapping__mdt>();
        for(Access_Adgm_Revenue_Mapping__mdt eachItem : [Select id,Template__c,Pricing_Line__c,Department__c,Invoice_Type__c,Item_Type__c,Revenue_Type__c,Service_Class__c,Service_Type__c from Access_Adgm_Revenue_Mapping__mdt WHERE Template__c IN : templateNames]){
            String keyStr = eachItem.Template__c +'-'+ eachItem.Pricing_Line__c;
            metaDataMap.put(keyStr,eachItem);
        }
        
        for(HexaBPM__SR_Price_Item__c eachLine : newList){
            String mapKey = eachLine.Template__c +'-'+ eachLine.SR_Price_Line_Name__c;
            system.debug(eachLine.Template__c);
            system.debug(eachLine.SR_Price_Line_Name__c);
            system.debug(mapKey);
            system.debug(metaDataMap.containskey(mapKey));
            if(metaDataMap.containskey(mapKey)){
                eachLine.Department__c = metaDataMap.get(mapKey).Department__c;
                eachLine.Invoice_Type1__c = metaDataMap.get(mapKey).Invoice_Type__c;
                eachLine.Item_Type1__c = metaDataMap.get(mapKey).Item_Type__c;
                eachLine.Revenue_Type__c = metaDataMap.get(mapKey).Revenue_Type__c;
                eachLine.Service_Class__c = metaDataMap.get(mapKey).Service_Class__c;
                eachLine.Service_Type__c = metaDataMap.get(mapKey).Service_Type__c;
            }
        }
    }
    
    /*
        Method Name :   createInvoiceLineItem
        Description :   Method to create invoice line item
    
    public static void createInvoiceLineItem (list<HexaBPM__SR_Price_Item__c> srPriceItemList, Boolean isUpdate) {
        Map<String,Id> mapofSRPRecordTypeNameandId = new Map<String,Id>();
        mapofSRPRecordTypeNameandId = ApexCodeUtility.getRecTypeDetails('Invoice_Line_Item__c');
        
        system.debug('createInvoiceLineItem----');
        // get Sr with invoice id
        Set<Id> setSRID = new Set<ID>();
        Set<Id> setSRPIds = new Set<Id>();
        for(HexaBPM__SR_Price_Item__c objPriceItem : srPriceItemList) {
            setSRID.add(objPriceItem.HexaBPM__ServiceRequest__c);
            setSRPIds.add(objPriceItem.Id);
        }
        // old SRP of SR
        if(setSRID <> null && setSRID.size() > 0) {
            Map<Id, HexaBPM__SR_Price_Item__c> mapOfSRP = new Map<Id, HexaBPM__SR_Price_Item__c>([SELECT ID FROM HexaBPM__SR_Price_Item__c WHERE HexaBPM__ServiceRequest__c =:setSRID AND ID NOT IN:setSRPIds]);
            if(mapOfSRP <> null && mapOfSRP.values().size() > 0 )
                setSRPIds.addAll(mapOfSRP.KeySet());
        }
        
        
        List<HexaBPM__SR_Price_Item__c> listSRPriceItem = new List<HexaBPM__SR_Price_Item__c>();
        listSRPriceItem = [SELECT Markup_Amount__c, Cost__c, Tax_Amount__c, HexaBPM__Price__c, Discount__c, HexaBPM__Pricing_Line__r.Name, id, HexaBPM__ServiceRequest__c, Name, HexaBPM__Status__c
                           FROM HexaBPM__SR_Price_Item__c 
                           WHERE id IN:setSRPIds ];
            
        Map<Id, Invoice__c> mapOfSRIdWithInvoice = new Map<Id, Invoice__c>();
        for(Invoice__c objInvoice : [SELECT ID, Service_Request__c, Markup_Amount__c, Tax_Amount__c, Cost__c, Entity__c
                                     FROM Invoice__c 
                                     WHERE Service_Request__c IN : setSRID]) {
                                         mapOfSRIdWithInvoice.put(objInvoice.Service_Request__c, objInvoice);
        }
        
        Map<Id, Invoice_Line_Item__c> mapOfSRPIdWithInvoiceLineItm = new Map<Id, Invoice_Line_Item__c>();
        //Map<Id, List<Invoice_Line_Item__c>> mapOfSRPIdWithInvoiceLineItm1 = new Map<Id, List<Invoice_Line_Item__c>>();
        for(Invoice_Line_Item__c objInvoiceLineItem : [SELECT ID, Amount__c, Discount_Amount__c, Invoice__c, SR_Price_Item__c
                                     FROM Invoice_Line_Item__c 
                                     WHERE SR_Price_Item__c IN : setSRPIds]) {
                                         mapOfSRPIdWithInvoiceLineItm.put(objInvoiceLineItem.SR_Price_Item__c, objInvoiceLineItem);
                                         //List<Invoice_Line_Item__c> listTLI = new List<Invoice_Line_Item__c>();
                                         //if(mapOfSRPIdWithInvoiceLineItm1 <> null && mapOfSRPIdWithInvoiceLineItm1.get(objInvoiceLineItem.SR_Price_Item__c) <> null) {
                                            // listTLI = mapOfSRPIdWithInvoiceLineItm1.get(objInvoiceLineItem.SR_Price_Item__c);
                                        // }
                                         //listTLI.add(objInvoiceLineItem);
                                         //mapOfSRPIdWithInvoiceLineItm1.put(objInvoiceLineItem.SR_Price_Item__c, listTLI);
                                             
        }
        
        List<Invoice_Line_Item__c> listInvoiceLineItem = new List<Invoice_Line_Item__c>();
        for(HexaBPM__SR_Price_Item__c objPriceItem : listSRPriceItem) {
            Id invoiceLineId, invoiceId ;
            // related invoice id
            if(mapOfSRIdWithInvoice <> null && mapOfSRIdWithInvoice.size() > 0 && mapOfSRIdWithInvoice.get(objPriceItem.HexaBPM__ServiceRequest__c) <> null)
                invoiceId = mapOfSRIdWithInvoice.get(objPriceItem.HexaBPM__ServiceRequest__c).id;
            else 
                invoiceId = null;
            if(invoiceId <> null) {
                // related invoice line item id
                if(mapOfSRPIdWithInvoiceLineItm <> null && mapOfSRPIdWithInvoiceLineItm.size() > 0 && mapOfSRPIdWithInvoiceLineItm.get(objPriceItem.id) <> null)
                    invoiceLineId = mapOfSRPIdWithInvoiceLineItm.get(objPriceItem.id).id;
                else 
                    invoiceLineId = null;
                
                Decimal cost =0, markup = 0;
                if(objPriceItem.Cost__c <> null ) {
                    cost = objPriceItem.Cost__c;
                }
                if(objPriceItem.Markup_Amount__c <> null ) {
                    markup = objPriceItem.Markup_Amount__c;
                }
                Decimal dAmountVal = 0;
                dAmountVal = cost + markup;
                listInvoiceLineItem.add(mapInvoiceLineItem(invoiceLineId, dAmountVal, objPriceItem.Discount__c, mapOfSRIdWithInvoice.get(objPriceItem.HexaBPM__ServiceRequest__c).id, 
                                                           objPriceItem.HexaBPM__Pricing_Line__r.Name, objPriceItem.Name, objPriceItem.id, objPriceItem.Tax_Amount__c, 0.0, objPriceItem.HexaBPM__Status__c, isUpdate, mapofSRPRecordTypeNameandId.get('Invoice Line Item'),cost, markup));                
                
                
                
               
            }
            
        }
        
        
        List<Invoice_Line_Item__c> listInvoiceLineItemdel = new List<Invoice_Line_Item__c>();
        listInvoiceLineItemdel = [SELECT ID
                                     FROM Invoice_Line_Item__c  
                                     WHERE Invoice__r.Service_Request__c IN : setSRID AND SR_Price_Item__c = null];
        
        if(listInvoiceLineItemdel <> null && listInvoiceLineItemdel.size() > 0){
            delete listInvoiceLineItemdel;
        }    
        // upsert the line item
        if(listInvoiceLineItem <> null && listInvoiceLineItem.size() > 0) {
           // upsert listInvoiceLineItem;
        }
    }
    
    */
    
    /*
        Method Name :   mapInvoiceLineItem
        Description :   Method to map invoice line item values
    
    public static Invoice_Line_Item__c mapInvoiceLineItem (Id invoiceLineId,Decimal dAmount, Decimal dDiscountAmount, String sInvoiceId, String itemDescription, String itemReference, Id sSRPriceItemId, Decimal dTaxAmount, Decimal dTaxableDiscountAmount, String sStatus, Boolean isUpdate, Id recTypeId, Decimal costVal, Decimal markVal) {
        Invoice_Line_Item__c objInvoiceLineItem = new Invoice_Line_Item__c();
        if(invoiceLineId <> null) {
            objInvoiceLineItem.id = invoiceLineId;
        }
        objInvoiceLineItem.RecordTypeId = recTypeId;
        objInvoiceLineItem.Amount__c = dAmount;
        objInvoiceLineItem.Discount_Amount__c = dDiscountAmount;
        //if(!isUpdate){
            objInvoiceLineItem.Invoice__c = sInvoiceId;    
        //}
        
        objInvoiceLineItem.Item_Description__c = itemDescription;
        objInvoiceLineItem.Item_Reference__c = itemReference;
        objInvoiceLineItem.SR_Price_Item__c = sSRPriceItemId;
        objInvoiceLineItem.Taxable_Discount_Amount__c = dTaxableDiscountAmount;
        objInvoiceLineItem.Tax_Amount__c = dTaxAmount;
        objInvoiceLineItem.Status__c = sStatus;
        objInvoiceLineItem.Markup_Amount__c = markVal;
        objInvoiceLineItem.Cost__c = costVal;
        return objInvoiceLineItem;
    }
        */
}