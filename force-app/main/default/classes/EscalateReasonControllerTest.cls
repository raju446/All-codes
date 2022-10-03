@isTest
public class EscalateReasonControllerTest {
    static testMethod void testEscalate(){
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
     	Case[] createdCaseList = TestClassUtility.createCase(new List<Case>{new Case()});
        Profile ManagerProfile = [SELECT Id FROM Profile WHERE Name='CRM Contact Centre Manager'];
        Group grp 			   = [SELECT id FROM Group WHERE DeveloperName= 'CRM_Business_Operations' AND type = 'queue'];
        User u 				   = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId =  ManagerProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName= uniqueUserName);
        insert u;
        map<boolean,string> testMap = EscalateReasonController.EscalateData(createdCaseList[0].id);
        String testReturnError      = EscalateReasonController.changeOwner(createdCaseList[0].id,'test');

        Test.startTest();
        createdCaseList[0].OwnerId  =  u.id;
        update createdCaseList;
        System.runAs(u) {
			map<boolean,string> testMap1 = EscalateReasonController.EscalateData(createdCaseList[0].id);
            createdCaseList[0].Status    = 'Escalated';
			update createdCaseList;  
            map<boolean,string> testMap2 = EscalateReasonController.EscalateData(createdCaseList[0].id);
            createdCaseList[0].
                CRM_Case_Resolution__c 	 = 'test';
            createdCaseList[0].status    = 'Closed'; 
            update createdCaseList; 
        Test.stopTest();
            map<boolean,string> testMap3 = EscalateReasonController.EscalateData(createdCaseList[0].id);
            String testReturnError2      = EscalateReasonController.changeOwner(createdCaseList[0].id,'test');
            
        }
        
       
        
    }
    
    
}