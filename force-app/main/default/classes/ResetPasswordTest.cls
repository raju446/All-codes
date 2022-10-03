@isTest(seealldata=true)
public class ResetPasswordTest
{
    private static testMethod void ResetPassword()
    {
        User usr = [Select id from User where isActive=true limit 1];
        Id conid;
        conid = [Select id,contactid from User where ContactId != null and isActive=true limit 1].contactid;
        
        test.startTest();
        try{
            ResetPassword.ResetPasswordFunction(usr.id);
            
        }catch(Exception ex){}
        
        try{
            ResetPassword.ResetPasswordFunctionOnContact(conid);
        }catch(Exception ex){}
        
        try{
            ResetPassword.getUserId(conid);
        }catch(Exception ex){}
        test.stopTest();
    }
}