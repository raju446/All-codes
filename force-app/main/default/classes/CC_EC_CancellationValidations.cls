/*
    Author      : Durga Prasad
    Date        : 17-Sep-2017
    Description : Custom code for EstablishmentCard Cancellation Validation
    -------------------------------------------------------------------------
*/
global without sharing class CC_EC_CancellationValidations implements HexaBPM.iCustomCodeExecutable {
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c stp) {
        string strResult = 'Success';
        if(stp!=null){
            boolean AllowedForCancellation = true;
            if(stp.HexaBPM__SR__c!=null && stp.HexaBPM__SR__r.HexaBPM__Customer__c!=null)
                AllowedForCancellation = CustomCodeUtilCls.HasActiveEmployees(stp.HexaBPM__SR__r.HexaBPM__Customer__c);
            if(!AllowedForCancellation)
                strResult = 'Please cancel the all Visa(s) before requesting for E-Channel Cancellation.';
        }
        return strResult;
    }
}