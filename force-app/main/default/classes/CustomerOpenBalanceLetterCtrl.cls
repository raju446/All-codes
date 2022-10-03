/**
 * @description       : 
 * @author            : Jayanta Karmakar
 * @group             : 
 * @last modified on  : 11-18-2020
 * @last modified by  : Jayanta Karmakar
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   11-18-2020   Jayanta Karmakar   Initial Version
**/
public without sharing class CustomerOpenBalanceLetterCtrl {
    public Account entityDetail {get;set;}
    public List<Invoice__c> openInvoices {get;set;}
    public List<Receipt__c> unappliedReceipts {get;set;}
    public decimal openInvoiceBalance {get;set;}
    public decimal unappliedReceiptsAmnt {get;set;}
    public decimal remainingAmnt {get;set;}
    public String addLine {get;set;}
    public String entCountry {get;set;}
    public boolean showInv {get;set;}
    public boolean showRcpt {get;set;}
    public CustomerOpenBalanceLetterCtrl(){
        openInvoiceBalance = 0;
        unappliedReceiptsAmnt = 0;
        remainingAmnt = 0;
        Id accId = apexpages.currentpage().getparameters().get('id');
        entityDetail = [select id,name,(select Building_Name__c, Country__c, Floor__c, Emirates__c, County__c, Office_Number__c, State__c, Street_Name_of_Cluster_on_the_Island__c,Country_ALPHA_3__c from Addresses__r where Type__c = 'Physical') from Account where id =: accId];
        if(entityDetail.Addresses__r.size() > 0){
            addLine = entityDetail.Addresses__r[0].Street_Name_of_Cluster_on_the_Island__c;
            entCountry = entityDetail.Addresses__r[0].Country__c;
        }
        openInvoices = [select id,name,Inv_Balance_OC__c,Total_Invoice_Amount_OC__c,Invoice_Balance__c,Oracle_Invoice_Type__c,Payment_Currency__c,Invoice_Date__c,Total_Amount_with_Discount_n_Tax__c,Balance_Amount_AED__c,Source_Invoice_Id__c,entity__r.operating_unit__r.OU_Abbreviation__c,Due_date__c from Invoice__c
                        where Entity__c =: accId AND Inv_Balance_OC__c != 0 and (Status__c = 'Success' OR Status__c  = 'Approved' OR Status__c = 'Invoiced')];
        for(Invoice__c inv : openInvoices){
            openInvoiceBalance += inv.Inv_Balance_OC__c;//inv.Balance_Amount_AED__c;
        }
        system.debug(openInvoices.size());
        unappliedReceipts = [select id,name,Balance_Amount_AED__c,Amount__c,Receipt_Date__c,Payment_Currency__c,Source_Receipt_Id__c,Receipt_Reference__c,Receipt_Balance__c,entity__r.operating_unit__r.OU_Abbreviation__c,transaction_reference__c from Receipt__c where Entity__c =: accId and Receipt_Balance__c > 0 and Status__c != 'Cancelled'];
        for(Receipt__c receipt : unappliedReceipts){
            unappliedReceiptsAmnt += receipt.Receipt_Balance__c;//receipt.Balance_Amount_AED__c;
        }
        
        if(openInvoices.size() > 0){
            showInv = true;
        } else {
            showInv = false;
        }
        
        if(unappliedReceipts.size() > 0){
            showRcpt = true;
        } else {
            showRcpt = false;
        }
        
        remainingAmnt = openInvoiceBalance - unappliedReceiptsAmnt;
    }
}