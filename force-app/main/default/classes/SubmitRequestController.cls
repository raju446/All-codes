/*********************************************************
    *   Author      :   Durga Prasad
    *   Company     :   PwC
    *   Date        :   03-Oct-2017
    *   Description :   Displays the Pricing Information to Submit the Request.
    ** * --------------------------------------------------------------------------------------
    * @Change History
    * Author            Date            Description
    * Yogesh Mahajan  09Feb2020    Added new check balance webservice call
 *********************************************************/
public without sharing class SubmitRequestController {
    public string strSRID{get; set;}
    public decimal AvailBalance{get; set;}
    public decimal AvailablePortalBalance {get; set;}
    public decimal TotalPriceItemVal {get; set;}
    public decimal DeficitBalance {get;set;}
    public String DefBalStr {get;set;}
    public HexaBPM__Service_Request__c objSR {get; set;}
    public list<HexaBPM__SR_Price_Item__c> lstSRPriceItems {get; set;}
    public list<HexaBPM__SR_Status__c> lstStatus = new list<HexaBPM__SR_Status__c>();
    public boolean hasPriceItems {get; set;}
    public boolean hasPriceLines {get; set;}
    public boolean isAllowed_to_Submit {get; set;}
    public boolean cannotProccedFlg;
    public boolean femaleSponsorDisclaimer{get;set;}
    public string errorStr {get;set;}
    public boolean isHumanitarianDisclaimer{get;set;}
    public Boolean isSubmitNotAllowed {get;set;}
    list<HexaBPM__Service_Request__c> objSRLst;
    
    public boolean HasPaymentAccess{get;set;}
    public SubmitRequestController() {
        isAllowed_to_Submit = true;
        hasPriceLines = false;
        if(apexpages.currentPage().getParameters().get('Id') != null && apexpages.currentPage().getParameters().get('Id') != '')
            strSRID = string.escapeSingleQuotes(apexpages.currentPage().getParameters().get('Id'));
        lstStatus = [select id,Name from HexaBPM__SR_Status__c where (Name = 'Submitted' or Name = 'submitted') limit 1];
        lstSRPriceItems = new list<HexaBPM__SR_Price_Item__c>();
        TotalPriceItemVal = 0;
        AvailablePortalBalance = 0;
        AvailBalance = 0;
        DeficitBalance = 0; 
        DefBalStr = '';
        femaleSponsorDisclaimer = false;
        hasPriceItems = false;
        cannotProccedFlg = true;
        isHumanitarianDisclaimer = false;
        isSubmitNotAllowed = false;
        if(strSRID!=null){
            objSRLst = getServiceRequest(strSRID);
            if(objSRLst!=null && objSRLst.size()>0)
                objSR = objSRLst[0];
        }
        //AvailBalance = objSR.HexaBPM__Customer__r.HexaBPM__Portal_Balance__c;
        if(objSRLst!=null && objSRLst.size()>0 && objSRLst[0].HexaBPM__Customer__r.Oracle_Party_Id__c != null && objSRLst[0].HexaBPM__Customer__r.Oracle_Party_Id__c != ''){
            try{
                 // As per new balance functionality we dont need to query balance from oracle. Hence commenting the bleow.
                //AvailBalance =  WS_BalanceCheck.GetOracleBalance(objSRLst[0].HexaBPM__Customer__r.Oracle_Party_Id__c);
                //Added new web service call
                // AvailBalance = WS_BalanceCheck.GetOracleBalance_New(objSRLst[0].HexaBPM__Customer__c);
            }catch(Exception e){AvailBalance = 0;}
        }
        
    }
    public pagereference CheckPriceLines(){
        Pagereference pg = new Pagereference('/apex/Noaccess');
        pg.setRedirect(true);
        boolean hasAccess = true;
        HasPaymentAccess = true;
        try{
            if(objSR!=null && objSR.HexaBPM__Customer__c!=null){
                string StrAccountId;
                for(User usr:[select Id,ContactId,Contact.AccountId,Contact.Types_of_Services_Accessible__c,Profile.Name from user where Id=:userinfo.getUserId() and ContactId!=null]){
                    if(usr.ContactId!=null && usr.Contact.Types_of_Services_Accessible__c!=null && usr.Contact.Types_of_Services_Accessible__c.indexof('Payment - Account Services')==-1){ HasPaymentAccess = false; }
                    StrAccountId = usr.Contact.AccountId;
                }
                if((StrAccountId!=null && StrAccountId!=objSR.HexaBPM__Customer__c) || HasPaymentAccess==false){hasAccess = false; return pg;}
            }
            string OpenSRValidation = CheckOpenSR.CheckOpenSRExists(objSR);
            if(OpenSRValidation!='Success'){isSubmitNotAllowed = true;ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,OpenSRValidation));return null;}
            string OtherValidation = CheckValidations(objSR);
            if(OtherValidation!='Success'){ isSubmitNotAllowed = true;ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,OtherValidation));return null;}
            HumanitarianDisclaimerCheck();
            if(strSRID != null){
                if(objSRLst != null && objSRLst.size() > 0){
                    /*if(objSRLst[0].HexaBPM__Record_Type_Name__c == 'P_O_Box_New' || objSRLst[0].HexaBPM__Record_Type_Name__c == 'P_O_Box_Renewal' ){
                        string poBoxCode = 'P_O_BOX_FEES';
                        list<Product2> objPOBoxProduct = [SELECT Id FROM Product2 WHERE ProductCode =:poBoxCode];
                        if(objPOBoxProduct!=null && objPOBoxProduct.size()>0){
                            list<HexaBPM__SR_Price_Item__c> existPOBoxPriceItems = [SELECT Id FROM HexaBPM__SR_Price_Item__c WHERE HexaBPM__Product__c = :objPOBoxProduct[0].Id AND HexaBPM__ServiceRequest__c = :objSRLst[0].Id];
                            if(existPOBoxPriceItems!=null && existPOBoxPriceItems.size()>0){
                                delete existPOBoxPriceItems;
                            }
                        }
                        list<HexaBPM__SR_Price_Item__c> srPriceItemsPOBoxInsert = new list<HexaBPM__SR_Price_Item__c>();
                        srPriceItemsPOBoxInsert = ApexCodeUtility.createPOBoxPriceItems(objSRLst[0]);
                        if(srPriceItemsPOBoxInsert!=null && srPriceItemsPOBoxInsert.size()>0){
                            insert srPriceItemsPOBoxInsert;
                        }
                    }
          */
                }
            }
            
            list<HexaBPM__Service_Request__c> lstServReq = new list<HexaBPM__Service_Request__c>();
            if(strSRID != null) {
                lstServReq = getExistingSRPriceLines(strSRID);
                if(lstServReq!= null && lstServReq.size() > 0) 
                {
                    objSR = lstServReq[0];
                    if(lstServReq[0].HexaBPM__SR_Price_Items1__r!= null && lstServReq[0].HexaBPM__SR_Price_Items1__r.size() > 0) 
                    {
                        hasPriceLines = true;
                        lstSRPriceItems = lstServReq[0].HexaBPM__SR_Price_Items1__r;
                        hasPriceItems = true;
                        for(HexaBPM__SR_Price_Item__c PI : lstServReq[0].HexaBPM__SR_Price_Items1__r) {
                            TotalPriceItemVal += PI.Total_Amount__c;
                        }
                    }
                    //system.debug('BalancefromOracle==>'+AvailBalance);
                    decimal ReceiptsAmount = ApexCodeUtility.getOpenReceiptsAmount(objSR.HexaBPM__Customer__c);
                    System.debug('ReceiptsAmount' +ReceiptsAmount);
                    decimal BlockedSRsAmount = ApexCodeUtility.getBlockedAmount(objSR.HexaBPM__Customer__c);
                    System.debug('BlockedSRsAmount' +BlockedSRsAmount);
                    
                    //As per new balance functionality we dont need to query balance from oracle. Hence commenting the bleow.
                    /*if(AvailBalance != null){
                        if(ReceiptsAmount!=null)
                            AvailBalance = AvailBalance + ReceiptsAmount;
                    }else if(AvailBalance==null && ReceiptsAmount!=null){
                        AvailBalance = ReceiptsAmount;
                    }
                    AvailablePortalBalance = AvailBalance;
                    if(BlockedSRsAmount!=null)
                        AvailablePortalBalance = AvailablePortalBalance - BlockedSRsAmount;*/
                    AvailablePortalBalance = PortalBalanceCalculator.finalbalance(objSR.HexaBPM__Customer__c);
                }
                if((AvailablePortalBalance - TotalPriceItemVal) < 0)
                {
                    DeficitBalance = AvailablePortalBalance - TotalPriceItemVal;
                    DeficitBalance = DeficitBalance.abs();
                    DefBalStr = String.valueOf(DeficitBalance);
                }
            }
        }catch(DMLException e){isSubmitNotAllowed = true;string strDMLError = string.valueOf(e.getdmlMessage(0));
            if (strDMLError == null)
                strDMLError = e.getMessage();
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, strDMLError));return null;
        }
        if(hasPriceLines==false){
            return SubmitSR();
        }else{return null;}
    }
    
    /* Changes the Service Request Status to Submitted by checking the required validation */
    public pagereference SubmitSR() 
    {
        System.debug('Portal Balance Error : '+errorStr);
        pagereference ref = new pagereference('/' + strSRID);
        ref.setRedirect(true);
        if(objSR.HexaBPM__External_SR_Status__r.HexaBPM__Code__c != 'DRAFT') {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'The Service Request is Already submitted.'));
            return null;
        }
        if(hasPriceLines && objSR.HexaBPM__customer__c != null && TotalPriceItemVal != null && TotalPriceItemVal > 0 && AvailablePortalBalance < TotalPriceItemVal) {ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'You dont have enough balance to Process the Request, Please click on Top Up.'));return null;}
        if(objSR.Has_Female_Sponsor__c == true && femaleSponsorDisclaimer == false){ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Please check on the disclaimer.'));return null;}
        Savepoint Submit_through_Button = Database.setSavepoint();
        objSR.HexaBPM__finalizeAmendmentFlg__c = true;
        objSR.HexaBPM__Submitted_Date__c = system.today();
        objSR.HexaBPM__Submitted_DateTime__c = system.now();
        if(lstStatus != null && lstStatus.size() > 0){
            objSR.HexaBPM__Internal_SR_Status__c = lstStatus[0].id;
            objSR.HexaBPM__External_SR_Status__c = lstStatus[0].id;
            try{
                list<HexaBPM__SR_Price_Item__c> lstPriceItems = new list<HexaBPM__SR_Price_Item__c>();
                for(HexaBPM__SR_Price_Item__c objItem : [select Id, HexaBPM__Status__c from HexaBPM__SR_Price_Item__c where HexaBPM__Status__c = 'Added' AND HexaBPM__ServiceRequest__c = :objSR.Id and IsDeleted = false]) {
                    objItem.HexaBPM__Status__c = 'Blocked';lstPriceItems.add(objItem);
                }
                if(lstPriceItems != null && lstPriceItems.size() > 0)
                    update lstPriceItems;
                HexaBPM.RecursiveControl.isUpdatedAlready = true;
                
                //ICA Change 1:
                HexaBPM__Service_Request__c getSr = [Select HexaBPM__customer__c, HexaBPM__customer__r.Name, HexaBPM__customer__r.Account_Name_Arabic__c FROM HexaBPM__Service_Request__c where id=:objSR.id];
                if(objSR.HexaBPM__Record_Type_Name__c == 'Establishment_Card_New' || objSR.HexaBPM__Record_Type_Name__c == 'Establishment_Card_Amendment' || objSR.HexaBPM__Record_Type_Name__c == 'Initial_Approval'){
                  objSR.Establishment_English_Name__c = getSr.HexaBPM__customer__r.Name+' ADGM';
                  objSR.Establishment_Arabic_Name__c  = getSr.HexaBPM__customer__r.Account_Name_Arabic__c+' '+system.label.ICA_ArabicADGM;//+' سوق أبوظبي العالمي';
                }
                
                //ICA Change 2:
                if(objSR.HexaBPM__Record_Type_Name__c == 'Establishment_Card_New' || objSR.HexaBPM__Record_Type_Name__c == 'Establishment_Card_Amendment')
                {
                  list<Initial_Approval_List__c> ialist = new list<Initial_Approval_List__c>();
                  if(objSR.HexaBPM__Record_Type_Name__c == 'Establishment_Card_New')
                  {
                    ialist = [Select id, Initial_Approval_Number__c FROM Initial_Approval_List__c WHERE Entity__c=:getSr.HexaBPM__customer__c and Assigned_To__c = null and Expiry_Date__c >=:Date.today() and Active__c=true order by CreatedDate DESC LIMIT 1];
                  }
                  else
                  {
                    ialist = [Select id, Initial_Approval_Number__c FROM Initial_Approval_List__c WHERE Entity__c=:getSr.HexaBPM__customer__c and Assigned_To__c = null and Expiry_Date__c >=:Date.today() and Active__c=true and Reason__c='Name Change' order by CreatedDate DESC LIMIT 1];
                    if(ialist.isEmpty())
                    {
                      list<HexaBPM__Service_Request__c> openIA = [Select id FROM HexaBPM__Service_Request__c WHERE HexaBPM__IsClosedStatus__c = false and Recordtype.DeveloperName = 'Initial_Approval' and HexaBPM__Customer__c=:getSr.HexaBPM__customer__c order by CreatedDate DESC LIMIT 1];
                      if(!openIA.isEmpty()){
                        objSR.HexaBPM__Linked_SR__c = openIA[0].id;
                      }
                    }
                  }
                  if(!ialist.isEmpty()){ objSR.Initial_Approval_Number__c = ialist[0].Initial_Approval_Number__c; ialist[0].Assigned_To__c = objSR.id; update ialist; }
                }
                update objSR;
            }catch(DMLException e){Database.rollback(Submit_through_Button);string strDMLError = string.valueOf(e.getdmlMessage(0));
                if (strDMLError == null)
                    strDMLError = e.getMessage();
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, strDMLError));return null;
            }
        }
        return ref;
    }
    /* Method to view the Service Request */
    public pagereference BacktoSR() {
        pagereference ref = new pagereference('/' + strSRID);
        ref.setRedirect(true);
        return ref;
    }
    /* Method to query the Service Request details */
    public static list<HexaBPM__Service_Request__c> getServiceRequest(string SRID) {
        list<HexaBPM__Service_Request__c> objSRLst = [select Id,Name,Has_Female_Sponsor__c,Disclaimer__c,HexaBPM__Ultimate_SR_Menu_Text__c,HexaBPM__finalizeAmendmentFlg__c,HexaBPM__SR_Template__c, CreatedDate,HexaBPM__Internal_Status_Name__c, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c, HexaBPM__External_SR_Status__r.HexaBPM__Type__c,HexaBPM__Internal_SR_Status__r.HexaBPM__Type__c, HexaBPM__Customer__r.HexaBPM__Portal_Balance__c, HexaBPM__Customer__r.HexaBPM__BG_Balance__c, HexaBPM__SR_Template__r.HexaBPM__Portal_Service_Request_Name__c,P_O_Box_Type__c,Entity_PO_Box_Expiry_Date__c,PO_Box__c,Passport_Number__c,HexaBPM__Contact__c, Sponsor_Gender__c, Relationship_with_Sponsor__c, RecordTypeId, 
                          Temporary_Work_Permit_Type__c,HexaBPM__External_SR_Status__r.HexaBPM__Code__c,HexaBPM__Internal_SR_Status__r.HexaBPM__Code__c,HexaBPM__Record_Type_Name__c,HexaBPM__customer__c,HexaBPM__External_Status_Name__c, HexaBPM__Submitted_DateTime__c,HexaBPM__Submitted_Date__c,HexaBPM__Customer__r.Oracle_Party_Id__c,HexaBPM__SR_Template__r.HexaBPM__Sub_menu__c,Dependent__c,HexaBPM__IsClosedStatus__c,HexaBPM__IsCancelled__c,HexaBPM__Is_Rejected__c,HexaBPM__Internal_SR_Status__r.Name,Passport_Issue_Date__c,Passport_Expiry_Date__c,Country_of_Issue__c,Place_of_Issue__c,First_Name__c,Title__c,Middle_Name__c,HexaBPM__Customer__r.Entity_Status__c,
                          HexaBPM__customer__r.Name, HexaBPM__customer__r.Account_Name_Arabic__c 
                          from HexaBPM__Service_Request__c where Id=:SRID];

        return objSRLst;
    }
    /* Method to query the Service Request details */
    public static list<HexaBPM__Service_Request__c> getExistingSRPriceLines(string SRID) {
        list<HexaBPM__Service_Request__c> lstServReq = [select Id, Name, Has_Female_Sponsor__c, Disclaimer__c, HexaBPM__Contact__r.Gender__c, Relationship_with_Sponsor__c, Sponsor_Gender__c, HexaBPM__Ultimate_SR_Menu_Text__c,HexaBPM__finalizeAmendmentFlg__c,HexaBPM__SR_Template__c, CreatedDate,HexaBPM__Internal_Status_Name__c, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c, HexaBPM__External_SR_Status__r.HexaBPM__Type__c,HexaBPM__Internal_SR_Status__r.HexaBPM__Type__c, HexaBPM__Customer__r.HexaBPM__Portal_Balance__c, HexaBPM__Customer__r.HexaBPM__BG_Balance__c, HexaBPM__SR_Template__r.HexaBPM__Portal_Service_Request_Name__c,P_O_Box_Type__c,Entity_PO_Box_Expiry_Date__c,PO_Box__c, RecordTypeId, 
                          HexaBPM__External_SR_Status__r.HexaBPM__Code__c,HexaBPM__Internal_SR_Status__r.HexaBPM__Code__c,HexaBPM__Record_Type_Name__c,HexaBPM__customer__c,HexaBPM__External_Status_Name__c, HexaBPM__Submitted_DateTime__c,HexaBPM__Submitted_Date__c,HexaBPM__Customer__r.Oracle_Party_Id__c,(select id, Name,HexaBPM__Price__c,HexaBPM__Pricing_Line__c,HexaBPM__Discount_Amount__c, HexaBPM__Status__c,HexaBPM__Product__c,HexaBPM__Product__r.Name,Description__c,HexaBPM__ServiceRequest__c,HexaBPM__Sys_Added_through_Code__c,Tax_Amount__c,Cost__c,Markup_Amount__c,Cancellation_Fee__c,Total_Amount__c,Fee__c from HexaBPM__SR_Price_Items1__r where HexaBPM__Status__c = 'Added')
                          from HexaBPM__Service_Request__c where Id=:SRID];

        return lstServReq;
    }
    public static string CheckValidations(HexaBPM__Service_Request__c objSR){
        string strResult = 'Success';
        strResult = ApexCodeUtility.SubmissionAllowed(objSR);
        return strResult;
    }
    public void HumanitarianDisclaimerCheck(){
        if(objSR.HexaBPM__Record_Type_Name__c == 'Dependent_Visa_New'){
            if(objSR.Sponsor_Gender__c == 'Male' && (objSR.Relationship_with_Sponsor__c == 'Father' || objSR.Relationship_with_Sponsor__c == 'Mother')){isHumanitarianDisclaimer = true;ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, Label.Humanitarian_Visa_Application_Message));
                
            }else if(objSR.Sponsor_Gender__c == 'Female' && (objSR.Relationship_with_Sponsor__c == 'Father' || objSR.Relationship_with_Sponsor__c == 'Mother' /*|| objSR.Relationship_with_Sponsor__c == 'Son' || objSR.Relationship_with_Sponsor__c == 'Daughter'*/)){
                isHumanitarianDisclaimer = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, Label.Humanitarian_Visa_Application_Message));
            }
        }
    }
}