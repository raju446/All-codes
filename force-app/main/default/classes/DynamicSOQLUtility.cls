/*
    Author      :   Yogesh Mahajan 
    Class Name  :   DynamicSOQLUtility
    Description :   Dyanmic SQOL String Creation
    Date        :   02/03/2019       
*/
public class DynamicSOQLUtility {
    /*
    Name : createSelect
    Parameters : List<String> - List fields to query
    String - Object API Name
    Returns Type : String - Dyanmic SOQL query String
    Description : Used to form the dyanmic SOQL 
    */
    public String createSelect(List<String> listFieldAPINames, String objectAPIName) {
        if(listFieldAPINames <> null && listFieldAPINames.size() > 0) {
            String soqlQuery = 'SELECT ';
            Integer index = 0;
            // iterate the fields
            for (String fieldAPIName : listFieldAPINames) {
                if(index == 0) {
                    soqlQuery += fieldAPIName.toLowerCase();
                    index++;
                } else {
                    soqlQuery += ', ' + fieldAPIName.toLowerCase();
                }//end else - if
                
            }//end for
            return soqlQuery +' FROM '+ objectAPIName;
        }//end if
        
        return null;
    }//end createSelect()
    
    
    /*
    Name : addWhereCondition
    Parameters : String - SOQL query string 
    String - Field API Name
    String - compare Value
    String - sOperater (= / Like / IN / NOT IN etc)
    Returns Type : String - Dyanmic SOQL query String
    Description : Used to form the dyanmic SOQL where clause
    */
    public String addWhereCondition(String soqlQuery, String fieldAPIName, String compareValue, String sOperater) {
        if(compareValue <> 'null') {
            soqlQuery += ' ' +'WHERE' + ' ' + fieldAPIName + ' ' + sOperater + '\'' + compareValue + '\'';
        } else {
            soqlQuery += ' ' +'WHERE' + ' ' + fieldAPIName + ' ' + sOperater + 'null';
        }
        
        return soqlQuery;
    }//end addWhereCondition()
    
    /*
    Name : addWhereCondition
    Parameters : String - SOQL query string 
    String - Field API Name multiplicklist
    String - compare Value 
    String - sOperater (= / Like / IN / NOT IN etc)
    Returns Type : String - Dyanmic SOQL query String
    Description : Used to form the dyanmic SOQL where clause
    */
    public String addWhereCondition(String soqlQuery, String fieldAPIName, List<String> compareValue, String sOperater) {

        soqlQuery += ' ' +'WHERE' + ' ' + fieldAPIName + ' ' + sOperater + '\'' + compareValue + '\'';

        
        return soqlQuery;
    }//end addWhereCondition()
    
    /*
    Name : addWhereCondition
    Parameters : String - SOQL query string 
    String - Field API Name
    String - compare Value
    String - sOperater (= / Like / IN / NOT IN etc)
    String - Condtion (AND / OR)
    Returns Type : String - Dyanmic SOQL query String
    Description : Used to form the dyanmic SOQL where clause
    */
    public String addWhereCondition(String soqlQuery, String fieldAPIName, String compareValue, String sOperater, String sANDORCondition) {
        soqlQuery += ' ' + sANDORCondition + ' ' + fieldAPIName + ' ' + sOperater + '\'' + compareValue + '\'';
        return soqlQuery;
    }//end addWhereCondition()
    
    /*
    Name : addWhereCondition
    Parameters : String - SOQL query string 
    String - Field API Name
    Boolean - compare Value
    String - sOperater (= / Like / IN / NOT IN etc)
    String - Condtion (AND / OR)
    Returns Type : String - Dyanmic SOQL query String
    Description : Used to form the dyanmic SOQL where clause
    */
    public String addWhereCondition(String soqlQuery, String fieldAPIName, Boolean compareValue, String sOperater, String sANDORCondition) {
        soqlQuery += ' ' + sANDORCondition + ' ' + fieldAPIName + ' ' + sOperater + '' + compareValue + '';
        return soqlQuery;
    }//end addWhereCondition()
    
    /*
    Name : addWhereCondition
    Parameters : String - SOQL query string 
    String - Field API Name
    List<String> - compare Values
    String - sOperater (= / Like / IN / NOT IN etc)
    String - Condtion (AND / OR)
    Returns Type : String - Dyanmic SOQL query String
    Description : Used to form the dyanmic SOQL where clause
    */
    public String addWhereCondition(String soqlQuery, String fieldAPIName, List<String> listOfCompareValue, String sOperater, String sANDORCondition) {
        soqlQuery += ' ' + sANDORCondition + ' ' + fieldAPIName + ' ' + sOperater + ':'+listOfCompareValue[0];
        return soqlQuery;
    }//end addWhereCondition()
    
    
    
    /*
    Name : addOrderByCondition
    Parameters : String - SOQL query string 
    String - Field API Name
    String - Order By (ASC / DESC)
    Returns Type : String - Dyanmic SOQL query String
    Description : Used to form the dyanmic SOQL Order By clause
    Note : Make this uncomment if you want to use in your class
    ***********************************************************************************/
    public String addOrderByCondition(String soqlQuery, String fieldAPIName, String orderBy) {
        soqlQuery += ' ORDER BY ' + fieldAPIName + ' ' + orderBy;
        return soqlQuery;
    }//end addOrderByCondition()
    
    /*
    Name : addLimitCondition
    Parameters : String - SOQL query string 
    Integer - no of record
    Returns Type : String - Dyanmic SOQL query String
    Description : Used to form the dyanmic SOQL Limit clause
    */
    public String addLimitCondition(String soqlQuery, Integer noOfRecord) {
        soqlQuery += ' LIMIT' + ' ' + noOfRecord;
        return soqlQuery;
    }//end addOrderByCondition()
    
    /*
    Name : addWhereMultiCondition
    Parameters : String - SOQL query string 
    String - Field API Name
    String - compare Value
    String - sOperater (INCLUDES)
	String - Condtion (AND / OR)
    Returns Type : String - Dyanmic SOQL query String
    Description : Used to form the dyanmic SOQL where clause
    */
    public String addWhereMultiCondition(String soqlQuery, String fieldAPIName, Set<String> setCompareValue, String sOperater, String sANDORCondition ) {
         soqlQuery += ' ' + sANDORCondition + ' ' + fieldAPIName + ' ' + sOperater + '('; 
        for(String compareValue: setCompareValue) {
            soqlQuery +=  '\'' + compareValue + '\',';
        }//end for
        soqlQuery = soqlQuery.removeEnd(',');
        soqlQuery += ')';    
        
        return soqlQuery;
    }//end addWhereMultiCondition()
    
    public static List<String> returnFieldNames(String objApiName){
        List<String> fieldLst = new List<String>();
        Set<String> lstOfFieldsToExclude = new Set<String>{'iscustomerportal'};
        Map<String, Schema.SObjectField> amap = Schema.getGlobalDescribe().get(objApiName).getDescribe().fields.getMap();
        try {
            for(String fieldName : amap.keySet()){
                system.debug('=====>'+fieldName);
                if(amap.get(fieldName).getDescribe().isUpdateable() && !lstOfFieldsToExclude.contains(fieldName)) {
                    fieldLst.add(fieldName);
                    system.debug(' in if condition=====>'+fieldName);
                }
            }
            //fieldLst.addAll(Schema.getGlobalDescribe().get(objApiName).getDescribe().fields.getMap().keyset());
        } catch (Exception ex) {
            system.debug(ex.getMessage());
        }
        return fieldLst;
    }
}