/**
*   Author      : Azmath
*   Descritpion : Test class for ICADocumentTriggeHandler
*/
@isTest
private class ICADocumentTriggeHandler_Test
{
	@testSetup
	public static void init()
	{
		Account acc 					= ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        HexaBPM__Service_Request__c sr 	= ICA_TestDataFactory.CreateInitialApprovalSR(acc.id);
        HexaBPM__Service_Request__c sr1 = ICA_TestDataFactory.CreateNewEstbSR(acc.id);
	}
    static testMethod void ICADocumentTriggeHandlertest()
    {
    	Account acc = [Select id from Account limit 1];
        HexaBPM__Service_Request__c sr 	= [Select id from HexaBPM__Service_Request__c where HexaBPM__Record_Type_Name__c='Initial_Approval' limit 1];
        HexaBPM__Service_Request__c sr1 = [Select id from HexaBPM__Service_Request__c where HexaBPM__Record_Type_Name__c='Establishment_Card_New' limit 1];
        
        ICA_Document__c ica = new ICA_Document__c(Attachment_Type_Text__c='COPY OF RESIDENCY',Service_Request__c=sr.id);
        insert ica;
        
        ICA_Document__c ica1 = new ICA_Document__c(Attachment_Type_Text__c='AMIRI DECREE',Service_Request__c=sr1.id);
        insert ica1;
    }
    static testMethod void ICADocumentTriggeHandlerTLtest()
    {
    	Account acc = [Select id from Account limit 1];
        HexaBPM__Service_Request__c sr 	= [Select id from HexaBPM__Service_Request__c where HexaBPM__Record_Type_Name__c='Initial_Approval' limit 1];
        
        ICA_Document__c ica = new ICA_Document__c(Attachment_Type_Text__c='TRADE LICENSE',Service_Request__c=sr.id);
        insert ica;
        ICA_Document__c ica1 = new ICA_Document__c(Attachment_Type_Text__c='EXCEPTIONAL ATTACHMENT NO 1',Service_Request__c=sr.id);
        insert ica1;
        ICA_Document__c ica2 = new ICA_Document__c(Attachment_Type_Text__c='EXCEPTIONAL ATTACHMENT NO 2',Service_Request__c=sr.id);
        insert ica2;
    }
    static testMethod void ICADocumentTriggeHandlerEsttest()
    {
    	Account acc = [Select id from Account limit 1];
        HexaBPM__Service_Request__c sr = [Select id from HexaBPM__Service_Request__c where HexaBPM__Record_Type_Name__c='Establishment_Card_New' limit 1];
        
        ICA_Document__c ica = new ICA_Document__c(Attachment_Type_Text__c='Establishment_Card_New',Service_Request__c=sr.id);
        insert ica;
        ICA_Document__c ica1 = new ICA_Document__c(Attachment_Type_Text__c='A COPY OF THE INVESTOR OR PARTNER\'S PASSPORT',Service_Request__c=sr.id);
        insert ica1;
        ICA_Document__c ica2 = new ICA_Document__c(Attachment_Type_Text__c='EXCEPTIONAL ATTACHMENT NO 1',Service_Request__c=sr.id);
        insert ica2;
        ICA_Document__c ica3 = new ICA_Document__c(Attachment_Type_Text__c='EXCEPTIONAL ATTACHMENT NO 2',Service_Request__c=sr.id);
        insert ica3;
    }
    static testMethod void ICADocumentTriggeHandlerEstRenewtest()
    {
    	Account acc = [Select id from Account limit 1];
        Id rid = Schema.SObjectType.HexaBPM__Service_Request__c.getRecordTypeInfosByName().get('Establishment Card - Renewal').getRecordTypeId();
    	HexaBPM__Service_Request__c sr = new HexaBPM__Service_Request__c(HexaBPM__Customer__c=acc.id, HexaBPM__Auto_Submit__c=true, Recordtypeid=rid, IA_Reason__c='Manual', 
    		Establishment_English_Name__c='Test ADGM', Establishment_Arabic_Name__c='Test ARrr', Initial_Approval_Number__c='1234');
    	insert sr;
    	
        ICA_Document__c ica = new ICA_Document__c(Attachment_Type_Text__c='ORIGINAL AUTHORIZATION FOR THE AUTHORIZED SIGNATORIES',Service_Request__c=sr.id);
        insert ica;
        ICA_Document__c ica1 = new ICA_Document__c(Attachment_Type_Text__c='A COPY OF THE INVESTOR OR PARTNER\'S PASSPORT',Service_Request__c=sr.id);
        insert ica1;
        ICA_Document__c ica2 = new ICA_Document__c(Attachment_Type_Text__c='EXCEPTIONAL ATTACHMENT NO 1',Service_Request__c=sr.id);
        insert ica2;
        ICA_Document__c ica3 = new ICA_Document__c(Attachment_Type_Text__c='EXCEPTIONAL ATTACHMENT NO 2',Service_Request__c=sr.id);
        insert ica3;
    }
    static testMethod void ICADocumentTriggeHandlerEstamendtest()
    {
    	Account acc = [Select id from Account limit 1];
        Id rid = Schema.SObjectType.HexaBPM__Service_Request__c.getRecordTypeInfosByName().get('Establishment Card Amendment').getRecordTypeId();
    	HexaBPM__Service_Request__c sr = new HexaBPM__Service_Request__c(HexaBPM__Customer__c=acc.id, HexaBPM__Auto_Submit__c=true, Recordtypeid=rid, IA_Reason__c='Manual', 
    		Establishment_English_Name__c='Test ADGM', Establishment_Arabic_Name__c='Test ARrr', Initial_Approval_Number__c='1234');
    	insert sr;
    	
        ICA_Document__c ica = new ICA_Document__c(Attachment_Type_Text__c='A COPY OF THE INVESTOR OR PARTNER\'S PASSPORT AND A COPY OF THE RESIDENC',Service_Request__c=sr.id);
        insert ica;
        ICA_Document__c ica1 = new ICA_Document__c(Attachment_Type_Text__c='ORIGINAL AUTHORIZATION FOR THE AUTHORIZED SIGNATORIES WITH THE ORIGINAL',Service_Request__c=sr.id);
        insert ica1;
    }
}