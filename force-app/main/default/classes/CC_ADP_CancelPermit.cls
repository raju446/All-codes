/*
@Author : Azmath
@Version : v1.
*/
global without sharing class CC_ADP_CancelPermit implements HexaBPM.iCustomCodeExecutable 
{
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SRi, HexaBPM__Step__c step) 
    {
        if(step.Id!=null && step.HexaBPM__SR__c!=null)
        {
            string fetchdatafrom='';
            HexaBPM__Service_Request__c amendmentSR = [Select id, Start_Date__c, End_Date__c, Location__c, Location_Arabic__c, HexaBPM__Parent_SR__c,ADP_Record_Type__c  
                                                        FROM HexaBPM__Service_Request__c where id=:step.HexaBPM__SR__c limit 1];
                            
            list<HexaBPM__Service_Request__c> lastestAmendSR = [Select id from HexaBPM__Service_Request__c where 
                                                HexaBPM__Parent_SR__c=:amendmentSR.HexaBPM__Parent_SR__c and ID !=:amendmentSR.id order by CreatedDate DESC limit 1];
            
            if(!lastestAmendSR.isEmpty()){
                fetchdatafrom = lastestAmendSR[0].id;
            }else{
                fetchdatafrom = amendmentSR.HexaBPM__Parent_SR__c;
            }
            string rectype = amendmentSR.ADP_Record_Type__c;
            string doctoCancel;
            
            if(rectype == 'Temporary_Fit_Out_Security_Clearance'){
                doctoCancel = 'Temporary Fit Out Security Clearance Permit';
            }else if(rectype == 'Permit_Alcohol' || rectype == 'Renew_Alcohol_Permit'){
                doctoCancel = 'Alcohol Permit';
            }else if(rectype == 'Permit_Entertainment'){
                doctoCancel = 'Entertainment Permit';
            }else if(rectype == 'Extended_Operating_Hours'){
                doctoCancel = 'Extended Business Hours Permit';
            }
            
            //Cancel permit of parent sr.
            for(HexaBPM__SR_Doc__c srdoc : [Select id from HexaBPM__SR_Doc__c where Name=:doctoCancel and HexaBPM__Service_Request__c=:fetchdatafrom  limit 1])
            {
                srdoc.HexaBPM__Status__c='Cancelled';
                update srdoc;
            }
            HexaBPM__Service_Request__c  cancelSR = [Select id from HexaBPM__Service_Request__c where id=:fetchdatafrom];
            cancelSR.Cancellation_Comment__c = '5';
            update cancelSR;
            //CC_PushtoADP  cc = new CC_PushtoADP ();
            CC_PushtoADP.pushtoADP_Future(rectype,fetchdatafrom,null);
        }
        return null;
    }  
}