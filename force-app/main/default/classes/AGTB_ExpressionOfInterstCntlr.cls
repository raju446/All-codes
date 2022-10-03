/*
@Author 		: Azmath
@Description 	: This class will submit the EoI form to AGTB and creates the Client On Board record in Salesforce.
@Version		: v1
*/
public with sharing class AGTB_ExpressionOfInterstCntlr 
{
	public AGTB_Client_On_Board__c sr {get;set;}
	string accountid;
	public boolean isReadonly {get;set;}
	public AGTB_ExpressionOfInterstCntlr(ApexPages.StandardController SC)
	{
		sr = new AGTB_Client_On_Board__c();
		isReadonly = false;
		User usr = [Select Contact.Account.Name, Contact.Account.Id, Contact.Account.Entity_Id__c, Contact.Account.Entity_Type__c, Contact.FirstName, Contact.LastName,
					Contact.Email, Contact.Phone From User where Id=:UserInfo.getUserId()];
		accountid = usr.Contact.Account.id;
		string activities='';
		if(accountid != null && accountid != '')
		{
			for(Business_Activity__c ba : [Select Activity_Name__c, Description__c from Business_Activity__c where Entity__c=:accountid]){
				string activity ='';
				activity = (ba.Activity_Name__c != null && ba.Activity_Name__c != '') ? ba.Activity_Name__c : ba.Description__c;
				
				if(activity != null && activity != '')
				{
					activities = activities + ba.Activity_Name__c+'; ';
				}
			}
			activities = activities.removeEnd('; ');
			sr.Nature_of_business__c = activities;
		}		
		sr.Entity_name__c		= usr.Contact.Account.Id;
		sr.Account_Name__c		= usr.Contact.Account.Name;
		sr.License_number__c	= usr.Contact.Account.Entity_Id__c;
		sr.Legal_entity_type__c = usr.Contact.Account.Entity_Type__c;
		sr.First_name__c		= usr.Contact.FirstName;
		sr.Last_name__c			= usr.Contact.LastName;
		sr.Email__c				= usr.Contact.Email;
		sr.Contact_number__c	= usr.Contact.Phone;
		sr.Type__c				= 'Expression Of Interest';
	}
	public PageReference doSave()
	{
		//Check allowed categories and activities..
		if(isValidCategoryAndActivity() == false){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'This service is not available.');
            ApexPages.addMessage(myMsg);
            return null;
		}
		
		// Check if the service request is already raised.
		if(isValidRequest() == false){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Your details have already been shared with AGTB.');
            ApexPages.addMessage(myMsg);
            return null;
		}
		
		if(sr.Preferred_method_of_contact__c == 'Telephone' && (sr.Preferred_time_in_case_of_call__c == null || sr.Preferred_time_in_case_of_call__c == '')){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select preferred time.');
            ApexPages.addMessage(myMsg);
            return null;
		}
		try
		{
			AGTB_EOI_JsonConstructor helper = new AGTB_EOI_JsonConstructor(sr);
			string payload = JSON.serialize(helper);
			payload = payload.replaceAll('_r','');
			system.debug('====='+payload);
			
			HTTPResponse response = AGTB_CustomerOnBoarding.EoI(payload);
			if(response.getStatusCode() != 200){
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Something went wrong. Please contact your administrator.');
            	ApexPages.addMessage(myMsg);
			}else{
				system.debug('==response==='+response.getBody());
				AGTB_response respWrap = new AGTB_response();
				respWrap = (AGTB_response)JSON.deserialize(response.getBody(), AGTB_response.class);
				
				system.debug('====='+respWrap.Unique_CaseId);
				system.debug('====='+respWrap.Correlation_Id);
				
				sr.Unique_Case_Id__c = respWrap.Unique_CaseId;
				sr.Correlation_Id__c = respWrap.Correlation_Id;
				insert sr;
				isReadonly = true;
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Thank you, your details have been shared with AGTB.');
            	ApexPages.addMessage(myMsg);
			}
		}catch(Exception ex){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
		}
		return null;
	}
	
	public boolean isValidRequest(){
		list<AGTB_Client_On_Board__c> sr = [Select id FROM AGTB_Client_On_Board__c where Entity_name__c=:accountid limit 1];
		if(!sr.isEmpty()){
			return false;
		}
		return true;
	}
	public boolean isValidCategoryAndActivity()
	{
		set<string> categories = new set<string>{'Non-Financial (Category B)', 'Financial (Category A)'};
		list<Account> account = [Select Category__c,(Select Activity_Code__c from Business_Activities__r) FROM Account where id=:accountid];
		if(!account.isEmpty())
		{
			if(account[0].Category__c == null || (!categories.contains(account[0].Category__c))){
            	return false;
        	}
			set<string> allowedActivities = AGTB_Activity_Codes__c.getAll().keyset();
			boolean isValidActivity = false;
			for(Business_Activity__c ba : account[0].Business_Activities__r)
            {
                if(ba.Activity_Code__c != null)
                {
                    string actCode = ba.Activity_Code__c.substringAfter('-');
                    if(allowedActivities.contains(actCode)){
                        return true;
                        break;
                    }
                }
            }
		}
		return false;
	}
}