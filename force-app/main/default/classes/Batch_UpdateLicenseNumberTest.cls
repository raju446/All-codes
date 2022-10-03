@isTest
public without sharing class Batch_UpdateLicenseNumberTest {
    //Test Setup
    @testSetup static void testSetupMethod() {
        map<String,ID> accountRecordTypeMap= ApexCodeUtility.getRecTypeDetails('Account');
        
        Account CRMEntity = new Account(Name='CRMAccount',CRM_Pre_Approval_Id__c='P1111',recordTypeId=accountRecordTypeMap.get('CRM Registered Entity'));
        insert CRMEntity;
        
        Account RegisteredEntity = new Account(Name='Registered Entity',Entity_Id__c='1111',Entity_Status__c ='Registered',recordTypeId=accountRecordTypeMap.get('ADGM Registered Company'));
        insert RegisteredEntity;
        
        Catalyst_Entity__c catalystMapping= new Catalyst_Entity__c(Entity_id__c='1111',Preapplication_number__c='P1111');
        insert catalystMapping;
    }
    @isTest static void runbatch(){
        test.StartTest();
            database.executeBatch(new Batch_UpdateLicenseNumber(),1);
            System.schedule('Batch_UpdateLicenseNumberTest','0 0 22 * * ? *',new Batch_UpdateLicenseNumber());
        test.StopTest(); 
        Account CRMEntity =[select id,CRM_Entity_Id__c,Entity_Status__c  from Account where name='CRMAccount' limit 1];
        //system.AssertEquals('1111',CRMEntity.CRM_Entity_Id__c);
        //system.AssertEquals('Registered',CRMEntity.Entity_Status__c );
    }
        
}