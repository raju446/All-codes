/*
    Author      : Kim Noceda
    Company     : PwC
    Date        : 24-Apr-2018
    Description : Utility class with generic methods for Custom codes
    -------------------------------------------------------------------------
*/
public without sharing class CustomCodeCodeUtility{
    
    @future
    public static void closeOpenActionItems(Id objSRId,list<string> lstStepsToExclude){
        
        system.debug('##SR_ID: '+objSRId);
        if(lstStepsToExclude==null)
            lstStepsToExclude = new list<string>();
        list<HexaBPM__Status__c> cancelledStep = [SELECT Id FROM HexaBPM__Status__c WHERE HexaBPM__Code__c = 'CANCELLED' LIMIT 1];
        system.debug('##CANCELLED_STEP: '+cancelledStep);
        List<HexaBPM__Step__c> updateOpenStepList = new List<HexaBPM__Step__c>();
        for(HexaBPM__Step__c objStep : [SELECT Id, HexaBPM__Status__c FROM HexaBPM__Step__c WHERE HexaBPM__SR__c = :objSRId AND Id NOT IN:lstStepsToExclude and HexaBPM__Status__r.HexaBPM__Type__c != 'End']){
            if(!cancelledStep.isEmpty()){
                objStep.HexaBPM__Status__c = cancelledStep[0].Id;
                updateOpenStepList.add(objStep);
            }
        }
        
        system.debug('##STEPLIST: '+updateOpenStepList);
        
        if(!updateOpenStepList.isEmpty()){
            try{
                update updateOpenStepList;
            } catch(Exception e){
                
            }
        }
    }
}