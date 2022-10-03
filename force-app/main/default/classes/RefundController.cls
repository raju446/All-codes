/*
    Author      :   Yogesh Mahajan
    Class Name  :   RefundController
    Description :   It is used as a controller for the refund Request page.
    Date        :   03/18/2020     
*/
public without sharing class RefundController {
	/*
	Method Name : Get picklist value map
	Description : Used send pickist map for invoice type and item description
	
    @AuraEnabled
    public static List<string> getInvoiceRevenue (String sourceSystemName) {
        
        List<String> listInvoiceRevenue = new List<String>();
        
        for(Invoice_Revenue_Classification__mdt objInvoiceRevenue : [SELECT Invoice_Type__c, Item_Description__c FROM Invoice_Revenue_Classification__mdt WHERE Source_System_Name__c = : sourceSystemName ]) {
            listInvoiceRevenue.add(objInvoiceRevenue.Invoice_Type__c);
        }
        system.debug('----->'+listInvoiceRevenue);
        return listInvoiceRevenue;
    }
    */
    
    @AuraEnabled  
    public static Refund__c fetchRefundDetails(String refundId) {
        return [select id, Status__c,Payment_Method__c, Entity__r.Oracle_Site_Id__c,Oracle_Callout_Status__c from Refund__c where id = : refundId];
    }    
    
    @AuraEnabled  
    public static String pushRefundRecToOrale(String refundId) {
        return RefundUtil.pushRefundToOracle(refundId);
    } 
    
    @AuraEnabled
    public static string submitForApproval(String refundId) {
        if(refundId <> null && refundId <> '') {
            List<Refund__c> listRefund = new List<Refund__c>();
            listRefund = [SELECT Id, Status__c FROM Refund__c WHERE id = :refundId ];
            if(listRefund <> null && listRefund.size() > 0 && (listRefund[0].Status__c == 'Draft' || listRefund[0].Status__c == 'Rejected')) {
                List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting Refund for approval ');
                
                req1.setObjectId(refundId);
                requests.add(req1);
                if(requests <> null && requests.size() > 0 ) {
                    List<Approval.ProcessResult> processResults = new List<Approval.ProcessResult>();
                    try {
                        processResults = Approval.process(requests, true);
                    }catch (exception ex) {
                        System.debug('Exception Is ' + ex.getMessage());
                        //Database.rollback( sp );
                        return  ex.getMessage();
                    }
                }
                return 'Success';
            } else if(listRefund <> null && listRefund.size() > 0 && listRefund[0].Status__c == 'Under Review') {
                return 'Record is already submitted for approval';
            } else if(listRefund <> null && listRefund.size() > 0 && (listRefund[0].Status__c == 'Invoiced' || listRefund[0].Status__c == 'Approved' )) {
                return 'Record is already processed';
            }
        }
        
        
        return 'Record not found';
    }
    
    
    /*
	Method Name : fetchPicklistVal
	Description : Used to fetch Picklist Values
	*/
    @AuraEnabled  
    public static RefundResponse getRefundDetails(String refundId) {
        List<Refund__c> listRefund = new List<Refund__c>();
        listRefund = [select id, Status__c,Payment_Method__c, Entity__r.Oracle_Site_Id__c from Refund__c where id = : refundId];
        if(listRefund <> null && listRefund.size() > 0) {
            RefundResponse objRefundResponse = new RefundResponse();
            objRefundResponse.objRefund = listRefund[0];
            if(listRefund[0].Status__c == 'Approved')
            	objRefundResponse.MSG = 'Success';
            else if(listRefund[0].Status__c == 'Cancelled')
                objRefundResponse.MSG = 'Refund request is cancelled';
            else if(listRefund[0].Status__c == 'Invoiced') 
                objRefundResponse.MSG = 'Refund request is already processed successfully';
            return objRefundResponse;
        }
            
        return null;
    }//end fetchPicklistVal()
    
    @AuraEnabled
    public static Billing_Management_Setting__mdt fetchBillingManagementMDTDetail(){
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        system.debug('Profile Name'+profileName);
        return [SELECT Add_Invoice__c,Add_Receipt__c,Corporate_Customer__c,Credit_Memo__c,DeveloperName,Fund_Transfer__c,Id,Individual_Customer__c,Label,Default_OU__c,Default_Source_System__c,
        Language,MasterLabel,NamespacePrefix,QualifiedApiName,Refund_Request__c FROM Billing_Management_Setting__mdt WHERE Label =: profileName];
    }
    
    @AuraEnabled
    public static SavedRefundwrapper getOldData(String refundId){
        SavedRefundwrapper objOldData = new SavedRefundwrapper();
        List<Refund__c> listRefund = new List<Refund__c>();
        //,(select id,Refund_Amount__c,Invoice_Line_Item__c from Refund_Line_Items__r)
        listRefund = [select id, Scenario__c,Actual_Payment_Method__c,Credit_Memo_Receipt__c,Source_System__c,CustomerOU__c,IBAN_Number__c,Vendor_Name__c,Vendor_Number__c,Bank_Name__c,Bank_Account_Number__c,Pushed_To_Oracle__c, Entity__c,Entity__r.Source_System_Name__c,Payment_Method__c, Receipt__c, Credit_Memo__c,Transaction_Types__c,Currency__c, Amount__c, Description__c, 
                    Authorization_Code__c,Card_First_Last_Digit__c
                    
                      from Refund__c 
                      where id =: refundId];
        system.debug('---->'+ listRefund[0].Amount__c);
        
        if(listRefund <> null && listRefund.size() > 0) {
            objOldData.objRefund = listRefund[0];
            //objOldData.objRefund.Amount__c = 55555;
            if(listRefund[0].Entity__c <> null ) {
                List<Account> listEntity = new List<Account>();
                listEntity = [select id, Name from account where id =: listRefund[0].Entity__c] ; 
                if(listEntity <> null && listEntity.size() > 0) {
                     objOldData.selectedEntity = listEntity[0];
                }
            }
            
            if(listRefund[0].Receipt__c <> null ) {
                List<Receipt__c> listReceipt = new List<Receipt__c>();
                listReceipt = [select id,Lookup_Search_Field__c, Receipt_Reference__c,Amount__c,Total_Applied_Amount__c from Receipt__c where id =: listRefund[0].Receipt__c] ; 
                system.debug('--->'+listReceipt);
                if(listReceipt <> null && listReceipt.size() > 0) {
                     objOldData.selectedReceipt = listReceipt[0];
                   // Map<Id, Refund_Line_Item__c> mapRefundLine = new Map<Id, Refund_Line_Item__c>();
                    /*for(Refund_Line_Item__c objRefundLine : listRefund[0].Refund_Line_Items__r) {
                        mapRefundLine.put(objRefundLine.Invoice_Line_Item__c, objRefundLine);
                    } */
                  //  system.debug('--->'+mapRefundLine);
                    //listRefundLine = listRefund[0].Refund_Line_Items__r;
                   // objOldData.listInvoiceLine = getRelatedInvoice(listReceipt[0].id, mapRefundLine);
                }
            }
            
            if(listRefund[0].Credit_Memo__c <> null ) {
                List<Invoice__c> listInvoice = new List<Invoice__c>();
                listInvoice = [select id, Name,Invoice_Balance__c from Invoice__c where id =: listRefund[0].Credit_Memo__c] ; 
                if(listInvoice <> null && listInvoice.size() > 0) {
                     objOldData.selectedCreditMemo = listInvoice[0];
                }
            } 
            
            if(listRefund[0].Credit_Memo_Receipt__c <> null ) {
                List<Receipt__c> listReceipt = new List<Receipt__c>();
                listReceipt = [select id,Lookup_Search_Field__c, Receipt_Reference__c,Amount__c,Total_Applied_Amount__c from Receipt__c where id =: listRefund[0].Credit_Memo_Receipt__c] ; 
                system.debug('--->'+listReceipt);
                if(listReceipt <> null && listReceipt.size() > 0) {
                     objOldData.selectedCreditMemoReceipt = listReceipt[0];
                }
            }
            
        }
        system.debug('====>'+objOldData);
        return objOldData;
    }
    
    
    /**
    * @description 
    * @author Jayanta Karmakar | 4/2/2020 
    * @param Refund__c objRefund 
    * @param RefundUtil.ResponseRefundWrapper IBANDetails 
    * @param String crditCardDetail 
    * @return RefundResponse 
    **/
    @AuraEnabled 
    public static RefundResponse saveIBAN(Refund__c objRefund,RefundUtil.ResponseRefundWrapper IBANDetails, String crditCardDetail) {
        if(objRefund <> null) {
            if(IBANDetails <> null && objRefund.Payment_Method__c == 'Bank Transfer') {
                objRefund.Vendor_Name__c =IBANDetails.P_OP_VENDOR_NAME;
                objRefund.Vendor_Number__c = IBANDetails.P_OP_VENDOR_NUMBER;
                objRefund.Bank_Account_Number__c = IBANDetails.P_OP_BANK_ACCOUNT_NUM;
                objRefund.Bank_Name__c = IBANDetails.P_OP_BANK_NAME;
                objRefund.IBAN_Number__c = IBANDetails.P_OP_IBAN;
            }
            if(crditCardDetail <> '' && objRefund.Payment_Method__c == 'Credit Card') {
                objRefund.Card_First_Last_Digit__c = crditCardDetail;
            }   
            RefundResponse objRefundResponse = new RefundResponse();
            objRefundResponse.objRefund = objRefund;
            objRefundResponse.MSG = 'success';
            try{
                update objRefund;
            }catch(exception ex) {
                objRefundResponse.MSG = ex.getMessage();
            }
            
        }
        return null;
    }
    
    @AuraEnabled 
    public static RefundUtil.ResponseRefundWrapper fetchIBAN(String entityId,String IBANNum) {
        return RefundUtil.getIBANDetail(entityId, IBANNum);
	}
    
    @AuraEnabled 
    public static RefundUtil.IBANElements fetchIBAN_New(String entityId,String IBANNum) {
        return RefundUtil.getIBANDetail_New(entityId, IBANNum);
	}
    
    /*
	Method Name : fetchPicklistVal
	Description : Used to fetch Picklist Values
	*/
    @AuraEnabled  
    public static List<LEX_Helper.PicklistValueWrapper> fetchPicklistVal(String objectApi,String fieldAPIname, Boolean nullRequired) {
        return LEX_Helper.getPicklistValues(objectApi, fieldAPIname, nullRequired);
    }//end fetchPicklistVal()
   /* @AuraEnabled
    public static List<InvoiceWrapper> getRelatedInvoice(String selectedReceiptId, Map<Id, Refund_Line_Item__c> mapOldRefundLine) {
        List<Id> listInvoiceId = new List<Id>(); 
        Map<Id,Decimal> invoiceVsAppliedAmountMap = new Map<Id,Decimal>();
        for(Related_Invoice_Receipt__c objRelatedInvoiceReceipt : [SELECT Receipt_Name__c, Receipt__c,Invoice__c,Amount_Applied__c FROM Related_Invoice_Receipt__c where Receipt__c = : selectedReceiptId]) {
            listInvoiceId.add(objRelatedInvoiceReceipt.Invoice__c);
            invoiceVsAppliedAmountMap.put(objRelatedInvoiceReceipt.Invoice__c,objRelatedInvoiceReceipt.Amount_Applied__c);
        }
        List<InvoiceWrapper> listInvoiceWrapper = new List<InvoiceWrapper>();
        for(Invoice__c objInvoice :[SELECT id,Transaction_Reference__c, Payment_Term__c, Payment_Currency__c, Oracle_Invoice_Type__c,Name,(SELECT Id,Amount__c,Tax_Amount__c,Discount_Amount__c,Taxable_Discount_Amount__c,Item_Description__c,Calculated_Amount__c FROM Invoice_Line_Items__r) FROM Invoice__c WHERE Id IN:listInvoiceId  ]){
            List<RelatedLineDetails> listInvoiceLineWrapper = new List<RelatedLineDetails>();
            InvoiceWrapper objInvoiceWrapper = new InvoiceWrapper();
            for(Invoice_Line_Item__c objInvoiceLineItem : objInvoice.Invoice_Line_Items__r) {
                RelatedLineDetails objRelatedLineDetails = new RelatedLineDetails();
                objRelatedLineDetails.InvoiceLineRec = objInvoiceLineItem;
                objRelatedLineDetails.refundAmount = 0;
                system.debug('--->'+objInvoiceLineItem.id);
                //system.debug('--->'+mapOldRefundLine;
                if(mapOldRefundLine <> null && mapOldRefundLine.get(objInvoiceLineItem.id) <> null ) {
                     objRelatedLineDetails.isSelected = true;
                    if(mapOldRefundLine.get(objInvoiceLineItem.id).Refund_Amount__c <> null)
                     objRelatedLineDetails.refundAmount = mapOldRefundLine.get(objInvoiceLineItem.id).Refund_Amount__c;
                }else {
                    objRelatedLineDetails.isSelected = false;
                } 
                    
                
                listInvoiceLineWrapper.add(objRelatedLineDetails);
            }
            objInvoiceWrapper.invoiceRec = objInvoice;
            objInvoiceWrapper.listInvoiceLineRec = listInvoiceLineWrapper;
            objInvoiceWrapper.appliedAmount = invoiceVsAppliedAmountMap.get(objInvoice.Id);
            listInvoiceWrapper.add(objInvoiceWrapper) ;
        }
        System.debug(listInvoiceWrapper);
        return listInvoiceWrapper;
    } */
    
    @AuraEnabled
    public static string saveRefundRecord(Refund__c refundRecord, List<InvoiceWrapper> invoiceList, List<AttachmentWrapper> attachmentFiles){
        System.debug('refundRecord===='+refundRecord);
        System.debug('invoiceList===='+attachmentFiles);
        System.debug('attachmentFiles===='+attachmentFiles);
        try{
            upsert refundRecord;
           /* if(invoiceList.size() > 0){
                List<Refund_Line_Item__c> refundLines = [SELECT Id,Invoice_Line_Item__c,Refund__c from Refund_Line_Item__c WHERE Refund__c =: refundRecord.Id];
                Map<Id,Refund_Line_Item__c> refundItemMap = new Map<Id,Refund_Line_Item__c>();
                for(Refund_Line_Item__c eachItem : refundLines){
                    refundItemMap.put(eachItem.Invoice_Line_Item__c, eachItem);
                }
                List<Refund_Line_Item__c> itemsToInser = new List<Refund_Line_Item__c>();
                List<Refund_Line_Item__c> itemsToDelete = new List<Refund_Line_Item__c>();
                Set<Id> invLineIds = new Set<Id>();
                for(InvoiceWrapper eachInvWrap : invoiceList){
                    for(RelatedLineDetails eachineWrap : eachInvWrap.listInvoiceLineRec){
                        if(eachineWrap.refundAmount != null && eachineWrap.refundAmount > 0){
                            invLineIds.add(eachineWrap.InvoiceLineRec.Id);
                            if(refundItemMap.containskey(eachineWrap.InvoiceLineRec.Id)){
                                refundItemMap.get(eachineWrap.InvoiceLineRec.Id).Refund_Amount__c = eachineWrap.refundAmount;
                                itemsToInser.add(refundItemMap.get(eachineWrap.InvoiceLineRec.Id));
                            }
                            itemsToInser.add(new Refund_Line_Item__c(Invoice_Line_Item__c = eachineWrap.InvoiceLineRec.Id, Refund__c = refundRecord.Id,Refund_Amount__c = eachineWrap.refundAmount));
                        } 
                    }
                }
                
                for(Refund_Line_Item__c eachItem : refundLines){
                    if(!invLineIds.contains(eachItem.Invoice_Line_Item__c)){
                        itemsToDelete.add(eachItem);
                    }
                }

                if(itemsToInser.size() > 0){
                    upsert itemsToInser;
                }
                
                if(itemsToDelete.size() > 0){
                    delete itemsToInser;
                }
            } */

            if(attachmentFiles.size() > 0){
                List<ContentVersion> conVersions = new List<ContentVersion>();
                for(AttachmentWrapper eachAW : attachmentFiles){
                    System.debug(eachAW.fileName);
                    System.debug(eachAW.isUploaded);
                    if(eachAW.isUploaded){
                        ContentVersion contentVers = new ContentVersion();
                        contentVers.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
                        contentVers.PathOnClient = eachAW.fileName; 
                        contentVers.Title = eachAW.fileName;
                        contentVers.VersionData = EncodingUtil.base64Decode(eachAW.blobval); // contentVersting your binary string to Blog
                        conVersions.add(contentVers);
                    }
                }
                System.debug('conVersions===='+conVersions);

                if(conVersions.size() > 0){
                    insert conVersions;
                    List<ContentVersion> insertedCV = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :conVersions];
                    List<ContentDocumentLink> contentDocToInsert = new List<ContentDocumentLink>();
                    for(ContentVersion eachCV : insertedCV){
                        ContentDocumentLink contentLink = new ContentDocumentLink();
                        contentLink.ContentDocumentId = eachCV.ContentDocumentId;
                        contentLink.LinkedEntityId = refundRecord.Id; 
                        contentLink.ShareType = 'I'; // Inferred permission
                        contentLink.Visibility = 'AllUsers';
                        contentDocToInsert.add(contentLink);
                    }
                    System.debug('contentDocToInsert===='+contentDocToInsert);
                    if(contentDocToInsert.size() > 0){
                        insert contentDocToInsert;
                    }
                }        
            }
            return refundRecord.Id;
        } catch(Exception e){
            
            System.debug('Exception===='+e.getLineNumber());
            return 'ERROR :'+e.getMessage();
        }
    }
    
    @AuraEnabled
    public static List<Receipt__c> fetchReceiptDetails(String receiptId){
        return [SELECT Id,Authorization_Code__c,Payment_Method__c,Payment_Currency__c,Amount__c,Credit_Card_F_L_Four_Digits__c,Total_Applied_Amount__c FROM Receipt__c WHERE Id =: receiptId];
    }

    @AuraEnabled
    public static List<Invoice__c> fetchCreditMemoDetails(String cmId){
        return [SELECT Id,Payment_Currency__c,Invoice_Balance__c FROM Invoice__c WHERE Id =: cmId];
    }
	
    public class SavedRefundwrapper {
        @AuraEnabled public Refund__c objRefund {get;set;}
        @AuraEnabled public sObject selectedEntity {get;set;}
        @AuraEnabled public sObject selectedCreditMemo {get;set;}
        @AuraEnabled public sObject selectedReceipt {get;set;}
        @AuraEnabled public sObject selectedCreditMemoReceipt {get;set;}
        @AuraEnabled public List<InvoiceWrapper> listInvoiceLine {get;set;}
    }
    
    public class InvoiceWrapper {
        @AuraEnabled public Invoice__c invoiceRec {get;set;}
        @AuraEnabled public Decimal appliedAmount {get;set;}
        @AuraEnabled public List<RelatedLineDetails> listInvoiceLineRec {get;set;}
            public InvoiceWrapper (){
                appliedAmount = 0.0;
            }                                                                               
    }//end InvoiceWrapper
    public class RelatedLineDetails {
        @AuraEnabled public Invoice_Line_Item__c InvoiceLineRec {get;set;}
        @AuraEnabled public Decimal refundAmount {get;set;}
        @AuraEnabled public Boolean isSelected {get;set;}
    }
    public class AttachmentWrapper {
        @AuraEnabled public String fileName {get;set;}
        @AuraEnabled public String blobval {get;set;} 
        @AuraEnabled public Boolean isUploaded {get;set;}
    }
    
    public class RefundResponse {
        @AuraEnabled public Refund__c objRefund {get;set;}
        @AuraEnabled public string MSG {get;set;}
    }
}