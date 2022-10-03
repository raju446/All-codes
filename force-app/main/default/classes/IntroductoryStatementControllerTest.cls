@isTest
public with sharing class IntroductoryStatementControllerTest {
    
    public static List<HexaBPM__Service_Request__c> createdSRList; 
    private static HexaBPM__SR_Template_Docs__c createdSRTempDocList;
    
    private static void init(){
        //createdSRList = TestUtility.createSR(1,'Permit_Entertainment');
        //insert createdSRList;
        
        HexaBPM__Document_Master__c hdm = new HexaBPM__Document_Master__c();
        hdm.Name = 'Work Resume';
        hdm.HexaBPM__Code__c = 'WORK_RESUME';
        insert hdm;
        
        HexaBPM__SR_Template__c hst = new HexaBPM__SR_Template__c();
        hst.HexaBPM__Active__c = true;
        hst.HexaBPM__SR_RecordType_API_Name__c = 'Permit_Entertainment';
        insert hst;
        
        createdSRTempDocList = new HexaBPM__SR_Template_Docs__c();
        createdSRTempDocList.HexaBPM__Added_through_Code__c = true;
        createdSRTempDocList.HexaBPM__Document_Master__c = hdm.Id;
        createdSRTempDocList.HexaBPM__SR_Template__c = hst.Id;
        createdSRTempDocList.HexaBPM__Document_Description_External__c = 'Test';
        createdSRTempDocList.HexaBPM__On_Submit__c = true;
        createdSRTempDocList.For_Introductory_Statement__c = true;
        insert createdSRTempDocList;
    }
    
    public static testmethod void TestIntroductoryStatementController(){
        init();
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = 'Test';
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        //newContacts[1].Portal_User_Creation__c = true;
        
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        //newContacts[1].Community_Username__c = 'test2@adgm.portal';
        insert newContacts;  
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        //User portalUser2 = [SELECT Id, isActive, ContactId FROM User WHERE ContactId = :newContacts[1].Id];
        
        createdSRList = TestUtility.createSR(1,'Permit_Entertainment');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        insert createdSRList;
        
        Amendment__c objAmm = new Amendment__c();
        objAmm.Full_Name__c = 'Test Participant 1';
        objAmm.Service_Request__c = createdSRList[0].Id;
        objAmm.Nationality_New__c = 'Australia';
        insert objAmm;
        
        Amendment__c objAmm2 = new Amendment__c();
        objAmm2.Full_Name__c = 'Test Participant 2';
        objAmm2.Service_Request__c = createdSRList[0].Id;
        insert objAmm2;
        
        Lookup__c lk = new Lookup__c(); 
        lk.Name = 'Australia';
        lk.Type__c = 'Nationality';     
        insert lk; 
        
        ApexPages.StandardController sc = new ApexPages.StandardController(createdSRList[0]);
        IntroductoryStatementController isc = new IntroductoryStatementController(sc);
        
        //system.runAs(portalUser){
            
            sc = new ApexPages.StandardController(createdSRList[0]);
            isc = new IntroductoryStatementController(sc);
            isc.existPersonnelId=newContacts[0].Id;
            isc.existPersonnelId = objAmm.Id;
            isc.editExisting();
            
            isc.saveRecord();
            isc.saveRedirect();
            isc.deletePartcipant();
        //}
        
    }
}