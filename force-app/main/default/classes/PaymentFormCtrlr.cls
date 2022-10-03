/*
    Author      : Kim Noceda
    Date        : 25-Sep-2017
    Description : Page Controller to perform payment transaction to payment gateway.
    --------------------------------------------------------------------------------------
*/
public class PaymentFormCtrlr {
    
    public String signature {get;set;}
    
    public String accesskey {get;set;}
    public String profileId {get;set;}
    public String transactionUid {get;set;}
    public String signedfieldNames {get;set;}
    public String unSignedfieldNames {get;set;}
    public String signedDateTime {get;set;}
    public String locale {get;set;}
    
    public String transactiontype {get;set;}
    public String referencenumber {get;set;}
    public String amt {get;set;}
    public String amtCurrency {get;set;}
    public string submitval{get;set;}
    
    public String billToForeName {get;set;}
    public String billToLastName {get;set;}
    public String billToStreet {get;set;}
    public String billToCity {get;set;}
    public String billToCountry {get;set;}
    public String billToEmail {get;set;}
    public String billToCompanyName {get;set;}
    
    public string customReceiptURL{get;set;}
    public string customCancelURL{get;set;}
    
    public string paymentPurpose{get;set;}
    public string strDateTime{get;set;}
    public string objSrId{get;set;}
    public string returnPage{get;set;}
    public string stepId{get;set;}
    public boolean isValidPaymentForm {get;set;}
    
    private static String kHexChars = '0123456789abcdefABCDEF';
    
    public PaymentFormCtrlr(){
        String amountURL = apexpages.currentpage().getparameters().get('amount');
        isValidPaymentForm = false;
        if(string.isNotEmpty(amountURL)){
            try{
                decimal iAmount = decimal.valueOf(amountURL);
                if(iAmount < 0){
                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter a valid number.');
                    ApexPages.addMessage(errMsg);
                }
                else if(iAmount > 200000){
                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'The maximum allowed amount is 200,000.');
                    ApexPages.addMessage(errMsg);
                }
                else
                    isValidPaymentForm = true;
            }
            catch(Exception ex){
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
                ApexPages.addMessage(errMsg);
            }
        }
        submitval = 'Submit';
        objSrId = '';
        //accesskey = 'a4cb4e5b37b9348e8d7549fbaeb3d4e4';
        accesskey = CyberSource__c.getValues('testcenter').Accesskey__c;
        //profileId = 'E6B4E208-8453-43BC-9907-7CAA5D7ADBE6';
        profileId = CyberSource__c.getValues('testcenter').ProfileId__c;
        transactionUid = getUUid();
        //transactionUid = '1be09989-a2ff-4baa-a926-2765f91996d8';
        System.debug('##UID: '+transactionUid);
        
        String srIdURL = apexpages.currentpage().getparameters().get('srId');
        System.debug('@@SRURL: '+srIdURL);
        if(srIdURL != null){
           objSrId = srIdURL; 
        }
        System.debug('@@OBJSRRURL: '+objSrId);
        
        String topupReturnURL = apexpages.currentpage().getparameters().get('topUpReturnUrl');
        returnPage = '';
        if(topupReturnURL != null){
            returnPage = topupReturnURL;
        }
        
        
        String stepIdStr = apexpages.currentpage().getparameters().get('stepId');
        stepId = '';
        if(stepIdStr != null){
            stepId = stepIdStr;
        }
        
        System.debug('@@RETURN: '+returnPage );
        System.debug('@@STEP: '+stepId );
        
        List<User> currentUser = [SELECT Id, Contact.Account.Name, FirstName, LastName, Email, City, Street FROM User WHERE Id = :Userinfo.getUserId() LIMIT 1];
        billToForeName = currentUser[0].FirstName;
        billToLastName = currentUser[0].LastName;
        billToEmail = currentUser[0].Email;
        billToStreet = currentUser[0].Street;
        billToCity = currentUser[0].City;
        billToCountry = 'AE';
        billToCompanyName = currentUser[0].Contact.Account.Name;
        signedfieldNames = 'access_key,profile_id,transaction_uuid,signed_field_names,unsigned_field_names,signed_date_time,locale,transaction_type,reference_number,amount,currency,override_custom_receipt_page,override_custom_cancel_page,merchant_defined_data1,merchant_defined_data2,merchant_defined_data3,merchant_defined_data4,merchant_defined_data5';
        unSignedfieldNames='bill_to_forename,bill_to_surname,bill_to_email,bill_to_address_line1,bill_to_address_city,bill_to_company_name,bill_to_address_country';
        //signedDateTime = '2017-10-02T09:24:02Z';
        //signedDateTime = getUTCDateTime(System.now().addhours(-4)).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        //signedDateTime = System.now().addhours(-4).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        signedDateTime = System.now().addhours(-4).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        locale = 'en';
    
