/***
	Name 	  	:	UpdateInvoiceReceiptEntityController
	Author		:	prateek.b.bansal@pwc.com
	CreatedDate	:	20 Apr 2021
	Description	:	This class we are using to update entity of invoice and receipt.
***/
public class UpdateInvoiceReceiptEntityController {
	@AuraEnabled
    public static ResponseWrapper updateInvoiceReceiptEntity(String objectType, String invoiceReceiptId, String entityToUpdate, String invoiceReceiptName, String newEntityName, String oldEntityName){
        
        try{
            system.debug('oldEntity==>>' + oldEntityName);
            ResponseWrapper respWrapper = new ResponseWrapper();
            InvoiceReceiptWrapper updatedInvoiceReceiptWrapList = new InvoiceReceiptWrapper();
            updatedInvoiceReceiptWrapList.newEntityId = newEntityName;
            updatedInvoiceReceiptWrapList.oldEntityId = oldEntityName;
            updatedInvoiceReceiptWrapList.invoiceReceiptName = invoiceReceiptName;
            if(objectType == 'Invoice'){
                Invoice__c invObj = new Invoice__c(Id = invoiceReceiptId, Entity__c = entityToUpdate);
                UPDATE invObj;
            }else if(objectType == 'Receipt'){
                Receipt__c recObj = new Receipt__c(Id = invoiceReceiptId, Entity__c = entityToUpdate);
                UPDATE recObj;
            }
            respWrapper.message = 'Record Updated Successfully';
            respWrapper.wrapper = updatedInvoiceReceiptWrapList;
            return respWrapper;
           
        }catch(Exception ex){
            ResponseWrapper respWrapper = new ResponseWrapper();
            respWrapper.message = ex.getMessage();
            return respWrapper;
        }  
    }
    
    public static String checkObjectType(Id salesforceId){
        Map<String,String> keys = new Map<String,String>();
        Map<String,Schema.SobjectType> describe = Schema.getGlobalDescribe();
        for(String s:describe.keyset()){
        	keys.put(describe.get(s).getDescribe().getKeyPrefix(),s);    
        }
        if(keys.containsKey(String.valueOf(salesforceId).substring(0,3))){
            system.debug('sOBject==>>' + keys.get(String.valueOf(salesforceId).substring(0,3)));
            return keys.get(String.valueOf(salesforceId).substring(0,3));
        }else{
            return null;
        }
    }
    
    public class ResponseWrapper{
        @AuraEnabled
        public String message;
        @AuraEnabled
        public InvoiceReceiptWrapper wrapper;
    }
    
    public class InvoiceReceiptWrapper{
        @AuraEnabled
        public String invoiceReceiptName;
        @AuraEnabled
        public String oldEntityId;
        @AuraEnabled
        public String newEntityId;
    }
    
    @AuraEnabled
    public static ResponseWrapper getSelectedObjectDetails(String objectType, String invoiceReceiptId){
        try{
            InvoiceReceiptWrapper updatedInvoiceReceiptWrapList = new InvoiceReceiptWrapper();
            ResponseWrapper respWrapper = new ResponseWrapper();
            
            Id invRecId = invoiceReceiptId; 
        	String invoiceReceiptObj = checkObjectType(invRecId);
            if(String.isNotBlank(objectType) && invoiceReceiptObj.containsIgnoreCase(objectType)){
                if(objectType == 'Invoice'){
                    List<Invoice__c> invLst = [SELECT Id, Name, Entity__r.Name FROM Invoice__c WHERE Id = :invoiceReceiptId LIMIT 1];
                    
                    if(!invLst.isEmpty()){
                        Invoice__c invObj = invLst[0];
						InvoiceReceiptWrapper wrapper = new InvoiceReceiptWrapper();
						wrapper.invoiceReceiptName = invObj.Name;
                        wrapper.oldEntityId = invObj.Entity__r.Name;
                        updatedInvoiceReceiptWrapList = wrapper;
                    }else{
                        respWrapper.message = 'No related Invoice record found.';
                    	return respWrapper;
                    }
                }else if(objectType == 'Receipt'){
                    List<Receipt__c> recLst = [SELECT Id, Name, Entity__r.Name FROM Receipt__c WHERE Id = :invoiceReceiptId LIMIT 1];
                    if(!recLst.isEmpty()){
                        Receipt__c recObj = recLst[0];
						InvoiceReceiptWrapper wrapper = new InvoiceReceiptWrapper();
						wrapper.invoiceReceiptName = recObj.Name;
                        wrapper.oldEntityId = recObj.Entity__r.Name;
                        updatedInvoiceReceiptWrapList = wrapper;
                    }else{
                        respWrapper.message = 'No related Receipt record found.';
                    	return respWrapper;
                    }
                }
                respWrapper.message = 'Success';
                respWrapper.wrapper = updatedInvoiceReceiptWrapList;
                return respWrapper;
            }else if(!invoiceReceiptObj.containsIgnoreCase(objectType)){
                respWrapper.message = (objectType + ' Id is not correct');
            	return respWrapper;
            }else{
                respWrapper.message = 'Please check with your administrator';
            	return respWrapper;
            }
        }catch(Exception ex){
            ResponseWrapper respWrapper = new ResponseWrapper();
            respWrapper.message = ex.getMessage();
            return respWrapper;
        }
    }
    
    @AuraEnabled
    public static ResponseWrapper fetchAccountDetails(String entityIdToUpdate){
        try{
			ResponseWrapper respWrapper = new ResponseWrapper();
            InvoiceReceiptWrapper updatedInvoiceReceiptWrapList = new InvoiceReceiptWrapper();
            Id entityId = entityIdToUpdate;
            String entityObj = checkObjectType(entityId);
            if(entityObj == 'Account'){
                List<Account> accLst = [SELECT Id, Name FROM Account WHERE Id = :entityId LIMIT 1];
                String newAccountName = '';
                if(!accLst.isEmpty()){
                    newAccountName = accLst[0].Name;
                    InvoiceReceiptWrapper wrapper = new InvoiceReceiptWrapper();
                    wrapper.newEntityId = newAccountName;
                    updatedInvoiceReceiptWrapList = wrapper;
                    
                    respWrapper.message = 'Success';
                	respWrapper.wrapper = updatedInvoiceReceiptWrapList;
                	return respWrapper;
                }else{
                    respWrapper.message = 'No related Account record found.';
                    return respWrapper;
                }
            }else{
                respWrapper.message = 'Entity Id is not correct';
                return respWrapper;
            }
        }catch(Exception ex){
            ResponseWrapper respWrapper = new ResponseWrapper();
            respWrapper.message = ex.getMessage();
            return respWrapper;
        }
    }
}