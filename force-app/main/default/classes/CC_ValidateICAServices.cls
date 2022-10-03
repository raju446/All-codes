global without sharing class CC_ValidateICAServices implements HexaBPM.iCustomCodeExecutable 
{
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) 
    {
        string strResult = 'Success';
         if(step.Id!=null && step.HexaBPM__SR__c!=null)
         {
            list<HexaBPM__Service_Request__c> srs = [Select id, HexaBPM__Customer__c from HexaBPM__Service_Request__c where id=:step.HexaBPM__SR__c];
            if(!srs.isEmpty()){
                string msg = ICA_ValidateService.validateRoles(srs[0].HexaBPM__Customer__c,step.HexaBPM__SR__c);
                if(msg != ''){
                    strResult = msg;
                }
            }
         }
         return strResult;
    }
}