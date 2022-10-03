public class CaseController {
    @AuraEnabled
    public static CaseRecord getCaseInfo(string id) {
        CaseRecord caseRec = new CaseRecord();
        caseRec.caseObj =  [select CRM_First_Name__c, CRM_Last_Name__c, Email_Address__c,CRM_Mobile__c,CRM_Phone__c,CRM_Company__c
                 from Case where id = :id];
        caseRec.recordTypeId = CaseController.getLeadRecTypeId('Lead Entity');
        return caseRec;
    }
    @AuraEnabled
    public static Id getLeadRecTypeId(String recordTypeLabel){
        Id recid = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();        
        return recid;
    }
    public class CaseRecord{
        @AuraEnabled
        public Case caseObj {get;set;}
        @AuraEnabled
        public Id recordTypeId {get;set;}
    } 
}