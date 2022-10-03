/**
 * @File Name          : LEX_PushEntityController.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 4/22/2020, 3:51:56 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/22/2020   Jayanta Karmakar     Initial Version
**/
({
	init : function(component, event, helper) {
        var v = component.get('v.recordId');
        console.log(v);
		component.set('v.Spinner',true);
		var action = component.get("c.fetchAccountDetail");
        action.setParams({
            'accountId': v
        });
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log(JSON.stringify(response.getReturnValue()));
                var resp = response.getReturnValue();
                if(resp.Oracle_Party_Id__c){
                    component.set('v.errorMessage','Entity is Already Pushed to Oracle !');
                    component.set('v.showError',true);
                    component.set('v.Spinner',false);
                } else {
                    var action2 = component.get("c.pushAccountToOracle");
                    action2.setParams({
                        'accId': resp
                    });
                    action2.setCallback(this, function(response){
                        var state = response.getState();
                        component.set('v.Spinner',false);
                        if (state === "SUCCESS") {
                            var result2  = response.getReturnValue();
                            if(result2){
                                component.set('v.sucessMessage','Record successfully pushed to Oracle !');
                    			component.set('v.showSucess',true);
                            } else {
                                component.set('v.errorMessage','Something went Wrong !');
                    			component.set('v.showError',true);
                            }
                        } else {
							console.log(state);
							console.log(response.getReturnValue());
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