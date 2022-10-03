/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class CustomLoginController {
    global String username{get;set;}
    global String password{get;set;}
    public string pageFlowId {get;set;}
    global CustomLoginController () {
        
    }
    global PageReference forwardToCustomAuthPage() {
        return new PageReference( '/customlogin');
    }
    global PageReference login() {
        string Customusername = username + Label.Login_Name_Prefix;
        return Site.login(Customusername, password, null);
    }

}