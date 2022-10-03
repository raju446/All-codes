/*
    Author      : Durga Prasad
    Company     : PwC
    Date        : 16-Nov-2017
    Description : Controller to display the PaymentInvoice in Email Template
    -------------------------------------------------------------------------
*/
public without sharing class PortalInvoiceTemplateController {
    public string SRID{get;set;}
    public decimal getTotalAmount(){
        decimal dTotalAmount = 0;
        if(SRID!=null){
            for(HexaBPM__SR_Price_Item__c SRP:[Select id,HexaBPM__Price__c,Fee__c,Tax_Amount__c,HexaBPM__Product__c,HexaBPM__Product__r.Name from HexaBPM__SR_Price_Item__c where HexaBPM__ServiceRequest__c=:SRID and HexaBPM__Price__c>0]){
                dTotalAmount = dTotalAmount+SRP.Fee__c;
                if(SRP.Tax_Amount__c!=null)
                    dTotalAmount = dTotalAmount+SRP.Tax_Amount__c;
            }
        }
        system.debug('dTotalAmount==>'+dTotalAmount);
        return dTotalAmount;
    }
    public list<SRPriceLine> getPaymentLines(){
        list<SRPriceLine> lstLines = new list<SRPriceLine>();
        if(SRID!=null){
            for(HexaBPM__SR_Price_Item__c SRP:[Select id,Fee__c,HexaBPM__Price__c,Tax_Amount__c,HexaBPM__Product__c,HexaBPM__Product__r.Name from HexaBPM__SR_Price_Item__c where HexaBPM__ServiceRequest__c=:SRID and HexaBPM__Price__c>0]){
                SRPriceLine objSRP = new SRPriceLine();
                objSRP.ItemDescription = SRP.HexaBPM__Product__r.Name;
                objSRP.Price = SRP.Fee__c;
                if(SRP.Tax_Amount__c!=null)
                    objSRP.TaxAmount = SRP.Tax_Amount__c;
                lstLines.add(objSRP);
            }
        }
        system.debug('lstLines==>'+lstLines);
        return lstLines;
    }
    public class SRPriceLine{
        public string ItemDescription{get;set;}
        public decimal Price{get;set;}
        public decimal TaxAmount{get;set;}
        public SRPriceLine(){
            ItemDescription = '';
            Price = 0;
            TaxAmount = 0;
        }
    }
}