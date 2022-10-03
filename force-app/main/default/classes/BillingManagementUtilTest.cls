@isTest
public class BillingManagementUtilTest
{
    public static testmethod void BillingManagementUtil_UT1()
    {
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        
        Id creditMemoRecType = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Credit Memo').getRecordTypeId();
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].RecordtypeId = creditMemoRecType;
        insert listInvoice;
        List<Invoice_Line_Item__c> listInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        insert listInvoiceLineItem;
        
        Journal_Header__c jh = new Journal_Header__c(Transaction_Type__c='Credit Memos',Invoice__c=listInvoice[0].id);
        insert jh;
        
        Test.startTest();
        
            BillingManagementUtil.CancelCreditMemo(listInvoice[0].id);
            listInvoice[0].Status__c = 'Invoiced';
            update listInvoice;
            Journal_Header__c jhe = new Journal_Header__c(Transaction_Type__c='Credit Memo Cancellation',Invoice__c=listInvoice[0].id);
            insert jhe;
            BillingManagementUtil.CancelCreditMemo(listInvoice[0].id);
            listInvoice[0].Status__c = null;
            listInvoice[0].Invoice_Balance__c = null;
            update listInvoice;
            BillingManagementUtil.CancelCreditMemo(listInvoice[0].id);
        	BillingManagementUtil.CancelCreditMemo('Testing');
        Test.stopTest();
    }
    
    public static testmethod void BillingManagementUtil_UT2()
    {
        Account[] fromAcc = TestClassUtility.createAccounts(1);
        fromAcc[0].Oracle_Party_Id__c = '123';
        fromAcc[0].Source_System_Name__c = 'FSRA';
        fromAcc[0].Name = 'FSRA';
        fromAcc[0].recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM FSRA').getRecordTypeId();
        insert fromAcc;
        
        Account[] toAcc = TestClassUtility.createAccounts(1);
        toAcc[0].Oracle_Party_Id__c = '456';
        toAcc[0].Source_System_Name__c = 'Academy';
        toAcc[0].Name = 'Academy';
        //toAcc[0].recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Academy').getRecordTypeId();
        insert toAcc;
        
        Receipt__c rec = new Receipt__c(Entity__c=fromAcc[0].id,Status__c ='Sucess',Journal_Created__c = true, Payment_Method__c ='Credit Card',Amount__c=100);
        insert rec;
        
        List<Fund_Transfer__c> listFundTransfer = TestClassUtility.createFundTransfer(1, fromAcc, toAcc);
        listFundTransfer[0].Reference_Receipt__c= rec.id;
        listFundTransfer[0].To_Receipt__c= rec.id;
        insert listFundTransfer;
        
        
        
        Test.startTest();
            BillingManagementUtil.FundTransferReversal(listFundTransfer[0].id);
            listFundTransfer[0].Status__c = 'Approved';
            //listFundTransfer[0].Pushed_To_Oracle__c= true;
            //listFundTransfer[0].Journal_Created__c= true;
            update listFundTransfer;
            
            BillingManagementUtil.FundTransferReversal(listFundTransfer[0].id);
        	listFundTransfer[0].Pushed_To_Oracle__c= true;
            listFundTransfer[0].Journal_Created__c= true;
            update listFundTransfer;
        
        	Journal_Header__c jh = new Journal_Header__c(Transaction_Type__c='Fund Transfer',Fund_Transfer__c=listFundTransfer[0].id);
            insert jh;
        	BillingManagementUtil.FundTransferReversal(listFundTransfer[0].id);
            Journal_Header__c jhe = new Journal_Header__c(Transaction_Type__c='Fund Transfer Reversal',Fund_Transfer__c=listFundTransfer[0].id);
            insert jhe;
            BillingManagementUtil.FundTransferReversal(listFundTransfer[0].id);
            rec.Is_Reversed__c = true;
            update rec;
            BillingManagementUtil.FundTransferReversal(listFundTransfer[0].id);
            rec.Amount__c = 0;
            rec.Is_Reversed__c = false;
            update rec;
            BillingManagementUtil.FundTransferReversal(listFundTransfer[0].id);
        BillingManagementUtil.FundTransferReversal('Testing FT');
        Test.stopTest();
        
    }
    
    public static testmethod void BillingManagementUtil_UT3()
    {
        Account[] fromAcc = TestClassUtility.createAccounts(1);
        fromAcc[0].Oracle_Party_Id__c = '123';
        fromAcc[0].Source_System_Name__c = 'FSRA';
        fromAcc[0].Name = 'FSRA';
        fromAcc[0].recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM FSRA').getRecordTypeId();
        insert fromAcc;
        
        Account[] toAcc = TestClassUtility.createAccounts(1);
        toAcc[0].Oracle_Party_Id__c = '456';
        toAcc[0].Source_System_Name__c = 'Academy';
        toAcc[0].Name = 'Academy';
        //toAcc[0].recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Academy').getRecordTypeId();
        insert toAcc;
        
        Receipt__c rec = new Receipt__c(Payment_Currency__c = 'USD', Entity__c=fromAcc[0].id,Status__c ='Sucess',Journal_Created__c = true, Payment_Method__c ='Credit Card',Amount__c=100);
        insert rec;
        
        List<Fund_Transfer__c> listFundTransfer = TestClassUtility.createFundTransfer(1, fromAcc, toAcc);
        listFundTransfer[0].Reference_Receipt__c= rec.id;
        listFundTransfer[0].From_Currency__c = 'USD';
        listFundTransfer[0].To_Currency__c = 'AED';
        //listFundTransfer[0].To_Receipt__c= rec.id;
        insert listFundTransfer;
        
        //UPDATE listFundTransfer;
        
        
        Test.startTest();
        	listFundTransfer[0].Status__c = 'Reversed';
        UPDATE listFundTransfer;
        	BillingManagementUtil.FundTransferReversal(listFundTransfer[0].id);
            
        
            //BillingManagementUtil.FundTransferReversal(listFundTransfer[0].id);
            listFundTransfer[0].Status__c = 'Approved';
            listFundTransfer[0].Pushed_To_Oracle__c= true;
            listFundTransfer[0].Journal_Created__c= true;
            update listFundTransfer;
            
            BillingManagementUtil.FundTransferReversal(listFundTransfer[0].id);
        	listFundTransfer[0].Pushed_To_Oracle__c= true;
            listFundTransfer[0].Journal_Created__c= true;
            update listFundTransfer;
        
        	Journal_Header__c jh = new Journal_Header__c(Transaction_Type__c='Fund Transfer',Fund_Transfer__c=listFundTransfer[0].id);
            insert jh;
        	BillingManagementUtil.FundTransferReversal(listFundTransfer[0].id);
            Journal_Header__c jhe = new Journal_Header__c(Transaction_Type__c='Fund Transfer Reversal',Fund_Transfer__c=listFundTransfer[0].id);
            insert jhe;
            BillingManagementUtil.FundTransferReversal(listFundTransfer[0].id);
            rec.Is_Reversed__c = true;
            update rec;
            BillingManagementUtil.FundTransferReversal(listFundTransfer[0].id);
            rec.Amount__c = 0;
            rec.Is_Reversed__c = false;
            update rec;
            BillingManagementUtil.FundTransferReversal(listFundTransfer[0].id);
        BillingManagementUtil.FundTransferReversal('Testing FT');
        Test.stopTest();
        
    }
    
}