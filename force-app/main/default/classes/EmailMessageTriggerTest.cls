@isTest
private class EmailMessageTriggerTest {
   
    static testMethod void deleteCase() {
        list<String> preventProfileNames = new List<String>();
        String preventProfilesLabel =  Label.EmailMessageValidationProfiles;
        if(String.isNotEmpty(preventProfilesLabel)){
            preventProfileNames = preventProfilesLabel.split(';');
        }
                
        Profile p = [SELECT Id FROM Profile WHERE Name =: preventProfileNames[0]]; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserEmailMessageTriggerTest@testorg.com');
    	//Insert test case record
        Case caseRec = new Case();
        caseRec.Subject = 'Case Test';  
        caseRec.Status ='New';
        caseRec.Priority = 'Medium';
        caseRec.Origin = 'Email';
        insert caseRec;
        
        
        System.runAs(u) {
            //Insert emailmessage for case
            EmailMessage email = new EmailMessage();
            email.FromAddress = 'standarduser@testorg.com';
            email.Incoming = True;
            email.ToAddress= 'test@xyz.org';
            email.Subject = 'Test email';
            email.HtmlBody = 'Test email body';
            email.ParentId = caseRec.Id; 
            insert email;
            Test.startTest();
            try{
            	delete email;
            }catch(Exception e){}
            Test.stopTest();
        }
    }
    
    static testMethod void insertCase() {
        list<String> preventProfileNames = new List<String>();
        String preventProfilesLabel =  Label.EmailMessageValidationProfiles;
        if(String.isNotEmpty(preventProfilesLabel)){
            preventProfileNames = preventProfilesLabel.split(';');
        }
                
        Profile p = [SELECT Id FROM Profile WHERE Name =: preventProfileNames[0]]; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserEmailMessageTriggerTest@testorg.com');
    	//Insert test case record
        Case caseRec = new Case();
        caseRec.Subject = 'Case Test';  
        caseRec.Status ='New';
        caseRec.Priority = 'Medium';
        caseRec.Origin = 'Email';
        insert caseRec;
        System.runAs(u) {
            Test.startTest();
            EmailMessage email = new EmailMessage();
            email.FromAddress = 'test@abc.org';
            email.Incoming = True;
            email.ToAddress= 'test@xyz.org';
            email.Subject = 'Test email';
            email.HtmlBody = 'Test email body';
            email.ParentId = caseRec.Id;
            try{
            	insert email;
            }catch(Exception e){}
            Test.stopTest();
        }
    }
}