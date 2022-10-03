@isTest
public with sharing class ChartControllerTest {
    public static list<HexaBPM__SR_Status__c> lstSRStatus = new list<HexaBPM__SR_Status__c>();
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static  List<Case> createdCaseList; 
    public static void init(){
        lstSRStatus = new list<HexaBPM__SR_Status__c>();
        HexaBPM__SR_Status__c objSRStatus;
        objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'Closed';
        objSRStatus.HexaBPM__Code__c = 'CLOSED';
        objSRStatus.HexaBPM__Type__c = 'End';
        lstSRStatus.add(objSRStatus);
        
        objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'Awaiting Sanction Approval';
        objSRStatus.HexaBPM__Code__c = 'AWAITING_SANCTION_APPROVAL';
        objSRStatus.HexaBPM__Type__c = 'Start';
        lstSRStatus.add(objSRStatus);

        objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'Rejected';
        objSRStatus.HexaBPM__Code__c = 'REJECTED';
        objSRStatus.HexaBPM__Type__c = 'Rejected';
        lstSRStatus.add(objSRStatus);
        
        objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'Awaiting Approval';
        objSRStatus.HexaBPM__Code__c = 'AWAITING_APPROVAL';
        objSRStatus.HexaBPM__Type__c = 'Start';
        lstSRStatus.add(objSRStatus);
        
        objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'Approved';
        objSRStatus.HexaBPM__Code__c = 'APPROVED';
        objSRStatus.HexaBPM__Type__c = 'Intermediate';
        lstSRStatus.add(objSRStatus);
        
        objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'Submitted';
        objSRStatus.HexaBPM__Code__c = 'SUBMITTED';
        lstSRStatus.add(objSRStatus);
        
        objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'Draft';
        objSRStatus.HexaBPM__Code__c = 'DRAFT';
        lstSRStatus.add(objSRStatus);
        
        insert lstSRStatus;
    }
    public static testmethod void TestStatementAccountController(){
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
                    
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Types_of_Services_Accessible__c = 'Company Services';
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        insert newContacts;  
        
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        insert createdSRList;
        
        createdCaseList = TestClassUtility.createCase(
                                new List<Case>{
                                    new Case()});   
        //createdCaseList[0].Contact = newContacts[0];
        //createdCaseList[0].Service_Request__c = createdSRList[0].Id;
        //update createdCaseList;
        Document_Details__c docs = new Document_Details__c();  
         docs.Document_Status__c='Active';
         docs.Document_Type__c= 'Residence Visa';
         docs.Account__c = newAccounts[0].Id;
         docs.Contact__c = newContacts[0].Id;
         docs.Service_Request__c = createdSRList[0].Id;
         docs.Document_Expiry_Date__c = system.today().addDays(30);
         
         insert docs; 
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        
        
        system.runAs(portalUser){
            
            ChartController prc = new ChartController();
            prc.prepareVisaChart();
            prc.prepareCaseChartData();
            prc.prepareSRPieChart();
            prc.prepareVisaExpiring_Due_Chart();
            
        } 
 
    }
    
    public static testmethod void TestStatementAccountController2(){
        
        init();
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '091283123';
        newAccounts[0].EChannel_Expiry_Date__c = date.today().adddays(5);
        newAccounts[0].Establishment_Card_Expiry_Date__c = date.today().adddays(5);
        insert newAccounts; 
                    
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Types_of_Services_Accessible__c = 'Company Services;Visa & Letter Services';
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        newContacts[0].Employment_Status__c = 'Active';
        newContacts[0].Sponsored_Employee__c = false;
        newContacts[0].Types_of_Services_Accessible__c = 'Company Services; Payment - Account Services; Permits Services';
        newContacts[0].RecordTypeId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Contact - Employee').getRecordTypeId();
        upsert newContacts;  

        System.debug('newContacts'+newContacts);

        HexaBPM__SR_Template__c srtemp = new HexaBPM__SR_Template__c();
        srtemp.HexaBPM__Menu__c = 'Government Services';
        srtemp.HexaBPM__Sub_menu_section__c = 'Visa Services';
        srtemp.HexaBPM__SR_RecordType_API_Name__c = 'Employment_Visa_New';
        srtemp.HexaBPM__Sub_menu__c = 'Employee';
        srtemp.HexaBPM__Menutext__c = 'adgm';
        srtemp.HexaBPM__Template_Sequence_No__c = 12;
        srtemp.HexaBPM__Portal_Service_Request_Name__c = 'test';
        srtemp.HexaBPM__Is_Through_Flow__c = true;
        srtemp.HexaBPM__SR_Instruction_URL__c = 'www.google.com';
        srtemp.Icon_Name__c = '134';
        srtemp.HexaBPM__Active__c = true;
        srtemp.HexaBPM__Available_for_menu__c = true;
        srtemp.Visible_To__c = 'Company User';    
        insert srtemp;

        createdSRList = TestUtility.createSR(1,'Employment_Visa_New');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].I_Agree__c = true;
        createdSRList[0].HexaBPM__Internal_SR_Status__c = lstSRStatus[6].Id; // changing the status to Draft
        createdSRList[0].HexaBPM__External_SR_Status__c = lstSRStatus[6].Id; // changing the status to Draft
        upsert createdSRList;
        System.debug('createdSRList[0].HexaBPM__Contact__c'+createdSRList[0].HexaBPM__Contact__r.Community_Username__c);
        
        Document_Details__c docs = new Document_Details__c();  
        docs.Document_Status__c='Active';
        docs.Document_Type__c= 'Residence Visa';
        docs.Account__c = newAccounts[0].Id;
        docs.Contact__c = newContacts[0].Id;
        docs.Service_Request__c = createdSRList[0].Id;
        docs.Document_Expiry_Date__c = system.today().addDays(30);
         
        insert docs; 
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        
        
        system.runAs(portalUser){
            ChartController prc = new ChartController();
            prc.prepareVisaChart();
            prc.prepareCaseChartData();
            prc.prepareSRPieChart();
            prc.prepareVisaExpiring_Due_Chart();
        }
            
 
    }
    public static testmethod void TestStatementAccountController3(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '091283123';
        insert newAccounts; 
                    
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Types_of_Services_Accessible__c = 'Company Services; Payment - Account Services; Permits Services';
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        insert newContacts;  
        
        HexaBPM__SR_Template__c srtemp = new HexaBPM__SR_Template__c();
        srtemp.HexaBPM__Menu__c = 'Government Services';
        srtemp.HexaBPM__Sub_menu_section__c = 'Company Services';
        srtemp.HexaBPM__SR_RecordType_API_Name__c = 'P_O_Box_New';
        srtemp.HexaBPM__Sub_menu__c = 'P.O. Box Services';
        srtemp.HexaBPM__Menutext__c = 'Government Services';
        srtemp.HexaBPM__Template_Sequence_No__c = 12;
        srtemp.HexaBPM__Portal_Service_Request_Name__c = 'test';
        srtemp.HexaBPM__Is_Through_Flow__c = true;
        srtemp.HexaBPM__SR_Instruction_URL__c = 'www.google.com';
        srtemp.Icon_Name__c = '134';
        srtemp.HexaBPM__Active__c = true;
        srtemp.HexaBPM__Available_for_menu__c = true;
        srtemp.Visible_To__c = 'Company User';    
        insert srtemp;

        HexaBPM__SR_Status__c srstatus = new HexaBPM__SR_Status__c();
        srstatus.HexaBPM__Type__c = 'Rejected';
        srstatus.SR_Approved__c = true;
        srstatus.HexaBPM__Code__c = 'test';
        insert srstatus;
        
        createdSRList = TestUtility.createSR(1,'P_O_Box_New');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].HexaBPM__Internal_SR_Status__c = srstatus.Id;
        createdSRList[0].I_Agree__c = true;
        insert createdSRList;
        
        createdCaseList = TestClassUtility.createCase(
                                new List<Case>{
                                    new Case()});   
        //createdCaseList[0].Contact = newContacts[0];
        //createdCaseList[0].Service_Request__c = createdSRList[0].Id;
        //update createdCaseList;
        Document_Details__c docs = new Document_Details__c();  
         docs.Document_Status__c='Active';
         docs.Document_Type__c= 'Residence Visa';
         docs.Account__c = newAccounts[0].Id;
         docs.Contact__c = newContacts[0].Id;
         docs.Service_Request__c = createdSRList[0].Id;
         docs.Document_Expiry_Date__c = system.today().addDays(30);
         
         insert docs; 
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        portalUser.Role__c = 'Lead Admin';
        
        system.runAs(portalUser){
        
            ChartController prc = new ChartController();
            prc.prepareVisaChart();
            prc.prepareCaseChartData();
            prc.prepareSRPieChart();
            prc.prepareVisaExpiring_Due_Chart();
            
        } 
 
    }
    public static testmethod void TestStatementAccountController4(){
        init();
        HexaBPM__SR_Template__c srtemp = new HexaBPM__SR_Template__c();
        srtemp.HexaBPM__Menu__c = 'test123';
        srtemp.HexaBPM__Sub_menu_section__c = 'Company Services';
        srtemp.HexaBPM__Sub_menu__c = 'tester';
        srtemp.HexaBPM__Menutext__c = 'adgm';
        srtemp.HexaBPM__SR_RecordType_API_Name__c = 'Employment_Visa_New';
        srtemp.HexaBPM__Template_Sequence_No__c = 12;
        srtemp.HexaBPM__Portal_Service_Request_Name__c = 'test';
        srtemp.HexaBPM__Is_Through_Flow__c = true;
        srtemp.HexaBPM__SR_Instruction_URL__c = 'www.google.com';
        srtemp.Icon_Name__c = '134';
        srtemp.HexaBPM__Active__c = true;
        srtemp.HexaBPM__Available_for_menu__c = true;
        srtemp.Visible_To__c = 'Company User';    
        insert srtemp;

        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '091283123';
        insert newAccounts; 
                    
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Types_of_Services_Accessible__c = 'Company Services; Payment - Account Services; Permits Services; Visa & Letter Services';
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        newContacts[0].Employment_Status__c = 'Active';
        newContacts[0].RecordTypeId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Contact - Employee').getRecordTypeId();
        insert newContacts;  
        
        createdSRList = TestUtility.createSR(1,'Employment_Visa_New');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].HexaBPM__External_SR_Status__c = lstSRStatus[5].id;
        createdSRList[0].HexaBPM__Internal_SR_Status__c = lstSRStatus[5].id;
        createdSRList[0].HexaBPM__SR_Template__c = srtemp.id; 
        createdSRList[0].I_Agree__c = true;
        insert createdSRList;
        
        createdCaseList = TestClassUtility.createCase(
                                new List<Case>{
                                    new Case()});   
        //createdCaseList[0].Contact = newContacts[0].Id;
        createdCaseList[0].ContactId = newContacts[0].Id;
        update createdCaseList;                         
        //User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        Document_Details__c docs = new Document_Details__c();  
        docs.Document_Status__c='Active';
        docs.Document_Type__c= 'Residence Visa';
        docs.Account__c = newAccounts[0].Id;
        docs.Contact__c = newContacts[0].Id;
        docs.Service_Request__c = createdSRList[0].Id;
        docs.Document_Expiry_Date__c = system.today().addDays(2);

        insert docs; 
        
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        portalUser.Role__c = 'Lead Admin';
        
        system.runAs(portalUser){  
            ChartController prc = new ChartController();
            prc.prepareVisaChart();
            prc.prepareCaseChartData();
            prc.prepareSRPieChart();
            prc.prepareVisaExpiring_Due_Chart();
        }
            
 
    }
    
}