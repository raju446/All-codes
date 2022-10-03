public without sharing class PaymentReceiptController{

    public Map<String,String> formDataMap {get;set;}
    public Set<String> keyMap {get;set;}
    public Receipt__c receipt{get;set;}
    public PaymentReceiptController(){
        System.debug('@@PARAM: '+ApexPages.CurrentPage().getParameters());
        formDataMap = new Map<String, String>();
        formDataMap = ApexPages.CurrentPage().getParameters();
        receipt = new Receipt__c();
        keyMap = formDataMap.keyset();
        for(string st : formDataMap.keyset()){
            system.debug('====='+st+':'+formDataMap.get(st));
        }
    }
    
    public pageReference checkParameters(){
        System.debug('##PARAM: '+ApexPages.CurrentPage().getParameters());
        string accountId;
        for(User usr:[Select Id, ContactId, Contact.AccountId FROM User WHERE Id =:Userinfo.getUserId() and ContactId!=null]){
            accountId = usr.Contact.AccountId;
        }
        receipt = new Receipt__c();
        receipt.Amount__c = Decimal.valueOf(formDataMap.get('req_amount'));
        if(accountId!=null)
            receipt.Entity__c = accountId;
        receipt.Message__c = formDataMap.get('message');
        receipt.Payment_Currency__c = formDataMap.get('req_currency');
        //receipt.Payment_Method__c = formDataMap.get('req_payment_method');
        receipt.Payment_Method__c = 'Credit Card';
        receipt.Payment_Purpose__c = 'Portal Deposit';
        receipt.Receipt_Date__c = system.now();
        receipt.Generate_Receipt__c = true; //12272017 -- Added to auto generate receipt on creation
        receipt.Authorization_Code__c = formDataMap.get('auth_code');
        receipt.Credit_Card_F_L_Four_Digits__c = formDataMap.get('req_card_number');
        receipt.Card_Transaction_Id__c = formDataMap.get('transaction_id');
        if(formDataMap.get('auth_time') != ''){
            //receipt.Receipt_Date__c = DateTime.valueOf(formDataMap.get('auth_time'));
        }
        if(formDataMap.get('reason_code') == '100' || formDataMap.get('reason_code') == '110'){
            receipt.Status__c = 'Success';
        }else{
            receipt.Status__c = 'Error';
            receipt.Invalid_Fields__c = formDataMap.get('invalid_fields');
            receipt.Decision__c = formDataMap.get('decision');
        }
        receipt.Transaction_Reference__c = formDataMap.get('req_reference_number');
        System.debug('##DATA3: '+formDataMap.get('req_merchant_defined_data3'));
        //receipt.Service_Request__c = formDataMap.get('merchant_defined_data3');
        if(formDataMap.get('req_merchant_defined_data3') != null){
            receipt.Service_Request__c = formDataMap.get('req_merchant_defined_data3');
        }
        try{
            upsert receipt;
        }catch(Exception e){
            system.debug('Exception==>'+e.getMessage());
        }
        String returnURLParam = formDataMap.get('req_merchant_defined_data4');
        String stepId = formDataMap.get('req_merchant_defined_data5');
        
        String returnUrl = '';
        if(receipt.Service_Request__c != null){
            system.debug('##PAYMENT: '+returnURLParam);
            if(returnURLParam == 'payment' || returnURLParam == 'Payment'){
                returnUrl = '/apex/PaymentStep?id='+receipt.Service_Request__c+'&StepId='+stepId;
            } else{
                returnUrl = '/apex/SubmitRequest?id='+receipt.Service_Request__c;
            }
        } else{
            returnUrl = '/'+receipt.Id;
        }
        
        PageReference pageRef = new PageReference(returnUrl);
        pageRef.setRedirect(true);
        return pageRef;
    }
}