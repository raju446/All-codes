global without sharing class DED_Utility 
{
    public static void identifyDEDService(list<Account> TriggerNew,map<Id,Account> TriggerOldMap,map<Id,Account> TriggerNewMap)
    {
        set<id> issueBLFZEDIds  = new set<id>();
        set<id> renewBLFZED     = new set<id>();
        set<id> cancelBLFZED    = new set<id>();
        set<id> modifyBLFZED    = new set<id>();
        //set<string> CURRENTStatus = new set<string>{'Registered','Enters Administration','In administration','In Liquidation','In receivership'};
        //set<string> ONHOLDStatus = new set<string>{'Inactive','Registration Inactive'};
        //set<string> CANCELLEDStatus = new set<string>{'Struck-Off','Deregistered','Dissolved','Deregistered by Registrar','Continued outside ADGM'};
        for(Account acc : TriggerNew)
        {
        	system.debug('=rec type==='+acc.Record_Type_Name__c);
            if(acc.Record_Type_Name__c == 'ADGM_Registered_Company' && acc.Entity_Type__c != System.Label.DED_DNOT_Allow_Type)
            {
                //IssueBLFZED service.
                if((acc.DED_Status__c == 'Current' && TriggerOldMap.get(acc.id).DED_Status__c != 'Current'  && acc.Data_Pushed_to_DED__c == false))
                {
                    issueBLFZEDIds.add(acc.id);
                } 
                
                //RenewBLFZED Service
                else if(
                	(acc.DED_Status__c == 'Current' && acc.License_Expiry_Date__c != null && 
                    TriggerOldMap.get(acc.id).License_Expiry_Date__c != acc.License_Expiry_Date__c && TriggerOldMap.get(acc.id).License_Expiry_Date__c != null))
                {
                    Date previousDate = TriggerOldMap.get(acc.id).License_Expiry_Date__c;
                    Integer numberOfDays = previousDate.daysBetween(acc.License_Expiry_Date__c);
                    if(numberOfDays > 90)
                        renewBLFZED.add(acc.id);
                }
                //CancelBLFZED Service
                else if((acc.DED_Status__c == 'Cancelled' && TriggerOldMap.get(acc.id).DED_Status__c != 'Cancelled' && acc.License_Expiry_Date__c != null))
                {
                        cancelBLFZED.add(acc.id);
                }
                //ModifyBLFZED service.
                else if((acc.IssueBLFZEd__c == false && acc.Data_Pushed_to_DED__c == true &&
                    (acc.Name !=  TriggerOldMap.get(acc.id).Name ||
                    acc.Account_Name_Arabic__c != TriggerOldMap.get(acc.id).Account_Name_Arabic__c ||
                    acc.Entity_Type__c != TriggerOldMap.get(acc.id).Entity_Type__c || 
                    (acc.DED_Status__c == 'On Hold' && TriggerOldMap.get(acc.id).DED_Status__c != 'On Hold') || 
                    (acc.DED_Status__c == 'Current' && TriggerOldMap.get(acc.id).DED_Status__c == 'On Hold')
                    )
                ))
                {
                    modifyBLFZED.add(acc.id);
                }
            }
        }
        if(!issueBLFZEDIds.isEmpty()){
            DED_Utility.updateIssueBLFZED(issueBLFZEDIds,'Issue');
        }
        if(!renewBLFZED.isEmpty()){
            DED_Utility.updateIssueBLFZED(renewBLFZED,'Renew');
        }
        if(!cancelBLFZED.isEmpty()){
            DED_Utility.updateIssueBLFZED(cancelBLFZED,'Cancel');
        }
        if(!modifyBLFZED.isEmpty()){
            DED_Utility.updateIssueBLFZED(modifyBLFZED,'Modify');
        }
    }
    
    
    @future
    public static void updateIssueBLFZED(set<id> accids,string serviceIdentifier)
    {
        list<Account> updateAccounts = new list<Account>();
        for(Account acc : [Select Id FROM Account where ID IN:accids])
        {
            if(serviceIdentifier == 'Issue')
                acc.IssueBLFZEd__c = true;
            else if(serviceIdentifier == 'Renew')
                acc.RenewBLFZED__c = true;
            else if(serviceIdentifier == 'Cancel')
            {
                acc.CancelBLFZED__c = true;
                acc.Cancellation_Date__c = Date.today();
            }
            else if(serviceIdentifier == 'Modify')
                acc.ModifyBLFZED__c = true;
            updateAccounts.add(acc);
        }
        if(!updateAccounts.isEmpty()){
            update updateAccounts; 
        } 
    }
    webservice static void callDEDService(Id accountid, string servicetype)
    {
        if(accountid != null && servicetype != '')
        {
            string restricttype = System.Label.DED_DNOT_Allow_Type;//'Restricted Scope Company';
            string addresstype = 'Physical';
            string ownerEnType = 'Restricted Scope Company';
            string query = 'SELECT ID,DED_Status__c, LicenseStatusID__c,LegalTypeID__c, Name,Cancellation_Date__c, Account_Name_Arabic__c,Entity_Id__c, License_Expiry_Date__c, Entity_Type__c, Entity_Status__c, Registration_Date__c, '; 
            query += '(Select id,State__c, Street_Name_of_Cluster_on_the_Island__c, Building_Name__c from Addresses__r WHERE Type__c=:addresstype ), ';
            query += '(Select id, Actual_Activity_code__c, Status__c, Activity_Name_Arabic__c, Activity_Name__c from Business_Activities__r), ';
            query += '(Select id,OwnerTypeId__c,RelationshipTypeID__c, EDOwnerID__c, Owner_Full_Name_En__c, Owner_Type__c, RelationShip_Start_Date__c, Relationship_Status1__c, Relationship_Type__c FROM Entity_Owners__r WHERE Entity_Type__c !=:ownerEnType)';
            query += ' From Account where Entity_Type__c !=:restricttype and ID=:accountid limit 1';
            list<Account> acc = Database.query(query);
            Account updateacc = new Account();
            if(!acc.isEmpty())
            {
                if(servicetype == 'Issue')
                {
                    //list<DED_Sub_Log__c> logs = DED_ServicesHandler.issueBLFZEDServiceRequest(acc[0]);
                    list<DED_Sub_Log__c> logs = DED_RestServicesHelper.issueBLFZEDServiceRequest(acc[0]);
                    updateacc.id = acc[0].id;
                    for(DED_Sub_Log__c sl : logs)
                    {
                        if(sl.Message_Text__c == 'Success'){
                            updateacc.IssueBLFZEd__c = false;
                            updateacc.Data_pushed_to_DED__c = true;
                            update updateacc;
                            break;
                        }
                    }
                }
                else if(servicetype == 'Modify'){
                    //list<DED_Sub_Log__c> logs = DED_ServicesHandler_OnPrem.modifyBLFZEDServiceRequest(acc[0]);
                    list<DED_Sub_Log__c> logs = DED_RestServicesHelper.modifyBLFZEDServiceRequest(acc[0]);
                    updateacc.id = acc[0].id;
                    for(DED_Sub_Log__c sl : logs)
                    {
                        if(sl.Message_Text__c == 'Success'){
                            updateacc.ModifyBLFZED__c = false;
                            update updateacc;
                            break;
                        }
                    }
                }
                else if(servicetype == 'Renew'){
                    //list<DED_Sub_Log__c> logs = DED_ServicesHandler.renewBLFZEDServiceRequest(acc[0]);
                    list<DED_Sub_Log__c> logs = DED_RestServicesHelper.renewBLFZEDServiceRequest(acc[0]);
                    updateacc.id = acc[0].id;
                    for(DED_Sub_Log__c sl : logs)
                    {
                        if(sl.Message_Text__c == 'Success'){
                            updateacc.RenewBLFZED__c = false;
                            update updateacc;
                            break;
                        }
                    }
                }
                else if(servicetype == 'Cancel'){
                    //list<DED_Sub_Log__c> logs = DED_ServicesHandler.cancelBLFZEDServiceRequest(acc[0]);
                    list<DED_Sub_Log__c> logs = DED_RestServicesHelper.cancelBLFZEDServiceRequest(acc[0]);
                    updateacc.id = acc[0].id;
                    for(DED_Sub_Log__c sl : logs)
                    {
                        if(sl.Message_Text__c == 'Success'){
                            updateacc.CancelBLFZED__c = false;
                            update updateacc;
                            break;
                        }
                    }
                }
            }
        }
    }
}