@isTest
public with sharing class PortalSidebarControllerTest {
    
    public static testmethod void TestPortalSidebarController1(){
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Total_Visas_Used__c = 3;
        newAccounts[0].Total_Visas_Allowed__c = 5;
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].HexaBPM__Portal_Balance__c = 250;
        insert newAccounts; 
            
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        
        newContacts[0].Community_Username__c = 'test1+@adgm.portal';
        insert newContacts;  
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        
        
        system.runAs(portalUser){
                        
            PortalSidebarController psc = new PortalSidebarController();
            psc.FetchBalanceFromOracle();
            list<string> lstAccessibleService = new list<string>();
            lstAccessibleService.add('Company Services');
            psc.getAccessibleServicesMenu(lstAccessibleService);
        } 
 
    }
    
}