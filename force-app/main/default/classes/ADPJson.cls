/*
@Author : Azmath
@Description : This class is used to parse the JSON.
@Version : v1.
*/

public class ADPJson {
    
    public ADPJson(String Recordtype, Id srid)
    {
        system.debug('*******srid is****'+srid+'****'+Recordtype);
        list<HexaBPM__Service_Request__c> sr            = new list<HexaBPM__Service_Request__c>();
        Account acc                                     = new Account();
        map<string,string> applicationInformationMap    = new map<string,string>();
        map<string,string> BusinessLicenseOwnerMap      = new map<string,string>();
        string srFields         = '';
        string partFields       = '';
        
        //Query SR and Participants details dynamcially..
        for(ADP_AttributesMapping__c cs : ADP_AttributesMapping__c.getAll().values())
        {
            if(cs.Permit_Name__c == Recordtype)
            {
                if(cs.Section__c == 'ApplicationInformation')
                {
                    if(cs.Is_Default__c == true){
                        applicationInformationMap.put(cs.ADP_Attribute__c,cs.Default_Value__c);
                    }else{
                        applicationInformationMap.put(cs.ADP_Attribute__c,cs.Field__c);
                        srFields = srFields + ','+ cs.Field__c;
                    }
                }
                if(cs.Section__c == 'BusinessLicenseOwner')
                {
                    if(cs.Is_Default__c == true)
                        BusinessLicenseOwnerMap.put(cs.ADP_Attribute__c,cs.Default_Value__c);
                    else{
                        BusinessLicenseOwnerMap.put(cs.ADP_Attribute__c,cs.Field__c);
                        partFields = partFields + ',' +cs.Field__c;
                    }
                }
            }
        }
        if(srFields != '')
        {
            string query = 'SELECT ID, NAME, HexaBPM__Customer__c,Application_Code__c,Transaction_Id__c,Status_Code__c, HexaBPM__Email__c,ADP_Status__c,HexaBPM__Send_SMS_to_Mobile__c,Cancellation_Comment__c '+srFields;
            query = query.removeEnd(',');
            if(partFields != '')
            {
                partFields = partFields.removeEnd(',');
                query = query + ', (SELECT ID '+ partFields + ' FROM Amendments__r) ';
                query = query + ', (SELECT ID, Name FROM HexaBPM__SR_Docs__r Where Available_to_ADP__c=true) ';
            }
            query = query + ' FROM HexaBPM__Service_Request__c WHERE ID =:srid';
            system.debug('=====query is ====='+query);
            sr = Database.query(query);
            system.debug('===sr docs ====='+sr[0].HexaBPM__SR_Docs__r);
        }
        system.debug('=====customer=='+sr[0].HexaBPM__Customer__c);
        //Query Account details..
        if(!sr.isEmpty()){
            acc = [SELECT ID, Name, Account_Name_Arabic__c, Entity_Id__c, Entity_Type__c, Registration_Date__c, License_Expiry_Date__c,LegalTypeID__c, 
                        (SELECT ID, Description_Arabic__c, Actual_Activity_code__c, Description__c FROM Business_Activities__r),
                        (SELECT ID, Street_Name_of_Cluster_on_the_Island__c, State__c, Building_Name__c FROM Addresses__r WHERE Type__c = 'Physical' LIMIT 1),
                        (SELECT ID, Name_in_English__c, Name_in_Arabic__c FROM Trade_Names__r LIMIT 1)                      
                         FROM Account WHERE ID=:sr[0].HexaBPM__Customer__c];
        }
        system.debug('====='+sr[0]);
        system.debug('====='+acc);
        system.debug('====='+applicationInformationMap.size());
        system.debug('====='+BusinessLicenseOwnerMap.size());
        UD_Input = new UD_Input(sr[0],acc,applicationInformationMap,BusinessLicenseOwnerMap);
    }
    
    public class BusinessLicenseActivities 
    {
        public List<BusinessLicenseActivity> BusinessLicenseActivity;
        public BusinessLicenseActivities(Account acc)
        {
            BusinessLicenseActivity = new list<BusinessLicenseActivity>();
            for(Business_Activity__c ba : acc.Business_Activities__r)
            {
                BusinessLicenseActivity b = new BusinessLicenseActivity(ba,acc);
                BusinessLicenseActivity.add(b);
            }
            if(acc.Business_Activities__r == null || acc.Business_Activities__r.size() == 0){
                BusinessLicenseActivity b = new BusinessLicenseActivity(null,acc);
                BusinessLicenseActivity.add(b);
            }
        }
    }

