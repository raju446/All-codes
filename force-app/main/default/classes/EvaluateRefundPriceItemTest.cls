@isTest
public with sharing class EvaluateRefundPriceItemTest {    
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    private static List<HexaBPM__Step__c> createdstepList; 
    private static User portalUser;
    public static HexaBPM__SR_Steps__c srSteps;
    public static void init(){
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
        
        HexaBPM__SR_Price_Item__c objPriceItem = new HexaBPM__SR_Price_Item__c();
        objPriceItem.HexaBPM__ServiceRequest__c = createdSRList[0].Id;
        objPriceItem.Entity__c  = newAccounts[0].Id;
        objPriceItem.HexaBPM__Sys_Added_through_Code__c = true;
        objPriceItem.HexaBPM__Non_Reevaluate__c = true;
        objPriceItem.Markup_Amount__c = 22;
        objPriceItem.Cost__c = 10;
        objPriceItem.Tax_Amount__c = 30;
        objPriceItem.Tax_Amount__c = 100;
        objPriceItem.Cancellation_Fee__c = 10;
        insert objPriceItem;
        
        HexaBPM__Status__c status = new HexaBPM__Status__c();
        status.HexaBPM__Type__c = 'Rejected';
        status.HexaBPM__Code__c = 'REQUEST_REJECTED';
        insert status;
        
        

        HexaBPM__SR_Template__c hst = new HexaBPM__SR_Template__c();
        hst.HexaBPM__Active__c = true;
        hst.Name='Employee Work Permit (UAE/GCC National) - New';
        hst.HexaBPM__SR_RecordType_API_Name__c = 'Employee_Work_Permit_UAE_GCC_National_New';
        insert hst;
        
        HexaBPM__Status__c stepStatus = new HexaBPM__Status__c(Name='Awaiting Verification',HexaBPM__Type__c='Start',HexaBPM__Code__c='AWAITING_VERIFICATION');
        insert stepStatus;
        
        HexaBPM__Step_Template__c stepTemplate = new HexaBPM__Step_Template__c(Name='Verification of Application',HexaBPM__Code__c='VERIFICATION_OF_APPLICATION',HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Summary__c='Verification of Application');
        insert stepTemplate;

        srSteps = new HexaBPM__SR_Steps__c(HexaBPM__SR_Template__c=hst.id,HexaBPM__Step_Template__c=stepTemplate.id,
        HexaBPM__Start_Status__c=stepStatus.id,HexaBPM__Active__c=true,HexaBPM__Summary__c='Verification of Application',Full_Refund__c = true,
        HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Step_Type__c='Quick Action',HexaBPM__Group_Name__c='Verification of Application');
        insert srSteps;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,srSteps.id);
        createdstepList[0].HexaBPM__Status__c = status.Id;
        insert createdstepList; 

        //Inserting Product Refund
        Product2 prod = new Product2(Name='Refund',productcode = 'REFUND');
        insert prod;

        portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
    } 
    public static testMethod void EvaluateRefundPriceItemFullRefundTest(){
        EvaluateRefundPriceItemTest.init();
        system.runAs(portalUser){
            EvaluateRefundPriceItem.CreateRefundLine(createdstepList[0]);
        } 
 
    }
    public static void PartialRefund(){
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
                    
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        insert newContacts;  
        
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        createdSRList[0].Date_of_Birth__c = Date.newInstance(2000, 12, 9);
        createdSRList[0].Person_In_UAE__c = 'Yes';
        createdSRList[0].Visa_Period__c = '1';
        insert createdSRList;
        
        HexaBPM__SR_Price_Item__c objPriceItem = new HexaBPM__SR_Price_Item__c();
        objPriceItem.HexaBPM__ServiceRequest__c = createdSRList[0].Id;
        objPriceItem.Entity__c  = newAccounts[0].Id;
        objPriceItem.HexaBPM__Sys_Added_through_Code__c = true;
        objPriceItem.HexaBPM__Non_Reevaluate__c = true;
        objPriceItem.Markup_Amount__c = 22;
        objPriceItem.Cost__c = 10;
        objPriceItem.Tax_Amount__c = 30;
        objPriceItem.Tax_Amount__c = 100;
        objPriceItem.Cancellation_Fee__c = 10;
        insert objPriceItem;
        
        HexaBPM__SR_Template__c hst = new HexaBPM__SR_Template__c();
        hst.HexaBPM__Active__c = true;
        hst.Name='Employee Work Permit (UAE/GCC National) - New';
        hst.HexaBPM__SR_RecordType_API_Name__c = 'Employee_Work_Permit_UAE_GCC_National_New';
        insert hst;
        
        HexaBPM__Status__c stepStatus = new HexaBPM__Status__c(Name='Awaiting Verification',HexaBPM__Type__c='Start',HexaBPM__Code__c='AWAITING_VERIFICATION');
        insert stepStatus;
        
        HexaBPM__Step_Template__c stepTemplate = new HexaBPM__Step_Template__c(Name='Verification of Application',HexaBPM__Code__c='VERIFICATION_OF_APPLICATION',HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Summary__c='Verification of Application');
        insert stepTemplate;

        srSteps = new HexaBPM__SR_Steps__c(HexaBPM__SR_Template__c=hst.id,HexaBPM__Step_Template__c=stepTemplate.id,
        HexaBPM__Start_Status__c=stepStatus.id,HexaBPM__Active__c=true,HexaBPM__Summary__c='Verification of Application',
        Full_Refund__c = false,Refund_Cost_Inside_UAE_Below_18__c=22,Refund_Amount_Inside_UAE_Below_18__c=55,Refund_Markup_Inside_UAE_Below_18__c=10,
        Refund_VAT_Inside_UAE_Below_18__c = 10,Refund_Amount_Inside_UAE__c=10,Refund_Cost_Inside_UAE__c=10,Refund_Markup_Inside_UAE__c=10,
        Refund_VAT_Inside_UAE__c=10,Refund_Amount_Outside_UAE__c=10,Refund_Cost_Outside_UAE__c=10,Refund_Markup_Outside_UAE__c=10,
        Refund_VAT_Outside_UAE__c=10,Refund_Cost_Outside_UAE_Below_18__c=10,Refund_Fee_Outside_UAE_Below_18__c=10,Refund_Markup_Outside_UAE_Below_18__c=10,
        Refund_VAT_Outside_UAE_Below_18__c=10,Age_Factor_18__c=false,
        HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Step_Type__c='Quick Action',HexaBPM__Group_Name__c='Verification of Application');
        insert srSteps;
        
        HexaBPM__Status__c status = new HexaBPM__Status__c();
        status.HexaBPM__Type__c = 'Rejected';
        status.HexaBPM__Code__c = 'REQUEST_REJECTED';
        insert status;

        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,srSteps.id);
        createdstepList[0].HexaBPM__Status__c = status.Id;
        insert createdstepList; 

        //Inserting Product Refund
        Product2 prod = new Product2(Name='Refund',productcode = 'REFUND');
        insert prod;

        portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
    }
    public static testMethod void EvaluateRefundPriceItemInsideUAEBelow18(){
        EvaluateRefundPriceItemTest.PartialRefund();
        system.runAs(portalUser){
            EvaluateRefundPriceItem.CreateRefundLine(createdstepList[0]);
        } 
 
    }
    public static testMethod void EvaluateRefundPriceItemOutsideUAEBelow18(){
        EvaluateRefundPriceItemTest.PartialRefund();
        createdSRList[0].Date_of_Birth__c = Date.newInstance(1970, 12, 9);
        createdSRList[0].Person_In_UAE__c = 'No';
        update createdSRList;
        system.runAs(portalUser){
            EvaluateRefundPriceItem.CreateRefundLine(createdstepList[0]);
        } 
 
    }
    
}