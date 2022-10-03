public class JournalVoucherTriggerHandler {
    
    public static void Execute_AI(list<Journal_Header__c> TriggerNew){
        /*list<Journal_Header__c> lstJH = new list<Journal_Header__c>();
        List<Id> jHIdlist = new List<Id>();
        String customLabelValue = System.Label.EnableFusionIntegration;
        System.debug('customLabelValue=='+customLabelValue);
        for(Journal_Header__c objJH:TriggerNew){
            system.debug('objJH.Source_System__c==>>' + objJH.Source_System__c); system.debug('!objJH.Sync_Not_Required__c==>>' + (!objJH.Sync_Not_Required__c));
            if(objJH.Source_System__c == 'BM' || String.isBlank(objJH.Source_System__c) && (objJH.Account__r.Name != 'LS-*' || objJH.Account__r.Name != 'CH-*')){
                if(!objJH.Sync_Not_Required__c && (customLabelValue != 'Disabled')){
                    PushJEstoOracle.PushJEToOracle_Future(objJH.id);
                }   
            }
        }*/
    }
    /****
     *   Name : Execute_AU
     *   Description : Journal Voucher After update functionality 
     *                  
     ****/
    public static void Execute_AU(Map<Id, Journal_Header__c> newJournalMap, Map<Id, Journal_Header__c> oldJournalMap){
        updateFusionReference(newJournalMap, oldJournalMap);
    }
    
    /****
     * Name         : updateFusionReference
     * Description  : Method to update fusion reference on base transactions (Invoice, Receipt, CreditMemo, Fund Transfer)
     ****/
    public static void updateFusionReference(Map<Id, Journal_Header__c> newJournalMap, Map<Id, Journal_Header__c> oldJournalMap){
        Map<String, List<Journal_Header__c>> transactionTypeJournalMap = new Map<String, List<Journal_Header__c>>();
        for(String jhId : newJournalMap.keySet()){
            if(newJournalMap.get(jhId).Oracle_FusionBatchName__c != oldJournalMap.get(jhId).Oracle_FusionBatchName__c){
                if(transactionTypeJournalMap.containsKey(newJournalMap.get(jhId).transaction_type__c)){
                    transactionTypeJournalMap.get(newJournalMap.get(jhId).transaction_type__c).add(newJournalMap.get(jhId));
                }else{
                    transactionTypeJournalMap.put(newJournalMap.get(jhId).transaction_type__c, new List<Journal_Header__c>{newJournalMap.get(jhId)});
                }
            }
        }
        List<Invoice__c> invLst = new List<Invoice__c>();
        List<Receipt__c> recLst = new List<Receipt__c>();
        Map<Id, Fund_Transfer__c> ftMap = new Map<Id, Fund_Transfer__c>();
        //List<Fund_Transfer__c> ftLst = new List<Fund_Transfer__c>();
        List<Refund__c> rfndLst = new List<Refund__c>();
        List<Invoice_Line_Item__c> adjustmentLst = new List<Invoice_Line_Item__c>();
        set<Id> ftIds = new set<Id>();
        for(String transactionType : transactionTypeJournalMap.keySet()){
            for(Journal_Header__c jhObj : transactionTypeJournalMap.get(transactionType)){
                if(transactionType == 'Sales Invoices' || transactionType == 'Credit Memos'){
                    invLst.add(new Invoice__c(Id = jhObj.Invoice__c, Oracle_Invoice_Id__c = jhObj.Oracle_FusionBatchName__c, Pushed_To_Oracle__c = true));
                }else if(transactionType == 'Receipts'){
                    recLst.add(new Receipt__c(Id = jhObj.Receipt__c, Oracle_Receipt_Id__c = jhObj.Oracle_FusionBatchName__c, Pushed_To_Oracle__c = true));
                }else if(transactionType == 'Fund Transfer' || transactionType == 'Fund Transfer - DC'){
                    ftMap.put(jhObj.Fund_Transfer__c, new Fund_Transfer__c(Id = jhObj.Fund_Transfer__c, Pushed_To_Oracle__c = true));
                    //ftLst.add(new Fund_Transfer__c(Id = jhObj.Fund_Transfer__c, Pushed_To_Oracle__c = true));
                    ftIds.add(jhObj.Fund_Transfer__c);
                }else if(transactionType == 'Refund'){
                    rfndLst.add(new Refund__c(Id = jhObj.Refund__c, Pushed_To_Oracle__c = true));
                }else if(transactionType == 'Adjustment'){
                    adjustmentLst.add(new Invoice_Line_Item__c(Id = jhObj.Invoice_Line_Item__c, Oracle_Adjustment_No__c = jhObj.Oracle_FusionBatchName__c));
                }
            }
        }
        for(Fund_Transfer__c ftObj : [SELECT Id, To_Receipt__c, Name FROM Fund_Transfer__c WHERE Id IN : ftIds]){
            recLst.add(new Receipt__c(Id = ftObj.To_Receipt__c, Oracle_Receipt_Id__c = ftObj.Name));
        }
        if(!invLst.isEmpty()){
            UPDATE invLst;
        }
        if(!recLst.isEmpty()){
            UPDATE recLst;
        }
        if(!ftMap.values().isEmpty()){
            UPDATE ftMap.values();
        }
        if(!rfndLst.isEmpty()){
            UPDATE rfndLst;
        }
        if(!adjustmentLst.isEmpty()){
            UPDATE adjustmentLst;
        }
    }
}