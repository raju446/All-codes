/*
Author      :   Azmath
Class Name  :   BillingManagementUtil
*/
public class BillingManagementUtil {
	/*Method Name : CancelCreditMemo
	Description : Used to cancel the selected CM*/
    @AuraEnabled
    public static cancelInvoiceclass CancelCreditMemo(String recordId){
        cancelInvoiceclass wr = new cancelInvoiceclass();
        try{
            Invoice__c inv = [Select id, Name, Status__c, Invoice_Balance__c, Total_Invoice_Amount_Rollup__c FROM Invoice__c where id=:recordId];
            if(inv.Status__c == 'Draft'){
                inv.Status__c = 'Cancelled';
                inv.Invoice_Balance__c = 0;
                update inv;
				
                wr.message 		= 'Credit Memo Cancelled Successfully.';
                wr.isCancelled 	= true;
            } else if((inv.Invoice_Balance__c != null && inv.Total_Invoice_Amount_Rollup__c != null) && (inv.Invoice_Balance__c == inv.Total_Invoice_Amount_Rollup__c)){
				list<Journal_Header__c> jh = [Select id from Journal_Header__c where Invoice__c=:recordId and Transaction_Type__c = 'Credit Memos'];
				if(!jh.isEmpty()){
                    BM_JournalEntryEngine.journalEntryCreationForHeaderReversal(new list<id>{jh[0].id},'Credit Memo Cancellation');
                    
                    list<Journal_Header__c> jhc = [Select id from Journal_Header__c where Transaction_Type__c='Credit Memo Cancellation'
                                                  	and  Invoice__c=:recordId];
                    if(!jhc.isEmpty()){
                        inv.Status__c = 'Cancelled';
                        inv.Invoice_Balance__c = 0;
                        update inv;
                        wr.message 		= 'Credit Memo Cancelled Successfully.';
                        wr.isCancelled 	= true;
                	}
				}
			} else{
                wr.message = 'Credit memo cannot be cancelled. Please check with sytem administrator.';
                wr.isCancelled = false;
            }
        }catch(Exception e){
            wr.message = e.getMessage();
            wr.isCancelled = false;
        }
        return wr;
    }
	
	/*Method Name : FundTransferReversal
	Description : Used to reverse the FT */
    @AuraEnabled
    public static cancelInvoiceclass FundTransferReversal(String recordId){
        cancelInvoiceclass wr = new cancelInvoiceclass();
        try{
            Fund_Transfer__c  ft = [Select id, Name, Reference_Receipt__c,Reference_Receipt__r.Is_Reversed__c, To_Receipt__c, Pushed_To_Oracle__c,
									Journal_Created__c,Status__c, Reference_Receipt__r.Payment_Currency__c FROM Fund_Transfer__c where id=:recordId];
            if(ft.Status__c == 'Draft'){
                ft.Status__c = 'Reversed';
                update ft;
				
                wr.message 		= 'Fund Transfer reversed Successfully.';
                wr.isCancelled 	= true; 
            } else if(ft.Pushed_To_Oracle__c == true || ft.Journal_Created__c == true){
				//Validation - Reference receipt should not be reversed.
				if(ft.Reference_Receipt__r.Is_Reversed__c == true){
					wr.message 		= 'The reference receipt is reversed. Please check with system administrator.';
					wr.isCancelled 	= true;
					return wr;
				}
				list<Journal_Header__c> jh = [Select id from Journal_Header__c where Fund_Transfer__c=:recordId and 
                                              	Transaction_Type__c IN ('Fund Transfer', 'Fund Transfer - DC') Limit 1];
				if(!jh.isEmpty()){
                    list<Receipt__c> toReceipt = [Select id, Payment_Currency__c, Amount__c, Receipt_Balance__c from Receipt__c where id=:ft.To_Receipt__c];
					 
					//Validation - Check if toReceipt already used for application.
                    if(!toReceipt.isEmpty()){
						if(toReceipt[0].Amount__c != toReceipt[0].Receipt_Balance__c){
							wr.message 		= 'To Receipt is already been used for application. Reversal cannot be done.';
							wr.isCancelled 	= true;
							return wr;
						}
                    }
                    
                   
                    List<Id> jhIds = new List<Id>();
                    for(Journal_Header__c jhObj : jh){
                        jhIds.add(jhObj.Id);
                    }
                    BM_JournalEntryEngine.journalEntryCreationForHeaderReversal(jhIds,'Fund Transfer Reversal');
                    //Check if api is successful by querying the JV for reversal.
                    list<Journal_Header__c> jhc = [Select id from Journal_Header__c where Transaction_Type__c='Fund Transfer Reversal'
                                                  	and Fund_Transfer__c=:recordId];
                    if(!jhc.isEmpty()){
                        ft.Status__c = 'Reversed';
                        update ft;
                        
						Receipt__c sReceiptUpdate =[Select id, Transferred_Amount__c from Receipt__c where id=:ft.Reference_Receipt__c];
						if(sReceiptUpdate.Transferred_Amount__c == null ){sReceiptUpdate.Transferred_Amount__c=0;}
                        if(toReceipt[0].Payment_Currency__c == ft.Reference_Receipt__r.Payment_Currency__c){
							sReceiptUpdate.Transferred_Amount__c = sReceiptUpdate.Transferred_Amount__c - toReceipt[0].Amount__c;
                        } else if(toReceipt[0].Payment_Currency__c == 'AED'){
							decimal amount = 0.00;
							amount = (toReceipt[0].Amount__c)/3.6725;
							sReceiptUpdate.Transferred_Amount__c = sReceiptUpdate.Transferred_Amount__c - amount;
						} else{
							decimal amount = 0.00;
							amount = (toReceipt[0].Amount__c) * 3.6725;
							sReceiptUpdate.Transferred_Amount__c = sReceiptUpdate.Transferred_Amount__c - amount;
						}
						
						update sReceiptUpdate;
						
						toReceipt[0].Is_Reversed__c = true;
						update toReceipt;

                        wr.message 		= 'Fund transfer reversed successfully.';
                        wr.isCancelled 	= true;
                	}else{
						wr.message 		= 'JV api has failed. Please check with administrator';
						wr.isCancelled 	= true;
					}
				} else{
					wr.message 		= 'JVs for Fund transfer not found.';
                    wr.isCancelled 	= true;
				}
			} else{
                wr.message = 'Fund transfer cannot be reversed. Please check with sytem administrator.';
                wr.isCancelled = false;
            }
        }catch(Exception e){
            system.debug('==exception message=='+e.getMessage());
            wr.message = e.getMessage();
            wr.isCancelled = false;
        }
        return wr;
    }
    public class cancelInvoiceclass{
        @AuraEnabled public String message;
        @AuraEnabled public boolean isCancelled;
    }
}