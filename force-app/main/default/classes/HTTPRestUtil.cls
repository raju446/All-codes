/**
 * @File Name          : HTTPRestUtil.cls
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 6/22/2020, 10:33:17 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/22/2020   Jayanta Karmakar     Initial Version
**/
public class HTTPRestUtil {
    public static HTTPResponse callWebservice(String sEndPointURL, String sMethod, String sBody){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(sEndPointURL);
        req.setMethod(sMethod);
        req.setTimeout(120000);
        req.setHeader('content-type','application/json');
        if(sMethod == 'POST'){
            req.setBody(sBody);
        }
        Http http = new Http();
        HTTPResponse objRespWrap = http.send(req);
        return objRespWrap;
    }
    
}