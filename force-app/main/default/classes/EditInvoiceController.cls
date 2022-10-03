/**
 * @File Name          : EditInvoiceController.cls
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 4/21/2020, 4:25:22 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    4/4/2020   Jayanta Karmakar     Initial Version
**/
public without sharing class EditInvoiceController {
     @AuraEnabled
    public static CreditMemoAppliedDetails fetchInvoiceDetails(String invoiceId){
        CreditMemoAppliedDetails objCreditMemoAppliedDetails = new CreditMemoAppliedDetails();
        objCreditMemoAppliedDetails.objInvoice = [select id,name,Entity__c,Payment_Currency__c,Oracle_Invoice_Id__c,Source_Invoice_Id__c, Invoice_Balance__c,Total_Taxable_Amount__c from Invoice__c where Id =: invoiceId];
        List<RelatedInvRecClass> listRelatedInv = new List<RelatedInvRecClass>();
        for(Invoice_Line_Item__c objInvoice_Line_Item : [select id,Invoice__c,GL_Date__c,Invoice__r.Name, Invoice__r.Source_Invoice_Id__c, Invoice__r.GL_Date__c,Amount__c,Invoice__r.Invoice_Balance__c,Invoice__r.In_Progress_Amount__c,Invoice__r.Oracle_Invoice_Id__c,Status__c,Invoice__r.Total_Taxable_Amount__c from Invoice_Line_Item__c where Related_Credit_Memo__c =: invoiceId AND Applied__c = TRUE]) {
            RelatedInvRecClass objRelatedInv = new RelatedInvRecClass();
            objRelatedInv.invoiceNo = objInvoice_Line_Item.Invoice__r.Source_Invoice_Id__c;//objInvoice_Line_Item.Invoice__r.Oracle_Invoice_Id__c ;
            objRelatedInv.invoiceId = objInvoice_Line_Item.Invoice__c;
            objRelatedInv.Amount = objInvoice_Line_Item.Amount__c;
            objRelatedInv.invoiceBalAmt = (objInvoice_Line_Item.Invoice__r.Invoice_Balance__c - objInvoice_Line_Item.Invoice__r.In_Progress_Amount__c) ;
            objRelatedInv.lineItemId = objInvoice_Line_Item.id;
            objRelatedInv.LineItem = objInvoice_Line_Item;
            objRelatedInv.lineItemGLDate = objInvoice_Line_Item.GL_Date__c;
            if(objInvoice_Line_Item.Invoice__r.GL_Date__c != null){ DateTime dt = objInvoice_Line_Item.Invoice__r.GL_Date__c; objRelatedInv.invoiceGLDate = date.newinstance(dT.year(), dT.month(), dT.day());    }
            if(objInvoice_Line_Item.Invoice__r.Total_Taxable_Amount__c != 0){ objRelatedInv.invTaxAmount = (objRelatedInv.invoiceBalAmt*((decimal)Constants.TAX_PERCENT/100));}
            else{ objRelatedInv.invTaxAmount = 0; }
            listRelatedInv.add(objRelatedInv);
        }
        objCreditMemoAppliedDetails.listRelatedInvRecClass = listRelatedInv;
        system.debug('objCreditMemoAppliedDetails----'+objCreditMemoAppliedDetails);
        return objCreditMemoAppliedDetails;
    }
    
    @AuraEnabled
    public static String upsertInvoice(Invoice__c objInvoice, String listRelatedInvRecClass){
        /*Map<String,Id> mapofInvoicelineRecordTypeNameandId = new Map<String,Id>();
        mapofInvoicelineRecordTypeNameandId = ApexCodeUtility.getRecTypeDetails('Invoice_Line_Item__c');
        system.debug('invoiceId'+listRelatedInvRecClass);
        List<RelatedInvRecClass> relatedList = new List<RelatedInvRecClass>();
        relatedList = (List<RelatedInvRecClass>)JSON.deserialize(listRelatedInvRecClass, List<RelatedInvRecClass>.class);
        List<Invoice_Line_Item__c> listInvoice_Line_Item = new List<Invoice_Line_Item__c>();

        if(relatedList <> null && relatedList.size() > 0) {
            for(RelatedInvRecClass objRelatedInvRecClass : relatedList) {
                Invoice_Line_Item__c objInvoice_Line_Item = new Invoice_Line_Item__c() ;
                if(objRelatedInvRecClass.lineItemId <> null && objRelatedInvRecClass.lineItemId <> '')
                    objInvoice_Line_Item.id = objRelatedInvRecClass.lineItemId;
                if(mapofInvoicelineRecordTypeNameandId <> null && mapofInvoicelineRecordTypeNameandId.get('Credit Memo Line') <> null) {
                    objInvoice_Line_Item.RecordTypeId =  mapofInvoicelineRecordTypeNameandId.get('Credit Memo Line');
                }
                objInvoice_Line_Item.Related_Credit_Memo__c = objInvoice.id;
                objInvoice_Line_Item.Invoice__c = objRelatedInvRecClass.invoiceId;
                objInvoice_Line_Item.Amount__c = objRelatedInvRecClass.Amount != null ? objRelatedInvRecClass.Amount*-1 : 0;
                if(objInvoice_Line_Item.GL_Date__c != null){
                	objInvoice_Line_Item.GL_Date__c = objRelatedInvRecClass.lineItemGLDate;    
                }
                
                if(objRelatedInvRecClass.LineItem != null && objRelatedInvRecClass.LineItem.Status__c == 'Invoiced'){
                    continue;
                }
                
                if(objRelatedInvRecClass.invTaxAmount != null && objRelatedInvRecClass.invTaxAmount != 0){
                    objInvoice_Line_Item.Tax__c = Constants.TaxCode;
                    objInvoice_Line_Item.Tax_Amount__c = (objRelatedInvRecClass.Amount*((decimal)Constants.TAX_PERCENT/100));
                }
                //Update tax code to 0. 1 Jun 2021
                if(String.isBlank(objInvoice_Line_Item.Tax__c)){
                    objInvoice_Line_Item.Tax__c = Label.CATALYST_Tax_Code;
                }
                listInvoice_Line_Item.add(objInvoice_Line_Item);
            }
        }

        try {
            system.debug('---->'+listInvoice_Line_Item);
            List<Id> liList = new List<Id>();
            if(listInvoice_Line_Item <> null && listInvoice_Line_Item.size() > 0) {
                upsert listInvoice_Line_Item;
                system.debug('---->'+listInvoice_Line_Item);
                for(Invoice_Line_Item__c il : listInvoice_Line_Item){
                    liList.add(il.Id);
                }
            }
            //Added for JE Entries creation
            if(liList.size()>0){BM_JournalEntryEngine.creditMemoApplicationJournalLines(liList);}
                
        }catch(exception ex){
            return ex.getMessage();            
        }*/
        
        try{
            Map<String,Id> mapofInvoicelineRecordTypeNameandId = new Map<String,Id>();
        	mapofInvoicelineRecordTypeNameandId = ApexCodeUtility.getRecTypeDetails('Invoice_Line_Item__c');
            
            List<RelatedInvRecClass> updatedApplications = new List<RelatedInvRecClass>();
        	updatedApplications = (List<RelatedInvRecClass>)JSON.deserialize(listRelatedInvRecClass, List<RelatedInvRecClass>.class);
            
            Map<Id, Invoice_Line_Item__c> existingApplicationsMap = new Map<Id, Invoice_Line_Item__c>();
            for(Invoice_Line_Item__c invApplication : [select id,Invoice__c,GL_Date__c,Invoice__r.Name, Invoice__r.GL_Date__c,Amount__c,Invoice__r.Invoice_Balance__c,
                                                       Invoice__r.In_Progress_Amount__c,Invoice__r.Oracle_Invoice_Id__c,Status__c,Invoice__r.Total_Taxable_Amount__c 
                                                       from Invoice_Line_Item__c 
                                                       where Related_Credit_Memo__c =: objInvoice.Id AND Applied__c = TRUE])
            {
            	existingApplicationsMap.put(invApplication.Invoice__c, invApplication);
            }
            Set<Id> invoiceIds = new Set<Id>();
            Map<Id,Invoice_Line_Item__c> newInvoiceApplicationMap = new Map<Id,Invoice_Line_Item__c>();
            Map<Id, RelatedInvRecClass> updatedApplicationsMap = new Map<Id, RelatedInvRecClass>();
            for(RelatedInvRecClass eachObj : updatedApplications){
                invoiceIds.add(eachObj.invoiceId);
                updatedApplicationsMap.put(eachObj.invoiceId, eachObj);
                if(!existingApplicationsMap.containskey(eachObj.invoiceId)){
                    if(eachObj.LineItem != null && eachObj.LineItem.Status__c == 'Invoiced'){continue;}
    				Invoice_Line_Item__c objInvoice_Line_Item = addNewInvoiceLineItem(eachObj,mapofInvoicelineRecordTypeNameandId,objInvoice);
                    newInvoiceApplicationMap.put(eachObj.invoiceId, objInvoice_Line_Item);
                }
            }
            
            Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>([SELECT id,Invoice_Balance__c from Invoice__c WHERE Id IN : existingApplicationsMap.keySet()]);
            Decimal applicationAmount = 0;
            
            List<Invoice_Line_Item__c> unappliedCreditNote = new List<Invoice_Line_Item__c>();
            List<Invoice__c> invoiceToUpdate = new List<Invoice__c>();
            for(Id eachInvoiceId : existingApplicationsMap.keySet()){
                if(!invoiceIds.contains(eachInvoiceId)){
                    Invoice_Line_Item__c tempApp = existingApplicationsMap.get(eachInvoiceId);
                    tempApp.Applied__c = false;
                    unappliedCreditNote.add(tempApp);
                    invoiceToUpdate.add(new Invoice__c(Id=eachInvoiceId,Invoice_Balance__c = invoiceMap.get(eachInvoiceId).Invoice_Balance__c + (existingApplicationsMap.get(eachInvoiceId).Amount__c * -1)));
                    applicationAmount = applicationAmount + existingApplicationsMap.get(eachInvoiceId).Amount__c;
                }
            }
            
            if(newInvoiceApplicationMap != null && newInvoiceApplicationMap.values().size() > 0){
                List<Id> newAppId = new List<Id>();
                INSERT newInvoiceApplicationMap.values();
                Map<Id, Invoice_Line_Item__c> invoiceAmountAppliedMap = new Map<Id, Invoice_Line_Item__c>();
                for(Invoice_Line_Item__c appliObj : newInvoiceApplicationMap.values()){
                    newAppId.add(appliObj.Id);
                    invoiceAmountAppliedMap.put(appliObj.Invoice__c, appliObj);
                }
                if(invoiceAmountAppliedMap.keySet().size() > 0){
                    List<Invoice__c> invoiceToDecreaseAmount = new List<Invoice__c>();
                    Map<Id,Invoice__c> invoiceBalanceMap = new Map<Id,Invoice__c>([SELECT id,Invoice_Balance__c from Invoice__c WHERE Id IN : invoiceAmountAppliedMap.keySet()]);
                    for(String invoiceId : invoiceAmountAppliedMap.keySet()){
                        Invoice__c invObj = new Invoice__c(Id=invoiceId);
                        invObj.Invoice_Balance__c = invoiceBalanceMap.get(invoiceId).Invoice_Balance__c - (invoiceAmountAppliedMap.get(invoiceId).Amount__c * -1);
                        invoiceToDecreaseAmount.add(invObj);
                        applicationAmount = applicationAmount - invoiceAmountAppliedMap.get(invoiceId).Amount__c;
                    }
                    if(!invoiceToDecreaseAmount.isEmpty()){UPDATE invoiceToDecreaseAmount;}
                }
                system.debug('newAppId==>>' + newAppId);
                if(newAppId.size() > 0){BM_JournalEntryEngine.creditMemoApplicationJournalLines(newAppId);}
            }
            Invoice__c parentInvoice = [SELECT Id, Invoice_Balance__c FROM Invoice__c WHERE Id =:objInvoice.Id LIMIT 1];
            parentInvoice.Invoice_Balance__c += applicationAmount;
            UPDATE parentInvoice;
            if(!unappliedCreditNote.isEmpty()){
                UPDATE unappliedCreditNote;
                UPDATE invoiceToUpdate;
                
                List<Id>  createReverseEntry = new List<Id>();
                for(Journal_Header__c jhRecord : [SELECT Id FROM Journal_Header__c WHERE Invoice_Line_Item__c IN : unappliedCreditNote AND Transaction_Type__c = 'Apply CreditMemo']){createReverseEntry.add(jhRecord.Id);}
                if(!createReverseEntry.isEmpty()){BM_JournalEntryEngine.journalEntryCreationForHeaderReversal(createReverseEntry, 'Unapply CreditMemo');}
            }
            
            
            
        }catch(Exception ex){
            system.debug('===exception is'+ex.getMessage());
            return ex.getMessage();
        }
        
        
        return 'SUCCESS';
    }

    public static Invoice_Line_Item__c addNewInvoiceLineItem(RelatedInvRecClass eachObj, Map<String,Id> mapofInvoicelineRecordTypeNameandId, Invoice__c objInvoice){
        Invoice_Line_Item__c objInvoice_Line_Item = new Invoice_Line_Item__c();
        if(eachObj.lineItemId <> null && eachObj.lineItemId <> '')
            objInvoice_Line_Item.id = eachObj.lineItemId;
        if(mapofInvoicelineRecordTypeNameandId <> null && mapofInvoicelineRecordTypeNameandId.get('Credit Memo Line') <> null) {
            objInvoice_Line_Item.RecordTypeId =  mapofInvoicelineRecordTypeNameandId.get('Credit Memo Line');
        }
        objInvoice_Line_Item.Related_Credit_Memo__c = objInvoice.id;
        objInvoice_Line_Item.Invoice__c = eachObj.invoiceId;
        objInvoice_Line_Item.Amount__c = eachObj.Amount != null ? eachObj.Amount*-1 : 0;
        if(objInvoice_Line_Item.GL_Date__c != null){objInvoice_Line_Item.GL_Date__c = eachObj.lineItemGLDate;    }
        
        
        if(eachObj.invTaxAmount != null && eachObj.invTaxAmount != 0){
            objInvoice_Line_Item.Tax__c = Constants.TaxCode;
            objInvoice_Line_Item.Tax_Amount__c = (eachObj.Amount*((decimal)Constants.TAX_PERCENT/100));
        }
        //Update tax code to 0. 1 Jun 2021
        if(String.isBlank(objInvoice_Line_Item.Tax__c)){objInvoice_Line_Item.Tax__c = Label.CATALYST_Tax_Code;}  
        objInvoice_Line_Item.Applied__c = true;
        return objInvoice_Line_Item;
    }
    
    /*@AuraEnabled
    public static String pushCMLineToOracle(String listRelatedInvRecClass){
        
        system.debug('invoiceId'+listRelatedInvRecClass);
        List<RelatedInvRecClass> relatedList = new List<RelatedInvRecClass>();
        relatedList = (List<RelatedInvRecClass>)JSON.deserialize(listRelatedInvRecClass, List<RelatedInvRecClass>.class);

        list<string> lstLineIds = new list<string>();

        if(relatedList <> null && relatedList.size() > 0) {
            for(RelatedInvRecClass objRelatedInvRecClass : relatedList) {
                if(objRelatedInvRecClass.LineItem != null && objRelatedInvRecClass.LineItem.Status__c != 'Invoiced'){
                    lstLineIds.add(objRelatedInvRecClass.LineItem.Id);
                }
            }
        }
        if(!lstLineIds.isEmpty()){
            string result = CreditMemoUtil.pushCreditMemoUpdateToOracle(lstLineIds);
            return result;
        }else{return 'No lines to push to Oracle';}
    }*/

    public class CreditMemoAppliedDetails {
        @AuraEnabled public Invoice__c objInvoice;
        @AuraEnabled public List<RelatedInvRecClass> listRelatedInvRecClass;
    }
    
    public class RelatedInvRecClass{
        @AuraEnabled public String invoiceNo;
        @AuraEnabled public String invoiceId;
        @AuraEnabled public Decimal Amount;
        @AuraEnabled public Decimal invoiceBalAmt;
        @AuraEnabled public string lineItemId;
        @AuraEnabled public Invoice_Line_Item__c LineItem;
        @AuraEnabled public decimal invTaxAmount;
        @AuraEnabled public Date lineItemGLDate;
        @AuraEnabled public Date invoiceGLDate;
    }
    
}