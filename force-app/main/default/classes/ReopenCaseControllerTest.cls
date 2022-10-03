@isTest
public class ReopenCaseControllerTest {
    static testMethod void TestReopen(){
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile ManagerProfile = [SELECT Id FROM Profile WHERE Name='CRM Contact Centre Manager'];
        User u 				   = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId =  ManagerProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName= uniqueUserName);
        insert u;
        
        Test.startTest();
        
        Case[] createdCaseList = TestClassUtility.createCase(new List<Case>{new Case()});
        createdCaseList[0].origin = 'Email';
        update createdCaseList[0];
       
        ReopenCaseController testt = new ReopenCaseController();
        testt.getItems();
        
        string encrpyt = ApexCodeUtility.getEncryptedValue(createdCaseList[0].id);
       
        ApexPages.currentPage().getParameters().put('caseId', encrpyt);
        ApexPages.currentPage().getParameters().put('email', String.valueOf('test@gmail.com'));
        ApexPages.currentPage().getParameters().put('reply', String.valueOf('yes'));
        testt.reopenCaseEmail();
        
       
        
            
        map<boolean,string> testMap 	          = ReopenCaseController.ReopenData(createdCaseList[0].id);
        String testReturnError      			  = ReopenCaseController.reopenCase(createdCaseList[0].id,'test');
        createdCaseList[0].CRM_Case_Resolution__c = 'smaple';
        createdCaseList[0].OwnerId                =  u.id;
        createdCaseList[0].Status				  = 'Closed';
        update createdCaseList;
        
        map<boolean,string> testMap2              = ReopenCaseController.ReopenData(createdCaseList[0].id);
        String testReturn 						  = ReopenCaseController.reopenCase(createdCaseList[0].id,'test');
        
        createdCaseList[0].Status				  = 'Closed';
        update createdCaseList;
        testt.selectedValue = 'Needs additional new information' ;
        testt.comments = 'test';
        
        ApexPages.currentPage().getParameters().put('caseId', createdCaseList[0].id);
        ApexPages.currentPage().getParameters().put('email', String.valueOf('test@gmail.com'));
        ApexPages.currentPage().getParameters().put('reply', String.valueOf('yes'));
        testt.reopenCaseEmail();
        
    	Test.stopTest(); 
     	
    }
    
    static testMethod void TestReopen_CreateSubcase(){
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile ManagerProfile = [SELECT Id FROM Profile WHERE Name='CRM Contact Centre Manager'];
        User u 				   = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId =  ManagerProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName= uniqueUserName);
        insert u;
        
        Test.startTest();
        
        Case[] createdCaseList = TestClassUtility.createCase(new List<Case>{new Case()});
        createdCaseList[0].origin = 'Email';
        update createdCaseList[0];
       
        ReopenCaseController testt = new ReopenCaseController();
        testt.getItems();
        
        string encrpyt = ApexCodeUtility.getEncryptedValue(createdCaseList[0].id);
       
        ApexPages.currentPage().getParameters().put('caseId', encrpyt);
        ApexPages.currentPage().getParameters().put('email', String.valueOf('test@gmail.com'));
        ApexPages.currentPage().getParameters().put('reply', String.valueOf('yes'));
        testt.reopenCaseEmail();
        
       
        
            
        map<boolean,string> testMap 	          = ReopenCaseController.ReopenData(createdCaseList[0].id);
        String testReturnError      			  = ReopenCaseController.reopenCase(createdCaseList[0].id,'test');
        createdCaseList[0].CRM_Case_Resolution__c = 'smaple';
        createdCaseList[0].OwnerId                =  u.id;
        createdCaseList[0].Status				  = 'Closed';
        update createdCaseList;
        
        map<boolean,string> testMap2              = ReopenCaseController.ReopenData(createdCaseList[0].id);
        String testReturn 						  = ReopenCaseController.reopenCase(createdCaseList[0].id,'test');
        
        createdCaseList[0].Status				  = 'Closed';
        update createdCaseList;
        testt.selectedValue = 'My case was not resolved successfully' ;
        testt.comments = 'test';
        
        ApexPages.currentPage().getParameters().put('caseId', createdCaseList[0].id);
        ApexPages.currentPage().getParameters().put('email', String.valueOf('test@gmail.com'));
        ApexPages.currentPage().getParameters().put('reply', String.valueOf('yes'));
        testt.reopenCaseEmail();
        
    	Test.stopTest(); 
     	
    }
}