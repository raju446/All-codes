/*
    Author      : Durga Prasad
    Date        : 24-June-2020
    Description : Handler class for ReceiptDescriptionTrigger
    -------------------------------------------------------------------------------------
*/
public without sharing class ReceiptDescriptionTriggerHandler {
    public static void Execute_BI(list<Receipt_Description__c> TriggerNew){
        PopulateRevenueMapping(TriggerNew);
    }
    public static void Execute_BU(list<Receipt_Description__c> TriggerNew,map<Id,Receipt_Description__c> TriggerOldMap){
        PopulateRevenueMapping(TriggerNew);
    }
    public static void PopulateRevenueMapping(list<Receipt_Description__c> TriggerNew){
        map<string,string> MapRevenueByItemType = new map<string,string>();
        list<string> listDescriptions = new list<string>();
        for(Receipt_Description__c RD:TriggerNew){
            if(RD.Description__c!=null)
                listDescriptions.add(RD.Description__c);
        }
        if(listDescriptions.size()>0){
            for(Revenue_Classification__c RC:[Select Id,Line_Item_Type__c from Revenue_Classification__c where Line_Item_Type__c IN:listDescriptions and Is_Credit_Memo__c=false and Operating_Unit__r.OU_Abbreviation__c='RA']){
                MapRevenueByItemType.put(RC.Line_Item_Type__c.tolowercase(),RC.Id);
            }
        }
        for(Receipt_Description__c RD:TriggerNew){
            if(RD.Description__c!=null && MapRevenueByItemType.get(RD.Description__c.tolowercase())!=null)
                RD.Revenue_Classification__c = MapRevenueByItemType.get(RD.Description__c.tolowercase());
        }
    }
}