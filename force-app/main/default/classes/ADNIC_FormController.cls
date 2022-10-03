/*
@Author 		: Shagufta
@Description 	: This class will submit the ADNIC form to create record in Salesforce, WF will send email once the form is submitted.
@Version		: v1
@Modified by 	: Azmath
*/
public with sharing class ADNIC_FormController {
	public ADNIC_Health_Insurance__c adnic {get;set;}
    public String NameContact{get;set;}
    public string MobileNumber{get;set;}
    public String emailId{get;set;}
    public String Entity_name{get;set;}
    public String Account_Name{get;set;}
    public String License_number{get;set;}
    public string Legal_entity_type{get;set;}
    public String AltContPerson{get;set;}
    public string AltContNumber{get;set;}
    public string AccountId{get;set;}
    public boolean isReadyonly{get;set;}
    public Id recid;
    
    //Constructor..
    public ADNIC_FormController()
	{
		adnic = new ADNIC_Health_Insurance__c();
		User usr = [Select Contact.Account.Name, Contact.Account.Id, Contact.Account.Entity_Id__c, Contact.Account.Entity_Type__c, Contact.FirstName, Contact.LastName,
					Contact.Email, Contact.Phone From User where Id=:UserInfo.getUserId()];
		
        Entity_name		= usr.Contact.Account.Id;
		Account_Name	= usr.Contact.Account.Name;
        AccountId 		=  usr.Contact.AccountId;
		License_number	= usr.Contact.Account.Entity_Id__c;
        Legal_entity_type = usr.Contact.Account.Entity_Type__c;
        isReadyonly = false;
    }
    
    //Submit form..
    public PageReference doSave()
	{
        try{
        	string message='';
        	if(adnic.id != null)
        	{
        		adnic.Email_Text__c='updated';
        		update adnic;
        	}else{
        		adnic.Account_Name__c = Account_Name;
		        adnic.License_number__c = License_number;
		        adnic.Legal_entity_type__c = Legal_entity_type;
		        adnic.entity_name__c= AccountId;
		        insert adnic;
		        message='Your enquiry has been submitted, one of ADNIC’s representatives will get in touch with you soon.';
        	}
	        isReadyonly = true;
	        if(message == null || message == ''){
	        	message='Your updated enquiry details have been successfully forwarded to ADNIC';
	        }
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,message);
	    	ApexPages.addMessage(myMsg);
        }catch(Exception ex){
        	system.debug('exception --'+ex.getmessage());
        	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Something went wrong. Please contact administrator.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        return null;
    }
    public PageReference doEdit()
	{
		if(adnic.id != null){
			isReadyonly = false;
		}
		return null;
	}
}