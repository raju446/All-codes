/*
    Author      : Durga Prasad
    Company     : PwC
    Date        : 26-Nov-2017
    Description : Case Trigger Handler
    -------------------------------------------------------------------------
    --Change History---
     Version: v1.0 : Description :[invokeAssignmentRulesInsert] Assignment rules updated.
     Version: v1.1 : Description :Checks the Ownership change validation - The new owner should belong to the same queue.
     Version: v1.1 : Description :SLA configuration ofr new Business development team. more details @Configure_BD_SLA method
*/
public without sharing class CaseTriggerHandler{
    public static void Execute_BI(list<Case> TriggerNew){
        boolean hasAccess = false;
        Set<id> caseOwnerId = new set<id>();
        for(Case cs:TriggerNew)
        {
            //caseAssignmentRuleOptions.assignmentRuleHeader.useDefaultRule = cs.CRM_Automatic_owner_change__c;
            if(string.valueof(cs.OwnerId).startsWith('00G') && cs.Sys_Case_Queue__c!=null){
                cs.Queue_Name__c = cs.Sys_Case_Queue__c;
            }
            
            //Change in BD cases..
            if(cs.origin == 'BD Email' && !string.valueOf(cs.OwnerId).startsWith('005'))
            {
                string cdesc = cs.Description;
                if(cdesc != null && cdesc != '')
                {
                    string des = cdesc;
                    des = des.substringBetween('Email:','Query:');
                    if(des != null && des != '' && des.contains('@')){
                        des = des.trim();
                        cs.SuppliedEmail = cs.Email_Address__c = des;
                    }
                    
                    string contname = cdesc.substringBetween('Name:','Contact number:');
                    if(contname != null && contname != ''){
                        contname = contname.trim();
                        cs.SuppliedName = cs.CRM_First_Name__c = contname;
                    }
                }
            }
        }
    }
    public static void Execute_AI(list<Case> TriggerNew){
        CaseTriggerHelper.invokeAssignmentRulesInsert(TriggerNew); //v1.0
        Map<Id, Case> mapNewCase = new Map<Id, Case>();
        mapNewCase = (Map<Id, Case>) Trigger.NewMap;
        list<Case> listEncryptCase = new list<case>();
        for(Case objCase : [SELECT ID,CRM_Encrypted_ID__c, origin, contactId FROM Case WHERE id IN:mapNewCase.keySet()]) {
            objCase.CRM_Encrypted_ID__c = ApexCodeUtility.getEncryptedValueURL(objCase.id);
            
            // fix for Issue - Govt Services users are not able to view the Case if the case has the contact (CRM contact) associated to it - Change by Shagufta 12/5/21
            if(objCase.Origin =='Email' && objCase.ContactId!=null ) {
                system.debug('in email to case , contactid ='+objCase.ContactId+ ';  case orgin=='+objCase.Origin); 
                objCase.ContactId = null;
            }
            listEncryptCase.add(objCase);
        }
        if(listEncryptCase<> null && listEncryptCase.size() > 0) {
            update listEncryptCase;
        }
        
        //Create SLA if Case is manually created and do not reassign is checked
        SLA_Configuration__c slaConfig = new SLA_Configuration__c();
        map<string,SLA_Configuration__c> MapSLAMaster = new map<string,SLA_Configuration__c>();
        list<string> lstOriginConfigValues = new list<string>();
        if(SLA_Configuration__c.getAll()!=null){
            for(SLA_Configuration__c SLA:SLA_Configuration__c.getAll().Values()){
                if(string.isNotBlank(SLA.Queue_Name__c) && SLA.Business_Hour_Id__c!=null && SLA.SLA_Minutes__c!=null){
                    if(string.isNotBlank(SLA.Level__c) && string.isNotBlank(SLA.SLA_Type__c) && SLA.SLA_Type__c.toLowerCase() == 'queue & level')
                        MapSLAMaster.put(SLA.Queue_Name__c.toLowerCase() + '_' + SLA.Level__c.toLowerCase(),SLA);
                    else if(string.isNotBlank(SLA.Case_Origin__c))
                    {   //Get the values configured for SLA - Combination will be QueueName and CaseOrigin. 
                        lstOriginConfigValues = SLA.Case_Origin__c.split(','); //Multiple Case Origin is seperated by comma in the custom setting. 
                        for(string slaOrigin : lstOriginConfigValues)
                             MapSLAMaster.put(SLA.Queue_Name__c.toLowerCase() + '_' + slaOrigin.trim().toLowerCase(),SLA);
                    }
                    else
                        MapSLAMaster.put(SLA.Queue_Name__c.toLowerCase(),SLA);
                }
            }
        }
        
        Set<Id> ownerIds = new Set<Id>();
        for(Case objCase : TriggerNew){
            if(objCase.CRM_Bypass_Assignment_Rule__c == true && objCase.Origin == 'Manual' && string.valueOf(objCase.OwnerId).startsWith('005')){
                ownerIds.add(objCase.OwnerId);
            }
        }
        
        system.debug('@@OWNERIDS: '+ownerIds);
        
        Map<Id,Id> ownerQueueMap = new Map<Id,Id>();
        Set<Id> groupIds = new Set<Id>();
        Map<Id,String> queueNameMap = new Map<Id,String>();
        Map<Id,Set<String>> multipleQueuesMap = new Map<Id,Set<String>>();
        if(ownerIds != null && !ownerIds.isEmpty()){
            for(GroupMember grpMem : [SELECT GroupId, UserOrGroupId,Group.Name FROM GroupMember WHERE UserOrGroupId IN :ownerIds AND Group.Type = 'Queue']){
                ownerQueueMap.put(grpMem.UserOrGroupId,grpMem.GroupId);
                groupIds.add(grpMem.GroupId);
                queueNameMap.put(grpMem.GroupId,grpMem.Group.Name);
                
                if(!multipleQueuesMap.containskey(grpMem.UserOrGroupId)){
                    multipleQueuesMap.put(grpMem.UserOrGroupId,new Set<String>{grpMem.Group.Name});
                } else{
                    multipleQueuesMap.get(grpMem.UserOrGroupId).add(grpMem.Group.Name);
                }
            }
        }
        
        system.debug('$$MULTIPLE_QUEUES: '+multipleQueuesMap);
        system.debug('$$QUEUENAMEMAP: '+queueNameMap);
        
        map<string,Case> MapCasesTBU = new map<string,Case>();
        list<Case_SLA__c> lstNewCreatedSLAs = new list<Case_SLA__c>();
        for(Case objCase : TriggerNew){
            if(objCase.CRM_Bypass_Assignment_Rule__c == true && objCase.Origin == 'Manual' && string.valueOf(objCase.OwnerId).startsWith('005')){
                if(ownerQueueMap.containskey(objCase.OwnerId)){
                    Case_SLA__c obj = new Case_SLA__c();
                    obj.Parent__c = objCase.Id;
                    obj.Change_Type__c = 'Owner';
                    obj.From__c = system.now();
                    system.debug('@@QUEUENAME: '+multipleQueuesMap.containskey(objCase.OwnerId));
                    if(multipleQueuesMap.containskey(objCase.OwnerId)){
                        Boolean hasMultipleGrps = false;
                        system.debug('@@QUEUENAME: '+multipleQueuesMap.get(objCase.OwnerId).size());
                        if(multipleQueuesMap.get(objCase.OwnerId).size() > 1){
                            for(String gmName : multipleQueuesMap.get(objCase.OwnerId)){
                                system.debug('@@DEPARTMENT: '+objCase.CRM_Department__c + ' - '+gmName+' - '+(objCase.CRM_Department__c == gmName));
                                if(objCase.CRM_Department__c == gmName){
                                    system.debug('@@DEPARTMENT_SELECTED: '+gmName);
                                    obj.Owner__c = gmName;
                                }
                            }
                            hasMultipleGrps = true;
                        } else{
                            obj.Owner__c = queueNameMap.get(ownerQueueMap.get(objCase.OwnerId));
                        }
                        
                        if(obj.Owner__c == null && hasMultipleGrps == true){
                            for(String gmName : multipleQueuesMap.get(objCase.OwnerId)){
                                system.debug('@@DEPARTMENT: '+objCase.CRM_Sub_Department__c + ' - '+gmName+' - '+(objCase.CRM_Sub_Department__c == gmName));
                                if(objCase.CRM_Sub_Department__c == gmName){
                                    system.debug('@@DEPARTMENT_SELECTED: '+gmName);
                                    obj.Owner__c = gmName;
                                }
                            }
                        }
                    }
                    system.debug('@@OWNER: '+obj.Owner__c);
                    if(queueNameMap.containskey(ownerQueueMap.get(objCase.OwnerId)) && obj.Owner__c == null){
                        obj.Owner__c = queueNameMap.get(ownerQueueMap.get(objCase.OwnerId));
                    }
                    obj.Status__c = objCase.Status;
                    obj.Priority__c = objCase.Priority;
                    
                    if(string.isNotBlank(obj.Owner__c) && obj.Owner__c.toLowerCase() == 'client support centre' && string.isNotBlank(objCase.Priority))
                        slaConfig = MapSLAMaster.get(obj.Owner__c.toLowerCase() + '_' + objCase.Priority.toLowerCase());
                    else if(string.isNotBlank(obj.Owner__c) && string.isNotBlank(objCase.Origin))
                        slaConfig = MapSLAMaster.get(obj.Owner__c.toLowerCase() + '_' + objCase.Origin.toLowerCase());
                    else
                    if(string.isNotBlank(obj.Owner__c))
                        slaConfig = MapSLAMaster.get(obj.Owner__c.toLowerCase());
                    system.debug('slaConfig----->'+slaConfig);
                    if(obj.Owner__c!=null && slaConfig !=null){
                        obj.Business_Hours_Id__c = slaConfig.Business_Hour_Id__c;
                        Long sla = slaConfig.SLA_Minutes__c.longvalue();
                        sla = sla*60*1000L;
                        obj.Due_Date_Time__c = BusinessHours.add(obj.Business_Hours_Id__c,system.now(),sla);
                        lstNewCreatedSLAs.add(obj);
                        Case objCS = new Case(Id=objCase.Id,Due_Date_Time__c = obj.Due_Date_Time__c);
                        MapCasesTBU.put(objCS.Id,objCS);
                    }
                }
            }
        }
        
        if(!lstNewCreatedSLAs.isEmpty()){
            try{
                if(!ApexCodeUtility.CaseTriggerRecursive){
                    ApexCodeUtility.CaseTriggerRecursive = true;
                    Database.UpsertResult[] srList = Database.upsert(lstNewCreatedSLAs, false);
                    if(MapCasesTBU!=null && MapCasesTBU.size()>0)
                        update MapCasesTBU.values();
                }
            }catch(Exception e){
                TriggerNew[0].addError(e.getMessage()+'');
            }
        }
        //Enabling Case module for BD team
        Configure_BD_SLA(TriggerNew, null);
    }
    public static void Execute_BU(list<Case> TriggerNew,map<Id,Case> TriggerOldMap){
        set<string> setAllowQueueToTransfer = new Set<String>{'Client Support Centre', 'Business Operations'};
        list<string> listQueueNames = new list<string>();
        string caseOrigin;
        
        //close case validation
        CaseTriggerHelper.closingCaseValidation(TriggerNew,TriggerOldMap);
        
        for(Case cs:TriggerNew){
                System.debug('Before update' +ApexCodeUtility.CaseOwnerChange);
                if(cs.CRM_Automatic_owner_change__c == true){
                    cs.CRM_Update_counter__c = cs.CRM_Update_counter__c + 1;
                    CaseTriggerHelper.OwnerChangeFromButton=false;
                }
                if(cs.CRM_Update_counter__c >=4)
                    CaseTriggerHelper.OwnerChangeFromButton=true;
                if(cs.Parent_Case__c!=null)
                    cs.ParentId = cs.Parent_Case__c;
                if(cs.OwnerId!=TriggerOldMap.get(cs.Id).OwnerId && string.valueof(cs.OwnerId).startsWith('00G') && cs.Sys_Case_Queue__c!=null)
                    cs.Queue_Name__c = cs.Sys_Case_Queue__c;
                //v1.1:Checks the Ownership change validation - The new owner should belong to the same queue.
                if(String.IsNotBlank(cs.Origin) && cs.Origin.toLowerCase() != 'email' && cs.Origin.toLowerCase() != 'accessadgm portal case' 
                && cs.Origin.toLowerCase() != 'web') // Ignoring the Accessadgm cases - validation not to fire
                {
                    //v1.1:Checks whether the case owner belongs to the same queue.
                    //v1.1:Adding the previous Queue Name to the list -listQueueNames to compare whether the new user belong to same queue.
                    if(ApexCodeUtility.CaseOwnerChange == true && cs.OwnerId!=TriggerOldMap.get(cs.Id).OwnerId 
                        && string.valueOf(cs.OwnerId).startsWith('005') && !setAllowQueueToTransfer.contains(cs.Queue_Name__c)
                            && !setAllowQueueToTransfer.contains(TriggerOldMap.get(cs.Id).Queue_Name__c)){
                        listQueueNames.add(TriggerOldMap.get(cs.Id).Queue_Name__c);
                    }
                    
                    //v1.1:Checking the change in queue - validation 
                    //v1.1: Condition for not changing from one queue to another.
                    if(ApexCodeUtility.CaseOwnerChange == true && cs.Queue_Name__c!=TriggerOldMap.get(cs.Id).Queue_Name__c 
                        && string.valueOf(cs.OwnerId).startsWith('00G') && !setAllowQueueToTransfer.contains(cs.Queue_Name__c)
                            && !setAllowQueueToTransfer.contains(TriggerOldMap.get(cs.Id).Queue_Name__c) 
                            && String.IsNotEmpty(TriggerOldMap.get(cs.Id).Queue_Name__c )){
                /* >>START 10152019 -- Commented out to allow reassignment */
                                //cs.addError('Owner should belong to '+TriggerOldMap.get(cs.Id).Queue_Name__c);
                /* >>END 10152019 -- Commented out to allow reassignment */
                    }
                }
                
                
                if((cs.CRM_Case_Original_Owner_Id__c == null || cs.CRM_Case_Original_Owner_Id__c == '') && (cs.OwnerId != TriggerOldMap.get(cs.Id).OwnerId || TriggerOldMap.get(cs.Id).CRM_Bypass_Assignment_Rule__c == true)){
                    cs.CRM_Case_Original_Owner_Id__c = TriggerOldMap.get(cs.Id).OwnerId;
                }
                
                /*if(cs.OwnerId != TriggerOldMap.get(cs.Id).OwnerId && cs.CRM_Case_First_Owner__c == null && string.valueof(TriggerOldMap.get(cs.Id).OwnerId).startsWith('005') && 
                    cs.CRM_Case_Original_Owner_Id__c != TriggerOldMap.get(cs.Id).OwnerId){*/
                    
                system.debug('@@CASE_ORIGINAL_OWNER: '+cs.CRM_Case_Original_Owner_Id__c);
                system.debug('@@CASE_OLD_OWNER: '+TriggerOldMap.get(cs.Id).OwnerId);
                system.debug('@@OWNERID: '+TriggerOldMap.get(cs.Id).OwnerId);
                if(cs.CRM_Case_First_Owner__c == null && ((cs.CRM_Case_Original_Owner_Id__c != TriggerOldMap.get(cs.Id).OwnerId && cs.OwnerId != TriggerOldMap.get(cs.Id).OwnerId) || TriggerOldMap.get(cs.Id).CRM_Bypass_Assignment_Rule__c == true)){
                    cs.CRM_Case_First_Owner__c = TriggerOldMap.get(cs.Id).OwnerId;
                }
        }
        //v1.1: Trigger_Settings__c to turn on/off the case ownsership change validation
        //v1.1: Checks whether the case owner belongs to the same queue.
        Trigger_Settings__c TS = Trigger_Settings__c.getValues('CaseOwnershipValidation');
        if(TS != null && TS.is_Active__c == TRUE){
            map<string,list<SetupObjectDataHelper.GroupDetails>> MapGroupMembers = new map<string,list<SetupObjectDataHelper.GroupDetails>>();
            if(listQueueNames.size()>0){
                MapGroupMembers = SetupObjectDataHelper.getGroupMembers(listQueueNames);
                if(ApexCodeUtility.CaseOwnerChange == true){
                    ApexCodeUtility.CaseOwnerChange = false;
                    for(Case cs:TriggerNew){
                        if(String.IsNotBlank(cs.Origin) && cs.Origin.toLowerCase() != 'email' && cs.Origin.toLowerCase() != 'accessadgm portal case' 
                            && cs.Origin.toLowerCase() != 'web' && cs.Origin.toLowerCase() != 'BD Email') // Ignoring the Accessadgm cases - validation not to fire for ownership change
                        {
                            string OldQueueName = TriggerOldMap.get(cs.Id).Queue_Name__c;
                            if(cs.OwnerId!=TriggerOldMap.get(cs.Id).OwnerId && string.valueOf(cs.OwnerId).startsWith('005') && OldQueueName!=null && MapGroupMembers.get(OldQueueName)!=null){
                                boolean IsGroupMember = false;
                                for(SetupObjectDataHelper.GroupDetails QMember:MapGroupMembers.get(OldQueueName)){
                                    if(QMember.GroupOrUserId==cs.OwnerId){
                                        IsGroupMember = true;
                                        break;
                                    }
                                }
                                if(!IsGroupMember)
                                    cs.addError('Owner should belong to '+OldQueueName);
                            }
                        }
                    }
                }
            }
            
        }
    }
    public static void Execute_AU(list<Case> TriggerNew,map<Id,Case> TriggerOldMap){
        
        set<string> setOwnerChangeCaseIds = new set<string>();
        set<string> setStatusChangeCaseIds = new set<string>();
        map<string,string> mapClosedCaseSLAs = new map<string,string>();
        list<Case_SLA__c> lstNewSLAs = new list<Case_SLA__c>();
        list<Case_SLA__c> lstNewCreatedSLAs = new list<Case_SLA__c>();
        list<case> CaseAutoAccept = new list<case>();
        list<case> CaseStatusChangeList = new list<case>();
        
        set<string> setCaseOwnerIds = new set<string>();
        for(Case cs:TriggerNew){
            if(string.valueof(cs.OwnerId).startsWith('00G') && cs.CRM_FirstTimeUpdate__c){
                setCaseOwnerIds.add(cs.OwnerId);
            }
        }
        map<string,string> MapQueueUser = new map<string,string>();
        if(setCaseOwnerIds.size()>0){
            for(GroupMember GrpMem:[select Id,GroupId,UserOrGroupId from GroupMember where GroupId IN:setCaseOwnerIds and UserOrGroupId=:userinfo.getuserid()]){
                MapQueueUser.put(GrpMem.GroupId,userinfo.getuserid());
            }
        }
        //Auto Accepting case 
        for(Case cs:TriggerNew){
            if(string.valueof(cs.OwnerId).startsWith('00G') && cs.CRM_FirstTimeUpdate__c){
                    Case objCSTBU = new Case(Id=cs.Id);
                    if(cs.CRM_Case_Original_Owner_Id__c == null || cs.CRM_Case_Original_Owner_Id__c == ''){
                        objCSTBU.CRM_Case_Original_Owner_Id__c = cs.OwnerId;
                    }
                    if(cs.Origin =='Manual'){
                        if(MapQueueUser.get(cs.OwnerId)!=null){
                            CaseTriggerHelper.OwnerChangeFromButton=false;
                            objCSTBU.ownerid = UserInfo.getUserId();
                            objCSTBU.status = 'Accepted';
                            objCSTBU.CRM_FirstTimeUpdate__c = false;
                            CaseAutoAccept.add(objCSTBU);
                        }
                    }else{
                        objCSTBU.CRM_FirstTimeUpdate__c = false;
                        CaseTriggerHelper.OwnerChangeFromButton=false;
                        CaseAutoAccept.add(objCSTBU);
                    }
              }
        }
        if(!CaseAutoAccept.isEmpty()){
            try {
                update CaseAutoAccept;
            } catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
        }
        
        //Create Manual Sharing for original case owner
        List<CaseShare> caseShareInsertList = new List<CaseShare>();
        
        Map<Id,Id> firstOwnerIds = new Map<Id,Id>();
        for(Case cs:TriggerNew){
            if(cs.CRM_Case_First_Owner__c != null && cs.OwnerId != cs.CRM_Case_First_Owner__c){
                firstOwnerIds.put(cs.CRM_Case_First_Owner__c,cs.OwnerId);
            }
        }
        
        Map<Id,Boolean> firstOwnerIsMember = new Map<Id,Boolean>();
        if(firstOwnerIds != null && !firstOwnerIds.isEmpty()){
            for(GroupMember grpMem : [SELECT GroupId, UserOrGroupId,Group.Name FROM GroupMember WHERE UserOrGroupId IN :firstOwnerIds.keyset() AND Group.Type = 'Queue']){
                if(firstOwnerIds.containskey(grpMem.UserOrGroupId)){
                    if(firstOwnerIds.get(grpMem.UserOrGroupId) == grpMem.GroupId){
                        system.debug('@@USERGRP: '+firstOwnerIds.get(grpMem.UserOrGroupId) + '  ---  '+grpMem.GroupId);
                        firstOwnerIsMember.put(grpMem.UserOrGroupId,true);
                    }
                    
                }
            }
        }
        system.debug('@@FIRST_OWNER: '+firstOwnerIds);
        system.debug('@@FIRST_OWNER_MEMBER: '+firstOwnerIsMember);
        
        for(Case cs:TriggerNew){
            /*if(TriggerOldMap.get(cs.Id).CRM_Case_First_Owner__c != cs.CRM_Case_First_Owner__c && cs.CRM_Case_First_Owner__c != null && TriggerOldMap.get(cs.Id).CRM_Case_First_Owner__c == null && 
                cs.OwnerId != cs.CRM_Case_First_Owner__c){*/
            system.debug('@@FIRST: '+cs.CRM_Case_First_Owner__c);
            system.debug('@@OWNER: '+cs.OwnerId);
            if(cs.CRM_Case_First_Owner__c != null && cs.OwnerId != cs.CRM_Case_First_Owner__c && cs.OwnerId != TriggerOldMap.get(cs.Id).OwnerId){
                CaseShare objCaseShare = new CaseShare();
                objCaseShare.CaseId = cs.Id;
                objCaseShare.UserOrGroupId = cs.CRM_Case_First_Owner__c;
                objCaseShare.RowCause = 'Manual';
                objCaseShare.CaseAccessLevel = 'Read';
                
                if(firstOwnerIsMember.containskey(cs.CRM_Case_First_Owner__c)){
                    if(firstOwnerIsMember.get(cs.CRM_Case_First_Owner__c) == false){
                        caseShareInsertList.add(objCaseShare);
                    }
                } else{
                    caseShareInsertList.add(objCaseShare);
                }
            }
        }
        
        if(!caseShareInsertList.isEmpty()){
            system.debug('@@SHARE: '+caseShareInsertList);
            insert caseShareInsertList;
        }
        
       //Changing Case status to assigned for change owner button.
        for(Case objCase:TriggerNew) {
            if ( objCase.OwnerId != TriggerOldMap.get(objCase.Id).OwnerId && CaseTriggerHelper.OwnerChangeFromButton==true)
                CaseStatusChangeList.add(New Case(Id=objCase.Id,Status='Assigned',CRM_Previous_Owner__c = TriggerOldMap.get(objCase.Id).Owner_Name__c));
           }
        if(!CaseStatusChangeList.isEmpty()){
            try {
                update CaseStatusChangeList;
            } catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
        }       
        /*Create SLA Record for the below conditions:
        1. If Queue changes
        2. If Priority changes
        3. If Case Status = 'Reopen'
        4. Update the SLA record when the case status is 'Pending - Customer'
        */
        map<string,Case> MapCasesTBU = new map<string,Case>();
        SLA_Configuration__c slaConfig = new SLA_Configuration__c();
        set<id> OwnerChangeId = new set<id>();
        map<string,SLA_Configuration__c> MapSLAMaster = new map<string,SLA_Configuration__c>();
        list<string> lstOriginConfigValues = new list<string>();
        if(SLA_Configuration__c.getAll()!=null){
            for(SLA_Configuration__c SLA:SLA_Configuration__c.getAll().Values()){
                if(string.isNotBlank(SLA.Queue_Name__c) && SLA.Business_Hour_Id__c!=null && SLA.SLA_Minutes__c!=null){
                    if(string.isNotBlank(SLA.Level__c) && string.isNotBlank(SLA.SLA_Type__c) && SLA.SLA_Type__c.toLowerCase() == 'queue & level')
                        MapSLAMaster.put(SLA.Queue_Name__c.toLowerCase() + '_' + SLA.Level__c.toLowerCase(),SLA);
                    else if(string.isNotBlank(SLA.Case_Origin__c))
                    {   //Get the values configured for SLA - Combination will be QueueName and CaseOrigin. 
                        lstOriginConfigValues = SLA.Case_Origin__c.split(','); //Multiple Case Origin is seperated by comma in the custom setting. 
                        for(string slaOrigin : lstOriginConfigValues)
                             MapSLAMaster.put(SLA.Queue_Name__c.toLowerCase() + '_' + slaOrigin.trim().toLowerCase(),SLA);
                    }
                    else
                        MapSLAMaster.put(SLA.Queue_Name__c.toLowerCase(),SLA);
                }
            }
        }
        system.debug('MapSLAMaster==>'+MapSLAMaster);
        
        for(Case cs:TriggerNew){
            if((cs.Queue_Name__c!=TriggerOldMap.get(cs.Id).Queue_Name__c ) 
            || (cs.Priority != TriggerOldMap.get(cs.Id).Priority )
            || (cs.Status == 'Re-Open' && cs.Status!=TriggerOldMap.get(cs.Id).Status )
            || ((cs.Status == 'Pending - Customer' || TriggerOldMap.get(cs.Id).Status == 'Pending - Customer') && cs.Status!=TriggerOldMap.get(cs.Id).Status )
            || ((cs.Status == 'Pending - Internal' || TriggerOldMap.get(cs.Id).Status == 'Pending - Internal') && cs.Status!=TriggerOldMap.get(cs.Id).Status ) 
            || (cs.Status != TriggerOldMap.get(cs.Id).Status && cs.Status == 'Escalated')
            ){ 
                system.debug('@@ESCALATED');
                setOwnerChangeCaseIds.add(cs.Id);
                //Create new sla record except for 'Pending - Customer';The sla will pause for 'Pending - Customer' or 'Pending - Internal'
                // SLA is not to be created for case having status='Pending - Customer'
                if(cs.Status != 'Pending - Customer' && cs.Status != 'Pending - Internal') { 
                    Case_SLA__c obj = new Case_SLA__c();
                    obj.Parent__c = cs.Id;
                    obj.Change_Type__c = 'Owner';
                    obj.From__c = system.now();
                    obj.Owner__c = cs.Queue_Name__c;
                    obj.Status__c = cs.Status;
                    obj.Priority__c = cs.Priority;
                    system.debug('QueueName==>'+cs.Queue_Name__c);
                    if(string.isNotBlank(cs.Queue_Name__c) && cs.Queue_Name__c.toLowerCase() == 'client support centre' && string.isNotBlank(cs.Priority))
                        slaConfig = MapSLAMaster.get(cs.Queue_Name__c.toLowerCase() + '_' + cs.Priority.toLowerCase());
                    else if(string.isNotBlank(cs.Queue_Name__c) && string.isNotBlank(cs.Origin))
                        slaConfig = MapSLAMaster.get(cs.Queue_Name__c.toLowerCase() + '_' + cs.Origin.toLowerCase());
                    else
                        if(string.isNotBlank(cs.Queue_Name__c))
                            slaConfig = MapSLAMaster.get(cs.Queue_Name__c.toLowerCase());
                    system.debug('cs.Queue_Name__c----->'+cs.Queue_Name__c);
                    system.debug('slaConfig----->'+slaConfig);
                    if(cs.Queue_Name__c!=null && slaConfig !=null){
                        obj.Business_Hours_Id__c = slaConfig.Business_Hour_Id__c;
                        Long sla = slaConfig.SLA_Minutes__c.longvalue();
                        sla = sla*60*1000L;
                        if(cs.Priority != TriggerOldMap.get(cs.Id).Priority){
                            lstNewCreatedSLAs.add(obj);
                            obj.Due_Date_Time__c = BusinessHours.add(obj.Business_Hours_Id__c,system.now(),sla);
                        }else{
                            obj.Due_Date_Time__c = BusinessHours.add(obj.Business_Hours_Id__c,system.now(),sla);
                            lstNewSLAs.add(obj);
                            system.debug('*********'+lstNewSLAs.size());
                            system.debug('*********'+lstNewSLAs);
                        }
                        
                        if(cs.Status == 'Escalated'){
                            obj.Due_Date_Time__c = BusinessHours.add(obj.Business_Hours_Id__c,system.now(),sla);
                            lstNewSLAs.add(obj);
                            system.debug('*********'+lstNewSLAs.size());
                            system.debug('*********'+lstNewSLAs);
                        }
                        Case objCS = new Case(Id=cs.Id,Due_Date_Time__c = obj.Due_Date_Time__c);
                        MapCasesTBU.put(objCS.Id,objCS);
                        
                        system.debug('@@LST_NEW_CREATED: '+lstNewCreatedSLAs);
                        system.debug('@@LST_NEW: '+lstNewSLAs);
                    }
                }
            }
            if(cs.Status!=TriggerOldMap.get(cs.Id).Status && cs.isClosed){
                mapClosedCaseSLAs.put(cs.Id,cs.Id);
            }
        }
        //Calculating the Enddatetime and the business minutes for the previously created SLA [Close SLA Feature]
        map<string,decimal> MapNewCreatedSLAs = new map<string,decimal>();//This map contains the QueueName and the Timespent for each queue in minutes.
        System.debug('MapNewCreatedSLAs>>>'+MapNewCreatedSLAs);
        if(setOwnerChangeCaseIds!=null && setOwnerChangeCaseIds.size()>0){
            System.debug('setOwnerChangeCaseIds>>>>'+setOwnerChangeCaseIds);
            for(Case_SLA__c sl:[Select Id,Business_Hours_Id__c,From__c,Until__c,Calculated_Business_Minutes__c,Parent__c,Owner__c from Case_SLA__c where Parent__c IN:setOwnerChangeCaseIds and From__c!=null and Change_Type__c='Owner']){
                System.debug('sl.Until__c>>>>'+sl.Until__c);
                Decimal TimeSpent = 0;
                if(MapNewCreatedSLAs.get(sl.Owner__c)!=null)
                    TimeSpent = MapNewCreatedSLAs.get(sl.Owner__c);
                if(sl.Until__c==null){
                    sl.Until__c = system.now();
                    if(sl.Business_Hours_Id__c!=null)
                        sl.Calculated_Business_Minutes__c = BusinessHours.diff(sl.Business_Hours_Id__c,sl.From__c,sl.Until__c)/1000/60;
                    lstNewSLAs.add(sl);
                    System.debug('lstNewSLAs>>>>>>>>');
                    System.debug(lstNewSLAs);
                }
                if(sl.Calculated_Business_Minutes__c!=null)
                    TimeSpent = TimeSpent + sl.Calculated_Business_Minutes__c;
                MapNewCreatedSLAs.put(sl.Owner__c,TimeSpent);
            }
        }
        
        System.debug('MapNewCreatedSLAs>>>'+MapNewCreatedSLAs);
        for(Case_SLA__c sla : lstNewCreatedSLAs){ //Calulating the difference in minutes.
            if(String.isNotBlank(sla.Owner__c) && String.isNotBlank(sla.Priority__c))
                slaConfig = MapSLAMaster.get(sla.Owner__c.toLowerCase() + '_' + sla.Priority__c.toLowerCase());
            if(slaConfig != null){
                Long slaVal = slaConfig.SLA_Minutes__c.longvalue();
                slaVal = slaVal*60*1000L;
                sla.Due_Date_Time__c = BusinessHours.add(sla.Business_Hours_Id__c,system.now(),slaVal);
                if(MapNewCreatedSLAs != null && MapNewCreatedSLAs.containsKey(sla.Owner__c)){
                    integer totalBusinessMinutes = Integer.valueOf(MapNewCreatedSLAs.get(sla.Owner__c)) * -1;
                    sla.Due_Date_Time__c = sla.Due_Date_Time__c.addMinutes(totalBusinessMinutes);
                }
                lstNewSLAs.add(sla);
            }
            Case objCS = new Case(Id=sla.Parent__c,Due_Date_Time__c = sla.Due_Date_Time__c);
            MapCasesTBU.put(objCS.Id,objCS);
        }
        
        if(mapClosedCaseSLAs!=null && mapClosedCaseSLAs.size()>0){
            try{
                list<Case_SLA__c> openSLAs = new list<Case_SLA__c>();
                //openSLAs.addAll(mapClosedCaseSLAs.values());
                for(Case_SLA__c sla:[select Id,Until__c,Business_Hours_Id__c,From__c,Calculated_Business_Minutes__c from Case_SLA__c where Parent__c IN:mapClosedCaseSLAs.keyset() and Until__c=null]){
                    sla.Until__c = system.now();
                    if(sla.Business_Hours_Id__c!=null)
                        sla.Calculated_Business_Minutes__c = BusinessHours.diff(sla.Business_Hours_Id__c,sla.From__c,sla.Until__c)/1000/60;
                    openSLAs.add(sla);
                }
                if(openSLAs!=null && openSLAs.size()>0){
                    Database.UpsertResult[] srList = Database.upsert(openSLAs, false);   
                }
            }catch(Exception e){
                TriggerNew[0].addError(e.getMessage()+'');
            }
        }
        if(lstNewSLAs!=null && lstNewSLAs.size()>0){
            try{
                if(!ApexCodeUtility.CaseTriggerRecursive){
                    ApexCodeUtility.CaseTriggerRecursive = true;
                    for(Case_SLA__c tempS : lstNewSLAs){
                        system.debug(tempS);
                    }
                    Database.UpsertResult[] srList = Database.upsert(lstNewSLAs, false);
                    if(MapCasesTBU!=null && MapCasesTBU.size()>0)
                        update MapCasesTBU.values();
                }
            }catch(Exception e){
                TriggerNew[0].addError(e.getMessage()+'');
            }
        }
        CaseTriggerHelper.invokeAssignmentRulesInsert(TriggerNew, TriggerOldMap);
        //Enabling Case module for BD team
        Configure_BD_SLA(TriggerNew, TriggerOldMap);
    }
    
    /* Method Name: Configure_BD_SLA
    *  Description: This method was introduced during Enabling Case module for BD team
    *               The method will be called form the after insert and after update Triggers.
    *               Static Variable is used to control the recurring execution
    *               SLA_Configuration__c is used to define the SLA time.
    *               Business Hours ID, Module=syste.label.CaseRecordTypeBDQueries, SLA in minutes/Hours, Level(used to check the case status)  is required, do not populate queue**)
    *
    *               Record Type=Office of business development
    *               If New --> 8 Hours
    *               If chnaged to Assigned or Accepted 8 Hours
    *               If closed Close
    *               
    */
    public static boolean execute_BD_Team_SLA = true;
    public static void Configure_BD_SLA(list<Case> newCase, map<Id,Case> oldCase){
         map<String,ID> caseRecordTypeMap=ApexCodeUtility.getRecTypeDetails('Case');
         list<Case> caseToProcess = new list<Case>();
         for(Case tempCase: newCase){
             if(tempCase.recordTypeID== caseRecordTypeMap.get(system.label.CaseRecordTypeBDQueries)){
                 caseToProcess.add(tempCase);
             }
         }
         if(!caseToProcess.isEmpty() && execute_BD_Team_SLA){
             map<String,SLA_Configuration__c> statusToSLAConfigMap = new map<String,SLA_Configuration__c>();
             for(SLA_Configuration__c tempSLA: [select id,Level__c,Business_Hour_Id__c,SLA_Hours__c,SLA_Minutes__c from SLA_Configuration__c where Module__c = :system.label.CaseRecordTypeBDQueries]){
                 statusToSLAConfigMap.put(tempSLA.Level__c,tempSLA);
             }
             //SLAs To Insert
             list<Case_SLA__c> slaToUpsert = new list<Case_SLA__c>();
             set<ID> slaToCloseParentID = new set<ID>();
             for(Case tempCase: caseToProcess){
             //If insert with New
             //or update from new create SLA
                 if(!tempCase.isClosed && statusToSLAConfigMap.containsKey(tempCase.Status) &&
                         ((trigger.isInsert && tempCase.Status.equalsIgnoreCase('New')) || 
                          (trigger.isUpdate && tempCase.Status!=oldCase.get(tempCase.Id).Status && oldCase.get(tempCase.Id).Status.equalsIgnoreCase('New')))){
                     SLA_Configuration__c slaRecord= statusToSLAConfigMap.get(tempCase.Status);  
                     Case_SLA__c tempSLARecord = new Case_SLA__c();
                     tempSLARecord.Parent__c = tempCase.Id;
                     tempSLARecord.Change_Type__c = 'Owner';
                     tempSLARecord.From__c = system.now();
                     tempSLARecord.Owner__c = tempCase.Owner_Name__c;
                     tempSLARecord.Status__c = tempCase.Status;
                     tempSLARecord.Priority__c = tempCase.Priority;
                     tempSLARecord.Business_Hours_Id__c =slaRecord.Business_Hour_Id__c;
                     tempSLARecord.Due_Date_Time__c=BusinessHours.add(tempSLARecord.Business_Hours_Id__c,system.now(),slaRecord.SLA_Minutes__c.longvalue()*60*1000L);
                     slaToUpsert.add(tempSLARecord);
                     if(trigger.isUpdate){slaToCloseParentID.add(tempCase.Id);}
                 }else if(tempCase.isClosed){
                     slaToCloseParentID.add(tempCase.Id);
                 }
             }
             for(Case_SLA__c tempSLAToUpdate : [select id,From__c,Business_Hours_Id__c from Case_SLA__c where Parent__c in :slaToCloseParentID]){
                 
                 slaToUpsert.add(new Case_SLA__c(id=tempSLAToUpdate.Id,
                                 Until__c = system.now(),
                                 Calculated_Business_Minutes__c = BusinessHours.diff(tempSLAToUpdate.Business_Hours_Id__c,tempSLAToUpdate.From__c,system.now())/1000/60));
             }
             if(!slaToUpsert.isEmpty()){
                 upsert slaToUpsert;
                 execute_BD_Team_SLA=false;
             }
         }
         
    }
}