        transactiontype = 'sale';
        //referencenumber = '0050Y000002DgrQQAS';
        referencenumber = getReferenceNumber(signedDateTime);
        
        amt = amountURL;
        if(amountURL == ''){
            amt = '100.00';
        }
        amtCurrency = 'AED';
        //amtCurrency = 'USD';
                
        //customReceiptURL = 'https://adgmdev-adgmdev.cs81.force.com/adgm/paymentreceipt';
        //customCancelURL = 'https://adgmdev-adgmdev.cs81.force.com/adgm/apex/home';
        customReceiptURL = Site.getBaseUrl()+'/paymentreceipt';
        customCancelURL = Site.getBaseUrl()+'/apex/home';
        
        paymentPurpose = '';
        strDateTime = System.now().addhours(-4).format();
        
        Map<string,string> oPassedParams = new Map<String,String>();
        oPassedParams.put('access_key',accesskey);
        oPassedParams.put('profile_id',profileId);
        oPassedParams.put('transaction_uuid',transactionUid); 
        oPassedParams.put('signed_field_names',signedfieldNames);
        oPassedParams.put('unsigned_field_names',unSignedfieldNames); 
        oPassedParams.put('signed_date_time',signedDateTime);
        oPassedParams.put('locale',locale);
        oPassedParams.put('transaction_type',transactiontype);
        oPassedParams.put('reference_number',referencenumber);
        oPassedParams.put('amount',amt);
        oPassedParams.put('currency',amtCurrency);
        oPassedParams.put('override_custom_receipt_page',customReceiptURL);
        oPassedParams.put('override_custom_cancel_page',customCancelURL);
        oPassedParams.put('merchant_defined_data1',paymentPurpose);
        oPassedParams.put('merchant_defined_data2',strDateTime);
        oPassedParams.put('merchant_defined_data3',objSrId);
        oPassedParams.put('merchant_defined_data4',returnPage);
        oPassedParams.put('merchant_defined_data5',stepId);
        oPassedParams.put('submit','Submit');
        //String data = Cybersource_Controller.buildDataToSign(oPassedParams);
        String data = buildDataToSign(oPassedParams);
        //String secretKey = 'df1e36e8fdb7470295004e4c2d4a344a5c64b1bfb94248b0aa9b3517eb0d3e1045ce7d9dc1654bb2a4828dc9a5a83bf06551ed3c12ab40d6bc23c9e55bdeb18609321e1f729640b1ba60db7af1d4dc84516435ed4b284e929b6b038f150a22ab0159ec38f36b41258f8e9cd89974547a70b079988c9443a79f8e61f371a4197e';
        String secretKey = Label.ClientSecret;
        system.debug('data====>'+data);
        //String signatureStr = Cybersource_Controller.sign(data,secretKey);
        String signatureStr = sign(data,secretKey);
        signature = signatureStr;
        System.debug('##SIGNATURE: '+signatureStr);
    }
    public String getUUid(){
        Blob b = Crypto.GenerateAESKey(128); 
        String h = EncodingUtil.ConvertTohex(b); 
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return guid;
    }
    
    public String getReferenceNumber(String currentDateTime){
        String refNumber = '';
        refNumber = Userinfo.getUserId() + '_' + currentDateTime;
        return refNumber;
    }
    
    public String buildDataToSign(Map<string,string> paramsArray) {
        System.debug('@@PARAMS: '+paramsArray);
        String[] signedFieldNames = paramsArray.get('signed_field_names').Split(',');
        List<string> dataToSign = new List<string>();
        string strResult = '';
        integer i=0;
        for(String oSignedFieldName : signedFieldNames){
            if(i==0)
                strResult = oSignedFieldName+'='+paramsArray.get(oSignedFieldName);
            else
                strResult = strResult+','+oSignedFieldName+'='+paramsArray.get(oSignedFieldName);
            i++;
        }
        return strResult;
    }
    
    public String sign(String data, String secretKey) {
        String result = EncodingUtil.base64Encode(Crypto.generateMac('hmacSHA256', Blob.valueOf(data), Blob.valueOf(secretKey)));
        return result;
    }
}