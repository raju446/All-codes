/*
    Author      : Durga Kandula
    Date        : 10-Aug-2020
    Description : REST API class which accepts the LeadId as Input and send the Lead Entity and its Lead Contacts as response.
	History:
	Naman	19-09-'21	Added FSRA_Sector__c to the query
	Naman	21-09-'21	Not querying Contact related fields anymore
	Naman	21-09-'21 	Added Industry__c to the query
	Naman	22-09-'21	Updated query to return only fields needed (NOTE: Returning 'FSRA_Sector__c' instead of 'Main_Sector__c)
	Naman	07-10-'21	Removed debug statements
    --------------------------------------------------------------------------------------------------------------------------
*/
@RestResource(urlMapping='/REST_CRMLeadDetails/*')
global without sharing class REST_CRMLeadDetails {
     @HttpPost
    global static ResponseDetails getLeadDetails(){
        REST_CRMLeadDetails.ResponseDetails objResponse = new REST_CRMLeadDetails.ResponseDetails();
        
        list<Lead> listFinancialLeads = new list<Lead>();
        string RequestString = RestContext.request.requestBody.tostring();
        RequestDetails objRequestWrap = (RequestDetails)JSON.deserialize(RequestString,RequestDetails.class);
        if(objRequestWrap!=null && objRequestWrap.LeadId!=null){
            /*for(Lead ld:[Select Id,FSRA_Sector__c,FSRA_Division__c,FirstName,LastName,Company,Email,Main_Sector__c,MobilePhone,Role__c,Other_Position__c,Key_Account__c,
                         Received_Consent__c,Received_Consent_Date__c,Contact_Preference__c,
                         LeadSource, ADGM_Referrer__c,Event_Name__c, Status,Rating,Channel_Partner__c,
                         Category__c,Sector__c,Sub_Sector__c,First_Contact_Date__c, Last_Contact_Date__c,CRM_Other_Activity__c,
                         CRM_Other_Sub_Activity__c,Lead_Country__c,Lead_Street__c,Lead_City__c,Lead_Zip_Postal_Code__c,Website,Phone,State_Province__c,
                         (Select Id,FirstName,LastName,Company,Email,Primary__c,
                          Main_Sector__c, Role__c,Received_Consent__c,Received_Consent_Date__c,
                          Other_Position__c, Contact_Preference__c, First_Contact_Date__c, Last_Contact_Date__c,Status,Lead_Country__c,Lead_Street__c,Lead_City__c,
                          Lead_Zip_Postal_Code__c, Primary_Contact_Type__c, Primary_Phone_Number_1__c,Primary_Phone_Number_2__c, Primary_Phone_Number_3__c,Primary_Email_1__c,
                          Primary_Email_2__c, Primary_Email_3__c,MobilePhone, Alternative_Contact_Type__c,Alternative_Email_1__c,Alternative_Email_2__c,Alternative_Email_3__c,
                          Alternative_Phone_Number_1__c, Alternative_Phone_Number_2__c, Alternative_Phone_Number_3__c, Alternative_Contact_Name__c,State_Province__c,
                          Alternative_Contact_Phone_Number__c, Alternative_Contact_Email__c
                          from Parent_Lead__r) from Lead where Id=:objRequestWrap.LeadId]){*/
            for(Lead ld:[Select Id,Company,Website,Phone,Received_Consent__c,Received_Consent_Date__c,Contact_Preference__c,
                         LeadSource,Status,ADGM_Referrer__c, Rating,Category__c,First_Contact_Date__c,FSRA_Sector__c,Last_Contact_Date__c,
                         FSRA_Division__c,Sector__c,Sub_Sector__c, CRM_Other_Activity__c, CRM_Other_Sub_Activity__c,Industry__c,Lead_Country__c,State_Province__c,Lead_Street__c,Lead_City__c,Lead_Zip_Postal_Code__c
                         from Lead where Id=:objRequestWrap.LeadId]){
                listFinancialLeads.add(ld);
                objResponse.LeadEntity = ld;
                //objResponse.LeadContacts = ld.Parent_Lead__r;
            }
        }         
        return objResponse;
    }
    global class RequestDetails{
        global string LeadId;
    }
    global class ResponseDetails{
        global Lead LeadEntity;
        //global list<Lead> LeadContacts;
        global ResponseDetails(){
            LeadEntity = new Lead();
            //LeadContacts = new list<Lead>();
        }
    }
}