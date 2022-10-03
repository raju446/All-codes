@isTest
public with sharing class AnnouncementImageUploadControllerTest {
    private static  List<Account> createdAccountList; 
    private static  List<Notice__c> createdNoticeList; 
    private static  List<Contact> createdContactList; 
   	public static void init(){
   		createdAccountList = TestClassUtility.createAccounts(1);
    	insert createdAccountList;
    	createdContactList = TestClassUtility.createContacts(1,createdAccountList[0].Id);
    	createdContactList[0].Profile_Picture_Id__c = 'test123';
    	insert createdContactList;
    	createdNoticeList = TestClassUtility.createNotice(
								new List<Notice__c>{
									new Notice__c(Entity__c = createdAccountList[0].Id)});
   	}	
   	public static testmethod void TestAnnouncementImageUploadControllerTest(){
      	//ApexPages.currentPage().getParameters().put('id',ntc.Id);
      	init();
      	String id = createdContactList[0].Id;
    	ApexPages.StandardController ssc = new ApexPages.StandardController(createdNoticeList[0]);
    	AnnouncementImageUploadController aic = new AnnouncementImageUploadController(ssc);
    	aic.strCroppedData = 'base64, iVBORw0KGgoAAAANSUhEUgAAAAUA AAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==';
    	aic.SaveCroppedImage();
    	aic.addContactPhoto(id);
    	aic.Cancel();
    	 
    }
}