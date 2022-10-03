public without sharing class ICA_StatusUpdateQueue implements Queueable
{
    public string status;
    public Id srID;
    public ICA_StatusUpdateQueue(string sts,Id sid)
    {
        this.status = sts;
        this.srID = sid;
    }
    public void execute(QueueableContext context)
    {
        list<HexaBPM__SR_Steps__c> srStepUSD = [SELECT Id, HexaBPM__Summary__c, HexaBPM__Step_No__c, HexaBPM__Start_Status__c, HexaBPM__Step_Template__c
                                                    FROM HexaBPM__SR_Steps__c 
                                                    WHERE HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c = 'Initial_Approval'  
                                                    AND HexaBPM__Step_Template_Code__c = 'Update Signatory Details'];
                                                    
        list<HexaBPM__SR_Steps__c> srStep =  [SELECT Id, HexaBPM__Summary__c, HexaBPM__Step_No__c, HexaBPM__Start_Status__c, HexaBPM__Step_Template__c
                                             FROM HexaBPM__SR_Steps__c 
                                            WHERE HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c = 'Initial_Approval' 
                                            AND HexaBPM__Step_Template_Code__c = 'Download Initial Approval Copy'];
                                            
        if(!string.isEmpty(status) && !string.isEmpty(srID))
        {
            list<HexaBPM__Step__c> srStepslist = new list<HexaBPM__Step__c>();
            if(!srStep.isEmpty() && status == '1'){//If Approved.
                HexaBPM__Step__c newStep            = new HexaBPM__Step__c();
                newStep.HexaBPM__Step_No__c         = srStep[0].HexaBPM__Step_No__c;
                newStep.HexaBPM__SR_Step__c         = srStep[0].Id; 
                newStep.HexaBPM__Summary__c         = srStep[0].HexaBPM__Summary__c;
                newStep.HexaBPM__Status__c          = system.label.ICA_AwaitingCopyDownload ;//srStep[0].HexaBPM__Start_Status__c;
                newStep.HexaBPM__SR__c              = srID;
                newStep.OwnerId                     = system.Label.System_Queue_Id;
                newStep.HexaBPM__Step_Template__c   = srStep[0].HexaBPM__Step_Template__c;
                newStep.HexaBPM__Start_Date__c      = Date.today();
                newStep.HexaBPM__Due_Date__c        = system.today();
                newStep.HexaBPM__Sys_Step_Loop_No__c = string.valueof(srStep[0].HexaBPM__Step_No__c)+'_1';
                srStepslist.add(newStep);
            }
            if(!srStepUSD.isEmpty() && status == '2'){//If rejected..
                HexaBPM__Step__c newStep            = new HexaBPM__Step__c();
                newStep.HexaBPM__Step_No__c         = srStepUSD[0].HexaBPM__Step_No__c;
                newStep.HexaBPM__SR_Step__c         = srStepUSD[0].Id; 
                newStep.HexaBPM__Summary__c         = srStepUSD[0].HexaBPM__Summary__c;
                newStep.HexaBPM__Status__c          = srStepUSD[0].HexaBPM__Start_Status__c;
                newStep.HexaBPM__SR__c              = srID;
                newStep.OwnerId                     = system.Label.Government_Services_Queue_Id;
                newStep.HexaBPM__Step_Template__c   = srStepUSD[0].HexaBPM__Step_Template__c;
                newStep.HexaBPM__Start_Date__c      = Date.today();
                newStep.HexaBPM__Due_Date__c        = system.today();
                newStep.HexaBPM__Sys_Step_Loop_No__c = string.valueof(srStepUSD[0].HexaBPM__Step_No__c)+'_1';
                srStepslist.add(newStep);
            }
            if(!srStepslist.isEmpty())
                insert srStepslist;
            if(srStepslist[0].id != null && status == '1')
            {
                srStepslist[0].HexaBPM__Status__c = system.label.ICA_DownloadCopy;
                update srStepslist;
                
                if(!test.isRunningTest()){
                    ICA_DownloadIACopyQueue que = new ICA_DownloadIACopyQueue(srID);
                    system.enqueueJob(que);
                }
            }
        }
    }
}