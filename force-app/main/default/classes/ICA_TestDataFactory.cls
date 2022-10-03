/*
@Author : Azmath
@Description : Test Data factory.
*/
@isTest
public class ICA_TestDataFactory
{
    public static Account CreateAccountwithRolesandAddress(){
    	Id rid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company').getRecordTypeId();
        Account a = new Account(Name='TestAccount',Account_Name_Arabic__c='كلاريتيك ليميتد',Entity_Id__c='12345',Entity_Status__c='Registered',Category__c='Retail (Category C)',
        			Entity_Type__c='Private Company Limited By Shares',Registration_Date__c=Date.today(),License_Expiry_Date__c=Date.today().addDays(361),Recordtypeid=rid,
        			Oracle_Party_Id__c='1234');
        insert a;
        
        //Create Roles
        Role__c role = new Role__c(Subject_Account__c=a.id, Type__c='Authorised Signatory', Forenames__c='Testforename', Forenames_in_Arabic__c='Testforename',
        				Nationality__c='India', Unified_ID__c='1234'); 
        insert role;
        
        //Create Address
        Address__c address = new Address__c(Type__c='Physical', Status__c='Active', State__c='Test', Office_Number__c='10', Floor__c='1', Entity__c=a.id,Emirates__c='Abu Dhabi');
        insert address;
        
        return a;
    }
    public static HexaBPM__Service_Request__c CreateInitialApprovalSR(Id accid){
    	Id rid = Schema.SObjectType.HexaBPM__Service_Request__c.getRecordTypeInfosByName().get('Initial Approval').getRecordTypeId();
    	HexaBPM__Service_Request__c sr = new HexaBPM__Service_Request__c(HexaBPM__Customer__c=accid, HexaBPM__Auto_Submit__c=true, Recordtypeid=rid, IA_Reason__c='Manual', 
    		Establishment_English_Name__c='Test ADGM', Establishment_Arabic_Name__c='Test ARrr', establishmentRequestActionTypeId__c='1',
    			Establishment_Request_Type__c='9', Establishment_Partnership_Type__c='6');
    	insert sr;
    	
    	return sr;
    }
    
    public static HexaBPM__Service_Request__c CreateNewEstbSR(Id accid){
    	Id rid = Schema.SObjectType.HexaBPM__Service_Request__c.getRecordTypeInfosByName().get('Establishment Card - New').getRecordTypeId();
    	HexaBPM__Service_Request__c sr = new HexaBPM__Service_Request__c(HexaBPM__Customer__c=accid, HexaBPM__Auto_Submit__c=true, Recordtypeid=rid, IA_Reason__c='Manual', 
    		Establishment_English_Name__c='Test ADGM', Establishment_Arabic_Name__c='Test ARrr', Initial_Approval_Number__c='1234');
    	insert sr;
    	
    	return sr;
    }
    
    public static API_Response__c createapilog(Id srId){
    	API_Response__c resp = new API_Response__c(Balance__c='100',AccountCode__c='1234',Token__c='1234',Bank_Code__c='1234',Service_Request__c=srId,Type__c='Application Submission',
    		Draft_Number__c='12345');
    	insert resp;
    	
    	return resp;
    }
    
     public static Initial_Approval_List__c createIACopy(Id accid){
    	Initial_Approval_List__c ia = new Initial_Approval_List__c(Entity__c=accid,Initial_Approval_Number__c='1234',Active__c=true);
    	insert ia;
    	
    	createAttachment(ia.id);
    	return ia;
    }
    
    public static Attachment createAttachment(Id parentid){
    	Blob b = Blob.valueOf('Test Data');
    	
    	Attachment attachment = new Attachment();
    	attachment.ParentId = parentId;
    	attachment.Name = 'CommercialLicense';
    	attachment.Body = b;
    	
    	insert(attachment);
    	return attachment;
    }
    
    public static HexaBPM__SR_Doc__c createSRDoc(Id srId)
    {
    	list<SR_Doc_Running_Number__c> srdocrnlist = new list<SR_Doc_Running_Number__c>();
    	SR_Doc_Running_Number__c docno = new SR_Doc_Running_Number__c(Name='SR_Doc_NOC',SR_Doc_Running_Number__c=1);
    	srdocrnlist.add(docno);
    	SR_Doc_Running_Number__c docno1 = new SR_Doc_Running_Number__c(Name='SR_Doc_GOV',SR_Doc_Running_Number__c=1);
    	srdocrnlist.add(docno1);
    	SR_Doc_Running_Number__c docno2 = new SR_Doc_Running_Number__c(Name='SR_Doc_LTR',SR_Doc_Running_Number__c=1);
    	srdocrnlist.add(docno2);
    	SR_Doc_Running_Number__c docno3 = new SR_Doc_Running_Number__c(Name='SR_Doc_PR',SR_Doc_Running_Number__c=1);
    	srdocrnlist.add(docno3);
    	SR_Doc_Running_Number__c docno4 = new SR_Doc_Running_Number__c(Name='SR_Doc_CRIMM',SR_Doc_Running_Number__c=1);
    	srdocrnlist.add(docno4);
    	insert srdocrnlist;
    	
    	HexaBPM__SR_Doc__c srdoc = new HexaBPM__SR_Doc__c(Name='Initial Approval/Rejection Letter', HexaBPM__Service_Request__c=srId,HexaBPM__Status__c	='Pending Upload');
    	insert srdoc;
    	
    	return srdoc;
    }
    public static HexaBPM__SR_Template__c createTemplate(string rectype)
    {
    	HexaBPM__SR_Template__c temp = new HexaBPM__SR_Template__c(Name='Initial Approval',HexaBPM__SR_RecordType_API_Name__c=rectype);
    	insert temp;
    	
    	return temp;
    }
    public static HexaBPM__Step_Template__c createstepTemplate(Id tempid, string stepcode,string stepname)
    {
    	HexaBPM__Step_Template__c steptemplate = new HexaBPM__Step_Template__c(Name=stepname,HexaBPM__Code__c=stepcode,HexaBPM__Step_RecordType_API_Name__c='General');
    	insert steptemplate;
    	
    	return steptemplate;
    }
    public static HexaBPM__SR_Steps__c createSRstep(string summary,id templateid, Id steptempid)
    {
    	HexaBPM__SR_Steps__c srstep = new HexaBPM__SR_Steps__c(HexaBPM__Summary__c=summary,HexaBPM__SR_Template__c=templateid,HexaBPM__Step_Template__c=steptempid,
    		HexaBPM__Step_RecordType_API_Name__c='Get New Draft Number');
    	insert srstep;
    	
    	return srstep;
    }
    public static HexaBPM__Step__c createStep(Id srId, string stepname,Id srtepId)
    {
    	HexaBPM__Step__c step = new HexaBPM__Step__c(HexaBPM__SR__c=srId, HexaBPM__Summary__c=stepname, HexaBPM__Start_Date__c=Date.today(), HexaBPM__SR_Step__c=srtepId);
    	insert step;
    	
    	return step;
    }
}