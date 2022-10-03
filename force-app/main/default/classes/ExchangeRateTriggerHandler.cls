public class ExchangeRateTriggerHandler {
    public static void Execute_AI(map<Id,Exchange_Rate__c> TriggerNewMap){
        List<Exchange_Rate__c> listExchangeRate = new List<Exchange_Rate__c>();
        listExchangeRate = [select id from Exchange_Rate__c where id IN: TriggerNewMap.keySet() order by CreatedDate desc];
        List<Operating_Unit__c> listOperating_Unit = new List<Operating_Unit__c>();
        listOperating_Unit = [select id, Exchange_Rate__c from Operating_Unit__c limit 100];
        if(listOperating_Unit <> null && listOperating_Unit.size() > 0 && listExchangeRate <> null && listExchangeRate.size() > 0) {
            for(Operating_Unit__c objOperating_Unit : listOperating_Unit ){
                objOperating_Unit.Exchange_Rate__c = listExchangeRate[0].id;
            }
            
            update listOperating_Unit;
        }
    }
}