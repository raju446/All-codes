public class UpdateAccessAdgmApplicationInvoices {
    
    public static void updateAppliationInvoices(){
        Savepoint sp;
        
        try{
            sp = Database.setSavepoint();
            List<Related_Invoice_Receipt__c> applicationLst = [SELECT Id, Invoice__c, Invoice__r.Service_Request__c, Oracle_Applied_Amount__c FROM Related_Invoice_Receipt__c WHERE CreatedDate = THIS_MONTH  AND Invoice__r.Service_Request__c != '' AND Oracle_Applied_Amount__c > 0];
            
            Map<Id, Decimal> invoiceBalanceMap = new Map<Id, Decimal>();
            set<Id> serviceRequestId = new set<Id>();
            
            for(Related_Invoice_Receipt__c applObj : applicationLst){
                
                Decimal invBal = invoiceBalanceMap.get(applObj.Invoice__c);
                if(invBal == null){
                    invBal = 0;
                }
                invBal = invBal + applObj.Oracle_Applied_Amount__c;
                invoiceBalanceMap.put(applObj.Invoice__c, invBal);
                applObj.Oracle_Applied_Amount__c = 0;
                serviceRequestId.add(applObj.Invoice__r.Service_Request__c);
            }
            system.debug('applicationLst==<<' + applicationLst.Size());
            system.debug('applicationLst==>>' + applicationLst);
            UPDATE applicationLst;
            List<Invoice__c> invList = new List<Invoice__c>();
            for(Id invId : invoiceBalanceMap.keySet()){
                invList.add(new Invoice__c(id = invId, Invoice_Balance__c = invoiceBalanceMap.get(invId)));
            }
            system.debug('invList==<<' + invList.Size());
            system.debug('invList==>>' + invList);
            UPDATE invList;
            
            List<HexaBPM__SR_Price_Item__c> priceItemLst = [SELECT Id, HexaBPM__Status__c FROM HexaBPM__SR_Price_Item__c WHERE HexaBPM__ServiceRequest__c IN :serviceRequestId];
            for(HexaBPM__SR_Price_Item__c priceItemObj : priceItemLst){
                priceItemObj.HexaBPM__Status__c = 'Consumed';
            }
            system.debug('priceItemLst==<<' + priceItemLst.Size());
            system.debug('priceItemLst==>>' + priceItemLst);
            UPDATE priceItemLst;
        }catch(Exception ex){
            system.debug(ex.getMessage());
            Database.rollback(sp);
        } 
    }
}