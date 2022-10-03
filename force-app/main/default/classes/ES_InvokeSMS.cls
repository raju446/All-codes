/*
    Author      : Durga Prasad
    Company     : PwC
    Date        : 18 Jan 2018
    ClassName   : ES_InvokeSMS
    Description : 
        - This is an Email service Class which will invokes through the WorkFlow Email Alert.
        - It Searches the "Phone Number" in the Subject and Gets that for Sending SMS.
        - The Content of the SMS is Dynamic and is Configured in Email Template, this Email Service 
          gets the plaintextbody of Email and treats that Text as SMS Content and send the SMS through API.
*/
global class ES_InvokeSMS implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
            string strEmailBody = email.plainTextBody;
            
            system.debug('strEmailBody===>'+strEmailBody);
            string strEmailSubject = email.subject;
            string phoneNumber = '';
            if(strEmailSubject!=null && strEmailSubject!='' && strEmailSubject.IndexOf('Phone=')>-1){
                list<string> lstPhone = strEmailSubject.split('Phone=');
                if(lstPhone!=null && lstPhone.size()>0 && lstPhone.size()==2){
                    phoneNumber = lstPhone[1];
                }
            }
            system.debug('phoneNumber===>'+phoneNumber);
            if(phoneNumber!=null && phoneNumber!='' && strEmailBody!=null && strEmailBody!=''){
                system.debug('Send SMS Invoking===>');
                WS_SendSMS.SendSMS(phoneNumber,strEmailBody);
            }
        return result;
    }
}