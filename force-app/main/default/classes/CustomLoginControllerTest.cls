@isTest
public with sharing class CustomLoginControllerTest {
    
    public static testmethod void TestCustomLoginController(){
        CustomLoginController clc = new CustomLoginController();
        clc.forwardToCustomAuthPage();
        clc.login();
        clc.pageFlowId = 'Test';
    }
    
}