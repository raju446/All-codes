/*
@Author : Azmath
@Description : This class is used to invoke the ICA services(Payment) from SR Template to automatially submit the request..
@Version : v1.
*/
global without sharing class CC_PushPaymentReqtoICA implements HexaBPM.iCustomCodeExecutable
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
        ICA_RestServicesUtil.invokepaymentservice(srId);
     }
}