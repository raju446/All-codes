/*********************************************************
        *   Author      :   Durga Prasad
        *   Company     :   PwC
        *   Date        :   05-Nov-2017
        *   Description :   Helper class for the Service Request Handler.
        * * --------------------------------------------------------------------------------------
        * * @Change History
        * Version    Author             Date            Description
          v1.1       Yogesh Mahajan     04/08/2019      Method to update invoice status = 'Consumed'
          v1.2       Durga Kandula      15/08/2019      ISSUE-000251 Method to delete the duplicate Initial Approvals Immediately
          v1.3      Shagufta Murshad  28/04/2021    Method to update contact upon residency data modification SR completion
    *********************************************************/
    public without sharing class ServiceRequestTriggerHelper{
        /*
            Method Name :   PopulateCreatedByLookup
            Description :   Method to Populate the CreatedBy Contact lookup field used in Community Sharing settings.
        */
        public static void PopulateCreatedByLookup(list<HexaBPM__Service_Request__c> lstSR){
            string ContactId;
            //  ISSUE-000643 START
            map<id,Document_Details__c> permitNumbers = new map<id,Document_Details__c>();
            set<id> accountids = new set<id>();
            //  ISSUE-000643 - END
            
            for(User usr:[Select Id,ContactId from User where Id=:userinfo.getUserId() and ContactId!=null]){
                ContactId = usr.ContactId;
            }
            for(HexaBPM__Service_Request__c SR:lstSR)
            {
                if(ContactId!=null)
                    SR.Created_By__c = ContactId;
                    
                //  ISSUE-000643 : Populate Permit number
                if(SR.HexaBPM__Record_Type_Name__c == 'Renew_Alcohol_Permit' || SR.HexaBPM__Record_Type_Name__c == 'Permit_Alcohol'){
                    accountids.add(SR.HexaBPM__Customer__c);
                }
            }
            
            //  ISSUE-000643
            if(!accountids.isEmpty())
            {
                for(Account acc : [Select id,(select id,Document_Number__c,Document_Expiry_Date__c from Document_Details__r where Document_Number__c != null and Document_Type__c='Alcohol Permit' Order by CreatedDate DESC LIMIT 1) from Account where Id IN:accountids])
                {
                    for(Document_Details__c dd : acc.Document_Details__r){ permitNumbers.put(acc.id,dd);}
                }
                for(HexaBPM__Service_Request__c SR:lstSR)
                {
                    if(SR.HexaBPM__Record_Type_Name__c == 'Renew_Alcohol_Permit')
                    {
                        if(!permitNumbers.containsKey(SR.HexaBPM__Customer__c))
                        {
                            SR.addError('Your company do not have alcohol permit yet to renew.'); 
                        }
                        else
                        {
                            SR.Permit_Number__c = permitNumbers.get(SR.HexaBPM__Customer__c).Document_Number__c;
                            SR.Valid_From__c = permitNumbers.get(SR.HexaBPM__Customer__c).Document_Expiry_Date__c;
                        }
                     }
                    else
                    {
                        if(permitNumbers.containsKey(SR.HexaBPM__Customer__c))
                        {
                                SR.addError('Your company already have an alcohol Permit.If it is expired, please raise renewal request.');
                        }
                    }
                }
            }
        }
        /*
            Method Name :   PopulateGovernmentAuthorityLookup
            Description :   Method to Populate the Government Authority Lookup field based on the picklist
        */
        public static void PopulateGovernmentAuthorityLookup(list<HexaBPM__Service_Request__c> lstSR){
            Map<string, Id> govAuthMap = new Map<string, Id>();
            boolean GetGovAuth = false;
            for(HexaBPM__Service_Request__c sr : lstSR){
                if(sr.Government_Authority_picklist__c != null)
                    GetGovAuth = true;
                    
            }
            if(GetGovAuth){
                for(Lookup__c gov : [SELECT Id, Name FROM Lookup__c WHERE Type__c = 'Government Authority']){
                    govAuthMap.put(gov.Name, gov.Id);
                }
            }
            for(HexaBPM__Service_Request__c sr : lstSR){
                if(sr.Government_Authority_picklist__c != null && govAuthMap.get(sr.Government_Authority_picklist__c)!=null)
                    sr.Government_Authority__c = govAuthMap.get(sr.Government_Authority_picklist__c);
            }
        }
        /*
            Method Name :   CalculateFines
            Description :   Method to calculate Fines if requesting for cancellattion or renewal after the expiry date
        */
        public static void CalculateFines(map<Id,HexaBPM__Service_Request__c> TriggerOld,list<HexaBPM__Service_Request__c> TriggerNew){
            /*
            map<string,list<Fines__c>> mapFineTypes = new map<string,list<Fines__c>>();
            for(Fines__c fine : Fines__c.getAll().values()){
                list<Fines__c> lstFines = new list<Fines__c>();
                if(mapFineTypes.get(fine.SR_Record_Type_Name__c.toLowerCase())!=null)
                    lstFines = mapFineTypes.get(fine.SR_Record_Type_Name__c.toLowerCase());
                lstFines.add(fine);
                mapFineTypes.put(fine.SR_Record_Type_Name__c.toLowerCase(),lstFines);
            }
            set<string> setAccountIds = new set<string>();
            set<string> setDocumentTypes = new set<string>();
            for(HexaBPM__Service_Request__c sr : TriggerNew){
                if(sr.HexaBPM__Customer__c!=null && TriggerOld.get(sr.Id).HexaBPM__Internal_SR_Status__c!=sr.HexaBPM__Internal_SR_Status__c && SR.HexaBPM__Internal_Status_Name__c=='Submitted' && sr.HexaBPM__Record_Type_Name__c!=null && mapFineTypes.get(sr.HexaBPM__Record_Type_Name__c.toLowerCase())!=null){
                    setAccountIds.add(sr.HexaBPM__Customer__c);
                    for(Fines__c fines:mapFineTypes.get(sr.HexaBPM__Record_Type_Name__c.toLowerCase())){
                        setDocumentTypes.add(fines.Document_Type__c);
                    }
                }
            }
            map<string,list<Document_Details__c>> MapAccDocumentDetails = new map<string,list<Document_Details__c>>();
            if(setDocumentTypes.size()>0 && setAccountIds.size()>0){
                for(Document_Details__c dd:[select Id,Document_Expiry_Date__c,Document_Type__c,Document_Status__c,Account__c from Document_Details__c where Account__c IN:setAccountIds and Document_Expiry_Date__c<:system.today() and Document_Type__c IN:setDocumentTypes and Document_Status__c='Active']){
                    list<Document_Details__c> lstDD = new list<Document_Details__c>();
                    if(MapAccDocumentDetails.get(dd.Account__c)!=null)
                        lstDD = MapAccDocumentDetails.get(dd.Account__c);
                    lstDD.add(dd);
                    MapAccDocumentDetails.put(dd.Account__c,lstDD);
                }
            }
            system.debug('MapAccDocumentDetails==>'+MapAccDocumentDetails);
            for(HexaBPM__Service_Request__c sr : TriggerNew){
                if(sr.HexaBPM__Customer__c!=null && TriggerOld.get(sr.Id).HexaBPM__Internal_SR_Status__c!=sr.HexaBPM__Internal_SR_Status__c && SR.HexaBPM__Internal_Status_Name__c=='Submitted' && sr.HexaBPM__Record_Type_Name__c!=null && mapFineTypes.get(sr.HexaBPM__Record_Type_Name__c.toLowerCase())!=null){
                    decimal TotalFineAmount = 0;
                    for(Fines__c Fines:mapFineTypes.get(sr.HexaBPM__Record_Type_Name__c.toLowerCase())){
                        string DocumentType = Fines.Document_Type__c;
                        decimal MaxCapAmount = Fines.Maximum_Fine_Amount__c;
                        integer GraceDays = 0;
                        if(Fines.Grace_Period__c!=null)
                            GraceDays = integer.valueOf(Fines.Grace_Period__c);
                        decimal FinePerMonth = Fines.Fine_Amount_Per_Month__c;
                        decimal FinePerDay = Fines.Fine_Amount__c;
                        decimal FirstMonthAmount = Fines.First_Month_Amount__c;
                        system.debug('DocumentType==>'+DocumentType);
                        if(MapAccDocumentDetails.get(sr.HexaBPM__Customer__c)!=null){
                            for(Document_Details__c DD:MapAccDocumentDetails.get(sr.HexaBPM__Customer__c)){
                                if(DD.Document_Type__c==DocumentType){
                                    Date ExpiredDate = DD.Document_Expiry_Date__c.addDays(GraceDays);
                                    integer DaysBetween = ExpiredDate.daysBetween(system.today());
                                    decimal CalculatedFineAmount = 0;
                                    if(FirstMonthAmount==null && FinePerMonth==null){
                                        if(FinePerDay!=null)
                                            CalculatedFineAmount = FinePerDay * DaysBetween;
                                    }else if(FirstMonthAmount!=null && FinePerMonth!=null){
                                        CalculatedFineAmount = CalculatedFineAmount + FirstMonthAmount;
                                        if(DaysBetween>30){
                                            decimal NumberofMonths = (DaysBetween-30)/30;
                                            integer ModVal = math.MOD(DaysBetween-30,30);
                                            if(ModVal>0)
                                                NumberofMonths = NumberofMonths + 1;
                                            CalculatedFineAmount = CalculatedFineAmount + (NumberofMonths*FinePerMonth);
                                        }
                                    }
                                    system.debug('CalculatedFineAmount==>'+CalculatedFineAmount);
                                    if(MaxCapAmount!=null && CalculatedFineAmount>MaxCapAmount)
                                        CalculatedFineAmount = MaxCapAmount;
                                    TotalFineAmount = TotalFineAmount + CalculatedFineAmount;
                                    break;
                                }
                            }
                        }
                    }
                    sr.Fine_Amount__c = TotalFineAmount;
                }
            }
            */
        }
        /*
            Method Name :   getAnnualAmount
            Description :   Method to get the annual amount of the fees
        */
        public static Decimal getAnnualAmount(Integer startMonth, String bundleType){
            Decimal totalAmount = 0;
            Map<String, PO_Box_Fees__c> poBoxFeesCSMap = new Map<String, PO_Box_Fees__c>();
            for(PO_Box_Fees__c poBoxFee : PO_Box_Fees__c.getAll().values()){
                poBoxFeesCSMap.put(poBoxFee.Name, poBoxFee);
            }
            System.debug('@@STARTMONTH: '+startMonth);
            Integer totalMonths = (12 - startMonth) + 1;
            if(poBoxFeesCSMap.get(bundleType)!=null && poBoxFeesCSMap.get(bundleType).Amount_Per_Month__c!=null)
                totalAmount = poBoxFeesCSMap.get(bundleType).Amount_Per_Month__c * totalMonths;
            return totalAmount;
        }
        
        /*
            Method Name :   ValidateResidenceVisaPassport
            Description :   Method to validate passport of new sr if already existing
        */
        public static void ValidateResidenceVisaPassport(List<HexaBPM__Service_Request__c> lstSR){
            Boolean hasExisting = false;
            Set<String> setOfPassport = new Set<String>();
            for(HexaBPM__Service_Request__c sr : lstSR){
                if(sr.HexaBPM__Record_Type_Name__c == 'Employment_Visa_New' || sr.HexaBPM__Record_Type_Name__c == 'Dependent_Visa_New'){
                    setOfPassport.add(sr.Passport_Number__c);
                }
            }
            if(!setOfPassport.isEmpty()){
                /*for(Document_Details__c docDetail : [SELECT Id FROM Document_Details__c 
                                                        WHERE Document_Type__c = 'Residence Visa' 
                                                        AND Passport_No__c IN :setOfPassport 
                                                        AND Document_Status__c = 'Active']){
                    hasExisting = true;
                }*/
            }
            
            for(HexaBPM__Service_Request__c sr : lstSR){
                if(sr.HexaBPM__Record_Type_Name__c == 'Employment_Visa_New' || sr.HexaBPM__Record_Type_Name__c == 'Dependent_Visa_New'){
                    if(hasExisting == true){
                        //sr.addError('There is an active Employee/Dependent with this Passport number.');
                    }
                }
            }
        }
        /*
            Method Name :   PopulateNationalityLookup
            Description :   Method to Populate the Nationality Lookup based on the Nationality picklist.
        */
        public static void PopulateNationalityLookup(list<HexaBPM__Service_Request__c> lstSR, Map<Id,HexaBPM__Service_Request__c> oldSRMap, Boolean isInsert){
            Map<String,Id> nationalityLookupMap = new Map<String,Id>();
            for(Lookup__c lkup : [SELECT Id, Name FROM Lookup__c WHERE Type__c = 'Nationality']){
                nationalityLookupMap.put(lkup.Name.toUpperCase(),lkup.Id);
            }
            
            if(isInsert == TRUE){
                for(HexaBPM__Service_Request__c objSR : lstSR){
                    if(nationalityLookupMap.containskey(objSR.Nationality__c)){
                        objSR.Nationality_Lookup__c = nationalityLookupMap.get(objSR.Nationality__c);
                    }
                }
            } else{
                for(HexaBPM__Service_Request__c objSR : lstSR){
                    if(objSR.Nationality__c != oldSRMap.get(objSR.Id).Nationality__c){
                        if(nationalityLookupMap.containskey(objSR.Nationality__c)){
                            objSR.Nationality_Lookup__c = nationalityLookupMap.get(objSR.Nationality__c);
                        }
                    }
                }
            }
            
        }
        /*
            Method Name :   AutoPopulateContactFields
            Description :   Method to Populate the Fields from contact based on the SR type.
        */
        public static void AutoPopulateContactFields(list<HexaBPM__Service_Request__c> lstSR, Map<Id,HexaBPM__Service_Request__c> srOldMap, Boolean isInsert){
        
            Map<String, String> mapConSRField = new Map<String, String>();
            Map<String, List<SR_Contact_Auto_Populate_Mapping__c>> srRectypeAutoMap = new Map<String, List<SR_Contact_Auto_Populate_Mapping__c>>();
            for(SR_Contact_Auto_Populate_Mapping__c cSRFieldMap : SR_Contact_Auto_Populate_Mapping__c.getAll().values()){
                if(cSRFieldMap.Active__c == TRUE){
                    mapConSRField.put(cSRFieldMap.Contact_Source_Field__c, cSRFieldMap.SR_Target_Field__c);
                    if(srRectypeAutoMap.containskey(cSRFieldMap.SR_Record_Type_API__c)){
                        srRectypeAutoMap.get(cSRFieldMap.SR_Record_Type_API__c).add(cSRFieldMap);
                    } else{
                        List<SR_Contact_Auto_Populate_Mapping__c> newFieldMap = new List<SR_Contact_Auto_Populate_Mapping__c>();
                        newFieldMap.add(cSRFieldMap);
                        srRectypeAutoMap.put(cSRFieldMap.SR_Record_Type_API__c, newFieldMap);
                    }
                }
            }
            system.debug('$$RECTYPEMAP: '+srRectypeAutoMap);
            system.debug('$$SR-CON_MAP: '+mapConSRField);
            Set<Id> contactIds = new Set<Id>();
            Set<String> residentVisaNum = new Set<String>();
            Set<Id> sponsorIds = new Set<Id>();
            for(HexaBPM__Service_Request__c objSR : lstSR)
            {
                if(objSR.HexaBPM__Record_Type_Name__c <> 'Dependent_Visa_Renewal'){
                    if(objSR.HexaBPM__Contact__c != null){
                        contactIds.add(objSR.HexaBPM__Contact__c);
                    }
                }
                else{
                    /*if(objSR.Dependent__c!= null){
                        contactIds.add(objSR.Dependent__c);
                    }*/
                    sponsorIds.add(objSR.HexaBPM__Contact__c);
                    if(isInsert == false)
                    {
                        if(objSR.Old_Residence_Visa_Number__c != srOldMap.get(objSR.Id).Old_Residence_Visa_Number__c){
                            residentVisaNum.add(objSR.Old_Residence_Visa_Number__c); 
                        }
                    }   
                    else{
                            residentVisaNum.add(objSR.Old_Residence_Visa_Number__c); 
                    }
                }
            }
            
            List<Contact> contactList = new List<Contact>();
            Map<String,Contact> dependentContactMap = new Map<String,Contact>();
            if(!contactIds.isEmpty()){
                String querySRStr = queryAllContactFields();
                List<Contact> conList = new List<Contact>();
                conList = Database.query(querySRStr);
                if(!conList.isEmpty()){
                    contactList.addAll(conList);
                }
            }
            if(!residentVisaNum.isEmpty()){
                String querySRStr = queryAllContactFieldsByResidenceVisaNum();
                List<Contact> conList = new List<Contact>();
                conList = Database.query(querySRStr);
                if(!conList.isEmpty()){
                    contactList.addAll(conList);
                    for(Contact objCon : conList){
                        dependentContactMap.put(objCon.Residence_Visa_Number__c,objCon);
                    }
                }
            }
            
            Map<Id,Contact> sponsorDetailMap = new Map<Id,Contact>();
            if(!contactList.isEmpty()){
                for(Contact objCon : contactList){
                    sponsorDetailMap.put(objCon.Id,objCon);
                }
            }
            
            for(HexaBPM__Service_Request__c objSR : lstSR){
                Id contactId = objSR.HexaBPM__Contact__c;
                if(objSR.HexaBPM__Record_Type_Name__c == 'Dependent_Visa_Renewal'){
                    contactId = null;
                    if(dependentContactMap.containskey(objSR.Old_Residence_Visa_Number__c)){
                        contactId = dependentContactMap.get(objSR.Old_Residence_Visa_Number__c).Id;
                        objSR.Dependent__c = contactId;
                    }
                    
                }
                if(contactId != null){
                    if(sponsorDetailMap.containskey(contactId)){
                        if(isInsert == true || (isInsert == false && objSR.HexaBPM__External_Status_Name__c == 'Draft')){
                            if(srRectypeAutoMap.containskey(objSR.HexaBPM__Record_Type_Name__c)){
                                for(SR_Contact_Auto_Populate_Mapping__c conMap : srRectypeAutoMap.get(objSR.HexaBPM__Record_Type_Name__c)){
                                    if(objSR.get(conMap.SR_Target_Field__c) == null){
                                        objSR.put(conMap.SR_Target_Field__c,sponsorDetailMap.get(contactId).get(conMap.Contact_Source_Field__c));
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        /*
            Method Name :   queryAllContactFields
            Description :   Method to query all contact fields from the set of contact ids.
        */
        public static string queryAllContactFields(){
            String queryStr = 'SELECT ';
            Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap();
            for(String s : objectFields.keySet()) {
               queryStr += ' ' + s + ', ';
            }
            queryStr = queryStr.subString(0,queryStr.Length()-2);
            queryStr += ' FROM Contact';
            queryStr += ' WHERE Id IN :contactIds';
            
            return queryStr;
        }
        /*
            Method Name :   queryAllContactFields
            Description :   Method to query all contact fields from the set of contact ids.
        */
        public static string queryAllContactFieldsByResidenceVisaNum(){
            String queryStr = 'SELECT ';
            Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap();
            for(String s : objectFields.keySet()) {
               queryStr += ' ' + s + ', ';
            }
            queryStr = queryStr.subString(0,queryStr.Length()-2);
            queryStr += ' FROM Contact';
            queryStr += ' WHERE Residence_Visa_Number__c IN :residentVisaNum';
            queryStr += ' AND Sponsor__c IN :sponsorIds';
            
            return queryStr;
        }
        
        
        /*
        Author : Azmath
        Description : This method will check the passport number and the emirates id with the existing active contacts and 
                        open SRs. If exists, throw an error.
        */
        public static void ValidateSR(list<HexaBPM__Service_Request__c> lstSR)
        {
            set<string> Srpassports = new set<string>();
            set<string> conList = new set<string>();
            set<string> accountids = new set<string>();
            set<string> validatePP = new set<string>();
            boolean ppexists = false;
            boolean eIDexists = false;
            string pp;
            string EID;
            String searchTerms = '';
    
            
            for(HexaBPM__Service_Request__c sr : lstSR)
            {
                set<string> recordtypes = new set<string>{'New_Work_Permit_Full_Time_Non_Sponsored_Employee'};
                
                if(recordtypes.contains(sr.HexaBPM__Record_Type_Name__c))
                {
                    if(sr.Passport_Number__c != null && sr.Passport_Number__c != ''){
                        Srpassports.add(sr.Passport_Number__c);
                        pp = sr.Passport_Number__c;
                    }
                    if(sr.Emirates_ID_Number__c != null && sr.Emirates_ID_Number__c != '') {EID = sr.Emirates_ID_Number__c;}
                }
                if(!String.isEmpty(pp))
                    searchTerms += '("' + pp + '")';
                
                if(!String.isEmpty(EID)){
                    if(!String.isEmpty(searchTerms)){
                        searchTerms += ' OR ';
                    }
                    searchTerms += '("' + EID + '")';
                }
            }
            if(!Srpassports.isEmpty())
            {
                
                set<id> contactRecTypes = new set<id>();
                
                for(RecordType rectype : [SELECT Id from RecordType WHERE sObjectType='Contact' AND 
                                            (DeveloperName='Contact_Employee' OR DeveloperName='Contact_Dependent') AND IsActive=true]){
                       contactRecTypes.add(rectype.id);
                }
                string status = 'Active';
                
                Search.SearchResults searchList = Search.find('FIND :searchTerms IN ALL FIELDS RETURNING Contact(Id,Passport_No__c,Emirates_ID_Number__c,Name where Recordtypeid IN:contactRecTypes and (Dependent_Status__c = :status OR Employment_Status__c =:status)), HexaBPM__Service_Request__c(Passport_Number__c,Emirates_ID_Number__c where HexaBPM__IsCancelled__c=false and HexaBPM__Is_Rejected__c = false AND HexaBPM__IsClosedStatus__c = false)');//where AccountId IN:accountids
                List<Search.SearchResult> contactlist = searchList.get('Contact');
                for(Search.SearchResult searchResult : contactlist)
                { 
                    Contact objCon = (Contact) searchResult.getSObject(); 
                    if(objCon.Passport_No__c == pp){
                        ppexists = true;
                    } 
                    if(objCon.Emirates_ID_Number__c == EID){
                        eIDexists = true;
                    }
                }
                
                List<Search.SearchResult> srlist = searchList.get('HexaBPM__Service_Request__c');
                for(Search.SearchResult searchResult : srlist){ 
                    HexaBPM__Service_Request__c objCon = (HexaBPM__Service_Request__c) searchResult.getSObject(); 
                    if(objCon.Passport_Number__c == pp){
                        ppexists = true;
                    }
                    if(objCon.Emirates_ID_Number__c == EID){
                        eIDexists = true;
                    }
                }
                for(HexaBPM__Service_Request__c sr : lstSR)
                {
                    if(ppexists == true)
                        sr.addError('You are not allowed to submit this request. Applicant is already existing in the system.Applicant with passport number - '+sr.Passport_Number__c +' is already existing system.');
                    
                    if(eIDexists == true)
                        sr.addError('You are not allowed to submit this request. Applicant is already existing in the system. Applicant with Emirates ID number - '+sr.Emirates_ID_Number__c +' is already existing system.');
                    
                }
            }
        }
        
        /*
        Author : Azmath
        Description : This method validates the Visa period against the category.
        */
        public static void validateVisaPeriod(list<HexaBPM__Service_Request__c> lstSR)
        {
            set<id> accountids = new set<id>();
            set<id> preventSave = new set<id>();
            for(HexaBPM__Service_Request__c sr : lstSR)
            {
                if((sr.HexaBPM__Record_Type_Name__c == 'Employment_Visa_New' || sr.HexaBPM__Record_Type_Name__c == 'Employment_Visa_Renewal') && sr.Visa_Period__c == '1' && sr.HexaBPM__Submitted_Date__c == null)
                {
                    accountids.add(sr.HexaBPM__Customer__c);
                }
            }
            if(!accountids.isEmpty())
            {
                
                for(Account acc : [Select Category__c,(Select id,Activity_Name__c from Business_Activities__r) FROM Account where id IN:accountids])
                {
                    if(acc.Category__c == 'Retail (Category C)'){
                        preventSave.add(acc.id);
                    }
                    else if(acc.Category__c == 'Non-Financial (Category B)'){
                        for(Business_Activity__c ba : acc.Business_Activities__r){
                            if(ba.Activity_Name__c.contains('Hotel Management'))
                                preventSave.add(acc.id);
                        }
                    }
                }
                for(HexaBPM__Service_Request__c sr : lstSR)
                {
                    if(preventSave.contains(sr.HexaBPM__Customer__c))
                        sr.addError('Please select valid visa period.');
                }
            }
            
        }
        
        
        /*
        Author : Azmath
        Description : This method checks if there are any employees with active status before applying for estb. cancellattion SR.
        Ticket Number : ISSUE-000668
        */
        public static void checkEmployeeStatus(list<HexaBPM__Service_Request__c> lstSR)
        {
            set<id> accountids = new set<id>();
            set<id> preventSave = new set<id>();
            for(HexaBPM__Service_Request__c sr : lstSR)
            {
                if(sr.HexaBPM__Record_Type_Name__c == 'Establishment_Card_Cancellation')
                {
                    accountids.add(sr.HexaBPM__Customer__c);
                }
            }
            if(!accountids.isEmpty())
            {
                for(Account acc : [Select id,(Select id from Contacts where Employment_Status__c='Active' limit 1) FROM Account where id IN:accountids])
                {
                    if(acc.contacts != null && acc.contacts.size()>0)
                    preventSave.add(acc.id);
                }
                for(HexaBPM__Service_Request__c sr : lstSR)
                {
                    if(preventSave.contains(sr.HexaBPM__Customer__c))
                        sr.addError('Please cancel all the employee visas/permits before cancelling the establishment card.');
                }
            }
        }
        
        /*
            Method Name :   updateInvoiceStatus
            Description :   Method to update invoice status = 'Consumed'
        */
        /*public static void updateInvoiceStatus (Set<Id> setSRIds) {
            List<Invoice__c> listInvoice = new List<Invoice__c>();
            
            for(Invoice__c objInvoice : [select id, Status__c, Service_Request__c from Invoice__c where Service_Request__c IN : setSRIds]) {
                objInvoice.Status__c = 'Consumed';
                listInvoice.add(objInvoice);
            }
            
            if(listInvoice <> null && listInvoice.size() > 0) {
                update listInvoice;
            }
        }*/
        
        /*
            Method Name :   DeleteDuplicateInitialApprovals
            Description :   Method to delete the duplicate Initial Approval SR's
        */
        public static void DeleteDuplicateInitialApprovals(list<HexaBPM__Service_Request__c> TriggerNew){//v1.2
            /*list<HexaBPM__Service_Request__c> lstSRTBD = new list<HexaBPM__Service_Request__c>();
            set<string> setAccountIds = new set<string>();
            for(HexaBPM__Service_Request__c SR:TriggerNew){
                if(SR.HexaBPM__Record_Type_Name__c =='Initial_Approval' && SR.HexaBPM__Customer__c!=null)
                    setAccountIds.add(SR.HexaBPM__Customer__c);
            }
            if(setAccountIds.size()>0){
                lstSRTBD = [Select Id from HexaBPM__Service_Request__c where HexaBPM__Customer__c IN:setAccountIds AND HexaBPM__Record_Type_Name__c ='Initial_Approval' AND (HexaBPM__External_Status_Name__c='Submitted' OR HexaBPM__External_Status_Name__c='Draft') AND Id NOT IN:TriggerNew];
                if(lstSRTBD!=null && lstSRTBD.size()>0){
                    try{
                        //delete lstSRTBD;
                    }catch(Exception e){}
                }
            }*/
        }
        
        /*
            Method Name :   beforeInsert
            Description :   Method to perform all beforeinsert activities..
        */
        public static void beforeInsert(list<HexaBPM__Service_Request__c> TriggerNew)
        {
            set<id> accountids = new set<id>();
            set<id> IAAccountids = new set<id>();
            map<id,Address__c> addressesmap = new map<id,Address__c>();
            for(HexaBPM__Service_Request__c sr : TriggerNew){
                if(sr.HexaBPM__Record_Type_Name__c == 'Temporary_Fit_Out_Security_Clearance'){
                    accountids.add(sr.HexaBPM__Customer__c);
                }
                if(sr.HexaBPM__Record_Type_Name__c == 'Initial_Approval'){
                    IAAccountids.add(sr.HexaBPM__Customer__c);
                }
            }
            if(!accountids.isEmpty()){
                for(Address__c address : [SELECT Entity__c,Office_Number__c,Floor__c,Building_Name__c,Street_Name_of_Cluster_on_the_Island__c, State__c,Emirates__c FROM Address__c
                                            WHERE Type__c='Physical' and Entity__c IN:accountids])
                {
                    addressesmap.put(address.Entity__c,address);
                }
            }
            
            //1. Populate physical address..
            if(!addressesmap.isEmpty()){
                for(HexaBPM__Service_Request__c sr : TriggerNew){
                    if(sr.HexaBPM__Record_Type_Name__c == 'Temporary_Fit_Out_Security_Clearance' && addressesmap.containsKey(sr.HexaBPM__Customer__c)){
                        string address='';
                        Address__c add = addressesmap.get(sr.HexaBPM__Customer__c);
                        address+=(!string.isBlank(add.Office_Number__c))?add.Office_Number__c+',':'';
                        address+=(!string.isBlank(add.Floor__c))?add.Floor__c+',':'';
                        address+=(!string.isBlank(add.Building_Name__c))?add.Building_Name__c+',':''+',';
                        address+=(!string.isBlank(add.Street_Name_of_Cluster_on_the_Island__c))?add.Street_Name_of_Cluster_on_the_Island__c+',':'';
                        address+=(!string.isBlank(add.State__c))?add.State__c+',':'';
                        address+=(!string.isBlank(add.Emirates__c))?add.Emirates__c:'';
                        sr.Entity_Physical_Address__c = address;
                    }
                }
            }
            
            //Check if parent Sr is closed..
            set<id> parentids = new set<id>();
            for(HexaBPM__Service_Request__c sr : TriggerNew){
                if(sr.HexaBPM__Record_Type_Name__c == 'ADGM_Permit_Amendment_Service_Request'){
                    parentids.add(sr.HexaBPM__Parent_SR__c);
                }
            }
            if(!parentids.isEmpty())
            {
                map<id,id> parentchildmap = new map<id,id>();
                set<id> validSR = new set<id>();
                for(HexaBPM__Service_Request__c sr : [select id,HexaBPM__IsClosedStatus__c,End_Date__c, Is_SR_Cancelled__c  from HexaBPM__Service_Request__c where Id in:parentids])
                {
                    if(sr.HexaBPM__IsClosedStatus__c == true && sr.Is_SR_Cancelled__c == false && sr.End_Date__c >= Date.today()){
                        validSR.add(sr.id);
                    }
                }
                //if(!paentset.isEmpty()){
                     for(HexaBPM__Service_Request__c sr : TriggerNew){
                        if(!validSR.contains(sr.HexaBPM__Parent_SR__c))
                        {
                            if(sr.ADP_Record_Type__c != 'Temporary_Fit_Out_Security_Clearance' && sr.ADP_Record_Type__c != 'Permit_Entertainment'
                                && sr.ADP_Record_Type__c != 'Extended_Operating_Hours'){
                                sr.addError('Please select allowed permit types to amend/cancel.');
                            }else
                              sr.addError('You cannot apply for amendment if Parent SR is not closed (or) Parent SR permit end date is passed (or) Parent SR is cancelled.');
                        }
                     }
                //}
            }
            
            //ICA Changes.
            if(!IAAccountids.isEmpty()){
              map<id,Account> accmap = new map<id,Account>();
              for(Account acc : [Select id,Name,Account_Name_Arabic__c, Establishment_English_Name__c, Establishment_Arabic_Name__c from Account where id in:IAAccountids])
              {
                accmap.put(acc.id,acc);
              }
              if(!accmap.isEmpty())
              {
                 for(HexaBPM__Service_Request__c sr : TriggerNew){
                    if(sr.HexaBPM__Record_Type_Name__c == 'Initial_Approval'){
                      if(accmap.containsKey(sr.HexaBPM__Customer__c)){
                        Account ac = accmap.get(sr.HexaBPM__Customer__c);
                        if(ac.Establishment_English_Name__c == null || sr.IA_Reason__c =='Name Change')
                        {
                          sr.Establishment_English_Name__c = ac.Name+' ADGM';
                          sr.Establishment_Arabic_Name__c = ac.Account_Name_Arabic__c+' '+system.label.ICA_ArabicADGM;//+' سوق أبوظبي العالمي';
                        }else{
                          sr.Establishment_English_Name__c = ac.Establishment_English_Name__c;
                          sr.Establishment_Arabic_Name__c = ac.Establishment_Arabic_Name__c;
                        }
                      }
                    }
                 }
              }
            }
        }
        
        /*
            Method Name :   populateSRReferenceNo
            Description :   Method to populate SR Reference Number
        */
        /*public static void populateSRReferenceNo(list<HexaBPM__Service_Request__c> TriggerNew){
            try{
                for(HexaBPM__Service_Request__c objSR : TriggerNew){
                    string RandomNum1 = generateReferenceNo(4);
                    string RandomNum2 = generateReferenceNo(4);
                    string RandomNum3 = generateReferenceNo(4);
                    string RandomNum4 = generateReferenceNo(4);
                    objSR.SR_Reference_Number__c = RandomNum1+RandomNum2+RandomNum3+RandomNum4;
                }
            } catch(Exception e){
            
            }
        }*/
        
        /*
            Method Name :   generateReferenceNo
            Description :   utility method to generate sr reference Number
        */
        /*public static string generateReferenceNo(integer len){
            string chars = 'BCDAEFGHIJKLMNOPQRSTUVWXYZ5678901234abcdefghijklmnopqrstuvwxyz';
            string randStr = '';
            
            while (randStr.length() < len) {
                Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
                randStr += chars.substring(idx, idx+1);
            }
            
            return randStr;
        }*/
        
        /*
            Method Name :   ResidencyDataModificationContactUpdate
            Description :   method to update cotact on visa holder data modification request completion
        */
        /*public static void ResidencyDataModificationContactUpdate(list<HexaBPM__Service_Request__c> lstSR){
            List<Contact> lstContactTBU = new List<Contact>();
            for(HexaBPM__Service_Request__c SR : lstSR){
                if(SR.HexaBPM__Record_Type_Name__c == 'Residency_Data_Modification_Service_Request' && SR.HexaBPM__External_Status_Name__c == 'Service Request Completed' ) {
                    Contact c = new Contact();
                    c.Id = SR.HexaBPM__Contact__c;
                    if(SR.Amendment_Required_List__c.contains('Name in English')){
                        c.FirstName = SR.First_Name__c;
                        c.LastName = SR.Last_Name__c;
                    }
                    if(SR.Amendment_Required_List__c.contains('Name in Arabic')){
                        c.Arabic_First_Name__c = SR.First_Name_Arabic__c;
                        c.Arabic_Last_Name__c = SR.Last_Name_Arabic__c;
                    }
                    if(SR.Amendment_Required_List__c.contains('Middle Name')){
                        c.Middle_Name__c = SR.Middle_Name__c;
                    }
                    if(SR.Amendment_Required_List__c.contains('Mother\'s Name')){
                        c.Mother_s_Name__c = SR.Mother_s_Name__c;
                    }
                    if(SR.Amendment_Required_List__c.contains('Religion')){
                        c.Religion__c = SR.Religion__c;
                    }
                    if(SR.Amendment_Required_List__c.contains('Date of Birth')){
                        c.Birthdate = SR.Date_of_Birth__c;
                    }
                    if(SR.Amendment_Required_List__c.contains('Nationality')){
                        c.Nationality__c = SR.Nationality__c;
                    }
                    if(SR.Amendment_Required_List__c.contains('Passport Number')){
                        c.Passport_Number__c = SR.Passport_Number__c;
                    }
                    lstContactTBU.add(c);
                }            
            }
            if(lstContactTBU.size()>0)
                update lstContactTBU;
        }*/
    }