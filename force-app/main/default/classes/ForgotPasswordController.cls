/**
 * An apex page controller that exposes the site forgot password functionality
 */
public with sharing class ForgotPasswordController {
    public String username {get; set;}   
       
    public ForgotPasswordController() {}
	
  	public PageReference forgotPassword() {
		if(string.isNotBlank(username)){
			string customUsername = username + Label.Login_Name_Prefix;
			boolean success = Site.forgotPassword(customUsername);
			PageReference pr = Page.ForgotPasswordConfirm;
			pr.setRedirect(true);
			
			if (success) {  			
				return pr;
			}
		}
		else{
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter the username.');
            ApexPages.addMessage(myMsg);
		}
			
  		return null;
  	}
}