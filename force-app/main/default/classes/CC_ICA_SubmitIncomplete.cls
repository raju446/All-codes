global without sharing class CC_ICA_SubmitIncomplete implements HexaBPM.iCustomCodeExecutable 
{
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) 
    {
        string strResult = 'Success';
        if(step.Id!=null && step.HexaBPM__SR__c!=null)
        {
            CC_ICA_SubmitIncomplete.pushtoICA_Future(step.HexaBPM__SR__c);
        }
        return null;
     }
     
     @Future(callout=true)
     public static void pushtoICA_Future(Id srId)
     {
        ICA_CreateUpdateEstablishmentUtil.invokesubmitIncompleteservice(srId);
     }
}