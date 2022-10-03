/*
    Author      : Durga Kandula
    Date        : 06-June-2020
    Description : Trigger Handler for RA_Invoice_Line_Item__c Object
*/
public without sharing class RA_InvoiceLineItemTriggerHandler {
    public static void Execute_BI(list<RA_Invoice_Line_Item__c> TriggerNew){
        
    }
    public static void Execute_AI(list<RA_Invoice_Line_Item__c> TriggerNew){
        list<Invoice_Line_Item__c> lstInvLI = new list<Invoice_Line_Item__c>();
        for(RA_Invoice_Line_Item__c RA_ILI:TriggerNew){
            if(RA_ILI.Invoice_Id__c!=null){
                Invoice_Line_Item__c lineObj = new Invoice_Line_Item__c();
                lineObj.Amount__c = RA_ILI.Fee_Amount_in_USD__c;
                lineObj.Tax_Amount__c = 0;
                lineObj.Item_Reference__c = RA_ILI.Receipt_Number__c;
                lineObj.Discount_Amount__c = null;
                lineObj.Taxable_Discount_Amount__c = null;
                lineObj.Quantity__c = 1;
                lineObj.Status__c = 'Consumed';
                lineObj.Type__c = 'Line';
                lineObj.Invoice__c = RA_ILI.Invoice_Id__c;
                lineObj.Source_Invoice_Line_Id__c = RA_ILI.Receipt_Number__c;
                lineObj.Line_Description__c = RA_ILI.General_Ledger_Entry_Description__c;
                //lineObj.Tax__c = '0%';
                lineObj.Tax__c = Label.CATALYST_Tax_Code;
                lineObj.RA_Receipt_Invoice__c = RA_ILI.RA_Receipt_Invoice__c;
                lineObj.RA_Invoice_Line_Item__c = RA_ILI.Id;
                
                //Revenue Classification Details
                lineObj.Service_Type__c = RA_ILI.RC_Service_Type__c;
                lineObj.Revenue_Type__c = RA_ILI.RC_Revenue_Class__c;
                lineObj.Service_Class__c = RA_ILI.RC_Service_Class__c;
                //lineObj.Item_Description__c = RA_ILI.RC_Item_Description__c;
                lineObj.Item_Description__c = RA_ILI.Fee_Description__c;
                lineObj.Schools__c = RA_ILI.RC_Schools__c;
                lineObj.Course_Type__c = RA_ILI.RC_Course_Type__c;
                lineObj.Department__c = RA_ILI.RC_Department__c;
                
                lstInvLI.add(lineObj);
            }
        }
        try{
            if(lstInvLI.size()>0)
                insert lstInvLI;
        }catch(Exception e){
            string sMessage = e.getMessage()+'';
            Log__c objLog = new Log__c(Line_Number__c = e.getLineNumber(),Additional_Information__c = sMessage,Stack_Trace__c =  e.getStackTraceString(),Type_Name__c = e.getTypeName());
            if(sMessage .length() > 240) 
                objLog.Message__c = sMessage.subString(0,240);
            else 
                objLog.Message__c = sMessage;
            insert objLog;
        }
    }
    public static void Execute_BU(list<RA_Invoice_Line_Item__c> TriggerNew,map<Id,RA_Invoice_Line_Item__c>TriggerOldMap){
        
    }
    public static void Execute_AU(list<RA_Invoice_Line_Item__c> TriggerNew,map<Id,RA_Invoice_Line_Item__c>TriggerOldMap){
        
    }
}