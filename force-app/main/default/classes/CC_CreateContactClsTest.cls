@isTest 
public with sharing class CC_CreateContactClsTest {
   
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList;
    private static HexaBPM__SR_Steps__c createSRstep;
     
    private static void init(){
        HexaBPM__SR_Template__c srtemp = new HexaBPM__SR_Template__c();
        srtemp.HexaBPM__Sub_menu__c = 'Employee';
        srtemp.HexaBPM__SR_RecordType_API_Name__c = 'Contact_Employee';
        insert srtemp;
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        insert newAccounts;
        
        createdSRList = TestUtility.createSR(1,'Permit_Alcohol');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__SR_Template__c = srtemp.Id; 
        insert createdSRList;   
        
        createSRstep = new  HexaBPM__SR_Steps__c();
        insert createSRstep;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,createSRstep.Id);
        insert createdstepList; 
        
        Contact_SR_Field_Mapping__c csf = new Contact_SR_Field_Mapping__c();
        csf.Name = 'AccountId';
        csf.SR_Field_API_Name__c =  'HexaBPM__Customer__c';
        csf.Contact_Field_API_Name__c = 'AccountId';
        insert csf;
        
        Contact_SR_Field_Mapping__c csf1 = new Contact_SR_Field_Mapping__c();
        csf1.Name = 'City__c';
        csf1.SR_Field_API_Name__c = 'City__c';
        csf1.Contact_Field_API_Name__c = 'City__c';
        insert csf1;
        
        Contact_SR_Field_Mapping__c csf2 = new Contact_SR_Field_Mapping__c();
        csf2.Name = 'LastName';
        csf2.SR_Field_API_Name__c =  'Last_Name__c';
        csf2.Contact_Field_API_Name__c = 'LastName';
        insert csf2;
        
        Document_Detail_SR_Field_Mapping__c ddsr = new Document_Detail_SR_Field_Mapping__c();
        ddsr.Active__c = true;
        ddsr.Document_Detail_Field_API_Name__c = 'Account__c';
        ddsr.Document_Type__c = 'Alcohol Permit';
        ddsr.Service_Request_Recordtype_API__c = 'Permit_Alcohol';
        ddsr.SR_Field_API_Name__c = 'HexaBPM__Customer__c';
        ddsr.Name = '1';
        insert ddsr;
    }
    
    public static testmethod void testcase(){
        init();
        CC_CreateContactCls con = new CC_CreateContactCls();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.Sub_Menu__c,HexaBPM__SR__r.HexaBPM__Record_Type_Name__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(createdSRList[0],lstOfSteps[0]);
    }
    private static void init2(){
        HexaBPM__SR_Template__c srtemp = new HexaBPM__SR_Template__c();
        srtemp.HexaBPM__Sub_menu__c = 'Dependent';
        srtemp.HexaBPM__SR_RecordType_API_Name__c = 'Contact_Dependent';
        insert srtemp;
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        insert newAccounts;
        
        createdSRList = TestUtility.createSR(1,'Permit_Alcohol');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__SR_Template__c = srtemp.Id; 
        insert createdSRList;   
        
        createSRstep = new  HexaBPM__SR_Steps__c();
        insert createSRstep;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,createSRstep.Id);
        insert createdstepList; 
        
        Contact_SR_Field_Mapping__c csf = new Contact_SR_Field_Mapping__c();
        csf.Name = 'AccountId';
        csf.SR_Field_API_Name__c =  'HexaBPM__Customer__c';
        csf.Contact_Field_API_Name__c = 'AccountId';
        insert csf;
        
        Contact_SR_Field_Mapping__c csf1 = new Contact_SR_Field_Mapping__c();
        csf1.Name = 'City__c';
        csf1.SR_Field_API_Name__c =     'City__c';
        csf1.Contact_Field_API_Name__c = 'City__c';
        insert csf1;
        
        Contact_SR_Field_Mapping__c csf2 = new Contact_SR_Field_Mapping__c();
        csf2.Name = 'LastName';
        csf2.SR_Field_API_Name__c =  'Last_Name__c';
        csf2.Contact_Field_API_Name__c = 'LastName';
        insert csf2;
        
        Document_Detail_SR_Field_Mapping__c ddsr = new Document_Detail_SR_Field_Mapping__c();
        ddsr.Active__c = true;
        ddsr.Document_Detail_Field_API_Name__c = 'Account__c';
        ddsr.Document_Type__c = 'Alcohol Permit';
        ddsr.Service_Request_Recordtype_API__c = 'Permit_Alcohol';
        ddsr.SR_Field_API_Name__c = 'HexaBPM__Customer__c';
        ddsr.Name = '1';
        insert ddsr;
    }
    
    public static testmethod void testcase2(){
        init2();
        CC_CreateContactCls con = new CC_CreateContactCls();
        List<HexaBPM__Step__c> lstOfSteps = [SELECT Id,HexaBPM__SR__r.HexaBPM__Contact__c , HexaBPM__SR__r.Sub_Menu__c,HexaBPM__SR__r.HexaBPM__Record_Type_Name__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.EvaluateCustomCode(createdSRList[0],lstOfSteps[0]);
        
    }
}