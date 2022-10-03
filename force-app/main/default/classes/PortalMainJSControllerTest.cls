@isTest
public with sharing class PortalMainJSControllerTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    
    public static testmethod void TestPortalMainJSController(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].EChannel_Expiry_Date__c = system.today ();
        newAccounts[0].Establishment_Card_Expiry_Date__c = system.today ();
        newAccounts[0].Establishment_Card_Issue_Date__c = system.today ();
        insert newAccounts; 
            
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        insert newContacts;  
        
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        insert createdSRList;
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        
        
        system.runAs(portalUser){
            
            TranslateFields__c tf = new TranslateFields__c();
            tf.Destination__c = 'Test1';
            tf.Source__c = 'Test123';   
            tf.Name = 'trans';   
            insert tf;
            
            system.currentPageReference().getParameters().put('srID',createdSRList[0].Id);
            system.currentPageReference().getParameters().put('srType','Initial_Approval');
            PortalMainJSController pmc = new PortalMainJSController();
            pmc.getSRDetail();
        
        } 
 
    }
}