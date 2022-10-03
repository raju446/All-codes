/**
 * @File Name          : RefundRequestController.cls
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 11-11-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/22/2020   Jayanta Karmakar     Initial Version
**/

public without sharing class RefundRequestController {
    
    /*
	Method Name : fetchReceiptPicklistVal
	Description : Used to fetch Receipt Picklist Values
	*/
    @AuraEnabled  
    public static List<LEX_Helper.PicklistValueWrapper> fetchPicklistVal(String objectApi,String fieldAPIname, Boolean nullRequired) {
        return LEX_Helper.getPicklistValues(objectApi, fieldAPIname, nullRequired);
    }//end fetchReceiptPicklistVal()
    
    
    @AuraEnabled
    public static string submitForApproval(String fundTransferId) {
        if(fundTransferId <> null && fundTransferId <> '') {
            List<Fund_Transfer__c> listFundTransfer= new List<Fund_Transfer__c>();
            listFundTransfer = [SELECT Id, Status__c FROM Fund_Transfer__c WHERE id = :fundTransferId ];
            if(listFundTransfer <> null && listFundTransfer.size() > 0 && (listFundTransfer[0].Status__c == 'Draft' || listFundTransfer[0].Status__c == 'Rejected')) {
                List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting Fund Transfer for approval ');
                
                req1.setObjectId(fundTransferId);
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
            } else if(listFundTransfer <> null && listFundTransfer.size() > 0 && listFundTransfer[0].Status__c == 'Under Review') {
                return 'Record is already submitted for approval';
            } else if(listFundTransfer <> null && listFundTransfer.size() > 0 && (listFundTransfer[0].Status__c == 'Invoiced' || listFundTransfer[0].Status__c == 'Approved' )) {
                return 'Record is already processed';
            }
        }
        
        
        return 'Record not found';
    }
    
    @AuraEnabled
    public static SavedFundTransferwrapper getOldData(String fundTransferId){
        SavedFundTransferwrapper objOldData = new SavedFundTransferwrapper();
        List<Fund_Transfer__c> listFund_Transfer = new List<Fund_Transfer__c>();
        listFund_Transfer = [select id, Scenario__c, From_Entity__c, To_Entity__c, From_Currency__c, To_Currency__c, Amount__c, Description__c,FromOU__c,ToOU__c,To_Source_System__c,From_Source_System__c,
                             		From_Entity__r.Parent.Id, From_Entity__r.Parent.Name, Reference_Receipt__c, Reference_Receipt__r.Name,Pushed_To_Oracle__c
                             from Fund_Transfer__c 
                             where id =: fundTransferId];
        if(listFund_Transfer <> null && listFund_Transfer.size() > 0) {
            objOldData.objFund_Transfer = listFund_Transfer[0];
            if(listFund_Transfer[0].From_Entity__c <> null && listFund_Transfer[0].From_Entity__r.ParentId <> null) {
                List<Account> listEntity = new List<Account>();
                listEntity = [select id, Name from account where id =: listFund_Transfer[0].From_Entity__r.ParentId] ; 
                if(listEntity <> null && listEntity.size() > 0) {
                     objOldData.selectedGoldenEntity = listEntity[0];
                }
            }
            
            if(listFund_Transfer[0].Reference_Receipt__c <> null) {
                List<Receipt__c> listReceipt = new List<Receipt__c>();
                listReceipt = [select id, Lookup_Search_Field__c from Receipt__c where id =: listFund_Transfer[0].Reference_Receipt__c] ; 
                if(listReceipt <> null && listReceipt.size() > 0) {
                     objOldData.selectedReceipt = listReceipt[0];
                }
            }
            
            if(listFund_Transfer[0].Scenario__c == 'Unidentified customer balance transfer'){
                List<Account> listFromEntity = new List<Account>();
                listFromEntity = [select id, Entity_Search_Field__c from account where id =: listFund_Transfer[0].From_Entity__c] ; 
                if(listFromEntity <> null && listFromEntity.size() > 0) {objOldData.selectedFromEntity = listFromEntity[0];}
                
                List<Account> listToEntity = new List<Account>();
                listToEntity = [select id, Entity_Search_Field__c from account where id =: listFund_Transfer[0].To_Entity__c] ; 
                if(listToEntity <> null && listToEntity.size() > 0) {objOldData.selectedToEntity = listToEntity[0];}
            } else {
                List<Account> listFromEntity = new List<Account>();
                listFromEntity = [select id, Name from account where id =: listFund_Transfer[0].From_Entity__c] ; 
                if(listFromEntity <> null && listFromEntity.size() > 0) {
                     objOldData.selectedFromEntity = listFromEntity[0];
                }
                
                List<Account> listToEntity = new List<Account>();
                listToEntity = [select id, Name from account where id =: listFund_Transfer[0].To_Entity__c] ; 
                if(listToEntity <> null && listToEntity.size() > 0) {
                     objOldData.selectedToEntity = listToEntity[0];
                }
            }
        }
        
        
        return objOldData;
    }
    
    /*
	Method Name : pushFundToOracle
	Description : Used to create Refund Receipt record
	*/
    @auraEnabled
    public static String pushFundToOracle (String sFundTransferId){ 
        
    	return BalanceTransferUtil.pushBalaceTransferToOracle(sFundTransferId);
    }
    
    @auraEnabled
    public static Fund_Transfer__c getRecordDetail (String sFundTransferId){ 
        return [select id,status__c from Fund_Transfer__c WHERE id =: sFundTransferId];
    }
    
    @AuraEnabled
    public static Account fetchUnidentifiedEntityDetails(String entityId){
        return [SELECT Id,RecordtypeId from Account WHERE Id =: entityId LIMIT 1];        
    }
    
    @AuraEnabled
    public static Account fetchFromEntityDetails(String entityId){
        return [SELECT Id,RecordtypeId,ParentId from Account WHERE Id =: entityId LIMIT 1];        
    }
    
    
    @AuraEnabled
    public static List<Account> fetchChildAccounts(String goldenEntityId, Boolean isOnlyRegistered){
        system.debug(goldenEntityId);
        system.debug(isOnlyRegistered);
        if(goldenEntityId != null && goldenEntityId != ''){
            if(isOnlyRegistered){
                return [SELECT Id,Name,recordtype.Name,Record_Type_Name__c,Source_System_Name__c from Account WHERE parentid =: goldenEntityId AND Recordtype.Name IN ('ADGM Registered Company')]; //'ADGM Guest', 
            } else {
                return [SELECT Id,Name,recordtype.Name,Record_Type_Name__c,Source_System_Name__c from Account WHERE parentid =: goldenEntityId];    
            }
        }
        return new List<Account>();
	}
	
	@AuraEnabled
    public static FundTransferResponse saveFundTransfer(Fund_Transfer__c ftObj, String currencyScenario, String ouScenario, List<AttachmentWrapper> attachmentFiles){
		try{
            Map<String, Receipt__c> receiptMap = new Map<String,Receipt__c>();  
            Decimal tAmount = ftObj.Amount__c;
            if(ftObj.From_Currency__c == 'AED' && ftObj.To_Currency__c == 'USD'){tAmount = ftObj.Amount__c / 3.6725;
            } else if(ftObj.From_Currency__c == 'USD' && ftObj.To_Currency__c == 'AED'){tAmount = ftObj.Amount__c * 3.6725;
            }
            
            ftObj.Currency_Scenario__c = currencyScenario;
            ftObj.Operating_Unit_Scenario__c = ouScenario;
            
            if(currencyScenario == 'Funds Transfer in same currency' && ouScenario == 'Same Operating Unit'){
                ftObj.Scenario__c = 'One customer to another customer balance transfer - Same OU';
            }else if(currencyScenario == 'Funds Transfer in different currency' && ouScenario == 'Same Operating Unit'){
                ftObj.Scenario__c = 'Payment in one currency and services in other currency | Same OU';
            }else if(currencyScenario == 'Funds Transfer in same currency' && ouScenario == 'Different Operating Unit'){
                ftObj.Scenario__c = 'Payment to one Authority and service from other Authority';
            }else if(currencyScenario == 'Funds Transfer in different currency' && ouScenario == 'Different Operating Unit'){
                ftObj.Scenario__c = 'Payment in one currency and services in other currency | Different OU';
            }
            
            
            List<Fund_Transfer__c> fundTransferList = [SELECT Id FROM Fund_Transfer__c WHERE Reference_Receipt__c = :ftObj.Reference_Receipt__c];
            Integer numberOfFundTransfer = 0;
            if(!fundTransferList.isEmpty()){
                numberOfFundTransfer = fundTransferList.size();
            }
            numberOfFundTransfer++;
            //Transaction_Type__c='Wallet',
            Receipt__c rp = [SELECT Id,Payment_Method__c,Transaction_type__C,Authorization_Code__c,Receipt_Reference__c,EFT_Reference_No__c,Transaction_Reference__c from Receipt__c WHERE ID =: ftObj.Reference_Receipt__c];
            String transRef = '';
            if(rp.Payment_Method__c.contains('Card') && rp.Authorization_Code__c != null){
                transRef = rp.Authorization_Code__c;
                if([SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox){
                    Integer randomNumber = Integer.valueof((Math.random() * 10000));
                    transRef = transRef+rp.Receipt_Reference__c;
                }
            } else if(rp.Payment_Method__c == 'Electronic Funds Transfer' && rp.EFT_Reference_No__c != null){transRef = rp.EFT_Reference_No__c;
            }else {
                transRef = rp.Transaction_Reference__c;
            }
            transRef = transRef +'-FT' + '-' + numberOfFundTransfer;
            //enhancement: do not create from receipt.
			//receiptMap.put('fromReceipt', new Receipt__c(Entity__c = ftObj.From_Entity__c, Amount__c = (ftObj.Amount__c * -1),Payment_Method__c = 'Cash',Payment_Currency__c = ftObj.From_Currency__c,Receipt_Type__c='Fund Transfer',Receipt_Date__c=Date.today()));
            receiptMap.put('toReceipt', new Receipt__c(Entity__c = ftObj.To_Entity__c, Amount__c = tAmount,Payment_Currency__c = ftObj.To_Currency__c,
                                                        Receipt_Type__c='Fund Transfer',Receipt_Date__c=Date.today(),Status__c = 'Success',Payment_Method__c = rp.Payment_Method__c,
                                                        Transaction_Reference__c=transRef,Transaction_type__C = rp.Transaction_type__C, GL_Date__c = ftObj.GL_Date__c));
            if(ftObj.Id != null){
                Fund_Transfer__c ftrec = [SELECT Id,From_Receipt__c,To_Receipt__c FROM Fund_Transfer__c WHERE Id =: ftObj.Id];
                //receiptMap.get('fromReceipt').Id = ftrec.From_Receipt__c;
                receiptMap.get('toReceipt').Id = ftrec.To_Receipt__c; 
            }
			upsert receiptMap.values();

			//ftObj.From_Receipt__c = receiptMap.get('fromReceipt').Id;
			ftObj.To_Receipt__c = receiptMap.get('toReceipt').Id;

            upsert ftObj;
            
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

                if(conVersions.size() > 0){
                    insert conVersions;
                    List<ContentVersion> insertedCV = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :conVersions];
                    List<ContentDocumentLink> contentDocToInsert = new List<ContentDocumentLink>();
                    for(ContentVersion eachCV : insertedCV){
                        ContentDocumentLink contentLink = new ContentDocumentLink();
                        contentLink.ContentDocumentId = eachCV.ContentDocumentId;
                        contentLink.LinkedEntityId = ftObj.Id; 
                        contentLink.ShareType = 'I'; // Inferred permission
                        contentLink.Visibility = 'AllUsers';
                        contentDocToInsert.add(contentLink);
                    }
                    if(contentDocToInsert.size() > 0){
                        insert contentDocToInsert;
                    }
                }        
            }
            
            return new FundTransferResponse(true, ftObj.Id);
		} catch(Exception e){
            return new FundTransferResponse(false, e.getMessage());
		}
    }

    public class FundTransferResponse{
        @AuraEnabled public string message;
        @AuraEnabled public Boolean isSuccess;
        public FundTransferResponse(Boolean succ, String msg){
            isSuccess = succ;
            message = msg;
        }
    }

    @AuraEnabled
    public static Receipt__c fetchReceiptBalance(String receiptId){
        return [SELECT Id,Receipt_Balance__c,Payment_Currency__c,Remaning_Amount__c From Receipt__c WHERE Id =: receiptId];
    }

    /*
	Method Name : createRefundReceipt
	Description : Used to create Refund Receipt record
	*/
  /*  @auraEnabled
    public static wrapperClass createRefundReceipt (Receipt__c objRefundReceipt, String fileName, String base64Data){
        wrapperClass returnwrapperClass = new  wrapperClass ();
        String message;
        objRefundReceipt = prepareReceipt(objRefundReceipt, 'Refund Request', false);
        try{
            insert objRefundReceipt;
            message = 'success';
            
        }catch(exception e){
            system.debug(e.getMessage());
            message =  e.getMessage();
        }
        
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; 
        conVer.PathOnClient = fileName; 
        conVer.Title = 'Bank Account Confirmation : ' + fileName; 
        conVer.VersionData = EncodingUtil.base64Decode(base64Data); 
        insert conVer;
        
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        
        //Create ContentDocumentLink
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = objRefundReceipt.id; 
        cDe.ShareType = 'I'; 
        cDe.Visibility = 'InternalUsers';
        insert cDe;
        
        returnwrapperClass.returnMessage = message;
        returnwrapperClass.returnID = objRefundReceipt.id;
        
        return returnwrapperClass;
        
    } */
    
    /*
	Method Name : createRefundReceipt
	Description : Used to create fund transfer Receipt record
	*/
   /* @auraEnabled
    public static wrapperClass createReceipt (String fromAccId,String toAccId, Receipt__c objRefundTransfer) {
        String message;
        wrapperClass returnwrapperClass = new  wrapperClass ();
        Receipt__c fromAccountReceipt = new Receipt__c ();
        Receipt__c toAccountReceipt = new Receipt__c ();
        Fund_Transfer_Details__c objFundTransferDetails = new Fund_Transfer_Details__c();
        objFundTransferDetails.From_Company__c = fromAccId;
        objFundTransferDetails.To_Company__c = toAccId;
        try{
            if(objFundTransferDetails <> null ) {
                insert objFundTransferDetails;
            }
            
            List<Receipt__c> listFundTransfer = new list<Receipt__c>();
            fromAccountReceipt = objRefundTransfer.clone();
            fromAccountReceipt.Entity__c = fromAccId;
            fromAccountReceipt.Fund_Transfer_Detail__c = objFundTransferDetails.id;
            listFundTransfer.add(prepareReceipt(fromAccountReceipt, 'Fund Transfer', true));
            
            
            
            toAccountReceipt = objRefundTransfer.clone();
            toAccountReceipt.Entity__c = toAccId;
            toAccountReceipt.Fund_Transfer_Detail__c = objFundTransferDetails.id;
            listFundTransfer.add(prepareReceipt(toAccountReceipt, 'Fund Transfer', false));
            
            try{
                if(listFundTransfer <> null && listFundTransfer.size() > 0) {
                    insert listFundTransfer;
                }
                
                message =  'success';
                
            }catch(exception e){
                system.debug(e.getMessage());
                message = e.getMessage();
                
            }
            
        }catch(exception e){
            system.debug(e.getMessage());
            message = e.getMessage();
            
        }
        returnwrapperClass.returnMessage = message;
        returnwrapperClass.returnID = toAccountReceipt.id;
        return returnwrapperClass;
    } */
    
    /*
	Method Name : createMemoReceipt
	Description : Used to create credit memo Receipt record
	*/
