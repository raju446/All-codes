@isTest
public with sharing class AlertsListControllerTest {
    private static  List<Account> createdAccountList; 
    private static  List<Contact> createdContactList; 
   	public static testmethod void testcase(){
    	
    	createdAccountList = TestClassUtility.createAccounts(1);
    	insert createdAccountList;
    	
    	createdContactList = TestClassUtility.createContacts(1,createdAccountList[0].Id);
    	insert createdContactList;
    	
    	String recId = Schema.Sobjecttype.Notice__c.getRecordTypeInfosByName().get('Alert').getRecordTypeId();
       	
       	Notice__c ntc = new Notice__c();
    	ntc.RecordTypeId = recId;
    	ntc.Entity__c = createdAccountList[0].Id;
    	ntc.Start_Date__c = system.today();
    	ntc.Type__c = 'Company Alert';
    	ntc.Alert_Text__c = 'test';
    	ntc.Status__c = 'Active';
    	ntc.End_Date__c = system.today();
    	ntc.Severity__c = 'High';
    	ntc.Available_for__c = 'Company User';
    	insert ntc;
        system.debug('----------------' + ntc.Id);
        AlertsListController cobj = new AlertsListController();	 
        cobj.getAlerts();
        cobj.refresh();
        cobj.getTotalPages();
    }
    
}