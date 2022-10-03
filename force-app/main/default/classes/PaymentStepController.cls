/*********************************************************
    *   Author      :   Durga Prasad
    *   Company     :   PwC
    *   Date        :   05-Nov-2017
    *   Description :   PaymentStep page controller used for Intermediate Payments.
 *********************************************************/
public without sharing class PaymentStepController {
    public string strSRID{get; set;}
    public string strStepID{get; set;}
    public decimal AvailBalance{get; set;}
    public decimal AvailablePortalBalance {get; set;}
    public decimal TotalPriceItemVal {get; set;}
    public decimal DeficitBalance {get;set;}
    public String DefBalStr {get;set;}
    public HexaBPM__Service_Request__c ServiceRequest{get; set;}
    public list<HexaBPM__SR_Price_Item__c> lstSRPriceItems {get; set;}
    map<string,string> MapParameters = new map<string,string>();
    public HexaBPM__Step__c PaymentStep;
    public boolean PaymentPending{get;set;}
    string SRAccountId;
    public PaymentStepController(){
        MapParameters = apexpages.currentPage().getParameters();
        PaymentStep = new HexaBPM__Step__c();
        if(MapParameters.get('Id') != null && MapParameters.get('Id') != '')
            strSRID = MapParameters.get('Id');
        if(MapParameters.get('StepId')!=null && MapParameters.get('StepId')!=''){
            PaymentPending = true;
            for(HexaBPM__Step__c stp:[Select Id,Name,HexaBPM__SR_Step__c,HexaBPM__SR__c,HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__Status__c,HexaBPM__Status__r.HexaBPM__Type__c from HexaBPM__Step__c where Id=:MapParameters.get('StepId')]){
                PaymentStep = stp;
                SRAccountId = stp.HexaBPM__SR__r.HexaBPM__Customer__c;
                if(stp.HexaBPM__Status__r.HexaBPM__Type__c=='End')
                    PaymentPending = false;
            }
            strStepID = MapParameters.get('StepId');
        }
        system.debug('@@PAYMENTPENDING: '+PaymentPending);
        DeficitBalance = 0; 
        DefBalStr = '';
    }
    /*
        Method Name :   CheckAccess
        Description :   Code to check the Service Request belongs to the logged In user's account or not
    */
    public pagereference CheckAccess(){
        Pagereference pg = new Pagereference('/apex/Noaccess');
        pg.setRedirect(true);
        boolean hasAccess = true;
        if(SRAccountId!=null){
            for(User usr:[select Id,ContactId,Contact.AccountId from user where Id=:userinfo.getUserId() and ContactId!=null]){
                if(SRAccountId!=usr.Contact.AccountId)
                    hasAccess = false;
            }
            if(!hasAccess)
                return pg;
        }
        PreparePriceItems();
        return null;
    }
    public void PreparePriceItems(){
        lstSRPriceItems = new list<HexaBPM__SR_Price_Item__c>();
        TotalPriceItemVal = 0;
        if(strSRID!=null){
             list<HexaBPM__Service_Request__c> lstServReq = new list<HexaBPM__Service_Request__c>();
             lstServReq = SubmitRequestController.getExistingSRPriceLines(strSRID);
             if(lstServReq!= null && lstServReq.size() > 0){
                ServiceRequest = lstServReq[0];
                
                if(lstServReq[0].HexaBPM__SR_Price_Items1__r!= null && lstServReq[0].HexaBPM__SR_Price_Items1__r.size() > 0) {
                    lstSRPriceItems = lstServReq[0].HexaBPM__SR_Price_Items1__r;
                    for(HexaBPM__SR_Price_Item__c PI : lstServReq[0].HexaBPM__SR_Price_Items1__r) {
                        TotalPriceItemVal += PI.Total_Amount__c;
                    }
                }
                //Commented by Azmath as we no longer needed to fetch oracle balance.
                /*AvailBalance =  WS_BalanceCheck.GetOracleBalance(lstServReq[0].HexaBPM__Customer__r.Oracle_Party_Id__c);
                system.debug('BalancefromOracle==>'+AvailBalance);
                decimal ReceiptsAmount = ApexCodeUtility.getOpenReceiptsAmount(lstServReq[0].HexaBPM__Customer__c);
                decimal BlockedSRsAmount = ApexCodeUtility.getBlockedAmount(lstServReq[0].HexaBPM__Customer__c);
                if(AvailBalance != null){
                    if(ReceiptsAmount!=null)
                        AvailBalance = AvailBalance + ReceiptsAmount;
                }else if(AvailBalance==null && ReceiptsAmount!=null){
                    AvailBalance = ReceiptsAmount;
                }
                AvailablePortalBalance = AvailBalance;
                if(BlockedSRsAmount!=null)
                    AvailablePortalBalance = AvailablePortalBalance - BlockedSRsAmount;*/
                
                AvailablePortalBalance = PortalBalanceCalculator.finalbalance(lstServReq[0].HexaBPM__Customer__c);
                if((AvailablePortalBalance - TotalPriceItemVal) < 0){
                    DeficitBalance = AvailablePortalBalance - TotalPriceItemVal;
                    DeficitBalance = DeficitBalance.abs();
                    DefBalStr = String.valueOf(DeficitBalance);
                }
             }
        }
    }
    
    public pagereference ConfirmPayment(){
        pagereference ref = new pagereference('/' + strSRID);
        ref.setRedirect(true);
        Savepoint PaymentConfirmationSP = Database.setSavepoint();
        for(HexaBPM__SR_Price_Item__c objItem : lstSRPriceItems) {
            objItem.HexaBPM__Status__c = 'Blocked';
        }
        try{
            if(lstSRPriceItems!=null && lstSRPriceItems.size()>0)
                update lstSRPriceItems;
            if(PaymentStep!=null && PaymentStep.Id!=null){
                HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c(Id=PaymentStep.HexaBPM__SR__c);
                for(HexaBPM__Step_Transition__c stptran : [select HexaBPM__SR_Status_Internal__c,HexaBPM__SR_Status_External__c,HexaBPM__Transition__r.HexaBPM__To__c,HexaBPM__Transition__r.HexaBPM__From__c from HexaBPM__Step_Transition__c where HexaBPM__Transition__c!=null and HexaBPM__SR_Step__c=:PaymentStep.HexaBPM__SR_Step__c and 
                HexaBPM__Transition__r.HexaBPM__From__c=:PaymentStep.HexaBPM__Status__c and HexaBPM__Transition__r.HexaBPM__To__r.HexaBPM__Type__c = 'End' limit 1]){
                    PaymentStep.HexaBPM__Status__c = stptran.HexaBPM__Transition__r.HexaBPM__To__c;
                    if(stptran.HexaBPM__SR_Status_Internal__c!=null)
                        objSR.HexaBPM__Internal_SR_Status__c = stptran.HexaBPM__SR_Status_Internal__c;
                    if(stptran.HexaBPM__SR_Status_External__c!=null)
                        objSR.HexaBPM__External_SR_Status__c = stptran.HexaBPM__SR_Status_External__c;
                    break;
                }
                update PaymentStep;
                if(objSR.HexaBPM__Internal_SR_Status__c!=null || objSR.HexaBPM__External_SR_Status__c!=null)
                    update objSR;
            }
        }catch(DMLException e){
            Database.rollback(PaymentConfirmationSP);
            string strDMLError = string.valueOf(e.getdmlMessage(0));
            if (strDMLError == null)
                strDMLError = e.getMessage();
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, strDMLError));
            return null;
        }
        return ref;
    }
    
    public pagereference CancelPayment(){
        pagereference ref = new pagereference('/' + strSRID);
        ref.setRedirect(true);
        return ref;
    }
}