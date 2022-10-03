@isTest
public class LEX_BackToObjectRecordPageControllerTest {
    
    
    
    public static testmethod void test1(){
        
        
        
        
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile ManagerProfile = [SELECT Id FROM Profile WHERE Name='CRM Contact Centre Manager'];
        User u                 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                          LocaleSidKey='en_US', ProfileId =  ManagerProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUserName);
        insert u;
        
        system.Test.startTest();
        
        Case[] createdCaseList = TestClassUtility.createCase(new List<Case>{new Case()});
        createdCaseList[0].OwnerId                =  u.id;
        
        task taskObj = new task(); 
        taskObj.OwnerId                =  u.id;
        insert taskObj;
        
        LEX_BackToObjectRecordPageController.RequestWrap reqWrapper = new LEX_BackToObjectRecordPageController.RequestWrap();
        LEX_BackToObjectRecordPageController.RespondWrap repWrapper = new LEX_BackToObjectRecordPageController.RespondWrap();
        
        reqWrapper.parentRecId = taskObj.Id;
        
        String requestString = JSON.serialize(reqWrapper);
        
        LEX_BackToObjectRecordPageController.fetchRelatedObject(requestString);    
        
    }
    
    
}