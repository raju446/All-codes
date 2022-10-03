/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class WS_FundTransferUpdatesTest {

    static testMethod void myUnitTest() {
    	Refund__c objrefund = new Refund__c();
    	objrefund.Scenario__c = 'Receipt generated but invoice not generated';
    	insert objrefund;
    	
        WS_FundTransferUpdates.ReqestDetails objwrap = new WS_FundTransferUpdates.ReqestDetails();
        objwrap.SFID = objrefund.Id;
        objwrap.Ref_Status = 's';
        objwrap.Payment_Status = 's';
        objwrap.Ref_Message = 'Refund Success';
        objwrap.AP_Invoice_No = 'A-12345';
        objwrap.Payment_Number = 'P-12345';
        
        WS_FundTransferUpdates.ProcessRequest(objwrap);
    }
    static testMethod void myUnitTest2() {
    	
    	WS_CreateEntityService.EntityInformation EntitywrapperObj = new WS_CreateEntityService.EntityInformation();
		WS_CreateEntityService.ProcessEntity(EntitywrapperObj);  
        
        EntitywrapperObj.EntityId = 'test1';
        EntitywrapperObj.EntityName = 'Test First Last';
        EntitywrapperObj.EntityNameArabic = 'test';
        EntitywrapperObj.SourceSystemName = 'RA';
        EntitywrapperObj.EntityType = 'ET';

        WS_CreateEntityService.ProcessEntity(EntitywrapperObj);
        
        EntitywrapperObj.SourceSystemName = 'RAAAA';
        WS_CreateEntityService.ProcessEntity(EntitywrapperObj);
        
        EntitywrapperObj.SourceSystemName = 'RAAAA';
        WS_CreateEntityService.ProcessEntity(EntitywrapperObj);
        
        EntitywrapperObj.Address_Line1 = 'Dubai';
        EntitywrapperObj.SourceSystemName = 'Catalyst';
        EntitywrapperObj.Recordtype_DeveloperName = 'ADGM_Registered_Company';
        EntitywrapperObj.Country = 'United Arab Emirates';
        
        WS_CreateEntityService.ProcessEntity(EntitywrapperObj);
        
        WS_CreateReceiptService.ReceiptInformation wrapperObj = new WS_CreateReceiptService.ReceiptInformation();
		WS_CreateReceiptService.ProcessReceipt(wrapperObj);  
        for(Account acc:[Select Id from Account limit 1]){
        	wrapperObj.Reference_Id = acc.Id;
        }
        wrapperObj.Receipt_Id = 'RA-1234';
        wrapperObj.Amount = '1000';
        wrapperObj.Payment_Method = 'Credit Card';
        wrapperObj.Source_System_ID = 'RA-1234';
		wrapperObj.Receipt_Date = '01/01/2020';
		wrapperObj.Description = 'Test Description';
		wrapperObj.Receipt_Currency = 'USD';
		wrapperObj.Related_Invoice_NO = '';
		wrapperObj.Amount_Applied = '1000';
		wrapperObj.File_Name = 'Test.pdf';
		wrapperObj.File_Body = 'Test PDF Body';
        WS_CreateReceiptService.ProcessReceipt(wrapperObj);
        
        string ReceiptId;
        for(Receipt__c rpt:[Select Id from Receipt__c limit 1]){
        	ReceiptId = rpt.Id;
        }
        
    	Refund__c objrefund = new Refund__c();
    	objrefund.Receipt__c = ReceiptId;
    	objrefund.Amount__c = 20000;
    	objrefund.Scenario__c = 'Receipt generated but invoice not generated';
    	insert objrefund;
    	
        WS_FundTransferUpdates.ReqestDetails objwrap = new WS_FundTransferUpdates.ReqestDetails();
        objwrap.SFID = objrefund.Id;
        objwrap.Ref_Status = 's';
        objwrap.Payment_Status = 's';
        objwrap.Ref_Message = 'Refund Success';
        objwrap.AP_Invoice_No = 'A-12345';
        objwrap.Payment_Number = 'P-12345';
        
        WS_FundTransferUpdates.ProcessRequest(objwrap);
    }
    
    static testMethod void myUnitTest3() {
    	Refund__c objrefund = new Refund__c();
    	objrefund.Scenario__c = 'Credit Memo';
    	insert objrefund;
    	
        WS_FundTransferUpdates.ReqestDetails objwrap = new WS_FundTransferUpdates.ReqestDetails();
        objwrap.SFID = objrefund.Id;
        objwrap.Ref_Status = 's';
        objwrap.Payment_Status = 's';
        objwrap.Ref_Message = 'Refund Success';
        objwrap.AP_Invoice_No = 'A-12345';
        objwrap.Payment_Number = 'P-12345';
        
        WS_FundTransferUpdates.ProcessRequest(objwrap);
    }
}