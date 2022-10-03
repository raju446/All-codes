global without sharing class  Batch_PopulateEntityBalanceNewLogic implements Database.Batchable<sObject>,Schedulable{
    global void execute(SchedulableContext sc) {
        database.executebatch(this,Integer.valueof(system.label.BatchSizeOfBalCal)); 
    } 
    global List<sObject> start(Database.BatchableContext BC)
    {
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company').getRecordTypeId();
        Id conRecType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact - Portal User').getRecordTypeId();
        return [SELECT Id,(Select id from Contacts where Recordtypeid=:conRecType limit 1) FROM Account 
                WHERE Recordtypeid=:accRecordTypeId  and  Entity_Id__c LIKE '000%' and Registration_Date__c != null];
    }
    
    global void execute(Database.BatchableContext BC,List<Account> accLst)
    {
        list<Customer_Portal_Balance__c> updateBal = new list<Customer_Portal_Balance__c>();
        for(Account acc: accLst)
        {
            if(acc.contacts != null && acc.contacts.size() > 0)
            {
                decimal finalAmount     = 0.00;
                decimal OpenRecAmount   = PortalBalanceCalculator.getOpenReceiptsAmount(acc.id);
                decimal OpenCMAmount    = PortalBalanceCalculator.getOpenCMAmount(acc.id);
                decimal openInvAmount   = PortalBalanceCalculator.getOpenInvAmount(acc.id);
                finalAmount = ((OpenRecAmount + OpenCMAmount) - openInvAmount).setscale(2);
                Date dt = Date.today();
                string upsertString = dt.day()+'-'+dt.month()+'-'+dt.year()+'-'+acc.id;
                Customer_Portal_Balance__c cpb = new Customer_Portal_Balance__c(Entity__c=acc.id,Date__c=Date.today(),
                                                    Upsert_ID__c=upsertString, Open_CM_Amount__c=OpenCMAmount,
                                                    Open_Invoice_Amount__c=openInvAmount,Open_Receipts_Amount__c=OpenRecAmount,
                                                    Portal_Balance__c=finalAmount);
                updateBal.add(cpb);
            }
        }
        if(!updateBal.isEmpty()){
            upsert updateBal Upsert_ID__c;
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
}