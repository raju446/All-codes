/**
 * @File Name          : reUsableMultiSelectLookupCtrl.cls
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 3/15/2020, 10:48:12 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/15/2020   Jayanta Karmakar     Initial Version
**/
public class reUsableMultiSelectLookupCtrl {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, List<sObject> ExcludeitemsList,String filterCriteria, String queryFieldValues) {
        String searchKey = '%' + searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();
 
        List<string> lstExcludeitems = new List<string>();
        for(sObject item : ExcludeitemsList ){
            lstExcludeitems.add(item.id);
        }
        
        if(queryFieldValues == null || queryFieldValues == '') {
            queryFieldValues = 'id, Name';
        }
         system.debug('filterCriteria------>'+filterCriteria);
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 and exclude already selected records  
        String sQuery =  'select '+ queryFieldValues+' from ' +ObjectName + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems '+filterCriteria+' order by createdDate DESC limit 5';
        system.debug('sQuery----->'+sQuery);
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}