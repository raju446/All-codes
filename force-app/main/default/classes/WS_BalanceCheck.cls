/*
    Author      : Durga Prasad
    Date        : 17-Feb-2017
    Description : Webservice class to get the latest balance of customer from oracle
    --------------------------------------------------------------------------------------
	* Yogesh Mahajan	09Feb2020		Added new webservice call
*/
public without sharing class WS_BalanceCheck {
    public static decimal GetOracleBalance(string PartyId){
        decimal OracleBalance;
        if(System.Label.BM_Use_New_BalanceCheckWS == 'Yes'){
            List<Account> accs = [select id from account where oracle_party_id__c =: PartyId and oracle_site_id__c = '104' LIMIT 1];
            if(accs.size() == 1)
            OracleBalance = GetOracleBalance_New(accs[0].id);
        } else {
            //string OracleLogins = 'UserName:Password';
            string OracleLogins;
            for(Oracle_API_Info__mdt OLG:[Select Id,Username__c,Password__c from Oracle_API_Info__mdt limit 1]){
                OracleLogins = OLG.Username__c+':'+OLG.Password__c;
            }
            string EncodedLogins = EncodingUtil.base64Encode(blob.valueof(OracleLogins));
            string EndPointUrl = label.OracleBalalnceCheckEndPoint;
            string PostData = '{"Create_OSS":{"InputParameters": {"P_ORA_PARTY_ID ": "'+PartyId+'"}}}';
            JSONParser parser;
            string responseString;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(EndPointUrl);
            req.setMethod('POST');
            req.setTimeout(6000);
            system.debug('postData===>'+postData);
            req.setHeader('Authorization', 'Basic ' + EncodedLogins);
            req.setHeader('content-type','application/json');
            req.setBody(postData);
            Http http = new Http();
            
            if(!Test.isRunningTest()){
                try{
                    HTTPResponse res = http.send(req);
                    responseString = string.valueOf(res.getBody());
                    parser = JSON.createParser(res.getBody());
                }catch(Exception e){
                    system.debug('Exception===>'+e.getMessage());
                }
            }else{
                responseString = '{"OutputParameters" : { "@xmlns" : "http://xmlns.oracle.com/apps/xxadgm/rest/Create_ACCESSADGM_Balance_Check/get_oss_cust_balance/","@xmlns:xsi" : "http://www.w3.org/2001/XMLSchema-instance","X_CUST_BAL_AMT" : "20000", "X_STATUS" : "S","X_ERROR_MSG" : ""}}';
                parser = JSON.createParser(responseString);
            }
            system.debug('responseString===>'+responseString);
            string BalanceAmount;
            string StatusCode;
            string Message;
            if(parser!=null){
                while(parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'X_CUST_BAL_AMT')) {
                        parser.nextToken();
                        if(parser.getText()!=null)
                            BalanceAmount = parser.getText();
                    }
                    if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'X_STATUS')) {
                        parser.nextToken();
                        StatusCode = parser.getText();
                    }
                    if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'X_ERROR_MSG')) {
                        parser.nextToken();
                        Message = parser.getText();
                    }
                }
            }
            system.debug('BalanceAmount===>'+BalanceAmount);
            system.debug('StatusCode===>'+StatusCode);
            system.debug('Message===>'+Message);
            if(BalanceAmount!=null && BalanceAmount!='null')
                OracleBalance = decimal.valueOf(BalanceAmount);
            
            system.debug('OracleBalance===>'+OracleBalance);
        }
        return OracleBalance;
    }
    
    /*
        Method Name     :   GetOracleBalance_New
        Description     :   Http Callout to ERP for get balance
							
    
    public static decimal GetOracleBalance_Old(string accId){
        decimal OracleBalance;
        if(string.isNotBlank(accId)) {
            //string OracleLogins = 'UserName:Password';
            string OracleLogins;
            for(Oracle_API_Info__mdt OLG:[Select Id,Username__c,Password__c from Oracle_API_Info__mdt limit 1]){
                OracleLogins = OLG.Username__c+':'+OLG.Password__c;
            }
            
            List<Account> listAcc = new List<Account>();
            listAcc = [SELECT Id,Oracle_Party_Id__c, Oracle_Site_Id__c  FROM Account WHERE id =: accId] ;
            if(listAcc<> null && listAcc.size() > 0) {
                string EncodedLogins = EncodingUtil.base64Encode(blob.valueof(OracleLogins));
                string EndPointUrl = label.OracleBalalnceCheckEndPoint;
                string PostData = '{"Create_OSS":{"InputParameters": {"P_ORA_PARTY_ID ": "'+listAcc[0].Oracle_Party_Id__c+'", "P_ORG_ID ": "'+listAcc[0].Oracle_Site_Id__c+'"}}}';
                JSONParser parser;
                string responseString;
                HttpRequest req = new HttpRequest();
                req.setEndpoint(EndPointUrl);
                req.setMethod('POST');
                req.setTimeout(6000);
                system.debug('postData===>'+postData);
                req.setHeader('Authorization', 'Basic ' + EncodedLogins);
                req.setHeader('content-type','application/json');
                req.setBody(postData);
                Http http = new Http();
                
                if(!Test.isRunningTest()){
                    try{
                        HTTPResponse res = http.send(req);
                        responseString = string.valueOf(res.getBody());
                        parser = JSON.createParser(res.getBody());
                    }catch(Exception e){
                        system.debug('Exception===>'+e.getMessage());
                    }
                }else{
                    responseString = '{"OutputParameters" : { "@xmlns" : "http://xmlns.oracle.com/apps/xxadgm/rest/Create_ACCESSADGM_Balance_Check/get_oss_cust_balance/","@xmlns:xsi" : "http://www.w3.org/2001/XMLSchema-instance","X_CUST_BAL_AMT" : "20000", "X_STATUS" : "S","X_ERROR_MSG" : ""}}';
                    parser = JSON.createParser(responseString);
                }
                system.debug('responseString===>'+responseString);
                string BalanceAmount;
                string StatusCode;
                string Message;
                if(parser!=null){
                    while(parser.nextToken() != null) {
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'X_CUST_BAL_AMT')) {
                            parser.nextToken();
                            if(parser.getText()!=null)
                                BalanceAmount = parser.getText();
                        }
                        if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'X_STATUS')) {
                            parser.nextToken();
                            StatusCode = parser.getText();
                        }
                        if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'X_ERROR_MSG')) {
                            parser.nextToken();
                            Message = parser.getText();
                        }
                    }
                }
                system.debug('BalanceAmount===>'+BalanceAmount);
                system.debug('StatusCode===>'+StatusCode);
                system.debug('Message===>'+Message);
                if(BalanceAmount!=null && BalanceAmount!='null')
                    OracleBalance = decimal.valueOf(BalanceAmount);
                
                system.debug('OracleBalance===>'+OracleBalance);
            }
            
            
        }
        return OracleBalance;
        
    }
*/
    public static balanceResponse doBalanceCheckCallout(string accId){
        try{
            List<Account> listAcc = [SELECT Id,Oracle_Party_Id__c, Oracle_Site_Id__c  FROM Account WHERE id =: accId] ;
            balanceRequest objbalanceRequest = new balanceRequest();
            objbalanceRequest.P_IN_ORG_ID = listAcc[0].Oracle_Site_Id__c;
            objbalanceRequest.P_IN_ORA_PARTY_ID = listAcc[0].Oracle_Party_Id__c;
            String PostData = JSON.serialize(objbalanceRequest);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(label.BM_OracleBalalnceCheckEndPoint_New);
            req.setMethod('POST');
            req.setTimeout(6000);
            system.debug('postData===>'+postData);
            req.setHeader('content-type','application/json');
            req.setBody(postData);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(res.getBody());
            return (balanceResponse)JSON.deserialize(res.getBody(), balanceResponse.class);
        } catch(Exception e){
            system.debug('Exception===>'+e.getMessage());
        }
        return null;
    } 
    
    /*
        Method Name     :   GetOracleBalance_New
        Description     :   Http Callout to ERP for get balance
    */
    public static decimal GetOracleBalance_New(string accId){
        Decimal OracleBalance = 0;
        if(string.isNotBlank(accId)) {
            balanceResponse objentitybalanceWrapperResponse = new balanceResponse();
            objentitybalanceWrapperResponse = doBalanceCheckCallout(accId);
                string BalanceAmount;
                string StatusCode;
                string Message;
                if(objentitybalanceWrapperResponse == null || objentitybalanceWrapperResponse.P_OP_CURRENCY_TBL_ITEM == null) {
                    OracleBalance = 0;
                } else {
                    
                
                for(BalanceCurrency objBalanceCurrency : objentitybalanceWrapperResponse.P_OP_CURRENCY_TBL_ITEM){
                    
                    if(objBalanceCurrency.X_CURRENCY == 'AED' && objBalanceCurrency.X_ORIGINAL_AMOUNT <> null && objBalanceCurrency.X_ORIGINAL_AMOUNT <> '' ) {
                        BalanceAmount = objBalanceCurrency.X_ORIGINAL_AMOUNT;
                    } 
                }    
                if(objentitybalanceWrapperResponse.P_OP_STATUS <> null && objentitybalanceWrapperResponse.P_OP_STATUS <> '' ) {
                    StatusCode = objentitybalanceWrapperResponse.P_OP_STATUS;
                } 
                
                if(objentitybalanceWrapperResponse.P_OP_ERROR_MSG <> null && objentitybalanceWrapperResponse.P_OP_ERROR_MSG <> '' ) {
                    Message = objentitybalanceWrapperResponse.P_OP_ERROR_MSG;
                }
                system.debug('BalanceAmount===>'+BalanceAmount);
                system.debug('StatusCode===>'+StatusCode);
                system.debug('Message===>'+Message);
                if(BalanceAmount!=null && BalanceAmount!='null')
                    OracleBalance = decimal.valueOf(BalanceAmount);
                }
                system.debug('OracleBalance===>'+OracleBalance);
            }
        return OracleBalance;
    }

    public static void updateEntityBalance(string accId){
        if(string.isNotBlank(accId)){
            balanceResponse objentitybalanceWrapperResponse = new balanceResponse();
            objentitybalanceWrapperResponse = doBalanceCheckCallout(accId);
            Account accountObj = new Account(Id = accId);
            if(objentitybalanceWrapperResponse.P_OP_STATUS == 'S'){
                for(BalanceCurrency objBalanceCurrency : objentitybalanceWrapperResponse.P_OP_CURRENCY_TBL_ITEM){
                    if(objBalanceCurrency.X_CURRENCY == 'AED'){
                        accountObj.Original_Amount_AED__c = Decimal.valueof(objBalanceCurrency.X_ORIGINAL_AMOUNT);
                        accountObj.Converted_Amount_AED__c = Decimal.valueof(objBalanceCurrency.X_CONVERTED_AMOUNT);
                    }

                    if(objBalanceCurrency.X_CURRENCY == 'USD'){
                        accountObj.Original_Amount_USD__c = Decimal.valueof(objBalanceCurrency.X_ORIGINAL_AMOUNT);
                        accountObj.Converted_Amount_USD__c = Decimal.valueof(objBalanceCurrency.X_CONVERTED_AMOUNT);
                    }
                }
            } else {
                accountObj.Oracle_Response_Message__c = objentitybalanceWrapperResponse.P_OP_ERROR_MSG;
            }
            update accountObj;
        }
    }
    
    public class balanceRequest {
        public string P_IN_ORA_PARTY_ID;
        public string P_IN_ORG_ID;
    }
    
    public class balanceResponse {
        public string P_OP_ORG_ID;
        public string P_OP_CUST_BAL_AMT;
        public string P_OP_STATUS;
        public string P_OP_ERROR_MSG;
        public List<BalanceCurrency> P_OP_CURRENCY_TBL_ITEM;
    }
    
    public class BalanceCurrency {
        public string X_CURRENCY;
        public string X_ORIGINAL_AMOUNT;
        public string X_CONVERTED_AMOUNT;
    }

    public static void UpdatePortalBalance(string OraclePartyId,decimal LatestBalance){
        Account acc = new Account();
        acc.Oracle_Party_Id__c = OraclePartyId;
        acc.Portal_Balance_Last_Updated__c = system.now();
        acc.HexaBPM__Portal_Balance__c = LatestBalance;
        try{
            upsert acc Oracle_Party_Id__c;
        }catch(Exception e){
            
        }
    }
}