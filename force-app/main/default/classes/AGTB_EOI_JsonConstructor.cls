//{ "ClientOnboarding": { "MessageInfo": { "Version": "BBBBBBB", "Guid": "AAAAAAAAA", "Source": "ADGM", "EventType": "ExpressionOfInterest", 
//"CreatedDate": "bbbbbbbb" }, "ClientEntity": { "LegalEntityName": "cccccc", "LegalEntityType": "ee", "NatureOfActivityBusiness": "e", 
//"Contacts": { "Contact": [ { "FirstName": "eeee", "LastName": "B", "PreferredMethodOfContact": "ddd", "Email": "AAA", "HomePhone": "dd", 
//"AlternateContactFirstName" : "test", "AlternateContactLastName" : "test", "AlternateEmail" : "test@test.com", "AlternatePhoneNumber": "8666666", 
//"PreferredTimeOfContact" : "2 PM", "Notes" : "New Contract Changes" } ] }, "Addresses": { "Address": [ { "Country": "CCC" } ] } } } }
/* *************************************************************************
AUTHOR         : AZMATH
DESCRIPTION    : This class will be used to construct the json for COB services..
VERSION        : V1
* ************************************************************************** */

public class AGTB_EOI_JsonConstructor
{
    public EoI ClientOnboarding;
    public AGTB_EOI_JsonConstructor(AGTB_Client_On_Board__c sr)
    {
        ClientOnboarding = new EoI(sr);
    }
    public class EoI
    {
        public message MessageInfo;
        public CE ClientEntity;
        public EoI(AGTB_Client_On_Board__c sr){
            MessageInfo   = new message();
            ClientEntity   = new CE(sr);
        }
    }
    public class message
    {
        public string Version;
        public string Guid;
        public string Source;
        public string EventType;
        public string CreatedDate;
        public message(){
            this.Version    ='1.0';
            this.Guid       ='G1';
            this.Source     ='ADGM';
            this.EventType  ='ExpressionOfInterest';
            this.CreatedDate = string.valueof(System.today());
        }
    }
    public class CE
    {
        public string LegalEntityName;
        public string LegalEntityType;
        public string NatureOfActivityBusiness;
        public address Addresses;
        public contact Contacts;
        public CE(AGTB_Client_On_Board__c sr){
            Addresses = new address(sr);
            Contacts = new contact(sr);
            LegalEntityName = sr.Account_Name__c;
            LegalEntityType = sr.Legal_entity_type__c;
            NatureOfActivityBusiness= sr.Nature_of_business__c;
        }
    }
    public class contact
    {
        public list<contact_x> Contact_r;
        public contact(AGTB_Client_On_Board__c sr){
            Contact_r = new list<contact_x>{new contact_x(sr)};
        }
    }
    public class contact_x{
        public string FirstName;
        public string LastName;
        public string PreferredMethodOfContact;
        public string Email;
        public string HomePhone;
        public string AlternateContactFirstName;
        public string AlternateContactLastName;
        public string AlternateEmail;
        public string AlternatePhoneNumber;
        public string PreferredTimeOfContact;
        public string Notes;
        
        public contact_x(AGTB_Client_On_Board__c sr){
            this.FirstName = sr.First_name__c;
            this.LastName = sr.Last_name__c;
            this.PreferredMethodOfContact = sr.Preferred_method_of_contact__c;
            this.Email = sr.Email__c;
            this.HomePhone = sr.Contact_number__c;
            this.AlternateContactFirstName = sr.Alt_First_name__c;
            this.AlternateContactLastName = sr.Alt_Last_name__c;
            this.AlternateEmail = sr.Alt_Email__c;
            this.AlternatePhoneNumber = sr.Alt_Phone_number__c;
            if(sr.Preferred_method_of_contact__c == 'Email'){
            	this.PreferredTimeOfContact = '';
            }else
            	this.PreferredTimeOfContact = sr.Preferred_time_in_case_of_call__c;
            if(sr.Notes_comments__c != null)
            this.Notes = sr.Notes_comments__c;
            else
            this.Notes = '';
        }
    }
    public class address
    {
        public list<Address_x> Address_r;
        public address(AGTB_Client_On_Board__c sr){
            Address_r = new list<Address_x>{new Address_x(sr)};
        }
    }
    public class Address_x{
        public string Country;
        public Address_x(AGTB_Client_On_Board__c sr){
            this.Country = sr.Principal_country_of_business__c;
            
        }
    }
}