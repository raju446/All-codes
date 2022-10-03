/**
 * @File Name          : AddressTrigger.trigger
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 3/30/2020, 4:31:33 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/30/2020   Jayanta Karmakar     Initial Version
**/
trigger AddressTrigger on Address__c (before insert, before update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            AddressTriggerHandler.handleBI(Trigger.new);
        } 

        if(Trigger.isUpdate){
            AddressTriggerHandler.handleBU(Trigger.new, Trigger.oldMap);    
        }
    }
}