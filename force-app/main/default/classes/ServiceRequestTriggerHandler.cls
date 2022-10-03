/*********************************************************
    *   Author      :   Durga Prasad
    *   Company     :   PwC
    *   Date        :   05-Nov-2017
    *   Description :   Handler class for the Service Request Trigger.
    
    * * --------------------------------------------------------------------------------------
    * * @Change History
    * Version    Author             Date            Description
      v1.2       Durga Kandula      15/08/2019      New Method to execute the logic on After Insert
      
 *********************************************************/
public without sharing class ServiceRequestTriggerHandler{
    public static void Execute_BI(list<HexaBPM__Service_Request__c> lstSR){
        ServiceRequestTriggerHelper.ValidateResidenceVisaPassport(lstSR);
        ServiceRequestTriggerHelper.PopulateCreatedByLookup(lstSR);
        ServiceRequestTriggerHelper.PopulateGovernmentAuthorityLookup(lstSR);
        ServiceRequestTriggerHelper.PopulateNationalityLookup(lstSR,null,true);
        //ServiceRequestTriggerHelper.PopulateSponsorDetails(lstSR,true);
        ServiceRequestTriggerHelper.AutoPopulateContactFields(lstSR,null,true);
        //ServiceRequestTriggerHelper.validateVisaPeriod(lstSR);
        ServiceRequestTriggerHelper.ValidateSR(lstSR);
        ServiceRequestTriggerHelper.checkEmployeeStatus(lstSR);//ISSUE-000668
        ServiceRequestTriggerHelper.beforeInsert(lstSR);
    }
    public static void Execute_AI(list<HexaBPM__Service_Request__c> TriggerNew){
        ServiceRequestTriggerHelper.DeleteDuplicateInitialApprovals(TriggerNew);
    }
    public static void Execute_BU(map<Id,HexaBPM__Service_Request__c> TriggerOld,list<HexaBPM__Service_Request__c> TriggerNew){
        //Code to populate the closed date on SR closure
        for(HexaBPM__Service_Request__c SR : TriggerNew){
            if(SR.HexaBPM__IsClosedStatus__c)
                SR.HexaBPM__Closed_Date_Time__c = system.now();
        }
        ServiceRequestTriggerHelper.PopulateGovernmentAuthorityLookup(TriggerNew);
        ServiceRequestTriggerHelper.CalculateFines(TriggerOld,TriggerNew);
        //ServiceRequestTriggerHelper.CreatePOBoxPriceItems(TriggerNew,TriggerOld);
        ServiceRequestTriggerHelper.PopulateNationalityLookup(TriggerNew,TriggerOld,false);
        //ServiceRequestTriggerHelper.PopulateSponsorDetails(TriggerNew,false);
        ServiceRequestTriggerHelper.AutoPopulateContactFields(TriggerNew,TriggerOld,false);
        //ServiceRequestTriggerHelper.validateVisaPeriod(TriggerNew);
        ServiceRequestTriggerHelper.checkEmployeeStatus(TriggerNew);//ISSUE-000668
    }
    public static void Execute_AU(map<Id,HexaBPM__Service_Request__c> TriggerOld,list<HexaBPM__Service_Request__c> TriggerNew){
        //ServiceRequestTriggerHelper.CreatePOBoxPriceItems(TriggerNew,TriggerOld);
    }
}