    public class BusinessLicense
    {
        public String TradeNameEN;
        public String BusinessNameEN;
        public String LegalFormExpDate;
        public String BusinessType;
        public String CountryOfOriginEN;
        public String BusinessNameAR;
        public String LicenseExpDate;
        public String BusinessLicenseID;
        public String LegalFormAR;
        public String CountryOfOriginAR;
        public String LegalFormIssueDate;
        public String LegalFormEN;
        public String LicenseIssueDate;
        public String TradeNameAR;
        public BusinessLicense(Account acc)
        {
            system.debug('===test==');
            Trade_Name__c tr = new Trade_Name__c();
            if(acc.Trade_Names__r != null && acc.Trade_Names__r.size() > 0)
                tr = acc.Trade_Names__r;
            if(tr.id != null){
                this.TradeNameEN = tr.Name_in_English__c;
                this.TradeNameAR = tr.Name_in_Arabic__c;
            }else{
                 this.TradeNameEN = acc.Name;
                this.TradeNameAR = acc.Account_Name_Arabic__c;
            }
            this.BusinessNameEN     = acc.Name;
            this.BusinessNameAR     = acc.Account_Name_Arabic__c;
            this.BusinessLicenseID  = acc.Entity_Id__c;
            this.BusinessType       = acc.LegalTypeID__c; //TBD//acc.Entity_Type__c;
            if(acc.Registration_Date__c != null)
                this.LicenseIssueDate   = acc.Registration_Date__c.Month()+'/'+acc.Registration_Date__c.Day()+'/'+acc.Registration_Date__c.Year();
            if(acc.License_Expiry_Date__c != null)
                this.LicenseExpDate     = acc.License_Expiry_Date__c.Month()+'/'+acc.License_Expiry_Date__c.Day()+'/'+acc.License_Expiry_Date__c.Year();
        }
    }

    public class BusinessLicenseOwners {
        public List<BusinessLicenseOwner> BusinessLicenseOwner;
        public BusinessLicenseOwners(HexaBPM__Service_Request__c sr, map<string,string> BusinessLicenseOwnerMap)
        {
            BusinessLicenseOwner = new list<BusinessLicenseOwner>();
            for(Amendment__c part : sr.Amendments__r)
            {
                BusinessLicenseOwner b = new BusinessLicenseOwner();
                if(part.Nationality_New__c != null)
                {
                    list<ADP_NationalityLookup__c> ad = [Select code__c from ADP_NationalityLookup__c where Nationality__c=:part.Nationality_New__c limit 1];
                    if(!ad.isEmpty() && ad[0].code__c != null) 
                        b.Nationality_Code = ad[0].code__c;
                }
                b.NationalityAR     = (BusinessLicenseOwnerMap.get('NationalityAR') != null? (string)part.get(BusinessLicenseOwnerMap.get('NationalityAR')):null);
                b.NameEN            = (BusinessLicenseOwnerMap.get('NameEN') != null? (string)part.get(BusinessLicenseOwnerMap.get('NameEN')):null);
                b.PassportNumber    = (BusinessLicenseOwnerMap.get('PassportNumber') != null? (string)part.get(BusinessLicenseOwnerMap.get('PassportNumber')):null);
                b.NationalityEN     = (BusinessLicenseOwnerMap.get('NationalityEN') != null? (string)part.get(BusinessLicenseOwnerMap.get('NationalityEN')):null);
                b.Gender            = (BusinessLicenseOwnerMap.get('Gender') != null? (string)part.get(BusinessLicenseOwnerMap.get('Gender')):null);
                b.NameAR            = (BusinessLicenseOwnerMap.get('NameAR') != null? (string)part.get(BusinessLicenseOwnerMap.get('NameAR')):null);
                b.EIDAnumber        = (BusinessLicenseOwnerMap.get('EIDAnumber') != null? (string)part.get(BusinessLicenseOwnerMap.get('EIDAnumber')):null);
                BusinessLicenseOwner.add(b);
            }
        }
    }
    
    public class BusinessLicenseOwner {
        public String NationalityAR;
        public String Nationality_Code;
        public String MOIunifiedNumber;
        public String EIDAnumber;
        public String NameEN;
        public String PassportNumber;
        public String NationalityEN;
        public String Gender;
        public String NameAR;
        public BusinessLicenseOwner(){}
    }

    public class RequestSession {
        public String UserID;
        public String UserPass;
        public String ExtUnitID;
        public RequestSession()
        {
            UserID = system.Label.ADP_UserId;
            UserPass = system.Label.ADP_pwd;
            ExtUnitID = system.Label.ADP_ExtUnitID;
        }
    }

