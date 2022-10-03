/* *************************************************************************
AUTHOR     : AZMATH
DESCRIPTION : This class will be used to consume AGTB web services..
VERSION   : V0.1
* ************************************************************************** */
public class AGTB_CustomerOnBoarding 
{
    /*
    @Author: Azmath
    @Description: The method "EoI" will be used to call the Expression of Interest api..
    */
    public static HTTPResponse EoI(string payload)
    {
        string formBody = '';
        formBody+= MultipartHelper.encodeHeaderKey('Client_Request');
        formBody+= MultipartHelper.encodeHeaderValue(payload,null);
        formBody+= MultipartHelper.encodeFooter();
        
        Blob bodyBlob = null;
        bodyBlob = EncodingUtil.base64Decode(formBody);
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','multipart/form-data; boundary='+MultipartHelper.boundary);
        req.setMethod('POST');
        if(system.label.IsSandBox == 'TRUE')
        	req.setEndpoint('callout:Informatica_URL/AGTB_ExpressionOfInterest');
        else if(system.label.AGTB_RunonCloud == 'FALSE')
        	req.setEndpoint('callout:Informatica_URL/AGTB_ExpressionOfInterest_Prod');
        else if(system.label.AGTB_RunonCloud == 'TRUE')
        	req.setEndpoint('callout:INFORMATICA_CLOUD/AGTB_ExpressionOfInterest_Prod_C');
        req.setBodyAsBlob(bodyBlob);
        req.setTimeout(120000);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res;
    }

    /*
    @Author: Azmath
    @Description: The method "COB" will be used to call the client onbaording api..
    */
    
    /*public static void COB()
    {
       AGTB_COBJsonConstructor cob = new AGTB_COBJsonConstructor();
       string payload = JSON.serialize(cob);
       payload = payload.replaceAll('_r','');
       string formBody = '';
       formBody+= MultipartHelper.encodeHeaderKey('Client_Request');
       formBody+= MultipartHelper.encodeHeaderValue(payload,null);
       formBody+= MultipartHelper.encodeFooter();
        
       Blob bodyBlob = null;
       bodyBlob = EncodingUtil.base64Decode(formBody);
        
       HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','multipart/form-data; boundary='+MultipartHelper.boundary);
        req.setMethod('POST');
        //https://informaticauat.adgm.com:443/process-engine/public/rt/AGTB_Auth_COB_Process
      
        //cloud endpoint:
        //req.setEndpoint('https://use4-cai.dm-us.informaticacloud.com/active-bpel/public/rt/4rdvwiYUPyPhiliKyceA04/AGTB_Auth_COB_Process');//Informatica Cloud
        
        //Test agent:
        req.setEndpoint('https://informaticauat.adgm.com:443/process-engine/public/rt/AGTB_Auth_COB_Process');
        req.setBodyAsBlob(bodyBlob);
        req.setTimeout(120000);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('=====res==='+res.getBody());
    }*/
    
    /*
  @Author: Azmath
  @Description: The method "fileUpload" will be used to upload the files to AGTB system..
  */
   /* public static void fileUpload()
    {  
        Attachment att = [Select Name,Body,ContentType FROM Attachment where id='00P25000004L11q'];
        string uniqueCaseId='8c4adf1a-d8a6-4c10-90f7-c8beb5fb102d';//
    string formBody = '';
        
        formBody+= MultipartHelper.encodeFileHeaderKey('File_UI',att.Name);
        formBody+= MultipartHelper.encodeHeaderValue(null,att.body);
        
    formBody+= MultipartHelper.encodeHeaderKey('UniqueCaseId_UI');
        formBody+= MultipartHelper.encodeHeaderValue(uniqueCaseId,null);
        formBody+= MultipartHelper.encodeFooter();
        
        
        
        Blob bodyBlob = null;
        bodyBlob = EncodingUtil.base64Decode(formBody);
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','multipart/form-data; boundary='+MultipartHelper.boundary);
        req.setMethod('POST');
        req.setEndpoint('https://use4-cai.dm-us.informaticacloud.com/active-bpel/public/rt/4rdvwiYUPyPhiliKyceA04/FileUpload');
       // req.setEndpoint('https://use4-cai.dm-us.informaticacloud.com/active-bpel/public/rt/4rdvwiYUPyPhiliKyceA04/FileUpload1');
        req.setBodyAsBlob(bodyBlob);
        req.setTimeout(120000);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('=====res==='+res.getBody());
    }*/
}