/*
@Author : Azmath
@Description : This class is used to invoke the ICA services from SR Template to automatially submit the request..
@Version : v1.
*/
global without sharing class CC_PushtoICA implements HexaBPM.iCustomCodeExecutable
{
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step)
    {
        if(step.Id!=null && step.HexaBPM__SR__c!=null)
        {
            pushtoICA_Future(step.HexaBPM__SR__c);
        }
        return null;
    }
    
    @Future(callout=true)
     public static void pushtoICA_Future(Id srId)
     {
        list<HexaBPM__Service_Request__c> rectype = [Select Recordtype.DeveloperName from HexaBPM__Service_Request__c where id=:srId];
        if(rectype[0].Recordtype.DeveloperName == 'Initial_Approval')
            ICA_RestServicesUtil.invokeInitialApprovalService(srId);
        else if(rectype[0].Recordtype.DeveloperName == 'Establishment_Card_New' || rectype[0].Recordtype.DeveloperName == 'Establishment_Card_Renewal' 
                || rectype[0].Recordtype.DeveloperName == 'Establishment_Card_Amendment' || rectype[0].Recordtype.DeveloperName == 'Establishment_Card_Cancellation')
            ICA_CreateUpdateEstablishmentUtil.invokeEstbservice(srId);
     }
}