@isTest 
public with sharing class AccountTriggerHandlerTest {
    private static List<Account> createdAccountList; 
    private static void init(){
    createdAccountList = TestClassUtility.createAccounts(1);
    insert createdAccountList;
   }
    
    public static testmethod void testcase(){
        init();
        Operating_Unit__c ou = new Operating_Unit__c(Oracle_Site_Id__c = '104', Source_System__c='Access');
        insert ou;
        createdAccountList[0].CRM_Entity_Id__c = createdAccountList[0].Id; 
        createdAccountList[0].Entity_Id__c = createdAccountList[0].Id; 
        
        update createdAccountList;
        String s = JSON.serialize(createdAccountList);
        AccountTriggerHandler.translateField(s);
       // CRM_CreateCRMRegEntity.updateCRMRegEntityStatus(new set<String>{createdAccountList[0].Id});
    }
    
    public static testmethod void testcase1(){
        List<Account> createdAccountList1 = TestClassUtility.createAccounts(5);
        for(Recordtype rec : [select id,name from Recordtype where sobjecttype = 'account']){
            if(rec.Name == 'ADGM Academy'){
                createdAccountList1[0].recordtypeid = rec.Id;
            } else if(rec.Name == 'ADGM Fintech'){
                createdAccountList1[1].recordtypeid = rec.Id; 
            } else if(rec.Name == 'ADGM'){
                createdAccountList1[2].recordtypeid = rec.Id; 
            } else if(rec.Name == 'Fourteenth Bridge Restricted'){
                createdAccountList1[3].recordtypeid = rec.Id; 
            } else if(rec.Name == 'Abu Dhabi Innovation Center'){
                createdAccountList1[4].recordtypeid = rec.Id; 
            }
        }
        AccountTriggerHandler.checkDuplicate(createdAccountList1);
    }
    public static testmethod void CRMChanges()
    {
        map<String,ID> accountRecordTypeMap= ApexCodeUtility.getRecTypeDetails('Account');
        Account CRMEntity = new Account(Name='CRMAccount',CRM_Pre_Approval_Id__c='1111',recordTypeId=accountRecordTypeMap.get('CRM Registered Entity'));
        insert CRMEntity;
        
        Account RegisteredEntity = new Account(Name='Registered Entity',Entity_Id__c='1111',Entity_Status__c ='Active',recordTypeId=accountRecordTypeMap.get('ADGM Registered Company'));
        insert RegisteredEntity;
        
        test.startTest();
        RegisteredEntity.Category__c = 'Retail (Category C)';
        RegisteredEntity.Entity_Status__c = 'Registered';
        update RegisteredEntity;
        
        RegisteredEntity.Name='Test';
        update RegisteredEntity;
        
        test.stopTest();
    }
        
}