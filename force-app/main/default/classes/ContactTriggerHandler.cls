/*
    Author      : Kim Noceda
    Date        : 19-Sep-2017
    Description : Trigger handler class that is being referenced in the ContactTrigger.
                  All DML methods are being handled in this handler class.
    --------------------------------------------------------------------------------------
     * @Change History
     * Author       Date            Description
     * Rajil        17-09-2018      V1.1 : Method to associate Entity when a contact is created 
                                    from Zapier "Full Contact Business Card" (Applicable to create contacts
                                    with RecordType "Contact - ADGM Court" from Zapier)
       Rajil        05/03/2018      V1.2 : method to translate firstNam,LastName English Fields to Arabic using Google API.
     * Yogesh       15/05/2019      Contact Id Encryption in field
     * Yogesh       15/05/2019      Add Country code values in phone field
     * Yogesh       16/07/2019      Add logic to by pass sharing rule for protocol if alternet email is been added with ('+1@' in email)
     * CRM Support  12/04/2020      Introduced new field and Method to populatethe address on contact from account fields, This is called in before insert
     * Naman        27/06/2021      Updated the method - mergeContactPhoneFields to bypass merging only for FSRA Connect related contacts as country code is not captured for them.

*/
global without sharing class ContactTriggerHandler {

    public static Map<String,Id> mapofContactRecordTypeNameandId = new Map<String,Id>();
    //method to check if the portal user creation flag is masrked as checked 
    public static void createPortalUser(List<Contact> newContactList){
        mapofContactRecordTypeNameandId = ApexCodeUtility.getRecTypeDetails('Contact');
        List<Id> contactIds = new List<Id>();
        Set<id> protocolContactIds = new Set<id>();
        String contactBR_PRecordtypreId ;
        if(mapofContactRecordTypeNameandId <> null && mapofContactRecordTypeNameandId.values().size() > 0 && mapofContactRecordTypeNameandId.containsKey('Contact – ADGM BR&P')) {
            contactBR_PRecordtypreId = mapofContactRecordTypeNameandId.get('Contact – ADGM BR&P');
        }
        for(Contact con : newContactList){
            if(con.Portal_User_Creation__c == true){
                contactIds.add(con.Id);
            }
            
            if(contactBR_PRecordtypreId <> null && con.recordtypeid == contactBR_PRecordtypreId){
                  protocolContactIds.add(con.Id);
            }
        }
        if(!contactIds.isEmpty()){
            createUser(contactIds);
        }
        Trigger_Settings__c TS = Trigger_Settings__c.getValues('ContactTrgr_TranslateField');
          if(TS != null && TS.is_Active__c == TRUE){
              if(!ApexCodeUtility.ContactTriggerRecursive && protocolContactIds != null && protocolContactIds.size() > 0)
                  ContactTriggerHandler.translateField(protocolContactIds, contactBR_PRecordtypreId);
         }
    }

    public static void Execute_BI() {
        List<Contact> listContact = new List<Contact>();
        mapofContactRecordTypeNameandId = ApexCodeUtility.getRecTypeDetails('Contact');
        String contactBR_PRecordtypreId ;
        if(mapofContactRecordTypeNameandId <> null && mapofContactRecordTypeNameandId.values().size() > 0 && mapofContactRecordTypeNameandId.containsKey('Contact – ADGM BR&P')) {
            contactBR_PRecordtypreId = mapofContactRecordTypeNameandId.get('Contact – ADGM BR&P');
        }
        List<Contact> listProtocolContact = new List<Contact>();
        for(Contact objContact : (List<Contact>)Trigger.New) {
            if(contactBR_PRecordtypreId <> null && objContact.recordtypeid == contactBR_PRecordtypreId && (objContact.MobilePhone <> null || objContact.Alternative_Phone_Number_1__c <> null)){
                listContact.add(objContact);
            }
            if(contactBR_PRecordtypreId <> null && objContact.recordtypeid == contactBR_PRecordtypreId ) {
                listProtocolContact.add(objContact);
            }
        }
        if(listContact <> null && listContact.size() > 0) {
            mergeContactPhoneFields(listContact);
        }
        if(listProtocolContact <> null && listProtocolContact.size() > 0) {
            changeProtocolEmail(listProtocolContact);
        }
        //CRM Support
        populateContactAddressFromAccont(trigger.new); 
    }
    
    public static void Execute_BU() {
        mapofContactRecordTypeNameandId = ApexCodeUtility.getRecTypeDetails('Contact');
        List<Contact> listContact = new List<Contact>();
        Map<Id, Contact> oldContactMap = new Map<Id, Contact>();
        oldContactMap = (Map<Id, Contact>) Trigger.oldMap;
        String contactBR_PRecordtypreId ;
        if(mapofContactRecordTypeNameandId <> null && mapofContactRecordTypeNameandId.values().size() > 0 && mapofContactRecordTypeNameandId.containsKey('Contact – ADGM BR&P')) {
            contactBR_PRecordtypreId = mapofContactRecordTypeNameandId.get('Contact – ADGM BR&P');
        }
        List<Contact> listProtocolContact = new List<Contact>();
        //Check old and new values for phone field
        for(Contact objContact : (List<Contact>)Trigger.New) {
            if(contactBR_PRecordtypreId <> null && objContact.recordtypeid == contactBR_PRecordtypreId && 
              (objContact.MobilePhone <> oldContactMap.get(objContact.id).MobilePhone || objContact.CRM_Mobile_Country_Code__c <> oldContactMap.get(objContact.id).CRM_Mobile_Country_Code__c
              || objContact.CRM_Alt_Ph_Num_Country_Code__c <> oldContactMap.get(objContact.id).CRM_Alt_Ph_Num_Country_Code__c || objContact.Alternative_Phone_Number_1__c <> oldContactMap.get(objContact.id).Alternative_Phone_Number_1__c)){
                listContact.add(objContact);
            }
            if(contactBR_PRecordtypreId <> null && objContact.recordtypeid == contactBR_PRecordtypreId && objContact.Email <> oldContactMap.get(objContact.id).Email) {
                listProtocolContact.add(objContact);
            }
        }
        if(listContact <> null && listContact.size() > 0) {
             mergeContactPhoneFields(listContact);
        }
        if(listProtocolContact <> null && listProtocolContact.size() > 0) {
            changeProtocolEmail(listProtocolContact);
        }
    }
    public static void Execute_AI() {
       populateEncryptedValue();
        addExternalMember();
    }
    
    
    public static void Execute_AU(list<Contact> newContact,map<Id,Contact> TriggerOldMap){
        mapofContactRecordTypeNameandId = ApexCodeUtility.getRecTypeDetails('Contact');
        String contactBR_PRecordtypreId ;
        if(mapofContactRecordTypeNameandId <> null && mapofContactRecordTypeNameandId.values().size() > 0 && mapofContactRecordTypeNameandId.containsKey('Contact – ADGM BR&P')) {
            contactBR_PRecordtypreId = mapofContactRecordTypeNameandId.get('Contact – ADGM BR&P');
        }
        Set<Id> protocolContactIds = new Set<Id>();
        for(Contact contact : newContact){
            System.debug(contact.recordtypeid);
            if(contactBR_PRecordtypreId <> null && contact.recordtypeid == contactBR_PRecordtypreId &&
                (contact.FirstName != TriggerOldMap.get(contact.id).FirstName || contact.LastName != TriggerOldMap.get(contact.id).LastName) || contact.Middle_Name__c != TriggerOldMap.get(contact.id).Middle_Name__c)
                protocolContactIds.add(contact.id);
        }
        Trigger_Settings__c TS = Trigger_Settings__c.getValues('ContactTrgr_TranslateField');
        if(TS != null && TS.is_Active__c == TRUE){
            if(!ApexCodeUtility.ContactTriggerRecursive && protocolContactIds != null && protocolContactIds.size() > 0)
                ContactTriggerHandler.translateField(protocolContactIds, contactBR_PRecordtypreId);
        }
    }
    
    /**
    * populateContactAddressFromAccont
    * 
    * Introduced in CRM Support 
    * This method is supposed to be called from before insert trigger
    * The method will be used to populate the address fields from the related account record
    *
    * @param  conList    List of Contacts
    * @return void
    */
    public static void populateContactAddressFromAccont(list<Contact> conList){
        map<ID,Account> relatedAccounts=new map<Id,Account>();
        for(Contact con: conList){
            if(con.AccountID!=null && con.Default_Account_Address__c){
                con.Default_Account_Address__c=false;
                relatedAccounts.put(con.AccountID,null);
            }
        }
        relatedAccounts=new map<Id,Account>([select id,Zip_Postal_Code_PO_Box__c,Street__c,State_Province__c,
                                            Country__c,City__c from account where id in :relatedAccounts.KeySet()]);
        for(Contact con: conList){
            if(relatedAccounts.containsKey(con.AccountID)){
                con.Country__c=relatedAccounts.get(con.AccountID).Country__c;
                con.State_Province__c=relatedAccounts.get(con.AccountID).State_Province__c;
                con.Street__c=relatedAccounts.get(con.AccountID).Street__c;
                con.Lead_City__c=relatedAccounts.get(con.AccountID).City__c;
                con.Zip_Postal_Code_PO_Box__c=relatedAccounts.get(con.AccountID).Zip_Postal_Code_PO_Box__c;
            }
        }
    }
    //method to create an alias for the portal user
    public static String createAlias(String lastName, String FirstName){
        final String chars = '0123456789';
        /*String aliasStr = FirstName.subString(0,1);       
        if(lastName!=null && lastName.length()>=2)      
            aliasStr = aliasStr + lastName.subString(0,2);      
        string randStr = '';        
        while (randStr.length() < 4) {      
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());     
           randStr += chars.substring(idx, idx+1);      
        }       
        aliasStr = aliasStr + randStr;*/
        String aliasStr = String.valueof(lastName.substring(0,1) + string.valueof(Math.random()).substring(4,9));  
        return aliasStr;
    }
    
    //method to create the username for the portal user with @adgm.portal as the domain
    /*public static String createUserName(String emailStr){
        String newUserEmail = emailStr;
        newUserEmail = newUserEmail.substringBefore('@');
        newUserEmail = newUserEmail + '@adgm.portal';  
        return newUserEmail;
    }*/
    
    //method to create and insert the portal user from the contact record
    public static void createUser(List<Id> contactIds){
        list<User> newPortalUsers = new list<User>();
        //list<Profile> profileCommunityAdmin = [SELECT Id, Name FROM Profile WHERE Name = :Label.Community_Profile_Name LIMIT 1];
        string PortalAdminProfileId;
        for(Profile pf:[SELECT Id, Name FROM Profile WHERE Name = :Label.Community_Profile_Name LIMIT 1]){
            PortalAdminProfileId = pf.Id;
        }
         //list<Profile> profileCommunityNonAdmin = [SELECT Id, Name FROM Profile WHERE Name = :Label.Community_Profile_Non_Admin_Name LIMIT 1]; 
        list<Profile> profileGuest = [SELECT Id, Name FROM Profile WHERE Name = :Label.Guest_User_Profile_Name LIMIT 1];
        
         /*
        map<string,string> MapRegUserProfiles = new map<string,string>();
        set<string> setRegUserProfileNames = new set<string>();
        map<string,string> MapUserProfileMapping = new map<string,string>();
        //{'ADGM Community Company Services User','ADGM Community Letters and Permits User','ADGM Community Visa Services User','  ADGM Community CS and VS User','ADGM Community LP and CS User','ADGM Community LP and VS User'};
        for(AccessADGM_Profile_Management__mdt mdt:[Select Profile_Name__c,Types_of_Services_Accessible__c from AccessADGM_Profile_Management__mdt limit 10000]){
          if(mdt.Profile_Name__c!=null){
            setRegUserProfileNames.add(mdt.Profile_Name__c);
            if(mdt.Types_of_Services_Accessible__c!=null)
              MapUserProfileMapping.put(mdt.Types_of_Services_Accessible__c,mdt.Profile_Name__c);
          }
        }
        for(Profile pf:[Select Id,Name from Profile where Name IN:setRegUserProfileNames]){
          MapRegUserProfiles.put(pf.Name,pf.Id);
        }
        */
        for(Contact con : [Select Id, FirstName, LastName,Types_of_Services_Accessible__c, Email, AccountId, Is_Guest_User__c, Community_Username__c, Title, MobilePhone, Role__c,Account.Entity_Sub_Type__c, Account.Entity_Type__c  
                            FROM Contact WHERE Id IN :contactIds]){
            User portalUser = new User();
            portalUser.Title = con.Title;
            portalUser.Phone = con.MobilePhone;
            portalUser.FirstName = con.FirstName;
            portalUser.LastName = con.LastName;
            portalUser.Email = con.Email;
            String nickNameStr = createAlias(con.LastName, con.FirstName);
            portalUser.CommunityNickname = nickNameStr;
            portalUser.Alias = nickNameStr;
            portalUser.UserName = con.Community_Username__c;
            portalUser.ContactId = con.Id;
            portalUser.Types_of_Services_Accessible__c = con.Types_of_Services_Accessible__c;
            if(con.Is_Guest_User__c == true){
                if(profileGuest!=null && profileGuest.size()>0)
                    portalUser.ProfileId = profileGuest[0].Id;
            }else{
                if(PortalAdminProfileId!=null && con.Types_of_Services_Accessible__c!=null && con.Types_of_Services_Accessible__c.indexOf('Company Services')>-1 && con.Types_of_Services_Accessible__c.indexOf('Payment - Account Services')>-1 && con.Types_of_Services_Accessible__c.indexOf('Permits Services')>-1 && con.Types_of_Services_Accessible__c.indexOf('Visa & Letter Services')>-1){
                    portalUser.ProfileId = PortalAdminProfileId;
                    portalUser.Role__c = 'Lead Admin';
                }else{
                     /*
                  if(con.Types_of_Services_Accessible__c!=null && MapUserProfileMapping.get(con.Types_of_Services_Accessible__c)!=null){
                    string ProfileName = MapUserProfileMapping.get(con.Types_of_Services_Accessible__c);
                    string ProfileId = MapRegUserProfiles.get(ProfileName);
                    system.debug('ProfileName==>'+ProfileName);
                    system.debug('ProfileId==>'+ProfileId);
                    if(ProfileId!=null)
                      portalUser.ProfileId = ProfileId;
                    
                    //
                    if(con.Types_of_Services_Accessible__c.indexOfIgnoreCase('Company Services')>-1 && con.Types_of_Services_Accessible__c.indexOfIgnoreCase('Visa Services')>-1 && con.Types_of_Services_Accessible__c.indexOfIgnoreCase('Letters & Permits')>-1){
                      portalUser.ProfileId = profileCommunityAdmin[0].Id;
                    }else if(con.Types_of_Services_Accessible__c.indexOfIgnoreCase('Company Services')>-1 && con.Types_of_Services_Accessible__c.indexOfIgnoreCase('Visa Services')>-1 && con.Types_of_Services_Accessible__c.indexOfIgnoreCase('Letters & Permits')==-1){
                      if(MapRegUserProfiles.get('ADGM Community CS and VS User')!=null)
                        portalUser.ProfileId = MapRegUserProfiles.get('ADGM Community CS and VS User');
                    }else if(con.Types_of_Services_Accessible__c.indexOfIgnoreCase('Visa Services')>-1 && con.Types_of_Services_Accessible__c.indexOfIgnoreCase('Letters & Permits')>-1 && con.Types_of_Services_Accessible__c.indexOfIgnoreCase('Company Services')==-1){
                      if(MapRegUserProfiles.get('ADGM Community LP and VS User')!=null)
                        portalUser.ProfileId = MapRegUserProfiles.get('ADGM Community LP and VS User');
                    }else if(con.Types_of_Services_Accessible__c.indexOfIgnoreCase('Company Services')>-1 && con.Types_of_Services_Accessible__c.indexOfIgnoreCase('Letters & Permits')>-1 && con.Types_of_Services_Accessible__c.indexOfIgnoreCase('Visa Services')==-1){
                      if(MapRegUserProfiles.get('ADGM Community LP and CS User')!=null)
                        portalUser.ProfileId = MapRegUserProfiles.get('ADGM Community LP and CS User');
                    }else if(con.Types_of_Services_Accessible__c.indexOfIgnoreCase('Company Services')>-1){
                      if(MapRegUserProfiles.get('ADGM Community Company Services User')!=null)
                        portalUser.ProfileId = MapRegUserProfiles.get('ADGM Community Company Services User');
                    }else if(con.Types_of_Services_Accessible__c.indexOfIgnoreCase('Visa Services')>-1){
                      if(MapRegUserProfiles.get('ADGM Community Visa Services User')!=null)
                        portalUser.ProfileId = MapRegUserProfiles.get('ADGM Community Visa Services User');
                    }else if(con.Types_of_Services_Accessible__c.indexOfIgnoreCase('Letters & Permits')>-1){
                      if(MapRegUserProfiles.get('ADGM Community Letters and Permits User')!=null)
                        portalUser.ProfileId = MapRegUserProfiles.get('ADGM Community Letters and Permits User');
                    }
                    //
                  }else{
                    portalUser.ProfileId = profileCommunityNonAdmin[0].Id;
                  }
                  */
                    if(con.Types_of_Services_Accessible__c!=null && con.Types_of_Services_Accessible__c.indexOf('Payment - Account Services')>-1)
                        portalUser.ProfileId = label.OSS_Community_Login_User_Payment;
                    else
                        portalUser.ProfileId = label.OSS_Community_Login_User;
                }
            }
            portalUser.TimeZoneSidKey = 'Asia/Dubai'; // Required
            portalUser.LocaleSidKey = 'en_GB'; // Required
            portalUser.EmailEncodingKey = 'ISO-8859-1'; // Required
            portalUser.LanguageLocaleKey = 'en_US'; // Required
            system.debug('##USERNAME: '+portalUser.UserName);
            newPortalUsers.add(portalUser);
        }
        
        if(!newPortalUsers.isEmpty()){
            insert newPortalUsers;
            list<Id> listUserIds = new list<Id>();
            for(User usr:newPortalUsers){
                if(usr.ProfileId!=PortalAdminProfileId)
                    listUserIds.add(usr.Id);
            }
            AssignPermissionSetToUsers(listUserIds);
        }
    }
    
    //method to populate Previous Company Name of the AccountId of the Contact is changed.
    public static void populatePreviousCompanyName(List<Contact> newContactList, Map<Id, Contact> oldContactMap){
        Set<Id> oldAccountIds = new Set<Id>();
        Map<Id, String> accountNameMap = new Map<Id, String>();
        for(Contact con : newContactList){
            if(con.AccountId != oldContactMap.get(con.Id).AccountId){
                oldAccountIds.add(oldContactMap.get(con.Id).AccountId);
            }
        }
        
        for(Account acct : [SELECT Id, Name FROM Account WHERE Id IN :oldAccountIds]){
            accountNameMap.put(acct.Id, acct.Name);
        }
        
        for(Contact con : newContactList){
            if(con.AccountId != oldContactMap.get(con.Id).AccountId){
                con.Previous_Company_Name__c = accountNameMap.get(oldContactMap.get(con.Id).AccountId);
            }
        }
    }
    public static string getRecTypeId(String SObjectName, String recordTypeLabel){
        string recid;
        if(SObjectName == 'Contact')
            recid = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();  
        else if(SObjectName == 'Account')      
            recid = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();  
        return recid;
    }
    //V1.1: Method to associate Entity when a contact is created from "Full Contact Business Card"
    public static void populateAccountForContact(List<Contact> newContactList){

        //1. Find whether the new contact which is coming through "FullContact Scanner" has a account present. If not, 
        //   create that account and associate to that contact.
        //2. If the Account already exists for the incoming contact, associate the contact with the existing account. [Account creation not needed for this]
        Set<string> companyNames = new Set<string>();
        List<Contact> contactsWithEmptyAccounts = new List<Contact>();
        for(Contact contact : newContactList){
            if(String.isNotBlank(contact.CRM_Company_Name__c)){
                companyNames.add(contact.CRM_Company_Name__c);
                if(String.isBlank(contact.AccountId) && contact.LeadSource == 'Full Contact Business Card' 
                    && contact.RecordTypeId == getRecTypeId('Contact','Contact - ADGM Court') ){
                        contactsWithEmptyAccounts.add(contact);
                }
            }
        }
        if (contactsWithEmptyAccounts.size() > 0) {
            map<string,string> mapAccountId = new map<string,string>();
            for(Account acc : [select Id,Name from Account where Name in :companyNames]){
                mapAccountId.put(acc.Name,acc.Id);
            }
            List<Account> newAccounts = new List<Account>();
            String accountName;
            Map<String,list<Contact>> contactsByNameKeys = new Map<String,list<Contact>>();
            //Create account for each contact
            for (Contact c : contactsWithEmptyAccounts) {
                if(mapAccountId.get(c.CRM_Company_Name__c) != null){
                    c.accountId = mapAccountId.get(c.CRM_Company_Name__c);
                }
                else{
                    accountName = c.CRM_Company_Name__c;
                    if(contactsByNameKeys.containsKey(accountName)){
                        contactsByNameKeys.get(accountName).add(c);
                    }
                    else{
                        contactsByNameKeys.put(accountName,new  List <contact> { c });
                    }
                    Account a = new Account(name=accountName,RecordTypeId = getRecTypeId('Account','ADGM Courts'));
                    newAccounts.add(a);
                }
            }
            if(newAccounts.size() > 0)
                insert newAccounts;

            for (Account a : newAccounts) {
                //Put account ids on contacts
                for(Contact c : contactsByNameKeys.get(accountName)){
                    c.accountId = a.Id;
                }
            }
        }
    }
    @future 
    static void AssignPermissionSetToUsers(list<Id> usersId) {
        System.debug('usersId'+usersId);
        list<PermissionSetAssignment> lstPSA = new list<PermissionSetAssignment>();
        map<string,string> MapPermissionSets = new map<string,string>();
        for(PermissionSet PS:[SELECT Id,Label,Name,License.Name FROM PermissionSet where License.Name='Customer Community Login']){
            if(PS.Label.StartsWith('00e')==false)
                MapPermissionSets.put(PS.Label,PS.Id);
        }
        System.debug('>>>>>>>>>>>>>>>>>MapPermissionSets');
        System.debug(MapPermissionSets);
        for(User usr:[Select Id,Types_of_Services_Accessible__c from User where Id IN:usersId and contact.Is_Guest_User__c = false]){
            System.debug('usr.Types_of_Services_Accessible__c'+usr.Types_of_Services_Accessible__c);
            if(usr.Types_of_Services_Accessible__c!=null){
                for(string PermissionSetName : MapPermissionSets.keyset()){
                    if(usr.Types_of_Services_Accessible__c.indexOf(PermissionSetName)>-1){
                        PermissionSetAssignment PSA = new PermissionSetAssignment(PermissionSetId=MapPermissionSets.get(PermissionSetName),AssigneeId=usr.Id);
                        lstPSA.add(PSA);
                    }
                }
            }
        }
        if(lstPSA.size()>0){
            upsert lstPSA;
        }
    }

    //V1.2: Method to translate fields
    // Note: Please make the batch size to 10 while inserting the contacts for translation in bulk.
    @future (callout = true)
    public static void translateField(Set<Id> ids, String protocolRecordTypeId){
        map<string,string> mapTranslateAPIValue = new map<string,string>();
        Http http1=new Http();
        HttpRequest req1=new HttpRequest();
        string queryParam = '';
        ApexCodeUtility.ContactTriggerRecursive = true;
        list<Contact> lstContactToUpdate = new list<Contact>();
        for(Contact c : [select id,recordtypeid,FirstName,LastName, Middle_Name__c from Contact where id in :ids and recordtypeid = :protocolRecordTypeId]){
            mapTranslateAPIValue = new map<string,string>();
            list<string> lstFields = new list<string>();
            integer i = 0;
            if(String.IsNotEmpty(c.FirstName)){
                queryParam += 'q='+c.FirstName + '&';
                lstFields.add('FirstName');
            }
            if(String.IsNotEmpty(c.LastName)){
                queryParam += 'q='+c.LastName + '&';
                lstFields.add('LastName');
            }
            if(String.IsNotEmpty(c.Middle_Name__c)){
                queryParam += 'q='+c.Middle_Name__c + '&';
                lstFields.add('Middle_Name__c');
            }
            string url = 'https://www.googleapis.com/language/translate/v2/?key='+Label.Google_API+'&source=en&target=ar&'+queryParam;
            req1.setendpoint(url);
            req1.setmethod('GET'); 
            HttpResponse res1;
            res1 = http1.send(req1);
            String str=res1.getbody();
            System.debug('str>>'+str);
            if(str != null && String.IsNotEmpty(str)){
                for(TranslateAPI.Translations transactiontmp : TranslateAPI.parse(str).Data.translations){
                    mapTranslateAPIValue.put(lstFields[i],transactiontmp.translatedText);
                    i++;
                }
            }
            for(LEX_MapTranslateField__c contactSettingObj : LEX_MapTranslateField__c.getAll().values()) {
                c.put(contactSettingObj.Destination__c,mapTranslateAPIValue.get(contactSettingObj.Source__c));
            }
            lstContactToUpdate.add(c);
        }
        try{
            if(lstContactToUpdate != null && lstContactToUpdate.size() > 0)
                update lstContactToUpdate;
        } catch (Exception e){
            
        }
    }
    
    /*
    Method Name : populateEncryptedValue
    Description : Store Encrypted_ID in field
    */
    public static void populateEncryptedValue () {
        Map<Id, Contact> mapNewContacts = new Map<Id, Contact>();
        mapNewContacts = (Map<Id, Contact>) Trigger.NewMap;
        List<Contact> listContact = new List<Contact>();
        for(Contact objContact : [SELECT ID,CRM_Encrypted_ID__c  FROM Contact WHERE id IN:mapNewContacts.keySet()]) {
            if(objContact.id <> null ) {
                objContact.CRM_Encrypted_ID__c = ApexCodeUtility.getEncryptedValueURL(objContact.id);
                listContact.add(objContact);
            }
            
        }
        if(listContact<> null && listContact.size() > 0) {
            try{
                update listContact;
            }catch(Exception e){
                ((List<Contact>) Trigger.New)[0].addError(e.getMessage()+'');
            }
        }
    }
    
    /*
    Method Name : addExternalMember
    Description : Used to add contact in campaign (Protocol Campaign)
    */
    public static void addExternalMember () {
        List<CampaignMember> listCampMemberToInsert = new List<CampaignMember>();
        for(Contact objContact : (List<Contact>)Trigger.New) {
            if(objContact.CRM_Current_Campaign__c <> null && objContact.Id <> null) {
                listCampMemberToInsert.add(new CampaignMember(campaignId = objContact.CRM_Current_Campaign__c, contactid= objContact.Id,CRM_I_Agree__c =objContact.CRM_I_Agree__c ,CRM_Disclaimer__c=objContact.CRM_Disclaimer__c));
            }
        }
        
        if(listCampMemberToInsert <> null && listCampMemberToInsert.size() > 0) {
            try{
                insert listCampMemberToInsert;
            }catch(Exception e){
                ((List<Contact>) Trigger.New)[0].addError(e.getMessage()+'');
            }
        }
    }
    
    /*
    Method Name : mergeContactPhoneFields
    Description : Used to merge country code in phone field.
    */
    public static void mergeContactPhoneFields (List<Contact> listContact) {        
        for(Contact objContact : listContact) {  
            //Do not merge if contact is from FSRA Connect
            if(objContact.From_FSRA__c == true){
                objContact.Phone = ''+objContact.MobilePhone;
                objContact.Alternative_Contact_Phone_Number__c = ''+objContact.Alternative_Phone_Number_1__c;                
            }
            else{                
                objContact.Phone = objContact.CRM_Mobile_Country_Code__c + objContact.MobilePhone;
                objContact.Alternative_Contact_Phone_Number__c = objContact.CRM_Alt_Ph_Num_Country_Code__c +objContact.Alternative_Phone_Number_1__c;
            }            
        }
    }
    
    /*
    Method Name : changeProtocolEmail
    Description : Used to by pass sharing rule for protocol if alternet email is been added with ('+1@' in email)
    */
    public static void changeProtocolEmail (List<Contact> listContacts) {
        
        for(Contact objContact: listContacts) {
            String oldEmail = objContact.Email;
            if(String.isNotBlank(objContact.Email) ) {
                objContact.Email = objContact.Email.replaceAll('\\+([0-9]*)@','@');  
                if(objContact.Email <> oldEmail) {
                    objContact.CRM_By_Pass_Duplicate_Rule__c = true;
                }else {
                    objContact.CRM_By_Pass_Duplicate_Rule__c = false;
                }
            } 
        }
    }
    
    public static string getContactRecTypeId(String recordTypeLabel){
        string recid = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();        
        return recid;
    }
    
    
    
   
}