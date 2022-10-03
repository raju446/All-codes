/*
    Author      : Durga Prasad
    Date        : 17-Sep-2017
    Description : Trigger Handler for Account Object
    --------------------------------------------------------------------------------------
    * @Change History
    * Author            Date            Description
    Jayanta Karmakar    19-Mar-2019     method to translate entity name English Fields to Arabic using Google API.
    Rajil Ravindran     30-Jun-2019     V1.1: Added the Golden Entity mapping for Execute_AI, Execute_AU method.
    Yogesh Mahajan      28-Aug-2019     V1.2: Added the Protal user check in Golden Entity calling method.
    Yogesh Mahajan      17-Jan-2020     v1.3: Added the oracle site id mapping logic
    Azmath              19-05-2020      DED Changes..
*/
public without sharing class AccountTriggerHandler {
    public static Map<String,Id> mapofAccountRecordTypeNameandId = new Map<String,Id>();
    public static void Execute_BI(list<Account> TriggerNew){
        if(System.Label.BM_AccountTriggerHandler == 'Yes'){
            Map<Id,String> mapofAccountRecordTypeIdAndName = new Map<Id,String>();
            mapofAccountRecordTypeIdAndName = ApexCodeUtility.getRecordTypeDetails('Account');
            for(Account acct:TriggerNew){
                
                acct.CRM_Record_Type_Name__c = mapofAccountRecordTypeIdAndName.get(acct.RecordTypeId);//
                System.debug('acct.CRM_Record_Type_Name__c>>'+acct.CRM_Record_Type_Name__c);
            }
            // FSRA Duplicate check
            checkDuplicate(TriggerNew);
            oracleSiteIdMapping(TriggerNew, mapofAccountRecordTypeIdAndName);
        }
    }
    public static void Execute_AI(list<Account> TriggerNew,map<Id,Account> TriggerOldMap){
        mapofAccountRecordTypeNameandId = ApexCodeUtility.getRecTypeDetails('Account');
        if(Label.Allow_Announcment_Creation == 'True')
        AccountTriggerHelper.CreateGeneralAnnouncements(TriggerNew);
        String BR_PRecordtypreId ;
        string goldenEntityRecTypeId ;
        List<Account> lstAct = new List<Account>();
        
        if(mapofAccountRecordTypeNameandId <> null && mapofAccountRecordTypeNameandId.values().size() > 0 && mapofAccountRecordTypeNameandId.containsKey('ADGM BR&P')) {
            BR_PRecordtypreId = mapofAccountRecordTypeNameandId.get('ADGM BR&P'); 
        } 
        if(System.Label.BM_AccountTriggerHandler == 'Yes'){
            if(mapofAccountRecordTypeNameandId <> null && mapofAccountRecordTypeNameandId.values().size() > 0 && mapofAccountRecordTypeNameandId.containsKey('Golden Entity')) {
                goldenEntityRecTypeId = mapofAccountRecordTypeNameandId.get('Golden Entity');
            }
        }
        
        //Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM BR&P').getRecordTypeId();
        if(!System.isFuture()) {
        
            List<Account> accLst = new List<Account>();
            for(Account acc : TriggerNew){
                if((acc.Account_Name_Arabic__c == null || acc.Account_Name_Arabic__c == '') && BR_PRecordtypreId <> null && acc.recordtypeid == BR_PRecordtypreId){
                    accLst.add(acc);
                }
                if(System.Label.BM_AccountTriggerHandler == 'Yes'){
                    if(acc.RecordTypeId != goldenEntityRecTypeId && acc.ParentId == null )
                        lstAct.add(acc);
                }
            }
            if(accLst.size() > 0){
                String s = JSON.serialize(accLst);
                translateField(s);
            }
            
            if(System.Label.BM_AccountTriggerHandler == 'Yes'){
                //V1.1: Creating the Golden Entity if record is not found using the DuplicateRule defined and linking the child records.
                if(ApexCodeUtility.isNotRecursive && lstAct != null && lstAct.size() > 0 && !currentUserIsPortal()){
                    AccountTriggerHelper.linkGoldenAccountParentId(lstAct,null);
                    ApexCodeUtility.isNotRecursive = false;
                }
                pushEntitiesToOracle(Trigger.new);
            }
        }
        
    }
    public static void Execute_BU(list<Account> TriggerNew,map<Id,Account> TriggerOldMap){
        if(System.Label.BM_AccountTriggerHandler == 'Yes'){
            Map<Id,String> mapofAccountRecordTypeIdAndName = new Map<Id,String>();
            mapofAccountRecordTypeIdAndName = ApexCodeUtility.getRecordTypeDetails('Account');
            oracleSiteIdMapping(TriggerNew, mapofAccountRecordTypeIdAndName);
            checkDuplicate(TriggerNew);
            
           for(Account acc : TriggerNew)
           {
                /*
                //LMM Changes..
                if(acc.Record_Type_Name__c == 'ADGM_Registered_Company' && acc.Entity_Status__c == 'Registered' 
                    && acc.Name != TriggerOldMap.get(acc.id).Name)
                {
                    acc.LMM_Date__c = Date.today();
                
                } */
                
                //CRM Changes..
               /* if(acc.Record_Type_Name__c == 'ADGM_Registered_Company' && acc.Name != TriggerOldMap.get(acc.id).Name)
                {
                    acc.Previous_Name__c = TriggerOldMap.get(acc.id).Name;
                } */
                
                if(acc.CRM_Record_Type_Name__c == null){
                	acc.CRM_Record_Type_Name__c = mapofAccountRecordTypeIdAndName.get(acc.RecordTypeId);
                }
            } 
        }
    }
    public static void Execute_AU(list<Account> TriggerNew,map<Id,Account> TriggerOldMap,map<Id,Account> TriggerNewMap){
        mapofAccountRecordTypeNameandId = ApexCodeUtility.getRecTypeDetails('Account');
        if(Label.Allow_CID_Approval == 'true'){
            AccountTriggerHelper.InitiateCIDApproval(TriggerNew,TriggerOldMap,TriggerNewMap);
            AccountTriggerHelper.CreateEstablishmentCardAlert(TriggerNew,TriggerOldMap);
        }
        String BR_PRecordtypreId ;
        string goldenEntityRecTypeId ;
        if(mapofAccountRecordTypeNameandId <> null && mapofAccountRecordTypeNameandId.values().size() > 0 && mapofAccountRecordTypeNameandId.containsKey('ADGM BR&P')) {
            BR_PRecordtypreId = mapofAccountRecordTypeNameandId.get('ADGM BR&P'); 
        } 
        
        if(System.Label.BM_AccountTriggerHandler == 'Yes'){
            if(mapofAccountRecordTypeNameandId <> null && mapofAccountRecordTypeNameandId.values().size() > 0 && mapofAccountRecordTypeNameandId.containsKey('Golden Entity')) {
                goldenEntityRecTypeId = mapofAccountRecordTypeNameandId.get('Golden Entity');
            }
        }
        
        system.debug('>>goldenEntityRecTypeId>>'+goldenEntityRecTypeId);
        List<Account> lstLinkAccount = new List<Account>();
        
        if(!System.isFuture()) 
        {
            //DED Changes..
            if(system.label.RunDEDIdentifyService == 'True'){
                DED_Utility.identifyDEDService(TriggerNew,TriggerOldMap,TriggerNewMap);
            }
            //DED Changes ends here..
            
            //CRM Change 1 & 2.
            set<string> acentityIds = new set<string>();
            set<string> eids = new set<string>();
            for(Account acc: TriggerNew)
            {
                //CRM change1 - Category C (Retail) changes.
               // Description : Create CRM Reg Entity when Category C of ADGM Reg entity status is changed to "Registered".
                if(acc.Category__c == 'Retail (Category C)' && acc.Record_Type_Name__c == 'ADGM_Registered_Company' && acc.Entity_Status__c == 'Registered' && TriggerOldMap.get(acc.id).Entity_Status__c != 'Registered'){
                    acentityIds.add(acc.Entity_Id__c);
                }
                
                //CRM Change 2 : 
               // Description: Update CRM Reg entity fields whenever there is a change in the ADGM Reg entity fields for all categories.
                if(acc.Record_Type_Name__c == 'ADGM_Registered_Company' && acc.Entity_Id__c != null && 
                        (acc.Entity_Status__c != TriggerOldMap.get(acc.id).Entity_Status__c || acc.Name != TriggerOldMap.get(acc.id).Name ||
                        acc.Registration_Date__c != TriggerOldMap.get(acc.id).Registration_Date__c ||
                        acc.License_Expiry_Date__c != TriggerOldMap.get(acc.id).License_Expiry_Date__c
                        ))
                {
                    eids.add(acc.Entity_Id__c);
                }
            }
            system.debug('====='+acentityIds);
            system.debug('====='+eids);
            if(!acentityIds.isEmpty()){
                CRM_CreateCRMRegEntity.createCategoryCEntities(acentityIds);
            }
            if(!eids.isEmpty()){
                CRM_CreateCRMRegEntity.updateCRMRegEntityStatus(eids);
            }
            // CRM Change 1 & 2 ends here..
            
            List<Account> accLst = new List<Account>();
            List<Account> listAccountForERP = new List<Account>();
            for(Account acc : TriggerNew){
                if((acc.Account_Name_Arabic__c == null || acc.Account_Name_Arabic__c == '' || (acc.Name != TriggerOldMap.get(acc.id).name && acc.Account_Name_Arabic__c == TriggerOldMap.get(acc.id).Account_Name_Arabic__c)) && BR_PRecordtypreId <> null && acc.recordtypeid == BR_PRecordtypreId){
                    accLst.add(acc);
                }
                if(System.Label.BM_AccountTriggerHandler == 'Yes'){
                    if(acc.Name <> TriggerOldMap.get(acc.id).name || acc.Source_System_Id__c <> TriggerOldMap.get(acc.id).Source_System_Id__c){
                        listAccountForERP.add(acc);
                    }
                    
                    if(acc.RecordTypeId != goldenEntityRecTypeId && acc.ParentId == null &&  TriggerOldMap.get(acc.id).ParentId == null)
                        lstLinkAccount.add(acc);
                }
            }
            if(System.Label.BM_AccountTriggerHandler == 'Yes'){
                if(ApexCodeUtility.isNotRecursiveForAccountUpdate && lstLinkAccount != null && lstLinkAccount.size() > 0 && !currentUserIsPortal()){
                    AccountTriggerHelper.linkGoldenAccountParentId(lstLinkAccount,TriggerOldMap);
                    ApexCodeUtility.isNotRecursiveForAccountUpdate = false;
                }
                if(listAccountForERP <> null && listAccountForERP.size() > 0){
                    pushEntitiesToOracle(listAccountForERP);        
                }
            }
            if(accLst.size() > 0){
                String s = JSON.serialize(accLst);
                translateField(s);
            }
        }
    }
    
    public static void Execute_AD(map<Id,Account> TriggerOldMap){
        //AccountTriggerHelper.removeDuplicate();
    }//end Execute_AD 
    
    /*
    Name : translateField
    Description : Translate account name using google api
    */
    @future (callout = true)
    public static void translateField(String accs){
        List<Account> accounts = (List<Account>)Json.deserialize(accs, List<Account>.class); 
        
        Http http1=new Http();
        HttpRequest req1=new HttpRequest();

        for(Account objAccount : accounts){

            string url = 'https://www.googleapis.com/language/translate/v2/?key='+Label.Google_API+'&source=en&target=ar&q='+EncodingUtil.URLENCODE(objAccount.Name,'UTF-8');
            req1.setendpoint(url);
            req1.setmethod('GET'); 
            HttpResponse res1;
            String str;
            try{
                res1 = http1.send(req1);
                str=res1.getbody();
                System.debug('str>>'+str);
                TranslateAPI objTranslateAPI = TranslateAPI.parse(str);
                
                objAccount.Account_Name_Arabic__c = objTranslateAPI.data.translations[0].translatedText;
            } catch(Exception e){

            }
            
        }
        try{
            update accounts;
        } catch (Exception e){
            
        }
    }
    /*
    Name : currentUserIsPortal
    Description : Get current user is portal user / not
    */
    public static Boolean currentUserIsPortal() {
        List<User> listUser = new List<User>();
        system.debug('=========='+UserInfo.getUserId());
        listUser = [SELECT ContactId FROM USER WHERE ID = :UserInfo.getUserId()];
        if(listUser <> null && listUser.size() > 0 && listUser[0].ContactId <> null) {
            return true;
        }
        return false;
    } 
    
    /*
    Name : oracleSiteIdMapping
    Description : Map oracle site before insert
     */
    public static void oracleSiteIdMapping(List<Account> listAccount, Map<Id,String> mapofAccountRecordTypeIdAndName) {
        // get custom metadata mapping
        Map<string, Oracle_Site_Id_Mapping__mdt> mapRecTypeNameWithSiteId = new Map<String, Oracle_Site_Id_Mapping__mdt>();
        for(Oracle_Site_Id_Mapping__mdt objOracleSiteIdMapping : [SELECT Entity_Record_Type_API_Name__c, Site_Id__c, Authority__c,Source_System__c FROM Oracle_Site_Id_Mapping__mdt]) {
            
            mapRecTypeNameWithSiteId.put(objOracleSiteIdMapping.Entity_Record_Type_API_Name__c, objOracleSiteIdMapping);
        }
        Map<String, Map<String, Id>> mapOperatingUnit = new Map<String, Map<String, Id>>();
        Map<String, Id> mapOperatingSourceSys;
        for(Operating_Unit__c objOperating_Unit : [Select id, Oracle_Site_Id__c, Source_System__c from Operating_Unit__c limit 100]) {
            mapOperatingSourceSys = new Map<String, Id>();
            if(mapOperatingUnit.get(objOperating_Unit.Oracle_Site_Id__c) <> null)
                mapOperatingSourceSys = mapOperatingUnit.get(objOperating_Unit.Oracle_Site_Id__c);
            if(objOperating_Unit.Source_System__c <> null) {
                String[] picklistValues = objOperating_Unit.Source_System__c.split(';');
                for(string sValues : picklistValues) {
                    mapOperatingSourceSys.put(sValues.trim(), objOperating_Unit.id);
                }
            }
            mapOperatingUnit.put(objOperating_Unit.Oracle_Site_Id__c, mapOperatingSourceSys);
        }
        if(mapofAccountRecordTypeIdAndName <> null && mapofAccountRecordTypeIdAndName.values().size() > 0 && mapRecTypeNameWithSiteId <> null && mapRecTypeNameWithSiteId.values().size() > 0) {
            //mapping the site id into entity
            for(Account objAcc : listAccount) {
                if(mapofAccountRecordTypeIdAndName.get(objAcc.RecordTypeId) <> null && mapRecTypeNameWithSiteId.get(mapofAccountRecordTypeIdAndName.get(objAcc.RecordTypeId)) <> null) {
                    if(mapRecTypeNameWithSiteId.get(mapofAccountRecordTypeIdAndName.get(objAcc.RecordTypeId)).Site_Id__c <> null && mapRecTypeNameWithSiteId.get(mapofAccountRecordTypeIdAndName.get(objAcc.RecordTypeId)).Site_Id__c <> '')
                        objAcc.Oracle_Site_Id__c = mapRecTypeNameWithSiteId.get(mapofAccountRecordTypeIdAndName.get(objAcc.RecordTypeId)).Site_Id__c;
                    if(mapRecTypeNameWithSiteId.get(mapofAccountRecordTypeIdAndName.get(objAcc.RecordTypeId)).Authority__c <> null && mapRecTypeNameWithSiteId.get(mapofAccountRecordTypeIdAndName.get(objAcc.RecordTypeId)).Authority__c <> '')
                        objAcc.Source_System_Name__c = mapRecTypeNameWithSiteId.get(mapofAccountRecordTypeIdAndName.get(objAcc.RecordTypeId)).Authority__c;
                    if(mapRecTypeNameWithSiteId.get(mapofAccountRecordTypeIdAndName.get(objAcc.RecordTypeId)).Source_System__c <> null && mapRecTypeNameWithSiteId.get(mapofAccountRecordTypeIdAndName.get(objAcc.RecordTypeId)).Source_System__c <> '' && (objAcc.Source_System__c == null || objAcc.Source_System__c == '' ))
                        objAcc.Source_System__c = mapRecTypeNameWithSiteId.get(mapofAccountRecordTypeIdAndName.get(objAcc.RecordTypeId)).Source_System__c;
                }
                if(objAcc.Oracle_Site_Id__c <> null && objAcc.Oracle_Site_Id__c <> '' && mapOperatingUnit <> null 
                   && mapOperatingUnit.get(objAcc.Oracle_Site_Id__c) <> null && (mapOperatingUnit.get(objAcc.Oracle_Site_Id__c)).get(objAcc.Source_System__c) <> null ) {
                    objAcc.Operating_Unit__c = (mapOperatingUnit.get(objAcc.Oracle_Site_Id__c)).get(objAcc.Source_System__c);
                }
            }
        }
        
    }
    
    public static void pushEntitiesToOracle(List<Account> listAccount) {
        
        // get custom metadata mapping
        Set<Id> setRecordTypeIds = new Set<Id>();
        for(Oracle_Site_Id_Mapping__mdt objOracleSiteIdMapping : [SELECT Entity_Record_Type_API_Name__c, Site_Id__c, Entity_Record_Type_Name__c FROM Oracle_Site_Id_Mapping__mdt where Is_Synch_from_Tigger__c = true]) {
            if(string.isNotBlank(objOracleSiteIdMapping.Entity_Record_Type_Name__c) && mapofAccountRecordTypeNameandId <> null && mapofAccountRecordTypeNameandId.get(objOracleSiteIdMapping.Entity_Record_Type_Name__c) <> null) {
                setRecordTypeIds.add(mapofAccountRecordTypeNameandId.get(objOracleSiteIdMapping.Entity_Record_Type_Name__c));
            }
        }
        
        
        List<String> listEntitiesFirst = new List<String>();
        List<String> listEntitiesSecound = new List<String>();
        Integer recordCount = 1;
        for(Account objAccount : listAccount) {
            if(!objAccount.Is_Manually_Created__c && objAccount.Oracle_Party_Id__c==null){
                if(objAccount.RecordTypeId <> null && setRecordTypeIds.contains(objAccount.RecordTypeId)) {
                    if(recordCount <= 100){
                        listEntitiesFirst.add(objAccount.id);
                    }
                    
                    if(recordCount > 100 && recordCount <= 200){
                        listEntitiesSecound.add(objAccount.id);
                    }
                    
                    recordCount++;
                    if(recordCount == 200){
                        break;
                    }
                }   
            }             
        }//end for
        // send first 100 accounts to oracle 
        if(listEntitiesFirst <> null && listEntitiesFirst.size() > 0){
            EntityUtil.PushEntityToOracle_Future(listEntitiesFirst);  
        }
           
        // send from 100 - 200 accounts to oracle 
        if(listEntitiesSecound <> null && listEntitiesSecound.size() > 0){
            EntityUtil.PushEntityToOracle_Future(listEntitiesSecound);     
        }
        
    }
    
    
    public static void checkDuplicate(List<Account> listAccount ) {
        
        mapofAccountRecordTypeNameandId = ApexCodeUtility.getRecTypeDetails('Account');
        string fsraRecTypeId = '',  fintechRecType = '', academyRecType = '', adgmRecType = '', fourteenthRecType ='', innovationType = '';
        Map<String, Account> mapofAccountName = new Map<String,Account>();
        Map<String, Account> mapofFintechAccountName = new Map<String,Account>();
        Map<String, Account> mapofAcademyAccountName = new Map<String,Account>();
        Map<String, Account> mapofADGMAccountName = new Map<String,Account>();
        Map<String, Account> mapofFourteenthAccountName = new Map<String,Account>();
        Map<String, Account> mapofInnovationAccountName = new Map<String,Account>();
        List<Id> listAccId = new List<Id>();
        List<Id> listFintechAccId = new List<Id>();
        List<Id> listAcademyAccId = new List<Id>();
        List<Id> listADGMAccId = new List<Id>();
        List<Id> listFourteenthAccId = new List<Id>();
        List<Id> listInnovationAccId = new List<Id>();
        if(mapofAccountRecordTypeNameandId <> null && mapofAccountRecordTypeNameandId.values().size() > 0 ) {
            fsraRecTypeId = mapofAccountRecordTypeNameandId.get('ADGM FSRA'); 
            academyRecType  = mapofAccountRecordTypeNameandId.get('ADGM Academy');
            fintechRecType = mapofAccountRecordTypeNameandId.get('ADGM Fintech');
            adgmRecType = mapofAccountRecordTypeNameandId.get('ADGM');
            fourteenthRecType = mapofAccountRecordTypeNameandId.get('Fourteenth Bridge Restricted');
            innovationType = mapofAccountRecordTypeNameandId.get('Abu Dhabi Innovation Center');
            for(Account objAccount: listAccount){
                // fsra
                if(objAccount.recordtypeId == fsraRecTypeId) {
                   
                    //Make sure another new account isn't also a duplicate  
                    if (mapofAccountName.containsKey(objAccount.Name)) {
                        objAccount.Name.addError('Duplicate Record Found');
                    } else {
                        mapofAccountName.put(objAccount.Name, objAccount);
                    }
                    if(objAccount.id <> null)
                        listAccId.add(objAccount.id);
                }
                // academy
                if(objAccount.recordtypeId == academyRecType) {
                   
                    //Make sure another new account isn't also a duplicate  
                    if (mapofAcademyAccountName.containsKey(objAccount.Name)) {
                        objAccount.Name.addError('Duplicate Record Found');
                    } else {
                        mapofAcademyAccountName.put(objAccount.Name, objAccount);
                    }
                    if(objAccount.id <> null)
                        listAcademyAccId.add(objAccount.id);
                }
                // fintech
                if(objAccount.recordtypeId == fintechRecType) {
                   
                    //Make sure another new account isn't also a duplicate  
                    if (mapofFintechAccountName.containsKey(objAccount.Name)) {
                        objAccount.Name.addError('Duplicate Record Found');
                    } else {
                        mapofFintechAccountName.put(objAccount.Name, objAccount);
                    }
                    if(objAccount.id <> null)
                        listFintechAccId.add(objAccount.id);
                }
                // ADGM
                if(objAccount.recordtypeId == adgmRecType) {
                   
                    //Make sure another new account isn't also a duplicate  
                    if (mapofADGMAccountName.containsKey(objAccount.Name)) {
                        objAccount.Name.addError('Duplicate Record Found');
                    } else {
                        mapofADGMAccountName.put(objAccount.Name, objAccount);
                    }
                    if(objAccount.id <> null)
                        listADGMAccId.add(objAccount.id);
                }
                //Fourteenth 
                if(objAccount.recordtypeId == fourteenthRecType) {
                   
                    //Make sure another new account isn't also a duplicate  
                    if (mapofFourteenthAccountName.containsKey(objAccount.Name)) {
                        objAccount.Name.addError('Duplicate Record Found');
                    } else {
                        mapofFourteenthAccountName.put(objAccount.Name, objAccount);
                    }

                    if(objAccount.id <> null)
                        listFourteenthAccId.add(objAccount.id);
                }
                
                //innovationType 
                if(objAccount.recordtypeId == innovationType) {
                   
                    //Make sure another new account isn't also a duplicate  
                    if (mapofInnovationAccountName.containsKey(objAccount.Name)) {
                        objAccount.Name.addError('Duplicate Record Found');
                    } else {
                        mapofInnovationAccountName.put(objAccount.Name, objAccount);
                    }
                    if(objAccount.id <> null)
                        listInnovationAccId.add(objAccount.id);
                }
            }
            
            
            
            //Query to find all the Accounts in the database that have the same name as any of the Accounts being inserted or updated.  
            for (Account acc : [SELECT Name, recordtypeId FROM Account WHERE (Name IN :mapofAccountName.KeySet() AND ID NOT IN:listAccId AND recordtypeid = :fsraRecTypeId) 
                                OR (Name IN :mapofAcademyAccountName.KeySet() AND ID NOT IN:listAcademyAccId AND recordtypeid = :academyRecType)
                               OR (Name IN :mapofFintechAccountName.KeySet() AND ID NOT IN:listFintechAccId AND recordtypeid = :fintechRecType)
                               OR (Name IN :mapofADGMAccountName.KeySet() AND ID NOT IN:listADGMAccId AND recordtypeid = :adgmRecType)
                               OR (Name IN :mapofFourteenthAccountName.KeySet() AND ID NOT IN:listFourteenthAccId AND recordtypeid = :fourteenthRecType)
                               OR (Name IN :mapofInnovationAccountName.KeySet() AND ID NOT IN:listInnovationAccId AND recordtypeid = :innovationType)]) {
                                   if(acc.recordtypeId == fsraRecTypeId) {
                                       Account newAcc = mapofAccountName.get(acc.Name);
                                       if(newAcc <> null)
                                        newAcc.Name.addError('Duplicate Record Found');
                                   }
                                   
                                   if(acc.recordtypeId == academyRecType) {
                                       Account newAcc = mapofAcademyAccountName.get(acc.Name);
                                       if(newAcc <> null)
                                            newAcc.Name.addError('Duplicate Record Found');
                                   }
                                   
                                   if(acc.recordtypeId == fintechRecType) {
                                       Account newAcc = mapofFintechAccountName.get(acc.Name);
                                       if(newAcc <> null)
                                        newAcc.Name.addError('Duplicate Record Found');
                                   }
                                   if(acc.recordtypeId == adgmRecType) {
                                       Account newAcc = mapofADGMAccountName.get(acc.Name);
                                       if(newAcc <> null)
                                            newAcc.Name.addError('Duplicate Record Found');
                                   }
                                   
                                   if(acc.recordtypeId == fourteenthRecType) {
                                       Account newAcc = mapofFourteenthAccountName.get(acc.Name);
                                       if(newAcc <> null)
                                            newAcc.Name.addError('Duplicate Record Found');
                                   }
                                   if(acc.recordtypeId == innovationType) {
                                       Account newAcc = mapofInnovationAccountName.get(acc.Name);
                                       if(newAcc <> null)
                                            newAcc.Name.addError('Duplicate Record Found');
                                   }
            }
        }
    }
}