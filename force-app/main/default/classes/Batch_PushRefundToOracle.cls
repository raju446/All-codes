/**
 * @File Name          : Batch_PushRefundToOracle.cls
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 4/7/2020, 3:38:56 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/7/2020   Jayanta Karmakar     Initial Version
**/
global class Batch_PushRefundToOracle implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable{
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM Refund__c WHERE Pushed_To_Oracle__c = false and (Status__c = \'Success\' OR Status__c = \'Approved\')';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Refund__c> scope){
        List<String> refundIds = new List<String>();
        for(Refund__c eachRefund : scope){
            //refundIds.add(eachRefund.Id);
            RefundUtil.pushRefundToOracle(eachRefund.Id);
        }
    }
    global void finish(Database.BatchableContext BC){
    
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new Batch_PushRefundToOracle(), 10);
    }
}