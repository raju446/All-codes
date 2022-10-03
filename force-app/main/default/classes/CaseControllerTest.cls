@isTest
public class CaseControllerTest {
    static testMethod void TestCaseLeadCreation(){
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
    	Case[] createdCaseList = TestClassUtility.createCase(new List<Case>{new Case()});
    	Profile ManagerProfile = [SELECT Id FROM Profile WHERE Name='CRM Contact Centre Manager'];
    	User u 				   = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                      LocaleSidKey='en_US', ProfileId =  ManagerProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUserName);
    	insert u;
        
        CaseController.getCaseInfo(createdCaseList[0].id);
    }
}