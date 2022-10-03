@isTest
public with sharing class PaymentFormCtrlrTest {
    
    public static testmethod void TestPaymentFormCtrlr(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
                    
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        insert newContacts;  
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        
        
        system.runAs(portalUser){
        
            CyberSource__c cy = new CyberSource__c();
            cy.Name = 'testcenter';
            cy.Accesskey__c = '24e935fea7893b89b0b9e5187c8c2f09';
            cy.ProfileId__c = '43C4103F-EA01-49C6-923F-820D0221066F';
            insert cy;
            PaymentFormCtrlr pfc = new PaymentFormCtrlr();
            
        } 
 
    }
}