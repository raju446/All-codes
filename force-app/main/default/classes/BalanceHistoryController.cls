/**
 * @File Name          : BalanceHistoryController.cls
 * @Description        : 
 * @Author             : Prateek.b.bansal@pwc.com 
 * @Group              : 
 * @Last Modified By   : Prateek.b.bansal@pwc.com
 * @Last Modified On   : 
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
**/
public class BalanceHistoryController {
    //function to get all operating units
    /*@AuraEnabled
    public static List<String> getOperatingUnits(){
        List<String> operatingUnitsList = new List<String>();
        Map<String, String> fieldValueAPIMap = getPicklistFieldValueAPIMap('Account', 'Oracle_Site_Id__c');
        for(AggregateResult aggrResultObj : [SELECT count(Id), Entity__r.Oracle_Site_Id__c oracleSiteId FROM Invoice__c WHERE Entity__r.Oracle_Site_Id__c != NULL GROUP BY Entity__r.Oracle_Site_Id__c]){
            if(fieldValueAPIMap.containsKey(String.valueOf(aggrResultObj.get('oracleSiteId')))){
                operatingUnitsList.add(fieldValueAPIMap.get(String.valueOf(aggrResultObj.get('oracleSiteId'))));
            }
        }
        return operatingUnitsList;
    }*/
    
    @AuraEnabled
    public static String createInvoiceReceiptRecords(Date glDate){
        List<Financial_Report__c> frLst = [SELECT Id FROM Financial_Report__c];
        if(frLst != null && frLst.size() > 0){
            //DELETE frLst;
        }
        Financial_Report__c financeReportRcrd = new Financial_Report__c(gl_Date__c = glDate);
        INSERT financeReportRcrd;
        BalanceHistoryBatch batchController = new BalanceHistoryBatch(glDate, financeReportRcrd);
        Database.executeBatch(batchController, 1);
        return 'We will let you know, once the dashboard is ready.';
    }
    
    //function to get Map of picklist field value and label
    /*public static Map<String, String> getPicklistFieldValueAPIMap(String objectName, String fieldName){
        Map<String, String> fieldValueAPIMap = new Map<String, String>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            fieldValueAPIMap.put(pickListVal.getValue(), pickListVal.getLabel());
        }   
        return fieldValueAPIMap;
    }*/
}