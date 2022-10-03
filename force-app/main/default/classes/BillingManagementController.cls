/*
Author      :   Yogesh Mahajan 
Class Name  :   BillingManagementController
Description :   It is used as a controller for the Billing Management page. This controller is used to get the related entities, Create and get the Invoices and Receipts .
Date        :   02/13/2019     
*/
public without sharing class BillingManagementController { 
    // Constants
    Private static final string STATUS = 'Draft';
    public static final string SUCCESS_MSG = 'Success';
    /*
Method Name : invoiceInitialization
Description : 
*/
    @AuraEnabled  
    public static Invoice__c invoiceInitialization () {
        return new Invoice__c();
    }
    /*
Method Name : lineItemInitialization
Description : 
*/
    @AuraEnabled  
    public static list<Invoice_Line_Item__c> lineItemInitialization () {
        return new list<Invoice_Line_Item__c>();
    }
    
    /*
Method Name : fetchUserDetails
Description : Used to fetch current user details
*/
    @AuraEnabled  
    public static string fetchUserDetails() {
        User objUser = [select id,Name, Profile.Name from User where id =: userInfo.getUserId()];
        return objUser.Profile.Name;
    }
    
    /*
Method Name : fetchAccountPicklistVal
Description : Used to fetch Receipt Picklist Values
*/
    @AuraEnabled  
    public static List<LEX_Helper.PicklistValueWrapper> fetchAccountPicklistVal(String fieldAPIname, Boolean nullRequired) {
        return LEX_Helper.getPicklistValues('Account', fieldAPIname, nullRequired);
    }//end fetchAccountPicklistVal()
    
    /*
Method Name : fetchReceiptPicklistVal
Description : Used to fetch Receipt Picklist Values
*/
    @AuraEnabled  
    public static List<LEX_Helper.PicklistValueWrapper> fetchReceiptPicklistVal(String fieldAPIname, Boolean nullRequired) {
        return LEX_Helper.getPicklistValues('Receipt__c', fieldAPIname, nullRequired);
    }//end fetchReceiptPicklistVal()
    
    /*
Method Name : fetchInvoicePicklistVal
Description : Used to fetch Invoice Picklist Values
*/
    @AuraEnabled  
    public static List<LEX_Helper.PicklistValueWrapper> fetchInvoicePicklistVal(String fieldAPIname, Boolean nullRequired) {
        return LEX_Helper.getPicklistValues('Invoice__c', fieldAPIname, nullRequired);
    }
    
    @AuraEnabled  
    public static List<LEX_Helper.PicklistValueWrapper> fetchInvoiceLineItemPicklistVal(String fieldAPIname, Boolean nullRequired) {
        return LEX_Helper.getPicklistValues('Invoice_Line_Item__c', fieldAPIname, nullRequired);
    }
    
    /*
Method Name : fetchAddressCountry
Description : Used to fetch Country Picklist Values on Address__c
*/
    @AuraEnabled  
    public static List<LEX_Helper.PicklistValueWrapper> fetchAddressPicklistVal(String fieldAPIname, Boolean nullRequired) {
        return LEX_Helper.getPicklistValues('Address__c', fieldAPIname, nullRequired);
    }//end fetchAddressPicklistVal()
    
    /*
Method Name : getRecordtypeMap
Description : Used to get record type details

@AuraEnabled
public static List<Recordtype> getRecordtypeMap(){
return [select id,name from RecordType where SobjectType = 'Account'];
}
*/
    
    @AuraEnabled
    public static Receipt__c fetchReceiptDetails(String receiptId){
        //return [select id,name,Entity__c,Payment_Currency__c,Pushed_to_Oracle__c,Payment_Status__c,Status__c,(select id,Amount_Applied__c,Invoice__r.Oracle_Invoice_Id__c FROM Related_Invoices__r) from Receipt__c where Id =: receiptId];
        return [select id,name,Entity__c,Payment_Currency__c,Pushed_to_Oracle__c,Status__c,(select id,Amount_Applied__c,Oracle_Applied_Amount__c,Invoice__r.Oracle_Invoice_Id__c FROM Related_Invoices__r) from Receipt__c where Id =: receiptId];
    }
    
    @AuraEnabled
    public static Invoice__c fetchInvoiceDetails(String invoiceId){
        return [select id,name,Status__c,Journal_Created__c,Sys_Oracle_Party_Id__c from Invoice__c where Id =: invoiceId];
    } 
    
    @AuraEnabled
    public static Account fetchAccountDetails(String recId){
        return [select id,Oracle_Site_Id__c from Account where Id =: recId];
    }
    
    @AuraEnabled
    public static String pushAccountToOracle(Account accId){
        EntityUtil.PushEntityToOracle(accId.Id, false);
        List<Account> accLst = [select Oracle_Party_Id__c from Account WHERE Id=: accId.id];
        if(accLst.size() > 0){
            Return accLst[0].Oracle_Party_Id__c;
        }
        return null;
    }
    
    /*
Method Name : fetchAccountPicklistVal
Description : Used to fetch Receipt Picklist Values
*/
    @AuraEnabled  
    public static CloneEntityWrapper fetchEntityDetails(String entityId) {
        CloneEntityWrapper objCloneEntityWrapper = new CloneEntityWrapper();
        objCloneEntityWrapper.objAcc = new Account();
        objCloneEntityWrapper.objAddressObject = new Address__c();
        if(entityId <> null && entityId <> '') {
            List<Account> listAcc = new List<Account>();
            listAcc = [SELECT Name, Account_Name_Arabic__c, Email__c, Phone, Source_System_Id__c, Registered_for_Tax__c, Tax_Registration_Number__c FROM Account WHERE id = : entityId ];
            objCloneEntityWrapper.objAcc = listAcc[0];
            List<Address__c > listAdd = new List<Address__c>();
            listAdd = [SELECT id,Country__c,State__c,Emirates__c, Street_Name_of_Cluster_on_the_Island__c,Type__c from Address__c where Entity__c =:entityId AND Type__c = 'Physical'];
            objCloneEntityWrapper.objAddressObject = listAdd[0];
        }
        
        return objCloneEntityWrapper;
    }//end fetchEntityDetails()
    
    @AuraEnabled
    public static EntityWrapper cloneEntity(String accId, String ouName, String sourceSystemName){
        EntityWrapper eWrap = new EntityWrapper();
        //eWrap.msg = 'Error';
        //return eWrap;
        Savepoint sp = Database.setSavepoint(); 
        try {
            
            Account acc = [SELECT ID, Name,Email__c,RecordType.Name,Parent.Name FROM Account WHERE Id = : accId];
            Account accCopy = acc.clone(false,true);
            accCopy.Oracle_Site_Id__c = ouName;
            accCopy.Source_System__c = sourceSystemName;
            
            for(Oracle_Site_Id_Mapping__mdt objOracleSiteIdMapping : [SELECT Entity_Record_Type_API_Name__c,Entity_Record_Type_Name__c, Site_Id__c, Authority__c FROM Oracle_Site_Id_Mapping__mdt WHERE Site_Id__c =: ouName LIMIT 1]) {
                accCopy.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(objOracleSiteIdMapping.Entity_Record_Type_Name__c).getRecordTypeId(); accCopy.Source_System_Name__c = objOracleSiteIdMapping.Authority__c;
            }
            
            insert accCopy;
            List<Address__c> listAdd = new List<Address__c>();
            
            for(Address__c objAddress : [select id,Country__c,State__c,Emirates__c, Street_Name_of_Cluster_on_the_Island__c,Type__c from Address__c where Entity__c =: accId]) {
                Address__c newAddress = new Address__c(); newAddress = objAddress.clone(false,true);newAddress.Entity__c = accCopy.id; listAdd.add(newAddress);
            }
            system.debug('accCopy ---------->'+accCopy);
            system.debug('listAdd ---------->'+listAdd);
            //eWrap.msg = 'Error';
            //return eWrap;
            if(listAdd <> null && listAdd.size() > 0){insert listAdd;}
                
            string oracleId = pushAccountToOracle(accCopy);eWrap.accountRec = getRecentlycreatedEntity(accCopy)[0];eWrap.msg = SUCCESS_MSG;
        } catch(Exception e) {
            Database.rollback( sp );
            system.debug(e.getMessage());
            eWrap.msg = e.getMessage();
        }
        return eWrap;
    }
    /*
Method Name : saveAccount
Description : Used to get create an account
*/
    @AuraEnabled
    public static EntityWrapper saveAccount (Account acc, String sRecordTypeId, Boolean isPersonAcc,String Concountry, Id contactId, String sourceSystemIDVal, Address__c objAddress,string OUName, String sourceSystemName) {
        EntityWrapper eWrap = new EntityWrapper();
        
        
        
        Savepoint sp = Database.setSavepoint(); 
        system.debug('--->'+objAddress);
        try{
            if(isPersonAcc){
                if(Concountry != null && Concountry != ''){
                    Map<String,String> countryMap = new Map<String,String>();
                    for(LEX_Helper.PicklistValueWrapper eachVal : fetchAddressPicklistVal('Country_ALPHA_3__c', false)){
                        countryMap.put(eachVal.picklistLabel,eachVal.picklistVal);
                    }
                    if(countryMap.containsKey(Concountry)){
                        objAddress.Country__c = countryMap.get(Concountry);
                        objAddress.Type__c = 'Physical';
                    }
                }
            }
            
            if(!isPersonAcc && acc <> null){
                /*if(mapAuthorityWithRecType <> null && mapofAccountRecordTypeNameandId <> null && acc.Source_System_Name__c <> null &&
mapAuthorityWithRecType.get(acc.Source_System_Name__c) <> null && mapofAccountRecordTypeNameandId.get(mapAuthorityWithRecType.get(acc.Source_System_Name__c)) <> null){
acc.RecordTypeID = mapofAccountRecordTypeNameandId.get(mapAuthorityWithRecType.get(acc.Source_System_Name__c)); 
}*/
                system.debug('========>'+acc.Oracle_Site_Id__c);
                if(acc.Oracle_Site_Id__c == '101'){
                    if(acc.Source_System__c == 'BM - Arbitration'){ acc.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Arbitration Center').getRecordTypeId(); 
                    } else if(acc.Source_System__c == 'BM - ADGM'){ acc.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM').getRecordTypeId(); 
                    }
                } else {
                    for(Oracle_Site_Id_Mapping__mdt objOracleSiteIdMapping : [SELECT Entity_Record_Type_API_Name__c,Entity_Record_Type_Name__c, Site_Id__c, Authority__c FROM Oracle_Site_Id_Mapping__mdt WHERE Site_Id__c =: acc.Oracle_Site_Id__c LIMIT 1]) {
                        acc.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(objOracleSiteIdMapping.Entity_Record_Type_Name__c).getRecordTypeId(); acc.Source_System_Name__c = objOracleSiteIdMapping.Authority__c;
                    }
                }
                //acc.RecordTypeID = sRecordTypeId;
                insert acc;
                
                system.debug(acc.Is_Manually_Created__c);
                //if(acc.Is_Manually_Created__c){
                // EntityUtil.PushEntityToOracle(acc.Id, false);
                //}
                system.debug('--->'+objAddress);
                system.debug('--->'+objAddress.Country__c);
                if(objAddress <> null && objAddress.Country__c <> null && objAddress.Country__c <> '') { objAddress.Entity__c = acc.id;objAddress.Type__c = 'Physical';insert objAddress;
                }
                
                eWrap.accountRec = getRecentlycreatedEntity(acc)[0]; eWrap.msg = SUCCESS_MSG;
            } else if(contactId <> null && isPersonAcc){
                system.debug('Inside person account --->'+contactId);
                List<Contact> listContact = new List<Contact>();
                listContact = [SELECT id, FirstName
                               , Middle_Name__c
                               , LastName
                               , Email
                               , Country__c
                               , State_Province__c
                               , City__c
                               , Street__c
                               FROM Contact 
                               WHERE id = :contactId ];
                if(listContact <> null && listContact.size() > 0 ) {
                    //insert account
                    Account objAccount = new Account(Oracle_Site_Id__c = OUName, Source_System__c = sourceSystemName);
                    for(Oracle_Site_Id_Mapping__mdt objOracleSiteIdMapping : [SELECT Entity_Record_Type_API_Name__c,Entity_Record_Type_Name__c, Site_Id__c, Authority__c FROM Oracle_Site_Id_Mapping__mdt WHERE Site_Id__c =: OUName LIMIT 1]) {
                        objAccount.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(objOracleSiteIdMapping.Entity_Record_Type_Name__c).getRecordTypeId(); objAccount.Source_System_Name__c = objOracleSiteIdMapping.Authority__c;
                    }
                    /*

if(mapAuthorityWithRecType <> null && mapofAccountRecordTypeNameandId <> null && sourceSystemName <> null &&
mapAuthorityWithRecType.get(sourceSystemName) <> null && mapofAccountRecordTypeNameandId.get(mapAuthorityWithRecType.get(sourceSystemName)) <> null){
objAccount.RecordTypeID = mapofAccountRecordTypeNameandId.get(mapAuthorityWithRecType.get(sourceSystemName)); 
}
//objAccount.RecordTypeId = sRecordTypeId;
*/
                    objAccount.Name = listContact[0].FirstName <> null ? listContact[0].FirstName : '';
                    objAccount.Name += listContact[0].Middle_Name__c <> null ? ' '+listContact[0].Middle_Name__c : ' ';
                    objAccount.Name += listContact[0].LastName <> null ? ' '+listContact[0].LastName : '';
                    
                    objAccount.Email__c = listContact[0].Email;
                    objAccount.Person_Account__c = true;
                    objAccount.Source_System_Id__c = sourceSystemIDVal;
                    insert objAccount;
                    // update contact
                    listContact[0].AccountId =objAccount.id ;
                    update listContact;
                    // create address
                    if(listContact[0].Country__c <> null && listContact[0].Country__c <> '') {
                        Address__c objNewAddress = new Address__c();
                        objNewAddress.Country__c = listContact[0].Country__c;
                        objNewAddress.State__c = listContact[0].State_Province__c;
                        objNewAddress.Emirates__c = listContact[0].City__c;
                        objNewAddress.Street_Name_of_Cluster_on_the_Island__c = listContact[0].Street__c;
                        objNewAddress.Entity__c = objAccount.id;
                        objNewAddress.Type__c = 'Physical'; 
                        insert objNewAddress;
                    }
                    
                    
                    eWrap.accountRec = getRecentlycreatedEntity(objAccount)[0];
                    eWrap.msg = SUCCESS_MSG;
                } else {eWrap.msg = 'Record not found';
                }
                
            }
        } catch (Exception e){
            Database.rollback( sp );
            if(isPersonAcc && contactId <> null) { Contact objCon = new Contact(); objCon.id = contactId; delete objCon;
            }
            system.debug(e.getMessage());
            eWrap.msg = e.getMessage();
            
        }
        
        return eWrap;
    }
    
    public static List<Account> getRecentlycreatedEntity(Account objAcc) {
        return [SELECT id,Name,Parent.Name,toLabel(Oracle_Site_Id__c),Oracle_Party_Id__c,Source_System_Name__c,RecordType.Name,Source_System__c  FROM Account WHERE ID =: objAcc.ID];
    }
    
    
    /*
Method Name : getRelatedEntity
Description : Used to get entities as per the search filters
*/
    @AuraEnabled
    public static List<EntityWrapper>  getRelatedEntity(String sName, String sADGMID, String sSiteID, String sRelatedEntity, string sSourceSys) {
        system.debug('sSiteID----->'+sSiteID);
        Boolean isSelected = false, isSearchKeyPresent = false;
        List<Account> listAccount = new List<Account>();
        //call dynamic SOQL 
        String soqlQuery = '';
        // Add all the query fields
        List<String> listFieldAPINames = new List<String>();
        // fields to query
        listFieldAPINames.add('Id');
        listFieldAPINames.add('Name');
        listFieldAPINames.add('RecordType.Name');
        listFieldAPINames.add('Parent.Name');
        listFieldAPINames.add('toLabel(Oracle_Site_Id__c)');
        //listFieldAPINames.add('Oracle_Party_Id__c');
        listFieldAPINames.add('Source_System_Name__c'); 
        listFieldAPINames.add('Source_System__c');
        
        DynamicSOQLUtility dynamicSOQLUtility = new DynamicSOQLUtility();
        Set<string> listRecTypeName = new Set<String>{'Golden Entity', 'ADGM BR&P', 'ADGM RA', 'ADGM Channel Partner'};
            // Call select function
            soqlQuery = dynamicSOQLUtility.createSelect(listFieldAPINames , 'Account');
        //soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'RecordType.Name', new List<string>{'listRecTypeName'}, 'NOT IN');
        soqlQuery = soqlQuery + ' ' +'WHERE RecordType.Name NOT IN: listRecTypeName';
        if(sRelatedEntity <> null && String.isNotBlank(sRelatedEntity)) {
            soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'Id', sRelatedEntity, '=', 'AND');
            isSearchKeyPresent = true;
        }else {
            
            if(sName <> null && string.isNotBlank(sName)) {
                sName = sName.replace('%', '');
                if(string.isNotBlank(sName)) {
                    String sNme = sName.trim();
                    soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'Name', '%'+sNme+'%', 'LIKE', 'AND');
                    isSearchKeyPresent = true;
                }
            }
            //commented by prateek.b.bansal@pwc.com on 17 Oct for fusion changes 
            /*if(sADGMID <> null && string.isNotBlank(sADGMID)) {
                sADGMID = sADGMID.replace('%', '');
                if(string.isNotBlank(sADGMID)) {
                    String sADGM = sADGMID.trim();
                    soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'Oracle_Party_Id__c', sADGM, '=', 'AND');
                    isSearchKeyPresent = true;
                }
                
            }*/
            //sSiteID = sSiteID.replace('%', '');
            if(sSiteID <> null && string.isNotBlank(sSiteID) && sSiteID <> 'None') {
                sSiteID = sSiteID.replace('%', '');
                if(string.isNotBlank(sSiteID)) {
                    String sSite = sSiteID.trim(); soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'Oracle_Site_Id__c', sSite, '=', 'AND'); isSearchKeyPresent = true;
                }
            }
            system.debug('--->'+sSourceSys);
            Billing_Management_Setting__mdt bms = fetchBillingManagementMDTDetail();
            if(bms.Default_Source_System__c == 'BM - Arbitration' || bms.Default_Source_System__c == 'BM - ADGM'){
                String sourceSys = bms.Default_Source_System__c; soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'Source_System__c', sourceSys, '=', 'AND'); isSearchKeyPresent = true;
            }
            /*if(sSourceSys <> null && string.isNotBlank(sSourceSys) && sSourceSys <> 'None') {
sSourceSys = sSourceSys.replace('%', '');
if(string.isNotBlank(sSourceSys)) {
String sourceSys = sSourceSys.trim();
soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'Source_System__c', sourceSys, '=', 'AND');
isSearchKeyPresent = true;
}
}*/
            
        }
        system.debug('--->'+soqlQuery);
        if(isSearchKeyPresent ) {
            listAccount = database.query(soqlQuery);
        }
        system.debug('--->'+listAccount);
        if(listAccount <> null && listAccount.size() > 0) {
            List<EntityWrapper> listEntityWrapper = new List<EntityWrapper>();
            EntityWrapper objEntityWrapper ;
            for(Account objAccount : listAccount) {
                objEntityWrapper = new EntityWrapper();
                objEntityWrapper.accountRec = objAccount;
                objEntityWrapper.isSelected = isSelected;
                listEntityWrapper.add(objEntityWrapper);
            }
            return listEntityWrapper;
        }//end if
        return null;
    }//end getCurrentAccount
    
    /*
Method Name : getRelatedReceipts
Description : Used to get selected entity receipt
*/ //where (Status__c = 'Draft' OR Status__c = 'Success' OR Status__c = 'Approved') and (Oracle_Receipt_Id__c = '' OR Oracle_Receipt_Id__c = null)
    @AuraEnabled
    public static List<ReceiptsWrapper> getRelatedReceipts(String selectedAccountId) {
        List<ReceiptsWrapper> listReceiptsWrapper = new List<ReceiptsWrapper>();
        try{
            for(Receipt__c objReceipt : [select id,Name,GL_Date__c,Journal_Created__c,Pushed_to_Oracle__c,Status__c,Payment_Currency__c,Amount__c,Remaning_Amount__c,Transaction_Reference__c,Description__c,Payment_Method__c, 
                                        Is_Created_Manually__c,Entity__c, Source_Receipt_Id__c,Receipt_Reference__c, Receipt_Date__c, Oracle_Receipt_Id__c,Receipt_Type__c,(SELECT Invoice__c, Invoice_Name__c,
                                        Amount_Applied__c, Oracle_Applied_Amount__c, Invoice__r.Invoice_Balance__c,Invoice__r.Oracle_Invoice_Id__c,Applied_Date__c from Related_Invoices__r where Direction__c = 'From Receipt To Invoice') 
                                         from Receipt__c where (Status__c = 'Draft' OR Status__c = 'Success' OR Status__c = 'Approved') and Remaning_Amount__c > 0 and Status__c != 'Under Review' 
                                         and Entity__c =: selectedAccountId ORDER BY Name DESC]){
                ReceiptsWrapper objReceiptsWrapper = new ReceiptsWrapper();
                objReceiptsWrapper.receiptRec = objReceipt;
                
                List<RelatedInvClass> listRelatedVal = new List<RelatedInvClass>();
                if(objReceipt.Related_Invoices__r.size() > 0){
                    
                    for(Related_Invoice_Receipt__c eachInvoice : objReceipt.Related_Invoices__r){
                        RelatedInvClass objRelatedInvClass = new RelatedInvClass();
                        objRelatedInvClass.Amount = eachInvoice.Amount_Applied__c;
                        objRelatedInvClass.invoiceNo = eachInvoice.Invoice__r.Oracle_Invoice_Id__c;
                        objRelatedInvClass.invoiceId = eachInvoice.Invoice__c;
                        objRelatedInvClass.invoiceBalAmt = eachInvoice.Invoice__r.Invoice_Balance__c;
                        objRelatedInvClass.AppliedDate = String.valueof(eachInvoice.Applied_Date__c);
                        listRelatedVal.add(objRelatedInvClass);
                    }
                    
                    objReceiptsWrapper.listrelatedInvoices = listRelatedVal;
                }
                if(objReceipt.Receipt_Type__c == 'Fund Transfer' && objReceipt.Journal_Created__c){listReceiptsWrapper.add(objReceiptsWrapper);
                } else if(objReceipt.Receipt_Type__c != 'Fund Transfer'){
                    listReceiptsWrapper.add(objReceiptsWrapper);
                }
                
            }
        } catch (Exception e){
            system.debug('---------------->'+ e.getMessage());
        }
        system.debug('listReceiptsWrapper--->'+listReceiptsWrapper);
        return listReceiptsWrapper;  
    }
    
    /*
Method Name : getReceipts
Description : Used to create dummay Receipt  

@AuraEnabled
public static List<ReceiptsWrapper> getReceipts(Account selectedAccount) {
system.debug('Method called for initialization');
List<ReceiptsWrapper> listReceiptsWrapper = new List<ReceiptsWrapper>();
if(selectedAccount <> null) {
Receipt__c objReceipt = new Receipt__c();
ReceiptsWrapper objReceiptsWrapper = new ReceiptsWrapper();      
objReceipt.Entity__c = selectedAccount.id;
objReceipt.Is_Created_Manually__c = true;
objReceipt.Status__c = STATUS;
objReceipt.Amount__c = 0;
objReceipt.Transaction_Reference__c = '';
objReceipt.Description__c = '';
objReceiptsWrapper.relatedInvoice = '';
objReceiptsWrapper.receiptRec = objReceipt;
objReceiptsWrapper.isEditable = false;  
objReceiptsWrapper.isSelectedForApproval = false;

listReceiptsWrapper.add(objReceiptsWrapper);
}
system.debug('listReceiptsWrapper--->'+listReceiptsWrapper);
return listReceiptsWrapper;

}
*/
    /*
Method Name : getRelatedInvoice
Description : Used to get selected entity Invoice
*/
    @AuraEnabled
    public static List<InvoiceWrapper> getRelatedInvoice(String selectedAccountId) {
        
        List<InvoiceWrapper> listInvoiceWrapper = new List<InvoiceWrapper>();
        try{
            for(Invoice__c objInvoice : [select id,Name,Status__c,Payment_Currency__c,Oracle_Invoice_Id__c,Payment_Term__c,Transaction_Reference__c,Description__c,
                                         Invoice_Date__c,Invoice_Class__c, Is_Created_Manually__c, Related_Receipt__c, Related_Receipt__r.Name, Entity__c,Oracle_Invoice_Type__c,
                                         Invoice_Balance__c,Is_Refundable__c, Credit_Memo_Type__c, In_Progress_Amount__c,GL_Date__c,Source_Invoice_Id__c,Is_Source_Invoice__c,Total_Invoice_Amount_OC__c,
                                         (SELECT Receipt_Name__c, Receipt__c,Amount_Applied__c,Receipt__r.Receipt_Balance__c FROM Related_Receipts__r where Direction__c = 'From Invoice To Receipt'),
                                         (SELECT Id,Amount__c,Tax_Amount__c,Discount_Amount__c,Taxable_Discount_Amount__c,Item_Description__c,Item_Reference__c,Tax__c,Line_Description__c,Department__c,Service_Type__c,Course_Type__c,Schools__c,Quantity__c,Discount_Description__c  FROM Invoice_Line_Items__r where RecordType.DeveloperName='Invoice_Line_Item' AND Is_Discount__c = false AND Status__c != 'Cancelled') 
                                         from Invoice__c where (((Status__c = 'Draft' OR Status__c = 'Success' OR Status__c = 'Rejected' OR Invoice_Balance__c > 0) AND RecordType.DeveloperName != 'Credit_Memo' ) OR (Invoice_Balance__c < 0 and Is_Refundable__c = true)) 
                                         AND Status__c != 'Under Review' and Oracle_Invoice_Id__c = null  and Entity__c = : selectedAccountId ORDER BY Name DESC] ){
                                             InvoiceWrapper objInvoiceWrapper = new InvoiceWrapper();
                                             objInvoiceWrapper.invoiceRec = objInvoice;
                                             //objInvoiceWrapper.isEditable = true;  
                                             // objInvoiceWrapper.isRemoveEnable = true; 
                                             //objInvoiceWrapper.isSelectedForApproval = false;
                                             //objInvoiceWrapper.relatedReceipt = objInvoice.Related_Receipt__r.Name;
                                             
                                             List<RelatedReceiptClass> listrelatedRec = new List<RelatedReceiptClass>();
                                             if(objInvoice.Related_Receipts__r.size() > 0){
                                                 for(Related_Invoice_Receipt__c eachReceipt : objInvoice.Related_Receipts__r){
                                                     RelatedReceiptClass objRelatedReceiptClass = new RelatedReceiptClass();
                                                     
                                                     objRelatedReceiptClass.Id = eachReceipt.Receipt__c; objRelatedReceiptClass.Name = eachReceipt.Receipt_Name__c; objRelatedReceiptClass.RecAmt = eachReceipt.Receipt__r.Receipt_Balance__c;
                                                     listrelatedRec.add(objRelatedReceiptClass);
                                                 }
                                                 objInvoiceWrapper.listRelatedReceiptClass = listrelatedRec;
                                             } 
                                             
                                             if(objInvoice.Invoice_Line_Items__r.size() > 0){
                                                 objInvoiceWrapper.listInvoiceLineRec = objInvoice.Invoice_Line_Items__r;
                                                 
                                             }
                                             listInvoiceWrapper.add(objInvoiceWrapper);
                                         }
        }catch(Exception e){
            system.debug('---------------->'+ e.getMessage());
        }     
        system.debug('listReceiptsWrapper--->'+listInvoiceWrapper);
        return listInvoiceWrapper;
        
    }
    
    /*
Method Name : getInvoice
Description : Used to create dummay invoice 

@AuraEnabled
public static List<InvoiceWrapper> getInvoice(Account selectedAccount) {
List<InvoiceWrapper> listInvoiceWrapper = new List<InvoiceWrapper>();
if(selectedAccount <> null) {
Invoice__c objInvoice =new Invoice__c(Status__c = STATUS,Tax_Amount__c =0,Markup_Amount__c=0,Cost__c=0, Is_Created_Manually__c = true);
InvoiceWrapper objInvoiceWrapper = new InvoiceWrapper();
objInvoiceWrapper.isSelectedForApproval = false;
objInvoice.Entity__c = selectedAccount.id;
objInvoiceWrapper.invoiceRec = objInvoice;
objInvoiceWrapper.isEditable = false;  
objInvoiceWrapper.relatedReceipt = '';  
objInvoiceWrapper.listInvoiceLineItemWrap = null;
objInvoiceWrapper.listInvoiceType = getInvoiceRevenue(selectedAccount.Oracle_Site_Id__c, true, null);
listInvoiceWrapper.add(objInvoiceWrapper);
}
system.debug('listReceiptsWrapper--->'+listInvoiceWrapper);
return listInvoiceWrapper;

}
*/
    /*
Method Name : getInvoiceLineItem
Description : Used to create dummay invoice line item

@AuraEnabled
public static List<InvoiceWrapper> getInvoiceLineItem(List<InvoiceWrapper> listInvoiceWrapper, Integer indexVal, Account selectedAcc) {
Map<String,Id> mapofAccountRecordTypeNameandId = new Map<String,Id>();
mapofAccountRecordTypeNameandId = ApexCodeUtility.getRecTypeDetails('Invoice_Line_Item__c');
List<InvoiceLineItemWrapper> listnvoiceLineItemWrapper = new List<InvoiceLineItemWrapper>();
if(listInvoiceWrapper[indexVal].listInvoiceLineItemWrap <> null) {
listnvoiceLineItemWrapper.addAll(listInvoiceWrapper[indexVal].listInvoiceLineItemWrap);
}
if(listInvoiceWrapper <> null) {
Invoice_Line_Item__c objInvoiceLineItem =new Invoice_Line_Item__c(Status__c = STATUS,Amount__c =0, Discount_Amount__c = 0,Tax_Amount__c=0,Taxable_Discount_Amount__c=0, recordtypeid = mapofAccountRecordTypeNameandId.get('Invoice Line Item'));
InvoiceLineItemWrapper objInvoiceLineItemWrapper = new InvoiceLineItemWrapper();
objInvoiceLineItemWrapper.isSelectedForApproval = false;
objInvoiceLineItem.Invoice__c = listInvoiceWrapper[indexVal].invoiceRec.Id;
objInvoiceLineItemWrapper.invoiceLineItemRec = objInvoiceLineItem;
objInvoiceLineItemWrapper.isEditable = false;  
objInvoiceLineItemWrapper.listInvoiceDesc = getInvoiceRevenue(selectedAcc.Oracle_Site_Id__c, false, listInvoiceWrapper[indexVal].invoiceRec.Oracle_Invoice_Type__c);
listnvoiceLineItemWrapper.add(objInvoiceLineItemWrapper);
}
if(listnvoiceLineItemWrapper <> null && listnvoiceLineItemWrapper.size() > 0) {
system.debug('listnvoiceLineItemWrapper--->'+listnvoiceLineItemWrapper.size());
listInvoiceWrapper[indexVal].listInvoiceLineItemWrap = listnvoiceLineItemWrapper ;
}

system.debug('listInvoiceWrapper--->'+listInvoiceWrapper);
system.debug('listInvoiceWrapper--->'+listInvoiceWrapper.size());
return listInvoiceWrapper;

}
*/
    /*
Method Name : createReceiptRecords
Description : Used to create receipt record 

@AuraEnabled
public static List<ReceiptsWrapper> createReceiptRecords(List<ReceiptsWrapper> listReceiptsVal, Integer indexVal) { 

User objUser = [select id,Name, Profile.Name from User where id =: userInfo.getUserId()];

List<ReceiptsWrapper> lstReceiptsWrapper = new List<ReceiptsWrapper>();
if(listReceiptsVal <> null && listReceiptsVal.size() > 0 && indexVal != null){
// Create invoice number map
Map<String, Id> mapOfInvoiceNameWithId = new Map<String, Id>();
for(Invoice__c objInvoice : [SELECT ID, NAME FROM Invoice__c  where Status__c = 'Draft' and Entity__c =: listReceiptsVal[0].receiptRec.Entity__c]) {
mapOfInvoiceNameWithId.PUT(objInvoice.Name, objInvoice.Id);
}
// Map<Id, Receipt__c> mapReceiptToUpsert = new Map<Id, Receipt__c>();
Map<Integer, Receipt__c> mapReceiptToUpsert = new Map<Integer, Receipt__c>();
Map<Integer, String> mapRelatedInvoice = new Map<Integer, String>();
Map<Integer, String> mapRelatedInvoiceAppliedAmount = new Map<Integer, String>();
Receipt__c objRec;
Integer count = 1;
for(ReceiptsWrapper objReceipt : listReceiptsVal) {
objRec = new Receipt__c();
objRec = objReceipt.receiptRec;

if(objReceipt.relatedInvoice <> null && String.isNotBlank(objReceipt.relatedInvoice )) {
objRec.Transaction_Type__c = 'POSTPAID';
} else {
objRec.Transaction_Type__c = 'PREPAID';
}
if(objUser.Profile.Name <> 'ADGM Finance Manager')
objRec.Status__c = 'Draft';
else
objRec.Status__c = 'Success';
if(objReceipt.relatedInvoice <> null && String.isNotBlank(objReceipt.relatedInvoice )) {
// objRec.Related_Invoice__c = mapOfInvoiceNameWithId.get(objReceipt.relatedInvoice );

}
//mapReceiptToUpsert.put(objRec.id,objRec);	
mapReceiptToUpsert.put(count,objRec);
mapRelatedInvoice.put(count, objReceipt.relatedInvoice);
mapRelatedInvoiceAppliedAmount.put(count, objReceipt.invoiceAmountApplied);
count++;
}

try{
upsert mapReceiptToUpsert.values();
createRelatedInvoice(mapReceiptToUpsert,mapRelatedInvoice,mapRelatedInvoiceAppliedAmount);
} catch(Exception ex) {
system.debug(ex.getMessage());
ReceiptsWrapper reciptWrap = new ReceiptsWrapper();
reciptWrap.msg = ex.getMessage();
lstReceiptsWrapper.add(reciptWrap);
return lstReceiptsWrapper;
}
Set<Id> setUpdatedRecIds = new Set<Id>();
for(Receipt__c objReceipt :  mapReceiptToUpsert.values()) {
setUpdatedRecIds.add(objReceipt.id);
}
system.debug('mapReceiptToUpsert--->'+mapReceiptToUpsert);
List<Receipt__c> listReceipt = new List<Receipt__c>();
listReceipt = [SELECT id,Name,Payment_Currency__c,Amount__c,Transaction_Reference__c,Description__c,Payment_Method__c, Is_Created_Manually__c, Related_Invoice__r.Name, Related_Invoice__c, Entity__c, Source_Receipt_Id__c, Receipt_Date__c, Oracle_Receipt_Id__c FROM Receipt__c WHERE id IN:setUpdatedRecIds and Pushed_to_Oracle__c = false];

system.debug(listReceipt[0].id);
if(indexVal >= 0 && listReceipt.size() == 1){
system.debug('Single Save');
ReceiptsWrapper reciptWrap = new ReceiptsWrapper();
reciptWrap.receiptRec = listReceipt[0];
reciptWrap.relatedInvoice = listReceipt[0].Related_Invoice__r.Name;
reciptWrap.isEditable = true;
reciptWrap.isRemoveEnable = true;
reciptWrap.index = indexVal;
reciptWrap.msg = SUCCESS_MSG;
lstReceiptsWrapper.add(reciptWrap);
} else {
system.debug('Save All Called');
for(Integer i = 0; i< listReceiptsVal.size(); i++){
ReceiptsWrapper reciptWrap = new ReceiptsWrapper();
reciptWrap.receiptRec = listReceipt[i];
reciptWrap.relatedInvoice = listReceipt[i].Related_Invoice__r.Name;
reciptWrap.isEditable = true;
reciptWrap.isRemoveEnable = true;
reciptWrap.index = i;
reciptWrap.msg = SUCCESS_MSG;
lstReceiptsWrapper.add(reciptWrap);
system.debug(lstReceiptsWrapper);
}
}
}        
return lstReceiptsWrapper;
}
*/
    /*
* Method Name : createInvoicewithLineItem
Description : Used to create Invoice record

@AuraEnabled
public static List<InvoiceWrapper> createInvoicewithLineItem(List<InvoiceWrapper>  listInvoicesVal, Integer indexVal, Boolean isInvoice) { 
List<InvoiceWrapper> lstInvoicesWrapper = new List<InvoiceWrapper>();
if(isInvoice) {
lstInvoicesWrapper =  createInvoiceRecords(listInvoicesVal, indexVal);
} else {
lstInvoicesWrapper =  createInvoiceLineItemRecords(listInvoicesVal, indexVal);
}
return lstInvoicesWrapper;
}
*/
    /*
* Method Name : createInvoiceLineItemRecords
Description : Used to create Invoice line item record

public static List<InvoiceWrapper> createInvoiceLineItemRecords(List<InvoiceWrapper> listInvoicesVal, Integer indexVal) { 
List<InvoiceWrapper> lstInvoicesWrapper = new List<InvoiceWrapper>();
List<Invoice_Line_Item__c> listInvoiceLineItemToUpsert = new List<Invoice_Line_Item__c> ();
Integer recCount = 0;
for(InvoiceWrapper objInvoice : listInvoicesVal) {
for(InvoiceLineItemWrapper objLineItem : objInvoice.listInvoiceLineItemWrap){
if(indexVal == -1 || recCount == indexVal ){
listInvoiceLineItemToUpsert.add(objLineItem.invoiceLineItemRec);
}
recCount++;
}
}
try{
upsert listInvoiceLineItemToUpsert;
} catch(Exception ex) {
system.debug(ex.getMessage());
InvoiceWrapper invcWrap = new InvoiceWrapper();
invcWrap.msg = ex.getMessage();
return lstInvoicesWrapper;
}
if(indexVal >= 0 && listInvoiceLineItemToUpsert.size() == 1){
system.debug('Single Save');
InvoiceWrapper invcWrap = new InvoiceWrapper();
invcWrap = listInvoicesVal[0];
//invcWrap.listInvoiceLineItemWrap = listInvoicesVal[indexVal].listInvoiceLineItemWrap;
invcWrap.listInvoiceLineItemWrap[indexVal].invoiceLineItemRec = listInvoiceLineItemToUpsert[0];
invcWrap.listInvoiceLineItemWrap[indexVal].isEditable = true;
invcWrap.listInvoiceLineItemWrap[indexVal].isRemoveEnable = false;
invcWrap.listInvoiceLineItemWrap[indexVal].index = indexVal;
invcWrap.listInvoiceLineItemWrap[indexVal].msg = SUCCESS_MSG;
system.debug('---------------->'+ invcWrap);
system.debug('---------------->'+ invcWrap.listInvoiceLineItemWrap);
lstInvoicesWrapper.add(invcWrap);


} else {
system.debug('Save All Called');
List<InvoiceLineItemWrapper> listInvoiceLineItemWrapper = new List<InvoiceLineItemWrapper>();
for(Integer i = 0; i< listInvoicesVal.size(); i++) {
InvoiceWrapper invcWrap = new InvoiceWrapper();
invcWrap = listInvoicesVal[i];
//invcWrap.isEditable = true;
// invcWrap.isRemoveEnable = true;
//invcWrap.index = i;
// invcWrap.msg = SUCCESS_MSG;
listInvoiceLineItemWrapper.clear();
for(Integer j = 0; j< listInvoiceLineItemToUpsert.size(); j++) {   
if(listInvoiceLineItemToUpsert[j].Invoice__c == invcWrap.invoiceRec.id){
InvoiceLineItemWrapper objInvoiceLineItemWrapper = new InvoiceLineItemWrapper();
objInvoiceLineItemWrapper.invoiceLineItemRec = listInvoiceLineItemToUpsert[j];
objInvoiceLineItemWrapper.isEditable = true;
objInvoiceLineItemWrapper.isRemoveEnable = false;
//invcWrap.index = i;
objInvoiceLineItemWrapper.msg = SUCCESS_MSG;
listInvoiceLineItemWrapper.add(objInvoiceLineItemWrapper);
}  
}
invcWrap.listInvoiceLineItemWrap = listInvoiceLineItemWrapper;
lstInvoicesWrapper.add(invcWrap);
system.debug(lstInvoicesWrapper);
}                
}
return lstInvoicesWrapper;
}
*/
    
    /*
Method Name : createInvoiceRecords
Description : Used to create Invoice record 

@AuraEnabled
public static List<InvoiceWrapper> createInvoiceRecords(List<InvoiceWrapper> listInvoicesWrapVal, Integer indexVal) { 
system.debug('-----Inside Invoice '+listInvoicesWrapVal);
List<InvoiceWrapper> lstInvoicesWrapper = new List<InvoiceWrapper>();
if(listInvoicesWrapVal <> null && listInvoicesWrapVal.size() > 0 && indexVal != null){

// Create invoice number map
Map<String, Id> mapOfReceiptNameWithId = new Map<String, Id>();
system.debug('---->'+[SELECT ID, NAME FROM Receipt__c WHERE  Status__c = 'Draft' and Entity__c =: listInvoicesWrapVal[0].invoiceRec.Entity__c]);
for(Receipt__c objReceipt : [SELECT ID, NAME FROM Receipt__c WHERE  Status__c = 'Draft' and Entity__c =: listInvoicesWrapVal[0].invoiceRec.Entity__c]) {
mapOfReceiptNameWithId.put(objReceipt.Name, objReceipt.Id);
}
system.debug('---->'+mapOfReceiptNameWithId);
Map<Integer,Invoice__c> mapInvoiceToUpsert = new Map<Integer,Invoice__c>();
Map<Integer,String> mapRelatedReceipt = new Map<Integer,String>();
Invoice__c objInv;
Integer counter = 0;
for(InvoiceWrapper objInvoiceWrapper : listInvoicesWrapVal) {
objInv = new Invoice__c();
objInv = objInvoiceWrapper.invoiceRec;

if(objInvoiceWrapper.relatedReceipt != null && objInvoiceWrapper.relatedReceipt != ''){
objInv.Transaction_Type__c = 'PREPAID';
} else {
objInv.Transaction_Type__c = 'POSTPAID';
}

if(objInvoiceWrapper.relatedReceipt <> null && String.isNotBlank(objInvoiceWrapper.relatedReceipt ) && mapOfReceiptNameWithId.get(objInvoiceWrapper.relatedReceipt ) <> null) {
//objInv.Related_Receipt__c = mapOfReceiptNameWithId.get(objInvoiceWrapper.relatedReceipt );
}
//listInvoiceToUpsert.add(objInv);
mapInvoiceToUpsert.put(counter,objInv);
mapRelatedReceipt.put(counter, objInvoiceWrapper.relatedReceipt);
counter++;
}
//system.debug('objInvoiceWrapper---->'+listInvoiceToUpsert);
try{
upsert mapInvoiceToUpsert.values();
createRelatedReceipt(mapInvoiceToUpsert,mapRelatedReceipt);
// insert related object code goes here.....
} catch(Exception ex) {
system.debug(ex.getMessage());

InvoiceWrapper invcWrap = new InvoiceWrapper();
invcWrap.msg = ex.getMessage();
lstInvoicesWrapper.add(invcWrap);
return lstInvoicesWrapper;

}

Set<Id> setUpdatedInvIds = new Set<Id>();
for(Invoice__c objInvoice :  mapInvoiceToUpsert.values()) {
setUpdatedInvIds.add(objInvoice.id);
}
system.debug('listInvoiceToUpsert--->'+mapInvoiceToUpsert.values());
List<Invoice__c> listInvoice = new List<Invoice__c>();
listInvoice = [select id,Name,Payment_Currency__c,Payment_Term__c,Transaction_Reference__c,Description__c,Invoice_Date__c,Invoice_Class__c, Is_Created_Manually__c, Related_Receipt__c, Related_Receipt__r.Name, Entity__c from Invoice__c WHERE id IN:setUpdatedInvIds ];
system.debug('listInvoice--->'+listInvoice);
//system.debug(listInvoice[0].id);
if(indexVal >= 0 && listInvoice.size() == 1){
system.debug('Single Save');
InvoiceWrapper invcWrap = new InvoiceWrapper();
invcWrap.invoiceRec = listInvoice[0];
invcWrap.relatedReceipt = listInvoice[0].Related_Receipt__r.Name;
invcWrap.listInvoiceLineItemWrap = listInvoicesWrapVal[0].listInvoiceLineItemWrap;
invcWrap.isEditable = true;
invcWrap.isRemoveEnable = true;
invcWrap.index = indexVal;
invcWrap.msg = SUCCESS_MSG;
lstInvoicesWrapper.add(invcWrap);
} else {
system.debug('Save All Called');
for(Integer i = 0; i< listInvoicesWrapVal.size(); i++){
InvoiceWrapper invcWrap = new InvoiceWrapper();
invcWrap.invoiceRec = listInvoice[i];
invcWrap.relatedReceipt = listInvoice[i].Related_Receipt__r.Name;
invcWrap.listInvoiceLineItemWrap = listInvoicesWrapVal[i].listInvoiceLineItemWrap;
invcWrap.isEditable = true;
invcWrap.isRemoveEnable = true;
invcWrap.index = i;
invcWrap.msg = SUCCESS_MSG;
lstInvoicesWrapper.add(invcWrap);
system.debug(lstInvoicesWrapper);
}
}

}

return lstInvoicesWrapper;
}


// Add or Remove Related Receipt on  Related_Invoice_Receipt__c object based on the page field 
public static void createRelatedReceipt(Map<Integer,Invoice__c> invoiceMap, Map<Integer, String> relatedReceiptMap){
List<Id> invoiceIds = new List<Id>();
for(Invoice__c inv : invoiceMap.values()){
invoiceIds.add(inv.Id);
}

Map<String,Set<String>> invoiceVsReceiptsMap = new Map<String,Set<String>>();
Map<Id,List<Related_Invoice_Receipt__c>> invoiceVsJNMap = new Map<Id,List<Related_Invoice_Receipt__c>>();
for(Related_Invoice_Receipt__c relatedInvoices : [SELECT Id,Receipt__r.Name,Invoice__c from Related_Invoice_Receipt__c WHERE Invoice__c IN : invoiceIds]){
if(invoiceVsReceiptsMap.containsKey(relatedInvoices.Invoice__c)){
invoiceVsReceiptsMap.get(relatedInvoices.Invoice__c).add(relatedInvoices.Receipt__r.Name);
} else {
invoiceVsReceiptsMap.put(relatedInvoices.Invoice__c, new Set<String>{relatedInvoices.Receipt__r.Name});
}

if(invoiceVsJNMap.containsKey(relatedInvoices.Invoice__c)){
invoiceVsJNMap.get(relatedInvoices.Invoice__c).add(relatedInvoices);
} else {
invoiceVsJNMap.put(relatedInvoices.Invoice__c, new List<Related_Invoice_Receipt__c>{relatedInvoices});
}
}

Set<String> allReceiptNames = new Set<String>();
for(String eachStr : relatedReceiptMap.values()){
if(eachStr != null && eachStr != ''){
allReceiptNames.addAll(eachStr.split(','));
}  
}

Map<String,Id> receiptNameVsIdMap = new Map<String,Id>();
for(Receipt__c eachReceipt : [SELECT Id,Name from Receipt__c WHERE Name IN : allReceiptNames]){
receiptNameVsIdMap.put(eachReceipt.Name, eachReceipt.id);
}

List<Related_Invoice_Receipt__c> relatedReceipt = new List<Related_Invoice_Receipt__c>();
List<Related_Invoice_Receipt__c> relatedReceiptToDelete = new List<Related_Invoice_Receipt__c>();
for(Integer i : invoiceMap.keyset()){
if(relatedReceiptMap.containskey(i)){
if(relatedReceiptMap.get(i) != null && relatedReceiptMap.get(i) != ''){
List<String> receiptsList = new List<String>();
receiptsList = relatedReceiptMap.get(i).split(',');
Set<String> receiptsSet = new Set<String>();
receiptsSet.addAll(receiptsList);

for(String s : receiptsList){
if(invoiceVsReceiptsMap.containsKey(invoiceMap.get(i).id)){
if(! invoiceVsReceiptsMap.get(invoiceMap.get(i).id).contains(s)){
if(receiptNameVsIdMap.containsKey(s)){
relatedReceipt.add(new Related_Invoice_Receipt__c(Invoice__c = invoiceMap.get(i).id, Receipt__c =receiptNameVsIdMap.get(s)));
}   
}
} else {
if(receiptNameVsIdMap.containsKey(s)){
relatedReceipt.add(new Related_Invoice_Receipt__c(Invoice__c = invoiceMap.get(i).id, Receipt__c =receiptNameVsIdMap.get(s)));
}   
}
}

if(invoiceVsJNMap.containskey(invoiceMap.get(i).Id)){
for(Related_Invoice_Receipt__c eachObj : invoiceVsJNMap.get(invoiceMap.get(i).Id)){
if(! receiptsSet.contains(eachObj.Receipt__r.Name)){
relatedReceiptToDelete.add(eachObj);
}
}
}

} else {
if(invoiceVsJNMap.containskey(invoiceMap.get(i).Id)){
relatedReceiptToDelete.addAll(invoiceVsJNMap.get(invoiceMap.get(i).Id));
}    
}
}
}

if(relatedReceipt.size() > 0){
insert relatedReceipt;
}

if(relatedReceiptToDelete.size() > 0){
delete relatedReceiptToDelete;
}
}

//------------------------------- End of Add or Remove Related_Invoice_Receipt__c object based on the page field ----------------------


// Add or Remove Related Invoice on  Related_Invoice_Receipt__c object based on the page field 
public static void createRelatedInvoice(Map<Integer,Receipt__c> receiptMap, Map<Integer, String> relatedInvoiceMap,Map<Integer, String> relatedInvoiceAmountApplied){
List<Id> receiptIds = new List<Id>();
for(Receipt__c rec : receiptMap.values()){
receiptIds.add(rec.Id);
}

Map<String,Set<String>> receiptVsInvoicesMap = new Map<String,Set<String>>();
Map<Id,List<Related_Invoice_Receipt__c>> receiptVsJNMap = new Map<Id,List<Related_Invoice_Receipt__c>>();
for(Related_Invoice_Receipt__c relatedReceipts : [SELECT Id,Receipt__r.Name,Invoice__c,Invoice__r.Name,Receipt__c from Related_Invoice_Receipt__c WHERE Receipt__c IN : receiptIds]){
if(receiptVsInvoicesMap.containsKey(relatedReceipts.Invoice__c)){
receiptVsInvoicesMap.get(relatedReceipts.Receipt__c).add(relatedReceipts.Invoice__r.Name);
} else {
receiptVsInvoicesMap.put(relatedReceipts.Receipt__c, new Set<String>{relatedReceipts.Invoice__r.Name});
}

if(receiptVsJNMap.containsKey(relatedReceipts.Receipt__c)){
receiptVsJNMap.get(relatedReceipts.Receipt__c).add(relatedReceipts);
} else {
receiptVsJNMap.put(relatedReceipts.Receipt__c, new List<Related_Invoice_Receipt__c>{relatedReceipts});
}
}

Set<String> allInvoiceNames = new Set<String>();
for(String eachStr : relatedInvoiceMap.values()){
if(eachStr != null && eachStr != ''){
allInvoiceNames.addAll(eachStr.split(','));
}  
}

Map<String,Id> invoiceNameVsIdMap = new Map<String,Id>();
for(Invoice__c eachInvoice : [SELECT Id,Name from Invoice__c WHERE Name IN : allInvoiceNames]){
invoiceNameVsIdMap.put(eachInvoice.Name, eachInvoice.id);
}

List<Related_Invoice_Receipt__c> relatedInvoice = new List<Related_Invoice_Receipt__c>();
List<Related_Invoice_Receipt__c> relatedInvoiceToDelete = new List<Related_Invoice_Receipt__c>();
for(Integer i : receiptMap.keyset()){
if(relatedInvoiceMap.containskey(i) && relatedInvoiceAmountApplied.containsKey(i)){
if(relatedInvoiceMap.get(i) != null && relatedInvoiceMap.get(i) != '' && relatedInvoiceAmountApplied.get(i) != null && relatedInvoiceAmountApplied.get(i) != ''){
List<String> invoicesList = new List<String>();
invoicesList = relatedInvoiceMap.get(i).split(',');

List<String> invoicesAmountApplied = new List<String>();
invoicesAmountApplied = relatedInvoiceAmountApplied.get(i).split(',');

Map<String,String> invoiceVsAmountAppliedMap = new Map<String,String>();

for(Integer cnt = 0; cnt<invoicesList.size(); cnt++){
invoiceVsAmountAppliedMap.put(invoicesList[cnt], invoicesAmountApplied[cnt]);
}

Set<String> invoiceSet = new Set<String>();
invoiceSet.addAll(invoicesList);

for(String s : invoicesList){
if(receiptVsInvoicesMap.containsKey(receiptMap.get(i).id)){
if(! receiptVsInvoicesMap.get(receiptMap.get(i).id).contains(s)){
if(receiptVsInvoicesMap.containsKey(s)){
relatedInvoice.add(new Related_Invoice_Receipt__c(Amount_Applied__c = Decimal.valueof(invoiceVsAmountAppliedMap.get(s)),Receipt__c = receiptMap.get(i).id, Invoice__c =invoiceNameVsIdMap.get(s)));
}   
}
} else {
if(invoiceNameVsIdMap.containsKey(s)){
relatedInvoice.add(new Related_Invoice_Receipt__c(Amount_Applied__c = Decimal.valueof(invoiceVsAmountAppliedMap.get(s)),Receipt__c = receiptMap.get(i).id, Invoice__c =invoiceNameVsIdMap.get(s)));
}   
}
}

if(receiptVsJNMap.containskey(receiptMap.get(i).Id)){
for(Related_Invoice_Receipt__c eachObj : receiptVsJNMap.get(receiptMap.get(i).Id)){
if(! invoiceSet.contains(eachObj.Invoice__r.Name)){
relatedInvoiceToDelete.add(eachObj);
}
}
}

} else {
if(receiptVsJNMap.containskey(receiptMap.get(i).Id)){
relatedInvoiceToDelete.addAll(receiptVsJNMap.get(receiptMap.get(i).Id));
}    
}
}
}

if(relatedInvoice.size() > 0){
insert relatedInvoice;
}

if(relatedInvoiceToDelete.size() > 0){
delete relatedInvoiceToDelete;
}
}
//------------------------------- End of Add or Remove Related_Invoice_Receipt__c object based on the page field ----------------------
*/
    /*
Method Name : fetchEntityRecordTypeValues
Description : Used to get record type
*/
    @AuraEnabled        
    public static List<Recordtype> fetchEntityRecordTypeValues() {
        List<Recordtype> listRecordTypes = new List<Recordtype>();
        Recordtype objRecordtype;
        List<Schema.RecordTypeInfo> recordtypes = Account.SObjectType.getDescribe().getRecordTypeInfos(); 
        for(RecordTypeInfo objRecordTypeInfo : recordtypes) {
            if(objRecordTypeInfo.isAvailable() && objRecordTypeInfo.getName() != 'Master') {
                objRecordtype= new Recordtype();
                objRecordtype.id = objRecordTypeInfo.getRecordTypeId();
                objRecordtype.Name = objRecordTypeInfo.getName();
                listRecordTypes.add(objRecordtype);
            }
        }
        return listRecordTypes;
    }
    
    /*
Method Name : submitForApproval
Description : Used to submit the selected receipt and invoice for approval
*/
    @AuraEnabled
    public static String submitRecordsForApproval (List<ReceiptsWrapper> listReceiptWrapper , List<InvoiceWrapper> listInvoiceWrapper ) {
        system.debug('Inside Submit for Approval');
        //Savepoint sp = Database.setSavepoint(); 
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
        system.debug('listReceiptWrapper---->'+listReceiptWrapper);
        system.debug('listInvoiceWrapper---->'+listInvoiceWrapper);
        
        if(listReceiptWrapper <> null && listReceiptWrapper.size() > 0) {
            for(ReceiptsWrapper objReceiptWrapper : listReceiptWrapper) {
                //if(objReceiptWrapper.isSelectedForApproval) {
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting receipt for approval ');req1.setObjectId(objReceiptWrapper.receiptRec.id);requests.add(req1);
                //} 
            }
            
        }
        
        if(listInvoiceWrapper <> null && listInvoiceWrapper.size() > 0) {
            for(InvoiceWrapper objInvoiceWrapper : listInvoiceWrapper) {
                //if(objInvoiceWrapper.isSelectedForApproval) {
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting invoice for approval ');req1.setObjectId(objInvoiceWrapper.invoiceRec.id);requests.add(req1);
                //}
                
            }
        }
        
        if(requests <> null && requests.size() > 0 ) {
            List<Approval.ProcessResult> processResults = new List<Approval.ProcessResult>();
            try {processResults = Approval.process(requests, true);
            }catch (exception ex) {System.debug('Exception Is ' + ex.getMessage()); return  ex.getMessage();
            }
        }
        
        
        return SUCCESS_MSG;
    }
    
    /*
Method Name : pushReciptToERP
Description : Used to submit the selected receipt and invoice for approval
*/
    @AuraEnabled
    public static string pushReciptToERP(String recordId, Boolean isReceipt){
        system.debug('--->'+recordId); 
        /*if(string.isNotBlank(recordId) && isReceipt){
            string resMSG = ReceiptUtil.PushReceiptToOracle_New(recordId);
            system.debug('---->'+resMSG);
            return resMSG;
        } else */
        if(string.isNotBlank(recordId) && !isReceipt){
            List<Invoice__c> invLst = [SELECT id,Recordtype.name FROM Invoice__c WHERE Id =: recordId];
            if(invLst[0].Recordtype.Name == 'Invoice'){
                return InvoiceUtil_New.updateInvoiceAndCreateJournalEntries(new List<string> {recordId});
            } /*else {
                return CreditMemoUtil.pushToOracleCreditMemo(new List<string> {recordId});
            }*/
            
        }
        return 'Record not found';
    }
    
    
    /*
Method Name : Get picklist value map
Description : Used send pickist map for invoice type and item description
*/
    @AuraEnabled
    public static List<string> getInvoiceRevenue (String oracle_SiteId, Boolean isType, String selectedInvoiceType, Boolean isCreditMemo) {
        
        List<String> listInvoiceRevenue = new List<String>();
        system.debug('----->'+oracle_SiteId);
        List<Revenue_Classification__c> listInvoiceRe = new List<Revenue_Classification__c>();
        if(isType) {listInvoiceRe = [SELECT Invoice_Type__c, Item_Description__c FROM Revenue_Classification__c WHERE toLabel(Oracle_Site_Id__c) = : oracle_SiteId and Is_Credit_Memo__c = : isCreditMemo ];
        } else {listInvoiceRe = [SELECT Invoice_Type__c, Item_Description__c FROM Revenue_Classification__c WHERE toLabel(Oracle_Site_Id__c) = : oracle_SiteId AND Invoice_Type__c =: selectedInvoiceType and Is_Credit_Memo__c = : isCreditMemo];
        }
        system.debug('----->'+listInvoiceRe);
        for(Revenue_Classification__c objInvoiceRevenue : listInvoiceRe) {
            if(isType) {listInvoiceRevenue.add(objInvoiceRevenue.Invoice_Type__c);
            }else {listInvoiceRevenue.add(objInvoiceRevenue.Item_Description__c);
            }
        }
        system.debug('----->'+listInvoiceRevenue);
        return listInvoiceRevenue;
    }
    
    @AuraEnabled
    public static RevenueMappingWrapper getInvoiceRevenueMapping (String accId, Boolean isCreditMemo) {
        Account acc = [SELECT id,Record_Type_Name__c,Source_System_Name__c,Source_System__c,Oracle_Site_Id__c,Operating_Unit__c,Operating_Unit__r.Invoice_Type__c,Operating_Unit__r.Credit_Memo_Type__c,Operating_Unit__r.Department__c, 
                       Operating_Unit__r.Default_Currency__c,Operating_Unit__r.Tax_Code__c,Operating_Unit__r.Default_School_Type__c FROM Account WHERE Id =: accId];
        /*List<Revenue_Classification__c> listInvoiceRe = [SELECT Id,Invoice_Type__c,Revenue_Type__c,Service_Type__c,Line_Item_Type__c FROM Revenue_Classification__c 
WHERE Oracle_Site_Id__c =: acc.Oracle_Site_Id__c AND Source_System_Name__c =: acc.Source_System_Name__c AND Source_System__c includes (:acc.Source_System__c) AND Is_Credit_Memo__c =: isCreditMemo];
System.debug(listInvoiceRe.size());
Map<String,List<Map<String,List<String>>>> finalMap = new Map<String,List<Map<String,List<String>>>>();
for(Revenue_Classification__c rc : listInvoiceRe){
if(finalMap.containsKey(rc.Invoice_Type__c)){
System.debug('Within if 1 condition');
for(Map<String,List<String>> innerMap : finalMap.get(rc.Invoice_Type__c)){
if(innerMap.containsKey(rc.Service_Type__c)){
innerMap.get(rc.Service_Type__c).add(rc.Line_Item_Type__c);
} else {
finalMap.get(rc.Invoice_Type__c).add(new Map<String,List<String>>{rc.Service_Type__c => new List<String>{rc.Line_Item_Type__c}});
}
}
} else {
System.debug('Within else 1 condition');
finalMap.put(rc.Invoice_Type__c, new List<Map<String,List<String>>>{new map<String,List<String>>{rc.Service_Type__c => new List<String>{rc.Line_Item_Type__c}}});
}
} */
        
        List<String> depts = new List<String>();
        if(acc.Operating_Unit__r.Department__c != null){depts = acc.Operating_Unit__r.Department__c.split(';');
        }
        
        List<Revenue_Classification__c> listInvoiceRe = [SELECT Id,Invoice_Type__c,Revenue_Type__c,Service_Type__c,Line_Item_Type__c,Service_Class__c,Room_Rates_USD__c FROM Revenue_Classification__c 
                                                         WHERE Operating_Unit__c =: acc.Operating_Unit__c AND Is_Credit_Memo__c =: isCreditMemo ORDER BY Service_Type__c ASC, Line_Item_Type__c ASC];
        System.debug(listInvoiceRe.size());
        
        
        Map<String, List<String>> revenueMap = new Map<String,List<String>>();
        for(Revenue_Classification__c rc : listInvoiceRe){
            if(acc.Oracle_Site_Id__c == '104'){
                if(revenueMap.containsKey(rc.Service_Type__c)){ revenueMap.get(rc.Service_Type__c).add(rc.Service_Class__c);
                } else { revenueMap.put(rc.Service_Type__c, new List<String>{rc.Service_Class__c});
                }
            } else {
                if(revenueMap.containsKey(rc.Service_Type__c)){revenueMap.get(rc.Service_Type__c).add(rc.Line_Item_Type__c);
                } else {revenueMap.put(rc.Service_Type__c, new List<String>{rc.Line_Item_Type__c});
                }
            }
            
        }
        
        // get payment term, currency and tax code
        List<Operating_Unit__c> listOperating_Unit = [SELECT id, Currency_To_Display__c, Payment_Term_To_Show__c, Tax_Codes_To_Display__c,Show_Department__c,
                                                      Show_Description__c,Show_Item_Type__c,Show_Quantity__c,Quantity_Label__c,Show_Service_Class__c,Service_Class__c ,Default_Payment_Term__c 
                                                      FROM Operating_Unit__c 
                                                      WHERE id =: acc.Operating_Unit__c];
        
        RevenueMappingWrapper wrap = new RevenueMappingWrapper();
        wrap.defaultCurrency = acc.Operating_Unit__r.Default_Currency__c;
        wrap.defaultTaxCode = acc.Operating_Unit__r.Tax_Code__c;
        wrap.schoolType = acc.Operating_Unit__r.Default_School_Type__c;
        
        // wrap.defaultDept = acc.Operating_Unit__r.Default_Department__c;
        if(listInvoiceRe.size() > 0){
            if(isCreditMemo){ wrap.invType = acc.Operating_Unit__r.Credit_Memo_Type__c; } 
            else { wrap.invType = acc.Operating_Unit__r.Invoice_Type__c; }
            wrap.departments = depts;
            
            if(listOperating_Unit <> null && listOperating_Unit.size() > 0) {
                wrap.defaultPaymentTerm = listOperating_Unit[0].Default_Payment_Term__c;wrap.ouObj = listOperating_Unit[0];wrap.listPaymentTerm = listOperating_Unit[0].Payment_Term_To_Show__c.split(';');wrap.listTaxCode = listOperating_Unit[0].Tax_Codes_To_Display__c.split(';');wrap.listCurrencyToDisplay = listOperating_Unit[0].Currency_To_Display__c.split(';');
                if(listOperating_Unit[0].Service_Class__c != null){ wrap.serviceClasses = listOperating_Unit[0].Service_Class__c.split(';');    }
            }
            
            if(acc.Record_Type_Name__c == 'ADGM_Arbitration_Center'){
                for(Revenue_Classification__c rc : listInvoiceRe){
                    RateWrapper rtw = new RateWrapper();rtw.lineType = rc.Line_Item_Type__c;rtw.usdrate  = rc.Room_Rates_USD__c;wrap.roomRates.add(rtw);
                }
            }
            
            for(String s : revenueMap.keySet()){
                ChildWrapper cw = new ChildWrapper();
                cw.serType = s;
                for(String s1 : revenueMap.get(s)){
                    if(! cw.lineItemType.contains(s1)){cw.lineItemType.add(s1);}
                }
                wrap.invRevenueMap.add(cw);
            }
            //wrap.invRevenueMap.sort();
            //wrap.invRevenueMap = revenueMap;
        }
        system.debug(wrap);
        return wrap;
    }
    
    public class RevenueMappingWrapper{
        @AuraEnabled
        public string invType;
        @AuraEnabled
        public List<string> departments;
        @AuraEnabled
        public string defaultCurrency;
        @AuraEnabled
        public string defaultTaxCode;
        @AuraEnabled
        public List<ChildWrapper> invRevenueMap;
        @AuraEnabled
        public List<String> listCurrencyToDisplay;
        @AuraEnabled
        public List<String> listPaymentTerm;
        @AuraEnabled
        public String schoolType;
        @AuraEnabled
        public List<String> listTaxCode;
        @AuraEnabled
        public List<String> serviceClasses;
        @AuraEnabled
        public Operating_Unit__c ouObj;
        @AuraEnabled
        public List<RateWrapper> roomRates;
        @AuraEnabled
        public String defaultPaymentTerm;
        public RevenueMappingWrapper(){
            invRevenueMap = new List<ChildWrapper>();
            departments = new List<String>();
            listTaxCode = new List<String>();
            listCurrencyToDisplay = new List<String>();
            listPaymentTerm = new List<String>();
            serviceClasses = new List<String>();
            roomRates = new List<RateWrapper>();
            defaultPaymentTerm = '';
        }
    }
    
    public class ChildWrapper{
        @AuraEnabled
        public string serType;
        @AuraEnabled
        public List<string> lineItemType;
        public ChildWrapper(){lineItemType = new List<string>();
        }
    }
    
    public class RateWrapper{
        @AuraEnabled
        public string lineType;
        @AuraEnabled
        public Double usdrate;
    }
    
    //-------------------------------New Component Methods -------------------------------------
    
    @AuraEnabled
    public static string upsertReceiptAndRelatedInvoices(Receipt__c recRecord, List<RelatedInvClass> lineItemsBody, List<AttachmentWrapper> attachmentFiles){
        system.debug('--->'+recRecord);
        system.debug('--->'+lineItemsBody);
        system.debug('--->'+lineItemsBody.size());
        Savepoint sp = Database.setSavepoint();
        try{
            User objUser = [select id,Name, Profile.Name from User where id =: userInfo.getUserId()];
            if(lineItemsBody.size() > 0){
                recRecord.Transaction_Type__c = 'NonWallet';
            } else {recRecord.Transaction_Type__c = 'Wallet';
            }
            /*if(objUser.Profile.Name <> 'ADGM Finance Manager'){
recRecord.Status__c = 'Draft';
}else{
recRecord.Status__c = 'Success';
} */
            recRecord.Is_Created_Manually__c = false;
            recRecord.Status__c = 'Success';
            upsert recRecord;
            
            if(attachmentFiles.size() > 0){
                List<ContentVersion> conVersions = new List<ContentVersion>();
                for(AttachmentWrapper eachAW : attachmentFiles){
                    System.debug(eachAW.fileName);
                    System.debug(eachAW.isUploaded);
                    if(eachAW.isUploaded){
                        ContentVersion contentVers = new ContentVersion();
                        contentVers.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
                        contentVers.PathOnClient = eachAW.fileName; 
                        contentVers.Title = eachAW.fileName;
                        contentVers.VersionData = EncodingUtil.base64Decode(eachAW.blobval); // contentVersting your binary string to Blog
                        conVersions.add(contentVers);
                    }
                }
                
                if(conVersions.size() > 0){
                    insert conVersions;
                    List<ContentVersion> insertedCV = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :conVersions];
                    List<ContentDocumentLink> contentDocToInsert = new List<ContentDocumentLink>();
                    for(ContentVersion eachCV : insertedCV){
                        ContentDocumentLink contentLink = new ContentDocumentLink();
                        contentLink.ContentDocumentId = eachCV.ContentDocumentId;
                        contentLink.LinkedEntityId = recRecord.Id; 
                        contentLink.ShareType = 'I'; // Inferred permission
                        contentLink.Visibility = 'AllUsers';
                        contentDocToInsert.add(contentLink);
                    }
                    if(contentDocToInsert.size() > 0){
                        insert contentDocToInsert;
                    }
                }        
            }
            
            if(lineItemsBody.size() > 0){
                Map<String, List<Related_Invoice_Receipt__c>> relatedInvoiceReceiptMap = new Map<String, List<Related_Invoice_Receipt__c>>{'forInsert'=> new List<Related_Invoice_Receipt__c>(), 'forDelete'=> new List<Related_Invoice_Receipt__c>()};
                    List<Related_Invoice_Receipt__c> oldRelatedRecords = [SELECT Id,Invoice__c,Receipt__c from Related_Invoice_Receipt__c WHERE Receipt__c =: recRecord.Id];
                if(oldRelatedRecords.size() > 0){
                    Set<Id> newInvoiceIds = new Set<Id>();
                    Map<Id,Related_Invoice_Receipt__c> existingInvoiceIds = new Map<Id,Related_Invoice_Receipt__c>();
                    for(Related_Invoice_Receipt__c eachObj : oldRelatedRecords){
                        existingInvoiceIds.put(eachObj.Invoice__c, eachObj);
                    }
                    
                    for(RelatedInvClass lineObj : lineItemsBody){
                        newInvoiceIds.add(lineObj.invoiceId);
                        if(! existingInvoiceIds.containskey(lineObj.invoiceId)){
                            relatedInvoiceReceiptMap.get('forInsert').add(new Related_Invoice_Receipt__c(Invoice__c = lineObj.invoiceId ,Receipt__c = recRecord.Id ,Oracle_Applied_Amount__c = lineObj.Amount, Amount_Applied__c = lineObj.Amount, Direction__c='From Receipt To Invoice',Applied_Date__c=Date.valueof(lineObj.AppliedDate))); //,Applied_Date__c=lineObj.AppliedDate
                        } else if(existingInvoiceIds.containskey(lineObj.invoiceId)){
                            Related_Invoice_Receipt__c rir = new Related_Invoice_Receipt__c();
                            rir = existingInvoiceIds.get(lineObj.invoiceId);
                            //rir.Invoice__c = lineObj.invoiceId;
                            rir.ORACLE_Applied_Amount__c = lineObj.Amount;
                            rir.Amount_Applied__c = lineObj.Amount;
                            rir.Applied_Date__c=Date.valueof(lineObj.AppliedDate);
                            relatedInvoiceReceiptMap.get('forInsert').add(rir);
                        }
                    }
                    
                    for(Related_Invoice_Receipt__c obj : oldRelatedRecords){
                        if(! newInvoiceIds.contains(obj.Invoice__c)){relatedInvoiceReceiptMap.get('forDelete').add(obj);
                        }
                    }
                } else {
                    for(RelatedInvClass lineObj : lineItemsBody){
                        relatedInvoiceReceiptMap.get('forInsert').add(new Related_Invoice_Receipt__c(Invoice__c = lineObj.invoiceId ,Receipt__c = recRecord.Id ,Oracle_Applied_Amount__c = lineObj.Amount, Amount_Applied__c = lineObj.Amount, Direction__c='From Receipt To Invoice',Applied_Date__c=Date.valueof(lineObj.AppliedDate))); //,Applied_Date__c=lineObj.AppliedDate
                    }
                }
                
                if(relatedInvoiceReceiptMap.get('forInsert').size() > 0 ){
                    upsert relatedInvoiceReceiptMap.get('forInsert');
                }
                
                if(relatedInvoiceReceiptMap.get('forDelete').size() > 0 ){ delete relatedInvoiceReceiptMap.get('forDelete');
                }
            }
        } catch(Exception e){return e.getMessage();Database.RollBack(sp);
        }
        return 'Success';
    }
    
    public class AttachmentWrapper {
        @AuraEnabled public String fileName {get;set;}
        @AuraEnabled public String blobval {get;set;} 
        @AuraEnabled public Boolean isUploaded {get;set;}
    }
    
    @AuraEnabled
    public static ResponseWrapper upsertCreditMemo(Invoice__c invRecord, List<Invoice_Line_Item__c> invoiceLines, List<RelatedReceiptClass> relatedReceipts, Boolean isCreditMemo, String selectedDeptVal){
        system.debug('Inside Credit Memo----->');
        Savepoint sp = Database.setSavepoint();
        ResponseWrapper objResponseWrapper = new ResponseWrapper();
        try {
            
            User objUser = [select id,Name, Profile.Name from User where id =: userInfo.getUserId()];
            if(isCreditMemo) {
                Map<String,Id> mapofInvoiceRecordTypeNameandId = new Map<String,Id>();
                mapofInvoiceRecordTypeNameandId = ApexCodeUtility.getRecTypeDetails('Invoice__c');
                invRecord.recordtypeId = mapofInvoiceRecordTypeNameandId.get('Credit Memo'); 
                invRecord.Invoice_Type__c = 'Credit Memo';
                invRecord.Is_Refundable__c = isCreditMemo;
                invRecord.Invoice_Date__c = system.today();
            }
            
            ///if(relatedReceipts.size() > 0){
            // invRecord.Transaction_Type__c = 'Wallet';
            // } else {
            // invRecord.Transaction_Type__c = 'NonWallet';
            // }
            
            if(objUser.Profile.Name <> 'ADGM Finance Manager')
                invRecord.Status__c = 'Draft';
            else
                invRecord.Status__c = 'Success';
            upsert invRecord;
            if(invoiceLines.size() > 0){
                for(Invoice_Line_Item__c ili : invoiceLines){
                    ili.Invoice__c = invRecord.Id;
                    ili.Status__c = 'Draft';
                    if(selectedDeptVal <> null && selectedDeptVal <> '')
                        ili.Department__c = selectedDeptVal;
                    Integer iTaxPercent = (Constants.SET_TAX_VALUES.contains(ili.Tax__c) ? Constants.TAX_PERCENT : 0);
                    ili.Tax_Amount__c = (ili.Amount__c != null ? (ili.Amount__c*((decimal)iTaxPercent/100)) : 0);
                    ili.Taxable_Discount_Amount__c = (ili.Discount_Amount__c != null ? (ili.Discount_Amount__c*((decimal)iTaxPercent/100)) : null);
                    
                    /* IDK why this is - RB
if(ili.Amount__c > 0)
ili.Amount__c = ili.Amount__c;
if(ili.Tax_Amount__c > 0)
ili.Tax_Amount__c = ili.Tax_Amount__c;
*/
                }
                upsert invoiceLines;
            }
            
            
            objResponseWrapper.invoiceRec = invRecord;
            objResponseWrapper.listInvoiceLineRec = invoiceLines;
            objResponseWrapper.msg = 'Success';
            /*
if(relatedReceipts.size() > 0){
Map<String, List<Related_Invoice_Receipt__c>> relatedInvoiceReceiptMap = new Map<String, List<Related_Invoice_Receipt__c>>{'forInsert'=> new List<Related_Invoice_Receipt__c>(), 'forDelete'=> new List<Related_Invoice_Receipt__c>()};
List<Related_Invoice_Receipt__c> oldRelatedRecords = [SELECT Id,Invoice__c,Receipt__c from Related_Invoice_Receipt__c WHERE Invoice__c =: invRecord.Id];
if(oldRelatedRecords.size() > 0){
Set<Id> newReceiptIds = new Set<Id>();
Set<Id> existingReceiptIds = new Set<Id>();
for(Related_Invoice_Receipt__c eachObj : oldRelatedRecords){
existingReceiptIds.add(eachObj.Receipt__c);
}

for(RelatedReceiptClass eachRelatedReceipt : relatedReceipts){
newReceiptIds.add(eachRelatedReceipt.Id);
if(! existingReceiptIds.contains(eachRelatedReceipt.Id)){
relatedInvoiceReceiptMap.get('forInsert').add(new Related_Invoice_Receipt__c(Invoice__c = invRecord.Id ,Receipt__c = eachRelatedReceipt.Id , Direction__c='From Invoice To Receipt'));
}
}

for(Related_Invoice_Receipt__c obj : oldRelatedRecords){
if(! newReceiptIds.contains(obj.Receipt__c)){
relatedInvoiceReceiptMap.get('forDelete').add(obj);
}
}
} else {
for(RelatedReceiptClass eachItem : relatedReceipts){
relatedInvoiceReceiptMap.get('forInsert').add(new Related_Invoice_Receipt__c(Invoice__c = invRecord.Id ,Receipt__c = eachItem.Id , Direction__c='From Invoice To Receipt'));
}
}

if(relatedInvoiceReceiptMap.get('forInsert').size() > 0 ){
insert relatedInvoiceReceiptMap.get('forInsert');
}

if(relatedInvoiceReceiptMap.get('forDelete').size() > 0 ){
delete relatedInvoiceReceiptMap.get('forDelete');
}
}
*/
        } catch (Exception e) {
            system.debug('Exception----->'+e.getMessage());
            //objResponseWrapper.invoiceRec = invRecord;
            objResponseWrapper.msg = 'Error';return objResponseWrapper; Database.RollBack(sp);
        }
        return objResponseWrapper;
    }
    
    @AuraEnabled
    public static string upsertInvoiceAndRelatedReceipts(Invoice__c invRecord, List<Invoice_Line_Item__c> invoiceLines, List<RelatedReceiptClass> relatedReceipts, Boolean isCreditMemo,List<AttachmentWrapper> attachmentFiles, String selectedDeptVal){
        Savepoint sp = Database.setSavepoint();
        try {
            invRecord.Source_System__c = 'BM';
            User objUser = [select id,Name, Profile.Name from User where id =: userInfo.getUserId()];
            if(isCreditMemo) {
                invRecord.Invoice_Type__c = 'Credit Memo';
                invRecord.Is_Refundable__c = isCreditMemo;
            }
            
            if(relatedReceipts <> null && relatedReceipts.size() > 0){
                invRecord.Transaction_Type__c = 'Wallet';
            } else {invRecord.Transaction_Type__c = 'NonWallet';
            }
            
            if(objUser.Profile.Name <> 'ADGM Finance Manager')
                invRecord.Status__c = 'Draft';
            else{invRecord.Status__c = 'Success';}
                
            upsert invRecord;
            
            
            if(attachmentFiles.size() > 0){
                List<ContentVersion> conVersions = new List<ContentVersion>();
                for(AttachmentWrapper eachAW : attachmentFiles){
                    System.debug(eachAW.fileName);
                    System.debug(eachAW.isUploaded);
                    if(eachAW.isUploaded){
                        ContentVersion contentVers = new ContentVersion();
                        contentVers.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
                        contentVers.PathOnClient = eachAW.fileName; 
                        contentVers.Title = eachAW.fileName;
                        contentVers.VersionData = EncodingUtil.base64Decode(eachAW.blobval); // contentVersting your binary string to Blog
                        conVersions.add(contentVers);
                    }
                }
                
                if(conVersions.size() > 0){
                    insert conVersions;
                    List<ContentVersion> insertedCV = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :conVersions];
                    List<ContentDocumentLink> contentDocToInsert = new List<ContentDocumentLink>();
                    for(ContentVersion eachCV : insertedCV){
                        ContentDocumentLink contentLink = new ContentDocumentLink();
                        contentLink.ContentDocumentId = eachCV.ContentDocumentId;
                        contentLink.LinkedEntityId = invRecord.Id; 
                        contentLink.ShareType = 'I'; // Inferred permission
                        contentLink.Visibility = 'AllUsers';
                        contentDocToInsert.add(contentLink);
                    }
                    if(contentDocToInsert.size() > 0){
                        insert contentDocToInsert;
                    }
                }        
            }
            
            if(invoiceLines.size() > 0){
                Set<Id> existingILIs = new Set<Id>();
                for(Invoice_Line_Item__c ili : invoiceLines){
                    if(ili.Id != null){
                        existingILIs.add(ili.Id);
                    } else {
                        ili.Invoice__c = invRecord.Id;
                        ili.Status__c = 'Draft';
                    }
                    if(selectedDeptVal <> null && selectedDeptVal <> '')
                        ili.Department__c = selectedDeptVal;
                    Integer iTaxPercent = (Constants.SET_TAX_VALUES.contains(ili.Tax__c) ? Constants.TAX_PERCENT : 0);
                    ili.Tax_Amount__c = (ili.Amount__c != null ? (ili.Amount__c*((decimal)iTaxPercent/100)) : 0);
                    ili.Taxable_Discount_Amount__c = (ili.Discount_Amount__c != null ? (ili.Discount_Amount__c*((decimal)iTaxPercent/100)) : null);
                    
                }
                
                List<Invoice_Line_Item__c> deleteInvoiceLines = new List<Invoice_Line_Item__c>();
                for(Invoice_Line_Item__c invoiceLineItems : [SELECT id from Invoice_Line_Item__c WHERE Invoice__c =: invRecord.Id]){
                    if(! existingILIs.contains(invoiceLineItems.Id)){deleteInvoiceLines.add(invoiceLineItems);
                    }
                }
                if(!deleteInvoiceLines.isEmpty()){ DELETE deleteInvoiceLines;
                }
                upsert invoiceLines;
            }
            
            if(relatedReceipts <> null && relatedReceipts.size() > 0){
                Map<String, List<Related_Invoice_Receipt__c>> relatedInvoiceReceiptMap = new Map<String, List<Related_Invoice_Receipt__c>>{'forInsert'=> new List<Related_Invoice_Receipt__c>(), 'forDelete'=> new List<Related_Invoice_Receipt__c>()};
                    List<Related_Invoice_Receipt__c> oldRelatedRecords = [SELECT Id,Invoice__c,Receipt__c from Related_Invoice_Receipt__c WHERE Invoice__c =: invRecord.Id AND Direction__c =: 'From Invoice To Receipt'];
                if(oldRelatedRecords.size() > 0){
                    Set<Id> newReceiptIds = new Set<Id>();
                    Set<Id> existingReceiptIds = new Set<Id>();
                    for(Related_Invoice_Receipt__c eachObj : oldRelatedRecords){
                        existingReceiptIds.add(eachObj.Receipt__c);
                    }
                    
                    for(RelatedReceiptClass eachRelatedReceipt : relatedReceipts){
                        newReceiptIds.add(eachRelatedReceipt.Id);
                        if(! existingReceiptIds.contains(eachRelatedReceipt.Id)){
                            relatedInvoiceReceiptMap.get('forInsert').add(new Related_Invoice_Receipt__c(Invoice__c = invRecord.Id ,Receipt__c = eachRelatedReceipt.Id , Direction__c='From Invoice To Receipt'));
                        }
                    }
                    
                    for(Related_Invoice_Receipt__c obj : oldRelatedRecords){
                        if(! newReceiptIds.contains(obj.Receipt__c)){relatedInvoiceReceiptMap.get('forDelete').add(obj);
                        }
                    }
                } else {
                    for(RelatedReceiptClass eachItem : relatedReceipts){
                        relatedInvoiceReceiptMap.get('forInsert').add(new Related_Invoice_Receipt__c(Invoice__c = invRecord.Id ,Receipt__c = eachItem.Id , Direction__c='From Invoice To Receipt'));
                    }
                }
                
                if(relatedInvoiceReceiptMap.get('forInsert').size() > 0 ){
                    insert relatedInvoiceReceiptMap.get('forInsert');
                }
                
                if(relatedInvoiceReceiptMap.get('forDelete').size() > 0 ){delete relatedInvoiceReceiptMap.get('forDelete');
                }
            }
        } catch (Exception e) {
            system.debug('es is : '+e.getStackTraceString());system.debug('es is : '+e.getLineNumber());system.debug('es is : '+e.getCause());return e.getMessage(); Database.RollBack(sp);
        }
        return 'Success';
    }
    
    @AuraEnabled
    public static map<string, string> TaxValues(){
        map<string, string> mapTaxValues = new map<string, string>();
        for(Schema.PicklistEntry objPE : Invoice_Line_Item__c.Tax__c.getDescribe().getPicklistValues()){
            mapTaxValues.put(objPE.getValue(), objPE.getLabel());
        }
        system.debug('mapTaxValues '+mapTaxValues);
        return mapTaxValues;
    }
    
    @AuraEnabled
    public static list<Account> fetchAccounts(string accountId){
        return [select Id,Name,toLabel(Source_System_Name__c) from Account where ParentId =: accountId];
    }
    
    @AuraEnabled
    public static Account fetchAccountDetail(string accountId){
        return [select Id,Name,Oracle_Party_Id__c from Account where Id =: accountId];
    }
    
    @AuraEnabled
    public static Billing_Management_Setting__mdt fetchBillingManagementMDTDetail(){
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        system.debug('Profile Name'+profileName);
        return [SELECT Add_Invoice__c,Add_Receipt__c,Corporate_Customer__c,Credit_Memo__c,DeveloperName,Fund_Transfer__c,Id,Individual_Customer__c,Label,Default_OU__c,Default_Source_System__c,
                Language,MasterLabel,NamespacePrefix,QualifiedApiName,Refund_Request__c FROM Billing_Management_Setting__mdt WHERE Label =: profileName];
    }
    
    /*Method Name : cancelInvoice
	Description : Used to cancel the selected invoice*/
    
    @AuraEnabled
    public static cancelInvoiceclass cancelInvoice(String recordId){
        // If(String.isNotBlank(recordId)){
        cancelInvoiceclass wr = new cancelInvoiceclass();
        try
        {
            Invoice__c inv = [Select id, Name, Status__c FROM Invoice__c where id=:recordId];
            if(inv.Status__c == 'Draft' || inv.Status__c == 'Rejected'){
                inv.Status__c = 'Cancelled';
                update inv;
                wr.message = 'Invoice Cancelled Successfully.';
                wr.isCancelled = true;
                List<Invoice__c> invlst = [Select id, Name, Status__c,(Select Id from Invoice_Line_Items__r WHERE Recordtype.DeveloperName = 'Invoice_Line_Item') FROM Invoice__c where id= 'a0Z2500000he53vEAA'];
                List<Id> invIdLst = new List<Id>();
                List<Id> invLineItemIdLst = new List<Id>();
                for(Invoice__c inv1 : invlst){
                    invIdLst.add(inv1.Id);
                    for(Invoice_Line_Item__c eachLine : inv1.Invoice_Line_Items__r){invLineItemIdLst.add(eachLine.Id);
                    }
                }
                /*Journal_Header__c jhObj = [Select Id from Journal_Header__c where Transaction_Type__c = 'Sales Invoices' and Invoice__c =: recordId];
                System.debug('invIdLst==='+invIdLst);
                if(invIdLst.size()>0)
                    BM_JournalEntryEngine.journalEntryCreationForReversal(invIdLst,'Invoice__c');*/           
            }else{
                wr.message = 'Invoice should be in Draft or Rejected status in order to cancel.';
                wr.isCancelled = false;
            }
        }catch(Exception e){
            wr.message = e.getMessage();wr.isCancelled = false;
        }
        return wr;
    }
	
	
	
    public class cancelInvoiceclass
    {
        @AuraEnabled public String message;
        @AuraEnabled public boolean isCancelled;
    }
    public class RelatedReceiptClass{
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String Name {get;set;}
        @AuraEnabled public Decimal RecAmt {get;set;}
    } 
    
    public class InvoiceLineClass{
        @AuraEnabled public Decimal Amount {get;set;}
        @AuraEnabled public Decimal TaxAmount {get;set;}
        @AuraEnabled public Decimal DiscountAmount {get;set;}
        @AuraEnabled public Decimal DiscountTaxAmount {get;set;}
        @AuraEnabled public String ItemDescription {get;set;}
        @AuraEnabled public String ItemReference {get;set;} 
        @AuraEnabled public String RecId {get;set;}
    }
    
    public class RelatedInvClass{
        @AuraEnabled public String invoiceNo {get;set;}
        @AuraEnabled public String invoiceId {get;set;}
        @AuraEnabled public Decimal Amount {get;set;}
        @AuraEnabled public Decimal invoiceBalAmt {get;set;}
        @AuraEnabled public String AppliedDate {get;set;}
    }
    
    public class EntityWrapper {
        @AuraEnabled public Account accountRec {get;set;}
        @AuraEnabled public Boolean isSelected {get;set;}
        @AuraEnabled public String msg {get;set;}
    }
    
    public class InvoiceWrapper {
        @AuraEnabled public Invoice__c invoiceRec {get;set;}
        @AuraEnabled public List<Invoice_Line_Item__c> listInvoiceLineRec {get;set;}
        @AuraEnabled public List<RelatedReceiptClass> listRelatedReceiptClass {get;set;}
        @AuraEnabled public String msg {get;set;}
        
        public InvoiceWrapper (){
            
        }                                                                               
    }//end InvoiceWrapper
    /*
public class InvoiceLineItemWrapper {
@AuraEnabled public Invoice_Line_Item__c invoiceLineItemRec {get;set;}
@AuraEnabled public Boolean isEditable {get;set;}
@AuraEnabled public Boolean isSelectedForApproval {get;set;}
@AuraEnabled public Boolean isRemoveEnable {get;set;}
@AuraEnabled public Integer index {get;set;}
@AuraEnabled public String msg {get;set;}
@AuraEnabled public List<String> listInvoiceDesc {get;set;}
public InvoiceLineItemWrapper (){
listInvoiceDesc = new List<String>{'','Penality Fees','FINANCIAL SERVICES'};
}
}//end InvoiceLineItemWrapper
*/
    public class ReceiptsWrapper {
        @AuraEnabled public Receipt__c receiptRec {get;set;}
        @AuraEnabled public List<RelatedInvClass> listrelatedInvoices {get;set;}
        @AuraEnabled public String msg {get;set;}
    }//end ReceiptsWrapper
    
    public class ResponseWrapper {
        @AuraEnabled public Invoice__c invoiceRec {get;set;}
        @AuraEnabled public List<Invoice_Line_Item__c> listInvoiceLineRec {get;set;}
        @AuraEnabled public String msg {get;set;}
    }
    
    public class CloneEntityWrapper {
        @AuraEnabled public Account objAcc {get;set;}
        @AuraEnabled public Address__c objAddressObject {get;set;}
    }
}