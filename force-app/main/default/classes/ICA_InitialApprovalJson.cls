/*
@Author : Azmath
@Description : This class is used to parse the JSON.
@Version : v1.
*/
public without sharing class ICA_InitialApprovalJson 
{
    public ICA_InitialApprovalJson(Id SrId)
    {
        HexaBPM__Service_Request__c sr = new HexaBPM__Service_Request__c();
        list<Role__c> Roles = new list<Role__c>();
        sr = [SELECT ID, establishmentRequestActionTypeId__c, Establishment_Request_Type__c,HexaBPM__Customer__c, Establishment_Partnership_Type__c, TransactionRef__c, 
            HexaBPM__Customer__r.Name, HexaBPM__Customer__r.Account_Name_Arabic__c, HexaBPM__Customer__r.Establishment_Card_No__c, HexaBPM__Customer__r.Entity_Id__c , New_Draft_Number__c ,
            Establishment_English_Name__c, Establishment_Arabic_Name__c 
            FROM HexaBPM__Service_Request__c WHERE ID=:SrId];
        if(sr.id != null)
        {
            Roles = [SELECT Unified_ID__c, Role_Full_Name__c, Role_Full_Name_Arabic__c, Nationality__c FROM Role__c WHERE Subject_Account__c=:sr.HexaBPM__Customer__c and Status__c='Active' Order by LastModifiedDate DESC];
        }
        
        UD_Input = new UD_Input(sr,Roles);
    }
    public class EstablishmentRequestRelatedPersons {
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
    }

    /*public class EstablishmentRequestRelatedEstablishments {
        public String arabicEstablishmentName;
        public String departmentId;
        public String nationalityId;
        public String establishmentNumber;
        public String englishEstablishmentName;
    }*/

    public UD_Input UD_Input;

    public class UD_Input 
    {
        public String arabicEstablishmentName;
        public String PreferedLanguageId;
        public String investorUnifiedNumber;
        public List<EstablishmentRequestRelatedPersons> establishmentRequestRelatedPersons;
        public String englishEstablishmentName;
        //public List<EstablishmentEconomicActivities> establishmentEconomicActivities;
        public String draftNumber;
        public String economicActivityId;
        public string equityCapitalAmount;
        public String investorPhoneNumber;
        public String AdministrativeRegionId;
        //public List<EstablishmentRequestRelatedEstablishments> establishmentRequestRelatedEstablishments;
        public String establishmentNationalityId;
        public String establishmentPartnershipTypeId;
        //public String establishmentAgentTypeId;
        public String requestNumber;
        public String establishmentRequestTypeId;
        public String immigrationDepartmentId;
        public String establishmentNumber;
        public String partnerUnifiedNumber;
        public String establishmentRequestActionTypeId;
        public String ServiceTransactionId;
        public UD_Input(HexaBPM__Service_Request__c sr, list<Role__c> roles)
        {
            this.ServiceTransactionId = '148';//This is fixed value as per Tahaluf
            this.AdministrativeRegionId = '1'; //This is fixed value as per Tahaluf
            this.PreferedLanguageId = '2'; //English
            this.economicActivityId = '611';//Free zones
            this.establishmentNationalityId = '1';//United Arab Emirates
            this.immigrationDepartmentId = '17';//This is fixed value as per Tahaluf
            this.equityCapitalAmount = '0';
            
            //Signatory Details..
            for(Role__c r : roles)
            {
                this.partnerUnifiedNumber   = r.Unified_ID__c;
                this.investorUnifiedNumber  = r.Unified_ID__c;
                break;
            }
            this.establishmentRequestRelatedPersons = new List<EstablishmentRequestRelatedPersons>();
            for(Role__c r : roles)
            {
                EstablishmentRequestRelatedPersons erp = new EstablishmentRequestRelatedPersons(r);
                establishmentRequestRelatedPersons.add(erp);
            }
            
            //SR Details..
            this.establishmentRequestActionTypeId   = sr.establishmentRequestActionTypeId__c;
            this.establishmentRequestTypeId         = sr.Establishment_Request_Type__c;
            this.establishmentPartnershipTypeId     = sr.Establishment_Partnership_Type__c; 
            
            //Account Details..
            this.englishEstablishmentName           = sr.Establishment_English_Name__c;//sr.HexaBPM__Customer__r.Name + ' ADGM';
            this.arabicEstablishmentName            = sr.Establishment_Arabic_Name__c; //sr.HexaBPM__Customer__r.Account_Name_Arabic__c+' سوق أبوظبي العالمي';
            if(sr.establishmentRequestActionTypeId__c == '2')
                this.establishmentNumber                = sr.HexaBPM__Customer__r.Establishment_Card_No__c;
            
            this.investorPhoneNumber                = system.label.ICA_PhoneNumber;
            this.draftNumber                        = sr.New_Draft_Number__c;
            this.requestNumber                      = sr.TransactionRef__c; 
        }
    }

    /*public class EstablishmentEconomicActivities {
        public String ActivityDate;
        public String EconomicActivityId;
        public String EstablishmentPartyStatusId;
    }*/
}