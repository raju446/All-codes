/**
*   Author      : Azmath
*   Descritpion : Test class for ICA_ViewInternalAuthsigCntlr.
*/
@isTest
public class ICA_ViewInternalAuthsigCntlr_Test
{
    static testMethod void ICA_ViewInternalAuthsigCntlrtest()
    {
    	Account acc = ICA_TestDataFactory.CreateAccountwithRolesandAddress();
        HexaBPM__Service_Request__c sr = ICA_TestDataFactory.CreateNewEstbSR(acc.id);
    	ApexPages.standardController SC = new ApexPages.standardController(sr);
    	ICA_ViewInternalAuthsigCntlr cnt = new ICA_ViewInternalAuthsigCntlr(SC);
    }
}