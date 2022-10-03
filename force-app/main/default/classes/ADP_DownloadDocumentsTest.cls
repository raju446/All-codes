/*
*Author : Azmath
Description : Test class for ADP_DownloadDocuments class.
*/
@isTest
public class ADP_DownloadDocumentsTest
{
    private static testMethod void ADP_DownloadDocumentsUT()
    {
        list<HexaBPM__Service_Request__c> srlist = ADPTestDataFactory.createcustomerandSR('Temporary_Fit_Out_Security_Clearance',1);
        system.assertEquals(srlist.isEmpty(),false);
        SRDocTriggerHandlerTest.createMasterData();
        HexaBPM__SR_Doc__c srdoc = ADPTestDataFactory.createSRDoc(srlist[0].id,'Test');
        system.debug('====srodc==='+srdoc.id);
        Attachment att = ADPTestDataFactory.createAttachment(srdoc.id);
        ADP_DownloadDocuments.RequestWrap dd = new ADP_DownloadDocuments.RequestWrap();
        dd.Document_ID = srdoc.id;
        String JsonMsg = JSON.serialize(dd);
        test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/GetDocuments/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        
        ADP_DownloadDocuments.documents respDetails = new ADP_DownloadDocuments.documents();
        respDetails = ADP_DownloadDocuments.getdocuments();
        test.stopTest();
     }
     private static testMethod void ADP_DownloadDocumentsUT1()
     {
        ADP_DownloadDocuments.RequestWrap dd = new ADP_DownloadDocuments.RequestWrap();
        String JsonMsg = JSON.serialize(dd);
        system.assertEquals(string.isEmpty(JsonMsg),false);
        test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/GetDocuments/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        
        ADP_DownloadDocuments.documents respDetails = new ADP_DownloadDocuments.documents();
        respDetails = ADP_DownloadDocuments.getdocuments();
        test.stopTest();
     
     }
}