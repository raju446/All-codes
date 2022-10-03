/*
    Author      :   Yogesh Mahajan
    Class Name  :   CreditMemoController
    Description :   It is used as a controller for the Credit Memo Request page.
    Date        :   07/13/2019     
*/
public without sharing class CreditMemoController {
    
    @AuraEnabled  
    public static Account getEntityDetail(String accID) {
        return [select id, name, toLabel(Oracle_Site_Id__c)  from account where id = : accID];
    }
    
    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews = [SELECT Id, Name FROM ListView WHERE SobjectType = 'Invoice__c' and Name='Credit Memo'];
        
        // Perform isAccessible() check here
        return listviews;
    }
    
    @AuraEnabled
    public static String getUserName() {
        return userinfo.getName();
    }
    
    @AuraEnabled  
    public static string getCreditMemoStatus(String creditMemoId) {
        List<Invoice__c> listInvoice  = new List<Invoice__c>();
        listInvoice = [select id, status__c, Oracle_Invoice_Id__c from Invoice__c where (Invoice_Type__c = 'Credit Memo') and id =:creditMemoId ];
        if(listInvoice <> null && listInvoice.size() > 0 && listInvoice[0].Oracle_Invoice_Id__c <> null && listInvoice[0].Oracle_Invoice_Id__c <> '') {
            return 'Record is already processed';
        } if(listInvoice <> null && listInvoice.size() > 0 && listInvoice[0].status__c <> 'Draft' && listInvoice[0].status__c <> 'Rejected') {
            return 'Record edit is not allowed';
        } else if(listInvoice <> null && listInvoice.size() > 0) {
            return 'Success';
        }
        return 'Only credit memo record is allowed to edit!!';
    }//end fetchReceiptPicklistVal()
	/*
	Method Name : fetchReceiptPicklistVal
	Description : Used to fetch Receipt Picklist Values
	*/
    @AuraEnabled  
    public static List<LEX_Helper.PicklistValueWrapper> fetchPicklistVal(String objectApi,String fieldAPIname, Boolean nullRequired) {
        return LEX_Helper.getPicklistValues(objectApi, fieldAPIname, nullRequired);
    }//end fetchReceiptPicklistVal()
	
    @AuraEnabled
    public static SavedCreditMemoWrapper getSavedCreditMemo (String invoiceId){
        SavedCreditMemoWrapper objSavedCreditMemoWrapper = new SavedCreditMemoWrapper();
        List<RelatedInvoicLinesClass> listInvoiceWrapper = new List<RelatedInvoicLinesClass>();
        List<RelatedInvoiceClass> listRelatedInvoiceClass = new List<RelatedInvoiceClass>();
        List<Id> listLineIds = new List<ID>();
        Map<Id, Invoice_Line_Item__c> mapILT = new Map<Id, Invoice_Line_Item__c>();
        List<sObject> listSelectedEntity = new List<sObject>();
        List<sObject> listSelectedInvoice = new List<sObject>();
        
             
        List<Invoice__c> listInvoice = new List<Invoice__c>();
        listInvoice = [select id,Name,Status__c, Source_System__c,Entity__r.Oracle_Site_Id__c,Entity__r.Source_System__c,Entity__r.Source_System_Name__c,Oracle_Invoice_Type__c,Invoice_Type__c,Payment_Currency__c, Invoice_Balance__c,Is_Refundable__c, RecordType.DeveloperName,Description__c,Total_Lines_Taxable_Amount__c, Total_Lines_Non_Taxable_Amount__c,
                                     (SELECT Id,Amount__c,Tax_Amount__c,Discount_Amount__c,Credit_Memo_Applied_Amount__c,Taxable_Discount_Amount__c,Item_Description__c, Calculated_Amount__c,Item_Reference__c, Invoice_Line_Item__c,Invoice_Line_Item__r.Invoice__c,Invoice_Line_Item__r.Invoice__r.Name, Invoice_Line_Item__r.Invoice__r.Oracle_Invoice_Type__c,Tax__c,Line_Description__c, Department__c,Service_Type__c,Course_Type__c,Schools__c,Quantity__c,Revenue_Type__c  FROM Invoice_Line_Items__r where recordtype.DeveloperName = 'Invoice_Line_Item') from Invoice__c Where ID =: invoiceId];
        
        if(listInvoice.size() > 0 && listInvoice[0].Invoice_Type__c == 'Credit Memo') {
            system.debug('listInvoice '+listInvoice[0].Invoice_Line_Items__r);
            objSavedCreditMemoWrapper.objInv = listInvoice[0];
            
            listSelectedEntity = [select id, Name, Oracle_Party_Id__c, Oracle_Site_Id__c from account where id =: listInvoice[0].Entity__c] ;   
            objSavedCreditMemoWrapper.selectedEntity = listSelectedEntity[0];
            //get revenue Detail
            objSavedCreditMemoWrapper.revenueDetail = getInvoiceRevenue(listInvoice[0].Entity__r.Source_System_Name__c);
            
            List<Id> listInvoiceId = new List<Id>();
            for(Invoice_Line_Item__c objInvoice_Line_Item : listInvoice[0].Invoice_Line_Items__r) {
                if(objInvoice_Line_Item.Amount__c <>null )
                	objSavedCreditMemoWrapper.inAmount = objInvoice_Line_Item.Amount__c;
                else 
                    objSavedCreditMemoWrapper.inAmount = 0;
                listLineIds.add(objInvoice_Line_Item.Invoice_Line_Item__c);
                mapILT.put(objInvoice_Line_Item.Invoice_Line_Item__c, objInvoice_Line_Item);
                listInvoiceId.add(objInvoice_Line_Item.Invoice_Line_Item__r.Invoice__c);
            }//end for
            listSelectedInvoice = [select id, Name,Invoice_Search_Text__c from Invoice__c where id IN: listInvoiceId] ; 
            if(listSelectedInvoice <> null && listSelectedInvoice.size() > 0)
            	objSavedCreditMemoWrapper.selectedInvoice = listSelectedInvoice[0];
            else 
                objSavedCreditMemoWrapper.selectedInvoice = null;
            objSavedCreditMemoWrapper.listOldLineId = listLineIds;
            objSavedCreditMemoWrapper.listRelatedInvLine = getInvoiceLines(listInvoiceId[0], mapILT, listInvoice[0] );
            objSavedCreditMemoWrapper.listInvoiceLineItem = listInvoice[0].Invoice_Line_Items__r;
				
        } else {
            return null;
        }

        system.debug('---->'+objSavedCreditMemoWrapper);
        return objSavedCreditMemoWrapper;
    }
    
	@AuraEnabled
    public static List<RelatedInvoicLinesClass> getInvoiceLines (String invoiceID, Map<Id, Invoice_Line_Item__c> oldSelectedLines, Invoice__c insertedMemo){
        system.debug('--->'+insertedMemo);
        List<Id> listInvoiceId = new List<ID>();
        if(invoiceID <> null && invoiceID <> '') {
			listInvoiceId.add(invoiceID);
        }
        if(insertedMemo <> null)
            listInvoiceId.add(insertedMemo.id);
        
        List<RelatedInvoicLinesClass> listInvoiceWrapper = new List<RelatedInvoicLinesClass>();
        List<Invoice__c> listInvoice = new List<Invoice__c>();
        if(insertedMemo <> null && insertedMemo.Is_Refundable__c) {
            listInvoice = [select id,Name, Payment_Term__c, Payment_Currency__c, Oracle_Invoice_Type__c,Invoice_Balance__c,Total_Lines_Non_Taxable_Amount__c,
                            Total_Lines_Taxable_Amount__c, Applied_Credit_Memo_Amount__c,
                                (SELECT Id,Amount__c,Tax_Amount__c,Credit_Memo_Applied_Amount__c,Discount_Amount__c,Taxable_Discount_Amount__c,Item_Description__c, Item_Reference__c,Invoice__c,Invoice__r.Payment_Currency__c,Applied_Status__c,Calculated_Amount__c,Line_Description__c,Line_Amount__c,Line_Tax_Amount__c,Tax__c, Department__c,Service_Type__c,Course_Type__c,Schools__c,Quantity__c,Revenue_Type__c 
                                 FROM Invoice_Line_Items__r where recordtype.DeveloperName = 'Invoice_Line_Item' and Is_Discount__c = false) 
                            from Invoice__c Where ID IN: listInvoiceId];
        } else if(oldSelectedLines == null || oldSelectedLines.values().size() == 0) {
            listInvoice = [select id,Name, Payment_Term__c, Payment_Currency__c, Oracle_Invoice_Type__c,Invoice_Balance__c,Total_Lines_Non_Taxable_Amount__c,
                            Total_Lines_Taxable_Amount__c, Applied_Credit_Memo_Amount__c,
                                (SELECT Id,Amount__c,Tax_Amount__c,Credit_Memo_Applied_Amount__c,Discount_Amount__c,Taxable_Discount_Amount__c,Item_Description__c, Item_Reference__c,Invoice__c,Invoice__r.Payment_Currency__c,Applied_Status__c,Calculated_Amount__c,Line_Description__c,Line_Amount__c,Line_Tax_Amount__c,Tax__c, Department__c,Service_Type__c,Course_Type__c,Schools__c,Quantity__c,Revenue_Type__c
                                 FROM Invoice_Line_Items__r where recordtype.DeveloperName = 'Invoice_Line_Item' and Is_Discount__c = false) from Invoice__c Where ID IN: listInvoiceId AND Status__c='Invoiced' AND Invoice_Balance__c > 0];
        } else {
            listInvoice = [select id,Name, Payment_Term__c, Payment_Currency__c, Oracle_Invoice_Type__c,Invoice_Balance__c,Total_Lines_Non_Taxable_Amount__c,
                            Total_Lines_Taxable_Amount__c, Applied_Credit_Memo_Amount__c,
                                (SELECT Id,Amount__c,Tax_Amount__c,Credit_Memo_Applied_Amount__c,Discount_Amount__c,Taxable_Discount_Amount__c,Item_Description__c, Item_Reference__c,Invoice__c,Invoice__r.Payment_Currency__c,Applied_Status__c,Calculated_Amount__c,Line_Description__c,Line_Amount__c,Line_Tax_Amount__c,Tax__c, Department__c,Service_Type__c,Course_Type__c,Schools__c,Quantity__c,Revenue_Type__c 
                                 FROM Invoice_Line_Items__r where recordtype.DeveloperName = 'Invoice_Line_Item' and Is_Discount__c = false) from Invoice__c Where ID IN: listInvoiceId AND Status__c='Invoiced' AND Invoice_Balance__c > 0];
        } 
        
        system.debug('--->'+listInvoice);
        for(Invoice__c objInvoice : listInvoice){
            system.debug('--->'+objInvoice);
        	RelatedInvoicLinesClass objRelatedInvoicLinesClass = new RelatedInvoicLinesClass();
            objRelatedInvoicLinesClass.invoiceRec = objInvoice;
            List<RelatedLineDetails> listRelatedLineDetails = new List<RelatedLineDetails>();
            for(Invoice_Line_Item__c objInvoice_Line_Item : objInvoice.Invoice_Line_Items__r) {
                system.debug('--->'+objInvoice_Line_Item);
                RelatedLineDetails objRelatedLineDetails = new RelatedLineDetails();
                objRelatedLineDetails.InvoiceLineRec = objInvoice_Line_Item;
                if((oldSelectedLines <> null && oldSelectedLines.values().size() > 0 && oldSelectedLines.get(objInvoice_Line_Item.id) <> null) || (insertedMemo <> null && insertedMemo.Is_Refundable__c))
                    objRelatedLineDetails.isSelected = true;
                else
                    objRelatedLineDetails.isSelected = false;
                objRelatedLineDetails.dAmount = 0;
                if(oldSelectedLines <> null && oldSelectedLines.get(objInvoice_Line_Item.id) <> null ) {
                    objRelatedLineDetails.dAmount = oldSelectedLines.get(objInvoice_Line_Item.id).Amount__c * -1;
                }

                listRelatedLineDetails.add(objRelatedLineDetails);
            }
            objRelatedInvoicLinesClass.listInvoiceLineRec = listRelatedLineDetails;    
            listInvoiceWrapper.add(objRelatedInvoicLinesClass);
        }
        system.debug('---->'+listInvoiceWrapper);
        return listInvoiceWrapper;
    }
    
    @AuraEnabled
    public static ResponseWrapper saveCreditMemo (Invoice__c objCreditMemo, List<RelatedInvoicLinesClass> listInvoiceWrapper, String accountId, Integer inAmount, String selectedScenario) {
        
        system.debug('objCreditMemo--->'+objCreditMemo);
        objCreditMemo.GL_Date__c = System.today();
        ResponseWrapper objResponseWrapper = new ResponseWrapper();
        Map<Id, Invoice_Line_Item__c> mapOldLineItem = new Map<Id, Invoice_Line_Item__c>();
        if(objCreditMemo.id <> null) {
            for(Invoice_Line_Item__c objInvoiceLineItem : [select id,Invoice_Line_Item__c  from Invoice_Line_Item__c where Invoice__c =:objCreditMemo.id]) {
                mapOldLineItem.put(objInvoiceLineItem.Invoice_Line_Item__c, objInvoiceLineItem);
            }
        }
        Map<String,Id> mapofInvoiceRecordTypeNameandId = new Map<String,Id>();
        mapofInvoiceRecordTypeNameandId = ApexCodeUtility.getRecTypeDetails('Invoice__c');
        
        List<Invoice_Line_Item__c> listMemoLines = new List<Invoice_Line_Item__c>();
        
        List<Invoice_Line_Item__c> listLineItemToDelete = new List<Invoice_Line_Item__c>();
        set<ID> selectLineIds = new set<ID>();
        map<Id, Invoice_Line_Item__c> mapLines = new map<Id, Invoice_Line_Item__c>();

        Invoice__c ActualInvoice;// = new Invoice__c();

        list<Id> lstInvIds = new list<id>();

        //Savepoint sp = Database.setSavepoint();
        try{
            if(string.isNotBlank(accountId) && objCreditMemo <> null) {
                if(selectedScenario != 'Invoice Fully Paid') {
                    
                    if(listInvoiceWrapper <> null && listInvoiceWrapper.size() > 0) {
                        objCreditMemo.Entity__c = accountId;
                        objCreditMemo.Status__c = 'Draft';
                        objCreditMemo.Payment_Currency__c = listInvoiceWrapper[0].listInvoiceLineRec[0].InvoiceLineRec.Invoice__r.Payment_Currency__c;
                        objCreditMemo.recordtypeId = mapofInvoiceRecordTypeNameandId.get('Credit Memo'); 
                        objCreditMemo.Invoice_Type__c = 'Credit Memo';
                        objCreditMemo.Related_Invoice__c = listInvoiceWrapper[0].listInvoiceLineRec[0].InvoiceLineRec.Invoice__c;
                        objCreditMemo.Invoice_Date__c = system.today();
                        

                        decimal dtotal = 0, dAppliedTotal = 0, lineAmt =0, taxAmt = 0;
                        for(RelatedInvoicLinesClass objRelatedInvoicLinesClass : listInvoiceWrapper) {
                            for(RelatedLineDetails objRelatedLineDetails : objRelatedInvoicLinesClass.listInvoiceLineRec){
                                if(objRelatedLineDetails.isSelected && objRelatedLineDetails.dAmount != null) {
                                    dtotal += objRelatedLineDetails.dAmount;
                                    lineAmt += objRelatedLineDetails.dAmount;
                                    Integer iTaxPercent = (Constants.SET_TAX_VALUES.contains(objRelatedLineDetails.InvoiceLineRec.Tax__c) ? Constants.TAX_PERCENT : 0);
                                    dtotal += (objRelatedLineDetails.dAmount*((decimal)iTaxPercent/100));
                                    taxAmt += (objRelatedLineDetails.dAmount*((decimal)iTaxPercent/100));
                                    lstInvIds.add(objRelatedLineDetails.InvoiceLineRec.Invoice__c);
                                }
                            }
                        }
                        //dtotal = dtotal*-1;
                        
                        for(Invoice__c objIn : [select Id,Applied_Credit_Memo_Amount__c,Invoice_Balance__c from Invoice__c where Id=:objCreditMemo.Related_Invoice__c]){
                            ActualInvoice = objIn;
                        }

                        for(Invoice__c objInv : [select Id,(select Amount__c,Tax_Amount__c from Invoice_Line_Items__r ) from Invoice__c 
                                                where Related_Invoice__c=:objCreditMemo.Related_Invoice__c AND Id !=: objCreditMemo.Id AND RecordTypeId =: mapofInvoiceRecordTypeNameandId.get('Credit Memo') ]){
                            for(Invoice_Line_Item__c objILI : objInv.Invoice_Line_Items__r)
                                dAppliedTotal += (objILI.Amount__c != null ? objILI.Amount__c : 0 );                            
                        }
                        dAppliedTotal = dAppliedTotal*-1;

                        system.debug(' dAppliedTotal  is '+dAppliedTotal);
                        system.debug(' dtotal  is '+dtotal);
                        if(ActualInvoice != null && (dAppliedTotal+dtotal) > ActualInvoice.Invoice_Balance__c ){
                            objResponseWrapper.MSG = 'Applied credit memo is more than invoice balance';
                            return objResponseWrapper;
                        }

                        upsert objCreditMemo;

                        if(ActualInvoice != null){
                            ActualInvoice.Applied_Credit_Memo_Amount__c = (dAppliedTotal+dtotal);
                            update ActualInvoice;
                        }


                        
                        system.debug('Credit Memo----->'+objCreditMemo);
                        system.debug('listInvoiceWrapper----->'+listInvoiceWrapper);
                        
                        for(RelatedInvoicLinesClass objRelatedInvoicLinesClass : listInvoiceWrapper) {
                            for(RelatedLineDetails objRelatedLineDetails : objRelatedInvoicLinesClass.listInvoiceLineRec){
                                if(objRelatedLineDetails.isSelected) {
                                    mapLines.put(objRelatedLineDetails.InvoiceLineRec.id, null);
                                }
                            }
                        }
                        if(!mapLines.isEmpty()){
                            mapLines = new map<Id, Invoice_Line_Item__c>([select Id,Tax__c from Invoice_Line_Item__c where Id IN : mapLines.keySet()]);
                        }

                        for(RelatedInvoicLinesClass objRelatedInvoicLinesClass : listInvoiceWrapper) {
                            for(RelatedLineDetails objRelatedLineDetails : objRelatedInvoicLinesClass.listInvoiceLineRec){
                                if(objRelatedLineDetails.isSelected) {
                                    selectLineIds.add(objRelatedLineDetails.InvoiceLineRec.id);
                                }
                                if(objRelatedLineDetails.isSelected ) {
                                    Invoice_Line_Item__c objCreditMemoLineItem = new Invoice_Line_Item__c();
                                    //Invoice_Line_Item__c oldLineItem = new Invoice_Line_Item__c();
                                    //oldLineItem.id =  objRelatedLineDetails.InvoiceLineRec.id;
                                    if(mapOldLineItem <> null && mapOldLineItem.get(objRelatedLineDetails.InvoiceLineRec.id) <> null) {
                                        objCreditMemoLineItem.id = mapOldLineItem.get(objRelatedLineDetails.InvoiceLineRec.id).id;
                                    }
                                    
                                    
                                    //oldLineItem.Applied_Status__c =  'Credit Memo Applied';
                                    
                                    //objRelatedLineDetails.InvoiceLineRec.Credit_Memo_Applied_Amount__c = objRelatedLineDetails.InvoiceLineRec.Credit_Memo_Applied_Amount__c == null ? 0 : -(objRelatedLineDetails.InvoiceLineRec.Credit_Memo_Applied_Amount__c);
                                    objCreditMemoLineItem.Invoice__c = objCreditMemo.id;
                                    objCreditMemoLineItem.Invoice_Line_Item__c = objRelatedLineDetails.InvoiceLineRec.id;
                                    objCreditMemoLineItem.Item_Reference__c = objRelatedLineDetails.InvoiceLineRec.Item_Reference__c;
                                    objCreditMemoLineItem.Line_Description__c = objRelatedLineDetails.InvoiceLineRec.Line_Description__c;
                                    objCreditMemoLineItem.Schools__c = objRelatedLineDetails.InvoiceLineRec.Schools__c;
                                    objCreditMemoLineItem.Department__c = objRelatedLineDetails.InvoiceLineRec.Department__c;
                                    objCreditMemoLineItem.Revenue_Type__c = objRelatedLineDetails.InvoiceLineRec.Revenue_Type__c;
                                    objCreditMemoLineItem.Course_Type__c = objRelatedLineDetails.InvoiceLineRec.Course_Type__c;
                                    objCreditMemoLineItem.Service_Type__c = objRelatedLineDetails.InvoiceLineRec.Service_Type__c;
                                    system.debug('objRelatedLineDetails.dAmount ---'+objRelatedLineDetails.dAmount);
                                    if(objRelatedLineDetails.dAmount <> null && objRelatedLineDetails.dAmount != 0){
                                        objCreditMemoLineItem.Amount__c = objRelatedLineDetails.dAmount > 0 ? objRelatedLineDetails.dAmount*-1 : objRelatedLineDetails.dAmount;
                                        objCreditMemoLineItem.Tax_Amount__c = 0;
                                        //oldLineItem.Credit_Memo_Applied_Amount__c = -(objRelatedLineDetails.InvoiceLineRec.Credit_Memo_Applied_Amount__c + objRelatedLineDetails.dAmount);
                                    }

                                    if(mapLines.get(objRelatedLineDetails.InvoiceLineRec.id) != null){
                                        objCreditMemoLineItem.Tax__c = mapLines.get(objRelatedLineDetails.InvoiceLineRec.id).Tax__c;
                                        Integer iTaxPercent = (Constants.SET_TAX_VALUES.contains(objCreditMemoLineItem.Tax__c) ? Constants.TAX_PERCENT : 0);
                                        objCreditMemoLineItem.Tax_Amount__c = (objCreditMemoLineItem.Amount__c != null ? (objCreditMemoLineItem.Amount__c*((decimal)iTaxPercent/100)) : 0);
                                    }

                                    //listMemoLines.add(oldLineItem);
                                    
                                    objCreditMemoLineItem.Item_Description__c = objRelatedLineDetails.InvoiceLineRec.Item_Description__c;
                                    listMemoLines.add(objCreditMemoLineItem);
                                } 
                                /*else if(mapOldLineItem <> null && mapOldLineItem.get(objRelatedLineDetails.InvoiceLineRec.id) <> null && !objRelatedLineDetails.isSelected) {
                                    //listLineItemToDelete.add(mapOldLineItem.get(objRelatedLineDetails.InvoiceLineRec.id));
                                    //Invoice_Line_Item__c oldLineItem = new Invoice_Line_Item__c();
                                   // oldLineItem.id =  objRelatedLineDetails.InvoiceLineRec.id;
                                    //oldLineItem.Applied_Status__c = '';
                                    
                                    listMemoLines.add(oldLineItem);
                                }*/
                            }                    
                        }
                        system.debug('listMemoLines---->'+listMemoLines);
                        if(listMemoLines.size() > 0) {
                            upsert listMemoLines;

                            for(Id objId : mapOldLineItem.keyset()) {
                                if(!selectLineIds.contains(objId))
                                    listLineItemToDelete.add(mapOldLineItem.get(objId));
                            }
                            if(listLineItemToDelete <> null && listLineItemToDelete.size() > 0) {
                                // delete old line item
                                delete listLineItemToDelete;
                            }
                            
                            //---------------------Add CM Applied Line ---------------------
                            
                            List<Invoice_Line_Item__c> appliedLine = [SELECT id from Invoice_Line_Item__c where Invoice__c =: ActualInvoice.id];
                            if(appliedLine.size() == 0){
                                Invoice_Line_Item__c newAppliedLine = new Invoice_Line_Item__c(recordtypeid = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Invoice_Line_Item').getRecordTypeId());
                                newAppliedLine.Amount__c = lineAmt;
                                newAppliedLine.Tax_Amount__c = taxAmt;
                                newAppliedLine.Invoice__c = ActualInvoice.id;
                                newAppliedLine.Related_Credit_Memo__c = objCreditMemo.id;
                                insert newAppliedLine;
                            }
                            
                            objResponseWrapper.MSG = 'success';
                            objResponseWrapper.invRec = objCreditMemo;
                        }else if(selectLineIds <> null && selectLineIds.size() > 0){
                            objResponseWrapper.MSG = 'success';
                            objResponseWrapper.invRec = objCreditMemo;
                            
                        } else {
                            objResponseWrapper.MSG = 'Please select at least one invoice';
                        }
                    } 
                }
            }
        } catch (Exception ex) {
           // Database.rollback( sp );
            objResponseWrapper.MSG = ex.getMessage();
            system.debug(ex.getMessage());
            system.debug(ex.getLineNumber());
            //objResponseWrapper.Invoice__c = objCreditMemo;
            //return ex.getMessage();
        }
        system.debug('objResponseWrapper------>'+objResponseWrapper);
        return objResponseWrapper;
    }
    
     
    
    /*
	Method Name : Get picklist value map
	Description : Used send pickist map for invoice type and item description
	*/
    @AuraEnabled
    public static List<string> getInvoiceRevenue (String accountId) {
        system.debug('accountId---->'+accountId);
        List<String> listInvoiceRevenue = new List<String>();
        if(accountId <> null && accountId <> '') {
            List<Account> listAcc = new List<Account>();
            listAcc = [select id, Operating_Unit__c from account where id = :accountId ];
            if(listAcc <> null && listAcc.size() > 0 && listAcc[0].Operating_Unit__c <> null)
            for(Operating_Unit__c objOperating_Unit : [SELECT id, Credit_Memo_Type__c FROM Operating_Unit__c WHERE id =: listAcc[0].Operating_Unit__c ]) {
                listInvoiceRevenue.add(objOperating_Unit.Credit_Memo_Type__c);
            }
        }
        
        system.debug('----->'+listInvoiceRevenue);
        return listInvoiceRevenue;
    }
    
    @AuraEnabled
    public static string pushMemoToOracle (String creditMemoId , Boolean isPushToOracle) {
        //if(!isPushToOracle) {
            List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting Credit Memo for approval ');
            system.debug('---->'+creditMemoId);
            req1.setObjectId(creditMemoId);
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
        /*}else {
            return CreditMemoUtil.pushToOracleCreditMemo(new List<String>{creditMemoId});
        }*/
        
        return 'Success';
        
    }
    
    
    @AuraEnabled
    public static Billing_Management_Setting__mdt fetchBillingManagementMDTDetail(){
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        system.debug('Profile Name'+profileName);
        return [SELECT Add_Invoice__c,Add_Receipt__c,Corporate_Customer__c,Credit_Memo__c,DeveloperName,Fund_Transfer__c,Id,Individual_Customer__c,Label,Default_OU__c,
        Language,MasterLabel,NamespacePrefix,QualifiedApiName,Refund_Request__c,Default_Source_System__c FROM Billing_Management_Setting__mdt WHERE Label =: profileName];
    }
    
    public class SavedCreditMemoWrapper {
        @AuraEnabled public Invoice__c objInv {get;set;}
        @AuraEnabled public List<RelatedInvoiceClass> listRelatedInvoices {get;set;}
        @AuraEnabled public List<RelatedInvoicLinesClass> listRelatedInvLine {get;set;}
        @AuraEnabled public List<Id> listOldLineId {get;set;}
        @AuraEnabled public sObject selectedEntity {get;set;}
        @AuraEnabled public sObject selectedInvoice {get;set;}
        @AuraEnabled public List<string> revenueDetail {get;set;}
        @AuraEnabled public Decimal inAmount {get;set;}
        @AuraEnabled public List<Invoice_Line_Item__c> listInvoiceLineItem {get;set;}
    }
    
    public class RelatedInvoiceClass{
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String Name {get;set;}
    } 
    
    public class RelatedInvoicLinesClass{
        @AuraEnabled public Invoice__c invoiceRec {get;set;}
        @AuraEnabled public List<RelatedLineDetails> listInvoiceLineRec {get;set;}
       /* public RelatedInvoicLinesClass() {
            listInvoiceLineRec = new List<RelatedLineDetails>();
        } */
    }
    
    public class RelatedLineDetails {
        @AuraEnabled public Invoice_Line_Item__c InvoiceLineRec {get;set;}
        @AuraEnabled public Boolean isSelected {get;set;}
        @AuraEnabled public Decimal dAmount {get;set;}
    }
    
    public class ResponseWrapper {
        @AuraEnabled public Invoice__c invRec {get;set;}
        @AuraEnabled public String MSG {get;set;}
    }
    
    
}