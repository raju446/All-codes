trigger StepTrigger on HexaBPM__Step__c(before update, after update)
{
    set<id> srids = new set<id>();
    set<id> trainingSRids = new set<id>();
    set<id> errorIds = new set<id>();
    map<id,id> stepandSrid = new map<id,id>();
    
    if(trigger.isUpdate && trigger.isBefore)
    {
        for(HexaBPM__Step__c step : trigger.new)
        {
            if(step.Step_Template_Code__c=='UPDATE_HEALTH_INSURANCE_DETAILS' || step.Step_Template_Code__c=='MEDICAL_IN_PROGRESS' 
               || step.Step_Template_Code__c=='SUBMIT_PASSPORT_VISA_STAMPING' || step.Step_Template_Code__c=='RESIDENCE_VISA_APPROVAL')
                step.HexaBPM__Sys_Step_Loop_No__c = string.valueOf(step.HexaBPM__Step_No__c)+'_1';
            
            
            if(step.HexaBPM__Step_Status__c == 'Application Submitted')
                srids.add(step.HexaBPM__SR__c);
            
            if(step.HexaBPM__Step_Status__c == 'Typing Completed' && (step.Service_Request_Name__c == 'Trainings and Seminars Permit' || step.Service_Request_Name__c == 'Photography Permit'))
                trainingSRids.add(step.HexaBPM__SR__c);
            
            system.debug('===='+step.HexaBPM__Summary__c+'====='+step.HexaBPM__Step_Status__c);
            if(step.HexaBPM__Summary__c != null && step.HexaBPM__Summary__c.contains('Cancellation') && step.HexaBPM__Step_Status__c == 'Approved')
            {
                stepandSrid.put(step.HexaBPM__SR__c,step.id);
            }
        }
    }
    else if(trigger.isUpdate && trigger.isAfter)
    {
        StepTriggerHandler.Execute_AU(trigger.new,trigger.oldmap);
    }
    if(!srids.isEmpty())
    {
        set<id> accountids = new set<id>();
        for(HexaBPM__Step__c step : [Select HexaBPM__SR__r.Service_Request_Name__c,
                                     HexaBPM__SR__r.HexaBPM__Customer__c FROM HexaBPM__Step__c
                                     WHERE ID IN:trigger.new ])
            
        {
            if( step.HexaBPM__SR__r.Service_Request_Name__c == 'Initial Approval')
                accountids.add(step.HexaBPM__SR__r.HexaBPM__Customer__c);
        }
        
        for(Role__c role : [Select Subject_Account__c ,Nationality_Arabic__c,Unified_ID__c,Middle_Name_Arabic__c,
                            Surname_in_Arabic__c,Forenames_in_Arabic__c FROM Role__c WHERE 
                            Subject_Account__c IN:accountids 
                            and Status__c='Active' ])
        {
            system.debug('===='+role.id+'=='+role.Nationality_Arabic__c+'=='+role.Unified_ID__c+'=='+role.Surname_in_Arabic__c+'==='+role.Forenames_in_Arabic__c);
            if(string.isBlank(role.Nationality_Arabic__c ) ||
               string.isBlank(role.Unified_ID__c)         ||
               string.isBlank(role.Surname_in_Arabic__c)  ||
               string.isBlank(role.Middle_Name_Arabic__c) ||
               string.isBlank(role.Forenames_in_Arabic__c)
              )
                errorIds.add(role.Subject_Account__c);
        }
        for(HexaBPM__Step__c step : [SELECT HexaBPM__SR__r.HexaBPM__Customer__c FROM HexaBPM__Step__c 
                                     WHERE Id IN:trigger.new])
        {
            if(errorIds.contains(step.HexaBPM__SR__r.HexaBPM__Customer__c))
            {
                HexaBPM__Step__c step1 = trigger.newmap.get(step.id);
                step1.addError('Please fill out the mandatory fields on Role');
            }
        }                            
    }
    
    if(!trainingSRids.isEmpty())
    {
        set<id> errorIds1 = new set<id>();
        set<id> approvedIds = new set<id>();
        
        for(Amendment__c am : [Select id,Is_Participant_Approved__c,Service_Request__c FROM Amendment__c 
                               WHERE Service_Request__c=:trainingSRids AND
                               (Is_Participant_Approved__c = null OR Is_Participant_Approved__c = 'Yes')
                               AND 
                               (Service_Request__r.Service_Request_Name__c = 'Trainings and Seminars Permit' 
                                or Service_Request__r.Service_Request_Name__c = 'Photography Permit')])
        {
            if(am.Is_Participant_Approved__c == null)
                errorIds1.add(am.Service_Request__c);
            else if(am.Is_Participant_Approved__c == 'Yes')
                approvedIds.add(am.Service_Request__c);
        }
        
        if(!errorIds1.isEmpty() || approvedIds.isEmpty())
        {
            for(HexaBPM__Step__c step : trigger.new)
            {
                //Check if List of Participants approved or not..
                if(errorIds.contains(step.HexaBPM__SR__c)){
                    step.addError('Please mention whether the Participant approved or not.');
                    return;
                }
                
                //Check if any one of the participant got approved.
                if(approvedIds.isEmpty())
                    step.addError('You cannot approve this step as none of the participants got approved.');
            }
        }
    }
    
    if(!stepandSrid.isEmpty())
    {
        set<id> srids1 = new set<id>();
        for(HexaBPM__Service_Request__c sr : [Select id,(select id from HexaBPM__SR_Price_Items1__r where Is_Refund_Line__c=true) from HexaBPM__Service_Request__c
                                              where ID IN:stepandSrid.keyset()])
        {
            if(sr.HexaBPM__SR_Price_Items1__r.isEmpty())
            {
                srids1.add(sr.id);
            }    
        }
        
        for(HexaBPM__Step__c step : trigger.new)
        {
            if(srids1.contains(step.HexaBPM__SR__c)){
                step.addError('You cannot approve the cancellation request as refund line is not created. Please contact system administrator.');
            }
        }
    }    
}