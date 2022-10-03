@isTest
private class ES_InvokeSMSTest{
    static testMethod void esInvokeSMStest1(){
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.htmlBody = 'test';
        email.PlainTextBody = 'test';
        email.fromAddress ='test@test.com';
        email.subject = 'Phone=+971564747474';
        
        test.startTest();
            ES_InvokeSMS  esInvokeSMS = new ES_InvokeSMS ();
            Messaging.InboundEmailResult result = esInvokeSMS.handleInboundEmail(email, env);
        test.stopTest();

    }
}