@isTest
public with sharing class ApexCodeUtilityTest {
    private static  List<Contact> createdContactList; 
    private static  List<Account> createdAccountList; 
    private static List<HexaBPM__Service_Request__c> createdSRList;
    
    public static void init(){
        createdAccountList = TestClassUtility.createAccounts(1);
        insert createdAccountList;
        createdContactList = TestClassUtility.createContacts(1,createdAccountList[0].Id);
        insert createdContactList;
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = createdContactList[0].Id;
        insert createdSRList;
    }
    public static testmethod void TestApexCodeutility(){
        //init();
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '0000001';
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        insert newContacts;  
        
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        insert createdSRList;
        
        Fines__c p = new Fines__c();
        p.Document_Type__c = 'test';
        p.SR_Record_Type_Name__c = 'Initial_Approval';
        p.Grace_Period__c = 5;
        p.Name  = 'tester';
        insert p;
        
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        system.runAs(portalUser){
        String str = '14713678901234567890123456713741';
        String email = 'abcd@gmail.com';
        String user = 'rishu';
        
        ApexCodeUtility acu = new ApexCodeUtility();
        //ApexCodeUtility.getEncryptedValueURL(str);
        String s = ApexCodeUtility.getEncryptedValue(str);
    
        //ApexCodeUtility.getDecryptedValueURL(s);
        ApexCodeUtility.getDecryptedValue(s);
        
        ApexCodeUtility.isExistingPortalUser(email);
        ApexCodeUtility.isExistingUsername(user); 
        ApexCodeUtility.isExistingUsernameSR(user);
        ApexCodeUtility.getOpenReceiptsAmount('abc');        
        ApexCodeUtility.getBlockedAmount('abc');  
        //ApexCodeUtility.isValidPhone('0097127278888843'); 
        HexaBPM__Service_Request__c objSR = createdSRList[0];
        string SRID = objSR.id;
        system.debug('====sr id===='+SRID);
        ApexPages.currentpage().getParameters().put('Id',objSR.id);
        SubmitRequestController sc = new SubmitRequestController();
        sc.CheckPriceLines();
        ApexCodeUtility.createPOBoxPriceItems(objSR);
        
        }
    }
    public static testmethod void TestApexCodeutility2(){
        //init();
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '0000002';
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        insert newContacts;  
        
        createdSRList = TestUtility.createSR(1,'P_O_Box_New');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        
        insert createdSRList;
        
        Fines__c p = new Fines__c();
        p.Document_Type__c = 'test';
        p.SR_Record_Type_Name__c = 'Initial_Approval';
        p.Grace_Period__c = 5;
        p.Name  = 'tester';
        insert p;
        
        Product2 p2 = new Product2();
        p2.ProductCode = 'P_O_BOX_FEES';
        p2.Name = 'test';
        insert p2;
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        //system.runAs(portalUser){
        String str = '14713678901234567890123456713741';
        String email = 'abcd@gmail.com';
        String user = 'rishu';
        
        ApexCodeUtility acu = new ApexCodeUtility();
        ApexCodeUtility.queryAllContactFields(newContacts[0].Id);
        //ApexCodeUtility.getEncryptedValueURL(str);
        String s = ApexCodeUtility.getEncryptedValue(str);
    
        //ApexCodeUtility.getDecryptedValueURL(s);
        ApexCodeUtility.getDecryptedValue(s);
        
        ApexCodeUtility.isExistingPortalUser(email);
        ApexCodeUtility.isExistingUsername(user); 
        ApexCodeUtility.isExistingUsernameSR(user);
        ApexCodeUtility.getOpenReceiptsAmount('abc');        
        ApexCodeUtility.getBlockedAmount('abc');  
        //ApexCodeUtility.isValidPhone('0097127277000043'); 
        
        HexaBPM__Service_Request__c objSR  = createdSRList[0];
        objSR = [Select id,HexaBPM__Record_Type_Name__c,P_O_Box_Type__c,HexaBPM__Customer__c,Entity_PO_Box_Expiry_Date__c,
        PO_Box__c,Passport_Number__c,Temporary_Work_Permit_Type__c,Dependent__c
        FROM HexaBPM__Service_Request__c Where Id=:objSR.id];
        ApexCodeUtility.createPOBoxPriceItems(objSR);
        ApexCodeUtility.CheckOpenFinePaymentStep(objSR.id);
        ApexCodeUtility.totalVisaCount(newAccounts[0].id);
        ApexCodeUtility.submittedSRS(newAccounts[0].id);
        ApexCodeUtility.getAnnualAmount(3, 'abc');
        //}
    }public static testmethod void TestApexCodeutility3(){
        //init();
        
        Product2 p2 = new Product2();
        p2.ProductCode = 'P_O_BOX_FEES';
        p2.Name = 'P.O. Box Fees';
        insert p2;
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '0000003';
        insert newAccounts; 
       
        PO_Box__c pb = new PO_Box__c();
        pb.Type__c  = 'P.O. Box Corporate';
        pb.Expiry_Date__c = system.today().addDays(-2);
        pb.Account__c = newAccounts[0].Id;
        pb.PO_Box_Number__c = '123456';
        insert pb;
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        insert newContacts;  
        
        createdSRList = TestUtility.createSR(1,'P_O_Box_Renewal');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].PO_Box__c = pb.Id;
        createdSRList[0].Passport_Number__c = '123456';
        //createdSRList[0].Entity_PO_Box_Expiry_Date__c = system.today();
        insert createdSRList;
        
        Fines__c p = new Fines__c();
        p.Document_Type__c = 'test';
        p.SR_Record_Type_Name__c = 'P_O_Box_Renewal';
        p.First_Month_Amount__c = 34;
        p.Fine_Amount_Per_Month__c = 44;
        p.Grace_Period__c = 5;
        p.Name  = 'tester';
        insert p;
        
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        //system.runAs(portalUser){
        String str = '14713678901234567890123456713741';
        String email = 'abcd@gmail.com';
        String user = 'rishu';
        
        ApexCodeUtility acu = new ApexCodeUtility();
        string encryptURL = ApexCodeUtility.getEncryptedValueURL(str);
        String s = ApexCodeUtility.getEncryptedValue(str);
    
        ApexCodeUtility.getDecryptedValueURL(encryptURL);
        ApexCodeUtility.getDecryptedValue(s);
        
        ApexCodeUtility.isExistingPortalUser(email);
        ApexCodeUtility.isExistingUsername(user); 
        ApexCodeUtility.isExistingUsernameSR(user);
        ApexCodeUtility.getOpenReceiptsAmount('abc');        
        ApexCodeUtility.getBlockedAmount('abc');  
        //ApexCodeUtility.isValidPhone('0097127277277777'); 
        
        
        HexaBPM__Service_Request__c objSR  = createdSRList[0];
        objSR = [Select id,HexaBPM__Record_Type_Name__c,P_O_Box_Type__c,HexaBPM__Customer__c,Entity_PO_Box_Expiry_Date__c,HexaBPM__Customer__r.Entity_Status__c,
        PO_Box__c,Passport_Number__c,Temporary_Work_Permit_Type__c,Dependent__c 
        FROM HexaBPM__Service_Request__c Where Id=:objSR.id];
        ApexCodeUtility.createPOBoxPriceItems(objSR);
        ApexCodeUtility.SubmissionAllowed(objSR);
        //}
    }
    public static testmethod void TestApexCodeutility4(){
        //init();
        Product2 p2 = new Product2();
        p2.ProductCode = 'P_O_BOX_FEES';
        p2.Name = 'P.O. Box Fees';
        insert p2;
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '0000004';
        insert newAccounts; 
        
        PO_Box__c pb = new PO_Box__c();
        pb.Type__c  = 'P.O. Box Corporate';
        pb.Expiry_Date__c = system.today();
        pb.Account__c = newAccounts[0].Id;
        pb.PO_Box_Number__c = '123456';
        insert pb;
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        insert newContacts;  
        
        createdSRList = TestUtility.createSR(1,'P_O_Box_Cancellation');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        //createdSRList[0].Entity_PO_Box_Expiry_Date__c = system.today();
        createdSRList[0].PO_Box__c = pb.Id;
        insert createdSRList;
        
        Fines__c p = new Fines__c();
        p.Document_Type__c = 'test';
        p.SR_Record_Type_Name__c = 'P_O_Box_Cancellation';
        p.First_Month_Amount__c = 34;
        p.Fine_Amount_Per_Month__c = 44;
        p.Grace_Period__c = 5;
        p.Name  = 'tester';
        insert p;
        
        
       // User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        //system.runAs(portalUser){
        String str = '/adgm/apex/test?id=0292929292';
        String email = 'abcd@gmail.com';
        String user = 'rishu';
        
        ApexCodeUtility acu = new ApexCodeUtility();
        //ApexCodeUtility.getEncryptedValueURL(str);
        String s = ApexCodeUtility.getEncryptedValue(str);
    
        //ApexCodeUtility.getDecryptedValueURL(s);
        ApexCodeUtility.getDecryptedValue(s);
        
        ApexCodeUtility.isExistingPortalUser(email);
        ApexCodeUtility.isExistingUsername(user); 
        ApexCodeUtility.isExistingUsernameSR(user);
        ApexCodeUtility.getOpenReceiptsAmount('abc');        
        ApexCodeUtility.getBlockedAmount('abc');  
        //ApexCodeUtility.isValidPhone('0097127271323212'); 
        //HexaBPM__Service_Request__c objSR = createdSRList[0];
        HexaBPM__Service_Request__c objSR  = createdSRList[0];
        objSR = [Select id,HexaBPM__Record_Type_Name__c,P_O_Box_Type__c,HexaBPM__Customer__c,Entity_PO_Box_Expiry_Date__c,
        PO_Box__c,Passport_Number__c,Temporary_Work_Permit_Type__c,Dependent__c
        FROM HexaBPM__Service_Request__c Where Id=:objSR.id];
        ApexCodeUtility.createPOBoxPriceItems(objSR);
        
        //}
    }
    
    public static testmethod void TestApexCodeutility5(){
        //init();
        Product2 p2 = new Product2();
        p2.ProductCode = 'P_O_BOX_FEES';
        p2.Name = 'P.O. Box Fees';
        insert p2;
        
       
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '0000001';
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        insert newContacts;  
        
        PO_Box__c pb = new PO_Box__c();
        pb.Type__c  = 'P.O. Box Corporate';
        pb.Expiry_Date__c = system.today();
        pb.Account__c = newAccounts[0].Id;
        pb.PO_Box_Number__c = '123456';
        insert pb;
        
        createdSRList = TestUtility.createSR(1,'Employment_Visa_New');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].Passport_Number__c = '123456';
        insert createdSRList;
        system.debug('======='+createdSRList[0].id);
        
        HexaBPM__Service_Request__c objSR  = createdSRList[0];
        objSR = [Select id,HexaBPM__Record_Type_Name__c,P_O_Box_Type__c,HexaBPM__Customer__c,Entity_PO_Box_Expiry_Date__c,HexaBPM__Customer__r.Entity_Status__c,
        PO_Box__c,Passport_Number__c,Temporary_Work_Permit_Type__c,Dependent__c 
        FROM HexaBPM__Service_Request__c Where Id=:objSR.id];
        system.debug('======='+objSR.id);
        ApexCodeUtility.createPOBoxPriceItems(objSR);
        ApexCodeUtility.SubmissionAllowed(objSR);

    }
    
    public static testmethod void TestApexCodeutility6(){
        //init();
        Product2 p2 = new Product2();
        p2.ProductCode = 'P_O_BOX_FEES';
        p2.Name = 'P.O. Box Fees';
        insert p2;
        
       
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '0000001';
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        newContacts[0].Employment_Type__c='Employee Work Permit';
        newContacts[0].Gender__c = 'Male';
        insert newContacts;  
     
        
        createdSRList = TestUtility.createSR(1,'Employment_Visa_Renewal');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].Passport_Number__c = '123456';
        createdSRList[0].Gender__c = 'Male';
        insert createdSRList;
        system.debug('======='+createdSRList[0].id);
        
        HexaBPM__Service_Request__c objSR  = createdSRList[0];
        objSR = [Select id,HexaBPM__Record_Type_Name__c,P_O_Box_Type__c,HexaBPM__Customer__c,Entity_PO_Box_Expiry_Date__c,
        PO_Box__c,Passport_Number__c,Temporary_Work_Permit_Type__c,Dependent__c,HexaBPM__Contact__c,HexaBPM__Customer__r.Entity_Status__c 
        FROM HexaBPM__Service_Request__c Where Id=:objSR.id];
        system.debug('======='+objSR.id);
        ApexCodeUtility.createPOBoxPriceItems(objSR);
        try{
        ApexCodeUtility.SubmissionAllowed(objSR);
        }catch(exception e){}
    }
    
    public static testmethod void TestApexCodeutility7(){
        //init();
        Product2 p2 = new Product2();
        p2.ProductCode = 'P_O_BOX_FEES';
        p2.Name = 'P.O. Box Fees';
        insert p2;
        
       
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '0000001';
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        newContacts[0].Employment_Type__c='Employee Work Permit';
        newContacts[0].Passport_No__c = '123456';
        newContacts[0].Dependent_Status__c = 'Active';
        newContacts[0].Residence_Visa_Date_of_Expiry__c = Date.today()+100;
        newContacts[0].Employment_Status__c = 'Active'; 
        newContacts[0].Gross_Monthly_Salary__c = 20000;
        insert newContacts; 

        List<Contact> newContacts1 = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts1[0].lastname='test123';
        newContacts1[0].Email='test123@test.com';
        newContacts1[0].Portal_User_Creation__c = true;
        newContacts1[0].Community_Username__c = 'test12@adgm.portal';
        newContacts1[0].Employment_Type__c='Employee Work Permit';
        newContacts1[0].Passport_No__c = '1234563';
        newContacts1[0].Dependent_Status__c = 'Active';
        newContacts1[0].Residence_Visa_Date_of_Expiry__c = Date.today()+100;
        newContacts1[0].Employment_Status__c = 'Active'; 
        newContacts1[0].Gross_Monthly_Salary__c = 20000;
        newContacts1[0].Sponsor__c = newContacts[0].id; 
        insert newContacts1;        
     
        
        createdSRList = TestUtility.createSR(1,'Dependent_Visa_Renewal');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].Dependent__c = newContacts1[0].Id;
        createdSRList[0].Passport_Number__c = '123456'; 
        
        insert createdSRList;
        system.debug('======='+createdSRList[0].id);
        
        HexaBPM__Service_Request__c objSR  = createdSRList[0];
        objSR = [Select id,HexaBPM__Record_Type_Name__c,P_O_Box_Type__c,HexaBPM__Customer__c,Entity_PO_Box_Expiry_Date__c,
        PO_Box__c,Passport_Number__c,Temporary_Work_Permit_Type__c,Dependent__c,HexaBPM__Contact__c,HexaBPM__Customer__r.Entity_Status__c 
        FROM HexaBPM__Service_Request__c Where Id=:objSR.id];
        system.debug('======='+objSR.id);
        ApexCodeUtility.createPOBoxPriceItems(objSR);
        Map<String,Id> mapofLeadRecordTypeNameandId = new Map<String,Id>();
        mapofLeadRecordTypeNameandId = ApexCodeUtility.getRecTypeDetails('Lead');
        ApexCodeUtility.savePayload('test', 'test', objSR.id, 'test');
        try{
        ApexCodeUtility.SubmissionAllowed(objSR);
            
        }catch(exception e){}
    }
    
}