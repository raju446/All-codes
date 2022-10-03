global without  sharing class DED_Batch_renewBLFZED implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        string restricttype = System.Label.DED_DNOT_Allow_Type;//'Restricted Scope Company';
        string addresstype = 'Physical';
        string query = 'SELECT ID, Name, Account_Name_Arabic__c,Entity_Id__c, License_Expiry_Date__c, Entity_Type__c, Entity_Status__c, Registration_Date__c '; 
        query += ' From Account where RenewBLFZED__c=true and Entity_Type__c !=:restricttype';
        return database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,list<Account> accounts)
    {
            //Note: This batch will run with the batch size "1".
            Account updateacc = new Account();
            for(Account acc : accounts)
            {
                list<DED_Sub_Log__c> logs = DED_RestServicesHelper.renewBLFZEDServiceRequest(acc);
                for(DED_Sub_Log__c sl : logs)
                {
                    if(sl.Message_Text__c == 'Success'){
                        updateacc.id = acc.id;
                        updateacc.RenewBLFZED__c = false;
                        break;
                    }
                }
            }
            if(updateacc.id != null)
                update updateacc;
    }
    global void finish(Database.BatchableContext BC){ 
        DED_Batch_cancelBLFZED  btch = new DED_Batch_cancelBLFZED();
        database.executeBatch(btch,1);
    }
}