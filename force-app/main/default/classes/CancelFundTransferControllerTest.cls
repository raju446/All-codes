@isTest
public class CancelFundTransferControllerTest {
    
    public static testmethod void test1(){
        Account[] fromAcc = TestClassUtility.createAccounts(1);
        fromAcc[0].Oracle_Party_Id__c = '123';
        fromAcc[0].Source_System_Name__c = 'FSRA';
        fromAcc[0].Name = 'FSRA';
        Insert fromAcc;
        
        Account[] toAcc = TestClassUtility.createAccounts(1);
        toAcc[0].Oracle_Party_Id__c = '456';
        toAcc[0].Source_System_Name__c = 'Academy';
        toAcc[0].Name = 'Academy';
        Insert toAcc;
        List<Fund_Transfer__c> listFundTransfer = TestClassUtility.createFundTransfer(1, fromAcc, toAcc);
        listFundTransfer[0].Status__c = 'Draft';
        Insert listFundTransfer;
        CancelFundTransferController.cancelFundTransfer(listFundTransfer[0].Id);
        listFundTransfer[0].Status__c = 'Approved';
        Update listFundTransfer;
        CancelFundTransferController.cancelFundTransfer(listFundTransfer[0].Id);
    }
}