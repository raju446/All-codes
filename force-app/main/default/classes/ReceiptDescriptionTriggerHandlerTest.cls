@isTest
public class ReceiptDescriptionTriggerHandlerTest{
    public static testmethod void doTest(){
        
        
        Operating_Unit__c ou = new Operating_Unit__c(Invoice_Type__c = 'Test');
        ou.OU_Abbreviation__c = 'RA';
        insert ou;
       
        Revenue_Classification__c rc = new Revenue_Classification__c(Service_Type__c = 'Test',Line_Item_Type__c='test',Operating_Unit__c = ou.Id,Type__c='Invoice',Invoice_Type__c='RA Invoice',Source_System_Name__c='Catalyst',Oracle_Site_Id__c='104');
        insert rc;
        
        Receipt_Description__c RD = new Receipt_Description__c();
        RD.Description__c = 'test';
        insert RD;
        
        RD.External_Entity_Name__c = 'Test';
        update RD;
    }
}