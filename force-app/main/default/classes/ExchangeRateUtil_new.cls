/**
* @File Name          : ExchangeRateUtil_new.cls
* @Description        : 
* @Author             : Anu Saxena
* @Group              : 
* @Last Modified By   : Anu Saxena
* @Last Modified On   : 10/4/2021
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    10/2/2021   Anu Saxena     Initial Version
**/
global class ExchangeRateUtil_new implements Schedulable{
    
    global void execute(SchedulableContext SC) {
        ExchangeRateUtil_new.doExchangeRateCall(); 
    }
    
    public static void doExchangeRateCall(){
        //String tDate = Date.today().DAY()+'-'+Date.today().Month()+'-'+Date.today().Year();
        doCalloutFromFuture('USD', 'AED');
    }
    
    @future (callout=true)
    public static void doCalloutFromFuture(String FromCurr, String toCurr) {
        try{
            String strtDate = Date.today().Year()+'-'+Date.today().Month()+'-'+Date.today().DAY();
            String endDate = Date.today().Year()+'-'+Date.today().Month()+'-'+Date.today().DAY();
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            system.debug('strtDate==>>' + strtDate);
            system.debug('endDate==>>' + endDate);
            request.setEndpoint('callout:Oracle_Cloud/fscmRestApi/resources/11.13.18.05/currencyRates?finder=CurrencyRatesFinder;fromCurrency='+FromCurr+',toCurrency='+toCurr+',userConversionType=Corporate,startDate='+strtDate+',endDate='+endDate+'&onlyData=True');
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            system.debug('response==>>' + response );
            
            if (response.getStatusCode() == 200) {
                System.debug('Response==='+response.getBody());
                Exchange_Rate__c erObj = new Exchange_Rate__c();
                ResponseWrapper respObj = new ResponseWrapper(); respObj = (ResponseWrapper)JSON.deserialize(response.getBody(), ResponseWrapper.class); List<Exchange_Rate__c> erObjList = new List<Exchange_Rate__c>();
                for(RateTable rt : respObj.items){List<String>  dtVals = new List<String>(); dtVals = rt.ConversionDate.split('-'); erObj.Conversion_Date__c = system.today();
                    if(rt.FromCurrency == 'AED' && rt.ToCurrency == 'USD'){erObj.AED_To_USD_Conversion_Rate__c = Decimal.valueOf(rt.ConversionRate);} else if(rt.FromCurrency == 'USD' && rt.ToCurrency == 'AED'){erObj.USD_To_AED_Conversion_Rate__c = Decimal.valueOf(rt.ConversionRate);} //erObjList.add(erObj);
                }
                request.setEndpoint('callout:Oracle_Cloud/fscmRestApi/resources/11.13.18.05/currencyRates?finder=CurrencyRatesFinder;fromCurrency='+toCurr+',toCurrency='+FromCurr+',userConversionType=Corporate,startDate='+strtDate+',endDate='+endDate+'&onlyData=True');
                request.setMethod('GET');
                response = http.send(request);
                respObj = new ResponseWrapper(); respObj = (ResponseWrapper)JSON.deserialize(response.getBody(), ResponseWrapper.class); erObjList = new List<Exchange_Rate__c>();
                for(RateTable rt : respObj.items){List<String> dtVals = new List<String>(); dtVals = rt.ConversionDate.split('-'); erObj.Conversion_Date__c = system.today();
                    if(rt.FromCurrency == 'AED' && rt.ToCurrency == 'USD'){erObj.AED_To_USD_Conversion_Rate__c = Decimal.valueOf(rt.ConversionRate);} else if(rt.FromCurrency == 'USD' && rt.ToCurrency == 'AED'){erObj.USD_To_AED_Conversion_Rate__c = Decimal.valueOf(rt.ConversionRate);} erObjList.add(erObj);
                }
                System.debug('erObjList==='+erObjList);if(erObjList.size()>0){insert erObjList;}
            }
        } catch(Exception ex){
            system.debug(ex.getMessage());
            system.debug(ex.getLineNumber());
            String sMessage = ex.getMessage();
            Log__c objLog = new Log__c();
            if(sMessage .length() > 240) {objLog.Message__c = sMessage.subString(0,240);
                                         } else {
                                             objLog.Message__c = sMessage;
                                         }
            objLog.Line_Number__c = ex.getLineNumber();
            objLog.Stack_Trace__c =  ex.getStackTraceString();
            objLog.Type_Name__c = ex.getTypeName();
            objLog.User_Email__c = UserInfo.getUserEmail();
            insert objLog;
        }
    }
    
    public class ResponseWrapper{
        public List<RateTable> items;
        public String count;
        public String hasMore;
        public String limitVal;
        public String offset;
        public List<Links> links;
    }
    
    public class RateTable{
        public string FromCurrency;
        public string ToCurrency;
        public string UserConversionType;
        public string ConversionDate;
        public string ConversionRate;
        public string ConversionType;
    }
    public class Links{
        public string rel;
        public string href;
        public string name;
        public string kind;
    }
    
}