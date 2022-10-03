/*
    Author      :   rajil
    Class Name  :   RecordTypeController
    Description :   It is used as a controller for custom record type Lightning Component
    Date        :   03/10/2019   

    Modified By : Yogesh Mahajan
    Date        : 04/02/2019
    Description : change the campaign record type mapping
*/
public class RecordTypeController {
    public static Map<Id, String> recordtypemap {get;set;}
    
    /*
    Name : fetchEntityRecordTypeValues
    Description : fetch all Entity Record Type Values
    */
   @AuraEnabled        
    public static List<String> fetchEntityRecordTypeValues(){
        User user = new User();
        user = getUserInfo();
        list<string> lstAllowedRecordTypes = new list<string> {'adgm_channel_partner'};
        List<Schema.RecordTypeInfo> recordtypes = Account.SObjectType.getDescribe().getRecordTypeInfos();    
        recordtypemap = new Map<Id, String>();
        for(RecordTypeInfo rt : recordtypes){
            if(rt.isAvailable()) {
                if(user != null && String.isNotBlank(user.Profile.Name) && user.Profile.Name.toLowerCase() == 'crm ra business development')
                {
                    if(rt.getName() != 'Master' && lstAllowedRecordTypes.indexOf(rt.getDeveloperName().toLowerCase()) > -1)
                        recordtypemap.put(rt.getRecordTypeId(), rt.getName());
                }
                else{
                    if(rt.getName() != 'Master')
                        recordtypemap.put(rt.getRecordTypeId(), rt.getName());
                }
            }
        }        
        return recordtypemap.values();
    }
    
    /*
    Name : fetchContactRecordTypeValues
    Description : fetch all Contact Record Type Values
    */
     @AuraEnabled        
    public static List<String> fetchContactRecordTypeValues(){
        List<Schema.RecordTypeInfo> recordtypes = Contact.SObjectType.getDescribe().getRecordTypeInfos();    
        recordtypemap = new Map<Id, String>();
        User user = new User();
        user = getUserInfo();
        list<string> lstAllowedRecordTypes = new list<string> {'contact_adgm_channel_partner'};
        for(RecordTypeInfo rt : recordtypes){
            if(rt.isAvailable()) {
                if(user != null && String.isNotBlank(user.Profile.Name) && user.Profile.Name.toLowerCase() == 'crm ra business development')
                {
                    if(rt.getName() != 'Master' && lstAllowedRecordTypes.indexOf(rt.getDeveloperName().toLowerCase()) > -1)
                        recordtypemap.put(rt.getRecordTypeId(), rt.getName());
                }
                else{
                    if(rt.getName() != 'Master')
                    recordtypemap.put(rt.getRecordTypeId(), rt.getName());
                }
            }
        }        
        return recordtypemap.values();
    }
    
    /*
    Name : fetchCampaignRecordTypeValues
    Description : fetch all Campaign Record Type Values
    */
    
    @AuraEnabled        
    public static RecordInfo fetchCampaignRecordTypeValues(){
        RecordInfo campaignObj = new RecordInfo();
        List<Schema.RecordTypeInfo> recordtypes = Campaign.SObjectType.getDescribe().getRecordTypeInfos();    
        recordtypemap = new Map<Id, String>();
        Map<Id, RecordType> mapCampRecordType = new Map<Id, RecordType>([SELECT Id, Name, Description FROM RecordType WHERE SobjectType = 'Campaign']);
        
        Map<String, String> mapProtocolCategory = new Map<String, string>();
        // get all protocol record types
        
        
        for(CRM_Protocol_Event_Category__mdt objProtocolEventCategory : [SELECT ID, CRM_Event_Category__c, CRM_Record_type_Developer_Name__c, CRM_Type__c FROM CRM_Protocol_Event_Category__mdt]) {
            mapProtocolCategory.put(objProtocolEventCategory.CRM_Record_type_Developer_Name__c, objProtocolEventCategory.CRM_Type__c);
        }//end for
        
        Map<String, List<RecordType>> mapProtocol =new Map<String, List<RecordType>>();
        List<RecordType> listBR_P = new List<RecordType>();
        List<RecordType> listNONBR_P = new List<RecordType>();
        for(RecordTypeInfo rt : recordtypes){
            if(rt.isAvailable()) {
                if(rt.getName() != 'Master' && mapProtocolCategory <> null && mapProtocolCategory.containskey(rt.getDeveloperName())) {
                    if(mapProtocol.get(mapProtocolCategory.get(rt.getDeveloperName())) == null) {
                        mapProtocol.put(mapProtocolCategory.get(rt.getDeveloperName()), new List<RecordType>{});
                    }
                    mapProtocol.get(mapProtocolCategory.get(rt.getDeveloperName())).add(mapCampRecordType.get(rt.getRecordTypeId()));
                } else if(rt.getName() != 'Master'){
                    listNONBR_P.add(mapCampRecordType.get(rt.getRecordTypeId()));
                }
            }
        }     
        campaignObj.mapRecordTypes = new Map<String, List<RecordType>>();
        campaignObj.mapRecordTypes = mapProtocol;
        if(listNONBR_P<> null && listNONBR_P.size() > 0 )
            campaignObj.mapRecordTypes.put('Select a Record Type', listNONBR_P);
        for(Contact contact : [select id from contact where email = :UserInfo.getUserEmail() and Account.Is_ADGM_Company__c = true limit 1])
            campaignObj.contactId = contact.id;
        return campaignObj;
    }
   
