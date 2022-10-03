public without sharing class ICAStatusUpdateTriggerHandler
{
    public static void Execute_AI(list<ICAStatusUpdate__e> triggerNew)
    {
        list<HexaBPM__SR_Steps__c> srStepUSD = [SELECT Id, HexaBPM__Summary__c, HexaBPM__Step_No__c, HexaBPM__Start_Status__c, HexaBPM__Step_Template__c
                                                    FROM HexaBPM__SR_Steps__c 
                                                    WHERE HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c = 'Initial_Approval'  
                                                    AND HexaBPM__Step_Template_Code__c = 'Update Signatory Details'];
                                                    
        list<HexaBPM__SR_Steps__c> srStep =  [SELECT Id, HexaBPM__Summary__c, HexaBPM__Step_No__c, HexaBPM__Start_Status__c, HexaBPM__Step_Template__c
                                             FROM HexaBPM__SR_Steps__c 
                                            WHERE HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c = 'Initial_Approval' 
                                            AND HexaBPM__Step_Template_Code__c = 'Download Initial Approval Copy'];
    
    
        list<HexaBPM__Step__c> srStepslist = new list<HexaBPM__Step__c>();
        for(ICAStatusUpdate__e ev : triggerNew)
        {
            if(!String.isEmpty(ev.RecordId__c) && !String.isEmpty(ev.Status__c))
            {
                if(!srStep.isEmpty() && ev.Status__c == '1'){//If Approved.
                    HexaBPM__Step__c newStep            = new HexaBPM__Step__c();
                    newStep.HexaBPM__Step_No__c         = srStep[0].HexaBPM__Step_No__c;
                    newStep.HexaBPM__SR_Step__c         = srStep[0].Id; 
                    newStep.HexaBPM__Summary__c         = srStep[0].HexaBPM__Summary__c;
                    newStep.HexaBPM__Status__c          = system.label.ICA_AwaitingCopyDownload ;//srStep[0].HexaBPM__Start_Status__c;
                    newStep.HexaBPM__SR__c              = ev.RecordId__c;
                    newStep.OwnerId                     = system.Label.System_Queue_Id;
                    newStep.HexaBPM__Step_Template__c   = srStep[0].HexaBPM__Step_Template__c;
                    newStep.HexaBPM__Start_Date__c      = Date.today();
                    newStep.HexaBPM__Due_Date__c        = system.today();
                    newStep.HexaBPM__Sys_Step_Loop_No__c = string.valueof(srStep[0].HexaBPM__Step_No__c)+'_1';
                    srStepslist.add(newStep);
               }
               if(!srStepUSD.isEmpty() && ev.Status__c == '2'){//If rejected..
                    HexaBPM__Step__c newStep            = new HexaBPM__Step__c();
                    newStep.HexaBPM__Step_No__c         = srStepUSD[0].HexaBPM__Step_No__c;
                    newStep.HexaBPM__SR_Step__c         = srStepUSD[0].Id; 
                    newStep.HexaBPM__Summary__c         = srStepUSD[0].HexaBPM__Summary__c;
                    newStep.HexaBPM__Status__c          = srStepUSD[0].HexaBPM__Start_Status__c;
                    newStep.HexaBPM__SR__c              = ev.RecordId__c;
                    newStep.OwnerId                     = system.Label.Government_Services_Queue_Id;
                    newStep.HexaBPM__Step_Template__c   = srStepUSD[0].HexaBPM__Step_Template__c;
                    newStep.HexaBPM__Start_Date__c      = Date.today();
                    newStep.HexaBPM__Due_Date__c        = system.today();
                    newStep.HexaBPM__Sys_Step_Loop_No__c = string.valueof(srStepUSD[0].HexaBPM__Step_No__c)+'_1';
                    srStepslist.add(newStep);
               }
            }
        }
        if(!srStepslist.isEmpty())
            insert srStepslist;
        }
}