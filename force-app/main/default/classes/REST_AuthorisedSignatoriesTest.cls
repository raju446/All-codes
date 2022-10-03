@isTest
private class REST_AuthorisedSignatoriesTest{
    static testmethod void restAuthSignatorytest1(){
    
        REST_AuthorisedSignatories.Document doc = new REST_AuthorisedSignatories.Document();
        doc.FileBody = 'test';
        doc.ContentType = 'application/pdf';
        doc.FileName = 'doc test';
        doc.FileId = '000012421';
    
        REST_AuthorisedSignatories.AuthorisedSignatory restAuthSig = new REST_AuthorisedSignatories.AuthorisedSignatory();
        restAuthSig.RoleId = '1234';
        restAuthSig.Role = 'test';
        restAuthSig.Title = 'test';
        restAuthSig.Forenames = 'test';
        restAuthSig.Surname = 'test';
        restAuthSig.ForenamesArabic = 'test';
        restAuthSig.SurnameArabic = 'test';
        restAuthSig.CountryofResidence = 'test';
        restAuthSig.Nationality = 'test';
        restAuthSig.Status = 'test';
        restAuthSig.EvidenceOfAppointment = doc;
        restAuthSig.PassportEvidence = doc;
        restAuthSig.UAE_Visa_or_Entry_Stamp = doc;
        restAuthSig.UAE_NationalID = doc;
        restAuthSig.EntityId = '00001';
        restAuthSig.isUpdate = false;
        restAuthSig.Capacity = 'test';
        
        String JsonMsg = JSON.serialize(restAuthSig);
    
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/AuthorisedSignatories/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
            
            REST_AuthorisedSignatories.ProcessAuthorisedSignatories();
        test.stopTest();
    }
    
    static testmethod void restAuthSignatorytest2(){
    Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company').getRecordTypeId();
        List<Account> createdAccountList = TestClassUtility.createAccounts(1);
        createdAccountList[0].Oracle_Party_Id__c = '00001';
        createdAccountList[0].Entity_Id__c = '00001';
        createdAccountList[0].Is_Initial_Approval__c=true;
        createdAccountList[0].recordtypeid=accRecordTypeId ;
        createdAccountList[0].TotalAuthorisedSignatories__c=1;
        insert createdAccountList;
        
        Business_Activity__c ba = new Business_Activity__c(Activity_Code__c='1234',Entity__c=createdAccountList[0].id);
        insert ba;
        
        Role__c role = new Role__c(Subject_Account__c=createdAccountList[0].id,Status__c='Active',Type__c='Authorised Signatory');
        insert role;
        
        REST_AuthorisedSignatories.Document doc = new REST_AuthorisedSignatories.Document();
        doc.FileBody = 'test';
        doc.ContentType = 'application/pdf';
        doc.FileName = 'doc test';
        doc.FileId = '000012421';
    
        REST_AuthorisedSignatories.AuthorisedSignatory restAuthSig = new REST_AuthorisedSignatories.AuthorisedSignatory();
        restAuthSig.RoleId = '1234';
        restAuthSig.Role = 'test';
        restAuthSig.Title = 'test';
        restAuthSig.Forenames = 'test';
        restAuthSig.Surname = 'test';
        restAuthSig.ForenamesArabic = 'test';
        restAuthSig.SurnameArabic = 'test';
        restAuthSig.CountryofResidence = 'test';
        restAuthSig.Nationality = 'test';
        restAuthSig.Status = 'test';
        restAuthSig.EvidenceOfAppointment = doc;
        restAuthSig.PassportEvidence = doc;
        restAuthSig.UAE_Visa_or_Entry_Stamp = doc;
        restAuthSig.UAE_NationalID = doc;
        restAuthSig.EntityId = '00001';
        restAuthSig.isUpdate = false;
        restAuthSig.Capacity = 'test';
        
        String JsonMsg = JSON.serialize(restAuthSig);
    
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/AuthorisedSignatories/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
            
            REST_AuthorisedSignatories.ProcessAuthorisedSignatories();
        test.stopTest();
    }
}