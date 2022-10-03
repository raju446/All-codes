/*
    Author      : Azmath
    Date        : 26-Jun-2018
    Description : Batch Class to delete duplicate Inital approvals.
    -------------------------------------------------------------------------------------------
*/
global without sharing class Batch_DeleteInactiveInitialApprovals implements Database.Batchable<sObject>
{
    global list<sObject> start(Database.BatchableContext BC){
        Id cidRectypeId;
        list<Account> acclist = new list<Account>();
        if(Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company')!=null && Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company').getRecordTypeId()!=null)
        {
            cidRectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company').getRecordTypeId();
            acclist = [Select id,
                            (SELECT Id,CreatedDate,Name FROM HexaBPM__Service_Requests__r WHERE HexaBPM__Record_Type_Name__c = 'Initial_Approval'
                             AND HexaBPM__IsCancelled__c <> TRUE 
                             AND HexaBPM__Is_Rejected__c <> TRUE 
                             AND HexaBPM__IsClosedStatus__c <> TRUE 
                             AND HexaBPM__External_Status_Name__c = 'Submitted'  
                             ORDER BY CreatedDate DESC)
                        FROM Account where Recordtypeid=:cidRectypeId ];
        }
        system.debug('====='+acclist[0]);
        return acclist;
    }
    global void execute(Database.BatchableContext BC,list<Account> acclist)
    {
        list<HexaBPM__Service_Request__c> SrsToBeDeleted = new list<HexaBPM__Service_Request__c>();
        if(!acclist.isEmpty() )
        {
            
            for(Account acc:acclist)
            {
                system.debug('=====sss====='+acc.HexaBPM__Service_Requests__r);
                if(acc.HexaBPM__Service_Requests__r != null && acc.HexaBPM__Service_Requests__r.size() > 1)
                {
                    Integer i=0;
                    DateTime LatestSRdatetime;
                    for(HexaBPM__Service_Request__c sr : acc.HexaBPM__Service_Requests__r)
                    {
                        if(i == 0)
                            LatestSRdatetime = sr.CreatedDate;
                        if(i != 0 && sr.createdDate < LatestSRdatetime)
                        {
                            system.debug('====='+sr.Name);
                            SrsToBeDeleted.add(sr);
                        }
                        i++;
                    }
                }
            }
        }
        if(!SrsToBeDeleted.isEmpty())
            Delete SrsToBeDeleted;
    }
    global void finish(Database.BatchableContext BC){
        
    }
}