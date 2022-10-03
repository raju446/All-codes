/**
 * @File Name          : WS_CreateInvoiceServiceTest.cls
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 6/24/2020, 1:58:26 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    6/24/2020   Jayanta Karmakar     Initial Version
**/
@isTest
public class WS_CreateInvoiceServiceTest {
    public static testmethod void createInvoiceTest(){
        List<Account> acc = TestClassUtility.createAccounts(1);
        insert acc;
        WS_CreateInvoiceService.InputParameters_Class inputWrap = new WS_CreateInvoiceService.InputParameters_Class();
        inputWrap.INV_CURRENCY = 'USD';
        inputWrap.INV_DATE = '2021/2/22';//Date.today();
        inputWrap.INV_DESC = 'Test class';
        inputWrap.INV_TYPE = 'ARC Invoice';
        inputWrap.PAYMENT_TERM = '21 Net';
        inputWrap.REFERENCE_ID = acc[0].id;
        inputWrap.SOURCE_INVOICE_ID = 'SI-000001';
        inputWrap.SOURCESYSTEM = 'FSRA';
        
        WS_CreateInvoiceService.Invoice_Lines_Wrapper lineWrapper = new WS_CreateInvoiceService.Invoice_Lines_Wrapper();
        lineWrapper.DEPARTMENT = 'Default';
        lineWrapper.INV_DISCOUNT_AMT = 0.0;
        lineWrapper.INV_DISCOUNT_TAX_AMT = 0.0;
        lineWrapper.ITEM_DESC = 'Test Desc';
        lineWrapper.ITEM_REF = 'ref001';
        lineWrapper.LINE_ITEM_TYPE = 'test item type';
        lineWrapper.PROGRAM_CODE = 'Default'; 
        lineWrapper.PROJECT_SEGMENT = 'Default';
        lineWrapper.QUANTITY = 1;
        lineWrapper.REVENUE_TYPE = 'Test';
        lineWrapper.SERVICE_TYPE = 'Test';
        lineWrapper.SOURCE_INVOICE_LINE_ID = '001';
        lineWrapper.TAX_AMOUNT = 0;
        lineWrapper.TAX_CODE = '0%';
        
        WS_CreateInvoiceService.ProcessInvoice(inputWrap);
        inputWrap.Invoice_Lines = new List<WS_CreateInvoiceService.Invoice_Lines_Wrapper>();
        inputWrap.Invoice_Lines.add(lineWrapper);
        Test.startTest();
            WS_CreateInvoiceService.ProcessInvoice(inputWrap);
        Test.stopTest();
    } 
}