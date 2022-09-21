public with sharing class Recordedit {

    @AuraEnabled(Cacheable = true)
    public static List<restaurant__c> getAccounts() {

        List<restaurant__c> accList = [SELECT Id,Name,BOOKING_NAMES__c,BOOKING_DATE__c,BOOKING_NUMBER__c,SETTING_TYPE__c,SERVERS_TIP__c,BILL__c,MENU_ITEMS__c FROM restaurant__c ];

        return accList;
    }    
}