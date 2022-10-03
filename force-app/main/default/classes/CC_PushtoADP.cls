/*
@Author : Azmath
@Description : This class is used to invoke the ADP services from SR Template to automatially submit the request..
@Version : v1.
*/
global without sharing class CC_PushtoADP implements HexaBPM.iCustomCodeExecutable
{
     global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.Id!=null && step.HexaBPM__SR__c!=null)
        {
            list<HexaBPM__Service_Request__c> srlist = [SELECT id, ADP_Record_Type__c, Recordtype.DeveloperName, Reason_of_Cancellation__c, HexaBPM__Parent_SR__c, HexaBPM__Parent_SR__r.Recordtype.DeveloperName 
                                                        FROM HexaBPM__Service_Request__c WHERE ID=:step.HexaBPM__SR__c];
            string rtype = srlist[0].ADP_Record_Type__c;                                            
            if(srlist[0].Recordtype.DeveloperName == 'ADGM_Permit_Amendment_Service_Request' && srlist[0].Reason_of_Cancellation__c != null && srlist[0].Reason_of_Cancellation__c != '')
            {
                Id cancelSRID;
                list<HexaBPM__Service_Request__c> lastestAmendSR = [Select id from HexaBPM__Service_Request__c where 
                                                HexaBPM__Parent_SR__c=:srlist[0].HexaBPM__Parent_SR__c and ID !=:srlist[0].id order by CreatedDate DESC limit 1];
                
                if(!lastestAmendSR.isEmpty()){
                    cancelSRID = lastestAmendSR[0].id;
                }else{
                    cancelSRID = srlist[0].HexaBPM__Parent_SR__c;
                }
                
                string doctoCancel;
                if(rtype == 'Temporary_Fit_Out_Security_Clearance'){
                    doctoCancel = 'Temporary Fit Out Security Clearance Permit';
                }else if(rtype == 'Permit_Alcohol' || rtype == 'Renew_Alcohol_Permit'){
                    doctoCancel = 'Alcohol Permit';
                }else if(rtype == 'Permit_Entertainment'){
                    doctoCancel = 'Entertainment Permit';
                }else if(rtype == 'Extended_Operating_Hours'){
                    doctoCancel = 'Extended Business Hours Permit';
                }
                for(HexaBPM__SR_Doc__c srdoc : [Select id from HexaBPM__SR_Doc__c where Name=:doctoCancel and HexaBPM__Service_Request__c=:cancelSRID  limit 1])
                {
                    srdoc.HexaBPM__Status__c='Cancelled';
                    update srdoc;
                }
                HexaBPM__Service_Request__c cancelSR = [Select id , Cancellation_Comment__c from HexaBPM__Service_Request__c where id=:cancelSRID];
                cancelSR.Cancellation_Comment__c = '5';
                update cancelSR;
                
                CC_AutoCloseStep cc = new CC_AutoCloseStep();
                cc.EvaluateCustomCode(sr,step);
                pushtoADP_Future(rtype,cancelSRID,null);
                
            }
            else{
                pushtoADP_Future(rtype,srlist[0].id,null);
            
            }         
            
        }
        return null;
     }
     @Future(callout=true)
     public static void pushtoADP_Future(string rectype, Id srid, Id paretnsr)
     {
        ADP_RestServicesHelper.invokeADPService(rectype, srid, paretnsr);
     }
}