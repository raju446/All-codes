public with sharing class createrecord {
    
    @AuraEnabled
    public static student2__c insertAccountMethod(student2__c accountObj){
        try {
            insert accountObj;
            return accountObj;
        } catch (Exception exp) {
            throw new AuraHandledException(exp.getMessage());
        }
    }
}