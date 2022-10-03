/**
 * @File Name          : Batch_PushFundTransferToOracle.cls
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 4/7/2020, 3:40:10 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/7/2020   Jayanta Karmakar     Initial Version
**/
global class Batch_PushFundTransferToOracle implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable{
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM Fund_Transfer__c WHERE Pushed_To_Oracle__c = false and (Status__c = \'Success\' OR Status__c = \'Approved\')';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Fund_Transfer__c> scope){
        //List<String> fundTransferIds = new List<String>();
        for(Fund_Transfer__c eachFundTransfer : scope){
            //fundTransferIds.add(eachFundTransfer.Id);
            BalanceTransferUtil.pushBalaceTransferToOracle(eachFundTransfer.Id);
        }
    }
    global void finish(Database.BatchableContext BC){
    
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new Batch_PushFundTransferToOracle(), 10);
    }
}