global without sharing class CC_Step_Assignment implements HexaBPM.iStepAssignmentExecutable {

    //Assigns owner for the first step that is created on SR submit 
    global List < HexaBPM__Step__c > Assign_Step_Owner_SR_Submit(Map < String, HexaBPM__Service_Request__c > MapSRs, list < HexaBPM__Step__c > lstSteps, Map < String, HexaBPM__SR_Steps__c > MapSRSteps) {
        return lstSteps;
    }
    global list < HexaBPM__Step__c > Assign_Step_Owner_Step_Closure(Map < String, HexaBPM__Step__c > MapSteps, list < HexaBPM__Step__c > lstSteps, Map < String, HexaBPM__SR_Steps__c > MapSRSteps) {
        return lststeps;
    }
}