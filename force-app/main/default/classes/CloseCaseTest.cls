@isTest
public class CloseCaseTest {
    
    static testMethod void TestCloseCase(){
        
    String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
    Profile ManagerProfile = [SELECT Id FROM Profile WHERE Name='CRM Contact Centre Manager'];
    User u 				   = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                      LocaleSidKey='en_US', ProfileId =  ManagerProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUserName);
    insert u;
        
    system.Test.startTest();
        
    Case[] createdCaseList = TestClassUtility.createCase(new List<Case>{new Case()});
    createdCaseList[0].OwnerId                =  u.id;
    update createdCaseList;
    map<boolean,string> testMap1 	          = CloseCase.CloseCaseAccsess(createdCaseList[0].id);//owner doesnot belog to the queue
    System.runAs (u){
    	map<boolean,string> testMap2 	      = CloseCase.CloseCaseAccsess(createdCaseList[0].id);//owner belongs to the queue       
    }
    
    createdCaseList[0].CRM_Case_Resolution__c = 'smaple';
    createdCaseList[0].Status				  = 'Closed';
    update createdCaseList;
    map<boolean,string> testMap3 	          = CloseCase.CloseCaseAccsess(createdCaseList[0].id); // case is closed
        
    String test = CloseCase.closeCase(createdCaseList[0].id,'sample'); 
    List<QuickText> listQuickText = CloseCase.fetchQuickText();   
    system.Test.stopTest();
    }
}