global without sharing class ResetPassword 
{
    //To reset password from User detail page..
     webservice static void ResetPasswordFunction(Id UserId)
    {
        System.resetPassword(UserId,true);
        system.debug('Password reset successfully..');
        
    }
    
    //To reset password from Contact page..
    webservice static void ResetPasswordFunctionOnContact(Id contactId)
    {
        Id UserId = [Select id from User where Contactid=:contactId].id;
        System.resetPassword(UserId,true);
        system.debug('Password reset successfully..');
    }
    
    //Pass User Id ..
    webservice static string getUserId(Id contactId)
    {
        Id UserId = [Select id from User where Contactid=:contactId].id;
        return UserId;
    }
}