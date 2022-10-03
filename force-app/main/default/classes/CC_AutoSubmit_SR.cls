/*
    Author      : Durga Prasad
    Date        : 13-Nov-2017
    Description : Custom code to Auto-Submit the Service Request
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_AutoSubmit_SR implements hexabpm.iAutoSubmissionExecutable{
    global String AutoSubmit_SR(set<id> setSRIds,string SubmittedStatusId) {
        String msg = 'Success';
        try{
            AutoSubmitSR_Future(setSRIds,SubmittedStatusId);
        }catch(Exception e){
            msg = e.getMessage();
        }
        return msg;
    }
    @future
    public static void AutoSubmitSR_Future(set<id> setSRIds,string SubmittedStatusId){
        list<HexaBPM__Service_Request__c> lstSRTBS = new list<HexaBPM__Service_Request__c>();
        for(string SRID : setSRIds){
            HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c(Id=SRID);
            objSR.HexaBPM__Auto_Submit__c = false;
            objSR.HexaBPM__Submitted_Date__c = system.today();
            objSR.HexaBPM__Submitted_DateTime__c = system.now();
            objSR.HexaBPM__Internal_SR_Status__c = SubmittedStatusId;
            objSR.HexaBPM__External_SR_Status__c = SubmittedStatusId;
            objSR.HexaBPM__FinalizeAmendmentFlg__c = true;
            lstSRTBS.add(objSR);
            system.debug('-----'+objSR.HexaBPM__Internal_SR_Status__c +'----'+objSR.HexaBPM__External_SR_Status__c);
        }
        if(lstSRTBS.size()>0)
            update lstSRTBS;
    
    }
}