/*
@Author : Azmath
@Description : Batch class to send the modified registered licenses to DED via api call on dialy basis.
@Version : v1.
*/
global without sharing class DED_Batch_modifyBLFZED implements Database.Batchable<sObject>, Database.Stateful,  Database.AllowsCallouts
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        string restricttype = System.Label.DED_DNOT_Allow_Type;//'Restricted Scope Company';
        string addresstype = 'Physical';
        string ownerEnType = 'Restricted Scope Company';
        string query = 'SELECT ID, DED_Status__c, LicenseStatusID__c,LegalTypeID__c, Name, Account_Name_Arabic__c,Entity_Id__c, License_Expiry_Date__c, Entity_Type__c, Entity_Status__c, Registration_Date__c, '; 
        query += '(Select id,State__c, Street_Name_of_Cluster_on_the_Island__c, Building_Name__c from Addresses__r WHERE Type__c=:addresstype), ';
        query += '(Select id, Actual_Activity_code__c, Status__c, Activity_Name_Arabic__c, Activity_Name__c from Business_Activities__r), ';
        query += '(Select id,OwnerTypeId__c,RelationshipTypeID__c, EDOwnerID__c, Owner_Full_Name_En__c, Owner_Type__c, RelationShip_Start_Date__c, Relationship_Status1__c, Relationship_Type__c FROM Entity_Owners__r WHERE Entity_Type__c !=:ownerEnType) ';
        query += ' From Account where ModifyBLFZED__c=true and Entity_Type__c !=:restricttype';
        return database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,list<Account> accounts)
    {
        //Note: This batch will run with the batch size "1".
        Account updateacc = new Account();
        
        for(Account acc : accounts)
        {
            list<DED_Sub_Log__c> logs = DED_RestServicesHelper.modifyBLFZEDServiceRequest(acc);
            for(DED_Sub_Log__c sl : logs)
            {
                if(sl.Message_Text__c == 'Success'){
                    updateacc.id = acc.id;
                    updateacc.ModifyBLFZED__c = false;
                    break;
                }
            }
        }
        if(updateacc.id != null)
            update updateacc;
    }
    global void finish(Database.BatchableContext BC){ 
         DED_Batch_renewBLFZED  btch = new DED_Batch_renewBLFZED();
        database.executeBatch(btch,1);
    }
}