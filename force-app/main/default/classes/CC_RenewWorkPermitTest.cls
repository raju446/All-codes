@isTest
public class CC_RenewWorkPermitTest
{
    private static testMethod void CC_RenewWorkPermit_UT()
    {
        Id contactRecordTypeid;
        Map <String,Schema.RecordTypeInfo> recordTypeMap = Contact.sObjectType.getDescribe().getRecordTypeInfosByName();
        if(recordTypeMap.containsKey('Contact - Employee')) {
         contactRecordTypeid = recordTypeMap.get('Contact - Employee').getRecordTypeId();
        }
        List<Account> createdAccountList = TestClassUtility.createAccounts(1);
        createdAccountList[0].Oracle_Party_Id__c = '0000001';
        insert createdAccountList;
 
        List<Contact> newContacts = TestClassUtility.createContacts(1, createdAccountList[0].Id);
        newContacts[0].Employment_Type__c = 'Employee Work Permit(UAE/GCC National)';
        newContacts[0].recordtypeid = contactRecordTypeid;
        insert newContacts;  
        
        Document_Details__c objDocDetail = new Document_Details__c();
        objDocDetail.Document_Type__c = 'Employee Work Permit(UAE/GCC National)';
        objDocDetail.Account__c = createdAccountList[0].Id;
        objDocDetail.Contact__c = newContacts[0].Id;
        objDocDetail.Document_Status__c = 'Active';
        insert objDocDetail;
        
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Employee_Work_Permit_UAE_GCC_National_Renew');
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        createdSRList[0].Work_Permit_Expiry_Date__c = Date.today();
        //createdSRList[0].Work_Permit_Expiry_Date__c = Date.today();
        createdSRList[0].Passport_Expiry_Date__c = Date.today();
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].id;
        insert createdSRList;
        
        List<HexaBPM__Step__c>  createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;
        
        createdstepList[0] = [Select id,HexaBPM__SR__c, HexaBPM__SR__r.HexaBPM__Contact__c, 
                    HexaBPM__SR__r.Work_Permit_Expiry_Date__c,HexaBPM__SR__r.Passport_Expiry_Date__c,
                    HexaBPM__SR__r.Work_Permit_Issue_Date__c,
                    HexaBPM__SR__r.HexaBPM__Record_Type_Name__c FROM HexaBPM__Step__c where id=:createdstepList[0].id];
        test.startTest();
        CC_RenewWorkPermit cc = new CC_RenewWorkPermit();
        cc.EvaluateCustomCode(createdSRList[0],createdstepList[0]);
        test.stopTest();
    }
    
    private static testMethod void CC_RenewWorkPermit_UT1()
    {
        Id contactRecordTypeid;
        Map <String,Schema.RecordTypeInfo> recordTypeMap = Contact.sObjectType.getDescribe().getRecordTypeInfosByName();
        if(recordTypeMap.containsKey('Contact - Employee')) {
         contactRecordTypeid = recordTypeMap.get('Contact - Employee').getRecordTypeId();
        }
        List<Account> createdAccountList = TestClassUtility.createAccounts(1);
        createdAccountList[0].Oracle_Party_Id__c = '0000001';
        insert createdAccountList;
 
        List<Contact> newContacts = TestClassUtility.createContacts(1, createdAccountList[0].Id);
        newContacts[0].Employment_Type__c = 'Temporary Employee Work Permit';
        newContacts[0].recordtypeid = contactRecordTypeid;
        insert newContacts;  
        
        Document_Details__c objDocDetail = new Document_Details__c();
        objDocDetail.Document_Type__c = 'Temporary Employee Work Permit';
        objDocDetail.Account__c = createdAccountList[0].Id;
        objDocDetail.Contact__c = newContacts[0].Id;
        objDocDetail.Document_Status__c = 'Active';
        insert objDocDetail;
        
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Temporary_Work_Permit_Renew');
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        createdSRList[0].Work_Permit_Expiry_Date__c = Date.today();
        //createdSRList[0].Work_Permit_Expiry_Date__c = Date.today();
        createdSRList[0].Passport_Expiry_Date__c = Date.today();
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].id;
        insert createdSRList;
        
        List<HexaBPM__Step__c>  createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;
        
        createdstepList[0] = [Select id,HexaBPM__SR__c, HexaBPM__SR__r.HexaBPM__Contact__c, 
                    HexaBPM__SR__r.Work_Permit_Expiry_Date__c,HexaBPM__SR__r.Passport_Expiry_Date__c,
                    HexaBPM__SR__r.Work_Permit_Issue_Date__c,HexaBPM__SR__r.Residence_Visa_Number__c,
                    HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c,HexaBPM__SR__r.Residence_Visa_Date_of_Issue__c,
                    HexaBPM__SR__r.HexaBPM__Record_Type_Name__c FROM HexaBPM__Step__c where id=:createdstepList[0].id];
        test.startTest();
        CC_RenewWorkPermit cc = new CC_RenewWorkPermit();
        cc.EvaluateCustomCode(createdSRList[0],createdstepList[0]);
        test.stopTest();
    }
    
    private static testMethod void CC_RenewWorkPermit_UT2()
    {
        Id contactRecordTypeid;
        Map <String,Schema.RecordTypeInfo> recordTypeMap = Contact.sObjectType.getDescribe().getRecordTypeInfosByName();
        if(recordTypeMap.containsKey('Contact - Employee')) {
         contactRecordTypeid = recordTypeMap.get('Contact - Employee').getRecordTypeId();
        }
        List<Account> createdAccountList = TestClassUtility.createAccounts(1);
        createdAccountList[0].Oracle_Party_Id__c = '0000001';
        insert createdAccountList;
 
        List<Contact> newContacts = TestClassUtility.createContacts(1, createdAccountList[0].Id);
        newContacts[0].Employment_Type__c = 'Employee Work Permit';
        newContacts[0].recordtypeid = contactRecordTypeid;
        newContacts[0].Work_Permit_Card_Number__c = '12345';
        insert newContacts;  
        
        Document_Details__c objDocDetail = new Document_Details__c();
        objDocDetail.Document_Type__c = 'Temporary Employee Work Permit';
        objDocDetail.Account__c = createdAccountList[0].Id;
        objDocDetail.Contact__c = newContacts[0].Id;
        objDocDetail.Document_Status__c = 'Active';
        insert objDocDetail;
        
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Employment_Visa_Renewal');
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        createdSRList[0].Work_Permit_Expiry_Date__c = Date.today();
        createdSRList[0].Passport_Expiry_Date__c = Date.today();
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].id;
        insert createdSRList;
        
        List<HexaBPM__Step__c>  createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;
        
        createdstepList[0] = [Select id,HexaBPM__SR__c, HexaBPM__SR__r.HexaBPM__Contact__c, 
                    HexaBPM__SR__r.Work_Permit_Expiry_Date__c,HexaBPM__SR__r.Passport_Expiry_Date__c,
                    HexaBPM__SR__r.Work_Permit_Issue_Date__c,HexaBPM__SR__r.Residence_Visa_Number__c,
                    HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c,HexaBPM__SR__r.Residence_Visa_Date_of_Issue__c,
                    HexaBPM__SR__r.HexaBPM__Record_Type_Name__c FROM HexaBPM__Step__c where id=:createdstepList[0].id];
        test.startTest();
        CC_RenewWorkPermit cc = new CC_RenewWorkPermit();
        cc.EvaluateCustomCode(createdSRList[0],createdstepList[0]);
        test.stopTest();
    }
    
}