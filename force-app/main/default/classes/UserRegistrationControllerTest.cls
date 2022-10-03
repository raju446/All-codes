@isTest
public with sharing class UserRegistrationControllerTest {
   
    private static HexaBPM__SR_Template_Docs__c srTempDoc; 
    private static List<HexaBPM__Document_Master__c> createDocMasList; 
    private static List<HexaBPM__Service_Request__c> createdSRList;
    
    private static void init(){
        createDocMasList = TestUtility.createDocMasters(1);
        createDocMasList[0].Name = 'test';
        createDocMasList[0].HexaBPM__Code__c = 'tester';
        insert createDocMasList;    
        HexaBPM__SR_Template__c srtemp = new HexaBPM__SR_Template__c();
        srtemp.HexaBPM__Active__c = true;
        srtemp.HexaBPM__SR_RecordType_API_Name__c = 'User_Access_Request_for_Registered_Company';
        insert srtemp;
        
        srTempDoc =  new HexaBPM__SR_Template_Docs__c();
        srTempDoc.HexaBPM__Added_through_Code__c = true;
        srTempDoc.HexaBPM__Document_Description_External__c = 'test';
        srTempDoc.HexaBPM__Optional__c = true;
        srTempDoc.HexaBPM__Document_Master__c = createDocMasList[0].Id;
        srTempDoc.HexaBPM__SR_Template__c = srtemp.Id;
        srTempDoc.HexaBPM__On_Submit__c = true;
        insert srTempDoc;
        
        createdSRList = TestUtility.createSR(1,'User_Access_Request_for_Registered_Company');
        //createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        //createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        //createdSRList[0].Valid_From__c = system.today();
     
        createdSRList[0].HexaBPM__Email__c = 'test@adgm.com';
        insert createdSRList;
        
    }
   public static testmethod void TestUserRegistrationController(){
        init();
        List<SR_Doc_Running_Number__c> srDocRunNumList = TestClassUtility.createSRDocRunningNumber();
        insert srDocRunNumList;
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Entity_Id__c = '098128313';
        newAccounts[0].Initial_Approval_Issue_Date__c = System.today().adddays(-5);
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        insert newContacts;  
        
        HexaBPM__SR_Status__c srStatus = new HexaBPM__SR_Status__c();
        srStatus.HexaBPM__Code__c = 'SUBMITTED';
        insert srStatus;
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        system.runAs(portalUser){
            UserRegistrationController urc = new UserRegistrationController();  
            urc.toggletaxregNum();
            urc.cancelReg();
            urc.guestUsername = '';
            urc.checkUName();
            
            urc.lstDocuments[0].objAttachment.Body = Blob.valueOf('138787q681qiugd'); 
            urc.lstDocuments[0].objAttachment.Name = 'test attachment';  
            urc.lstDocuments[0].isOptional = true;
            
            //populate values
            urc.objSR.Title__c = 'Mr.';
            urc.objSr.First_Name__c = 'First Name';
            urc.objSr.Last_Name__c = 'Last Name';
            urc.objSr.Date_of_Birth__c = System.today().addYears(-20);
            urc.objSr.HexaBPM__Email__c = 'testadgm001@adgm.com';
            urc.objSr.HexaBPM__Send_SMS_to_Mobile__c = '+971563921111';
            urc.objSr.License_Number__c = newAccounts[0].Entity_Id__c;
            urc.guestUsername = 'testportal001';
            urc.SubmitSR();
            
            
            UserRegistrationController urc2 = new UserRegistrationController();
            urc2.SubmitSR();
            
            urc2.objSr.Last_Name__c = 'LastName#';
            urc2.objSr.License_Number__c = '129354545454';
            urc2.objSr.Date_of_Birth__c = System.today();
            urc2.SubmitSR();
        }
        
   } 
   public static testmethod void TestUserRegistrationController2(){
        init();
        List<SR_Doc_Running_Number__c> srDocRunNumList = TestClassUtility.createSRDocRunningNumber();
        insert srDocRunNumList;
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Entity_Id__c = '098128313';
        newAccounts[0].Initial_Approval_Issue_Date__c = System.today().adddays(-5);
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        insert newContacts;  
        
        HexaBPM__SR_Status__c srStatus = new HexaBPM__SR_Status__c();
        srStatus.HexaBPM__Code__c = 'SUBMITTED';
        insert srStatus;
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        system.runAs(portalUser){
            UserRegistrationController urc = new UserRegistrationController();  
            urc.toggletaxregNum();
            urc.cancelReg();
            urc.guestUsername = 'test';
            urc.checkUName();
            
            urc.lstDocuments[0].objAttachment.Body = Blob.valueOf('138787q681qiugd'); 
            urc.lstDocuments[0].objAttachment.Name = 'test attachment';  
            urc.lstDocuments[0].isOptional = true;
            
            //populate values
            urc.objSR.Title__c = 'Mr.';
            urc.objSr.First_Name__c = 'First Name';
            urc.objSr.Last_Name__c = 'Last Name';
            urc.objSr.Date_of_Birth__c = System.today().addYears(-20);
            urc.objSr.HexaBPM__Email__c = 'testadgm001@adgm.com';
            urc.objSr.HexaBPM__Send_SMS_to_Mobile__c = '+971563921111';
            urc.objSr.License_Number__c = newAccounts[0].Entity_Id__c;
            urc.guestUsername = 'testportal001';
            urc.objSR.I_Agree__c = true;
            urc.SubmitSR();
            urc.checkPhone('1234567890');
            urc.checkExistingCompanyName('TestAccount1');
            urc.checkExistingLicenseExpiry(newAccounts[0].Id);
            urc.createSRDoc();
            
            
            UserRegistrationController urc2 = new UserRegistrationController();
            urc2.SubmitSR();
            

            urc2.objSr.Last_Name__c = 'LastName#';
            urc2.objSr.License_Number__c = '129354545454';
            urc2.objSr.Date_of_Birth__c = System.today();
            urc2.SubmitSR();
            
        }
   } 
   
   public static testmethod void TestUserRegistrationController3(){
        init();
        List<SR_Doc_Running_Number__c> srDocRunNumList = TestClassUtility.createSRDocRunningNumber();
        insert srDocRunNumList;
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Entity_Id__c = '098128313';
        newAccounts[0].Initial_Approval_Issue_Date__c = System.today().adddays(-5);
        newAccounts[0].License_Expiry_Date__c = System.today().addyears(1);
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        insert newContacts;  
        
        HexaBPM__SR_Status__c srStatus = new HexaBPM__SR_Status__c();
        srStatus.HexaBPM__Code__c = 'SUBMITTED';
        insert srStatus;
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        system.runAs(portalUser){
            UserRegistrationController urc = new UserRegistrationController();  
            urc.toggletaxregNum();
            urc.cancelReg();
            urc.guestUsername = 'test';
            urc.checkUName();
            
            urc.lstDocuments[0].objAttachment.Body = Blob.valueOf('138787q681qiugd'); 
            urc.lstDocuments[0].objAttachment.Name = 'test attachment';  
            urc.lstDocuments[0].isOptional = true;
            
            //populate values
            urc.objSR.Title__c = 'Mr.';
            urc.objSr.First_Name__c = 'First Name';
            urc.objSr.Last_Name__c = 'Last Name';
            urc.objSr.Date_of_Birth__c = System.today().addYears(-30);
            urc.objSr.HexaBPM__Email__c = 'testadgm001@adgm.com';
            urc.objSr.HexaBPM__Send_SMS_to_Mobile__c = '+971563921111';
            urc.objSr.License_Number__c = newAccounts[0].Entity_Id__c;
            urc.guestUsername = 'testportal001';
            urc.objSR.I_Agree__c = true;
            urc.SubmitSR();
            
            
        }
   }
   public static testmethod void TestUserRegistrationController4(){
        init();
        List<SR_Doc_Running_Number__c> srDocRunNumList = TestClassUtility.createSRDocRunningNumber();
        insert srDocRunNumList;
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Entity_Id__c = '098128313';
        newAccounts[0].Initial_Approval_Issue_Date__c = System.today().adddays(-5);
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        insert newContacts;  
        
        HexaBPM__SR_Status__c srStatus = new HexaBPM__SR_Status__c();
        srStatus.HexaBPM__Code__c = 'SUBMITTED';
        insert srStatus;
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        system.runAs(portalUser){
            UserRegistrationController urc = new UserRegistrationController();  
            urc.toggletaxregNum();
            urc.cancelReg();
            urc.guestUsername = 'test';
            urc.checkUName();
            
            urc.lstDocuments[0].objAttachment.Body = Blob.valueOf('138787q681qiugd'); 
            urc.lstDocuments[0].objAttachment.Name = 'test attachment';  
            urc.lstDocuments[0].objAttachment.ContentType = 'application/pdf';
            urc.lstDocuments[0].isOptional = true;
            
            //populate values
            urc.objSR.Title__c = 'Mr.';
            urc.objSr.First_Name__c = 'First Name';
            urc.objSr.Last_Name__c = 'Last Name';
            urc.objSr.Date_of_Birth__c = System.today().addYears(-20);
            urc.objSr.HexaBPM__Email__c = 'testadgm001@adgm.com';
            urc.objSr.HexaBPM__Send_SMS_to_Mobile__c = '+971563921111';
            urc.objSr.License_Number__c = newAccounts[0].Entity_Id__c;
            urc.guestUsername = 'testportal001';
            urc.objSR.I_Agree__c = true;
            urc.SubmitSR();
            urc.checkPhone('1234567890');
            urc.checkExistingCompanyName('TestAccount1');
            urc.checkExistingLicenseExpiry(newAccounts[0].Id);
            urc.createSRDoc();
            
            
            UserRegistrationController urc2 = new UserRegistrationController();
            urc2.SubmitSR();
            

            urc2.objSr.Last_Name__c = 'LastName#';
            urc2.objSr.License_Number__c = '129354545454';
            urc2.objSr.Date_of_Birth__c = System.today();
            urc2.SubmitSR();
            
        }
   } 
   public static testmethod void TestUserRegistrationController5(){
        init();
        List<SR_Doc_Running_Number__c> srDocRunNumList = TestClassUtility.createSRDocRunningNumber();
        insert srDocRunNumList;
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Entity_Id__c = '098128313';
        newAccounts[0].Initial_Approval_Issue_Date__c = System.today().adddays(-5);
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        insert newContacts;  
        
        HexaBPM__SR_Status__c srStatus = new HexaBPM__SR_Status__c();
        srStatus.HexaBPM__Code__c = 'SUBMITTED';
        insert srStatus;
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        system.runAs(portalUser){
            UserRegistrationController urc = new UserRegistrationController();  
            urc.toggletaxregNum();
            urc.cancelReg();
            urc.guestUsername = 'test';
            urc.checkUName();
            
            urc.lstDocuments[0].objAttachment.Body = Blob.valueOf('138787q681qiugd'); 
            urc.lstDocuments[0].objAttachment.Name = 'test attachment';  
            urc.lstDocuments[0].objAttachment.ContentType = 'application/pdf';
            urc.lstDocuments[0].isOptional = true;
            
            //populate values
            urc.objSR.Title__c = 'Mr.';
            urc.objSr.First_Name__c = 'First Name';
            urc.objSr.Last_Name__c = 'Last Name';
            urc.objSr.Date_of_Birth__c = System.today().addYears(-20);
            urc.objSr.HexaBPM__Email__c = 'testadgm001@adgm.com';
            urc.objSr.HexaBPM__Send_SMS_to_Mobile__c = '+971563921111';
            urc.objSr.License_Number__c = newAccounts[0].Entity_Id__c;
            urc.objSr.Registered_for_Tax__c = 'Yes';
            urc.guestUsername = 'testportal001';
            urc.objSR.I_Agree__c = true;
            urc.SubmitSR();
            urc.checkPhone('1234567890');
            urc.checkExistingCompanyName('TestAccount1');
            urc.checkExistingLicenseExpiry(newAccounts[0].Id);
            urc.createSRDoc();
            
            
            UserRegistrationController urc2 = new UserRegistrationController();
            urc2.SubmitSR();
            

            urc2.objSr.Last_Name__c = 'LastName#';
            urc2.objSr.License_Number__c = '129354545454';
            urc2.objSr.Date_of_Birth__c = System.today();
            urc2.SubmitSR();
            
        }
   } 
}