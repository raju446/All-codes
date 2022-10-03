/**
 * @File Name          : LEX_PushRefundController.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 6/29/2020, 4:05:13 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/24/2020   Jayanta Karmakar     Initial Version
**/
({
	init : function(component, event, helper) {
        var v = component.get('v.recordId');
        console.log(v);
		component.set('v.Spinner',true);
		var action = component.get("c.fetchRefundDetails");
        action.setParams({
            'refundId': v
        });
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log(JSON.stringify(response.getReturnValue()));
                var resp = response.getReturnValue();
                if(resp.Status__c != 'Success' && resp.Status__c != 'Approved'){
                    component.set('v.errorMessage','Status should be Success or Approved !');
                    component.set('v.showError',true);
                    component.set('v.Spinner',false);
				} else if(resp.Oracle_Callout_Status__c == 'S'){
					component.set('v.errorMessage','Record already pushed to Oracle !');
                    component.set('v.showError',true);
                    component.set('v.Spinner',false);
				} else {
                    var action2 = component.get("c.pushRefundRecToOrale");
                    action2.setParams({
                        'refundId': v
                    });
                    action2.setCallback(this, function(response){
                        var state = response.getState();
                        component.set('v.Spinner',false);
                        if (state === "SUCCESS") {
                            var result2  = response.getReturnValue();
                            if(result2 == 'Success' || result2 == 'SUCCESS'){
                                component.set('v.sucessMessage','Record successfully pushed to Oracle !');
                    			component.set('v.showSucess',true);
                            } else {
                                component.set('v.errorMessage',result2);
                    			component.set('v.showError',true);
                            }
                        }
                    });
                    $A.enqueueAction(action2);
                }
			} else {
				component.set('v.Spinner',false);
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
	}
})