    public UD_Input UD_Input;

    public class Documents {
        public List<Document_C> Document;
        public Documents(HexaBPM__Service_Request__c sr)
        {
          Document = new list<Document_C>();
          for(HexaBPM__SR_Doc__c srdoc : [Select Id,Name FROM HexaBPM__SR_Doc__c where HexaBPM__Service_Request__c=:sr.id and Available_to_ADP__c=true])
          {
            Document_C doc = new Document_C(srdoc); 
            Document.add(doc);
          }
        }
    }
  
  public class Document_C { 
        public String DocumentID;
        public String DocumentName;
        public String DocContentType;
        public Document_C(HexaBPM__SR_Doc__c doc)
        {
          DocumentID = string.valueof(doc.Id).substring(0,15);
          DocumentName = doc.Name;
        }
    }
    
    public class BusinessLicenseAddress {
        public String CityCode;
        public String BuildingNameAR;
        public String CityEN;
        public String PrimaryAreaAR;
        public String BuildingNameEN;
        public String CityAR;
        public String PrimaryAreaEN;
        public BusinessLicenseAddress(Account acc)
        {
            system.debug('====btest===');
            Address__c address= new Address__c();
            if(acc.Addresses__r != null && acc.Addresses__r.size()>0)   
                address = acc.Addresses__r;
            if(address.id != null)
            {
                this.CityCode = '1';
                this.CityEN = 'Abu Dhabi';
                this.CityAR = 'الإمارات العربية المتحدة';
                string primaryArea = address.Street_Name_of_Cluster_on_the_Island__c + ','+address.State__c;
                primaryArea = primaryArea.replaceAll(',null','');
                this.PrimaryAreaEN = primaryArea;
                this.BuildingNameAR = address.Building_Name__c;         
            }else{
                this.CityCode = '1';
                this.CityEN = 'Abu Dhabi';
                this.CityAR = 'الإمارات العربية المتحدة';
            }
        }
    }

    public class UD_Input 
    {
        public BusinessLicenseActivities BusinessLicenseActivities;
        public BusinessLicense BusinessLicense;
        public BusinessLicenseOwners BusinessLicenseOwners;
        public RequestSession RequestSession;
        public Documents Documents;
        public BusinessLicenseAddress BusinessLicenseAddress;
        public ApplicationInformation ApplicationInformation;
        public UD_Input(HexaBPM__Service_Request__c sr, Account acc, map<string,string> applicationInformationMap,map<string,string> BusinessLicenseOwnerMap)
        {
            BusinessLicenseActivities   = new BusinessLicenseActivities(acc);
            BusinessLicense             = new BusinessLicense(acc);
            if(sr.Amendments__r != null && sr.Amendments__r.size() > 0)
                BusinessLicenseOwners       = new BusinessLicenseOwners(sr,BusinessLicenseOwnerMap);
            RequestSession              = new RequestSession();
            Documents                   = new Documents(sr);
            BusinessLicenseAddress      = new BusinessLicenseAddress(acc);
            ApplicationInformation      = new ApplicationInformation(sr,applicationInformationMap);
        }
    }

    

    public class BusinessLicenseActivity 
    {
        public String ActivityDescriptionAR;
        public String ActivityID;
        public String ActivityDescriptionEN;
        public BusinessLicenseActivity(Business_Activity__c ba,Account acc)
        {
            if(ba != null){
                this.ActivityDescriptionAR  = ba.Description_Arabic__c;
                this.ActivityID             = ba.Actual_Activity_code__c;
                this.ActivityDescriptionEN  = ba.Description__c;
            }else{
                this.ActivityDescriptionAR  = acc.Account_Name_Arabic__c;
                this.ActivityID             = acc.Entity_Id__c;
                this.ActivityDescriptionEN  = acc.Name;
            }
        }
    }

