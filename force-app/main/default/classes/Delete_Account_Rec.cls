/* 
Author : Azmath
Description : This class will be used to delete the account records and capture the audit..

*/ 
public without sharing class Delete_Account_Rec
{
    public string recordid {get;set;}
    public Delete_Account_Rec(ApexPages.standardController SC)
    {
        recordid= Apexpages.currentPage().getParameters().get('Id');
        
        
    }
     public pageReference deleteRec()
     {
         Account acc;
         pagereference pg = new PageReference('/lightning/o/Account/list?filterName=Recent');
         pg.setRedirect(true);
         string crmentityid = '';
         list<Account> lst = [Select id,Name,CRM_Entity_Id__c,OwnerId, Owner.Name, Recordtype.Name from Account where id=:recordid];
         if(!lst.isEmpty()){
             acc = lst[0];
             delete lst; 
             
             list<Authsession> a = [SELECT Id, SourceIp,LoginType,SessionType,UserType FROM AuthSession WHERE UsersId = :UserInfo.getUserId() 
                            ORDER BY CreatedDate DESC limit 1];
             CRM_Audit__c ca = new CRM_Audit__c();
             ca.Deleted_By__c = UserInfo.getUserId();
             ca.Deleted_Object__c = 'Account';
             ca.Deleted_Record_ID__c = acc.id;
             ca.Entity_ID__c = acc.CRM_Entity_Id__c;
             ca.Record_Name__c = acc.Name;
             ca.Record_Owner__c = acc.Owner.Name;
             ca.Deleted_Record_Owner_Id__c = acc.OwnerId;
             ca.Record_Type__c  = acc.RecordType.Name;
             insert ca;
             return pg;
               
         }
         return null;
     }
}