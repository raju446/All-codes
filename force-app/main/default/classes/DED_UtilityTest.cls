@isTest
public class DED_UtilityTest 
{
    static testMethod void identifyDEDServiceTest()
    {
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company').getRecordTypeId();
        Account acc = new Account(Name='DED Test',Account_Name_Arabic__c='DED Test',Entity_Id__c='00001',License_Expiry_Date__c=Date.today(),Recordtypeid=accRecordTypeId,
                            Entity_Type__c='Private Company Limited By Shares',Entity_Status__c='Active',Registration_Date__c=Date.today(),IssueBLFZEd__c=true);
        insert acc;
        
       
       test.startTest();
       
        acc.Entity_Status__c = 'Registered';
        update acc;
        
        acc.License_Expiry_Date__c = Date.today().addDays(360);
        update acc;
        
        acc.Data_Pushed_to_DED__c = true;
        acc.IssueBLFZEd__c = false;
        acc.Name = 'Test';
        update acc;
        
        acc.Entity_Status__c = 'Deregistered';
        update acc;
        
        DED_Utility.identifyDEDService(new list<Account>{acc}, new map<Id,Account>{acc.id=>acc}, new map<Id,Account>{acc.id=>acc});
        DED_Utility.updateIssueBLFZED(new set<id>{acc.id},'Issue');
        DED_Utility.updateIssueBLFZED(new set<id>{acc.id},'Modify');
        DED_Utility.updateIssueBLFZED(new set<id>{acc.id},'Renew');
        DED_Utility.updateIssueBLFZED(new set<id>{acc.id},'Cancel');
       test.stopTest();
    }
    static testMethod void callDEDServiceTest()
    {
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company').getRecordTypeId();
        Account acc = new Account(Name='DED Test',Account_Name_Arabic__c='DED Test',Entity_Id__c='00001',License_Expiry_Date__c=Date.today(),Recordtypeid=accRecordTypeId,
                            Entity_Type__c='Private Company Limited By Shares',Entity_Status__c='Active',Registration_Date__c=Date.today(),IssueBLFZEd__c=true);
        insert acc;
        
        test.startTest();
        test.setMock(HttpCalloutMock.class, new DED_issueMockHttpResponse());
        DED_Utility.callDEDService(acc.id,'Issue');
        test.stopTest();
    }
    static testMethod void callDEDServiceTestModifyTest()
    {
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company').getRecordTypeId();
        Account acc = new Account(Name='DED Test',Account_Name_Arabic__c='DED Test',Entity_Id__c='00001',License_Expiry_Date__c=Date.today(),Recordtypeid=accRecordTypeId,
                            Entity_Type__c='Private Company Limited By Shares',Entity_Status__c='Active',Registration_Date__c=Date.today(),IssueBLFZEd__c=true);
        insert acc;
        
        test.startTest();
        test.setMock(HttpCalloutMock.class, new DED_modifyMockHttpResponse());
        DED_Utility.callDEDService(acc.id,'Modify');
        test.stopTest();
        
    }
    
    static testMethod void callDEDServiceTestRenewTest()
    {
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company').getRecordTypeId();
        Account acc = new Account(Name='DED Test',Account_Name_Arabic__c='DED Test',Entity_Id__c='00001',License_Expiry_Date__c=Date.today(),Recordtypeid=accRecordTypeId,
                            Entity_Type__c='Private Company Limited By Shares',Entity_Status__c='Active',Registration_Date__c=Date.today(),IssueBLFZEd__c=true);
        insert acc;
        
        test.startTest();
        test.setMock(HttpCalloutMock.class, new DED_RenewMockHttpResponse());
        DED_Utility.callDEDService(acc.id,'Renew');
        test.stopTest();
        
    }
    
    static testMethod void callDEDServiceTestCancelTest()
    {
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company').getRecordTypeId();
        Account acc = new Account(Name='DED Test',Account_Name_Arabic__c='DED Test',Entity_Id__c='00001',License_Expiry_Date__c=Date.today(),Recordtypeid=accRecordTypeId,
                            Entity_Type__c='Private Company Limited By Shares',Entity_Status__c='Active',Registration_Date__c=Date.today(),IssueBLFZEd__c=true);
        insert acc;
        
        test.startTest();
        test.setMock(HttpCalloutMock.class, new DED_CancelMockHttpResponse());
        DED_Utility.callDEDService(acc.id,'Cancel');
        test.stopTest();
        
    }
}