    public class ApplicationInformation {
        public String PROemail;
        public String EntertainmentTypeEN;
        public String EndTime;
        public String ContractorNameAR;
        public String PROnameAR;
        public String StartTime;
        public String PermitLocationAR;
        public String ContactPersonPhone;
        public String StatusCode;
        public String PermitEndDate;
        public String ApplicationCode;
        public String PROnameEN;
        public String PROUID;
        public String ApplicationType;
        public String PermitReason;
        public String PermitLocationEN;
        public String PROmobile;
        public String ContactPersonName;
        public String PermitStartDate;
        public String CreatedDate;
        public String EntertainmentTypeAR;
        public String ApplicationID;
        public String ContractorNameEN;
        public String PROUAEID;
        public ApplicationInformation(HexaBPM__Service_Request__c sr, map<string,string> applicationInformationMap )
        {
          //If Amendment permit raised for cancellation then
          //1. Application Code = 2
          //2. Status Code = 5
          
            this.ApplicationID = sr.Id;
            //Query child SR details..
            list<HexaBPM__Service_Request__c> mainSR = [Select id,Start_Date__c,End_Date__c,Location__c,Location_Arabic__c, Recordtype.DeveloperName, Reason_of_Cancellation__c   FROM HexaBPM__Service_Request__c 
              where HexaBPM__Parent_SR__c=:sr.Id order by HexaBPM__Submitted_Date__c DESC LIMIT 1];
            
            this.ApplicationCode = (applicationInformationMap.get('ApplicationCode') != null? applicationInformationMap.get('ApplicationCode'):null);
            if(sr.Transaction_Id__c != null){
                this.ApplicationCode = '2';
            }
            
            //Application Type.. 
            this.ApplicationType = applicationInformationMap.get('ApplicationType');
            
            //Status Code..
            if(sr.ADP_Status__c == 'INCOMPLETE' || sr.ADP_Status__c == '3'){
                this.StatusCode = '8';
            }
            else if(sr.Cancellation_Comment__c != null && sr.Cancellation_Comment__c != ''){
                this.StatusCode = sr.Cancellation_Comment__c;
            }else{
                this.StatusCode = '1';
            }
            
            system.debug('====status code=='+this.statuscode);
            if(sr.HexaBPM__Customer__c != null && sr.HexaBPM__Email__c != null)
            {
                list<Contact> con = [Select Name from Contact where AccountId=:sr.HexaBPM__Customer__c and Email=:sr.HexaBPM__Email__c and Recordtype.name='Contact - Portal User' LIMIT 1];
                if(!con.isEmpty()){
                    this.PROnameEN = con[0].Name;
                }
            }
            this.PROemail = sr.HexaBPM__Email__c;
            this.PROmobile = sr.HexaBPM__Send_SMS_to_Mobile__c;
            
            this.PermitReason = (applicationInformationMap.get('PermitReason') != null? (string)sr.get(applicationInformationMap.get('PermitReason')):null);
            this.PermitLocationEN = (applicationInformationMap.get('PermitLocationEN') != null? (string)sr.get(applicationInformationMap.get('PermitLocationEN')):null);
            this.PermitLocationAR = (applicationInformationMap.get('PermitLocationAR') != null? (string)sr.get(applicationInformationMap.get('PermitLocationAR')):null);
            
             
            
            if(applicationInformationMap.get('PermitStartDate') != null && sr.get(applicationInformationMap.get('PermitStartDate')) != null){
                Date dt = (Date)sr.get(applicationInformationMap.get('PermitStartDate'));
                PermitStartDate = dt.Month()+'/'+dt.Day()+'/'+dt.Year();
                
            
              system.debug('===start date=='+PermitStartDate);
            }
            if(applicationInformationMap.get('PermitEndDate') != null && sr.get(applicationInformationMap.get('PermitEndDate')) != null){
                Date dt = (Date)sr.get(applicationInformationMap.get('PermitEndDate'));
                PermitEndDate = dt.Month()+'/'+dt.Day()+'/'+dt.Year();
                
            
              system.debug('===PermitEndDate=='+PermitEndDate);
            }
            if(applicationInformationMap.get('CreatedDate') != null && sr.get(applicationInformationMap.get('CreatedDate')) != null){
                Date dt = (Date)sr.get(applicationInformationMap.get('CreatedDate'));
                CreatedDate = dt.Month()+'/'+dt.Day()+'/'+dt.Year();
            }
            this.StartTime              = (applicationInformationMap.get('StartTime') != null? string.valueof(sr.get(applicationInformationMap.get('StartTime'))):null);
            if(this.StartTime != null){
                StartTime = StartTime.replaceAll(':00.000Z','');
            }
            this.EndTime                = (applicationInformationMap.get('EndTime') != null? string.valueof(sr.get(applicationInformationMap.get('EndTime'))):null);
            if(this.EndTime != null){
                EndTime = EndTime.replaceAll(':00.000Z','');
            }
            this.EntertainmentTypeEN    = (applicationInformationMap.get('EntertainmentTypeEN') != null? (string)sr.get(applicationInformationMap.get('EntertainmentTypeEN')):null);
            this.EntertainmentTypeAR    = (applicationInformationMap.get('EntertainmentTypeAR') != null? (string)sr.get(applicationInformationMap.get('EntertainmentTypeAR')):null);
        }
    }
}