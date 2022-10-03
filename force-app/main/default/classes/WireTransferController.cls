/*
    Author      : Kim Noceda
    Date        : 27-Nov-2017
    Description : Page Controller to Wire Transfer page
    --------------------------------------------------------------------------------------
    Modification History
    Version         Author               Purpose
    v1.1            Rajil              Added the file format validation 
    --------------------------------------------------------------------------------------
*/
public without sharing class WireTransferController{

    public Receipt__c newReceipt {get;set;}
    public String bankTransRefNum {get;set;}
    public String amountStr {get;set;}
    public String receiptDescription {get;set;}
    
    public Boolean hasErrorAmt {get;set;}
    public Boolean hasErrorAmtValue {get;set;}
    public Boolean hasErrorRefNum{get;set;}
    public Boolean hasErrorAttachment{get;set;}
    
    public Attachment fileUploadAtt {get;set;}
    public decimal maxAmountValue {get;set;}
    public string strSelectedFileType {get;set;}
    public string hasFileError {get;set;}
    
    public String errorMessageStr {get;set;}
    public integer iFileSize {get;set;}
    public string selectedContenttype  {get;set;}

    public WireTransferController(){
    
        Id contactId = [SELECT Id, ContactId FROM User WHERE Id = :Userinfo.getUserId()].ContactId;
        Id accountId = [SELECT Id, AccountId FROM Contact WHERE Id = :contactId].AccountId;
        
        amountStr = apexpages.currentpage().getparameters().get('amount');
    
        newReceipt = new Receipt__c();
        newReceipt.Payment_Purpose__c = 'Portal Deposit';
        newReceipt.Payment_Method__c = 'Wire Transfer';
        newReceipt.Entity__c = accountId; 
        newReceipt.Payment_Currency__c = 'AED';
        bankTransRefNum = '';
        receiptDescription = '';
        hasErrorRefNum = false;
        hasErrorAmt = false;
        hasErrorAmtValue = false;
        hasErrorAttachment = false;
        fileUploadAtt = new Attachment();
        
        if(Label.Wire_Transfer_Max_Amount != '' && Label.Wire_Transfer_Max_Amount != null){
            maxAmountValue = decimal.valueOf(Label.Wire_Transfer_Max_Amount);
        } else{
            maxAmountValue = 200000;
        }
        
        errorMessageStr = '';
    }
    
    public PageReference cancel(){
        PageReference pageRef = new PageReference('/apex/home');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference saveReceipt(){
        hasErrorAmt = false;
        hasErrorAmtValue = false;
        hasErrorRefNum = false;
        hasErrorAttachment = false;
        errorMessageStr = '';
        
        if(amountStr == '' || amountStr == null){
            hasErrorAmt = true;
            fileUploadAtt = new Attachment();
        }
        if(bankTransRefNum == '' || bankTransRefNum == null){
            hasErrorRefNum = true;
            fileUploadAtt = new Attachment();
        }
        if(fileUploadAtt.name == '' || fileUploadAtt.name == null){
            hasErrorAttachment = true;
        }
        //Checks File validation for the format types -- v1.1
        boolean validFile = false;
        if(fileUploadAtt != null && string.isNotEmpty(fileUploadAtt.name)){
            //string selectedContenttype = fileUploadAtt.contenttype;
            if(string.isNotEmpty(selectedContenttype)){
                System.debug('selectedContenttype'+selectedContenttype);
                String[] validContentTypes =new String[]{'jpg', 'jpeg', 'bmp', 'png', 'pdf'};
                for(string strContentType : validContentTypes ){
                    if(selectedContenttype.indexOf(strContentType) > -1){ 
                        validFile = true;
                        break;
                    }
                }
            }
            if(validFile == false){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a valid file format');
                ApexPages.addMessage(myMsg);
                fileUploadAtt = new Attachment(); 
                return null;
            }
            // 1MB validation
            else if(validFile == true){
                if(iFileSize > 1048576) { 
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please upload a file with a maximum of 1MB size');
                    ApexPages.addMessage(myMsg);
                    fileUploadAtt = new Attachment(); 
                    return null;
                }
            }
        }
        
        if(hasErrorAmt == false && hasErrorRefNum == false && hasErrorAttachment == false){
            decimal amount;
            if(amountStr == ''){
                amount = 0.00;
            } else{
                amount = decimal.valueOf(amountStr);
            }
            if(amount <= 0){
                hasErrorAmtValue = true;
                errorMessageStr = 'Please enter a valid amount.';
                fileUploadAtt = new Attachment(); 
                return null;
            } else if(amount > maxAmountValue){
                hasErrorAmtValue = true;
                errorMessageStr = 'The maximum allowed amount is 200,000.';
                fileUploadAtt = new Attachment(); 
                return null;
            } else{
                newReceipt.Amount__c = amount;
                newReceipt.Description__c = receiptDescription;
                newReceipt.Transaction_Reference__c = bankTransRefNum;
                newReceipt.Status__c = 'Under Review';
                newReceipt.Generate_Receipt__c = true;
                List<Group> finnceTeamQueue = [SELECT Id FROM Group WHERE DeveloperName = 'Finance_Team' AND Type = 'Queue' LIMIT 1];
               // newReceipt.OwnerId = finnceTeamQueue[0].Id;
                
                try{
                    insert newReceipt;
                    if(fileUploadAtt.Body != null){
                        fileUploadAtt.ParentId = newReceipt.Id;
                        insert fileUploadAtt;
                    }
                    PageReference pageRef = new PageReference('/'+newReceipt.Id);
                    pageRef.setRedirect(true);
                    return pageRef;
                }catch(DMLException e){
                    string DMLError = e.getdmlMessage(0)+'';
                    if(DMLError==null){
                        DMLError = e.getMessage()+'';
                    }
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,DMLError);
                    ApexPages.addMessage(myMsg);
                }
            }
        }
        return null;
    }
}