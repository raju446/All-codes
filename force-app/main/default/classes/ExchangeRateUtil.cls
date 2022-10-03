/**
 * @File Name          : ExchangeRateUtil.cls
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 7/1/2020, 3:18:01 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/19/2020   Jayanta Karmakar     Initial Version
**/
global class ExchangeRateUtil implements Schedulable{
    public static void doExchangeRateCall(){
        String tDate = Date.today().DAY()+'-'+Date.today().Month()+'-'+Date.today().Year();
        doCalloutFromFuture(tDate);
    }
    
    @future (callout=true)
    public static void doCalloutFromFuture(String todayDate) {
        try{
            system.debug(todayDate);
            String jsonString = '{"P_IN_DATE": "'+todayDate+'"}';
            System.debug('request-->'+ jsonString);
            HTTPResponse response = new HTTPResponse(); 
            List<ERP_Endpoint_Details__mdt> listERPEndpointDetails = new List<ERP_Endpoint_Details__mdt>();
            listERPEndpointDetails = [SELECT ID,Endpoint_URL__c, Password__c, Username__c,HTTP_Method__c  FROM ERP_Endpoint_Details__mdt WHERE Is_Active__c = true AND DeveloperName =: 'Exchange_Rate' LIMIT 1];
            if(listERPEndpointDetails.size() > 0){
                //response = HTTPRestUtil.callWebservice('https://informaticauat.adgm.com:443/process-engine/public/rt/ExchangeRateProcess', 'POST',jsonString);
                response = HTTPRestUtil.callWebservice(listERPEndpointDetails[0].Endpoint_URL__c,listERPEndpointDetails[0].HTTP_Method__c,jsonString);
                system.debug('Response body ---->'+response.getBody());
                ResponseWrapper respObj = new ResponseWrapper();
                respObj = (ResponseWrapper)JSON.deserialize(response.getBody(), ResponseWrapper.class);
                Exchange_Rate__c erObj = new Exchange_Rate__c(Oracle_Callout_Status__c = respObj.P_OP_STS, Oracle_Response_Message__c = respObj.P_OP_MSG);
                if(respObj.P_OP_STS == 'S'){
                    for(RateTable rt : respObj.P_OP_RATES){
                        List<String> dtVals = new List<String>();
                        dtVals = rt.X4_CONV_DATE.split('-');
                        erObj.Conversion_Date__c = date.newinstance(Integer.valueOf(dtVals[2]), Integer.valueOf(dtVals[1]), Integer.valueOf(dtVals[0]));
                        if(rt.X2_FROM_CURRENCY == 'AED' && rt.X3_TO_CURRENCY == 'USD'){
                            erObj.AED_To_USD_Conversion_Rate__c = Decimal.valueOf(rt.X6_CONVERSION_RATE);
                        } else if(rt.X2_FROM_CURRENCY == 'USD' && rt.X3_TO_CURRENCY == 'AED'){
                            erObj.USD_To_AED_Conversion_Rate__c = Decimal.valueOf(rt.X6_CONVERSION_RATE);
                        }
                    }
                }
                
                insert erObj;
            }
        } catch(Exception ex){
            system.debug(ex.getMessage());
            system.debug(ex.getLineNumber());
            String sMessage = ex.getMessage();
            Log__c objLog = new Log__c();
            if(sMessage .length() > 240) {
                objLog.Message__c = sMessage.subString(0,240);
            } else {
                objLog.Message__c = sMessage;
            }//end if
            
            objLog.Line_Number__c = ex.getLineNumber();
            objLog.Stack_Trace__c =  ex.getStackTraceString();
            objLog.Type_Name__c = ex.getTypeName();
            objLog.User_Email__c = UserInfo.getUserEmail();
            insert objLog;
        }
    }
    
    public class ResponseWrapper{
        public string P_OP_STS;
        public string P_OP_MSG;
        public List<RateTable> P_OP_RATES;
    }
    
    public class RateTable{
        public string X6_CONVERSION_RATE;
        public string X2_FROM_CURRENCY;
        public string X5_CONV_TYPE;
        public string X4_CONV_DATE;
        public string X3_TO_CURRENCY;
    }
    
    global void execute(SchedulableContext SC) {
        ExchangeRateUtil.doExchangeRateCall(); 
    }
}