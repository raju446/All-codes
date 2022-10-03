/*
    Author      :   Jayanta Karmakar
    Class Name  :   TaskTriggerHandler
    Description :   Trigger handler class that is being referenced in the TaskTrigger.
                    All DML methods are being handled in this handler class.
    Date        :   03/04/2019
    ---------------------------------------------------------------------------------------------
    
     * @Change History
     * Author       Date            Description
     * 
     * CRM Support  12/04/2020     The method is introduced to update the email Counter on the lead record
     *                             The method is introduced to update the Last Contact Date on Lead, whenever the Email or Call is logged on Lead record
*/
public class TaskTriggerHandler{
    public Static void doBI(List<Task> newList){
    }

    public Static void doAI(List<Task> newList){
        updateCampaignStatus(newList);
        //CRM Support
        //This method will also update Last_Contact_Date__c field on lead for email and Call tasks
        updateContactedDate(newList);
    }

    public Static void doBU(List<Task> newList){
    }

    public Static void doAU(List<Task> newList, Map<Id,Task> taskOldMap){
        updateCampaignStatus(newList);
        updateCaseStatusInProgress(newList,taskOldMap);
    }
    /*
    Name : updateCampaignStatus
    Description : update Campaign Status if all task are completed.
    */    
    public static void updateCampaignStatus(List<Task> newList){
        Set<String> campTypes = new Set<String>();
        
        for(CRM_Protocol_Event_Category__mdt pec : [select CRM_Event_Category__c from CRM_Protocol_Event_Category__mdt limit 1000]){
            campTypes.add(pec.CRM_Event_Category__c);
        }

        Set<Id> campIds = new Set<Id>();
        for(Task t : newList){
            campIds.add(t.whatId);
        }
        
        List<Campaign> campLst = [select id,Main_Category__c,(SELECT id,status FROM Tasks WHERE status NOT IN ('Completed', 'Deferred')) from Campaign where Id in : campIds AND Main_Category__c IN : campTypes and Status = 'Planned'];
        
        for(Campaign cm : campLst){
            if(cm.Tasks.size() == 0) {
                cm.Status = 'In Progress';
            }//end if
            
        }
        
        try{
            update campLst;
        } catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    
    /*
    Name : updateCampaignStatus
    Description : update Campaign Status if all task are completed.
    */ 
    public static void updateCaseStatusInProgress(List<Task> newList, Map<Id,Task> oldTaskMap){
        Set<Id> caseIds = new Set<Id>();
        Set<Id> taskIds = new Set<Id>();
        for(Task objTask : newList){
            if(objTask.WhatId != null){
                String whatIdStr = objTask.WhatId;
                String prefixStr = whatIdStr.subString(0,3);
                if(prefixStr == '500' && objTask.Status != oldTaskMap.get(objTask.Id).Status && 
                    objTask.Status == 'Completed' && objTask.TaskSubType == 'Task' && 
                    objTask.CRM_Internal_Task__c == true){
                    caseIds.add(objTask.WhatId);
                    taskIds.add(objTask.Id);
                }
            }
        }
        
        /*Map<Id,Integer> taskMap = new Map<Id,Integer>();
        for(Task objTask : [SELECT Id,Status FROM Task WHERE WhatId IN :caseIds AND Id NOT IN :taskIds]){
            if()
        }*/
        
        
        Set<String> originAllowed = new Set<String>{'Client Support Centre Email','Manual','ACCESSADGM Portal Case','Registration Authority Email','Monitoring and Enforcement Email','Office of Data Protection Email'};
        List<Case> updateCaseList = new List<Case>();
        for(Case objCase : [SELECT Id,Status,(SELECT Id FROM Tasks WHERE Status != 'Completed' AND CRM_Internal_Task__c = true AND Id NOT IN: taskIds) FROM Case WHERE Id In :caseIds AND Origin IN :originAllowed AND isClosed = false AND isEscalated = false]){
            System.debug('@@CASE_TASK: '+objCase.Tasks);
            if(objCase.Tasks.size() == 0){
                objCase.Status = 'In Progress';
                updateCaseList.add(objCase);
            }
        }
        
        if(updateCaseList != null && !updateCaseList.isEmpty()){
            update updateCaseList;
        }
    }
    
    /**
    * updateEmailConterOnLead
    * 
    * This method is added during CRm Support Project, Called directly from the trigger on After triggers
    * This will update the email counter on related lead records
    *
    * @param  newList    List of new task Records 
    * @param  oldList    List of new old Records         
    * @return void
    */
    public static void updateEmailConterOnLead(List<Task> newList,list<Task> oldList){
        String leadPrefix = Lead.SObjectType.getDescribe().getKeyPrefix();
        map<Id,Lead> relatedLeadMap = new map<ID,Lead>();
        if(newList!=null){
            for(task tempT : newList){
                if(tempT.WhoId!= null && string.valueof(tempT.WhoId).startsWith(leadPrefix) ){
                    relatedLeadMap.put(tempT.WhoId,null);
                }
            }
        }
        if(oldList!=null){
            for(task tempT : oldList){
                if(tempT.WhoId!= null && string.valueof(tempT.WhoId).startsWith(leadPrefix) ){
                    relatedLeadMap.put(tempT.WhoId,null);
                }
            }
        }
        
        //get all related lead records
        relatedLeadMap = new map<ID,Lead>([select id,EmailCount__c,(select id from Tasks where Type='Email') from Lead where id in :relatedLeadMap.keySet()]);
        List<Lead> recordToUpdate = new list<LEad>();
        for(Lead tempLead : relatedLeadMap.values()){
            if(tempLead.EmailCount__c!=tempLead.Tasks.Size()){
                recordToUpdate.add(new Lead (id=tempLead.Id,EmailCount__c=tempLead.Tasks.Size()));
            }
        }
        if(!recordToUpdate.isEmpty()){
            update recordToUpdate;
        }
        
    }
    
    
    /**
    * updateContactedDate
    * 
    * THis method was introduced in CRM Support project
    * This method will also update Last_Contact_Date__c field on lead for email and Call tasks.
    * This method i scalled from After insert trigger
    *
    * @param  newRecords   List of new task Records         
    * @return void
    */
    public static void updateContactedDate(List<Task> newList){
        list<Lead> leadsToUpdate = new list<Lead>();
        String leadPrefix = Lead.SObjectType.getDescribe().getKeyPrefix(); 
        if(newList!=null){
            for(task tempT : newList){
                if(tempT.WhoId!= null && string.valueof(tempT.WhoId).startsWith(leadPrefix) && 
                   (tempT.Type=='Email' || tempT.Type=='Call' )){
                    leadsToUpdate.add(new lead(id=tempT.WhoId,Last_Contact_Date__c=system.today()));
                }
            }
            if(!leadsToUpdate.isEmpty()){
                update leadsToUpdate;
            }    
        }
    }
}