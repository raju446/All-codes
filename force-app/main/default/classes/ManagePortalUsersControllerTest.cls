/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ManagePortalUsersControllerTest {
    
    private static  List<Contact> createdContactList; 
    private static  List<Account> createdAccountList; 
    private static HexaBPM__SR_Template_Docs__c createdSRTempDocList;
    
    static testMethod void managePortalLoadTest() {
        
        HexaBPM__Document_Master__c hdm = new HexaBPM__Document_Master__c();
        hdm.Name = 'Work Resume';
        hdm.HexaBPM__Code__c = 'WORK_RESUME';
        insert hdm;
        
        HexaBPM__SR_Template__c hst = new HexaBPM__SR_Template__c();
        hst.HexaBPM__Active__c = true;
        hst.HexaBPM__SR_RecordType_API_Name__c = 'User_Access_Request_for_Registered_Company';
        insert hst;
        
        createdSRTempDocList = new HexaBPM__SR_Template_Docs__c();
        createdSRTempDocList.HexaBPM__Added_through_Code__c = true;
        createdSRTempDocList.HexaBPM__Document_Master__c = hdm.Id;
        createdSRTempDocList.HexaBPM__SR_Template__c = hst.Id;
        createdSRTempDocList.HexaBPM__Document_Description_External__c = 'Test';
        createdSRTempDocList.HexaBPM__On_Submit__c = true;
        insert createdSRTempDocList;
       
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(2, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[1].Portal_User_Creation__c = true;
        
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        newContacts[1].Community_Username__c = 'test2@adgm.portal';
        insert newContacts;  
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        User portalUser2 = [SELECT Id, isActive, ContactId FROM User WHERE ContactId = :newContacts[1].Id];
        
        
        system.runAs(portalUser){
            Test.startTest();
                //intantiate controller class
                ManagePortalUsersController managePortal = new ManagePortalUsersController();
                
                //deactivate other portal user
                managePortal.selectedUserId = portalUser2.Id;
                managePortal.userAction = 'Deactivate';
                managePortal.userUpdate();
                List<User> portalUserCheck1 = [SELECT Id, isActive FROM User WHERE Id = :portalUser2.Id];
                System.assertEquals(false, portalUserCheck1[0].isActive);
                
                //activate other portal user
                managePortal.selectedUserId = portalUser2.Id;
                managePortal.userAction = 'Activate';
                managePortal.userUpdate();
                List<User> portalUserCheck2 = [SELECT Id, isActive FROM User WHERE Id = :portalUser2.Id];
                System.assertEquals(false, portalUserCheck2[0].isActive);
                
                //edit and save contact details
                managePortal.existContactId = portalUser2.ContactId;
                managePortal.editContact();
                managePortal.objCon.FirstName = 'Test Contact Name';
                managePortal.saveContact();
                List<Contact> contactCheck = [SELECT Id, FirstName FROM Contact WHERE Id = :portalUser2.ContactId];
                System.assertEquals('FirstName2', contactCheck[0].FirstName);
                
                //create and save new contact details
                managePortal.createNewContact();
                managePortal.objCon.LastName = 'New LName';
                managePortal.objCon.FirstName = 'NewLastName';
                managePortal.objCon.Email = 'testNew@test.com'; 
                managePortal.invalidFileMsg = '';
                managePortal.hasError = false;
                //List<managePortal.DocumentDetailsCls> ls2 = new List<managePortal.DocumentDetailsCls>(managePortal.lstDocuments)
                for(ManagePortalUsersController.DocumentDetailsCls doc : managePortal.lstDocuments){
                    doc.objAttachment.Body = Blob.valueOf('Test Data');
                }
                managePortal.saveContact();
                
                //add new user and cancel
                managePortal.createNewContact();
                managePortal.cancelDetail();
                //
                
                
                //managePortal.userAdminUpdate();
                managePortal.userAdminAction = 'Promote';
                managePortal.UpdateAccessType();
                managePortal.checkDocuments();
                managePortal.createSRDoc();
                managePortal.checkUname();
                managePortal.fieldValidation();
            Test.stopTest();
        }
        
        
    }
    static testMethod void managePortalLoadTest1(){
        
            Test.startTest();
            ManagePortalUsersController managePortal = new ManagePortalUsersController();
            managePortal.objSR.Title__c = 'Mr.';
            managePortal.objSR.First_Name__c = 'Test';
            managePortal.objSR.Last_Name__c = 'Test1';
            managePortal.objSR.Date_of_Birth__c = system.today().addYears(-20);
            managePortal.objSR.HexaBPM__Email__c = 'Test81723713@test.com';
            managePortal.guestUsername = 'usertest0001';
            
            
            createdAccountList = TestClassUtility.createAccounts(1);
            insert createdAccountList;
            createdContactList = TestClassUtility.createContacts(1,createdAccountList[0].Id);
            
            managePortal.objCon = createdContactList[0];
            managePortal.saveContact();
            ManagePortalUsersController.DocumentDetailsCls d = new ManagePortalUsersController.DocumentDetailsCls();
            Test.stopTest();
        
    }
    
    static testMethod void managePortalLoadTest2(){
        
            Test.startTest();
            ManagePortalUsersController managePortal = new ManagePortalUsersController();
            managePortal.objSR.Title__c = 'Mr.';
            managePortal.objSR.First_Name__c = 'Test';
            managePortal.objSR.Last_Name__c = 'Test1';
            managePortal.objSR.Date_of_Birth__c = system.today().addYears(-20);
            managePortal.objSR.HexaBPM__Email__c = 'Test1231313@test.com';
            managePortal.objSR.HexaBPM__Send_SMS_to_Mobile__c = '+971564747474';
            managePortal.guestUsername = 'usertest0001';
            
            managePortal.checkUname();
            
            managePortal.saveContact();
            //ManagePortalUsersController.DocumentDetailsCls d = new ManagePortalUsersController.DocumentDetailsCls();
            Test.stopTest();
        
    }
}