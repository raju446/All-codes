public class CancelFundTransferController {
    
	@AuraEnabled
    public static cancelFundTransferclass cancelFundTransfer(String recordId){
        List<Fund_Transfer__c> fundTransferLst = [SELECT Id, Status__c, From_Receipt__c, To_Receipt__c FROM Fund_Transfer__c WHERE Id = :recordId LIMIT 1];
        system.debug('fundTransferLst==>>' + fundTransferLst);
        if(!fundTransferLst.isEmpty()){
            if(fundTransferLst[0].status__c == 'Draft'){
                fundTransferLst[0].status__c = 'Cancelled';
                UPDATE fundTransferLst;
                List<Receipt__c> receiptLst = new List<Receipt__c>();
                if(fundTransferLst[0].From_Receipt__c != null){
                    Receipt__c fromReceipt = new Receipt__c(Id = fundTransferLst[0].From_Receipt__c, Status__c = 'Cancelled');
                    receiptLst.add(fromReceipt);
                }
                if(fundTransferLst[0].To_Receipt__c != null){
                    Receipt__c toReceipt = new Receipt__c(Id = fundTransferLst[0].To_Receipt__c, Status__c = 'Cancelled');
                    receiptLst.add(toReceipt);
                }
                if(!receiptLst.isEmpty()){
                    UPDATE receiptLst;
                }
                cancelFundTransferclass resp = new cancelFundTransferclass();
                resp.isCancelled = true;
                resp.message = 'Fund Transfer is cancelled';
                return resp;
            }else{
                cancelFundTransferclass resp = new cancelFundTransferclass();
                resp.isCancelled = false;
                resp.message = 'Fund Transfer must be in Draft status.';
                return resp;
            }
        }
       	return null;
    }
    
    public class cancelFundTransferclass{
        @AuraEnabled public String message;
        @AuraEnabled public boolean isCancelled;
    }
}