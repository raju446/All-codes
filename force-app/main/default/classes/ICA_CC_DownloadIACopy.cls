global without sharing class ICA_CC_DownloadIACopy implements HexaBPM.iCustomCodeExecutable
{
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) 
    {
        string strResult = 'Success';
        if(step.Id!=null && step.HexaBPM__SR__c!=null)
        {
            downloadcopy(step.HexaBPM__SR__c);
        }
        return null;
    }
    
    @Future(callout=true)
    public static void downloadcopy(Id srId)
    {
        list<HexaBPM__Service_Request__c> rectype = [Select Recordtype.developername from HexaBPM__Service_Request__c where id=:srId];
        if(!rectype.isEmpty()){
            if(rectype[0].Recordtype.developername == 'Initial_Approval'){
                ICA_EstablishmentCardUtil.invokePrintIACopyapi(srId); 
            }else{
                ICA_EstablishmentCardUtil.invokePrintEstbCardCopyapi(srId);
            }
        }
    }
}