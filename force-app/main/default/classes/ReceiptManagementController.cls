/*
    Author      : Kim Noceda
    Date        : 27-Nov-2017
    Description : Page Controller to Receipt Management page
    --------------------------------------------------------------------------------------
*/
public without sharing class ReceiptManagementController{

    public Receipt__c newReceipt {get;set;}
    public String selPaymentMode {get;set;}
    public Boolean hasErrorPayment {get;set;}
    public String bankTransRefNum {get;set;}
    public Boolean hasErrorRefNum{get;set;}

    public ReceiptManagementController(ApexPages.StandardController stdControlle){
    
        newReceipt = new Receipt__c();
        newReceipt.Status__c = 'Draft';
        newReceipt.Payment_Purpose__c = 'Portal Deposit';
        newReceipt.Payment_Currency__c = 'AED';
        bankTransRefNum = '';
        
        hasErrorRefNum = false;
    }
    
    public List<SelectOption> getPaymentModes(){
        List<SelectOption> paymentMethods = new List<SelectOption>();
        paymentMethods.add(new SelectOption('','--None--'));
        paymentMethods.add(new SelectOption('Wire Transfer','Wire Transfer'));
        paymentMethods.add(new SelectOption('Credit Card','Credit Card'));
        paymentMethods.add(new SelectOption('POS','POS'));
        return paymentMethods;
    }
    
    public PageReference cancel(){
        PageReference pageRef = new PageReference('/'+Label.Receipt_Object_Prefix);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference saveReceipt(){
        hasErrorPayment = false;
        hasErrorRefNum = false;
        if(selPaymentMode == '' || selPaymentMode == null){
            hasErrorPayment = true;
        }
        if(bankTransRefNum == '' || bankTransRefNum == null){
            hasErrorRefNum = true;
        }
        if(hasErrorPayment == false && hasErrorRefNum == false){
            try{
                newReceipt.Payment_Method__c = selPaymentMode;
                newReceipt.Transaction_Reference__c = bankTransRefNum;
                insert newReceipt;
                PageReference pageRef = new PageReference('/'+newReceipt.Id);
                pageRef.setRedirect(true);
                return pageRef;
            } catch(Exception e){
                string DMLError = e.getdmlMessage(0)+'';
                if(DMLError==null){
                    DMLError = e.getMessage()+'';
                }
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,DMLError);
                ApexPages.addMessage(myMsg);
            }
        }
        return null;
    }
}