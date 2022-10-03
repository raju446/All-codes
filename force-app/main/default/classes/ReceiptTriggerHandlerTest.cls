@isTest
public with sharing class ReceiptTriggerHandlerTest {
	
    public static testmethod void TestReceiptTriggerHandler(){
        Exchange_Rate__c er = new Exchange_Rate__c(USD_To_AED_Conversion_Rate__c = 3.6725,Conversion_Date__c = Date.today());
        insert er;
        OU_Basd_Invoice_Running_Number__c rn = new OU_Basd_Invoice_Running_Number__c(name = 'fsra',Operating_Unit__c = '103', Type__c = 'Receipt',Running_Number__c =1);
        insert rn;
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        acc[0].Oracle_site_id__c = '103';
        insert acc;
    	Receipt__c recp = new Receipt__c(entity__c = acc[0].id);
    	recp.Status__c='Success';
        recp.GL_Date__c = Date.today();
        recp.Payment_Method__c = 'Electronic Funds Transfer';
        insert recp;    	
    	ReceiptTriggerHandler rth = new ReceiptTriggerHandler();
    	recp.Status__c='Approved';
        recp.Generate_Receipt__c = true;
        recp.Document_Version__c = 0;
    	update recp;
    	ReceiptTriggerHandler.Execute_BI(new list<Receipt__c> ());
    	ReceiptTriggerHandler.Execute_BU(new list<Receipt__c> (),new map<Id,Receipt__c>()); 
    }
    
}