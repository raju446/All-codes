@isTest
public class AcceptCaseControllerTest {
    static testMethod void testAcceptCase(){
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Case[] createdCaseList = TestClassUtility.createCase(new List<Case>{new Case()});
        Profile ManagerProfile = [SELECT Id FROM Profile WHERE Name='CRM Contact Centre Manager'];
        Group grp 			   = [SELECT id FROM Group WHERE DeveloperName= 'CRM_Business_Operations' AND type = 'queue'];
        Group userGroup 	   = [SELECT id FROM Group WHERE DeveloperName= 'CRM_Client_Support_Centre' AND type = 'queue'];
        User u 				   = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId =  ManagerProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUserName);
        insert u;
        
        system.test.startTest();
        Case getCase = AcceptCaseController.getCase(createdCaseList[0].id);
        createdCaseList[0].ownerId = u.id;
        update createdCaseList;
        String test = AcceptCaseController.saveCaseWithOwner(createdCaseList[0].id); //case is owned by another user
        System.runAs(u) {
            String ownertest = AcceptCaseController.saveCaseWithOwner(createdCaseList[0].id); //case owner is accepting the case
			createdCaseList[0].ownerId = grp.id;
            update createdCaseList;
			String queueOwnerTest = AcceptCaseController.saveCaseWithOwner(createdCaseList[0].id);//case owner is a queue
            
        }
        
        createdCaseList[0].ownerId = userGroup.id;
        String ownerID = AcceptCaseController.getUserId();
        String acceptingCase = AcceptCaseController.releaseCaseToQueue(createdCaseList[0].id); //case is owned by another user
        createdCaseList[0].ownerId = u.id;
        update createdCaseList;
        System.runAs(u) {
            String acceptingCaseAsUser = AcceptCaseController.releaseCaseToQueue(createdCaseList[0].id);//case owner is accepting the case 
        }
        
        
        List<ListView> testList = AcceptCaseController.getListViews();
        system.test.stopTest();
    }
}