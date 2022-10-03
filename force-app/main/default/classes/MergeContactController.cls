/**
 * @description       : 
 * @author            : Jayanta Karmakar
 * @group             : 
 * @last modified on  : 24-05-2021
 * @last modified by  : Jayanta Karmakar
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   01-16-2021   Jayanta Karmakar   Initial Version
**/
public without sharing class MergeContactController {
    @AuraEnabled
    public static list<contact> getContactList(string conEmail, String firstNam, String lastNam) {
        List<String> excludeRecordtypes = new List<String>{'Contact - Portal User'};
        String queryString = 'Select id,Name,Email,FirstName,LastName,Phone,Account.Name,Account.Recordtype.Name,Account.Entity_Id__c,Recordtype.Name,Passport_No__c,Nationality__c From Contact WHERE Recordtype.Name NOT IN : excludeRecordtypes AND (';
        List<String> orConditions = new List<String>();
        if(conEmail != null && conEmail != ''){
            orConditions.add(' Email =: conEmail ');
        }
        if(firstNam != null && firstNam != ''){
            orConditions.add(' FirstName =: firstNam ');
        }
        if(lastNam != null && lastNam != ''){
            orConditions.add(' LastName =: lastNam ');
        }
        
        queryString += String.join(orConditions, ' OR ') + ') ORDER BY lastmodifieddate DESC';

        System.debug('queryString==>'+ queryString); 
        list<contact> contactListRecord = Database.query(queryString);
       // list<contact> contactListRecord = [Select id,Name,Email,FirstName,LastName,Phone,Account.Name,Account.Recordtype.Name,Account.Entity_Id__c,Recordtype.Name,Passport_No__c,Nationality__c 
         //                                   From Contact WHERE (Email = : conEmail OR firstname = : firstNam OR lastNam =: lastNam) AND ];
        if(contactListRecord.size() == 0){
            throw new AuraHandledException('No Record Found..'); 
        }
        return contactListRecord;
    }
    
    @AuraEnabled
    public static String mergeContacts(string masterRecord, List<String> contsToMerge) {
        String merge_Result = '';
        try{
            List<List<Contact>> contsList = new List<List<Contact>>();
            List<String> contactFields = DynamicSOQLUtility.returnFieldNames('Contact');
            Map<Id, Contact> mapOfContacts = new Map<Id, Contact>((Contact[])Database.query('Select '+String.join(contactFields, ',')+' FROM Contact WHERE Id IN : contsToMerge OR Id =: masterRecord ORDER BY lastmodifieddate DESC'));
            
            for(String eachField : contactFields){
                if(mapOfContacts.get(masterRecord).get(eachField) == null){
                    for(Id eachItem : mapOfContacts.keySet()){
                        if(eachItem != masterRecord && mapOfContacts.get(eachItem).get(eachField) != null){
                            mapOfContacts.get(masterRecord).put(eachField, mapOfContacts.get(eachItem).get(eachField));
                            break;
                        }
                    }
                }
            }
            
            //update mapOfContacts.values();
            Contact masterContact = mapOfContacts.get(masterRecord);
            update masterContact;
            mapOfContacts.remove(masterRecord);
            
            for(Contact con : mapOfContacts.values()){
                if(contsList.size() == 0){
                    contsList.add(new List<Contact>{con});
                } else if(contsList[contsList.size() - 1].size() < 2){
                    contsList[contsList.size() - 1].add(con);
                } else {
                    contsList.add(new List<Contact>{con});
                }
            }
            
            Savepoint sp = Database.setSavepoint();
            for (List<Contact> var : contsList) {
                if(var.size() > 0){
                    merge_Result = merge_Duplicates(masterContact, var);
                    if(merge_Result != '' && merge_Result != 'Success') {
                        Database.rollback(sp);
                        return merge_Result;
                    }
                }
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage()); 
        }
        return merge_Result;
    }
    
    public static String merge_Duplicates (Contact masterRecord, List<Contact> listDuplicates) {
        String sError = '';
        Database.MergeResult[] results = Database.merge(masterRecord, listDuplicates, false);
        for(Database.MergeResult res : results) {
            if(!res.isSuccess()){
                for(Database.Error err : res.getErrors()) {
                    System.debug(err.getMessage());
                    sError = sError + '-' +err.getMessage();
                }
            }
        }
        if( sError <> '' ) {
            return sError; 
        }
        return 'Success';
    }
}