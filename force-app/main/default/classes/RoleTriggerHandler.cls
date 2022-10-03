/*
    Author      : Kim Noceda
    Date        : 11-Apr-2018
    Description : Trigger Handler for Role Object
    --------------------------------------------------------------------------------------
*/
public without sharing class RoleTriggerHandler {
    public static void Execute_BI(list<Role__c> TriggerNew){
        
    }
    public static void Execute_AI(list<Role__c> TriggerNew){
        if(Label.Allow_CID_Approval_Role == 'true'){
            RoleTriggerHelper.InitiateCIDApproval(TriggerNew,null,true);
        }
    }
    public static void Execute_BU(list<Role__c> TriggerNew,map<Id,Role__c> TriggerOldMap){
        
    }
    public static void Execute_AU(list<Role__c> TriggerNew,map<Id,Role__c> TriggerOldMap){
        if(Label.Allow_CID_Approval_Role == 'true'){
            RoleTriggerHelper.InitiateCIDApproval(TriggerNew,TriggerOldMap,false);
        }
    }
}