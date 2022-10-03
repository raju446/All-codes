@isTest
public class ServiceRequestViewControllerTest {
    
    private static List<HexaBPM__Service_Request__c> createdSRList;
	@isTest
    public static void runTest(){
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
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        system.runAs(portalUser){
        	ApexPages.currentpage().getParameters().put('Id',createdSRList[0].id);
            ServiceRequestViewController controller = new ServiceRequestViewController();
            controller.checkAccessibility();
        }
    }
}