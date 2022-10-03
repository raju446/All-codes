@isTest
public with sharing class TradeNameTriggerHandlerTest {
    private static  List<Account> createdAccountList; 
    public static testmethod void TestTradeNameTriggerHandler(){
    	
    	HexaBPM__SR_Status__c srStatusSubmitted = new HexaBPM__SR_Status__c();
    	srStatusSubmitted.HexaBPM__Code__c = 'SUBMITTED';
    	
    	insert srStatusSubmitted;
    	
    	createdAccountList = TestClassUtility.createAccounts(1);
    	createdAccountList[0].License_Expiry_Date__c = system.today();
    	insert createdAccountList;
    	
    	
    	test.startTest();
	    	Trade_Name__c tradename = new Trade_Name__c();
	    	tradename.Entity__c = createdAccountList[0].Id;
	    	tradename.Name_in_English__c = 'TEST1';
	    	tradename.Primary__c = true;
	    	insert tradename;
	    	
	    	Trade_Name__c tradename1 = new Trade_Name__c();
	    	//tradename.Entity__c = createdAccountList[0].Id;
	    	//tradename.Primary__c = true;
	    	insert tradename1;
	    	
	    	tradename.Primary__c = false;
	    	update tradename1;
    	test.stopTest();
    	
    }    
     public static testmethod void TestTradeNameTriggerHandler2(){
    	
    	HexaBPM__SR_Status__c srStatusSubmitted = new HexaBPM__SR_Status__c();
    	srStatusSubmitted.HexaBPM__Code__c = 'SUBMITTED';
    	
    	insert srStatusSubmitted;
    	
    	createdAccountList = TestClassUtility.createAccounts(1);
    	createdAccountList[0].License_Expiry_Date__c = system.today();
    	insert createdAccountList;
    	 
    	
    	test.startTest();
	    	Trade_Name__c tradename = new Trade_Name__c();
	    	tradename.Entity__c = createdAccountList[0].Id;
	    	tradename.Name_in_English__c = 'TEST1';
	    	tradename.Primary__c = false;
	    	insert tradename;
	    	
	    	Trade_Name__c tradename1 = new Trade_Name__c();
	    	//tradename.Entity__c = createdAccountList[0].Id;
	    	//tradename.Primary__c = true;
	    	insert tradename1;
	    	
	    	tradename.Primary__c = true;
	    	update tradename;
    	test.stopTest();
    	
    }    
}