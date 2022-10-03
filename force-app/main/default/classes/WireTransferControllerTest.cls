@isTest
public with sharing class WireTransferControllerTest {
    
    public static testmethod void TestWireTransferController(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        //newContacts[1].Portal_User_Creation__c = true;
        
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        //newContacts[1].Community_Username__c = 'test2@adgm.portal';
        insert newContacts;  
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        //User portalUser2 = [SELECT Id, isActive, ContactId FROM User WHERE ContactId = :newContacts[1].Id];
        
        system.runAs(portalUser){
            system.currentPageReference().getParameters().put('amount', '500');
            WireTransferController wtc = new WireTransferController();
            wtc.fileUploadAtt.Name = 'Test.jpg';
            wtc.fileUploadAtt.Body = Blob.valueof('Tester');
            wtc.selectedContenttype = 'jpg';
            wtc.amountStr = '500';
            wtc.bankTransRefNum = 'TRA-8743524';
            wtc.cancel();
            wtc.saveReceipt();  
        }   
    }
    
    public static testmethod void TestWireTransferController2(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].FirstName = newContacts[0].FirstName + '7';
        newContacts[0].Portal_User_Creation__c = true;
        //newContacts[1].Portal_User_Creation__c = true;
        
        newContacts[0].Community_Username__c = 'test7@adgm.portal';
        //newContacts[1].Community_Username__c = 'test2@adgm.portal';
        insert newContacts;  
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        //User portalUser2 = [SELECT Id, isActive, ContactId FROM User WHERE ContactId = :newContacts[1].Id];
        
        system.runAs(portalUser){
            WireTransferController wtc = new WireTransferController();
            
            wtc.amountStr = '123';
            wtc.bankTransRefNum = '456';
            wtc.fileUploadAtt.Body = Blob.valueof('Tester');
            wtc.fileUploadAtt.Name = 'Test.jpg';
            wtc.cancel();
            wtc.saveReceipt();              
        }   
    }
    public static testmethod void TestWireTransferControllerCatch(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].FirstName = newContacts[0].FirstName + '6';
        //newContacts[1].Portal_User_Creation__c = true;
        
        newContacts[0].Community_Username__c = 'test6@adgm.portal';
        //newContacts[1].Community_Username__c = 'test2@adgm.portal';
        insert newContacts;  
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        //User portalUser2 = [SELECT Id, isActive, ContactId FROM User WHERE ContactId = :newContacts[1].Id];
        
        system.runAs(portalUser){
            WireTransferController wtc = new WireTransferController();
            
            wtc.amountStr = '123';
            wtc.bankTransRefNum = '456';
            wtc.fileUploadAtt.Body = Blob.valueof('Tester');
            wtc.cancel();
            wtc.saveReceipt();              
        }   
    }
    public static testmethod void TestWireTransferController3(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].FirstName = newContacts[0].FirstName + '3';
        //newContacts[1].Portal_User_Creation__c = true;
        
        newContacts[0].Community_Username__c = 'test3@adgm.portal';
        //newContacts[1].Community_Username__c = 'test2@adgm.portal';
        insert newContacts;  
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        //User portalUser2 = [SELECT Id, isActive, ContactId FROM User WHERE ContactId = :newContacts[1].Id];
        
        system.runAs(portalUser){
            String str = '-20';
            system.currentPageReference().getParameters().put('amount',str);
            
            WireTransferController wtc = new WireTransferController();
            
            //wtc.amountStr = '123';
            wtc.bankTransRefNum = '456';
            wtc.fileUploadAtt.Body = Blob.valueof('Tester');
            wtc.fileUploadAtt.Name = 'Test.jpg';
            wtc.cancel();
            wtc.saveReceipt();              
        }   
    }
    public static testmethod void TestWireTransferController4(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].FirstName = newContacts[0].FirstName + '4';
        //newContacts[1].Portal_User_Creation__c = true;
        
        newContacts[0].Community_Username__c = 'test4@adgm.portal';
        //newContacts[1].Community_Username__c = 'test2@adgm.portal';
        insert newContacts;  
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        //User portalUser2 = [SELECT Id, isActive, ContactId FROM User WHERE ContactId = :newContacts[1].Id];
        
        system.runAs(portalUser){
            String str = '400000';
            system.currentPageReference().getParameters().put('amount',str); 
            
            WireTransferController wtc = new WireTransferController();
            
            //wtc.amountStr = '123';
            wtc.bankTransRefNum = '456';
            wtc.fileUploadAtt.Body = Blob.valueof('Tester');
            wtc.fileUploadAtt.Name = 'Test.jpg';
            wtc.cancel();
            wtc.saveReceipt();              
        }   
    }
    public static testmethod void TestWireTransferController5(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].FirstName = newContacts[0].FirstName + '5';
        //newContacts[1].Portal_User_Creation__c = true;
        
        newContacts[0].Community_Username__c = 'test5@adgm.portal';
        //newContacts[1].Community_Username__c = 'test2@adgm.portal';
        insert newContacts;  
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        //User portalUser2 = [SELECT Id, isActive, ContactId FROM User WHERE ContactId = :newContacts[1].Id];
        
        system.runAs(portalUser){
            system.currentPageReference().getParameters().put('amount', '500');
            WireTransferController wtc = new WireTransferController();
            wtc.fileUploadAtt.Name = 'Test.jpg';
            wtc.fileUploadAtt.Body = Blob.valueof('Tester');
            wtc.selectedContenttype = 'jpg';
            wtc.amountStr = '500';
            wtc.bankTransRefNum = 'TRA-8743524';
            wtc.iFileSize = 2048576;
            wtc.cancel();
            wtc.saveReceipt();  
        }   
    }
    
}