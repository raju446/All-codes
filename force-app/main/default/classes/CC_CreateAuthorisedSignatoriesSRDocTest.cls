@isTest
public with sharing class CC_CreateAuthorisedSignatoriesSRDocTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;  
    private static List<Account> createdAccountList; 
    private static HexaBPM__SR_Template_Docs__c createdSRTempDocList;
    
    private static void init(){
        
        createdAccountList = TestClassUtility.createAccounts(1);
        insert createdAccountList;
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, createdAccountList[0].Id);
        insert newContacts;  
        
        HexaBPM__Document_Master__c hdm = new HexaBPM__Document_Master__c();
        hdm.Name = 'Valid visa Copy';
        hdm.HexaBPM__Code__c = 'VALID_VISA_COPY';
        insert hdm;
        
        HexaBPM__SR_Template__c hst = new HexaBPM__SR_Template__c();
        hst.HexaBPM__Active__c = true;
        hst.HexaBPM__SR_RecordType_API_Name__c = 'Initial_Approval';
        insert hst;
        
        createdSRTempDocList = new HexaBPM__SR_Template_Docs__c();
        createdSRTempDocList.HexaBPM__Added_through_Code__c = true;
        createdSRTempDocList.HexaBPM__Document_Master__c = hdm.Id;
        createdSRTempDocList.HexaBPM__SR_Template__c = hst.Id;
        createdSRTempDocList.HexaBPM__Document_Description_External__c = 'Test';
        createdSRTempDocList.HexaBPM__On_Submit__c = true;
        createdSRTempDocList.For_Introductory_Statement__c = true;
        insert createdSRTempDocList;
        
        Role__c r = new Role__c();
        r.Subject_Account__c = createdAccountList[0].Id;
        r.Type__c = 'Authorised Signatory';
        r.Status__c = 'Active';
        r.Nationality__c = 'UNITED ARAB EMIRATES';
        insert r;
    
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList; 
        
        
    }
    public static testmethod void TestCC_CreateAuthorisedSignatoriesSRDoc(){
        init();
        CC_CreateAuthorisedSignatoriesSRDoc con = new CC_CreateAuthorisedSignatoriesSRDoc();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Contact__c, HexaBPM__SR__r.HexaBPM__Customer__c
                                                     FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        
    }
    
    
    private static void init2(){
        
        createdAccountList = TestClassUtility.createAccounts(1);
        insert createdAccountList;
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, createdAccountList[0].Id);
        insert newContacts;  
        
        HexaBPM__Document_Master__c hdm = new HexaBPM__Document_Master__c();
        hdm.Name = 'Work Resume';
        hdm.HexaBPM__Code__c = 'WORK_RESUME';
        insert hdm;
        
        HexaBPM__SR_Template__c hst = new HexaBPM__SR_Template__c();
        hst.HexaBPM__Active__c = true;
        hst.HexaBPM__SR_RecordType_API_Name__c = 'Initial_Approval';
        insert hst;
        
        createdSRTempDocList = new HexaBPM__SR_Template_Docs__c();
        createdSRTempDocList.HexaBPM__Added_through_Code__c = true;
        createdSRTempDocList.HexaBPM__Document_Master__c = hdm.Id;
        createdSRTempDocList.HexaBPM__SR_Template__c = hst.Id;
        createdSRTempDocList.HexaBPM__Document_Description_External__c = 'Test';
        createdSRTempDocList.HexaBPM__On_Submit__c = true;
        createdSRTempDocList.For_Introductory_Statement__c = true;
        insert createdSRTempDocList;
        
        Role__c r = new Role__c();
        r.Subject_Account__c = createdAccountList[0].Id;
        r.Type__c = 'Authorised Signatory';
        r.Status__c = 'Active';
        r.Nationality__c = 'UNITED ARAB EMIRATES';
        insert r;
    
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id;
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList; 
        
        
    }
    public static testmethod void TestCC_CreateAuthorisedSignatoriesSRDoc2(){
        init2();
        CC_CreateAuthorisedSignatoriesSRDoc con = new CC_CreateAuthorisedSignatoriesSRDoc();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Contact__c, HexaBPM__SR__r.HexaBPM__Customer__c
                                                     FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(null,lstOfSteps[0]);
        
    }
}