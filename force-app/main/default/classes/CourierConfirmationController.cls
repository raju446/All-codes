/**********************************************************
    Author      :   Durga Prasad
    Company     :   PwC
    Description :   Controller to Confirm the Courier Delivery
*************************************************************/
public without sharing class CourierConfirmationController{
    public HexaBPM__Step__c objStep{get;set;}
    public HexaBPM__Service_Request__c objSR{get;set;}
    public string SRID{get;set;}
    public string StepID{get;set;}
    public map<id,HexaBPM__Step_Transition__c> mapStepTransition;
    public string selectedTransition{get;set;}
    public list<selectoption> listTransitions{get;set;}
    public string SRAccountId;
    public boolean AllowedToProceed{get;set;}
    public CourierConfirmationController(ApexPages.StandardController controller){
        selectedTransition = '';
        AllowedToProceed = false;
        if(apexpages.currentpage().getParameters().get('Id')!=null)
            SRID = String.escapeSingleQuotes(apexpages.currentpage().getParameters().get('Id'));
        
        if(apexpages.currentpage().getParameters().get('StepId')!=null){
            StepID = String.escapeSingleQuotes(apexpages.currentpage().getParameters().get('StepId'));
            for(HexaBPM__Step__c step:[Select Id,Name,HexaBPM__Status__c,HexaBPM__SR_Step__c,HexaBPM__SR__c,HexaBPM__Summary__c,HexaBPM__SR__r.HexaBPM__Customer__c from HexaBPM__Step__c where Id=:StepID]){
                objSR = new HexaBPM__Service_Request__c(Id=step.HexaBPM__SR__c);
                objStep = step;
                SRAccountId = step.HexaBPM__SR__r.HexaBPM__Customer__c;
            }
        }
    }
    /*
        Method Name :   CheckAccess
        Description :   Code to check the Service Request belongs to the logged In user's account or not
    */
    public pagereference CheckAccess(){
        Pagereference pg = new Pagereference('/apex/Noaccess');
        pg.setRedirect(true);
        boolean hasAccess = true;
        set<string> accesslist = new set<string>();
        accesslist.addAll(label.Awaiting_Confirmation_Access.split(';'));
        if(SRAccountId!=null){
            for(User usr:[select Id,ContactId,Contact.AccountId,Profile.Name,Name from user where Id=:userinfo.getUserId()]){
                if(usr.ContactId!=null){
                    if(SRAccountId!=usr.Contact.AccountId)
                        hasAccess = false;
                    else
                        AllowedToProceed = true;
                }else if(usr.ContactId==null && (usr.Profile.Name.indexOf('System Administration')>-1 || 
                            usr.Profile.Name.indexOf('System Admin')>-1)  
                            || usr.Profile.Name.indexOf('ADGM Government Services Supervisor')>-1 
                            || accesslist.contains(usr.Name)
                   ){
                    AllowedToProceed = true;
                }
            }
            if(!hasAccess)
                return pg;
        }
        PrepareTransitions();
        return null;
    }
    public void PrepareTransitions(){
        mapStepTransition = new map<id,HexaBPM__Step_Transition__c>();
        listTransitions = new list<selectoption>();
        listTransitions.add(new selectoption('','--None--'));
        selectedTransition = '';
        for(HexaBPM__Step_Transition__c trans:[select HexaBPM__From__c,HexaBPM__Transition__r.HexaBPM__To__r.HexaBPM__Reupload_Document__c,HexaBPM__Parent_SR_Status__c,HexaBPM__To__c,HexaBPM__Parent_Step_Status__c,HexaBPM__Transition__c,HexaBPM__Transition__r.HexaBPM__To__c,HexaBPM__SR_Step__c,HexaBPM__SR_Status_External__c,HexaBPM__SR_Status_Internal__c from HexaBPM__Step_Transition__c where HexaBPM__SR_Step__c=:objStep.HexaBPM__SR_Step__c and HexaBPM__Transition__c!=null and HexaBPM__Display_on_Portal__c=true]){
            listTransitions.add(new selectoption(trans.HexaBPM__Transition__r.HexaBPM__To__c,trans.HexaBPM__To__c));
            mapStepTransition.put(trans.HexaBPM__Transition__r.HexaBPM__To__c,trans);
        }
    }
    public pagereference ConfirmDeliveryOption(){
        pagereference pg = new pagereference('/'+SRID);
        pg.setredirect(true);
        if(selectedTransition==''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please select the Delivery Option'));
            return null;
        }
        if(SRID!=null){
            String openPaymentValidation = ApexCodeUtility.CheckOpenFinePaymentStep(SRID);
            if(openPaymentValidation!='Success'){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,openPaymentValidation));
                return null;
            }
        }
        Savepoint Confirm_svpoint = Database.setSavepoint();
        try{
            if(selectedTransition!=null && selectedTransition!='' && objSR!=null && objSR.Id!=null && objStep!=null && objStep.Id!=null){
                objStep.HexaBPM__Status__c = selectedTransition;
                
                if(mapStepTransition.get(selectedTransition).HexaBPM__SR_Status_Internal__c!=null && mapStepTransition.get(selectedTransition).HexaBPM__SR_Status_External__c!=null){
                    objSR.HexaBPM__Internal_SR_Status__c = mapStepTransition.get(selectedTransition).HexaBPM__SR_Status_Internal__c;
                    objSR.HexaBPM__External_SR_Status__c = mapStepTransition.get(selectedTransition).HexaBPM__SR_Status_External__c;
                }
                
                update objSR;
                update objStep;
            }
        }catch(DMLException e){
            string DMLError = e.getdmlMessage(0)+'';
            system.debug('Full DMLError==>'+e.getdmlMessage(0));
            for (Integer i = 0; i < e.getNumDml(); i++) {
                System.debug(i+'Exception===>'+e.getDmlMessage(i));
            }
            if(DMLError==null){
                DMLError = e.getMessage()+'';
            }
            Database.rollback(Confirm_svpoint);
            system.debug('DMLError==>'+DMLError);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,DMLError));
            return null;
        }
        return pg;
    }
    /*
     * Method Name : CancelAction
     * Description : Method invoked on click of the cancel button. Redirects the page back to the SR Detail page
    */
    public pagereference CancelAction(){
        Pagereference pg = new Pagereference('/'+SRID);
        pg.setredirect(true);
        return pg;
    }
}