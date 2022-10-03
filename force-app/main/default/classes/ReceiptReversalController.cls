/**
 * @File Name          : ReceiptReversalController.cls
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 4/30/2020, 1:52:54 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/30/2020   Jayanta Karmakar     Initial Version
**/
public class ReceiptReversalController {
    @AuraEnabled  
    public static Receipt__c getReceiptDetails(String receiptId) {
        return [SELECT Id,Is_Reversed__c,Pushed_to_Oracle__c, Journal_Created__c FROM Receipt__c WHERE Id =: receiptId];
    }
    
    @AuraEnabled  
    public static String pushReceiptToOracle(String receiptId) {
        
       List<Id> journalHeaderId = new LIst<Id>();
        for(Journal_Header__c jh : [Select Id, Name, Receipt__c from Journal_Header__c where Receipt__c =: receiptId]){
            journalHeaderId.add(jh.Id);
        }
        
        //if(journalHeaderId.size()>0){BM_JournalEntryEngine.journalEntryCreationForReversal(journalHeaderId);}
        
        return ReceiptUtil.PushReceiptReversalToOracle(receiptId); 
    }
}