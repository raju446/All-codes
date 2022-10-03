/**
 * @File Name          : Batch_PushEntityToOracle.cls
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 11-16-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/8/2020   Jayanta Karmakar     Initial Version
**/
global class Batch_PushEntityToOracle implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
    global Database.QueryLocator start(Database.BatchableContext BC){
        //String query = 'SELECT Id FROM Account WHERE Oracle_Party_Id__c = null';
        //SELECT Id FROM Account WHERE Oracle_Party_Id__c = null and recordtype.developername = \'ADGM_Registered_Company\' and Invoice_Count__c > 0 AND To_Be_Pushed_To_ERP_TBD__c = true
        String query = '';
        if(Test.isRunningTest()){
            query = 'SELECT Id FROM Account WHERE Oracle_Party_Id__c = null';
        } else {
            query = 'SELECT Id FROM Account WHERE Oracle_Party_Id__c = null AND To_Be_Pushed_To_ERP_TBD__c = true';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Account> scope){
        for(Account acc : scope){
            EntityUtil.PushEntityToOracle(acc.Id, false);
        }
    }
    global void finish(Database.BatchableContext BC){
      
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new Batch_PushEntityToOracle(), 10);
    }
}