public with sharing class  Restaurantedit {
    @AuraEnabled(cacheable=true)
    public static List<restaurant__c> getOpportunities(){
        return [SELECT Id, Name, BOOKING_NAMES__c, BOOKING_DATE__c, BOOKING_NUMBER__c, SETTING_TYPE__c, SERVERS_TIP__c, BILL__c, MENU_ITEMS__c,	LOCATION__c FROM restaurant__c];
    }
}