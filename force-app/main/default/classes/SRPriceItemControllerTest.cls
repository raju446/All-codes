@isTest
public with sharing class SRPriceItemControllerTest {
   private static List<HexaBPM__Service_Request__c> createdSRList; 
     private static HexaBPM__SR_Price_Item__c objPriceItem;  
    public static testmethod void TestSRPriceItemController(){
      
      List<Account> newAccounts = TestClassUtility.createAccounts(1);
    insert newAccounts; 
          
    List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
    newContacts[0].Portal_User_Creation__c = true;
    
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
    insert newContacts;  
    
    createdSRList = TestUtility.createSR(1,'Initial_Approval');
      createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        insert createdSRList;
    
       objPriceItem = new HexaBPM__SR_Price_Item__c();
           objPriceItem.HexaBPM__ServiceRequest__c = createdSRList[0].Id;
           objPriceItem.Entity__c  = newAccounts[0].Id;
           //objPriceItem.HexaBPM__Product__c = objPOBoxProduct[0].Id;
           objPriceItem.HexaBPM__Price__c = 89;
           //objPriceItem.Markup_Amount__c = ;
           objPriceItem.HexaBPM__Status__c = 'Blocked';
           objPriceItem.HexaBPM__Sys_Added_through_Code__c = true;
           objPriceItem.HexaBPM__Non_Reevaluate__c = true;
          insert objPriceItem;
        
       // List<HexaBPM__SR_Price_Item__c> srPriceList = [SELECT Id, CreatedDate, HexaBPM__Status__c FROM HexaBPM__SR_Price_Item__c WHERE Id = :objPriceItem.Id];
      
    User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
    
    
    system.runAs(portalUser){
      
      system.currentPageReference().getParameters().put('id',createdSRList[0].Id);
        SRPriceItemController prc = new SRPriceItemController();
       
        
    } 
 
  }
    
    
}