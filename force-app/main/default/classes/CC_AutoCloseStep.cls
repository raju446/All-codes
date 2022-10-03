/*
    Author      : Durga Prasad
    Date        : 18-Oct-2017
    Description : Custom code to Close the Current Step
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_AutoCloseStep implements HexaBPM.iCustomCodeExecutable {
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c stp) {
        string strResult = 'Success';
        HexaBPM__Step__c step = new HexaBPM__Step__c(Id=stp.Id);
        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c(Id=stp.HexaBPM__SR__c);
        for(HexaBPM__Step_Transition__c stptran : [select HexaBPM__SR_Status_Internal__c,HexaBPM__SR_Status_External__c,HexaBPM__Transition__r.HexaBPM__To__c,HexaBPM__Transition__r.HexaBPM__From__c
         from HexaBPM__Step_Transition__c where HexaBPM__Transition__c!=null and HexaBPM__SR_Step__c=:stp.HexaBPM__SR_Step__c and HexaBPM__Transition__r.HexaBPM__From__c=:stp.HexaBPM__Status__c and  HexaBPM__Transition__r.HexaBPM__To__r.HexaBPM__Type__c = 'End' limit 1
        ]){
            step.HexaBPM__Status__c = stptran.HexaBPM__Transition__r.HexaBPM__To__c;
            if(stptran.HexaBPM__SR_Status_Internal__c!=null)
            	objSR.HexaBPM__Internal_SR_Status__c = stptran.HexaBPM__SR_Status_Internal__c;
            if(stptran.HexaBPM__SR_Status_External__c!=null)
            	objSR.HexaBPM__External_SR_Status__c = stptran.HexaBPM__SR_Status_External__c;
            break;
        }
        try{
            update step;
            if(objSR.HexaBPM__Internal_SR_Status__c!=null || objSR.HexaBPM__External_SR_Status__c!=null)
            	update objSR;
        }catch(Exception e){
            strResult = e.getmessage()+'';
        }
        return strResult;
    }
}