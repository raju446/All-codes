/*
    Author      : Durga Prasad
    Date        : 31-Mar-2018
    Description : Custom code to Close the open Step on approval of customer cancellation step
    -------------------------------------------------------------------------------------------
*/
global without sharing class CC_Cancel_OpenSteps implements hexabpm.iCustomCodeExecutable{
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c stp) {
        string strResult = 'Success';
        list<HexaBPM__Step__c> lstOpenSteps = new list<HexaBPM__Step__c>();
        if(stp.HexaBPM__SR__c!=null){
            string CancelStatus;
            for(HexaBPM__Status__c status:[Select Id,HexaBPM__Code__c from HexaBPM__Status__c where HexaBPM__Code__c='CANCELLED_BY_CUSTOMER' and HexaBPM__Type__c='End']){
                CancelStatus = status.Id;
            }
            try{
                if(CancelStatus==null){
                    HexaBPM__Status__c objStepStatus = new HexaBPM__Status__c();
                    objStepStatus.Name = 'Cancelled By Customer';
                    objStepStatus.HexaBPM__Code__c = 'CANCELLED_BY_CUSTOMER';
                    objStepStatus.HexaBPM__Type__c = 'End';
                    upsert objStepStatus HexaBPM__Code__c;
                    CancelStatus = objStepStatus.Id;
                }
                if(CancelStatus!=null){
                    list<HexaBPM__Step__c> lstSteps = new list<HexaBPM__Step__c>();
                    for(HexaBPM__Step__c step:[Select Id,HexaBPM__Status__c from HexaBPM__Step__c where HexaBPM__SR__c=:stp.HexaBPM__SR__c and Id!=:stp.Id and HexaBPM__Status_Type__c!='End']){
                        step.HexaBPM__Status__c = CancelStatus;
                        step.HexaBPM__Closed_Date__c = system.today();
                        step.HexaBPM__Closed_Date_Time__c = system.now();
                        lstSteps.add(step);
                    }
                    if(lstSteps.size()>0)
                        update lstSteps;
                }
            }catch(DMLException e){
                string DMLError = e.getdmlMessage(0)+'';
                if(DMLError==null){
                    DMLError = e.getMessage()+'';
                }
                strResult = DMLError;
            }
        }
        return strResult;
    }
}