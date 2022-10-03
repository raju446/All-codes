/*
    Author      : Azmath
    Date        : 13-Apr-2021
    Description : Class to cancel the permit.
    --------------------------------------------------------------------------------------
*/
public without sharing class ADP_CancelPermit 
{
    public HexaBPM__Service_Request__c sr {get;set;}
    string AccountId;
    public boolean IsCancel_RejectAllowed{get;set;}
    public ADP_CancelPermit(ApexPages.StandardController controller)
    {
        sr = new HexaBPM__Service_Request__c();
        if(controller.getId() != null){
            sr = [SELECT id, Name, Reason_of_Cancellation__c, HexaBPM__Customer__c,HexaBPM__SR_Template__c, Transaction_Id__c, Recordtype.DeveloperName  FROM HexaBPM__Service_Request__c WHERE Id=:controller.getId()];
            system.debug('===srtemplate=='+sr.HexaBPM__SR_Template__c);
        }
    }
    public ADP_CancelPermit()
    {
        
    }
    
    public pageReference confirmCancel()
    {
        try
        {
            //if(sr.Transaction_Id__c != null && sr.Transaction_Id__c != '')
            //{
                sr.Cancellation_Comment__c = '5';
                update sr;
                //ADP_RestServicesHelper.invokeADPService(sr.Recordtype.DeveloperName, sr.id, null);
                
                list<HexaBPM__SR_Steps__c> srStep = [SELECT Id, HexaBPM__Summary__c, HexaBPM__Step_No__c, HexaBPM__Start_Status__c, HexaBPM__Step_Template__c
                                                FROM HexaBPM__SR_Steps__c 
                                                WHERE HexaBPM__SR_Template__c = :sr.HexaBPM__SR_Template__c 
                                                AND HexaBPM__Step_Template_Code__c = 'Cancel_Permit'];
                                                
                list<HexaBPM__Step__c> cancelledStep = new list<HexaBPM__Step__c>();
                if(!srStep.isEmpty()){
                    //create step record
                    HexaBPM__Step__c newStep = new HexaBPM__Step__c();
                    newStep.HexaBPM__Step_No__c = srStep[0].HexaBPM__Step_No__c;
                    newStep.HexaBPM__SR_Step__c = srStep[0].Id; 
                    newStep.HexaBPM__Summary__c = srStep[0].HexaBPM__Summary__c;
                    newStep.HexaBPM__Status__c = srStep[0].HexaBPM__Start_Status__c;
                    newStep.HexaBPM__SR__c = sr.Id;
                    newStep.HexaBPM__Step_Template__c = srStep[0].HexaBPM__Step_Template__c;
                    cancelledStep.add(newStep);
                }
                if(!cancelledStep.isEmpty())
                {
                    insert cancelledStep;
                    if(sr.Transaction_Id__c != null && sr.Transaction_Id__c != '')
                        CC_PushtoADP.pushtoADP_Future(sr.Recordtype.DeveloperName, sr.id, null);
                }
            //}
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,ex.getMessage()));
            return null;
        }
        return new pageReference('/'+sr.id).setRedirect(true);
    }
}