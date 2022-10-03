/*
@Author : Azmath
@Description : This class is used to create commercial license document under the SR doc of SR.So that ADP can download this doc via download document api.
@Version : v1.
*/
global without sharing class CC_ADP_CreateCommercialLicenseDoc implements HexaBPM.iCustomCodeExecutable
{
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step)
    {
        if(step.Id!=null && step.HexaBPM__SR__c!=null)
        {
            try{
                list<Attachment> att = [Select id, Name, Body, BodyLength, ContentType, Description FROM Attachment where ParentId =:step.HexaBPM__SR__r.HexaBPM__Customer__c and Name Like '%commercial%' 
                    order by CreatedDate DESC LIMIT 1];
                if(!att.isEmpty())
                {
                    HexaBPM__SR_Doc__c srdoc = new HexaBPM__SR_Doc__c(Name='Commercial License',HexaBPM__Service_Request__c=step.HexaBPM__SR__c,
                                    Available_to_ADP__c=true,HexaBPM__Status__c='Uploaded');
                    insert srdoc;
                    
                    Attachment at = new Attachment(Name=att[0].name,Body=att[0].Body,ContentType=att[0].ContentType,Description=att[0].Description,parentid=srdoc.id);
                    insert at;
                }
            }catch(Exception ex){
                System.debug('=====exception is ===='+ex.getMessage());
            }
        }
        return null;
    }
}