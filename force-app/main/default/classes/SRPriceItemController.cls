/*******************************************************************************************************
 * SRPriceItem Page for the Service Request Detail Page 
 * This page is used to override the standard price item page on the Service Request Detail page , retrieves the Service Request Price Items for the corresponding SR
 * Author: Rajil 
 * Created on : 13th March 2018 
 */
 
public without sharing class SRPriceItemController{
    public list<HexaBPM__SR_Price_Item__c> lstSRPriceItem {get;set;}
    public SRPriceItemController(){
        string srID = ApexPages.currentPage().getParameters().get('id');
        User user =  [select contact.AccountId from user where id=:userinfo.getuserid()];
        if(user != null) {
            lstSRPriceItem = new list<HexaBPM__SR_Price_Item__c>();
            lstSRPriceItem = [select Name, HexaBPM__Product__r.Name, Fee__c, Tax_Amount__c, Total_Amount__c
                 from HexaBPM__SR_Price_Item__c where HexaBPM__ServiceRequest__c= :srID  and HexaBPM__ServiceRequest__r.HexaBPM__Customer__c = :user.contact.AccountId];
        }
    }
}