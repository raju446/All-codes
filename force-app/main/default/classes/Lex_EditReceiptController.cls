/**
 * @File Name          : Lex_EditReceiptController.cls
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 4/21/2020, 4:25:22 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/4/2020      Jayanta Karmakar     Initial Version
 * 2.0    13/Oct/2021   Prateek Bansal       update upsertRelatedInvoiceReceipt method to apply and unapply receipt
**/
public class Lex_EditReceiptController {
    @AuraEnabled
    public static Receipt__c fetchReceiptDetails(String receiptId){
        return [select id,name,Entity__c,Payment_Currency__c,Remaning_Amount__c,conversion_rate__c, Oracle_Receipt_Id__c,Amount__c,(select id,Amount_Applied__c,Invoice__r.Oracle_Invoice_Id__c,Invoice__r.Source_Invoice_Id__c,Invoice__c,Applied_Date__c FROM Related_Invoices__r WHERE Applied__c = true) from Receipt__c where Id =: receiptId];
    }
	
    @AuraEnabled
    public static String upsertRelatedInvoiceReceipt(Receipt__c receiptObjct, String relatedListString){
        try{
            System.debug(relatedListString);
            System.debug(receiptObjct);
            System.debug(receiptObjct.Related_Invoices__r);
            /*List<RelatedInvRecClass> relatedList = new List<RelatedInvRecClass>();
            relatedList = (List<RelatedInvRecClass>)JSON.deserialize(relatedListString, List<RelatedInvRecClass>.class);
            System.debug(relatedList);
            Map<Id,Related_Invoice_Receipt__c> invVsRIRMap = new Map<Id,Related_Invoice_Receipt__c>();
            //receiptObjct.Related_Invoices__r
            for(Related_Invoice_Receipt__c eachRecord : [SELECT Id,Invoice__c,Amount_Applied__c FROM Related_Invoice_Receipt__c WHERE Receipt__c =: receiptObjct.Id]){
                invVsRIRMap.put(eachRecord.Invoice__c, eachRecord);
            }
            Set<Id> invoiceIds = new Set<Id>();
            List<Related_Invoice_Receipt__c> recordsToDelete = new List<Related_Invoice_Receipt__c>();
            for(RelatedInvRecClass eachObj : relatedList){
                invoiceIds.add(eachObj.invoiceId);
                System.debug(invVsRIRMap.containskey(eachObj.invoiceId));
                if(invVsRIRMap.containskey(eachObj.invoiceId)){
                    invVsRIRMap.get(eachObj.invoiceId).Amount_Applied__c = eachObj.Amount;
                }else {
                    invVsRIRMap.put(eachObj.invoiceId, new Related_Invoice_Receipt__c(Receipt__c = receiptObjct.Id, Invoice__c = eachObj.invoiceId,Amount_Applied__c= eachObj.Amount, Direction__c = 'From Receipt To Invoice',Applied_Date__c=Date.valueof(eachObj.AppliedDate)));
                }
            }
            Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>([SELECT id,Invoice_Balance__c from Invoice__c WHERE Id IN : invVsRIRMap.keySet()]);
            List<Invoice__c> invoiceToUpdate = new List<Invoice__c>();
            for(Id eachInvoiceId : invVsRIRMap.keySet()){
                if(! invoiceIds.contains(eachInvoiceId)){
                    recordsToDelete.add(invVsRIRMap.get(eachInvoiceId));
                    invoiceToUpdate.add(new Invoice__c(Id=eachInvoiceId,Invoice_Balance__c = invoiceMap.get(eachInvoiceId).Invoice_Balance__c + invVsRIRMap.get(eachInvoiceId).Amount_Applied__c));
                }
            }
            System.debug(invVsRIRMap.keyset());
            System.debug(invVsRIRMap.values());
            List<Id> relInvRecptId = new List<Id>();
            if(invVsRIRMap.values().size() > 0){
                upsert invVsRIRMap.values();
                System.debug('after insert==invVsRIRMap.values()===='+invVsRIRMap.values());
                for (Related_Invoice_Receipt__c ri : invVsRIRMap.values()){relInvRecptId.add(ri.Id);}
            }
            //Added for JE entry creation
            System.debug(relInvRecptId);
            if(relInvRecptId.size() > 0){
                BM_JournalEntryEngine.receiptApplicationJournalLines(relInvRecptId);
            }

            System.debug(recordsToDelete);
            if(recordsToDelete.size() > 0){
                delete recordsToDelete;
            }
            
            system.debug(invoiceToUpdate);
            if(invoiceToUpdate.size() > 0){
                update invoiceToUpdate;
            }
            ReceiptUtil.PushReceiptToOracle_Future_New(new List<String>{receiptObjct.Id});*/
            /*2.0*/
            List<RelatedInvRecClass> updatedApplications = new List<RelatedInvRecClass>();
            updatedApplications = (List<RelatedInvRecClass>)JSON.deserialize(relatedListString, List<RelatedInvRecClass>.class);
			            
            Map<Id,Related_Invoice_Receipt__c> allExistingInvoiceApplicationMap = new Map<Id,Related_Invoice_Receipt__c>();
            Map<Id,Related_Invoice_Receipt__c> newInvoiceApplicationMap = new Map<Id,Related_Invoice_Receipt__c>();
            //receiptObjct.Related_Invoices__r
            for(Related_Invoice_Receipt__c eachRecord : [SELECT Id,Invoice__c,Amount_Applied__c, Applied__c FROM Related_Invoice_Receipt__c WHERE Receipt__c =: receiptObjct.Id AND Applied__c = true]){
                allExistingInvoiceApplicationMap.put(eachRecord.Invoice__c, eachRecord);
            }
            Map<Id,Decimal> invoiceAppliedMap = new Map<Id, Decimal>();
            Map<Id,Decimal> invoiceUnAppliedMap = new Map<Id, Decimal>();
            Set<Id> invoiceIds = new Set<Id>();
            List<Related_Invoice_Receipt__c> recordsToUpdate = new List<Related_Invoice_Receipt__c>();
            for(RelatedInvRecClass eachObj : updatedApplications){
                invoiceIds.add(eachObj.invoiceId);
                Decimal receiptRemainingAmount = receiptObjct.Remaning_Amount__c;
                if(!allExistingInvoiceApplicationMap.containskey(eachObj.invoiceId)){
                    invoiceAppliedMap.put(eachObj.invoiceId, eachObj.Amount);
                    //newInvoiceApplicationMap.put(eachObj.invoiceId, new Related_Invoice_Receipt__c(Receipt__c = receiptObjct.Id, Invoice__c = eachObj.invoiceId,Amount_Applied__c= eachObj.Amount, Oracle_Unapplied_Amount__c = receiptObjct.Remaning_Amount__c - eachObj.Amount,Direction__c = 'From Receipt To Invoice',Applied_Date__c=Date.valueof(eachObj.AppliedDate), Applied__c = true));
                	Related_Invoice_Receipt__c application = new Related_Invoice_Receipt__c();
                    application.Receipt__c = receiptObjct.Id;
                    application.Invoice__c = eachObj.invoiceId;
                    application.Amount_Applied__c = eachObj.Amount;
                    application.Oracle_Applied_Amount__c = eachObj.Amount;
                    //application.Oracle_Unapplied_Amount__c = receiptRemainingAmount - eachObj.Amount;
                    //receiptRemainingAmount = receiptRemainingAmount - eachObj.Amount;
                    application.Direction__c = 'From Receipt To Invoice';
                    application.Applied_Date__c=Date.valueof(eachObj.AppliedDate); 
                    application.Applied__c = true;
                    application.Journal_Created__c = true;
                    application.GL_Date__c = application.Applied_Date__c;
                    if(receiptObjct.Payment_Currency__c == 'USD'){
                        //application.Oracle_Converted_Applied_Amount__c = eachObj.Amount * receiptObjct.Conversion_Rate__c;
                    	//application.Oracle_Converted_UnApplied_Amount__c = (receiptObjct.Remaning_Amount__c - eachObj.Amount) * receiptObjct.Conversion_Rate__c;
                    }else{
                        //application.Oracle_Converted_Applied_Amount__c = eachObj.Amount * receiptObjct.Conversion_Rate__c;
                    	//application.Oracle_Converted_UnApplied_Amount__c = (receiptObjct.Remaning_Amount__c - eachObj.Amount) * receiptObjct.Conversion_Rate__c;
                    }
                    newInvoiceApplicationMap.put(eachObj.invoiceId,application);
                }
            }
            
            
            Map<Id,Invoice__c> invoiceMap = new Map<Id,Invoice__c>([SELECT id,Invoice_Balance__c, Converted_Invoice_Balance__c, Payment_Currency__c, conversion_rate__c from Invoice__c WHERE Id IN : allExistingInvoiceApplicationMap.keySet()]);
            List<Invoice__c> invoiceToUpdate = new List<Invoice__c>();
            for(Id eachInvoiceId : allExistingInvoiceApplicationMap.keySet()){
                if(!invoiceIds.contains(eachInvoiceId)){Related_Invoice_Receipt__c tempApp = allExistingInvoiceApplicationMap.get(eachInvoiceId);tempApp.Applied__c = false;tempApp.Oracle_Applied_Amount__c = null;recordsToUpdate.add(tempApp);
                    invoiceToUpdate.add(new Invoice__c(Id=eachInvoiceId,Invoice_Balance__c = invoiceMap.get(eachInvoiceId).Invoice_Balance__c + allExistingInvoiceApplicationMap.get(eachInvoiceId).Amount_Applied__c,
                                       					Converted_Invoice_Balance__c = invoiceMap.get(eachInvoiceId).Converted_Invoice_Balance__c + (invoiceMap.get(eachInvoiceId).payment_currency__c == 'AED' ? allExistingInvoiceApplicationMap.get(eachInvoiceId).Amount_Applied__c :
                                       					allExistingInvoiceApplicationMap.get(eachInvoiceId).Amount_Applied__c * invoiceMap.get(eachInvoiceId).conversion_rate__c)));
                }
            }
            
            if(newInvoiceApplicationMap != null && newInvoiceApplicationMap.keySet().size() > 0){
                List<Id> relInvRecptId = new List<Id>();
                INSERT newInvoiceApplicationMap.values();
                if(invoiceAppliedMap.keySet().Size() > 0){
                    List<Invoice__c> invoiceList = new List<Invoice__c>();
                    for(Invoice__c invObj : [SELECT Id, Invoice_Balance__c, Converted_Invoice_Balance__c, Payment_Currency__c, Conversion_Rate__c FROM Invoice__c WHERE Id IN : invoiceAppliedMap.keySet()]){
                        invObj.Invoice_Balance__c = invObj.Invoice_Balance__c - invoiceAppliedMap.get(invObj.Id);
                        invObj.Converted_Invoice_Balance__c = invObj.Converted_Invoice_Balance__c - (invObj.payment_currency__c == 'AED' ? invoiceAppliedMap.get(invObj.Id) : invoiceAppliedMap.get(invObj.Id) * invObj.conversion_rate__c);
                        invoiceList.add(invObj);
                    }
                    if(!invoiceList.isEmpty()){UPDATE invoiceList;}
                }
                for (Related_Invoice_Receipt__c ri : newInvoiceApplicationMap.values()){relInvRecptId.add(ri.Id);}
                if(relInvRecptId.size() > 0){BM_JournalEntryEngine.receiptApplicationJournalLines(relInvRecptId);}
            }
            
            if(!recordsToUpdate.isEmpty()){
                UPDATE recordsToUpdate;UPDATE invoiceToUpdate;List<Id>  createReverseEntry = new List<Id>();
                for(Journal_Header__c jhRecord : [SELECT Id, Related_Invoice_Receipt__c FROM Journal_Header__c WHERE Related_Invoice_Receipt__c IN : recordsToUpdate AND Transaction_Type__c = 'Apply Receipt']){
                    createReverseEntry.add(jhRecord.Id);
                }
                if(!createReverseEntry.isEmpty()){BM_JournalEntryEngine.journalEntryCreationForHeaderReversal(createReverseEntry, 'Unapply Receipt');}
            }
            
            return 'SUCCESS';
        } catch(Exception e){
            System.debug(e.getMessage());
            system.debug(e.getLineNumber());
            return e.getMessage();
        }
    }

    public class RelatedInvRecClass{
        @AuraEnabled public String invoiceNo;
        @AuraEnabled public String invoiceId;
        @AuraEnabled public Decimal Amount;
        @AuraEnabled public Decimal invoiceBalAmt;
        @AuraEnabled public String AppliedDate;
    }
}