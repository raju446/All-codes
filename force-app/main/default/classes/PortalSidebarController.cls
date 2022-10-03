/*********************************************************
    *   Author      :   Rajil Ravindram
    *   Company     :   PwC
    *   Date        :   10-Oct-2017
    *   Description :   Displays the Company Glance in Portal
 *********************************************************/
public without sharing class PortalSidebarController{
    public user currentuser{get;set;}
    public decimal portalBalance{get;set;}
    public string accountName{get;set;}
    public string OperatingName{get;set;}
    public decimal TotalVisasUsed{get;set;}
    public decimal TotalVisasAllowed{get;set;}
    public decimal ActiveLicenses{get;set;}
    public String Locale { get; set; }
    public String Language { get; set; }
    public String URL { get; set; }
    public boolean isExternalUser{get;set;}
    public string profilePicId {get;set;}
    public string contactId {get;set;}
    public Integer pendingRequestCount {get;set;}
    public Integer savedRequestCount {get;set;}
    public Integer currentRequestCount {get;set;}
    public string userServiceType;
    public list<string> lstAccessibleService;
    public list<string> lstAccessibleMenu;
    public string TotalVisaGuarantee{get;set;}
    public string AvailVisaGuarantee{get;set;}
    public boolean isGuestUser{get;set;}
    public boolean hasPartyId {get;set;}
    Account accountObj;
    public boolean isPaymentServiceEnabled {get;set;}
    public boolean isLeadAdmin;
    public PortalSidebarController(){
        lstAccessibleMenu = new list<string>();
        TotalVisaGuarantee = '0';
        AvailVisaGuarantee = '0';
        TotalVisasAllowed = 0;
        TotalVisasUsed = 0;
        portalBalance = 0;
        OperatingName = '';
        ActiveLicenses = 0;
        isExternalUser = false;
        isGuestUser = true;
        isPaymentServiceEnabled = false;
        lstAccessibleService = new list<string>();
        hasPartyId = false;
        currentuser = [Select Id,ContactId,Contact.Is_Guest_User__c,Contact.AccountId,contact.Profile_Picture_Id__c,Profile.Name,LanguageLocaleKey,LocaleSidKey,contact.Account.Oracle_Party_Id__c,Contact.Types_of_Services_Accessible__c,Role__c from User where Id=:userinfo.getuserId()];
        if(currentuser!=null && currentuser.ContactId!=null){
            isExternalUser = true;
            isGuestUser = currentuser.Contact.Is_Guest_User__c;
            Locale = currentuser.LocaleSidKey;
            Language  = currentuser.LanguageLocaleKey ;
            contactId = currentuser.ContactId;
            
            if(currentuser.contact.Account.Oracle_Party_Id__c != null)
            {
                hasPartyId = true;
            }
            if(String.isNotBlank(currentuser.Contact.Types_of_Services_Accessible__c)){
                string paymentOptionStr = currentuser.Contact.Types_of_Services_Accessible__c.toLowerCase();
                if(paymentOptionStr.indexOf('payment - account services')>-1)
                    isPaymentServiceEnabled = true;
            }
            userServiceType = currentuser.Contact.Types_of_Services_Accessible__c;
            if(String.isNotBlank(currentuser.Role__c) && currentuser.Role__c.toLowerCase() == 'lead admin')
                isLeadAdmin = true;
            if(String.isNotBlank(userServiceType)){
                lstAccessibleService.addAll(userServiceType.split(';'));
                userServiceType = currentuser.Contact.Types_of_Services_Accessible__c.toLowerCase();
            }
            if(lstAccessibleService != null && lstAccessibleService.size() > 0)
                lstAccessibleMenu = getAccessibleServicesMenu(lstAccessibleService);
        }
        if(currentuser != null && currentuser.ContactId!=null)
            profilePicId = currentuser.contact.Profile_Picture_Id__c;
        
        string userId = UserInfo.getUserId();
        User u = [SELECT LanguageLocaleKey,LocaleSidKey from User WHERE id=:userId];
        Locale = u.LocaleSidKey;
        Language  = u.LanguageLocaleKey ;
        system.debug('Locale initially of '+userId+' is '+u.LocaleSidKey);
        URL = ApexPages.currentPage().getHeaders().get('Host') + ApexPages.currentPage().getUrl();
        
        if(currentuser != null && currentuser.ContactId!=null){
            for(Account acc : [SELECT HexaBPM__Portal_Balance__c,Name,Total_Visas_Used__c,Total_Visas_Allowed__c,Oracle_Party_Id__c FROM Account WHERE id =:currentuser.Contact.AccountId]){
                accountObj = acc;
            }
        }
        
        //1. Pending Requests...
        AggregateResult[] groupedResultsPendingRequest;
        if(!isGuestUser){
            groupedResultsPendingRequest = [SELECT COUNT(id)cnt FROM HexaBPM__Step__c 
                                                            where HexaBPM__Status_Type__c != 'End' and Owner_Alias__c = 'Client'
                                                             and Service_Request_Name__c != 'Initial Approval' 
                                                              and HexaBPM__SR__r.HexaBPM__Customer__c = :currentuser.Contact.AccountId
                                                               and HexaBPM__SR__r.HexaBPM__SR_Template__r.HexaBPM__Sub_menu_section__c in:lstAccessibleMenu];
         }else{
             groupedResultsPendingRequest = [SELECT COUNT(id)cnt FROM HexaBPM__Step__c 
                                                            where HexaBPM__Status_Type__c != 'End' and Owner_Alias__c = 'Client'
                                                             and Service_Request_Name__c != 'Initial Approval' 
                                                              and HexaBPM__SR__r.HexaBPM__Customer__c = :currentuser.Contact.AccountId
                                            ];
         } 
         
        Object objPendingRequestCount = groupedResultsPendingRequest[0].get('cnt');
        if(objPendingRequestCount != null){
            pendingRequestCount = Integer.valueOf(objPendingRequestCount);
        }
        
        
        //2. Saved Requests..
        AggregateResult[] groupedResultsSavedRequest;
        if(!isGuestUser){
            groupedResultsSavedRequest = [SELECT COUNT(id)cnt FROM HexaBPM__Service_Request__c 
                                                            where HexaBPM__Internal_Status_Name__c = 'Draft' and HexaBPM__External_SR_Status__r.Name = 'Draft'
                                                             and HexaBPM__Record_Type_Name__c != 'User_Access_Request_for_Registered_Company'
                                                              and HexaBPM__Record_Type_Name__c != 'Guest_User_Access_Request' 
                                                               and HexaBPM__Record_Type_Name__c != 'Initial_Approval' 
                                                                and HexaBPM__Customer__c = :currentuser.Contact.AccountId
                                                                 and HexaBPM__SR_Template__r.HexaBPM__Sub_menu_section__c in:lstAccessibleMenu];
        }else{
            groupedResultsSavedRequest = [SELECT COUNT(id)cnt FROM HexaBPM__Service_Request__c 
                                                            where HexaBPM__Internal_Status_Name__c = 'Draft' and HexaBPM__External_SR_Status__r.Name = 'Draft'
                                                             and HexaBPM__Record_Type_Name__c != 'User_Access_Request_for_Registered_Company'
                                                              and HexaBPM__Record_Type_Name__c != 'Guest_User_Access_Request' 
                                                               and HexaBPM__Record_Type_Name__c != 'Initial_Approval' 
                                                                and HexaBPM__Customer__c = :currentuser.Contact.AccountId
                                                           ];
        
        
        }
        Object objSavedRequestCount = groupedResultsSavedRequest[0].get('cnt');
        if(objSavedRequestCount != null){
            savedRequestCount = Integer.valueOf(objSavedRequestCount);
        }
        
        
        
        //3. Current Requests...
        AggregateResult[] groupedResultsCurrentRequest;
        if(!isGuestUser){
            groupedResultsCurrentRequest = [SELECT COUNT(id)cnt FROM HexaBPM__Service_Request__c 
                                                            where SR_Status_Type__c = false
                                                             and HexaBPM__Is_Rejected__c = false 
                                                             and HexaBPM__IsClosedStatus__c = false 
                                                              and HexaBPM__External_Status_Name__c != 'Draft' 
                                                              and HexaBPM__Record_Type_Name__c != 'User_Access_Request_for_Registered_Company'
                                                              and HexaBPM__Record_Type_Name__c != 'Guest_User_Access_Request' 
                                                               and HexaBPM__Record_Type_Name__c != 'Initial_Approval' 
                                                                and HexaBPM__Customer__c = :currentuser.Contact.AccountId
                                                                 and HexaBPM__SR_Template__r.HexaBPM__Sub_menu_section__c in:lstAccessibleMenu];
        }else{
            groupedResultsCurrentRequest = [SELECT COUNT(id)cnt FROM HexaBPM__Service_Request__c 
                                                            where SR_Status_Type__c = false
                                                             and HexaBPM__Is_Rejected__c = false 
                                                             and HexaBPM__IsClosedStatus__c = false 
                                                              and HexaBPM__External_Status_Name__c != 'Draft' 
                                                              and HexaBPM__Record_Type_Name__c != 'User_Access_Request_for_Registered_Company'
                                                              and HexaBPM__Record_Type_Name__c != 'Guest_User_Access_Request' 
                                                               and HexaBPM__Record_Type_Name__c != 'Initial_Approval' 
                                                                and HexaBPM__Customer__c = :currentuser.Contact.AccountId
                                                             ];
        }
        Object objCurrentRequestCount = groupedResultsCurrentRequest[0].get('cnt');
        if(objCurrentRequestCount != null){
            currentRequestCount = Integer.valueOf(objCurrentRequestCount);
        }
        
    }
    public void FetchBalanceFromOracle()
    {
        system.debug('accountObj==>>' + accountObj);
        if(accountObj != null)// && accountObj.Oracle_Party_Id__c!=null) 
        {
            /*decimal ReceiptsAmount = ApexCodeUtility.getOpenReceiptsAmount(currentuser.Contact.AccountId);
            decimal BlockedSRsAmount = ApexCodeUtility.getBlockedAmount(currentuser.Contact.AccountId);
            
            decimal BalancefromOracle;
            try{
                BalancefromOracle = WS_BalanceCheck.GetOracleBalance(accountObj.Oracle_Party_Id__c);
                accountObj.HexaBPM__Portal_Balance__c = BalancefromOracle;
                accountObj.Portal_Balance_Last_Updated__c = system.now();
                update accountObj;
            }catch(Exception e){
                BalancefromOracle = 0;   
            }
            //decimal BalancefromOracle =  WS_BalanceCheck.GetOracleBalance(accountObj.Oracle_Party_Id__c);
            system.debug('BalancefromOracle==>'+BalancefromOracle);
            if(BalancefromOracle!=null)
                portalBalance = BalancefromOracle;
            
            if(ReceiptsAmount!=null)
                portalBalance = portalBalance + ReceiptsAmount;
                
           
            
            if(BlockedSRsAmount!=null)
                portalBalance = portalBalance - BlockedSRsAmount;
            portalBalance = portalBalance.setScale(2);*/
            
            //Added new balance functionality
            portalBalance = PortalBalanceCalculator.finalbalance(currentuser.Contact.AccountId);
            portalBalance = portalBalance.setScale(2);
            system.debug('portalBalance==>>' + portalBalance);
            accountName = accountObj.Name;
            OperatingName = accountObj.Name;
            if(accountObj.Total_Visas_Used__c!=null)
                TotalVisasUsed = accountObj.Total_Visas_Used__c;
            if(accountObj.Total_Visas_Allowed__c!=null)
                TotalVisasAllowed = accountObj.Total_Visas_Allowed__c;
        }
    }
    public list<string> getAccessibleServicesMenu(list<string> lstAccessibleService){
        list<string> showMenu = new list<string>();
        for(AccessADGM_Portal_Setting__mdt menuSetting : [select Services_Menu__c from AccessADGM_Portal_Setting__mdt 
                                                    where Type_Of_Service__c in :lstAccessibleService]){
        showMenu.addAll(menuSetting.Services_Menu__c.split(';'));
        }
        return showMenu;
    }
    
}