public without sharing class LoginVerificationController {
    public X2FA_Authentication__c authToken;
    public string userId;
    public String inputValue {get; set;}
    public Boolean isError {get; set;}
    public string AuthTokenId;
    public LoginVerificationController() { 
        isError = false;
        authToken = new X2FA_Authentication__c();
        userId = UserInfo.getUserId();
        authToken.OwnerId = userId;
        authToken.User_Id__c = userId;     
        authToken.User__c = userId;  
    }
    public PageReference verify(){
        isError = false;
        if(inputValue==null || String.isBlank(inputValue)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a valid authentication code.'));
            return null;
        }
        system.debug('AuthTokenId==>'+AuthTokenId);
        datetime CurrentTime = System.NOW();
        boolean CodeMatched = false;
        for(X2FA_Authentication__c  Auth : [select Id,OwnerId,Verification_Code__c from X2FA_Authentication__c where User_Id__c=:userId and Valid_Until__c>=:CurrentTime order by Valid_Until__c Desc Limit 1]){
            system.debug('Auth Token==>'+Auth.Verification_Code__c);
            if(inputValue.equals(Auth.Verification_Code__c))
                CodeMatched = true;
        }
        
        if(CodeMatched){
            return Auth.SessionManagement.finishLoginFlow();
        }else{
            isError=true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You have entered an incorrect authentication code. Please try again, or click the button to send a new code.'));
        }
        /*
        if(AuthTokenId!=null)
            authToken = [Select Id,OwnerId,Verification_Code__c from X2FA_Authentication__c where Id=:AuthTokenId];
        
        if(authToken.Verification_Code__c!=null && !String.isBlank(authToken.Verification_Code__c)){
            system.debug('inputValue==>'+inputValue);
            system.debug('Verification_Code__c==>'+authToken.Verification_Code__c);
            if(inputValue.equals(authToken.Verification_Code__c)){
                return Auth.SessionManagement.finishLoginFlow();
            }else{                
                isError=true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You have entered an incorrect authentication code. Please try again, or click the button to send a new code.'));
                return null;
            }
        }
        */
        return null;
    }
    public PageReference resend(){
        authToken = new X2FA_Authentication__c();
        userId = UserInfo.getUserId();
        authToken.OwnerId = userId;
        authToken.User_Id__c = userId;
        authToken.User__c = userId;
        AuthTokenId = null;
        try{
            for(User usr:[Select Id,Email,UserName,MobilePhone from User where Id=:userId]){
                authToken.User_Email__c = usr.Email;
                authToken.User_Name__c = usr.UserName;
                authToken.User_Mobile__c = usr.MobilePhone;
            }
            insert authToken;
            AuthTokenId = authToken.Id;
        }catch(Exception e){
            System.debug('@@Error in creating authToken: '+e.getMessage());
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'You have been sent a new authentication code to your email. If you are still having trouble logging in, contact your administrator.'));
        return null;
    }
    public void createAuthToken(){
        try{
            for(User usr:[Select Id,Email,UserName,MobilePhone from User where Id=:userId]){
                authToken.User_Email__c = usr.Email;
                authToken.User_Name__c = usr.UserName;
                authToken.User_Mobile__c = usr.MobilePhone;
            }
            insert authToken;
            AuthTokenId = authToken.Id;
        }catch(Exception e){
            System.debug('@@Error in creating authToken: '+e.getMessage());
        }
    }
}