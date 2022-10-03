/***********    *******************************************************************************
*  Author         :   Durga
*  Company        :   PwC
*  Date           :   11-April-2017
*  Description    :   Apex Controller for creating Fines by business team
*  Version        :   1.0
********************************************************************************************/
public without sharing class FinesController {
    public HexaBPM__SR_Price_Item__c objSRP{get;set;}
    public HexaBPM__Service_Request__c objSR{get;set;}
    public boolean hasPermission{get;set;}
    public FinesController(ApexPages.StandardController controller){
        objSRP = new HexaBPM__SR_Price_Item__c();
        objSR = new HexaBPM__Service_Request__c();
        objSRP.HexaBPM__Sys_Added_through_Code__c = true;
        objSRP.HexaBPM__Non_Reevaluate__c = true;
        objSRP.HexaBPM__Status__c = 'Added';
        hasPermission = true;
        if(apexpages.currentpage().getParameters().get('Id')!=null){
            objSRP.HexaBPM__ServiceRequest__c = string.escapeSingleQuotes(apexpages.currentpage().getParameters().get('Id'));
            for(HexaBPM__Service_Request__c SR : [select Id,Name,HexaBPM__SR_Template__c,HexaBPM__Internal_SR_Status__c,HexaBPM__External_SR_Status__c,HexaBPM__Internal_Status_Name__c,HexaBPM__IsClosedStatus__c,HexaBPM__Is_Rejected__c,HexaBPM__IsCancelled__c from HexaBPM__Service_Request__c where Id=:objSRP.HexaBPM__ServiceRequest__c]){
                objSR = SR;
            }
        }
    }
    public void checkPermissions(){
        if(objSR.HexaBPM__Internal_Status_Name__c=='Draft' || (objSR.HexaBPM__IsCancelled__c==true || objSR.HexaBPM__Is_Rejected__c==true || objSR.HexaBPM__IsClosedStatus__c==true )){
            hasPermission = false;
            if(objSR.HexaBPM__Internal_Status_Name__c=='Draft')
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Fines are not allowed for Draft Service Request(s)'));
            else
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Fines are not allowed for Closed Service Request(s)'));
        }else{
            for(HexaBPM__Step__c stp:[Select Id from HexaBPM__Step__c where HexaBPM__SR__c=:objSR.Id and HexaBPM__SR_Step__r.HexaBPM__Step_Template_Code__c='PAYMENT_OF_FINES' and HexaBPM__Status_Type__c!='End']){
                hasPermission = false;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'There is an open Payment Step already assigned to the client.'));
            }
        }
    }
    public pagereference SaveFine(){
        Savepoint SRP_SVP = Database.setSavepoint();
        try{
            list<HexaBPM__SR_Steps__c> SRStep = [SELECT Id, HexaBPM__Summary__c, HexaBPM__Step_No__c, HexaBPM__Start_Status__c, HexaBPM__Step_Template__c,OwnerId FROM HexaBPM__SR_Steps__c 
                                                WHERE HexaBPM__SR_Template__c=:objSR.HexaBPM__SR_Template__c AND HexaBPM__Step_Template_Code__c = 'PAYMENT_OF_FINES'];
            list<HexaBPM__Step__c> FineStep = new list<HexaBPM__Step__c>();
            if(SRStep!=null && SRStep.size()>0){
                for(Product2 pd:[select Id from Product2 where productcode='AUTOMATIC_FINES']){
                    objSRP.HexaBPM__Product__c = pd.Id;
                }
                if(objSRP.HexaBPM__Product__c==null){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Fine Product not found, Please contact your System Administrator.'));  
                }
                objSRP.HexaBPM__Price__c = objSRP.Cost__c + objSRP.Markup_Amount__c;
                HexaBPM__Step__c newStep = new HexaBPM__Step__c();
                newStep.HexaBPM__Step_No__c = srStep[0].HexaBPM__Step_No__c;
                newStep.HexaBPM__SR_Step__c = srStep[0].Id;
                newStep.HexaBPM__Summary__c = srStep[0].HexaBPM__Summary__c;
                newStep.HexaBPM__Status__c = srStep[0].HexaBPM__Start_Status__c;
                newStep.HexaBPM__SR__c = objSR.Id;
                newStep.OwnerId = SRStep[0].OwnerId;
                newStep.HexaBPM__Step_Template__c = srStep[0].HexaBPM__Step_Template__c;
                newStep.Fines_Amount__c = objSRP.Cost__c;
                newStep.Fines_Reason__c = objSRP.Description__c;
                FineStep.add(newStep);
            }else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Fine Step not found, Please contact your System Administrator.'));
                return null;
            }
            if(FineStep.size()>0){
                insert FineStep;
                objSRP.HexaBPM__Step__c = FineStep[0].Id;
                insert objSRP;
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