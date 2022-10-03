/*
    Author      :   Yogesh Mahajan 
    Class Name  :   MergeAccountsController
    Description :   It is used as a controller for the merge page. This class is to search the duplicate entities by name and merge entities. 
    Date        :   02/05/2019
*/
public without sharing class MergeAccountsController {
    public static final string SUCCESS_MSG = 'Success';
    public static final string FAILED_MSG = 'Failed';

    @AuraEnabled
    public static List<LEX_Helper.PicklistValueWrapper> fetchPickListValue(String fieldAPIname){
        return LEX_Helper.getPicklistValues('Account', fieldAPIname, false);
    }
    
    /*
    Name : getCurrentAccount
    Description : get current entity detail
    */
    @AuraEnabled
    public static List<Account> getCurrentAccount(Id recordId) {
        return [SELECT Name
                        , Phone
                        , Website
                        , Email__c
                        , Id 
                FROM Account 
                WHERE Id =: recordId];
    }//end getCurrentAccount
    
    /*
    Name : getSearchResult
    Description : get entity search result
    */
    @AuraEnabled
    public static List<EntityWrapper> getSearchResult(String recordId, List<EntityWrapper> listCurrentAccounts, String sName, String sEmail, String sPhone, String sWebsite, String siteid) {
        
        // get golden entity
		String goldenRectypeId = getAccountRecTypeId('Golden Entity');
        List<EntityWrapper> enWrapperLst = new List<EntityWrapper>();
        List<Account> listAccount = new List<Account>();
        Map<Id, Account> mapAccountDetails = new Map<Id, Account>();//(listCurrentAccounts);   
       
        Set<Id> setPortalAccount = new Set<Id>();
        setPortalAccount = getPortalAccounts();
        
        Boolean isSearchKeyPresent = false;
        //call dynamic SOQL
        String soqlQuery = '';
        // Add all the query fields
        List<String> listFieldAPINames = new List<String>();
        // fields to query
        listFieldAPINames.add('Id');
        listFieldAPINames.add('Name');
        listFieldAPINames.add('Phone');
        listFieldAPINames.add('Email__c');
        listFieldAPINames.add('Website');
        listFieldAPINames.add('Source_System_Id__c');
        listFieldAPINames.add('RecordType.Name');
        listFieldAPINames.add('Source_System_Name__c');
        listFieldAPINames.add('Oracle_Party_Id__c');
        listFieldAPINames.add('createddate');
        listFieldAPINames.add('Entity_Status__c');
        listFieldAPINames.add('Entity_Id__c');
        DynamicSOQLUtility dynamicSOQLUtility = new DynamicSOQLUtility();
        // Call select function
        soqlQuery = dynamicSOQLUtility.createSelect(listFieldAPINames , 'Account');
        //add where clause
        soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'RecordtypeId', goldenRectypeId , '!=');
        
        //soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'Id', new List<String>{'setPortalAccount'} , '!=' , 'AND');
        soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'Id', new List<String>{'setPortalAccount'} , 'NOT IN' , 'AND');
        if(sName <> null && sName != '' && string.isNotBlank(sName)) {
            sName = sName.replace('%', '');
            if(string.isNotBlank(sName)) {
                String stName = sName.trim();
                soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'Name', '%'+stName+'%', 'LIKE', 'AND');
                isSearchKeyPresent = true;
            }
            
        }//end if 
        
        if(siteid <> null && siteid != '' && string.isNotBlank(siteid)) {
            soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'Oracle_Site_Id__c', siteid, '=', 'AND');
            isSearchKeyPresent = true;
        }

        if(sEmail <> null && sEmail != '' && string.isNotBlank(sEmail)) {
            soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'Email__c', sEmail, '=', 'AND');
            isSearchKeyPresent = true;
        }//end if
        if(sPhone <> null && sPhone != '' && string.isNotBlank(sPhone)) {
            soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'Phone', sPhone, '=', 'AND');
            isSearchKeyPresent = true;
        }//end if
        if(sWebsite <> null && sWebsite != '' && string.isNotBlank(sWebsite)) {
            soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'Website', sWebsite, '=', 'AND');
            isSearchKeyPresent = true;
        }//end if       
        if(isSearchKeyPresent) {
            soqlQuery = dynamicSOQLUtility.addOrderByCondition(soqlQuery, 'RecordType.Name','ASC');
            soqlQuery = dynamicSOQLUtility.addLimitCondition(soqlQuery, 1000);
            listAccount = database.query(soqlQuery);
            
        }//end if
        if(listAccount <> null && listAccount.size() > 0) {
            for(Account accRec : listAccount){
                EntityWrapper enWrapperObj = new EntityWrapper();
                enWrapperObj.accountRec = accRec;
                enWrapperObj.isSelected = false;
                enWrapperObj.accLink = '/'+accRec.Id;
                enWrapperLst.add(enWrapperObj);
            } 
            return enWrapperLst;
        }//end if
        
        return null;
    }//end getSearchResult
    
    /*
    Name : getDuplicateAccounts
    Description : get duplicate entity wrapper
    */
    @AuraEnabled
    public static List<EntityWrapper> getDuplicateAccounts(Id recordId) {
        // get golden entity
		String goldenRectypeId = getAccountRecTypeId('Golden Entity');        
        List<EntityWrapper> enWrapperLst = new List<EntityWrapper>();
        List<Account> listAccount = new List<Account>();
        listAccount = [SELECT ID,Name,Phone,Website, Source_System_Id__c, RecordtypeId, RecordType.Name FROM ACCOUNT WHERE ID=:recordId];
        EntityWrapper enWrapperObj = new EntityWrapper();
        enWrapperObj.accountRec = listAccount[0];
        enWrapperObj.isSelected = false;
        enWrapperLst.add(enWrapperObj);
        List<Account> listExactMatchAccount = new List<Account>();
        listExactMatchAccount = getDuplicates(listAccount, goldenRectypeId);
        
        if(listExactMatchAccount <> null) {
            for(Account accRec : listExactMatchAccount){
                enWrapperObj = new EntityWrapper();
                if(listAccount[0].RecordtypeId == accRec.RecordtypeId) {
                    enWrapperObj.accountRec = accRec;
                    enWrapperObj.isSelected = false;
                    enWrapperLst.add(enWrapperObj);
                }
               
            }
        } 
        if(enWrapperLst.size() == 1) {
            enWrapperLst.clear();
        }
        
        return enWrapperLst;
    }
    

    /*
    Name : getDuplicateAccounts
    Description : get duplicate entity details
    */
    @AuraEnabled
    public static List<Account> getDuplicates(List<Account> listAccount, String goldenRectypeId) {
        List<Account> listExactMatchAccount = new List<Account>();
        Set<Id> setPortalAccount = new Set<Id>();
        setPortalAccount = getPortalAccounts();
        setPortalAccount.add(listAccount[0].Id);
        if(listAccount <> null && listAccount.size() > 0) {
            Boolean isSearchKeyPresent = false;
            //call dynamic SOQL
            String soqlQuery = '';
            // Add all the query fields
            List<String> listFieldAPINames = new List<String>();
            // fields to query
            listFieldAPINames.add('Id');
            listFieldAPINames.add('Name');
            listFieldAPINames.add('Phone');
            listFieldAPINames.add('Email__c');
            listFieldAPINames.add('Website');
            listFieldAPINames.add('RecordtypeId');
            listFieldAPINames.add('RecordType.Name');
            DynamicSOQLUtility dynamicSOQLUtility = new DynamicSOQLUtility();
            // Call select function
            soqlQuery = dynamicSOQLUtility.createSelect(listFieldAPINames , 'Account');
            //add where clause
            soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'Name', 'null' , '!=');
            
        	soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'Id', new List<String>{'setPortalAccount'} , '!=' , 'AND');
            if(string.isNotBlank(listAccount[0].Website)) {
                soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'Website', listAccount[0].Website, '=', 'AND ( ');
                isSearchKeyPresent = true;
            }
            
            if(string.isNotBlank(listAccount[0].Source_System_Id__c)) {
                
                soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'Source_System_Id__c', listAccount[0].Source_System_Id__c, '=', isSearchKeyPresent == true ? 'OR' : 'AND ( ');
                isSearchKeyPresent = true;
            }
            if(isSearchKeyPresent) {
                soqlQuery = soqlQuery + ' ) ';
                soqlQuery = dynamicSOQLUtility.addLimitCondition(soqlQuery, 1000);
                listExactMatchAccount = database.query(soqlQuery);
                
            }
            
            map<string, List<Id>> mapParentAccount = new map<string, List<Id>>();
            mapParentAccount = AccountTriggerHelper.findAccounts(listAccount);
            system.debug('------>'+mapParentAccount.get(listAccount[0].Name));
            List<Account> listFuzzyAccountMatch = new List<Account>();
            listFuzzyAccountMatch = [SELECT ID,Name,Phone,Website, Source_System_Id__c, RecordtypeId, RecordType.Name FROM Account WHERE ID IN:mapParentAccount.get(listAccount[0].Name)];
            listExactMatchAccount.addAll( listFuzzyAccountMatch);
            /*
            if(mapParentAccount.get(listAccount[0].Name) <> null) {
                for(Account accRec : listExactMatchAccount){
                    enWrapperObj = new EntityWrapper();
                    enWrapperObj.accountRec = accRec;
                    enWrapperObj.isSelected = false;
                    enWrapperLst.add(enWrapperObj);
                }
            } 
            if(enWrapperLst.size() == 1) {
                enWrapperLst.clear();
            }
            */
        }
        
       return listExactMatchAccount;
    }//end getAccounts

    /*
    Name : mergeEntities
    Description : It is used to set to merge entity
    */
    @AuraEnabled
    public static String mergeEntities(Account masterRecord, List<Account> listDuplicates) {
        List<Account> listDuplicateAccGroup1 = new List<Account>();
        List<Account> listDuplicateAccGroup2 = new List<Account>();
        List<Account> listDuplicateAccGroup3 = new List<Account>();
        List<Account> listDuplicateAccGroup4 = new List<Account>();
        List<Account> listDuplicateAccGroup5 = new List<Account>();
        
        List<Id> listAccIdToMerge = new List<Id>();
        for(Account objAcc: listDuplicates) {
            listAccIdToMerge.add(objAcc.id);
        }
        listAccIdToMerge.add(masterRecord.id);
        // Old Code //
        //Map<Id, Account> mapOfAccounts = new Map<Id, Account>([SELECT Name , Phone, Website, Email__c, Id FROM Account WHERE Id IN:listAccIdToMerge]);
        // New Code //
        List<String> accountFields = DynamicSOQLUtility.returnFieldNames('Account');
        Map<Id, Account> mapOfAccounts = new Map<Id, Account>((Account[])Database.query('Select '+String.join(accountFields, ',')+' FROM Account WHERE Id IN : listAccIdToMerge ORDER BY createddate DESC'));
        for(String eachField : accountFields){
            if(mapOfAccounts.get(masterRecord.id).get(eachField) == null){
                for(Id eachItem : mapOfAccounts.keySet()){
                    if(eachItem != masterRecord.id && mapOfAccounts.get(eachItem).get(eachField) != null){
                        mapOfAccounts.get(masterRecord.id).put(eachField, mapOfAccounts.get(eachItem).get(eachField));
                        break;
                    }
                }
            }
        }
        
        update mapOfAccounts.values();
        //---------------------------------
        for(Integer index = 0; index < 10 ; index++) {
            if(listDuplicates <> null && listDuplicates.size() > index) {
                if(listDuplicateAccGroup1.size() <> 2) {
                    listDuplicateAccGroup1.add(mapOfAccounts.get(listDuplicates[index].id));
                } else if(listDuplicateAccGroup2.size() <> 2) {
                    listDuplicateAccGroup2.add(mapOfAccounts.get(listDuplicates[index].id));
                }else if(listDuplicateAccGroup3.size() <> 2) {
                    listDuplicateAccGroup3.add(mapOfAccounts.get(listDuplicates[index].id));
                }else if(listDuplicateAccGroup4.size() <> 2) {
                    listDuplicateAccGroup4.add(mapOfAccounts.get(listDuplicates[index].id));
                }else if(listDuplicateAccGroup5.size() <> 2) {
                    listDuplicateAccGroup5.add(mapOfAccounts.get(listDuplicates[index].id));
                }//end else - if
            }//end if
        }//end for
        // Create a savepoint while AccountNumber is null
   		Savepoint sp = Database.setSavepoint();
        String merge_Result = '';
        if(listDuplicateAccGroup1.size() > 0 ) {
            merge_Result = merge_Duplicates(mapOfAccounts.get(masterRecord.id), listDuplicateAccGroup1);
            if(merge_Result <> '' && merge_Result <> SUCCESS_MSG) {
                // Rollback to the previous null value
                Database.rollback(sp);
                return merge_Result;
            }//end if
        }//end if
        
        merge_Result = '';
        if(listDuplicateAccGroup2.size() > 0 ) {
            merge_Result = merge_Duplicates(mapOfAccounts.get(masterRecord.id), listDuplicateAccGroup2);
            if(merge_Result <> '' && merge_Result <> SUCCESS_MSG) {
                // Rollback to the previous null value
                Database.rollback(sp);
                return merge_Result;
            }//end if
        }//end if
        
        merge_Result = '';
        if(listDuplicateAccGroup3.size() > 0 ) {
            merge_Result = merge_Duplicates(mapOfAccounts.get(masterRecord.id), listDuplicateAccGroup3);
            if(merge_Result <> '' && merge_Result <> SUCCESS_MSG) {
                // Rollback to the previous null value
                Database.rollback(sp);
                return merge_Result;
            }//end if
        }//end if
        
        merge_Result = '';
        if(listDuplicateAccGroup4.size() > 0 ) {
            merge_Result = merge_Duplicates(mapOfAccounts.get(masterRecord.id), listDuplicateAccGroup4);
            if(merge_Result <> '' && merge_Result <> SUCCESS_MSG) {
               // Rollback to the previous null value
                Database.rollback(sp);
                return merge_Result;
            }//end if
        }//end if
        
        merge_Result = '';
        if(listDuplicateAccGroup5.size() > 0 ) {
            merge_Result = merge_Duplicates(mapOfAccounts.get(masterRecord.id), listDuplicateAccGroup5);
            if(merge_Result <> '' && merge_Result <> SUCCESS_MSG) {
                // Rollback to the previous null value
                Database.rollback(sp);
                return merge_Result;
            }//end if
        }//end if

        return SUCCESS_MSG;
    }//end mergeEntities()    
    
    /*
    Name : merge_Duplicates
    Description : It is used to perform merge entities operation
    */    
    public static String merge_Duplicates (Account masterRecord, List<Account> listDuplicates) {

        String sError = '';
        // Merge accounts into master
        Database.MergeResult[] results = Database.merge(masterRecord, listDuplicates, false);
      
        for(Database.MergeResult res : results) {
            if (res.isSuccess()) {
                // Get the master ID from the result and validate it
                System.debug('Master record ID: ' + res.getId());             
                
                // Get the IDs of the merged records and display them
                List<Id> mergedIds = res.getMergedRecordIds();
                System.debug('IDs of merged records: ' + mergedIds);    
                
            }
            else {
                for(Database.Error err : res.getErrors()) {
                    // Write each error to the debug output
                    System.debug(err.getMessage());
                    sError = sError + '-' +err.getMessage();
                }//end for
            }//end if - else
        }//end for
        if( sError <> '' ) {
            return sError;
        }//end if
        return SUCCESS_MSG;
    }//end merge_Duplicates
    
    
    /*
	Name : getDuplicateEntityDetails
	Description : get duplicate related to current entity
	*/
	@AuraEnabled  
    public static List<Account> getDuplicateEntityDetails(Id entityId) {
        // get golden entity
		String goldenRectypeId = getAccountRecTypeId('Golden Entity');
        List<Account> listAccount = new List<Account>();
        listAccount = [SELECT ID,Name,Phone,Website, Source_System_Id__c, RecordtypeId, RecordType.Name FROM ACCOUNT WHERE ID=:entityId];
        List<Account> listExactMatchAccount = new List<Account>();
        //listExactMatchAccount = getDuplicates(listAccount);
        Integer counter = 1;
        for(Account objAccount : getDuplicates(listAccount, goldenRectypeId) ) {
            if(counter <> 10) {
                if(listAccount[0].RecordtypeId == objAccount.RecordtypeId) {
                    listExactMatchAccount.add(objAccount);
                    counter++;
                }
                
            } else {
                break;
            }
            
        }
        return listExactMatchAccount;
    }
    
    /*
    Name : getPortalAccounts
    Description : It is used to get portal entity details
    */ 
    public static Set<Id> getPortalAccounts() {
		set<Id> setAccountId = new Set<Id>();
        for(User objUser : [SELECT Id, AccountId FROM User WHERE AccountId != null LIMIT 1000]) {
            if( String.isNotBlank(objUser.AccountId) ) {
                setAccountId.add(objUser.AccountId);
            }
        }
		return setAccountId;        
    }
    
    /*
    Name : getContactRecTypeId
    Description : It is used to get account record type
    */ 
    public static string getAccountRecTypeId(String recordTypeLabel){
        string recid = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();        
        return recid;
    }
    
    // Entity Wrapper Class
    public class EntityWrapper {
        @AuraEnabled public Account accountRec {get;set;}
        @AuraEnabled public Boolean isSelected {get;set;}
        @AuraEnabled public String accLink {get;set;}
    }
}//end class