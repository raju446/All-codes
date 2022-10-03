@isTest
public class SRPictureControllerTest
{
    private static testMethod void UT()
    {
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Permit_Alcohol');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        insert createdSRList;
        
        ApexPages.standardController SC = new Apexpages.standardController(createdSRList[0]);
        //ApexPages.currentpage().getParameters().put('Id',createdSRList[0].id);
        SRPictureController sp = new SRPictureController(SC);
        
        ApexPages.currentpage().getParameters().put('Id',createdSRList[0].id);
        sp.strCroppedData='base64,ksjdlfjsjfwurouwebase64,orjeworuoieworueowu';
        system.debug('========='+sp.strCroppedData.indexOf('base64,'));
        sp.SaveCroppedImage();
    
    }
    private static testMethod void SREmpPictureController()
    {
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Permit_Alcohol');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        insert createdSRList;
        
        ApexPages.currentpage().getParameters().put('Id',createdSRList[0].id);
        ApexPages.standardController SC = new Apexpages.standardController(createdSRList[0]);
        SREmpPictureController con = new SREmpPictureController(SC);
        con.removephoto();
        
    }
}