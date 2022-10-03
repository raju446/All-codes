public without sharing class ICA_CreateUpdateEstablishmentJson 
{
    public ICA_CreateUpdateEstablishmentJson(Id SrId)
    {
        HexaBPM__Service_Request__c sr = new HexaBPM__Service_Request__c();
        list<Role__c> Roles = new list<Role__c>();
        list<Address__c> address = new list<Address__c>();
        
        sr = [SELECT ID, TransactionRef__c, Service_Transaction_Id__c, HexaBPM__Customer__c, HexaBPM__Customer__r.Establishment_Card_Issue_Date__c,HexaBPM__Customer__r.Establishment_Card_Expiry_Date__c,
            HexaBPM__Customer__r.Name, HexaBPM__Customer__r.Account_Name_Arabic__c, HexaBPM__Customer__r.Establishment_Card_No__c, HexaBPM__Customer__r.Entity_Id__c,HexaBPM__Customer__r.Category__c,
            HexaBPM__Customer__r.Registration_Date__c, HexaBPM__Customer__r.License_Expiry_Date__c, Initial_Approval_Number__c, Establishment_English_Name__c, Establishment_Arabic_Name__c,
            /*HexaBPM__Customer__r.Previous_Name__c, HexaBPM__Customer__r.Previous_Name_Arabic__c,*/ New_Draft_Number__c,
            HexaBPM__Customer__r.Establishment_English_Name__c, HexaBPM__Customer__r.Establishment_Arabic_Name__c 
            FROM HexaBPM__Service_Request__c WHERE ID=:SrId];
            
        if(sr.id != null)
        {
            Roles = [SELECT Unified_ID__c, Role_Full_Name__c, Role_Full_Name_Arabic__c, Nationality__c FROM Role__c WHERE Subject_Account__c=:sr.HexaBPM__Customer__c and Status__c='Active' 
                        Order by LastModifiedDate DESC];
            address = [SELECT Building_Name__c, Office_Number__c, Address_for_DDP__c FROM Address__c WHERE Entity__c=:sr.HexaBPM__Customer__c and Type__c='Physical' LIMIT 1];
        }
         
        UD_Input = new UD_Input(sr,Roles,address); 
    }
    public class EstablishmentRequestRelatedPersons 
    {
        public String MobileNumber;
        public String PersonUnifiedNumber;
        public String EmployeeTypeId;
        public String EnglishFullName;
        public String NationalityId;
        public String ArabicFullName;
        public EstablishmentRequestRelatedPersons(Role__c r)
        {
            if(r != null && r.id != null)
            {
                this.MobileNumber           = system.label.ICA_PhoneNumber;
                this.PersonUnifiedNumber    = r.Unified_ID__c;
                this.EmployeeTypeId         = '2';
                this.EnglishFullName        = r.Role_Full_Name__c;
                list<ICA_Nationality__c> cs = [Select Code__c FROM ICA_Nationality__c WHERE Nationality__c=:r.Nationality__c];
                if(!cs.isEmpty()){
                    this.NationalityId      = cs[0].Code__c;
                }
                this.ArabicFullName         = r.Role_Full_Name_Arabic__c;
            }
        }
        public EstablishmentRequestRelatedPersons(){}
    }

    public UD_Input UD_Input;

    public class UD_Input {
        public String EstablishmentNationalityId;
        public String EstablishmentLicenseTypeId;
        public String EnglishEstablishmentNewName;
        public String WorkSectorId;
        public String BuildingName;
        public String EconomicActivityId;
        public datetime CardIssueDate;
        public List<EstablishmentRequestRelatedPersons> establishmentRequestRelatedPersons;
        public date EstablishmentLicenceExpiryDate;
        public String ShopNumber;
        //public List<EstablishmentEconomicActivities> establishmentEconomicActivities;
        public String draftNumber;
        public String EstablishmentId;
        public String AdministrativeRegionId;
        public String EstablishmentTypeId;
        public String requestNumber;
        public String ArabicEstablishmentName;
        public String EstablishmentLicenceNumber;
        public String CityId;
        public String EstablishmentClassId;
        public datetime CardExpiryDate;
        public String FaxNumber;
        public String InvestorPhoneNumber;
        public Integer NumberOfYears;
        public date EstablishmentLicenceIssueDate;
        public String ReferenceRequestNumber;
        public String TransactionReasonId;
        public String ArabicEstablishmentNewName;
        public String EmirateId;
        public String InvestorUnifiedNumber;
        public String ImmigrationDepartmentId;
        public String WorkTelephone;
        public String EstablishmentNumber;
        public String WorkAddressDetails;
        public String PoBox;
        public String EnglishEstablishmentName;
        public String ServiceTransactionId;
        public String EstablishmentLicensePlaceId;
        public UD_Input(HexaBPM__Service_Request__c sr, list<Role__c> roles, list<Address__c> address)
        {
            this.ServiceTransactionId           = sr.Service_Transaction_Id__c;//140 - New Establishment Card (Private / Freezone), 157 - Establishment Card Renew-al (Private / Freezone),162 - Cancel Establishment Card, 160 -  Data Modification
            if(sr.Service_Transaction_Id__c == '140' || sr.Service_Transaction_Id__c == '160')//replaced 139 with 140 and 158 with 157
                this.ReferenceRequestNumber         = sr.Initial_Approval_Number__c;
            
            this.AdministrativeRegionId         = '1'; //Fix as per Tahaluf.
            if(sr.Service_Transaction_Id__c != '162' && sr.Service_Transaction_Id__c != '160')
                this.NumberOfYears                  = 3;
            this.ImmigrationDepartmentId        = system.label.ICA_ImmigrationDepartmentId;//'17'; //Fix as per Tahaluf.
            
            this.EstablishmentNumber            = sr.HexaBPM__Customer__r.Establishment_Card_No__c;
            this.CardIssueDate                  = sr.HexaBPM__Customer__r.Establishment_Card_Issue_Date__c;
            this.CardExpiryDate                 = sr.HexaBPM__Customer__r.Establishment_Card_Expiry_Date__c;
            if(sr.Service_Transaction_Id__c == '140')
            {
                this.EnglishEstablishmentName       = sr.Establishment_English_Name__c;
                this.ArabicEstablishmentName        = sr.Establishment_Arabic_Name__c;
            }
            else {
                this.EnglishEstablishmentName       = sr.HexaBPM__Customer__r.Establishment_English_Name__c;
                this.ArabicEstablishmentName        = sr.HexaBPM__Customer__r.Establishment_Arabic_Name__c;
            }
            if(sr.Service_Transaction_Id__c == '160')//Estb. Amendment
            {
                this.EnglishEstablishmentNewName    = sr.HexaBPM__Customer__r.Name + ' ADGM';
                this.ArabicEstablishmentNewName     = sr.HexaBPM__Customer__r.Account_Name_Arabic__c+' '+system.label.ICA_ArabicADGM;// +' سوق أبوظبي العالمي';
                this.TransactionReasonId            = '316';
            } 
            this.EstablishmentLicenceNumber     = sr.HexaBPM__Customer__r.Entity_Id__c;
            this.EstablishmentLicenceIssueDate  = sr.HexaBPM__Customer__r.Registration_Date__c;
            this.EstablishmentLicenceExpiryDate = sr.HexaBPM__Customer__r.License_Expiry_Date__c;
            this.EstablishmentTypeId            = system.label.ICA_EstablishmentTypeId;//'8';//EMIRATE GOVERNMENT-  Fix as per Tahaluf.
            this.WorkSectorId                   = system.label.ICA_WorkSectorId;//'3';//GOVERNMENT ESTABLISHMENTS -  Fix as per Tahaluf.
            if(system.label.ICA_EstablishmentLicensePlaceId != 'NA')
                this.EstablishmentLicensePlaceId    = system.label.ICA_EstablishmentLicensePlaceId;//'10';//AD INTERNATIONAL MARKET - Fix as per Tahaluf.
            this.EstablishmentLicenseTypeId     = system.label.ICA_EstablishmentLicenseTypeId;//'1'; //COMMERCIAL - Fix as per Tahaluf.
            this.EstablishmentNationalityId     = '1'; //United Arab Emirates - Fix as per Tahaluf.
            this.EmirateId                      = '1'; //Abu Dhabi - Fix as per Tahaluf.
            this.CityId                         = '1'; //Abu Dhabi 
            for(Address__c add : address)
            {
                this.WorkAddressDetails         = add.Address_for_DDP__c;
                this.BuildingName               = add.Building_Name__c;
                this.ShopNumber                 = add.Office_Number__c;
            }
            this.WorkTelephone                  = system.Label.ICA_WorkPhone;
            this.PoBox                          = '11999';
            this.FaxNumber                      = system.Label.ICA_WorkPhone;
            this.EconomicActivityId             = system.Label.ICA_EconomicActivityId;//Free zones
            if(sr.HexaBPM__Customer__r.Category__c != null){
                string estcategory = '';
                if(sr.HexaBPM__Customer__r.Category__c == 'Financial (Category A)'){
                    estcategory = '1';
                }else if(sr.HexaBPM__Customer__r.Category__c == 'Non-Financial (Category B)'){
                    estcategory = '2';
                }else{
                    estcategory = '3';
                }
                this.EstablishmentClassId       = estcategory;
            }
            if(sr.Service_Transaction_Id__c == '140' || sr.Service_Transaction_Id__c == '160')
            {
                for(Role__c r : roles)
                {
                    this.InvestorUnifiedNumber  = r.Unified_ID__c;
                    break;
                }
                this.InvestorPhoneNumber        = system.Label.ICA_PhoneNumber;
                if(sr.Service_Transaction_Id__c == '140')
                {   
                    this.establishmentRequestRelatedPersons = new List<EstablishmentRequestRelatedPersons>();
                    for(Role__c r : roles)
                    {
                        EstablishmentRequestRelatedPersons erp = new EstablishmentRequestRelatedPersons(r);
                        establishmentRequestRelatedPersons.add(erp);
                    }
                    //Add internal auth. signatories.
                    for(Internal_Auth_Signatories__c sig : Internal_Auth_Signatories__c.getAll().values())
                    {
                        EstablishmentRequestRelatedPersons erp = new EstablishmentRequestRelatedPersons();
                        erp.MobileNumber            = sig.Mobile_Number__c;
                        erp.PersonUnifiedNumber     = sig.Name;
                        erp.EmployeeTypeId          = sig.Employee_Type_Code__c;
                        erp.EnglishFullName         = sig.Full_Name__c;
                        erp.NationalityId           = sig.NationalityCode__c;
                        erp.ArabicFullName          = sig.Full_Name_Arabic__c;
                        establishmentRequestRelatedPersons.add(erp);
                    }
                }
            }
            this.requestNumber  = sr.TransactionRef__c; //Mandatory when the request is incomplete.  ................ configure
            this.draftNumber    = sr.New_Draft_Number__c;//Mandatory when the request is incomplete. ............. confugure
        }
    }
    /*public class EstablishmentEconomicActivities {
        public String ActivityDate;
        public String EconomicActivityId;
        public String EstablishmentPartyStatusId;
    }*/
}