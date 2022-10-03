/*
    Author      : Kim Noceda
    Date        : 08-Jan-2018
    Description : Trigger handler class that is being referenced in the TradeNameTrigger.
                  All DML methods are being handled in this handler class.
    --------------------------------------------------------------------------------------
*/
public without sharing class TradeNameTriggerHandler{
    
    /*
        Method Name :   SetPrimaryAsUnchecked
        Description :   Method to Set Primary of related Trade names as unchecked.
    */
    public static void SetPrimaryAsUnchecked(List<Trade_Name__c> newTradeNames, Map<Id, Trade_Name__c> oldTradeNameMap, Boolean isInsert){
        Set<Id> entityIds = new Set<Id>();
        Set<Id> tradeNameIds = new Set<Id>();
        List<Trade_Name__c> tradeNamesToUpdate = new List<Trade_Name__c>();
        if(isInsert == true){
            for(Trade_Name__c objTradeName : newTradeNames){
                if(objTradeName.Primary__c == true){
                    entityIds.add(objTradeName.Entity__c);
                    tradeNameIds.add(objTradeName.Id);
                }
            }
        } else{
            for(Trade_Name__c objTradeName : newTradeNames){
                if(objTradeName.Primary__c == true && oldTradeNameMap.get(objTradeName.Id).Primary__c == false){
                    entityIds.add(objTradeName.Entity__c);
                    tradeNameIds.add(objTradeName.Id);
                }
            }
        }
        for(Trade_Name__c objTN : [SELECT Id, Primary__c FROM Trade_Name__c WHERE Entity__c IN :entityIds AND Id NOT IN :tradeNameIds]){
            objTN.Primary__c = false;
            tradeNamesToUpdate.add(objTN);
        }
        if(!tradeNamesToUpdate.isEmpty()){
            update tradeNamesToUpdate;
        }
    }
    
    /*
        Method Name :   InitiateCIDApproval
        Description :   Method to Initiate CID Approval for the Entity.
    */
    public static void InitiateCIDApproval(List<Trade_Name__c> newTradeNames, Map<Id, Trade_Name__c> oldTradeNameMap, Boolean isInsert){
        List<HexaBPM__Service_Request__c> objSRList = new List<HexaBPM__Service_Request__c>();
        Id cidRectypeId;
        List<User> currentUser = [SELECT Id, UserType, Email FROM User WHERE Id = :Userinfo.getUserId() LIMIT 1];
        if(!currentUser.isEmpty()){
            if(currentUser[0].UserType == 'Standard'){
                for(RecordType rectype : [SELECT Id from RecordType WHERE sObjectType='HexaBPM__Service_Request__c' AND DeveloperName=:Label.Initial_Approval_Recordtype_API AND IsActive=true]){
                   cidRectypeId = rectype.Id;
                }
                Set<Id> accountIds = new Set<Id>();
                for(Trade_Name__c objTN : newTradeNames){
                     if(isInsert == true){
                        /*if(objTN.Primary__c == true){
                            accountIds.add(objTN.Entity__c);
                        }*/
                        //04112018 -- Trigger Initial Approval if a new Trade name is inserted
                        accountIds.add(objTN.Entity__c);
                    } else{
                        /*if(objTN.Primary__c == true && oldTradeNameMap.get(objTN.Id).Primary__c == false){
                            accountIds.add(objTN.Entity__c);
                        }*/
                        //04112018 -- Trigger Initial Approval if there is an update on the Trade Name
                        if((objTN.Name_In_English__c != oldTradeNameMap.get(objTN.Id).Name_In_English__c) ||
                            (objTN.Name_in_Arabic__c != oldTradeNameMap.get(objTN.Id).Name_in_Arabic__c) ||
                            (objTN.Status__c != oldTradeNameMap.get(objTN.Id).Status__c && objTN.Status__c=='Active') ||
                            (objTN.Primary__c != oldTradeNameMap.get(objTN.Id).Primary__c)){
                            accountIds.add(objTN.Entity__c);
                        }
                    }
                }
                for(Account objAcct : [SELECT Id, Entity_Id__c, 
                                        (SELECT Id FROM Relationships__r WHERE Status__c = 'Active' AND Type__c = 'Authorised Signatory' LIMIT 1),
                                        (SELECT Id from Business_Activities__r LIMIT 1)
                                        FROM Account WHERE Id IN :accountIds]){
                    if(objAcct.Relationships__r.size() > 0 && objAcct.Business_Activities__r.size() > 0){   
                        HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
                        objSR.License_Number__c = objAcct.Entity_Id__c;
                        objSR.RecordtypeId = cidRectypeId;
                        objSR.HexaBPM__Customer__c = objAcct.Id;
                        objSR.HexaBPM__Email__c = currentUser[0].Email;
                        objSR.HexaBPM__Auto_Submit__c = true;
                        objSRList.add(objSR);
                    }
                }
                
                if(!objSRList.isEmpty()){
                    Savepoint sp = Database.setSavepoint();
                    try{
                        insert objSRList;
                    } catch(Exception e){
                        System.debug('##Error: '+e.getMessage());
                        Database.rollback(sp);
                    }
                    
                    
                    /*List<HexaBPM__SR_Status__c> srStatusSubmittedId = [SELECT Id, HexaBPM__Code__c FROM HexaBPM__SR_Status__c WHERE HexaBPM__Code__c = 'SUBMITTED'];
                    for(HexaBPM__Service_Request__c objSR : objSRList){
                        objSR.HexaBPM__Internal_SR_Status__c = srStatusSubmittedId[0].Id;
                        objSR.HexaBPM__External_SR_Status__c = srStatusSubmittedId[0].Id;
                        objSR.HexaBPM__Submitted_Date__c = system.today();
                        objSR.HexaBPM__Submitted_DateTime__c = system.now();
                    }
                    if(!objSRList.isEmpty()){
                        update objSRList;
                    }*/
                }
            }
        }
    }
}