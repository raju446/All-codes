/*
     * @Change History
    * Author            Version     Date            Description
    Rajil Ravindran     V1.1        01-08-2019      Case Bypass assignment checkbox added to skip/fire the assignment rules using CRM_Bypass_Assignment_Rule__c
*/
public without sharing class CaseTriggerHelper{
    Public static boolean OwnerChangeFromButton = true;
    public static boolean assignmentRule = true;
    
  
    public static void invokeAssignmentRulesInsert(List<Case> caseList){
        Database.DMLOptions caseAssignmentRuleOptions = new Database.DMLOptions();
        caseAssignmentRuleOptions.assignmentRuleHeader.useDefaultRule = true;
        
        Set<Id> caseIds = new Set<Id>();
        for(Case objCase : caseList){
            caseIds.add(objCase.Id);
        }
        
        List<Case> caseToUpdate = new List<Case>();
        for(Case objCase : [SELECT Id,CRM_Bypass_Assignment_Rule__c,CRM_Case_Original_Owner_Id__c,OwnerId FROM Case WHERE Id IN: caseIds]){
            if(objCase.CRM_Bypass_Assignment_Rule__c == false){ //V1.1
                objCase.setOptions(caseAssignmentRuleOptions);
            }/*else{
                system.debug('##ORIGINAL: '+objCase.OwnerId);
                objCase.CRM_Case_Original_Owner_Id__c = objCase.OwnerId;
            }*/
            objCase.CRM_Bypass_Assignment_Rule__c = false; 
            caseToUpdate.add(objCase);
        }
        if(!caseToUpdate.isEmpty() && assignmentRule){
            system.debug('@@case_to_update: '+caseToUpdate);
            assignmentRule = false;
            update caseToUpdate;
        }
    }
    
    public static void invokeAssignmentRulesInsert(List<Case> caseList, Map<Id,Case> caseOldMap){
        Database.DMLOptions caseAssignmentRuleOptions = new Database.DMLOptions();
        caseAssignmentRuleOptions.assignmentRuleHeader.useDefaultRule = true;
        
        Set<Id> caseIds = new Set<Id>();
        for(Case objCase : caseList){
            if(objCase.Type != caseOldMap.get(objCase.Id).Type || objCase.CRM_Department__c != caseOldMap.get(objCase.Id).CRM_Department__c
                 || objCase.CRM_Sub_Department__c != caseOldMap.get(objCase.Id).CRM_Sub_Department__c
                 || objCase.CRM_Bypass_Assignment_Rule__c != caseOldMap.get(objCase.Id).CRM_Bypass_Assignment_Rule__c){

                    caseIds.add(objCase.Id);
            }
        }
        
        List<Case> caseToUpdate = new List<Case>();
        for(Case objCase : [SELECT Id,CRM_Bypass_Assignment_Rule__c FROM Case WHERE Id IN: caseIds]){
            if(objCase.CRM_Bypass_Assignment_Rule__c == false) //V1.1
                objCase.setOptions(caseAssignmentRuleOptions);
            objCase.CRM_Bypass_Assignment_Rule__c = false;
            caseToUpdate.add(objCase);
        }
        if(!caseToUpdate.isEmpty() && assignmentRule){
            assignmentRule = false;
            update caseToUpdate;
        }
    }
    
    public static void closingCaseValidation(List<Case> newCaseList, Map<Id,Case> caseOldMap){
        Set<Id> caseIds = new Set<Id>();
        for(Case objCase : newCaseList){
            if((objCase.Status != caseOldMap.get(objCase.Id).Status) && objCase.Status == 'Closed' && objCase.Origin != 'ACCESSADGM Portal Case' && objCase.Origin != 'Email') {
                caseIds.add(objCase.Id);
            }
        }
        
        Map<Id, Integer> caseActMap = new Map<Id, Integer>();
        for(Case objCase : [SELECT Id,(Select WhatId,Status FROM Tasks WHERE Status <> 'Completed' AND CRM_Internal_Task__c = true) FROM Case WHERE Id IN :caseIds]){
            Integer ctr = 0;
            if(objCase.Tasks != null){
                ctr = objCase.Tasks.size();
            }
            caseActMap.put(objCase.Id,ctr);
        }
        
        for(Case objCase : newCaseList){
            if(caseActMap.containskey(objCase.Id)){
                if(caseActMap.get(objCase.Id) > 0){
                    objCase.addError('Please close the open tasks before closing the case.');
                }
            }
        }
    }
}