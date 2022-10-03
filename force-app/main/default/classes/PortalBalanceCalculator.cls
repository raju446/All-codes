/*
    Author      : Azmath
    Date        : 18-10-2021
    Description : This class is used to calculate the portal balance.
*/
global without sharing class PortalBalanceCalculator
{
    webservice static decimal finalbalance(Id accid)
    {
        decimal finalAmount     = 0.0;
        decimal OpenRecAmount   = PortalBalanceCalculator.getOpenReceiptsAmount(accid);
        decimal OpenCMAmount    = PortalBalanceCalculator.getOpenCMAmount(accid);
        decimal openInvAmount   = PortalBalanceCalculator.getOpenInvAmount(accid);
        
        finalAmount = ((OpenRecAmount + OpenCMAmount) - openInvAmount).setscale(2);
        return finalAmount;
    }
    webservice static decimal getOpenReceiptsAmount(Id accid)
    {
        decimal OpenRecAmount = 0.0;
        AggregateResult[] OpenRecBalancecount = [SELECT SUM(Balance_Amount_AED__c)sum FROM Receipt__c where Entity__c=:accid 
                                                and Balance_Amount_AED__c!=null 
                                                and Payment_Currency__c !='USD' and (Status__c='Success' or Status__c='Approved') 
                                                and Balance_Amount_AED__c>0];
        
        if(OpenRecBalancecount != null && OpenRecBalancecount.size() > 0 && OpenRecBalancecount[0].get('sum') != null){
             OpenRecAmount = (decimal)OpenRecBalancecount[0].get('sum');
        }
        system.debug('==open receipts balance is'+OpenRecAmount);
        return OpenRecAmount;
    }
    webservice static decimal getOpenCMAmount(Id accid)
    {
        decimal OpenCMAmount = 0.0;
        AggregateResult[] OpenCMBalancecount = [SELECT SUM(Invoice_Balance__c)sum FROM Invoice__c where Entity__c=:accid 
                                                and Invoice_Balance__c!=null and Recordtype.DeveloperName='Credit_Memo' 
                                                and Payment_Currency__c !='USD' and (Status__c='Success' or Status__c='Approved' or Status__c='Invoiced')];
        if(OpenCMBalancecount != null && OpenCMBalancecount.size() > 0 && OpenCMBalancecount[0].get('sum') != null){ 
             OpenCMAmount = -(decimal)OpenCMBalancecount[0].get('sum');
        }
        system.debug('==open receipts balance is'+OpenCMAmount);
        return OpenCMAmount;
    }
    webservice static decimal getOpenInvAmount(Id accid)
    {
        decimal openInvAmount=0.0;
        /*AggregateResult[] Openinvoiceamt = [SELECT SUM(Total_Amount__c)sum from HexaBPM__SR_Price_Item__c where
                                   HexaBPM__ServiceRequest__r.HexaBPM__Customer__c=:accid and
                                   (HexaBPM__Status__c='Blocked' or HexaBPM__Status__c='Consumed') and Total_Amount__c!=null];

        if(Openinvoiceamt != null && Openinvoiceamt.size() > 0 && Openinvoiceamt[0].get('sum') != null){ 
            openInvAmount = (decimal)Openinvoiceamt[0].get('sum');
        }*/
        set<id> srids = new set<id>();
        for(HexaBPM__SR_Price_Item__c pi : [Select HexaBPM__ServiceRequest__c, Total_Amount__c from HexaBPM__SR_Price_Item__c where
                                           	HexaBPM__ServiceRequest__r.HexaBPM__Customer__c=:accid and
                                            (HexaBPM__Status__c='Blocked' or HexaBPM__Status__c='Consumed')
                                            and Total_Amount__c!=null and Total_Amount__c!=0])
        {
            srids.add(pi.HexaBPM__ServiceRequest__c);
      		openInvAmount = openInvAmount+(decimal)pi.Total_Amount__c;
        }
        system.debug('open sr price item '+openInvAmount);
        //Query partial invoiced amounts.
         AggregateResult[] OpenPartialinvoiceamt = [SELECT SUM(Invoice_Balance__c)sum from Invoice__c where Status__c='Invoiced'
                                                   	and Entity__c=:accid and Invoice_Balance__c > 0 
                                                    and Invoice_Balance__c != null 
                                                    and Payment_Currency__c != 'USD' 
                                                    and Service_Request__c NOT IN:srids];
        
        if(OpenPartialinvoiceamt != null && OpenPartialinvoiceamt.size() > 0 && OpenPartialinvoiceamt[0].get('sum') != null){
            openInvAmount = openInvAmount + (decimal)OpenPartialinvoiceamt[0].get('sum');
        }
        system.debug('open inv partial amount '+OpenPartialinvoiceamt);
        system.debug('==open inv balance is'+openInvAmount);
        return openInvAmount;
    }
}