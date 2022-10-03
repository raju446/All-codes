global without sharing class Batch_UpdateCustomerPortalBalance implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global List<sObject> start(Database.BatchableContext BC){
        set<Id> accIds = new set<Id>();
        List<Related_Invoice_Receipt__c> applLst = [SELECT Id, Invoice__c, Invoice__r.Entity__c, Invoice__r.Service_Request__c, Oracle_Applied_Amount__c FROM Related_Invoice_Receipt__c WHERE CreatedDate = THIS_MONTH  AND Invoice__r.Service_Request__c != '' AND Oracle_Applied_Amount__c = 0];
        for(Related_Invoice_Receipt__c appObj : applLst){
            accIds.add(appObj.Invoice__r.Entity__c);            
        }
        return [SELECT Id, Oracle_Party_Id__c FROM Account WHERE Id IN :accIds];
    }
    
    global void execute(Database.BatchableContext BC,List<Account> accLst){
        
        Account accObj = accLst[0];
        String accountId = accObj.Id;
        String oraclePartyId = accObj.Oracle_Party_Id__c;
        
        decimal ReceiptsAmount = getOpenReceiptsAmount(accountId);
        decimal BlockedSRsAmount = getBlockedAmount(accountId);
        decimal BalancefromOracle = 0;
        decimal portalBalance = 0;
        try{
            BalancefromOracle = WS_BalanceCheck.GetOracleBalance(oraclePartyId);
            if(BalancefromOracle == null){
                BalancefromOracle = 0;
            }
        }catch(Exception e){
            BalancefromOracle = 0;   
        }
        system.debug('BalancefromOracle==>>' + BalancefromOracle);
        system.debug('ReceiptsAmount==>>' + ReceiptsAmount);
        if(ReceiptsAmount!=null)
            BalancefromOracle = BalancefromOracle + ReceiptsAmount;
        
        if(BlockedSRsAmount!=null)
            BalancefromOracle = BalancefromOracle - BlockedSRsAmount;
        BalancefromOracle = BalancefromOracle.setScale(2);
        
        accObj.Entity_Portal_Amount__c = BalancefromOracle;
        UPDATE accObj;
    }
    
    public decimal getOpenReceiptsAmount(string EntityId){
        decimal Amount = 0.0;
        if(EntityId!=null){
            for(Receipt__c RP:[select Id,Amount__c from Receipt__c where Entity__c=:EntityId and Oracle_Receipt_Id__c=null and Amount__c!=null and Payment_Currency__c != 'USD' and (Status__c='Success' or Status__c='Approved') and Receipt_Type__c != 'Fund Transfer']){
                Amount = Amount + RP.Amount__c;
            }
        }
        return Amount;
    }
    
    public decimal getBlockedAmount(string EntityId){
        decimal Amount = 0.0;
        if(EntityId!=null){
            for(HexaBPM__SR_Price_Item__c SRP:[select Id,HexaBPM__Price__c,Tax_Amount__c,Total_Amount__c from HexaBPM__SR_Price_Item__c where HexaBPM__ServiceRequest__r.HexaBPM__Customer__c=:EntityId and (HexaBPM__Status__c='Blocked' or HexaBPM__Status__c='Consumed') and Total_Amount__c!=null]){
                Amount = Amount + SRP.Total_Amount__c;
            }
        }
        return Amount;
    }
    
    global void finish(Database.BatchableContext BC){ 
        
    }
    
}