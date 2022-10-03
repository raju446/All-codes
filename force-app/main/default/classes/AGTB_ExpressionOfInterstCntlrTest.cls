/*
@Author: Azmath
@Description : Test class for AGTB_ExpressionOfInterstCntlr class
*/

@isTest
public with sharing class AGTB_ExpressionOfInterstCntlrTest
{
 	@testSetup
    static void init()
    {
    	List<Account> newAccounts 	= TestClassUtility.createAccounts(1);
     	newAccounts[0].Category__c 	= 'Non-Financial (Category B)';
        insert newAccounts;
        
        Business_Activity__c act = new Business_Activity__c(Activity_Name__c='test', Activity_Code__c='000786-6210', Entity__c=newAccounts[0].id);
        insert act; 
        
        AGTB_Activity_Codes__c cset = new AGTB_Activity_Codes__c(Name='6210');
        insert cset;
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Profile_Picture_Id__c = '12345';
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Is_Guest_User__c = false;
        newContacts[0].Community_Username__c = 'agtbtest2@adgm.portal';
        insert newContacts;
    }
    static testMethod void testEoIForm()
    {
    	Contact con = [Select id from Contact];
    	User portalUser = [SELECT Id FROM User WHERE ContactId = :con.Id];
    	test.startTest();
        system.runAs(portalUser)
        {
        	test.setMock(HttpCalloutMock.class, new AGTB_MockHttpResponseEoI());
        	AGTB_Client_On_Board__c cob 	= new AGTB_Client_On_Board__c();
        	ApexPages.standardController sc = new Apexpages.standardController(cob);
        	AGTB_ExpressionOfInterstCntlr eoi = new AGTB_ExpressionOfInterstCntlr(sc);
        	eoi.dosave();
        }
        test.stopTest();
    }
    static testMethod void testEoIFormValidaion1()
    {
    	Contact con = [Select id from Contact];
    	User portalUser = [SELECT Id FROM User WHERE ContactId = :con.Id];
    	Business_Activity__c act = [Select Activity_Code__c from Business_Activity__c limit 1];
    	act.Activity_Code__c='1234';
    	update act;
    	
    	test.startTest();
        system.runAs(portalUser)
        {
        	test.setMock(HttpCalloutMock.class, new AGTB_MockHttpResponseEoI());
        	AGTB_Client_On_Board__c cob 	= new AGTB_Client_On_Board__c();
        	ApexPages.standardController sc = new Apexpages.standardController(cob);
        	AGTB_ExpressionOfInterstCntlr eoi = new AGTB_ExpressionOfInterstCntlr(sc);
        	eoi.dosave();
        }
        test.stopTest();
    }
    static testMethod void testEoIFormValidaion2()
    {
    	Contact con = [Select id,Accountid from Contact];
    	User portalUser = [SELECT Id FROM User WHERE ContactId = :con.Id];
    	
    	AGTB_Client_On_Board__c co = new AGTB_Client_On_Board__c(Entity_name__c=con.Accountid);
    	insert co;
    	
    	test.startTest();
        system.runAs(portalUser)
        {
        	test.setMock(HttpCalloutMock.class, new AGTB_MockHttpResponseEoI());
        	AGTB_Client_On_Board__c cob 	= new AGTB_Client_On_Board__c();
        	ApexPages.standardController sc = new Apexpages.standardController(cob);
        	AGTB_ExpressionOfInterstCntlr eoi = new AGTB_ExpressionOfInterstCntlr(sc);
        	eoi.dosave();
        }
        test.stopTest();
    }
}