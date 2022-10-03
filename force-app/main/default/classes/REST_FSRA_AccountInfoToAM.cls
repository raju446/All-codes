/*
    Author      : Durga Kandula
    Date        : 10-Aug-2020
    Description : REST API class to send Converted Account, Contacts to FSRA.
    Version History
    Prachi       24-Mar-2021    Mapped the field Converted_By_User__c to be passed to FSRA
	Naman		 1-Jul-2021		Added FSRA Division field to the wrapper to be sent back to FSRA Connect
	Naman		 19-Sept-2021	Sending FSRA_Sector__c back to FSRA Connect
	Naman		 21-Sept-2021   Not sending contact related fields to FSRA Connect 
	Naman		 22-Sept-2021	Updated query and wrapper to send only needed fields to FSRA Connect
	Naman		 22-Sept-2021	Added 'Other Activity' and 'Other Sub-Activity' to the wrapper
	Naman		 7-Oct-2021		Removed debug statements having PII info
    -------------------------------------------------------------------------
*/

@RestResource(urlMapping='/REST_FSRA_AccountInfoToAM/*')
global with sharing class REST_FSRA_AccountInfoToAM {
    @HttpPost
    global static CRMEntityWrap SendAccountDetails(){
         REST_FSRA_AccountInfoToAM.CRMEntityWrap objWrap = new REST_FSRA_AccountInfoToAM.CRMEntityWrap();
         
        string RequestString = RestContext.request.requestBody.tostring();
        RequestDetails objRequestWrap = (RequestDetails)JSON.deserialize(RequestString,RequestDetails.class);
        if(objRequestWrap!=null && objRequestWrap.LeadId!=null){
            try{
                string AccountId;
                for(Lead objLead:[Select Id,Created_By_User__c,Converted_By_User__c,ConvertedAccountId from Lead where Id=:objRequestWrap.LeadId and ConvertedAccountId!=null]){
                    objWrap.Converted_By_User = objLead.Converted_By_User__c;
                    objWrap.Created_By_User = objLead.Created_By_User__c;
                    AccountId = objLead.ConvertedAccountId;
                }
                if(AccountId!=null){
                    map<string,Account> MapAccounts = new map<string,Account>();
                    /*for(Account acc:[Select Id,FSRA_Sector__c,Name,Email__c,Entity_Id__c,Website,Phone,Fax,Main_Sector__c,Sector__c,Sub_Sector__c,Industry__c,AccountSource,
                                     Country__c, City__c, Street__c, Zip_Postal_Code_PO_Box__c,State_Province__c,FSRA_Division__c,
                    (Select Id,FirstName,LastName,Email,Salutation,Position__c,Other_Position__c,MobilePhone, Country__c, Lead_City__c,Street__c,Zip_Postal_Code_PO_Box__c,State_Province__c from Contacts) 
                                     from Account where Id=:AccountId]){*/
                   for(Account acc:[Select Id,FSRA_Sector__c,Name,Entity_Id__c,Website,Phone,Main_Sector__c,Sector__c,Sub_Sector__c,Industry__c,AccountSource,
                                     Country__c, City__c, Street__c, Zip_Postal_Code_PO_Box__c,State_Province__c,FSRA_Division__c,CRM_Other_Activity__c,CRM_Other_Sub_Activity__c
                                     from Account where Id=:AccountId]){
                        MapAccounts.put(acc.Id,acc);
                    }
                    map<string,Account> MapResponse = new map<string,Account>();
                    for(Opportunity opp:[Select Id,Name,AccountId,Main_Sector__c,Sector__c,Sub_Sector__c,StageName from Opportunity where AccountId=:AccountId]){
                        Account acc = MapAccounts.get(opp.AccountId);
                        
                        objWrap.Entity_Name = acc.Name;
                        //objWrap.Entity_Email = acc.Email__c;
                        objWrap.Entity_Website = acc.Website;
                        objWrap.Entity_Phone = acc.Phone;
                        //objWrap.Entity_Fax = acc.Fax;
                        objWrap.EntityId = acc.Entity_Id__c;
                        objWrap.Entity_Source = acc.AccountSource;
                        objWrap.CRM_AccountId = acc.Id;
                        objWrap.Entity_Country = acc.Country__c;
                        objWrap.Entity_City = acc.City__c;
                        objWrap.Entity_Street = acc.Street__c;
                        objWrap.Entity_ZipCode = acc.Zip_Postal_Code_PO_Box__c;
                        objWrap.Entity_State = acc.State_Province__c;
                        objWrap.FSRA_Division = acc.FSRA_Division__c;
                        //Naman 19-9-'21
                        objWrap.Entity_Sector = acc.FSRA_Sector__c;
                        objWrap.Entity_Activity = acc.Sector__c;
                        objWrap.Entity_Sub_Activity = acc.Sub_Sector__c;
                        //Naman 22-9-'21
                        objWrap.Entity_Other_Activity = acc.CRM_Other_Activity__c;
                        objWrap.Entity_Other_Sub_Activity = acc.CRM_Other_Sub_Activity__c;
                        
                        /*if(acc.Contacts!=null && acc.Contacts.size()>0){
                            list<ContactDetails> lstContacts = new list<ContactDetails>();
                            for(Contact con:acc.Contacts){
                                ContactDetails objConWrap = new ContactDetails();
                                objConWrap.Contact_Salutation = con.Salutation;
                                objConWrap.Contact_FirstName = con.FirstName;
                                objConWrap.Contact_LastName = con.LastName;
                                objConWrap.Contact_Email = con.Email;
                                objConWrap.Contact_Position = con.Position__c;
                                objConWrap.Contact_Other_Position = con.Other_Position__c;
                                objConWrap.Contact_Mobile = con.MobilePhone;
                                objConWrap.CRM_ContactId = con.Id;
                                objConWrap.Contact_Country = con.Country__c;
                                objConWrap.Contact_City = con.Lead_City__c;
                                objConWrap.Contact_Street = con.Street__c;
                                objConWrap.Contact_ZipCode = con.Zip_Postal_Code_PO_Box__c;
                                objConWrap.Contact_State = con.State_Province__c;
                                lstContacts.add(objConWrap);
                            }
                            objWrap.lstContacts = lstContacts;
                        }*/
                        
                        objWrap.CRM_OpportunityId = opp.Id;
                        //objWrap.Opportunity_Sector = opp.Main_Sector__c;
                        //objWrap.Opportunity_StageName = opp.StageName;
                        //objWrap.Opportunity_Activity = opp.Sector__c;
                        //objWrap.Opportunity_Sub_Activity = opp.Sub_Sector__c;
                    }
                }
            }catch(Exception e){
                //objResp.bSuccess = false;
                //objResp.StatusCode = '500';
                //objResp.Message = e.getMessage()+'';
            }
        }
        return objWrap;
    }
    global class RequestDetails{
        global string LeadId;
    }
    global class CRMEntityWrap{
        global string Entity_Name;
        //global string Entity_Email;
        global string Entity_Website;
        global string Entity_Phone;
        //global string Entity_Fax;
        global string EntityId;
        global string Entity_Source;        
        global string CRM_AccountId;
        global string FSRA_AccountId;
        global string Entity_Country;
        global string Entity_City;
        global string Entity_Street;
        global string Entity_ZipCode;
        global string Entity_State;
        global string Entity_Sector;
        global string Entity_Activity;
        global string Entity_Sub_Activity;
        global string Entity_Other_Activity;
        global string Entity_Other_Sub_Activity;
        
        //global list<ContactDetails> lstContacts;
        
        global string CRM_OpportunityId;
        //global string Opportunity_Sector;
        //global string Opportunity_StageName;
        //global string Opportunity_Activity;
        //global string Opportunity_Sub_Activity;
        
        global string Created_By_User;
        global string Converted_By_User;
        
        //Naman - FSRA Division
        global string FSRA_Division;
        
        global CRMEntityWrap(){
            //lstContacts = new list<ContactDetails>();
        }
    }
    /*global class ContactDetails{
        global string Contact_Salutation;
        global string Contact_FirstName;
        global string Contact_LastName;
        global string Contact_Email;
        global string Contact_Position;
        global string Contact_Other_Position;
        global string Contact_Mobile;
        global string CRM_ContactId;
        global string FSRA_ContactId;
        global string Contact_Country;
        global string Contact_City;
        global string Contact_Street;
        global string Contact_ZipCode;
        global string Contact_State;
    }*/
    global class ResponseDetails{
        global boolean bSuccess;
        global string StatusCode;
        global string Message;
        global ResponseDetails(){
            bSuccess = true;
            StatusCode = '201';
            Message = 'Success';
        }
    } 
}