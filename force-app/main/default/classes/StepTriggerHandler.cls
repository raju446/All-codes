public without sharing class StepTriggerHandler
{
    public static void  Execute_AU(list<HexaBPM__Step__c> TriggerNew,map<id,HexaBPM__Step__c> oldmap)
    {
        set<id> createresubmitinSrs = new set<id>();
        set<id> createreuploadinSrs = new set<id>();
        set<id> createConfirmsubmitinSrs = new set<id>();
        
        for(HexaBPM__Step__c step : TriggerNew)
        {
            if(step.Step_Template_Code__c=='GET_NEW_DRAFT_NUMBER' && step.HexaBPM__Step_Status__c == 'Get New Draft Number' && oldmap.get(step.id).HexaBPM__Step_Status__c != step.HexaBPM__Step_Status__c)// || step.Step_Template_Code__c=='RESUBMIT_APPLICATION' )
            {
                createresubmitinSrs.add(step.id);
            }
            else if(step.Step_Template_Code__c=='RESUBMIT_APPLICATION' && step.HexaBPM__Step_Status__c == 'Re Submit Application' && oldmap.get(step.id).HexaBPM__Step_Status__c != step.HexaBPM__Step_Status__c)
            {
                createreuploadinSrs.add(step.id);
            }
            else if(step.Step_Template_Code__c=='REUPLOAD_DOCUMENTS' && step.HexaBPM__Step_Status__c == 'Document Uploaded' && oldmap.get(step.id).HexaBPM__Step_Status__c != step.HexaBPM__Step_Status__c)
            {
                createConfirmsubmitinSrs.add(step.id);
            }
        }
        system.debug('==createresubmitinSrs=='+createresubmitinSrs);
        system.debug('==createreuploadinSrs=='+createreuploadinSrs);
        system.debug('==createConfirmsubmitinSrs=='+createConfirmsubmitinSrs);
        if(!createresubmitinSrs.isEmpty())
        {
            map<string, HexaBPM__SR_Steps__c> templatesteps = new map<string, HexaBPM__SR_Steps__c>();
            map<id,string> stepwithRectype = new map<id,string>();
            
            for(HexaBPM__SR_Steps__c srStep : [SELECT Id, HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c, HexaBPM__Summary__c, HexaBPM__Step_No__c, HexaBPM__Start_Status__c, HexaBPM__Step_Template__c
                                            FROM HexaBPM__SR_Steps__c 
                                            WHERE HexaBPM__Step_Template_Code__c = 'RESUBMIT_APPLICATION' and 
                                            (HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c = 'Initial_Approval' or 
                                            HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c = 'Establishment_Card_Renewal' or 
                                            HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c = 'Establishment_Card_Amendment' or 
                                            HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c = 'Establishment_Card_Cancellation' or 
                                            HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c = 'Establishment_Card_New')])
            {
                templatesteps.put(srStep.HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c,srStep);
            }
            
           for(HexaBPM__Step__c step : [Select id, HexaBPM__SR__r.Recordtype.DeveloperName from HexaBPM__Step__c where id IN:createresubmitinSrs])
           {
                stepwithRectype.put(step.id,step.HexaBPM__SR__r.Recordtype.DeveloperName);
                system.debug('===checks=='+step.id+'==='+step.HexaBPM__SR__r.Recordtype.DeveloperName);
           }  
          
          list<HexaBPM__Step__c> srsteps = new list<HexaBPM__Step__c>();
          for(HexaBPM__Step__c step : TriggerNew)
          {
            if(stepwithRectype.containsKey(step.id))
            {
                HexaBPM__SR_Steps__c srStep = templatesteps.get(stepwithRectype.get(step.id));
                 if(srStep != null)
                 {
                    HexaBPM__Step__c newStep        = new HexaBPM__Step__c();
                    newStep.HexaBPM__Step_No__c     = srStep.HexaBPM__Step_No__c;
                    newStep.HexaBPM__SR_Step__c     = srStep.Id; 
                    newStep.HexaBPM__Summary__c     = srStep.HexaBPM__Summary__c;
                    newStep.HexaBPM__Status__c      = srStep.HexaBPM__Start_Status__c;
                    newStep.HexaBPM__SR__c          = step.HexaBPM__SR__c;
                    newStep.HexaBPM__Start_Date__c  = Date.today();
                    newStep.HexaBPM__Due_Date__c    = system.today();
                    newStep.HexaBPM__Sys_Step_Loop_No__c = string.valueof(srStep.HexaBPM__Step_No__c)+'_1';
                    newStep.OwnerId                 = Label.Government_Services_Queue_Id;
                    newStep.HexaBPM__Step_Template__c = srStep.HexaBPM__Step_Template__c;
                    srsteps.add(newStep);
                }
            }
          }
          if(!srsteps.isEmpty()){
            insert srsteps;
          }
        }
        
        if(!createreuploadinSrs.isEmpty())
        {
            map<string, HexaBPM__SR_Steps__c> templatesteps = new map<string, HexaBPM__SR_Steps__c>();
            map<id,string> stepwithRectype = new map<id,string>();
            
            for(HexaBPM__SR_Steps__c srStep : [SELECT Id, HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c, HexaBPM__Summary__c, HexaBPM__Step_No__c, HexaBPM__Start_Status__c, HexaBPM__Step_Template__c
                                            FROM HexaBPM__SR_Steps__c 
                                            WHERE HexaBPM__Step_Template_Code__c = 'REUPLOAD_DOCUMENTS' and 
                                            (HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c = 'Initial_Approval' or 
                                            HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c = 'Establishment_Card_Renewal' or 
                                            HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c = 'Establishment_Card_Amendment' or 
                                            HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c = 'Establishment_Card_Cancellation' or 
                                            HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c = 'Establishment_Card_New')])
            {
                templatesteps.put(srStep.HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c,srStep);
            }
            
           for(HexaBPM__Step__c step : [Select id, HexaBPM__SR__r.Recordtype.DeveloperName from HexaBPM__Step__c where id IN:createreuploadinSrs])
           {
                stepwithRectype.put(step.id,step.HexaBPM__SR__r.Recordtype.DeveloperName);
           }  
          
          list<HexaBPM__Step__c> srsteps = new list<HexaBPM__Step__c>();
          for(HexaBPM__Step__c step : TriggerNew)
          {
            if(stepwithRectype.containsKey(step.id))
            {
                HexaBPM__SR_Steps__c srStep = templatesteps.get(stepwithRectype.get(step.id));
                 if(srStep != null)
                 {
                    HexaBPM__Step__c newStep        = new HexaBPM__Step__c();
                    newStep.HexaBPM__Step_No__c     = srStep.HexaBPM__Step_No__c;
                    newStep.HexaBPM__SR_Step__c     = srStep.Id; 
                    newStep.HexaBPM__Summary__c     = srStep.HexaBPM__Summary__c;
                    newStep.HexaBPM__Status__c      = srStep.HexaBPM__Start_Status__c;
                    newStep.HexaBPM__SR__c          = step.HexaBPM__SR__c;
                    newStep.HexaBPM__Start_Date__c  = Date.today();
                    newStep.HexaBPM__Due_Date__c    = system.today();
                    newStep.HexaBPM__Sys_Step_Loop_No__c = string.valueof(srStep.HexaBPM__Step_No__c)+'_1';
                    newStep.OwnerId                 = Label.Government_Services_Queue_Id;
                    newStep.HexaBPM__Step_Template__c = srStep.HexaBPM__Step_Template__c;
                    srsteps.add(newStep);
                }
            }
          }
          if(!srsteps.isEmpty()){
            insert srsteps;
          }
        
        }
        
        if(!createConfirmsubmitinSrs.isEmpty())
        {
            map<string, HexaBPM__SR_Steps__c> templatesteps = new map<string, HexaBPM__SR_Steps__c>();
            map<id,string> stepwithRectype = new map<id,string>();
            
            for(HexaBPM__SR_Steps__c srStep : [SELECT Id, HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c, HexaBPM__Summary__c, HexaBPM__Step_No__c, HexaBPM__Start_Status__c, HexaBPM__Step_Template__c
                                            FROM HexaBPM__SR_Steps__c 
                                            WHERE HexaBPM__Step_Template_Code__c = 'CONFIRM_RESUBMIT' and 
                                            (HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c = 'Initial_Approval' or 
                                            HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c = 'Establishment_Card_Renewal' or 
                                            HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c = 'Establishment_Card_Amendment' or 
                                            HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c = 'Establishment_Card_Cancellation' or 
                                            HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c = 'Establishment_Card_New')])
            {
                templatesteps.put(srStep.HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c,srStep);
            }
            
           for(HexaBPM__Step__c step : [Select id, HexaBPM__SR__r.Recordtype.DeveloperName from HexaBPM__Step__c where id IN:createConfirmsubmitinSrs])
           {
                stepwithRectype.put(step.id,step.HexaBPM__SR__r.Recordtype.DeveloperName);
           }  
          
          list<HexaBPM__Step__c> srsteps = new list<HexaBPM__Step__c>();
          for(HexaBPM__Step__c step : TriggerNew)
          {
            if(stepwithRectype.containsKey(step.id))
            {
                HexaBPM__SR_Steps__c srStep = templatesteps.get(stepwithRectype.get(step.id));
                 if(srStep != null)
                 {
                    HexaBPM__Step__c newStep        = new HexaBPM__Step__c();
                    newStep.HexaBPM__Step_No__c     = srStep.HexaBPM__Step_No__c;
                    newStep.HexaBPM__SR_Step__c     = srStep.Id; 
                    newStep.HexaBPM__Summary__c     = srStep.HexaBPM__Summary__c;
                    newStep.HexaBPM__Status__c      = srStep.HexaBPM__Start_Status__c;
                    newStep.HexaBPM__SR__c          = step.HexaBPM__SR__c;
                    newStep.HexaBPM__Start_Date__c  = Date.today();
                    newStep.HexaBPM__Due_Date__c    = system.today();
                    newStep.HexaBPM__Sys_Step_Loop_No__c = string.valueof(srStep.HexaBPM__Step_No__c)+'_1';
                    newStep.OwnerId                 = Label.Government_Services_Queue_Id;
                    newStep.HexaBPM__Step_Template__c = srStep.HexaBPM__Step_Template__c;
                    srsteps.add(newStep);
                }
            }
          }
          if(!srsteps.isEmpty()){
            insert srsteps;
          }
        
        }
    }
}