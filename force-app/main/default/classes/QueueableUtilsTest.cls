@isTest
public class QueueableUtilsTest {
    public static testmethod void test1(){
                Loop__DDP__c docPackage = new Loop__DDP__c();
        docPackage.Name = 'Test NOC';
        docPackage.Type_of_Document__c = 'No Objection Certificate';
        insert docPackage;
        
        Loop__DDP_Integration_Option__c deliveryOption = new Loop__DDP_Integration_Option__c();
        deliveryOption.Name = 'Test NOC';
        deliveryOption.Loop__DDP__c = docPackage.Id;
        insert deliveryOption;
        
        List<HexaBPM__Document_Master__c> newDocMasters = TestUtility.createDocMasters(1);
        newDocMasters[0].DDP_Letter_Template__c = deliveryOption.Id;
        insert newDocMasters;
        
        
         Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        acc[0].Oracle_site_id__c = '103';
        insert acc;
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].Invoice_Balance__c = 100;
        listInvoice[0].Recordtypeid = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Credit_Memo').getRecordTypeId();
        insert listInvoice;
        
        
        QueueableUtils apc = new QueueableUtils();
        apc.recordId = listInvoice[0].Id;
        apc.DocumentMasterId = newDocMasters[0].id;
          Test.startTest();
                         System.enqueueJob(apc);
         
            
          Test.stopTest();
    }
}