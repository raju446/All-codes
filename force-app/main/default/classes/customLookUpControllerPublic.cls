/**
 * @File Name          : customLookUpControllerPublic.cls
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 3/23/2020, 2:04:11 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/15/2020   Jayanta Karmakar     Initial Version
**/


public class customLookUpControllerPublic {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord,String searchFieldName, String ObjectName, String filterCondition) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = '%'+searchKeyWord + '%';
        system.debug(searchKey);
        List < sObject > returnList = new List < sObject > ();
      	system.debug('filterCondition--->'+filterCondition);
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select id, '+searchFieldName+' from ' +ObjectName + ' where '+searchFieldName+' LIKE: searchKey ' + filterCondition + ' order by createdDate DESC limit 5';
        system.debug('sQuery--->'+sQuery);
        List < sObject > lstOfRecords = Database.query(sQuery);
        system.debug(lstOfRecords);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}