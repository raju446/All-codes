public without sharing class PortalUserController{
    public list<Contact> lstPortalContacts {get;set;}
    Account acct;
    public PortalUserController(ApexPages.StandardController stdController){
        acct = (Account)stdController.getRecord();
        lstPortalContacts = new list<Contact>();
        
       /* if(acct != null) {
            lstPortalContacts = [select Id,Name, Email,Role__c, Job_Code__c, Employment_Status__c, Employment_Type__c,Types_of_Services_Accessible__c from Contact
                                    where accountId = :acct.Id and RecordType.Name = 'Contact - Portal User'];
        }*/
        
        if(acct != null) 
        {
            for(Contact con : [select Id,Name, Email,Role__c, Job_Code__c, Employment_Status__c, Employment_Type__c,Types_of_Services_Accessible__c,
                (select id from users where isActive=true) from Contact where accountId = :acct.Id and RecordType.Name = 'Contact - Portal User'])
            {
                if(con.users!= null && con.users.size() > 0)
                    lstPortalContacts.add(con);
             
            }
        }
      }
    
 }