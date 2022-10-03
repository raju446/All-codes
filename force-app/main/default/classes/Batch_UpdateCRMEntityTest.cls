@isTest
public without sharing class Batch_UpdateCRMEntityTest 
{
	@testSetup static void testSetupMethod()
	{
        map<String,ID> accountRecordTypeMap= ApexCodeUtility.getRecTypeDetails('Account');
        
         Profile p = [SELECT Id FROM Profile WHERE Name = 'CRM Office of Business Development' LIMIT 1];
        User crmuser = [SELECT Id FROM User WHERE ProfileId = :p.Id and isActive=true limit 1];
        system.runAs(crmuser)
        {
           Account CRMEntity = new Account(Name='CRMAccount',CRM_Pre_Approval_Id__c='1111',recordTypeId=accountRecordTypeMap.get('CRM Registered Entity'));
           insert CRMEntity;
        }
   
        Account RegisteredEntity = new Account(Name='Registered Entity',Entity_Id__c='1111',Entity_Status__c ='Registered',recordTypeId=accountRecordTypeMap.get('ADGM Registered Company'));
        insert RegisteredEntity;
    }
    @isTest static void runbatch(){
        test.StartTest();
            database.executeBatch(new Batch_UpdateCRMEntity(),1);
            System.schedule('Batch_UpdateCRMEntity','0 0 22 * * ? *',new Batch_UpdateCRMEntity());
        test.StopTest(); 
    }
}