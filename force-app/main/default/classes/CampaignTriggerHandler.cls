/*
    Author      :   Yogesh Mahajan 
    Class Name  :   CampaignTriggerHandler
    Description :   It is used as a campaign trigger handler
    Date        :   03/06/2019     
--------------------------------------------------------------------------------------
     * @Change History
     * Author       	Date            Description
	Yogesh Mahajan		15/05/2019		Campaign Id Encryption in field
	Yogesh Mahajan		06/01/2020		Non - Protocol record owner mapping 

*/
public without sharing class CampaignTriggerHandler{
    // Constants
    private static final String ERROR_MSG = 'Please add documents before closing the campaign.';
    private static final String COMPLETED_STATUS = 'Completed';
    private static final String IN_PROGRESS_STATUS = 'In Progress'; 
    private static final String PROTOCOL_SETUP = 'Protocol';
    private static final String GS_SETUP = 'GS';
    private static final String CORP_SETUP = 'Corp';
    private static final String PROTOCOL_PROFILE_NAME = 'CRM Protocol';
     
    public static void Execute_BI(list<Campaign> newCampList){
        updateShareEventWith(newCampList);
        populateCreatedByUserProfile(newCampList);
        updateEventEndDate();
    }
    public static void Execute_AI(list<Campaign> newCampList){
        Id profileId = userinfo.getProfileId();
		String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        createDefaultMemebers();
        createCampaignStatus(newCampList);
        createDyanmicTasks(true, profileName);
        addCampaignMembers(newCampList);
        populateEncryptedValue(); 
    }
    public static void Execute_BU(list<Campaign> TriggerNew,map<Id,Campaign> TriggerOldMap){
        CreateSurveyResponses(TriggerNew,TriggerOldMap);
        updateShareEventWith(TriggerNew);
        shareWithProtocol();
        updateEventEndDate();
        
    }
    
    public static void Execute_AU() {
        Id profileId = userinfo.getProfileId();
		String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        createDyanmicTasks(false, profileName);
        createSetupTasks(profileName);
        addCampaignMembers(Trigger.new);
         
    }
    
    /*
	Method Name : populateEncryptedValue
	Description : Store Encrypted_ID in field
	*/
    public static void populateEncryptedValue () {
        Map<Id, Campaign> mapNewCampaign = new Map<Id, Campaign>();
        mapNewCampaign = (Map<Id, Campaign>) Trigger.NewMap;
        List<Campaign> listCampaign = new List<Campaign>();
        for(Campaign objCampaign : [SELECT ID,CRM_Encrypted_ID__c  FROM Campaign WHERE id IN:mapNewCampaign.keySet()]) {
            if(objCampaign.id <> null) {
                objCampaign.CRM_Encrypted_ID__c = ApexCodeUtility.getEncryptedValueURL(objCampaign.id);
            	listCampaign.add(objCampaign);
            }
            
        }
        if(listCampaign<> null && listCampaign.size() > 0) {
            try {
            	update listCampaign;
            }catch(Exception e){
                ((List<Campaign>) Trigger.New)[0].addError(e.getMessage()+'');
            }
        }
        
    }
    
    /*
        Method Name : updateEventEndDate
        Description : update end date for Lecture and Government event
    */
    public static void updateEventEndDate(){
        for(Campaign objCampaign : (List<Campaign>)Trigger.new ){
            if(objCampaign.Main_Category__c <> null && (objCampaign.Main_Category__c == 'MBZ Majlis Lecture' || objCampaign.Main_Category__c == 'Government Event')
               && objCampaign.CRM_Meeting_Date_Time__c <> null) {
                   objCampaign.CRM_End_Date__c =  datetime.newInstance((objCampaign.CRM_Meeting_Date_Time__c).year(), (objCampaign.CRM_Meeting_Date_Time__c).month(), (objCampaign.CRM_Meeting_Date_Time__c).day()).addHours(18);
               }
            
        }
    }
    
    // Description : Populate multiselect value to text field
    public static void updateShareEventWith(list<Campaign> newCampList){
        for(Campaign camp : newCampList){
            if(camp.CRM_Share_With__c != null){
                camp.CRM_Share_Event_with__c = camp.CRM_Share_With__c;
            }
        }
    }
    
    /*
        Method Name : shareWithProtocol
        Description : populate Created By User Profile name into campaign
    */
    public static void shareWithProtocol(){
        Map<Id, Campaign> mapCampaign = new Map<Id, Campaign>();
        mapCampaign = (Map<Id, Campaign>) Trigger.newMap;
        // get Event Owner Mapping
        Map<String, String> mapEventMapping = new Map<String, string>();
        
        for(CRM_Event_Owner_Mapping__mdt objMapping : [select id, CRM_Email__c, CRM_Event_Category__c from CRM_Event_Owner_Mapping__mdt Limit 1000]) {
            mapEventMapping.put(objMapping.CRM_Event_Category__c, objMapping.CRM_Email__c);
        }//end for
        
        Map<String, Id> mapUserEmailWithId = new Map<String, Id>();
        for(User objUser : [SELECT id, Email FROM User WHERE Email IN: mapEventMapping.values()]) {
            mapUserEmailWithId.put(objUser.Email, objUser.id);
        }
        
        if(mapUserEmailWithId <> null && mapUserEmailWithId.values().size() > 0 && mapEventMapping <> null) {
            for (Campaign objCamp : mapCampaign.values()) {
                
                if(objCamp.CRM_Submit_to_Protocol_Team__c && objCamp.Main_Category__c <> null   && mapUserEmailWithId.get(mapEventMapping.get(objCamp.Main_Category__c)) <> null){
                    objCamp.ownerid = mapUserEmailWithId.get(mapEventMapping.get(objCamp.Main_Category__c));
                    objCamp.Campaign_Responsible__c = mapUserEmailWithId.get(mapEventMapping.get(objCamp.Main_Category__c));
                }

            }
        }
        
       
    }
    /*
        Method Name : populateCreatedByUserProfile
        Description : populate Created By User Profile name into campaign
    */
    public static void populateCreatedByUserProfile(list<Campaign> newCampList){
        Map<Id,User> userMap = new Map<Id,User>([select id,Profile.Name from user where id = : userinfo.getuserId()]);
         Set<String> setProtocolCategory = new Set<String>();
        // get all protocol record types
        
        for(CRM_Protocol_Event_Category__mdt objProtocolEventCategory : [SELECT ID, CRM_Event_Category__c FROM CRM_Protocol_Event_Category__mdt limit 1000]) {
            setProtocolCategory.add(objProtocolEventCategory.CRM_Event_Category__c);
        }//end for

        for(Campaign objCampaign : newCampList){
            objCampaign.CRM_Created_By_User_Profile__c = userMap.get(userinfo.getuserId()).Profile.Name;
            if(setProtocolCategory <> null && objCampaign.Main_Category__c <> null && setProtocolCategory.contains(objCampaign.Main_Category__c) ) {
                objCampaign.IsActive = true;
            }
        }        
    }
    /*
        Method Name : createCampaignStatus
        Description : Create camapign member status 'Draft'
    */
    public static void createCampaignStatus(List<Campaign> newRec){
        List<CampaignMemberStatus> cmsLst = new List<CampaignMemberStatus>();
        for(Campaign camp : newRec){
            CampaignMemberStatus cms = new CampaignMemberStatus(CampaignId=camp.Id, HasResponded=False, Label='Draft', SortOrder=3, IsDefault=true);
            cmsLst.add(cms);
        }
        
        try{
            insert cmsLst;
        }catch(Exception e){
            system.debug(e.getMessage());
        }
    }
    /*
        Method Name : createDefaultMemebers
        Description : Create Default campaign Members if camapaign is related to protocol
    */
    public static void createDefaultMemebers(){
        List<Campaign> listNewCampaign = (List<Campaign>)Trigger.New;
        Set<String> setCategories = new Set<String>();
        // List record type record that we need to skip for processing
        
        for(Campaign objCampaign: listNewCampaign) {
            if(objCampaign.Main_Category__c <> null && objCampaign.Main_Category__c <> '') {
                setCategories.add(objCampaign.Main_Category__c);
            }
        }
        if(setCategories.size() > 0) {
            Map<String, List<Id>> mapOfCatagoryWithContactId = new Map<String, List<Id>>();
            String soqlQuery = '';
            List<String> listFieldAPINames = new List<String>();
            listFieldAPINames.add('Id');
            listFieldAPINames.add('CRM_Campaign_Category__c');
            DynamicSOQLUtility dynamicSOQLUtility = new DynamicSOQLUtility();
            soqlQuery = dynamicSOQLUtility.createSelect(listFieldAPINames , 'Contact');
            soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'CRM_Campaign_Category__c', 'null', '<>');
            soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'Account.Is_ADGM_Company__c', false, '<>', 'AND');
            soqlQuery = dynamicSOQLUtility.addWhereMultiCondition(soqlQuery, 'CRM_Campaign_Category__c', setCategories, 'INCLUDES', 'AND');
            //system.debug('-->'+soqlQuery);
            for(Contact objContact : database.query(soqlQuery)) {
                if(objContact.CRM_Campaign_Category__c <> null ){
                    for(String sCategory : (objContact.CRM_Campaign_Category__c).split(';')) {
                        if(mapOfCatagoryWithContactId.get(sCategory) <> null) {
                            mapOfCatagoryWithContactId.get(sCategory).add(objContact.id);
                        } else {
                            mapOfCatagoryWithContactId.put(sCategory, new List<Id>{objContact.id});     
                        }
                    } 
                }
                
            }
            // Create Campaign Memmber records
            List<CampaignMember> listCampaignMemberToInsert = new List<CampaignMember>();
            for(Campaign objCampaign: listNewCampaign) {
                if(mapOfCatagoryWithContactId.get(objCampaign.Main_Category__c) <> null) {
                    for(Id contactId : mapOfCatagoryWithContactId.get(objCampaign.Main_Category__c)) {
                        listCampaignMemberToInsert.add(new CampaignMember(ContactId = contactId, CampaignId = objCampaign.id));
                    }
                }
            }
            try{
                if(listCampaignMemberToInsert.size() > 0)
                    insert listCampaignMemberToInsert;
            }Catch(Exception e){
                System.debug(e.getMessage());
            }
        }
        
    }
    // get Campaign Record Type Id
    public static string  getCampaignRecTypeId(String recordTypeLabel){
        string recid;
        if(Schema.SObjectType.Campaign.getRecordTypeInfosByName().get(recordTypeLabel) <> null ){
            recid = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();  
        }      
        return recid;
    }
    
    /*
        Method Name : CreateSurveyResponses
        Description : Creates Survey Responses for the Internal Invitees on marking the Campaign as Completed.
    */
    public static void CreateSurveyResponses(list<Campaign> TriggerNew,map<Id,Campaign> TriggerOldMap){
        
        list<string> listEventCategories = new list<string>();
        set<string> setCampaignIds = new set<string>();
        List<CampaignMember> listCampaignMember = new List<CampaignMember>();
        list<CRM_Survey_Question__c> lstSurveyQuestions = new list<CRM_Survey_Question__c>();
        map<string,list<string>> MapInternalInvitees = new map<string,list<string>>();
        for(Campaign cm : TriggerNew){
            if( (cm.Status=='Completed' || cm.Status=='In Progress') && cm.CRM_Start_Feedback_Process__c && (TriggerOldMap.get(cm.Id).CRM_Start_Feedback_Process__c != cm.CRM_Start_Feedback_Process__c || (TriggerOldMap.get(cm.Id).Status <> 'Completed' && TriggerOldMap.get(cm.Id).Status <> 'In Progress')) && cm.Main_Category__c!=null){
                listEventCategories.add(cm.Main_Category__c);
                setCampaignIds.add(cm.Id);
            }
        }
        system.debug('setCampaignIds---->'+setCampaignIds);
        system.debug('listEventCategories--->' + listEventCategories);
        if(listEventCategories.size()>0){
            String soqlQuery = '';
            List<String> listFieldAPINames = new List<String>();
            listFieldAPINames.add('Id');
            listFieldAPINames.add('CRM_Survey_Category__c');
            DynamicSOQLUtility dynamicSOQLUtility = new DynamicSOQLUtility();
            soqlQuery = dynamicSOQLUtility.createSelect(listFieldAPINames , 'CRM_Survey_Question__c');
            soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'CRM_Survey_Category__c', 'null', '<>');
            soqlQuery = dynamicSOQLUtility.addWhereMultiCondition(soqlQuery, 'CRM_Survey_Category__c', new Set<String>(listEventCategories), 'INCLUDES', 'AND');
            system.debug('soqlQuery--->'+soqlQuery);
            for(CRM_Survey_Question__c SQ: database.query(soqlQuery)){
                lstSurveyQuestions.add(SQ);
            }
            
            for(CampaignMember CM:[Select Id,ContactId,CampaignId,CRM_RSVP__c, CRM_Campaign_Status__c, CRM_Send_Feedback_Email__c  from CampaignMember where CampaignId IN:setCampaignIds and CRM_Internal_Invitee__c=true and CRM_RSVP__c = 'Yes']){
                list<string> lstContactIds = new list<string>();
                if(CM.CRM_Send_Feedback_Email__c) {
                    if(MapInternalInvitees.get(CM.CampaignId)!=null)
                        lstContactIds = MapInternalInvitees.get(CM.CampaignId);
                    lstContactIds.add(CM.ContactId);
                    MapInternalInvitees.put(CM.CampaignId,lstContactIds);
                }
                
                if(CM.CRM_Send_Feedback_Email__c)
                    CM.CRM_Campaign_Status__c = 'Completed';
                listCampaignMember.add(CM);
            }
        }
        list<CRM_Survey_Response__c> lstSurveyResponses = new list<CRM_Survey_Response__c>();
        for(Campaign cm : TriggerNew){
            
            if((cm.Status=='Completed' || cm.Status=='In Progress') && cm.CRM_Start_Feedback_Process__c && (TriggerOldMap.get(cm.Id).CRM_Start_Feedback_Process__c != cm.CRM_Start_Feedback_Process__c || (TriggerOldMap.get(cm.Id).Status <> 'Completed' && TriggerOldMap.get(cm.Id).Status <> 'In Progress')) && cm.Main_Category__c!=null && MapInternalInvitees.get(cm.Id) <> null){
                for(string ContactId:MapInternalInvitees.get(cm.Id)){
                    for(CRM_Survey_Question__c Quest:lstSurveyQuestions){
                        if(Quest.CRM_Survey_Category__c!=null && Quest.CRM_Survey_Category__c.indexOf(cm.Main_Category__c)>-1)
                            lstSurveyResponses.add(new CRM_Survey_Response__c(CRM_Campaign__c=cm.Id,CRM_Contact__c=ContactId,CRM_Survey_Question__c=Quest.Id));
                    }
                }
            }
        }
		system.debug('lstSurveyResponses==>>' + lstSurveyResponses);        
        if(listCampaignMember.size() > 0) {
            
            try{
                update listCampaignMember;
            }catch(Exception e){
                TriggerNew[0].addError(e.getMessage()+'');
            }
        }
                    
        
        
        if(lstSurveyResponses.size()>0){
            try{
                insert lstSurveyResponses;
                
                
            }catch(Exception e){
                TriggerNew[0].addError(e.getMessage()+'');
            }
        }

    }
    
    /*
        Method Name : createPlanningTasks
        Description : create planning status task for protocol team.
    */
    public static void createDyanmicTasks(Boolean isInsert, String profileName) {
        Id currentUserId = UserInfo.getUserId();
        List<Task> listTaskToInsert = new List<Task>();
        Map<Id, Campaign> mapCampaign = new Map<Id, Campaign>();
        Map<Id, Campaign> mapOldCampaign = new Map<Id, Campaign>();
        if(!isInsert) {
            mapOldCampaign = (Map<Id, Campaign>) Trigger.oldMap;
        }
        
        mapCampaign = (Map<Id, Campaign>) Trigger.newMap;
        List<Campaign> listCampForTask = new List<Campaign>();
        listCampForTask = ((Map<Id, Campaign>) Trigger.newMap).values();
        
        // get metedata for task
        List<CRM_Protocol_Task_Configuration__mdt> listProtocolTask = new List<CRM_Protocol_Task_Configuration__mdt>([SELECT ID , CRM_Related_Profile__c, CRM_Event_Status__c, CRM_Event_Category__c, CRM_Task_Comment__c, CRM_Task_Due_date__c, CRM_Task_Subject__c, CRM_Active__c, CRM_Action_Related_To__c 
                                                                                                             FROM CRM_Protocol_Task_Configuration__mdt where CRM_Active__c = TRUE AND CRM_Is_Arrange_Setup__c = false ]);
        DateTime dueDate;
        if(listProtocolTask <> null && listCampForTask <> null) {            
            for (Campaign objCampaign: listCampForTask) {
                
                if(isInsert || mapOldCampaign.get(objCampaign.id).status <> objCampaign.status) {
                    for (CRM_Protocol_Task_Configuration__mdt objProtocolTask : listProtocolTask) {
                        if(objCampaign.status == objProtocolTask.CRM_Event_Status__c && objCampaign.Main_Category__c == objProtocolTask.CRM_Event_Category__c &&
                          objProtocolTask.CRM_Related_Profile__c <> null && String.isNotBlank(objProtocolTask.CRM_Related_Profile__c) && objProtocolTask.CRM_Related_Profile__c.contains(profileName)) {
                               Long slaVal;
                               slaVal = Integer.valueOf(objProtocolTask.CRM_Task_Due_date__c)*8*60*60*1000L;
                               dueDate = BusinessHours.add(Label.HexaBPM.Business_Hours_Id,system.now(),slaVal);
                               if(objCampaign.CRM_Meeting_Date_Time__c < dueDate)
                                   dueDate = system.now();
                               listTaskToInsert.add(mappingTaskValues(objCampaign, currentUserId, objProtocolTask.CRM_Task_Subject__c, objProtocolTask.CRM_Task_Comment__c, dueDate, objProtocolTask.CRM_Action_Related_To__c));
                               
                           }//end if
                    }//end for
                }//end if
               
            }//end for
        }//end if      
        if(listTaskToInsert <> null && listTaskToInsert.size() > 0) {
            try{
                insert listTaskToInsert;
            }catch(Exception e){
               listCampForTask[0].addError(e.getMessage()+'');
            }
        }//end if
        
    }//end createPlanningTasks()
    
    public static void createSetupTasks(String profileName) {
        Id currentUserId = UserInfo.getUserId();
        
        // List task to insert
        List<Task> listTaskToInsert = new List<Task>();
        //Old campaign data
        Map<Id, Campaign> mapOldCampaign = new Map<Id, Campaign>();
        mapOldCampaign = (Map<Id, Campaign>) Trigger.oldMap;
        // BusinessHours calculation
        Long slaVal;
        slaVal = 40*60*60*1000L;
        DateTime duedate = BusinessHours.add(Label.HexaBPM.Business_Hours_Id,system.now(),slaVal);
       
        // Map Arrage setup value
        Map<String,Map<String, Set<String>>> mapArrangeSetup = new Map<String,Map<String, Set<String>>>();
        Map<String,Map<String, CRM_Protocol_Task_Configuration__mdt>> mapArrangeSetupRecs = new Map<String,Map<String, CRM_Protocol_Task_Configuration__mdt>>();
        for(CRM_Protocol_Task_Configuration__mdt ptc : [SELECT ID , CRM_Action_Related_To__c, CRM_Arrange_Setup_Type__c, CRM_Event_Category__c, CRM_Related_Profile__c, CRM_Arrange_Setup_values__c, CRM_Active__c,CRM_Task_Comment__c,CRM_Task_Subject__c,CRM_Event_Status__c FROM CRM_Protocol_Task_Configuration__mdt WHERE CRM_Is_Arrange_Setup__c = TRUE AND CRM_Active__c = TRUE]){
            
            if(mapArrangeSetup.containsKey(ptc.CRM_Event_Category__c)){
                if(! mapArrangeSetup.get(ptc.CRM_Event_Category__c).containsKey(ptc.CRM_Arrange_Setup_Type__c)){
                    Map<String, Set<String>> mapAS = new Map<String, Set<String>>();
                    Set<String> setupVals = new Set<String>();
                    if(ptc.CRM_Arrange_Setup_values__c != null){
                        setupVals.addAll(ptc.CRM_Arrange_Setup_values__c.split(';'));
                    }
                    mapArrangeSetup.get(ptc.CRM_Event_Category__c).put(ptc.CRM_Arrange_Setup_Type__c, setupVals);
                }
            } else {
                Map<String, Set<String>> mapAS = new Map<String, Set<String>>();
                Set<String> setupVals = new Set<String>();
                if(ptc.CRM_Arrange_Setup_values__c != null){
                    setupVals.addAll(ptc.CRM_Arrange_Setup_values__c.split(';'));
                }
                mapAS.put(ptc.CRM_Arrange_Setup_Type__c, setupVals);
                mapArrangeSetup.put(ptc.CRM_Event_Category__c, mapAS);
            }

            if(mapArrangeSetupRecs.containsKey(ptc.CRM_Event_Category__c)){
                if(! mapArrangeSetupRecs.get(ptc.CRM_Event_Category__c).containsKey(ptc.CRM_Arrange_Setup_Type__c)){
                    Map<String, CRM_Protocol_Task_Configuration__mdt> mapAS = new Map<String, CRM_Protocol_Task_Configuration__mdt>();
                    mapArrangeSetupRecs.get(ptc.CRM_Event_Category__c).put(ptc.CRM_Arrange_Setup_Type__c, ptc);
                }
            } else {
                Map<String, CRM_Protocol_Task_Configuration__mdt> mapAS = new Map<String, CRM_Protocol_Task_Configuration__mdt>();
                mapAS.put(ptc.CRM_Arrange_Setup_Type__c, ptc);
                mapArrangeSetupRecs.put(ptc.CRM_Event_Category__c, mapAS);
            }
        }
        
        // Check campaign Category
        for (Campaign objCampaign: (List<Campaign>) Trigger.New) {
            if(mapArrangeSetupRecs.containsKey(objCampaign.Main_Category__c) && mapArrangeSetup.containsKey(objCampaign.Main_Category__c) && objCampaign.CRM_Arrange_Setup__c <> null && objCampaign.CRM_Arrange_Setup__c <> '' && objCampaign.Status == IN_PROGRESS_STATUS ) {  
                    if(objCampaign.CRM_Meeting_Date_Time__c < dueDate)
                        dueDate = system.now();
                List<String> setupDetails = new List<String>(); 
                List<String> oldSetupDetails = new List<String> ();
                if(objCampaign.CRM_Arrange_Setup__c <> null && objCampaign.CRM_Arrange_Setup__c <> '') {
                    setupDetails = objCampaign.CRM_Arrange_Setup__c.split(';');
                }
                if( mapOldCampaign.get(objCampaign.id).CRM_Arrange_Setup__c <> null &&  mapOldCampaign.get(objCampaign.id).CRM_Arrange_Setup__c <> '') {    
                    oldSetupDetails = mapOldCampaign.get(objCampaign.id).CRM_Arrange_Setup__c.split(';'); 
                }
                    Map<String,String> aMap = new Map<String,String>();
                    for(String sDetail : setupDetails) {
                        for(String eachKey : mapArrangeSetup.get(objCampaign.Main_Category__c).keyset()){
                            if((mapArrangeSetup.get(objCampaign.Main_Category__c).get(eachKey)).contains(sDetail) && (mapOldCampaign.get(objCampaign.id).status <> objCampaign.Status || !oldSetupDetails.contains(sDetail))) {
                                String sProtocolComments = '';
                                if(aMap.containsKey(eachKey)){
                                    sProtocolComments = aMap.get(eachKey)+ '-' +sDetail +'\n';
                                } else {
                                    sProtocolComments = sProtocolComments+ '-' +sDetail +'\n'; 
                                }   
                                aMap.put(eachKey, sProtocolComments); 
                                
                            }//end if 
                        }
                    }//end for
                    
                    for(String each : aMap.keySet()){
                        if(aMap.get(each) != null && aMap.get(each) != '' && mapArrangeSetupRecs.get(objCampaign.Main_Category__c).containsKey(each)){
                            if(objCampaign.status == mapArrangeSetupRecs.get(objCampaign.Main_Category__c).get(each).CRM_Event_Status__c && 
                              mapArrangeSetupRecs.get(objCampaign.Main_Category__c).get(each).CRM_Related_Profile__c <> null &&
                              String.isNotBlank(mapArrangeSetupRecs.get(objCampaign.Main_Category__c).get(each).CRM_Related_Profile__c)  &&
                              mapArrangeSetupRecs.get(objCampaign.Main_Category__c).get(each).CRM_Related_Profile__c.contains(profileName)
                              ){
                                String body = mapArrangeSetupRecs.get(objCampaign.Main_Category__c).get(each).CRM_Task_Comment__c +'\n'+aMap.get(each);
                                listTaskToInsert.add(mappingTaskValues(objCampaign, currentUserId, mapArrangeSetupRecs.get(objCampaign.Main_Category__c).get(each).CRM_Task_Subject__c, body, duedate, mapArrangeSetupRecs.get(objCampaign.Main_Category__c).get(each).CRM_Action_Related_To__c));
                            }
                        }
                    }      
            }//end if
        }//end for       
        if(listTaskToInsert <> null && listTaskToInsert.size() > 0) {
            try{
                insert listTaskToInsert;
            }catch(Exception e){
                ((List<Campaign>) Trigger.New)[0].addError(e.getMessage()+'');
            }
        }//end if
        
    }
    
   
    /*
        Method Name : mappingTaskValues
        Description : map te task details
    */
    public static Task mappingTaskValues(Campaign objCamp, Id assignToId, String sSubject, String sComments, DateTime dueDate, String relatedTo) {
        Task objTask = new Task();
        objTask.Subject = sSubject;
        objTask.Status = 'Not Started';
        objTask.WhatId = objCamp.id;
        objTask.OwnerId = assignToId;       
        objTask.ActivityDate =  date.newinstance(dueDate.year(), dueDate.month(), dueDate.day());
        objTask.Description = sComments;
        objTask.CRM_Campaign_Name__c = objCamp.Name;
        objTask.CRM_Event_Venue__c = objCamp.CRM_Meeting_Location__c;
        objTask.CRM_Event_Start_Date__c = objCamp.CRM_Meeting_Date_Time__c;
        objTask.CRM_Action_Related_To__c = relatedTo;
        return objTask;
    }// end mappingTaskValues()
    
    
    /*
        Method Name : addCampaignMembers
        Description : adds campaign member based on department field
    */
    public static void addCampaignMembers(List<Campaign> newList){
        Set<String> depts = new Set<String>();
        Map<Id,Set<id>> campaignMemberMap = new Map<Id,Set<id>>();
        for(Campaign cmp : [select id,CRM_Department__c,(select id,contactid from campaignMembers) from Campaign where id in : newList]){
            if(cmp.CRM_Department__c != null){
                depts.addAll(cmp.CRM_Department__c.split(';'));
            }
            Set<Id> cmIds = new Set<Id>();
            for(campaignMember cmpMem : cmp.campaignMembers){
                cmIds.add(cmpMem.contactid);
            }
            campaignMemberMap.put(cmp.id, cmIds);
        }
        List<String> deptsLst = new List<String>();
        deptsLst.addAll(depts);
        String depsString = String.join(deptsLst,'\',\'');
        depsString = '\''+depsString+'\'';
        String queryString = 'select id,CRM_Department__c from contact where CRM_Department__c includes ('+depsString+')';
        
        List<contact> contacts = new List<Contact>();
        if(depts != null && depts.size() > 0){
        	contacts = Database.query(queryString);    
        }
        
        Map<String,Set<Contact>> conMap = new Map<String,Set<Contact>>();
        for(String str : depts){
            for(Contact con : contacts){
                if(con.CRM_Department__c.contains(str)){
                    if(conMap.containsKey(str)){
                        conMap.get(str).add(con);
                    } else {
                        conMap.put(str, new Set<Contact>{con});
                    }
                }
            }
        }

        List<CampaignMember> membersToInsert = new List<CampaignMember>();
        for(Campaign cmp : newList){
            for(String str : depts){
                if(cmp.CRM_Department__c.contains(Str)){
                    if(conMap.containsKey(str)){
                        for(Contact con : conMap.get(str)){
                            if(campaignMemberMap.containsKey(cmp.id)){
                                if(! campaignMemberMap.get(cmp.id).contains(con.Id)){
                                    CampaignMember cMember = new CampaignMember(contactid = con.id,campaignid = cmp.id);
                                    membersToInsert.add(cMember);
                                }
                            }
                        }
                    }
                }
            }
        }

        try{
            insert membersToInsert;
        } catch(Exception e){
            system.debug(e.getMessage());
        }
    }
}