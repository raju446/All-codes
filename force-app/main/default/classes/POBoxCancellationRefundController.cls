/***********  *******************************************************************************
*  Author         :   Kim Noceda
*  Company        :   PwC
*  Date           :   23-April-2018
*  Description    :   Apex Controller for creating Refund for POBox Cancellation by business team
*  Version        :   1.0
********************************************************************************************/
public without sharing class POBoxCancellationRefundController {
    public HexaBPM__SR_Price_Item__c objSRP{get;set;}
    public HexaBPM__Service_Request__c objSR{get;set;}
    public boolean hasPermission{get;set;}
    list<HexaBPM__SR_Steps__c> SRStep;
    string StepStatus;
    list<HexaBPM__SR_Status__c> cancelSRStatus;
    string ProductId;
    
    public POBoxCancellationRefundController(ApexPages.StandardController controller){
        objSRP = new HexaBPM__SR_Price_Item__c();
        objSR = new HexaBPM__Service_Request__c();
        objSRP.HexaBPM__Sys_Added_through_Code__c = true;
        objSRP.HexaBPM__Non_Reevaluate__c = true;
        objSRP.HexaBPM__Status__c = 'Added';
        hasPermission = true;
        SRStep = new list<HexaBPM__SR_Steps__c>();
        if(apexpages.currentpage().getParameters().get('Id')!=null){
            objSRP.HexaBPM__ServiceRequest__c = string.escapeSingleQuotes(apexpages.currentpage().getParameters().get('Id'));
            for(HexaBPM__Service_Request__c SR : [select Id,Name,HexaBPM__SR_Template__c,HexaBPM__Internal_SR_Status__c,HexaBPM__External_SR_Status__c,HexaBPM__Internal_Status_Name__c,HexaBPM__IsClosedStatus__c,HexaBPM__Is_Rejected__c,HexaBPM__IsCancelled__c from HexaBPM__Service_Request__c where Id=:objSRP.HexaBPM__ServiceRequest__c]){
              objSR = SR;
            }
            
            for(HexaBPM__SR_Steps__c objSRStep:[SELECT Id, HexaBPM__Summary__c, HexaBPM__Step_No__c, HexaBPM__Start_Status__c, HexaBPM__Step_Template__c,OwnerId FROM HexaBPM__SR_Steps__c WHERE HexaBPM__SR_Template__c=:objSR.HexaBPM__SR_Template__c AND HexaBPM__Step_Template_Code__c = 'P_O_BOX_REFUND']){
                SRStep.add(objSRStep);
            }
            if(SRStep!=null && SRStep.size()>0){
                for(HexaBPM__Step_Transition__c stptran : [select HexaBPM__SR_Status_Internal__c,HexaBPM__SR_Status_External__c,HexaBPM__Transition__r.HexaBPM__To__c,HexaBPM__Transition__r.HexaBPM__From__c
                             from HexaBPM__Step_Transition__c where HexaBPM__Transition__c!=null and HexaBPM__SR_Step__c=:SRStep[0].Id and HexaBPM__Transition__r.HexaBPM__To__r.HexaBPM__Type__c = 'End' limit 1]){
                    StepStatus = stptran.HexaBPM__Transition__r.HexaBPM__To__c;
                }
            }
        }
        cancelSRStatus = [SELECT Id FROM HexaBPM__SR_Status__c WHERE HexaBPM__Code__c = 'CANCELLED' LIMIT 1];
        for(Product2 pd:[select Id from Product2 where productcode='P_O_BOX_REFUND']){
            ProductId = pd.Id;
        }
    }
    public void checkPermissions(){
        if(objSR.HexaBPM__Internal_Status_Name__c=='Draft' || (objSR.HexaBPM__IsCancelled__c==true || objSR.HexaBPM__Is_Rejected__c==true || objSR.HexaBPM__IsClosedStatus__c==true)){
            hasPermission = false;
            if(objSR.HexaBPM__Internal_Status_Name__c=='Draft')
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Refunds are not allowed for Draft Service Request(s)'));
            else
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Refunds are not allowed for Closed Service Request(s)'));
        }
    }
    public pagereference SaveRefund(){
        Savepoint SRP_SVP = Database.setSavepoint();
        try{
            list<HexaBPM__Step__c> poBoxRefundStep = new list<HexaBPM__Step__c>();
            if(!SRStep.isEmpty()){
                if(ProductId!=null){
                    objSRP.HexaBPM__Product__c = ProductId;
                }else{
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'PO Box Refund with code "P_O_BOX_REFUND" not found, Please contact your System Administrator.')); 
                    return null;
                }
                objSRP.Is_Refund_Line__c = true;
                objSRP.Cost__c = 0 - objSRP.Cost__c;
                objSRP.Markup_Amount__c = 0 - objSRP.Markup_Amount__c;
                objSRP.Tax_Amount__c = 0 - objSRP.Tax_Amount__c;
                objSRP.HexaBPM__Price__c = objSRP.Cost__c + objSRP.Markup_Amount__c;
                
                HexaBPM__Step__c newStep = new HexaBPM__Step__c();
                newStep.HexaBPM__Step_No__c = srStep[0].HexaBPM__Step_No__c;
                newStep.HexaBPM__SR_Step__c = srStep[0].Id;
                newStep.HexaBPM__Summary__c = srStep[0].HexaBPM__Summary__c;
                newStep.HexaBPM__Status__c = srStep[0].HexaBPM__Start_Status__c;
                newStep.HexaBPM__SR__c = objSR.Id;
                newStep.OwnerId = SRStep[0].OwnerId;
                newStep.HexaBPM__Step_Template__c = srStep[0].HexaBPM__Step_Template__c;
                poBoxRefundStep.add(newStep);
                
                if(!cancelSRStatus.isEmpty()){
                    insert objSRP;
                    objSR.Letter_Available_for_Download__c = true;
                    update objSR;
                    
                    
                    list<string> lstStepIds = new list<string>();
                    if(!poBoxRefundStep.isEmpty()){
                        insert poBoxRefundStep;
                        lstStepIds.add(poBoxRefundStep[0].Id);
                    }
                    CustomCodeCodeUtility.closeOpenActionItems(objSR.Id,lstStepIds);
                    
                    poBoxRefundStep[0].HexaBPM__Status__c = StepStatus;
                    update poBoxRefundStep;
                    
                }else{
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Cancel Status not found, Please contact your System Administrator.')); 
                    return null;
                }
            }else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'PO Box Refund Step not found, Please contact your System Administrator.'));
                return null;
            }
        }catch(DMLException e){
            string DMLError = e.getdmlMessage(0)+'';
            system.debug('Full DMLError==>'+e.getdmlMessage(0));
            for(Integer i = 0; i < e.getNumDml(); i++) {
                System.debug(i+'Exception===>'+e.getDmlMessage(i));
            }
            if(DMLError==null){
                DMLError = e.getMessage()+'';
            }
            Database.rollback(SRP_SVP);
            system.debug('DMLError==>'+DMLError);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,DMLError));
            return null;
        }
        return NavigateToSR();
    }
    public pagereference NavigateToSR(){
        Pagereference pg = new Pagereference('/'+objSR.Id);
        pg.setRedirect(true);
        return pg;
    }
}