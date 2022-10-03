@isTest
public with sharing class NoticeTriggerHandlerTest {
    
    private static  List<Account> createdAccountList; 
    private static Notice__c notice ;  
    
    public static void init(){
        createdAccountList = TestClassUtility.createAccounts(1);
        createdAccountList [0].Oracle_Party_Id__c = '000001';
        insert createdAccountList;
        
        List<Recordtype> rectype = [SELECT Id FROM Recordtype WHERE SObjectType = 'Notice__c' AND DeveloperName = 'Announcement' LIMIT 1];
    
        notice = new Notice__c();
        notice.recordtypeId = rectype[0].Id;
        notice.Publish__c = true;
    }   
    public static testmethod void NoticeTriggerHandlerTest(){
        init();
        insert notice;
        
        update notice;
    }
    
}