    /*
    Name : fetchCaseRecordTypeValues
    Description : fetch all case Record Type Values
    */
     @AuraEnabled        
    public static RecordInfo fetchCaseRecordTypeValues(){
        RecordInfo caseObj = new RecordInfo();
        List<Schema.RecordTypeInfo> recordtypes = Case.SObjectType.getDescribe().getRecordTypeInfos();    
        recordtypemap = new Map<Id, String>();
        for(RecordTypeInfo rt : recordtypes){
            if(rt.isAvailable()) {
                if(rt.getName() != 'Master')
                recordtypemap.put(rt.getRecordTypeId(), rt.getName());
            }
        }
        caseObj.recordType =  recordtypemap;
        caseObj.user = getUserInfo();
        return caseObj;
    }
    /*
    Name : getContactRecTypeId
    Description : get contact Record Type Id
    */
     @AuraEnabled
    public static Id getContactRecTypeId(String recordTypeLabel){
        Id recid = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();        
        return recid;
    }  
    /*
    Name : getEntityRecTypeId
    Description : get contact Record Type Id
    */
    @AuraEnabled
    public static Id getEntityRecTypeId(String recordTypeLabel){
        Id recid = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();        
        return recid;
    }  
    /*
    Name : getUserInfo
    Description : get user info
    */
    @AuraEnabled
    public static User getUserInfo(){
        User user = [select Profile.Name,contactid FROM User Where id =: userInfo.getUserId()];
        return user;
    }
    /*
    Name : getCaseRecTypeId
    Description : get case record type id
    */
      @AuraEnabled
    public static Id getCaseRecTypeId(String recordTypeLabel){
        Id recid = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();        
        return recid;
    }
    public class RecordInfo{
        @AuraEnabled
        public User user {get;set;}
        @AuraEnabled
        public Map<Id, String> recordType {get;set;}
        @AuraEnabled
        public string contactId {get;set;}
        
        @AuraEnabled
        public Map<String, List<RecordType>> mapRecordTypes {get;set;}
    }
    
    /*
    Name : getCaseRecTypeId
    Description : get case record type id
    */
    @AuraEnabled
    public static DelegationInfo getTaskDetails(String tskId){
        List<Task> listTask = [select id,Description,CRM_External_First_Name__c,CRM_External_Middle_Name__c, CRM_External_Last_Name__c, CRM_External_Contact_Id__c, CRM_External_Email__c,CRM_External_Company_Id__c, CRM_External_Mobile__c, CRM_External_Country_Code__c, CRM_External_Job_Title__c, WhatId from Task where id =: tskId];     
        DelegationInfo objDelegationInfo = new DelegationInfo();
        List<Lookup__c> listJobTitle = new List<Lookup__c>([SELECT Id FROM Lookup__c WHERE Name =: Label.CRM_Protocol_Other_Job_Title]);
        if(listTask <> null && listTask.size() > 0 && listTask[0].CRM_External_Contact_Id__c <> null && listTask[0].CRM_External_Contact_Id__c <> '') {
            List<Contact> listContact = [select id, Country__c, State_Province__c,City__c,Street__c,Zip_Postal_Code_PO_Box__c from contact where id=:listTask[0].CRM_External_Contact_Id__c ];
            objDelegationInfo.objTask = listTask[0];
            if(listContact <> null && listContact.size() > 0 ) {
                objDelegationInfo.objContact = listContact[0];
            }
            if(listJobTitle <> null && listJobTitle.size() > 0) {
                objDelegationInfo.objLookup = listJobTitle[0];
            }
            return objDelegationInfo;
        }
            
        return null;
    }
    public class DelegationInfo{ 
        @AuraEnabled
        Lookup__c objLookup {get;set;}
         @AuraEnabled
        Task objTask {get;set;}
         @AuraEnabled
        Contact objContact {get;set;}
    }
}