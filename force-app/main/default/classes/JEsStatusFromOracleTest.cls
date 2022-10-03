@isTest
public class JEsStatusFromOracleTest {
    
    public static testmethod void testMethod1(){
        
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        insert acc;
        
        List<Address__c> addLst = TestClassUtility.createAddress (1, acc);
        insert addLst;
        
        DateTime dt = Datetime.now();
        String curYear = String.ValueOf(Date.Today().Year());
        GL_Period_Configuration__c gp1 = new GL_Period_Configuration__c(Active__c=true, Month__c =dt.format('MMMM'), Year__c=curYear);
        insert gp1;
        
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,acc);
        listInvoice[0].GL_Date__c = system.today();
        listInvoice[0].Invoice_Date__c = system.today();
        listInvoice[0].Payment_Term__c = 'IMMEDIATE';
        listInvoice[0].Payment_Currency__c = 'USD';
        insert listInvoice;
        listInvoice[0].Status__c='Approved' ;  
        listInvoice[0].Generate_Document__c = true;
        listInvoice[0].Document_Version__c = 0;
        update listInvoice;
        
        List<Invoice_Line_Item__c> listInvoiceLineItem = TestClassUtility.createInvoiceLineItem(1,listInvoice);
        listInvoiceLineItem[0].Revenue_Type__c = 'Corporate Services';
        listInvoiceLineItem[0].Amount__c = 100;
        listInvoiceLineItem[0].Tax_Amount__c = 5;
        insert listInvoiceLineItem;
        
        Journal_Header__c jhObj = new Journal_Header__c();
        jhObj.Name = 'JV' + '-' + '00001';
        jhObj.Transaction_Type__c = 'Sales Invoices';
        jhObj.Invoice__c = listInvoice[0].Id;
        jhObj.Reference_Id__c = listInvoice[0].Id;
        jhObj.Reference_Name__c = listInvoice[0].Name;
        jhObj.Entity_Name__c = listInvoice[0].Entity__r.Name;
        jhObj.Account__c = listInvoice[0].Entity__c;
        jhObj.GL_Date__c = listInvoice[0].GL_Date__c.date();
        
        insert jhObj;
        
        
        Journal_Entry__c je = new Journal_Entry__c(Invoice__c = String.valueOf(listInvoice[0].Id),
                                                   Account__c = 'Receivable',
                                                   GL_Date__c = listInvoice[0].GL_Date__c.date(),
                                                   Entity__c = '04',
                                                   Entity_Description__c = 'ADGM Courts OU',
                                                   Account_Segment__c = '11201',
                                                   Account_Segment_Description__c = 'Accounts Receivables',
                                                   Credit_OC__c = listInvoice[0].Total_Invoice_Amount_OC__c,
                                                   Currency__c =  listInvoice[0].Payment_Currency__c,
                                                   Conversion_Rate__c = listInvoice[0].Conversion_Rate__c,
                                                   Name = jhObj.Name + '-' + '1');
        je.journal_header__c = jhObj.Id;
        je.Operating_Unit_Name__c = listInvoice[0].Entity__r.Operating_unit__r.OU_Abbreviation__c;
        
        
        insert je;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new JEsStatusHttpCalloutMock());
        JEsStatusFromOracle.doCalloutFromFuture('0000000', '0000000',null);
        JEsStatusFromOracle.savePayload('TestEndPoint','TestReqBody', String.valueOf(jhObj.Id),'TestRespBody',String.valueOf(listInvoice[0].Id));
        //String endPoint,String reqBody, String recordId,String respBody,String relatedRecordId
        Test.stopTest();
    }
    
}