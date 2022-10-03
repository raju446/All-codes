@isTest
public class LoginVerificationControllerTest{
    public static testmethod void TestMethod1(){
        LoginVerificationController objLVC = new LoginVerificationController();
        objLVC.createAuthToken();
        for(X2FA_Authentication__c FA:[Select Id,Verification_Code__c from X2FA_Authentication__c order by createddate desc limit 1]){
            objLVC.inputValue = FA.Verification_Code__c;
        }
        objLVC.verify();
        objLVC.resend();
    }
}