/*
    Author      : Kim Noceda
    Date        : 07-Jan-2017
    Description : Trigger handler class that is being referenced in the AccountTriggerHandler.
                  All DML methods are being handled in this handler class.
    --------------------------------------------------------------------------------------
     * @Change History
    * Author            Date            Description
    Rajil Ravindran     19-Aug-2019     V1.1: ISSUE-000302 : Condition added to check if Establishment card exists before triggering name change email and freezing functionality.
*/
public without sharing class AccountTriggerHelper {

    /*
        Method Name :   InitiateCIDApproval
        Description :   Method to Initiate CID Approval for the Entity.
    */
    public static void InitiateCIDApproval(List<Account> accountList, Map<Id, Account> oldAccountMap, Map<Id, Account> newAccountMap)
    {
        
        Id cidRectypeId;
        Id regCompRecTypeId;
        List<HexaBPM__Service_Request__c> objSRList = new List<HexaBPM__Service_Request__c>();
        set<id> accountids = new set<id>();
        list<Account> accLst = new list<Account>();
        
        for(RecordType rt : [SELECT Id FROM Recordtype WHERE SObjectType = 'Account' AND (DeveloperName = 'ADGM_Registered_Company')])
        {
            regCompRecTypeId = rt.id;
        }
        for(RecordType rectype : [SELECT Id from RecordType WHERE sObjectType='HexaBPM__Service_Request__c' AND DeveloperName=:Label.Initial_Approval_Recordtype_API AND IsActive=true]){
             cidRectypeId = rectype.Id;
        }
        for(Account objAcct : [SELECT Id, Name, License_Expiry_Date__c,Entity_Id__c,Account_Name_Arabic__c,Establishment_Card__c                                        
                                        FROM Account WHERE Id IN :newAccountMap.keyset() and Recordtypeid=:regCompRecTypeId])
        {
            if(
                ((objAcct.Name != oldAccountMap.get(objAcct.Id).Name) ||(objAcct.Account_Name_Arabic__c != oldAccountMap.get(objAcct.Id).Account_Name_Arabic__c)) && 
                objAcct.License_Expiry_Date__c != null 
                )
            {
                HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
                if(cidRectypeId!=null)
                    objSR.RecordtypeId = cidRectypeId;
                objSR.HexaBPM__Customer__c = objAcct.Id;
                objSR.HexaBPM__Email__c = UserInfo.getUserEmail();
                objSR.License_Number__c = objAcct.Entity_Id__c;
                objSR.HexaBPM__Auto_Submit__c = true;
                objSR.IA_Reason__c = 'Name Change';
                objSRList.add(objSR);
                //V1.1: Trigger Name Change Email only when Establishment Card exists for an Entity.
                if(objAcct.Establishment_Card__c != null){
                    objAcct.IsEntityChanged__c = true;
                    accLst.add(objAcct);
                    accountids.add(objAcct.id);
                }
            }
        }
        try{
            if(!objSRList.isEmpty())
                insert objSRList;
            
            if(!accLst.isEmpty()){
                update accLst;
                
                Future_Handler.notifyPortalUsers(accountids);
            }
        }catch(Exception e){
            System.debug('##Error: '+e.getMessage());
        }
        
        
        /*List<HexaBPM__Service_Request__c> objSRList = new List<HexaBPM__Service_Request__c>();
        Id cidRectypeId;
        List<User> currentUser = [SELECT Id, UserType, Email FROM User WHERE Id = :Userinfo.getUserId() LIMIT 1];
        if(!currentUser.isEmpty()){
            if(currentUser[0].UserType == 'Standard'){
                for(RecordType rectype : [SELECT Id from RecordType WHERE sObjectType='HexaBPM__Service_Request__c' AND DeveloperName=:Label.Initial_Approval_Recordtype_API AND IsActive=true]){
                   cidRectypeId = rectype.Id;
                }
                Map<Id,Boolean> accountCIDMap = new Map<Id,Boolean>();
                for(Account objAcct : [SELECT Id, Name, License_Expiry_Date__c,
                                        (SELECT Id FROM Relationships__r WHERE Status__c = 'Active' AND Type__c = 'Authorised Signatory' LIMIT 1),
                                        (SELECT Id from Business_Activities__r LIMIT 1)
                                        FROM Account WHERE Id IN :newAccountMap.keyset()]){
                    if(((objAcct.Name != oldAccountMap.get(objAcct.Id).Name) && oldAccountMap.get(objAcct.Id).Name != null && objAcct.License_Expiry_Date__c != null) || 
                        ((objAcct.License_Expiry_Date__c != oldAccountMap.get(objAcct.Id).License_Expiry_Date__c) && oldAccountMap.get(objAcct.Id).License_Expiry_Date__c != null)){
                        Boolean isInitialAppAllowed = true;
                        if(objAcct.Relationships__r.size() == 0 || objAcct.Business_Activities__r.size() == 0){
                            isInitialAppAllowed = false;
                        }
                        accountCIDMap.put(objAcct.Id, isInitialAppAllowed);
                    }
                }
                for(Account objAcct : accountList){
                    if(((objAcct.Name != oldAccountMap.get(objAcct.Id).Name) && oldAccountMap.get(objAcct.Id).Name != null && objAcct.License_Expiry_Date__c != null) || 
                        ((objAcct.License_Expiry_Date__c != oldAccountMap.get(objAcct.Id).License_Expiry_Date__c) && oldAccountMap.get(objAcct.Id).License_Expiry_Date__c != null)){
                        if(accountCIDMap.containskey(objAcct.Id)){
                            if(accountCIDMap.get(objAcct.Id) == true){
                                HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
                                if(cidRectypeId!=null)
                                    objSR.RecordtypeId = cidRectypeId;
                                objSR.HexaBPM__Customer__c = objAcct.Id;
                                objSR.HexaBPM__Email__c = currentUser[0].Email;
                                objSR.License_Number__c = objAcct.Entity_Id__c;
                                objSR.HexaBPM__Auto_Submit__c = true;
                                objSRList.add(objSR);
                            }
                        }
                    }
                }
                
                if(!objSRList.isEmpty()){
                    Savepoint sp = Database.setSavepoint();
                    try{
                        insert objSRList;
                    } catch(Exception e){
                        System.debug('##Error: '+e.getMessage());
                        Database.rollback(sp);
                    }
                    
                    
                }
            }
        }*/
    }
    /*
        Method Name :   Create Alert for Establishment Card
        Description :   Method to Create an alerrt on the Entity for the Establishment card
    */
    public static void CreateEstablishmentCardAlert(List<Account> accountList, Map<Id, Account> oldAccountMap)
    {
        /*System.debug('@@ESTABLISHMENT');
        Boolean isForEstablishmentCard = false;
        String alertRecordtype = ''; 
        for(Account objAcct : accountList){
            if(objAcct.Initial_Approval_Flag__c != oldAccountMap.get(objAcct.Id).Initial_Approval_Flag__c && 
                objAcct.Initial_Approval_Flag__c == TRUE){
                isForEstablishmentCard = true;
            }
        }
        
        if(isForEstablishmentCard == true){
            List<Recordtype> alertRectype = [SELECT Id FROM Recordtype WHERE SObjecttype = 'Notice__c' AND DeveloperName = 'Alert' LIMIT 1];
            if(alertRectype.size() > 0 && alertRectype != null){
                alertRecordtype = alertRectype[0].Id;
            }
        }*/
        //As per Riddhi, the below code no need to execute.
        /*
        List<Notice__c> alertList = new List<Notice__c>();
        for(Account objAcct : accountList){
            if(objAcct.Initial_Approval_Flag__c != oldAccountMap.get(objAcct.Id).Initial_Approval_Flag__c && 
                objAcct.Initial_Approval_Flag__c == TRUE){
                Notice__c objAlert = new Notice__c();
                objAlert.Entity__c = objAcct.Id;
                objAlert.Type__c = 'Company Alert';
                objAlert.Available_for__c = 'Company User';
                objAlert.Title__c = 'Your Establishment card is due for renewal.';
                objAlert.Start_Date__c = System.today();
                objAlert.End_Date__c = System.today().addDays(7);
                objAlert.Status__c = 'Active';
                objAlert.Alert_Text__c = 'Your Establishment card is due for renewal.';
                if(alertRecordtype != ''){
                    objAlert.RecordtypeId = alertRecordtype;
                }
                alertList.add(objAlert);
            }
        }
        if(!alertList.isEmpty()){
            try{
                insert alertList;
            } catch(Exception e){
                System.debug('##ERROR: '+e.getMessage());
            }
        }*/
    }
    /*
        Method Name :   CreateDependentNotFoundContact
        Description :   Method to create dependent not found contact on insert of Registered company entity
    */
    /*public static void CreateDependentNotFoundContact(List<Account> accountList){
        List<Recordtype> registeredCompanyEntityRectype = [SELECT Id FROM Recordtype WHERE SObjectType = 'Account' AND DeveloperName = 'ADGM_Registered_Company' LIMIT 1];
        List<Recordtype> dependentContactRectype = [SELECT Id FROM Recordtype WHERE SObjectType = 'Contact' AND DeveloperName = 'Contact_Dependent' LIMIT 1];
        
        Set<Id> entityIds = new Set<Id>(); 
        for(Account objAcct : accountList){
            if(objAcct.RecordtypeId == registeredCompanyEntityRectype[0].Id){
                entityIds.add(objAcct.Id);
            }
        }
        
        Set<Id> entityHasExisting = new Set<Id>(); 
        for(Contact objCon : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :entityIds AND Dependent_not_found__c = TRUE]){
            entityHasExisting.add(objCon.AccountId);
        }
        
        List<Contact> dependentContactNotFoundList = new List<Contact>();
        for(Account objAcct : accountList){
            if(objAcct.RecordtypeId == registeredCompanyEntityRectype[0].Id && !entityHasExisting.contains(objAcct.Id)){
                Contact objCon = new Contact();
                objCon.RecordtypeId = dependentContactRectype[0].Id;
                objCon.AccountId = objAcct.Id;
                objCon.LastName = 'Dependent not found';
                objCon.Dependent_not_found__c = true;
                dependentContactNotFoundList.add(objCon);
            }
        }
        
        if(!dependentContactNotFoundList.isEmpty()){
            try{
                insert dependentContactNotFoundList;
            } catch(Exception e){
                System.debug('##ERROR: '+e.getMessage());
            }
        }
    }*/
    
     /*
        Method Name :   CreateGeneralAnnouncements
        Description :   Method to Create general announcements for newly created Entities
    */
    public static void CreateGeneralAnnouncements(List<Account> accountList)
    {
      set<id> recTIds = new set<id>();
      for(RecordType rt : [SELECT Id FROM Recordtype WHERE SObjectType = 'Account' AND (DeveloperName = 'ADGM_Guest' OR DeveloperName = 'ADGM_Registered_Company')])
      {
        recTIds.add(rt.id);
      }
          List<Recordtype> announcementRectype = new List<Recordtype>();
          if(accountList.size() > 0){
              announcementRectype = [SELECT Id FROM Recordtype WHERE SObjectType = 'Notice__c' AND DeveloperName = 'Announcement' LIMIT 1];
          }
          
          if(!announcementRectype.isEmpty()){
              String querySRStr = queryAllNoticeFields(announcementRectype[0].Id);
              List<Notice__c> announcementList;// = new list<Notice__c>();//Database.query(querySRStr);
              if(System.Label.BM_AccountTriggerHandler == 'Yes'){
                    announcementList = new list<Notice__c>();
              } else {
                    announcementList = Database.query(querySRStr);    
              }
              if(announcementList.size() > 0){
                  List<Notice__c> announcementsToBeInserted = new List<Notice__c>();
                  Map<Id,Notice__c> announcementMap = new Map<Id,Notice__c>();
                  for(Notice__c objAnn : announcementList){
                      announcementMap.put(objAnn.Id,objAnn);
                  }
                  
                  for(Account objAcct : accountList)
                  {
                    if(recTIds.contains(objAcct.recordtypeid))
                    {
                        for(Id key : announcementMap.keyset()){
                            Notice__c objNotice = announcementMap.get(key).clone();
                            objNotice.Entity__c = objAcct.Id;
                            announcementsToBeInserted.add(objNotice);
                        }
                    }
                  }
                  
                  if(!announcementsToBeInserted.isEmpty()){
                      try{
                          insert announcementsToBeInserted;
                      } catch(Exception e){
                          system.debug('##ERROR: '+e.getMessage());
                          accountList[0].addError(e.getMessage());
                      }
                  }
              }
          }
    }
    
    
     /*
        Method Name :   findDuplicate
        Description :   Used to find and mark the duplicate account
    */
    public static void findDuplicate() {
        //DuplicateCheck.processAccount(((Map<Id, Account>) Trigger.NewMap).Keyset());
    }
    
    /*
        Method Name :   findDuplicate
        Description :   Used to find and mark the duplicate account
    */
    public static void removeDuplicate() {
        //DuplicateCheck.updateDuplicateAccount((Map<Id, Account>) Trigger.OldMap, false);
        //
        /*
        Map<Id, Account> mapAccount = new Map<Id, Account>();
        mapAccount = (Map<Id, Account>)Trigger.newMap;
        Set<Id> setMasterAccIds = new set<Id>();
        for (Account objAccount : [SELECT id, MasterRecordId
                                  FROM account 
                                  WHERE LastModifiedDate = LAST_N_DAYS:1 
                                   AND MasterRecordId IN: mapAccount.KeySet() ALL ROWS]) {
                setMasterAccIds.add(objAccount.MasterRecordId);
        }//end for
        
        for(Id objAccountId : setMasterAccIds) {
            if(mapAccount.get(objAccountId) <> null && mapAccount.get(objAccountId).Is_Duplicate__c ) {
                mapAccount.get(objAccountId).Is_Duplicate__c = false;
            }//end if   
        }//end for
*/
    }//end removeDuplicate()
    
    public static string queryAllNoticeFields(String recordtypeId){
        String queryStr = 'SELECT ';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Notice__c').getDescribe().fields.getMap();
        for(String s : objectFields.keySet()) {
           queryStr += ' ' + s + ', ';
        }
        queryStr = queryStr.subString(0,queryStr.Length()-2);
        queryStr += ' FROM Notice__c';
        queryStr += ' WHERE Entity__c = null';
        queryStr += ' AND Publish__c = true';
        queryStr += ' AND RecordtypeId  =  \''+recordtypeId+'\'';
        
        return queryStr;
    }
    
    /**
    Version: V1.1
    Description: Finds the Duplicate Account and returns the result in Map. 
    @param: accs - This is the paramter holding List of Accounts.
    @returns map - This returns the AccountName and the Fuzzy Duplicate AccountID (First match record) found from the Duplicate Rule.
    */
    public static map<string, List<Id>> findAccounts(List<Account> accs) { 
        map<string, List<Id>> mapParentAccount = new map<string, List<Id>>();
        Id parentAcctId;
        List<Datacloud.FindDuplicatesResult> results;
        try {
            results = Datacloud.FindDuplicates.findDuplicates(accs);
            System.debug('results>>'); 
            System.debug(results);
        } catch (Exception ex) {
            accs[0].addError(ex.getMessage());
            //return null;
        }
        if(results != null && results.size() > 0){
            for (Integer i = 0; i < accs.size(); i++) {
                Account foundAcct = new Account();
                List<Id> listAccountId = new List<Id>();
                parentAcctId = null;
                // Find the first duplicate result with a match result, then use the first match record.
                for(Datacloud.DuplicateResult dr : results[i].getDuplicateResults()){
                    System.debug('dr>>>>');
                    System.debug(dr);
                    System.debug('dr.matchResults.size()>>>>'+dr.matchResults.size());
                    System.debug('dr.getMatchResults()[0].matchRecords.size()>>>>'+dr.getMatchResults()[0].matchRecords.size());
                    if (dr.matchResults.size() > 0 && dr.getMatchResults()[0].matchRecords.size() > 0) {
                        System.debug('foundAcct>>'+foundAcct);
                        for(Datacloud.MatchRecord objMatchRecord : dr.getMatchResults()[0].getMatchRecords()) {
                            System.debug('accs[i].id>>>>'+accs[i]);
                            system.debug('((Account)objMatchRecord.getRecord()).id>>>'+((Account)objMatchRecord.getRecord()).id);
                            //if(accs[i].id != ((Account)objMatchRecord.getRecord()).id)
                                listAccountId.add(((Account)objMatchRecord.getRecord()).id);
                        }
                        foundAcct = (Account) dr.getMatchResults()[0].getMatchRecords()[0].getRecord();
                        parentAcctId = foundAcct.id;
                        break;
                    }
                }
                mapParentAccount.put(accs[i].Name,listAccountId);
            }
        }

        return mapParentAccount;
    }
    /**
    Version: V1.1
    Description: Links the Account to an existing Golden Account if any found. If not found, create a GoldenEntity and link the incoming account to this. 
    @param: accountList - This is the paramter holding List of Accounts passed to find Golden Account.
    @param: oldAccountMap - This is the paramter holding map of Accounts - required if method is invoked from an update trigger.
    @returns void - Void.
    */
    public static void linkGoldenAccountParentId(List<Account> accountList, Map<Id, Account> oldAccountMap){
        System.debug('linkGoldenAccountParentId>>>');
        List<Account> lstAct = new List<Account>();
        List<Account> lstUpdateParentIdForAcct = new List<Account>();
        List<Account> lstGoldenAccount = new List<Account>();
        string goldenEntityRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Golden Entity').getRecordTypeId();
        //mapParentAccount: This map contains the key as EntityName and Value as the GoldenEntityId if found any from the duplicate rule.
        map<string, List<Id>> mapParentAccount = new map<string,List<Id>>();
        for(Account acc : accountList){
            Account acctObj = new Account();
            //acctObj.id = acc.id;
            acctObj.Name = acc.Name;
            acctObj.ownerid= system.label.Golden_Entity_OwnerId;
            acctObj.CRM_Record_Type_Name__c = 'CRM_Golden_Entity';
            acctObj.RecordTypeId = goldenEntityRecTypeId;
            lstAct.add(acctObj);
        }
        System.debug('lstAct>>>>');
        System.debug(lstAct);
        mapParentAccount = AccountTriggerHelper.findAccounts(lstAct); //Checks for fuzzy golden account for the incoming account
        System.debug('mapParentAccount>>>>'+mapParentAccount);
        for(String strActName : mapParentAccount.keySet()) {
            System.debug(strActName + '>>>>'+mapParentAccount.get(strActName));
            if(mapParentAccount.get(strActName) == null || mapParentAccount.get(strActName).size() == 0){
                System.debug('creating Golden Entity:'+strActName);
                //Creating the Golden Entity if the record is not found in the Duplicate Rule.
                Account goldenAct = new Account();
                goldenAct.recordTypeId = goldenEntityRecTypeId;
                goldenAct.Name = strActName;
                lstGoldenAccount.add(goldenAct);
            }
        }
        System.debug('lstGoldenAccount.size()>>'+lstGoldenAccount.size());
        System.debug('ApexCodeUtility.isNotRecursive>>>>>'+ApexCodeUtility.isNotRecursive);
        //Inserting the lstGoldenAccount List.
        if(lstGoldenAccount != null && lstGoldenAccount.size() > 0){
            list<Database.SaveResult> AccSVResult = Database.insert(lstGoldenAccount);
            set<string> setAccountIds = new set<string>();          
            if(AccSVResult!=null){
                for(Database.SaveResult sr : AccSVResult){
                    if(sr.isSuccess())
                        setAccountIds.add(sr.getId());
                }
            }
            if(setAccountIds.size()>0){
                for(Account acc:[Select Id,Name from Account where Id IN:setAccountIds]){
                    mapParentAccount.put(acc.Name,new list<Id>{acc.Id});
                }
            }
        }
        //Mapping the Golden EntityId to the Map:mapParentAccount (key is 'EntityName') for the newly created GoldenEntity
        /*
        for(Account acct : lstGoldenAccount){
            mapParentAccount.put(acct.Name, new List<Id>{acct.id});
        }
        */
        List<Account> lstUpdateParentAccount = new List<Account>();
        for(Account acc : accountList){
            if(mapParentAccount.get(acc.Name) != null && mapParentAccount.get(acc.Name).size() > 0 ){
                Account actObj  = new Account(Id = acc.Id);
                actObj.ParentId = mapParentAccount.get(acc.Name)[0];
                lstUpdateParentAccount.add(actObj);
            }
        }
        System.debug('lstUpdateParentAccount>>>>');
        System.debug(lstUpdateParentAccount);
        if(lstUpdateParentAccount != null && lstUpdateParentAccount.size() > 0){
            update lstUpdateParentAccount;
        }
    }
}