/*    @auraEnabled
    public static wrapperClass createMemoReceipt (Receipt__c objcreateMemo){
        
        wrapperClass returnwrapperClass = new  wrapperClass ();
        String message;
        system.debug('---->'+objcreateMemo);
        objcreateMemo = prepareReceipt(objcreateMemo, 'Credit Memo', false);
                
        try{
            insert objcreateMemo ;
            message =  'success';
            
        }catch(exception e){
            system.debug(e.getMessage()); 
            message = e.getMessage();
        }
        
        returnwrapperClass.returnMessage = message;
        returnwrapperClass.returnID = objcreateMemo.id;
        
        return returnwrapperClass;
    }*/
    
    /*
	Method Name : prepareReceipt
	Description : Used to prepare Receipt record
	*/
  /*  public static Receipt__c prepareReceipt (Receipt__c objRefundReceipt, String sReceiptType, boolean isFrom) {
        Receipt__c objReceipt = new Receipt__c();
        objReceipt = objRefundReceipt;
        objReceipt.Status__c	= 'Draft';
        objReceipt.Receipt_Type__c = sReceiptType;
        objReceipt.Refund_Receipt_Date__c   = system.today();
        if( sReceiptType == 'Refund Request' && objReceipt.Amount__c <> null) {
            objReceipt.Amount__c	= -objReceipt.Amount__c;
        }else if(sReceiptType == 'Fund Transfer' && isFrom && objReceipt.Amount__c <> null) {
            objReceipt.Amount__c	= -objReceipt.Amount__c;
        } else  {
            objReceipt.Amount__c	= objReceipt.Amount__c;
        } 
        return objReceipt;
    } */
    
    public class SavedFundTransferwrapper {
        @AuraEnabled public Fund_Transfer__c objFund_Transfer {get;set;}
        @AuraEnabled public sObject selectedGoldenEntity {get;set;}
        @AuraEnabled public sObject selectedReceipt {get;set;}
        @AuraEnabled public sObject selectedFromEntity {get;set;}
        @AuraEnabled public sObject selectedToEntity {get;set;}
    }
      
   /* public class wrapperClass{
        @AuraEnabled public String returnMessage{get;set;}
        @AuraEnabled public String returnID{get;set;}
        
    }  */
    
    public class AttachmentWrapper {
        @AuraEnabled public String fileName {get;set;}
        @AuraEnabled public String blobval {get;set;} 
        @AuraEnabled public Boolean isUploaded {get;set;}
    }
}