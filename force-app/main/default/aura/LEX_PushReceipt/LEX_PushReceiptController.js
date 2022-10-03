/**
 * @description       : 
 * @author            : Jayanta Karmakar
 * @group             : 
 * @last modified on  : 02-11-2021
 * @last modified by  : Jayanta Karmakar
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   02-11-2021   Jayanta Karmakar   Initial Version
**/
({
	init : function(component, event, helper) {
        var v = component.get('v.recordId');
        console.log(v);
        component.set('v.Spinner',true);
		var action = component.get("c.fetchReceiptDetails");
        action.setParams({
            'receiptId': v
        });
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log(JSON.stringify(response.getReturnValue()));
                var resp = response.getReturnValue();
                if(resp.Status__c != 'Success' && resp.Status__c != 'Approved' && !(resp.Status__c == 'Rejected' && resp.Payment_Status__c == 'Payment Received from Incorrect Source')){
                    component.set('v.errorMessage','Status should be Success or Approved !');
                    component.set('v.showError',true);
                    component.set('v.Spinner',false);
                } else if(resp.Pushed_to_Oracle__c){
                    component.set('v.errorMessage','Record is already pushed to Oracle !');
                    component.set('v.showError',true);
                    component.set('v.Spinner',false);
                } else {
                    var action2 = component.get("c.pushReciptToERP");
                    action2.setParams({
                        'recordId': v,
                        'isReceipt' : true
                    });
                    action2.setCallback(this, function(response){
                        var state = response.getState();
                        component.set('v.Spinner',false);
                        if (state === "SUCCESS") {
                            var result2  = response.getReturnValue();
                            if(result2 == 'Success'){
                                component.set('v.sucessMessage','Record successfully pushed to Oracle !');
                                component.set('v.showSucess',true);
                                $A.get('e.force:refreshView').fire();
                            } else {
                                component.set('v.errorMessage',result2);
                    			component.set('v.showError',true);
                            }
                        }
                    });
                    $A.enqueueAction(action2);
                }
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
	}
})