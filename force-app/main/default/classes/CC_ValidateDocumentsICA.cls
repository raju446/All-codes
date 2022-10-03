global without sharing class CC_ValidateDocumentsICA implements HexaBPM.iCustomCodeExecutable
{
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step)
    {
        string strResult = 'Success';
        if(step.Id!=null && step.HexaBPM__SR__c!=null)
        {
            list<HexaBPM__Service_Request__c> srdraftno = [Select Draft_Number__c FROM HexaBPM__Service_Request__c WHERE ID=:step.HexaBPM__SR__c];
            system.debug('===draftno=='+srdraftno);
            if(!srdraftno.isEmpty() && srdraftno[0].Draft_Number__c == null){
                strResult = 'It seems application is not submitted yet as the Draft Number is emtpy, please note that application submission will take few seconds to process.';
                strResult += 'Please contact system administrator for assistance.';
                return strResult;
            } 
            
            list<ICA_Document__c> reqdocsnotuploaded = [Select id from ICA_Document__c where Is_Attachment_Mandatory__c=true and 
                Is_Document_Uploaded__c=false and Service_Request__c=:step.HexaBPM__SR__c limit 1];
            if(!reqdocsnotuploaded.isEmpty()){
                strResult = 'Please upload the required ICA documents and close the step.';
            }
        }
        return strResult;
    }    
}