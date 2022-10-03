/*********************LeadTriggerHandler********************/
/***
***Author:  Rajil
***Date:    09-Jul-2018
***Purpose: TriggerHandler used for Lead Object
-----------------------------------------------------------------
     * @Change History
     *
     * CRM Support        12/04-2020    Added functionality to auto format the Phone number field for consistancy
     *                                  Add functionality to post on chatter when the Primary LEad Contact is changed for the Lead Entity
     *                                  When event is related with th eLead record, The primary contact will automatically create Related Event
     *                                  During conversion process, all the Related Event records are reparented to the related case record.
     
     * Azmath           29-04-2020  Moved the automation logic from process builder to Triggers as the triggers and PB together conflicting the exectuion process.
     * Shagufta         20-05-2021  Migrate custom notes created for lead to entity on lead conversion
     * Prachi           19-09-2021  Mapped Main sector to FSRA Sector field for FSRA Lead -- COMMENTED ON 6th Jan 2022
     * Prachi           15-11-2021  Added without sharing in the class
***/
public without sharing class LeadTriggerHandler{
    public static Map<String,Id> mapofLeadRecordTypeNameandId = new Map<String,Id>();
    //Execute_BI: Execute Before Insert
    public static void Execute_BI(list<Lead> leads)
    {
        //CRM Support
        //This method will be formatting the Phone and MobilePhone standard fields
        formatPhoneNumber(leads);
        set<string> companies = new set<string>();
        Map<string,set<string>> leadEntityWithContacts = new Map<string,set<string>>();
        map<string,string> leadEntitieswithIds = new map<string,string>();
        for(Lead l :leads)
        {
            l.Sys_record_Type_Name__c = l.Record_Type_Name__c; //Assign the record type name for the field "Sys_record_Type_Name__c"
           
            if(l.Record_Type_Name__c == 'Lead_Entity' && l.Data_Source__c == 'Scan'){
                companies.add(l.company);
            }
        }
       
       
        if(!companies.isEmpty())
        {
            for(Lead l :[Select id, FirstName, LastName, company, Email, Record_Type_Name__c FROM Lead where Company IN:companies])
            {
                if(l.Record_Type_Name__c == 'Lead_Entity')
                    leadEntitieswithIds.put(l.company,l.id);
                   
                if(leadEntityWithContacts.containsKey(l.company)){
                    leadEntityWithContacts.get(l.company).add(l.email);
                }else if(l.email != null){
                    leadEntityWithContacts.put(l.company,new set<string>{l.email});
                }
            }
            system.debug('*************'+leadEntitieswithIds);
            if(!leadEntityWithContacts.isEmpty())
            {
                for(Lead le : leads)
                {
                    if(leadEntityWithContacts.containsKey(le.company)){
                        set<string> emailslist = leadEntityWithContacts.get(le.company);
                        if(emailslist.contains(le.email)){
                            le.addError('Contact already exists in the system.');
                        }
                        else{
                            le.Related_Lead_Entity__c = leadEntitieswithIds.get(le.company);
                            le.RecordTypeId = system.label.Lead_Contact;
                        }
                    }
                }
            }
        }

        //mapFSRASector(leads, null);
    }
    //Execute_AI: Execute After Insert
    public static void Execute_AI(list<Lead> leads){
       
        mapofLeadRecordTypeNameandId = ApexCodeUtility.getRecTypeDetails('Lead');
        LeadTriggerHandler.createPrimaryLeadContacts(leads);
       
        //Moving process builder logic to trigger..
        if(LeadTriggerHelper.isFirstTime){
            system.debug('==process builder logic executed here..'+LeadTriggerHelper.isFirstTime);
            LeadTriggerHelper.isFirstTime = false;
            LeadTriggerHelper.updateLeadEntityPrimaryContactInfo(leads,null);
        }
    }
    //Execute_BU: Execute Before Update
    public static void Execute_BU(list<Lead> leads,map<Id,Lead> TriggerOldMap){
        //CRM Support
        //This method will be formatting the Phone and MobilePhone standard fields
        formatPhoneNumber(leads);
        //mapFSRASector(leads, TriggerOldMap);
        for(Lead lead : leads)
        {
            if(lead.Record_Type_Name__c == 'Lead_Entity' && lead.MobilePhone != null )
                lead.Primary_Phone_Number_1__c = lead.MobilePhone;
               
            if(lead.Data_Source__c == 'Scan' ){
                lead.Data_Source__c = null;
            }
            system.debug('123triggd'+lead.Status);
            system.debug('l123 triggd'+ TriggerOldMap.get(lead.Id).status);
            if(lead.Status!= TriggerOldMap.get(lead.Id).status){
                if(lead.Status=='Evaluating' && lead.Evaluating_Date__c==null){
                    lead.Evaluating_Date__c = system.today();
                }
                if(lead.Status=='First contact' && lead.First_Contact_Date__c==null){
                    lead.First_Contact_Date__c = system.today();
                }
                if(lead.Status=='Follow up on meetings' && lead.Follow_Up_on_Meeting_Date__c==null){
                    lead.Follow_Up_on_Meeting_Date__c = system.today();
                }
                if(lead.Status=='Firm Interest' && lead.Firm_Interest_Date__c==null){
                    lead.Firm_Interest_Date__c = system.today();
                }
                if(lead.Status=='In application' && lead.In_Application_Date__c==null){
                    lead.In_Application_Date__c = system.today();
                }
                if(lead.Status=='Application submitted' && lead.Application_Submission_Date__c==null){
                    lead.Application_Submission_Date__c = system.today();
                }
                if(lead.Status=='Not Interested' && lead.Not_Interested_Date__c==null){
                    lead.Not_Interested_Date__c = system.today();
                }
            }
        }    
    }

    //Mapped Main sector to FSRA Sector field for FSRA Lead
    /*public static void mapFSRASector(list<Lead> leads,map<Id,Lead> TriggerOldMap){
        List<Lead> leadRecordsToProcess = new List<Lead>();
        for(Lead lead : leads){
            if(lead.From_FSRA__c == true && (TriggerOldMap == null || (TriggerOldMap != null && TriggerOldMap.get(lead.Id).Main_Sector__c != lead.Main_Sector__c))){
                leadRecordsToProcess.add(lead);
            }
        }
        for(Lead lead : leadRecordsToProcess){
            lead.FSRA_Sector__c = lead.Main_Sector__c;
            lead.Main_Sector__c = null;
        }
    }*/

    public static string getLeadRecTypeId(String recordTypeLabel){
        string recid = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();        
        return recid;
    }
    public static void Execute_AU(list<Lead> newLead,map<Id,Lead> TriggerOldMap){

        /* The below method definition creates the roles for the leadcontacts */
        map<string, Lead> mapConvertedLeadInfo = new map<string, Lead>();
        map<string, Lead> mapRelatedLeadInfo = new map<string, Lead>();
        list<Role__c> lstRoles = new list<Role__c>(); //list of roles for the related contacts.
        list<Database.LeadConvert> lstRelatedLeadconvert = new list<Database.LeadConvert>();
        map<string,string> mapLeadWithParentEntity = new map<string,string>();
        list<lead> lstPrimaryLead = new list<lead>();
        for(Lead Lead: newLead){
            if(Lead.isConverted && TriggerOldMap.get(Lead.Id).isConverted!=Lead.isConverted){ //Get the converted leads to the map.
                mapConvertedLeadInfo.put(Lead.id, Lead);
                //Adding the roles for the converted leads.
                Role__c role = new Role__c();
                role.Object_Contact__c = Lead.ConvertedContactId;
                role.Subject_Account__c = Lead.ConvertedAccountId;
                role.Type__c = Lead.Role__c;
                role.Title__c = Lead.Salutation;
                role.Forenames__c = Lead.FirstName;
                role.Surname__c = Lead.LastName;
                lstRoles.add(role);
                if(String.IsNotEmpty(Lead.Parent_Entity__c))
                    mapLeadWithParentEntity.put(Lead.ConvertedAccountId,Lead.Parent_Entity__c);
            }
        }
       
        // Migrate notes created for lead to entity - Shagufta 06/05/2021  
        List<Note__c> lstNote = new List<Note__c>();            
        lstNote = [SELECT id, title__c, Lead__c, Private__c, Lead_Owner_Email__c, Notes__c, Owner_Role__c, Notes_Rich__c, Share_Note_With__c, Share_Note_With_Sys__c, Share_with_Team__c, createdById from note__c where Lead__c IN : mapConvertedLeadInfo.keySet()];  
        List<Note__c> lstNoteToMigrate = new List<Note__c>();    
           
        for( Note__c note: lstNote ){                
           Id opppty_Id= mapConvertedLeadInfo.get(note.Lead__c).ConvertedOpportunityId;
           note.Account__c = mapConvertedLeadInfo.get(note.Lead__c).ConvertedAccountId;
           note.Lead__c = null;
           lstNoteToMigrate.add(note);           
           /* if(opppty_Id !=null){
                Note__c noteObj = note.clone();                
                noteObj.Account__c =null;
                noteObj.Opportunity__c = opppty_Id;
                lstNoteToMigrate.add(noteObj);
            }*/          
        }  
        upsert lstNoteToMigrate;
        system.debug('lstNoteToMigrate'+lstNoteToMigrate);    
        // END -Migrate notes created for lead to entity - Shagufta 06/05/2021
       
        System.debug('mapConvertedLeadInfo:' + mapConvertedLeadInfo);
         //Consider only the converted leads.
        if(!ApexCodeUtility.LeadTriggerRecursive && mapConvertedLeadInfo != null && !mapConvertedLeadInfo.isEmpty()){
            ApexCodeUtility.LeadTriggerRecursive = true;
            LeadStatus leadStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true Limit 1];
            for(Lead relatedLead: [select id, Related_Lead_Entity__r.ConvertedAccountId, Role__c,Passport__c,Nationality__c,Salutation,FirstName,LastName,Primary__c,isConverted from Lead where Related_Lead_Entity__c in: mapConvertedLeadInfo.KeySet()
                    and Status not in('Invalid', 'Duplicate') and isConverted = false]){
                //Converting the lead contacts for the corresponding leads.
                if(relatedLead.Primary__c == false ){
                    mapRelatedLeadInfo.put(relatedLead.id, relatedLead);
                    Database.LeadConvert Leadconvert = new Database.LeadConvert();
                    Leadconvert.setLeadId(relatedLead.id);
                    Leadconvert.setAccountId(relatedLead.Related_Lead_Entity__r.ConvertedAccountId); //Associate the account id for the to-be converted leads.            
                    Leadconvert.setConvertedStatus(leadStatus.MasterLabel);
                    Leadconvert.setDoNotCreateOpportunity(TRUE);
                    lstRelatedLeadconvert.add(Leadconvert);
                }
                else
                    lstPrimaryLead.add(relatedLead);
            }
            //CRM Support
            map<ID,ID> convertedLeadToContactID = new Map<ID,ID>();
           
            if(!lstRelatedLeadconvert.isEmpty()){ //Converting the related leads.
                list<Database.LeadConvertResult> leadConvertResult = Database.convertLead(lstRelatedLeadconvert);
                for(Database.LeadConvertResult lcr: leadConvertResult){
                    if(lcr.isSuccess()){
                        convertedLeadToContactID.put(lcr.getLeadId(),lcr.getContactId());
                        //Adding the roles for the converted leads.
                        Role__c role = new Role__c();
                        role.Object_Contact__c = lcr.getContactId();
                        role.Subject_Account__c = lcr.getAccountId();
                        //Lead leadObj = new Lead();
                        //leadObj = mapRelatedLeadInfo.get(lcr.getLeadId()).Role__c;
                        if(mapRelatedLeadInfo.get(lcr.getLeadId()) != null && mapRelatedLeadInfo.containsKey(lcr.getLeadId())){
                            role.Type__c = mapRelatedLeadInfo.get(lcr.getLeadId()).Role__c;
                            role.Title__c = mapRelatedLeadInfo.get(lcr.getLeadId()).Salutation;
                            role.Forenames__c = mapRelatedLeadInfo.get(lcr.getLeadId()).FirstName;
                            role.Surname__c = mapRelatedLeadInfo.get(lcr.getLeadId()).LastName;
                        }
                        lstRoles.add(role);
                    }
                }
            }
            if(lstRoles.size()> 0)
                upsert lstRoles; //inserting the roles for lead contacts
           
            //CRM Support
            //Reparent all the Events from the converted  lead to new Contact record for tracking
            list<Related_Event__c> listOFEventsToUpdate = [select ID,Lead_Contact__c from Related_Event__c where Lead_Contact__c in :convertedLeadToContactID.Keyset()];
            for(Related_Event__c relEvent : listOFEventsToUpdate){
                    relEvent.Contact__c=convertedLeadToContactID.get(relEvent.Lead_Contact__c);
            }
            if(!listOFEventsToUpdate.isEmpty()){
                update listOFEventsToUpdate;
            }
            list<Lead_Source__c> lstLeadSource = new list<Lead_Source__c>();
            for(Lead_Source__c leadSource : [select Entity__c,Referrer_Lead_Entity__c from Lead_Source__c where Referrer_Lead_Entity__c in :mapConvertedLeadInfo.keySet()]){
                System.debug('convertedActId'+mapConvertedLeadInfo.get(leadSource.Referrer_Lead_Entity__c).ConvertedAccountId);
                leadSource.Entity__c = mapConvertedLeadInfo.get(leadSource.Referrer_Lead_Entity__c).ConvertedAccountId;
                leadSource.Referrer_Lead_Entity__c = null;
                lstLeadSource.add(leadSource);
            }
            upsert lstLeadSource;
           
            //Associating the Lead Note with the Opportunity for the converted leads.
            list<Note__c> lstLeadNotes = new list<Note__c>();
            for(Note__c leadNote : [select Lead__c from Note__c where Lead__c in :mapConvertedLeadInfo.keySet()]){
                leadNote.Opportunity__c = mapConvertedLeadInfo.get(leadNote.Lead__c).ConvertedOpportunityId;
                lstLeadNotes.add(leadNote);
            }
            upsert lstLeadNotes;

            //Populating the Entity Parent with the Parent Lead Entity Value
            list<Account> lstEntity = new list<Account>();
            if(mapLeadWithParentEntity != null){
                for(Account entity: [select id,ParentId from Account where id in :mapLeadWithParentEntity.keySet()]){
                    entity.ParentId = mapLeadWithParentEntity.get(entity.id);
                    lstEntity.add(entity);
                }
                if(lstEntity.size() > 0)
                    upsert lstEntity;
            }

            //Delete the Primary Lead Contact since it is already captured in the Lead Entity.
            delete lstPrimaryLead;
        }
        LeadTriggerHandler.validatePrimaryLeadContact(newLead);
       
        //Moved Process builder logic to trigger..
        if(LeadTriggerHelper.isFirstTime){
            system.debug('==process builder logic executed here..'+LeadTriggerHelper.isFirstTime);
            LeadTriggerHelper.isFirstTime = false;
            LeadTriggerHelper.updatePrimaryLeadContactinfo(newLead,TriggerOldMap);
            LeadTriggerHelper.updateLeadEntityPrimaryContactInfo(newLead,TriggerOldMap);
        }
    }
    //Validation to select atleast one lead contact as Primary.
    public static void validatePrimaryLeadContact(list<lead> lstleads){
        map<id,id> mapPrimaryLeadContactMap = new map<id,id>();
        set<id> relatedLeadEntity = new set<id>();
        for(lead objLead : lstleads){
            relatedLeadEntity.add(objLead.Related_Lead_Entity__c);
        }
        for(lead lead : [select id,Primary_Lead_Contact__c from lead where id in :relatedLeadEntity]){
            mapPrimaryLeadContactMap.put(lead.id,lead.Primary_Lead_Contact__c);
        }
        for(lead objLead : lstleads){
            if(mapPrimaryLeadContactMap.get(objLead.Related_Lead_Entity__c) != null
                && mapPrimaryLeadContactMap.get(objLead.Related_Lead_Entity__c) == objLead.id
                && objLead.Primary__c == false){
                    lstleads[0].addError('Please select atleast one lead contact as Primary.');
                    break;
            }
           
        }
    }
    //Creates Primary lead contacts whenever a leadEntity is created.
    //Lead Mapping settings retrieved from Map_PrimaryContact_Setting__c custom settings.
    public static void createPrimaryLeadContacts(list<lead> leads){
        List<lead> lstPrimaryLead = new List<lead>();
        //CRM Support
        map<ID,ID> parentLeadToEventMap= new map<ID,ID>();
        for(Lead lead : leads){
            if(mapofLeadRecordTypeNameandId <> null && mapofLeadRecordTypeNameandId.values().size() > 0
               && mapofLeadRecordTypeNameandId.containsKey('Lead Contact') && mapofLeadRecordTypeNameandId.containsKey('Lead Entity')
               && lead.RecordTypeId == mapofLeadRecordTypeNameandId.get('Lead Entity')){
                   Lead leadContact = new Lead();
                   leadContact.RecordTypeId = mapofLeadRecordTypeNameandId.get('Lead Contact');
                   leadContact.Sys_record_Type_Name__c = 'Lead_Contact';
                   leadContact.Primary__c = true;
                   leadContact.Data_Source__c = lead.Data_Source__c;
                   
                   for(Map_PrimaryContact_Setting__c contactSettingObj : Map_PrimaryContact_Setting__c.getAll().values()) {
                       leadContact.put(contactSettingObj.TargetObjectField__c,lead.get(contactSettingObj.SourceFieldName__c));
                   }
                   lstPrimaryLead.add(leadContact);
                   if(lead.Event_Name_Lookup__c!=null){
                       parentLeadToEventMap.put(lead.ID,lead.Event_Name_Lookup__c);
                   }
                   //Set the FROM FSRA checkbox to true for Lead Contact if Lead entity has From FSRA set to true
                   if(lead.From_FSRA__c == true){
                        leadContact.From_FSRA__c = true;
                   }
               }
        }
        if(lstPrimaryLead.size() > 0)
        {
            try{
                insert lstPrimaryLead;
                //CRM Support
                createLeadEventRelationship(lstPrimaryLead,parentLeadToEventMap);
            }
            catch(Exception ex){
                //The below code is added to rephrase the error message whenever a duplicate is found for a lead.
                String exceptionMsg = ex.getMessage();
                System.debug('exceptionMsg'+exceptionMsg);
                if(exceptionMsg.indexOf('DUPLICATES_DETECTED')> -1)
                    leads[0].addError('DUPLICATES_DETECTED');
            }
        }
    }
   
    /**
    * primaryContactUpdateNotification
    *
    * This method was introduced in CRM Support
    * This method is called directly from After Insert and Update events.
    * Whenever the primary contact is updated for the LEad- Contact record type, chatter post is created as notification on lead record
    *    
    *
    * @param  newLeads    List of new Lead Records        
    * @param  oldLeadMap     old lead record used to compare the record with new instance
    * @return void
    */
    public static void primaryContactUpdateNotification(list<Lead> newLeads,map<id,Lead> oldLeadMap){
        if(mapofLeadRecordTypeNameandId.isEmpty()){
            mapofLeadRecordTypeNameandId = ApexCodeUtility.getRecTypeDetails('Lead');
        }
        list<FeedItem> feedItemsTOInsert = new list<FeedItem>();
        for(Lead tempL: newLeads){
            if(mapofLeadRecordTypeNameandId.containsKey('Lead Contact') && tempL.RecordTypeID==mapofLeadRecordTypeNameandId.get('Lead Contact') &&
               tempL.Primary__c && tempL.Related_Lead_Entity__c!=null && (oldLeadMap==null || tempL.Primary__c!= oldLeadMap.get(tempL.Id).Primary__c)){
                   feedItemsTOInsert.add(new FeedItem(ParentId=tempL.Related_Lead_Entity__c,
                                        Body='Primary Contact for lead is '+tempL.FirstName+' '+tempL.Lastname));
               }
        }
        if(!feedItemsTOInsert.isEmpty()){
            database.insert(feedItemsTOInsert,false);
        }
    }
   
    /**
    * createLeadEventRelationship
    *
    * This method was introduced in CRM Support
    * This method is called on when primary contact is auto created from the lead record.
    * Whenever the primary contact is auto created, If the lead has relationship with the event, The Primary lead contact will be related to event
    *    
    *
    * @param  leadRecords    List of new Lead Records        
    * @param  leadRecords    List of new Lead Records        
    * @return void
    */
    public static void createLeadEventRelationship(list<Lead> leads, map<ID,ID> parentLeadToEventMap){
        list<Related_Event__c> eventsToInsert = new list<Related_Event__c>();
        for(lead tmpLead: leads){
            if( parentLeadToEventMap.containsKey(tmpLead.Related_Lead_Entity__c)){
                eventsToInsert.add(new Related_Event__c(Event__c=parentLeadToEventMap.get(tmpLead.Related_Lead_Entity__c),
                                            Lead_Contact__c=tmpLead.Id));
            }
        }
        if(!eventsToInsert.isEmpty()){
            insert eventsToInsert;
        }
    }
    /**
    * formatPhoneNumber
    *
    * This method was introduced in CRm Support
    * This method is called from Before Insert and befor update calls
    * Thi smethod will format the Phone number and MobilePhone field based on below mentioned logic.
    * If the MobilePhone field is not populated it will auto populat ethe field
    * Rules:  1. Remove (0)
    *         2. Remove all -(dash),.(dot), (space)
    *         3. replace string starting with 00 to +
    *
    * @param  leadRecords    List of new LEad Records        
    * @return void
    */
    public static void formatPhoneNumber(list<Lead> leadRecords){
        //t.replaceAll('[^0-9]','');
        for(Lead tLead : leadRecords){
            if(tLead.MobilePhone!=null){
                tLead.MobilePhone=formatPhoneNumberHelper(tLead.MobilePhone);
            }
            if(tLead.Phone!=null){
                tLead.Phone=formatPhoneNumberHelper(tLead.Phone);
                if(tLead.MobilePhone==null){tLead.MobilePhone=tLead.Phone;}
            }
        }
    }
    public static String formatPhoneNumberHelper(String phoneNmber){
        String valueToReturn='';
        phoneNmber=phoneNmber.replaceAll('\\(0\\)','');
        if(phoneNmber.startsWith('00')){
            phoneNmber=phoneNmber.replaceFirst('00','+');
        }
        if(phoneNmber.startsWith('+')){
            valueToReturn='+';
        }
        return valueToReturn+phoneNmber.replaceAll('[^0-9]','');
    }
   
}