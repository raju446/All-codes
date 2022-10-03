/*
    Author      : Durga Prasad
    Company     : PwC
    Date        : 08-Nov-2017
    Description : Webservice class to send the SMS which will be trigger from Email Service
    ---------------------------------------------------------------------------------------
*/
global without sharing class WS_SendSMS{
    @future (callout=true)
    webservice static void SendSMS(string MobileNumber,string strMessage){
        //http://messaging.etisalat.ae/bms/soap/Messenger.asmx/HTTP_SendSms?customerID=13534&userName=digital2&userPassword=phygital2017&originator=Test%202&smsText=My%20Second%20SMS%20from%20ADGM&recipientPhone=0506757517&messageType=Latin&defDate=20160120100100&blink=false&flash=false&Private=false
        
        system.debug('SRMob==>'+MobileNumber);
        system.debug('strMessage==>'+strMessage);
        
        string EndpointUrl = label.SMS_Endpoint;
        string customerID;
        string userName;
        string userPassword;
        string originator;
        string smsText = EncodingUtil.URLENCODE(strMessage,'UTF-8');
        string recipientPhone = MobileNumber;
        string messageType;
        string defDate;
        string blink;
        string flash;
        string strPrivate;
        
        for(SMS_Gateway_Config__mdt Config:[Select CustomerID__c,Blink__c,defDate__c,Flash__c,MessageType__c,Originator__c,Password__c,Private__c,Username__c from SMS_Gateway_Config__mdt limit 1]){
            customerID = Config.CustomerID__c;
            userName = Config.Username__c;
            userPassword = Config.Password__c;
            originator = EncodingUtil.URLENCODE(Config.Originator__c,'UTF-8');
            messageType = Config.MessageType__c;
            defDate = Config.defDate__c;
            blink = Config.Blink__c+'';
            flash = Config.Flash__c+'';
            strPrivate = Config.Private__c+'';
        }
        string SMSEndPoint = EndpointUrl+'customerID='+customerID+'&userName='+userName+'&userPassword='+userPassword+'&originator='+originator+'&smsText='+smsText+'&recipientPhone='+recipientPhone+'&messageType='+messageType+'&defDate='+defDate+'&blink='+blink+'&flash='+flash+'&Private='+strPrivate;
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        HttpResponse res = new HttpResponse();
        req.setTimeout(120000);//milliseconds
        req.setEndpoint(SMSEndPoint);
        req.setMethod('GET');
        try{
            if(!system.test.isRunningTest())
                res = http.send(req);
            system.debug('Response==>'+res.getBody());
        }catch(Exception e){}
    }
}