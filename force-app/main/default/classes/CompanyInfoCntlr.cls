/*
    Author      : Rajil Ravindran
    Date        : 10-Aug-2017
    Description : Controller class to display the company(Account) information.
    --------------------------------------------------------------------------------------
*/
public with sharing class CompanyInfoCntlr {
  public Boolean isCommunity{get;set;}
    public companyInfoWrapper wrapper{get;set;}
  public CompanyInfoCntlr() {
    wrapper = new companyInfoWrapper();
    User objUser = new User();
    System.debug('****'+objUser.Contact.AccountId);
    
    Id accId; 

    for(User objUsr:[select id,ContactId,Contact.AccountId from User where Id=:userInfo.getUserId()]){
            objUser = objUsr;
            if(objUsr.ContactId!=null)
                isCommunity = true;
         }

     if(objUser.Contact.AccountId == NULL)
      {
        accId  = apexpages.currentPage().getParameters().get('Id');
      } 
      else
      {
        accId = objUser.Contact.AccountId;
      }
     lstCompanyInfoWrapper(accId);   
  }
  public void lstCompanyInfoWrapper( ID AccountId)
  { 
      Account acc = accInfo(AccountId);
      wrapper.acc = acc;
      wrapper.accContacts = accContacts(AccountId);
  }


  public List<Contact> accContacts(Id AccountId)
  {
   return ([Select FirstName,LastName,Email,MobilePhone,Name,Title,Phone,Job_Title__c from Contact Where AccountId =: AccountId]);
  }
  public Account accInfo(Id AccountId)
  {
       String accQuery = queryAllFields(sObjectType.Account.FieldSets.CompanyInfoFS.getFields(),'Account' );
     accQuery += 'WHERE ID = :AccountId LIMIT 1';
     Account acc = Database.query(accQuery);
     return  acc; 
  }

    public static string queryAllFields(List < Schema.FieldSetMember > fieldSetMembers, String objectName)
    {
        String query = ' SELECT ';
        for (Schema.FieldSetMember f: fieldSetMembers) {
            query += f.getFieldPath() + ',';
        }
        query = query.subString(0, query.length() - 1);
        query += ' FROM ' + objectName + ' ';
        return query;
    }
  public List<Schema.FieldSetMember> getFields() {
        return SObjectType.Account.FieldSets.CompanyInfoFS.getFields();
    }



  public class companyInfoWrapper
  {
    public Account acc {get;set;}
    public List<Contact> accContacts {get;set;}
    public companyInfoWrapper()
    {
       acc= new Account();
       accContacts = new List<Contact>();
    }

  }
}