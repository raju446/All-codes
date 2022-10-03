/*
    Author      : Durga Prasad
    Company		: PwC
    Date        : 16-Nov-2017
    Description : Controller to display the sum of SR-PriceItem in Email Template
    ------------------------------------------------------------------------------
*/
public without sharing class PriceItemRollupController{
    public string SRID{get;set;}
    public string getTotalAmount(){
        string TotalAmount = '0';
        if(SRID!=null){
            decimal dTotalAmmount = 0;
            for(HexaBPM__SR_Price_Item__c SRP:[Select id,HexaBPM__Price__c from HexaBPM__SR_Price_Item__c where HexaBPM__ServiceRequest__c=:SRID and HexaBPM__Price__c>0]){
                dTotalAmmount = dTotalAmmount+SRP.HexaBPM__Price__c;
            }
            TotalAmount = dTotalAmmount+'';
        }
        return TotalAmount;
    }
}