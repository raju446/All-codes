@isTest
private class ServiceRequestTriggerHelperTest{
    static testMethod void PopulateCreatedByLookupTest(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '1000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Permit_Alcohol');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        
        
        List<Contact> newContacts = TestClassUtility.createContacts(2, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test1+4@adgm.portal';
        insert newContacts;
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];

        test.startTest();
            system.runAs(portalUser){
                insert createdSRList;
            }
        test.stopTest();

    }
    
    static testMethod void PopulateGovernmentAuthorityLookupTest(){
    
        Lookup__c objlkup = new Lookup__c();
        objlkup.Name = 'National Media Council';
        objlkup.Type__c = 'Government Authority';
        insert objlkup;
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '2000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Permit_Alcohol');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].Government_Authority_picklist__c = 'National Media Council';
        
        
        List<Contact> newContacts = TestClassUtility.createContacts(2, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test1+1@adgm.portal';
        insert newContacts;
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        
        test.startTest();
            system.runAs(portalUser){
                insert createdSRList;
            }
        test.stopTest();

    }
    
    static testMethod void getAnnualAmountTest(){
    
        PO_Box_Fees__c pofee = new PO_Box_Fees__c();
        pofee.Name = 'Ezimail Gold';
        pofee.Amount_Per_Month__c = 1000;
        insert poFee;
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '3000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Permit_Alcohol');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        insert createdSRList;
        
        List<Contact> newContacts = TestClassUtility.createContacts(2, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test1+2@adgm.portal';
        insert newContacts;
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        
        test.startTest();
            system.runAs(portalUser){
                ServiceRequestTriggerHelper.getAnnualAmount(1,'Ezimail Gold');
            }
        test.stopTest();

    }
    
    static testMethod void ValidateResidenceVisaPassportTest(){
    
        PO_Box_Fees__c pofee = new PO_Box_Fees__c();
        pofee.Name = 'Ezimail Gold';
        pofee.Amount_Per_Month__c = 1000;
        insert poFee;
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '4000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        Document_Details__c docs = new Document_Details__c();  
        docs.Document_Status__c='Active';
        docs.Document_Type__c= 'Residence Visa';
        docs.Account__c = newAccounts[0].Id;
        docs.Passport_No__c = 'PASS-1234';
        insert docs;
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Employment_Visa_New');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].Passport_Number__c = 'PASS-1234';
        
        
        List<Contact> newContacts = TestClassUtility.createContacts(2, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test1+3@adgm.portal';
        insert newContacts;
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        
        test.startTest();
            system.runAs(portalUser){
                try{
                    insert createdSRList;
                } catch(Exception e){
                }
            }
        test.stopTest();

    }
    
    static testMethod void PopulateNationalityLookupTest(){
    
        Lookup__c objlkup = new Lookup__c();
        objlkup.Name = 'Australia';
        objlkup.Type__c = 'Nationality';
        insert objlkup;
        
        Lookup__c objlkup2 = new Lookup__c();
        objlkup2.Name = 'Austria';
        objlkup2.Type__c = 'Nationality';
        insert objlkup2;
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '5000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        newAccounts[0].Category__c = 'Non-Financial (Category B)';
        insert newAccounts; 

        Business_Activity__c ba  = new Business_Activity__c();
        ba.Entity__c             = newAccounts[0].id;
        ba.Activity_Name__c         = 'Hotel Management';
        insert ba;
            
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Employment_Visa_New');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].Nationality__c = 'Australia';
        
        List<Contact> newContacts = TestClassUtility.createContacts(2, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test++1@adgm.portal';
        insert newContacts;
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        
        test.startTest();
            system.runAs(portalUser){
                insert createdSRList;
                
                createdSRList[0].Nationality__c = 'Austria';
                update createdSRList;
        }
        test.stopTest();

    }
    
    static testMethod void ValidateSR(){
        
        SR_Contact_Auto_Populate_Mapping__c m = new SR_Contact_Auto_Populate_Mapping__c(Name='1',Active__c=true,Contact_Source_Field__c='Name',SR_Target_Field__c='Name');
        SR_Contact_Auto_Populate_Mapping__c m1 = new SR_Contact_Auto_Populate_Mapping__c(Name='2',Active__c=true,Contact_Source_Field__c='ID',SR_Target_Field__c='ID');
        list<SR_Contact_Auto_Populate_Mapping__c> maplst = new list<SR_Contact_Auto_Populate_Mapping__c>{m,m1};
        insert maplst;
                
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '6000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(2, newAccounts[0].Id);
        newContacts[0].Passport_No__c = '123456';
        insert newContacts;
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'New_Work_Permit_Full_Time_Non_Sponsored_Employee');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].Passport_Number__c='1234';
        insert createdSRList;
        ServiceRequestTriggerHelper.queryAllContactFieldsByResidenceVisaNum();
        ServiceRequestTriggerHelper.queryAllContactFields();

    }
    
    static testMethod void validateVisaPeriod()
    {
        test.startTest();
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '7000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        newAccounts[0].Category__c = 'Non-Financial (Category B)';
        insert newAccounts; 
        
        Business_Activity__c ba  = new Business_Activity__c();
        ba.Entity__c             = newAccounts[0].id;
        ba.Activity_Name__c      = 'Hotel Management';
        insert ba;
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Employment_Visa_New');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].Nationality__c = 'Australia';
        createdSRList[0].Visa_Period__c= '1';
        try{
        insert createdSRList;
        ServiceRequestTriggerHelper.validateVisaPeriod(createdSRList);
        
        }catch(exception e){}
        
        
        test.stopTest();
    }
   /* static testMethod void deleteIAtest()
    {
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '8000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        newAccounts[0].Category__c = 'Non-Financial (Category B)';
        insert newAccounts; 
        
        Business_Activity__c ba  = new Business_Activity__c();
        ba.Entity__c             = newAccounts[0].id;
        ba.Activity_Name__c      = 'Hotel Management';
        insert ba;
        test.startTest();
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        insert createdSRList;
            
        List<HexaBPM__Service_Request__c> createdSRList1 = TestUtility.createSR(1,'Initial_Approval');
        createdSRList1[0].HexaBPM__Customer__c = newAccounts[0].Id;
       
        insert createdSRList1;
        
        test.stopTest();
    }*/
    static testMethod void ValidateSR1(){
        
        SR_Contact_Auto_Populate_Mapping__c m = new SR_Contact_Auto_Populate_Mapping__c(Name='1',Active__c=true,Contact_Source_Field__c='Name',SR_Target_Field__c='Name');
        SR_Contact_Auto_Populate_Mapping__c m1 = new SR_Contact_Auto_Populate_Mapping__c(Name='2',Active__c=true,Contact_Source_Field__c='ID',SR_Target_Field__c='ID');
        list<SR_Contact_Auto_Populate_Mapping__c> maplst = new list<SR_Contact_Auto_Populate_Mapping__c>{m,m1};
        insert maplst;
                
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '9000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Passport_No__c = '123456';
        newContacts[0].Gross_Monthly_Salary__c  = 10000;
        newContacts[0].Employment_Status__c='Active';
        newContacts[0].Passport_Expiry_Date__c =system.today()+100;
        insert newContacts;
        
        List<Contact> newContacts1 = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts1[0].Email = 'testttt++@test.com';
        newContacts1[0].Passport_No__c = '123456sdf';
        newContacts1[0].Dependent_Status__c='Active';
        newContacts1[0].Passport_Expiry_Date__c =system.today()+100;
        newContacts1[0].Sponsor__c = newContacts[0].id;
        insert newContacts1;
        test.startTest();
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Dependent_Visa_Renewal');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].Passport_Number__c='1234';
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].id;
        createdSRList[0].Dependent__c = newContacts1[0].id;
        insert createdSRList;
        ServiceRequestTriggerHelper.queryAllContactFieldsByResidenceVisaNum();
        ServiceRequestTriggerHelper.queryAllContactFields();
        ServiceRequestTriggerHelper.getAnnualAmount(1,'Ezimail Gold');
        test.stopTest();
    }
    
    static testMethod void ValidateSR2(){
        
        SR_Contact_Auto_Populate_Mapping__c m = new SR_Contact_Auto_Populate_Mapping__c(Name='1',Active__c=true,Contact_Source_Field__c='Name',SR_Target_Field__c='Name');
        SR_Contact_Auto_Populate_Mapping__c m1 = new SR_Contact_Auto_Populate_Mapping__c(Name='2',Active__c=true,Contact_Source_Field__c='ID',SR_Target_Field__c='ID');
        list<SR_Contact_Auto_Populate_Mapping__c> maplst = new list<SR_Contact_Auto_Populate_Mapping__c>{m,m1};
        insert maplst;
                
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '9000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Passport_No__c = '123456';
        newContacts[0].Gross_Monthly_Salary__c  = 10000;
        newContacts[0].Employment_Status__c='Active';
        newContacts[0].Passport_Expiry_Date__c =system.today()+100;
        insert newContacts;
        
        List<Contact> newContacts1 = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts1[0].Email = 'testttt++@test.com';
        newContacts1[0].Passport_No__c = '123456sdf';
        newContacts1[0].Dependent_Status__c='Active';
        newContacts1[0].Passport_Expiry_Date__c =system.today()+100;
        newContacts1[0].Sponsor__c = newContacts[0].id;
        insert newContacts1;
        test.startTest();
        try{
            List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Establishment_Card_Cancellation');
            createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
            createdSRList[0].Passport_Number__c='1234';
            createdSRList[0].HexaBPM__Contact__c = newContacts[0].id;
            createdSRList[0].Dependent__c = newContacts1[0].id;
            insert createdSRList;
        }catch(exception ex) {
            
        }
        
        
        test.stopTest();
    }
    static testMethod void ADPtestcases()
    {
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Temporary_Fit_Out_Security_Clearance');
        insert createdSRList;
        Address__c address = ADPTestDataFactory.createAddress(createdSRList[0].HexaBPM__Customer__c);
        List<HexaBPM__Service_Request__c> createdSRListIA = TestUtility.createSR(1,'Initial_Approval');
        createdSRListIA[0].HexaBPM__Customer__c = createdSRList[0].HexaBPM__Customer__c;
        insert createdSRListIA;
    }
}