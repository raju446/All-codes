@isTest
public with sharing class NotificationPictureControllerTest {
    
    private static List<Notice__c> noticeList;  
    
    public static void init(){
    	
    	List<Account> newAccounts = TestClassUtility.createAccounts(1);
		insert newAccounts; 
		
		noticeList = TestClassUtility.createNotice(new List<Notice__c>{new Notice__c (Entity__c = newAccounts[0].Id)});  
    	
    }
    
    public static testmethod void TestNotificationPictureController(){
    	init();
    	system.currentPageReference().getParameters().put('Id', noticeList[0].Id);
    	NotificationPictureController npc = new NotificationPictureController(new ApexPages.StandardController(noticeList[0]));
    	npc.strCroppedData = 'base64,1234';
    	npc.SaveCroppedImage();
    	npc.ContactId ='tester';
    	
    }    
}