Global class unsubscribe implements Messaging.inboundEmailHandler{
 
Global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, 
							Messaging.InboundEnvelope env ) {

 
Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
 
 List<Contact> lc = new List <contact>();
List<Lead> ll = new List <lead>();
 
 String mySubject = email.subject.toLowerCase();
 String s = 'unsubscribe';
 
 Boolean unsubMe;
 
unsubMe = mySubject.contains(s);
 
 if (unsubMe == true) {
 	
 	try {
 	 
	 for (Contact c : [Select Id, Name, Email, HasOptedOutOfEmail
						From Contact
						Where Email = :env.fromAddress
						And hasOptedOutOfEmail = false
						Limit 100]) {
						
 							c.hasOptedOutOfEmail = true;
							lc.add(c);					               
	}	 
 		
  		update lc;
 			}
 	catch (System.QueryException e) {
		System.debug('Contact Query Issue: ' + e);
		} 	

 	try {
 	 for (Lead l : [Select Id, Name, Email, HasOptedOutOfEmail
						From Lead
						Where Email = :env.fromAddress
						And isConverted = false
						And hasOptedOutOfEmail = false
						Limit 100]) {
 		l.hasOptedOutOfEmail = true;
		ll.add(l);
					           
           System.debug('Lead Object: ' + l);   
	}	 
 		update ll;
 			}

 	catch (System.QueryException e) {
		System.debug('Lead Query Issue: ' + e);
		} 	

	System.debug('Found the unsubscribe word in the subject line.');
 } 
 else {
 	System.debug('No Unsuscribe word found in the subject line.' );
 }
 
result.success = true;
return result;
	}	
	 
static testMethod void testUnsubscribe() {

    Messaging.InboundEmail email = new Messaging.InboundEmail() ;
   Messaging.InboundEnvelope env 	= new Messaging.InboundEnvelope();

    Lead l = new lead(firstName='Rasmus', 
   			lastName='Mencke',
   			Company='Salesforce', 
   			Email='rmencke@salesforce.com', 
   			HasOptedOutOfEmail=false);
   insert l;

    Contact c = new Contact(firstName='Rasmus', 
   				lastName='Mencke', 
   				Email='rmencke@salesforce.com', 
   				HasOptedOutOfEmail=false);
   insert c;
   
    email.subject = 'test unsubscribe test';
   env.fromAddress = 'rmencke@salesforce.com';
   
    unsubscribe unsubscribeObj = new unsubscribe();
   unsubscribeObj.handleInboundEmail(email, env );
						
   }
 
static testMethod void testUnsubscribe2() {

    Messaging.InboundEmail email = new Messaging.InboundEmail();
   Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

    Lead l = new lead(firstName='Rasmus', 
   			lastName='Mencke',
   			Company='Salesforce', 
   			Email='rmencke@salesforce.com', 
   			HasOptedOutOfEmail=false);
   insert l;

    Contact c = new Contact(firstName='Rasmus', 
   				lastName='Mencke', 
   				Email='rmencke@salesforce.com', 
   				HasOptedOutOfEmail=false);
   insert c;
   
    email.subject = 'test';
   env.fromAddress = 'rmencke@salesforce.com';

    unsubscribe unsubscribeObj = new unsubscribe();
   unsubscribeObj.handleInboundEmail(email, env );						
   }    
   
}