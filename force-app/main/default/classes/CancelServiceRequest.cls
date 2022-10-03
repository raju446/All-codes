/*
    Author      : Kim Noceda
    Date        : 24-Oct-2017
    Description : Class that creates a cancellation step.
                    Referenced in the Cancel SR custom button
    --------------------------------------------------------------------------------------
*/
global without sharing class CancelServiceRequest{
    
    //method to create cancel stepsunder the SR
    webservice static String createCancelStep(String srId){
        String resultStr = '';
        
        HexaBPM__Service_Request__c serviceRequest = [SELECT Id, HexaBPM__SR_Template__c FROM HexaBPM__Service_Request__c WHERE Id = :srId];
        
        //query on the SR Step cancelled related to the SR template
        List<HexaBPM__SR_Steps__c> srStep = [SELECT Id, HexaBPM__Summary__c, HexaBPM__Step_No__c, HexaBPM__Start_Status__c, HexaBPM__Step_Template__c
                                                FROM HexaBPM__SR_Steps__c 
                                                WHERE HexaBPM__SR_Template__c = :serviceRequest.HexaBPM__SR_Template__c 
                                                AND HexaBPM__Step_Template_Code__c = 'Cancellation_Request_by_Customer'];
       
        system.debug('@@@@'+srStep);
        List<HexaBPM__Step__c> cancelledStep = new List<HexaBPM__Step__c>();
        if(!srStep.isEmpty()){
            //create step record
            HexaBPM__Step__c newStep = new HexaBPM__Step__c();
            newStep.HexaBPM__Step_No__c = srStep[0].HexaBPM__Step_No__c;
            newStep.HexaBPM__SR_Step__c = srStep[0].Id; 
            newStep.HexaBPM__Summary__c = srStep[0].HexaBPM__Summary__c;
            newStep.HexaBPM__Status__c = srStep[0].HexaBPM__Start_Status__c;
            newStep.HexaBPM__SR__c = serviceRequest.Id;
            newStep.OwnerId = Label.Government_Services_Queue_Id;
            newStep.HexaBPM__Step_Template__c = srStep[0].HexaBPM__Step_Template__c;
            cancelledStep.add(newStep);
        }
        
        try{
        
            //insert step
            if(!cancelledStep.isEmpty()){
                insert cancelledStep;
            }
        
            resultStr = 'Success';
        } catch(Exception e){
            resultStr = e.getMessage();
        }
        
        
        return resultStr;
    }
    
    //method to check if there is an already exisisting cancellation step
    webservice static String checkExistingCancelRequest(String srId){
        String resultStr = '';
        List<HexaBPM__Step__c> existingCancelledStep = [SELECT Id FROM HexaBPM__Step__c 
                                                        WHERE HexaBPM__Summary__c = 'Cancellation Request by Client' 
                                                        AND HexaBPM__SR__c = :srId 
                                                        AND (HexaBPM__Status__r.HexaBPM__Code__c = 'AWAITING_APPROVAL' 
                                                        OR HexaBPM__Status__r.HexaBPM__Code__c = 'APPROVED')];
        if(!existingCancelledStep.isEmpty()){
            resultStr = 'Existing';
        } else{
            resultStr = 'Success';
        }
        return resultStr;
    }
    
    //method to check if there is an open Payment Step
    webservice static String checkOpenPaymentStep(String srId){
        String resultStr = '';
        List<HexaBPM__Step__c> openPaymentStep = [SELECT Id FROM HexaBPM__Step__c 
                                                        WHERE HexaBPM__SR_Step__r.HexaBPM__Step_RecordType_API_Name__c = 'Payment_Step' 
                                                        AND HexaBPM__SR__c = :srId 
                                                        AND HexaBPM__Status__r.HexaBPM__Type__c <> 'End'];
        if(!openPaymentStep.isEmpty()){
            resultStr = 'Payment Step';
        } else{
            resultStr = 'Success';
        }
        return resultStr;
    }
    
    //method to delete Draft Service Request
    webservice static String deleteDraftSR(String srId){
        String resultStr = '';
        List<HexaBPM__Service_Request__c> selectedSR = [SELECT Id FROM HexaBPM__Service_Request__c WHERE Id = :srId];
        if(!selectedSR.isEmpty()){
            try{
                delete selectedSR;
                resultStr = 'Success';
            }catch(Exception e){
                resultStr = 'Failed';
            }
        }
        return resultStr;
    }
}