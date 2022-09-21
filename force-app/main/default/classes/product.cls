public with sharing class product {
    @AuraEnabled(cacheable=true)
    public static List<oppo_product__c> getproductList() {
        return [SELECT Id,Name,Opportunity__c,Description__c,price__c,Quantity__c
            FROM oppo_product__c];
    }
}