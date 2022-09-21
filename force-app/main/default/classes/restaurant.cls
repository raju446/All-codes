public with sharing class restaurant {

    /*Using multiple parameter in apex  controller */
    @AuraEnabled
    public static restaurant__c	 submitScoreAction(string name ,string BOOKING_NAMES, string SETTING_TYPE, string MENU_ITEMS, integer BILL){
        restaurant__c rest = new restaurant__c();{
        rest.Name=Name;
        rest.BOOKING_NAMES__c=BOOKING_NAMES;
        rest.SETTING_TYPE__c=SETTING_TYPE;
        rest.MENU_ITEMS__c=MENU_ITEMS;
        rest.BILL__c=BILL;
        system.debug('raju'+rest);
        insert rest;
        return rest;
    }
  }
}