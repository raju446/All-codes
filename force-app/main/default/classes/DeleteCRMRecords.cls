@isTest
public class DeleteCRMRecords
{
    static testMethod void del_Account()
    {
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company').getRecordTypeId();
        Account acc = new Account(Name='DED Test',Account_Name_Arabic__c='DED Test',Entity_Id__c='00001',License_Expiry_Date__c=Date.today().addDays(360),
                            Entity_Type__c='Private Company Limited By Shares',Entity_Status__c='Registered',Registration_Date__c=Date.today(),IssueBLFZEd__c=true);
 
        insert acc;
        
        ApexPages.currentpage().getParameters().put('Id',acc.id);
        Apexpages.standardController SC = new Apexpages.standardController(acc);
        Delete_Account_Rec cntlr = new Delete_Account_Rec(sc);
        cntlr.deleteRec();
    }
    static testMethod void del_Contact()
    {
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company').getRecordTypeId();
        Account acc = new Account(Name='DED Test',Account_Name_Arabic__c='DED Test',Entity_Id__c='00001',License_Expiry_Date__c=Date.today().addDays(360),
                            Entity_Type__c='Private Company Limited By Shares',Entity_Status__c='Registered',Registration_Date__c=Date.today(),IssueBLFZEd__c=true);
 
        insert acc;
        
        Contact con = new Contact(accountid=acc.id,lastname='test');
        insert con;
        
        ApexPages.currentpage().getParameters().put('Id',con.id);
        Apexpages.standardController SC = new Apexpages.standardController(con);
        Delete_Contact_Rec cntlr = new Delete_Contact_Rec(sc);
        cntlr.deleteRec();
    }
    static testMethod void del_opp()
    {
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company').getRecordTypeId();
        Account acc = new Account(Name='DED Test',Account_Name_Arabic__c='DED Test',Entity_Id__c='00001',License_Expiry_Date__c=Date.today().addDays(360),
                            Entity_Type__c='Private Company Limited By Shares',Entity_Status__c='Registered',Registration_Date__c=Date.today(),IssueBLFZEd__c=true);
 
        insert acc;
        Id aoppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Financial').getRecordTypeId();
        
        Opportunity opp= new Opportunity(accountid=acc.id,Name='test',stageName='Pre-Applicant',Recordtypeid=aoppRecordTypeId,CloseDate=System.today());
        insert opp;
        
        ApexPages.currentpage().getParameters().put('Id',opp.id);
        Apexpages.standardController SC = new Apexpages.standardController(opp);
        Delete_OpportunityRec cntlr = new  Delete_OpportunityRec(sc);
        cntlr.deleteRec();
    }
    static testMethod void del_Lead()
    {
        
        
        Lead lead= new Lead(lastname='test',firstname='test',Lead_City__c ='AD',Lead_Country__c ='United Arab Emirates',Company='test');
        insert lead;
        
        ApexPages.currentpage().getParameters().put('Id',lead.id);
        Apexpages.standardController SC = new Apexpages.standardController(lead);
        Delete_LeadRec cntlr = new  Delete_LeadRec(sc);
        cntlr.deleteRec();
    }
}