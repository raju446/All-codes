/*
    Author      : Durga Prasad
    Company     : PwC
    Date        : 28-Aug-2018
    Description : Opportunity Trigger Handler
    -------------------------------------------------------------------------
    * @Change History
    * Author       Date            Description
    *
    * CRM SUpport  12/04/2020    Added method to populate the Application ID at the related account level
     
*/
public without sharing class OpportunityTriggerHandler {
    public static void Execute_AI(list<Opportunity> TriggerNew){
        list<Opportunity_Stage_Lifecycle__c> lstNewSLAs = new list<Opportunity_Stage_Lifecycle__c>();
        for(Opportunity Opp:TriggerNew){
            Opportunity_Stage_Lifecycle__c obj = new Opportunity_Stage_Lifecycle__c();
            obj.Parent__c = Opp.Id;
            obj.Change_Type__c = 'Stage';
            obj.From__c = system.now();
            obj.Stage__c = Opp.StageName;
            //obj.Owner__c = Opp.Owner_Name__c;
            obj.Business_Hours_Id__c = label.HexaBPM.Business_Hours_Id;
            lstNewSLAs.add(obj);
        }
        if(lstNewSLAs.size()>0)
            insert lstNewSLAs;
    }
    public static void Execute_AU(list<Opportunity> TriggerNew,map<Id,Opportunity> TriggerOldMap){
            CreateOpportunityStageSLA(TriggerNew,TriggerOldMap);
            //CRM Support
            populatePreApplicationNumber(TriggerNew,TriggerOldMap);
         }
    
    /**
    * populatePreApplicationNumber
    * 
    * Introduced in CRM Support 
    * This method is supposed to be called from after update trigger
    * The method will be used to populate the CRM_Pre_Approval_Id__c on related account when the Pre_Application_Number__c field is updated on Opportunity
    *
    * @param  TriggerNew    List of Opportunity (Trigger.New)
    * @param  TriggerOldMap Old Opportunities Map to validate value change
    *
    * @return void
    */
    public static void populatePreApplicationNumber(list<Opportunity> TriggerNew,map<Id,Opportunity> TriggerOldMap){
        list<Account> accToUpdate = new list<Account>();
        for(Opportunity opty : TriggerNew){
            if(opty.Pre_Application_Number__c!=null && opty.Pre_Application_Number__c != TriggerOldMap.get(opty.Id).Pre_Application_Number__c ){
                accToUpdate.add(new Account(Id=opty.AccountId,CRM_Pre_Approval_Id__c=opty.Pre_Application_Number__c ));
            }
        }
        if(!accToUpdate.isEmpty()){
            update accToUpdate;
        }
    }
    
    public static void CreateOpportunityStageSLA(list<Opportunity> TriggerNew,map<Id,Opportunity> TriggerOldMap){
        
        set<string> setOwnerChangeCaseIds = new set<string>();
        set<string> setStatusChangeCaseIds = new set<string>();
        map<string,string> mapClosedOppSLAs = new map<string,string>();
        list<Opportunity_Stage_Lifecycle__c> lstNewSLAs = new list<Opportunity_Stage_Lifecycle__c>();
        
        map<string,SLA_Configuration__c> MapSLAMaster = new map<string,SLA_Configuration__c>();
        if(SLA_Configuration__c.getAll()!=null){
            for(SLA_Configuration__c SLA:SLA_Configuration__c.getAll().Values()){
                if(SLA.Queue_Name__c!=null && SLA.SLA_Hours__c!=null && SLA.Business_Hour_Id__c!=null && SLA.SLA_Minutes__c!=null)
                    MapSLAMaster.put(SLA.Queue_Name__c.toLowerCase(),SLA);
            }
        }
        system.debug('MapSLAMaster==>'+MapSLAMaster);
        map<string,Opportunity> MapCasesTBU = new map<string,Opportunity>();
        for(Opportunity Opp:TriggerNew){
            if(Opp.StageName!=TriggerOldMap.get(Opp.Id).StageName && Opp.isClosed){
                mapClosedOppSLAs.put(Opp.Id,Opp.Id);
            }
            if(Opp.StageName!=TriggerOldMap.get(Opp.Id).StageName){
                setStatusChangeCaseIds.add(Opp.Id);
                Opportunity_Stage_Lifecycle__c obj = new Opportunity_Stage_Lifecycle__c();
                obj.Parent__c = Opp.Id;
                obj.Change_Type__c = 'Stage';
                obj.From__c = system.now();
                obj.Stage__c = Opp.StageName;
                obj.Business_Hours_Id__c = label.HexaBPM.Business_Hours_Id;
                if(!Opp.isClosed){
                    lstNewSLAs.add(obj);
                }else{
                    obj.Until__c = system.now();
                    if(obj.Business_Hours_Id__c!=null)
                        obj.Calculated_Business_Minutes__c = BusinessHours.diff(obj.Business_Hours_Id__c,obj.From__c,obj.Until__c)/1000/60;
                    mapClosedOppSLAs.put(Opp.Id,Opp.Id);
                }
            }
        }
        if(setStatusChangeCaseIds!=null && setStatusChangeCaseIds.size()>0){
            for(Opportunity_Stage_Lifecycle__c sl:[Select Id,Business_Hours_Id__c,From__c,Until__c,Calculated_Business_Minutes__c from Opportunity_Stage_Lifecycle__c where Parent__c IN:setStatusChangeCaseIds and From__c!=null and Until__c=null and Change_Type__c='Stage']){
                sl.Until__c = system.now();
                if(sl.Business_Hours_Id__c!=null)
                    sl.Calculated_Business_Minutes__c = BusinessHours.diff(sl.Business_Hours_Id__c,sl.From__c,sl.Until__c)/1000/60;
                lstNewSLAs.add(sl);
            }
        }
        if(mapClosedOppSLAs!=null && mapClosedOppSLAs.size()>0){
            try{
                list<Opportunity_Stage_Lifecycle__c> openSLAs = new list<Opportunity_Stage_Lifecycle__c>();
                for(Opportunity_Stage_Lifecycle__c sla:[select Id,Until__c,Business_Hours_Id__c,From__c,Calculated_Business_Minutes__c from Opportunity_Stage_Lifecycle__c where Parent__c IN:mapClosedOppSLAs.keyset() and Until__c=null]){
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
                if(!ApexCodeUtility.OpportunityTriggerRecursive){
                    ApexCodeUtility.OpportunityTriggerRecursive = true;
                    Database.UpsertResult[] srList = Database.upsert(lstNewSLAs, false);
                    if(MapCasesTBU!=null && MapCasesTBU.size()>0)
                        update MapCasesTBU.values();
                }
            }catch(Exception e){
                TriggerNew[0].addError(e.getMessage()+'');
            }
        }
        
    }
}