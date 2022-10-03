/**
 * @File Name          : LEX_PushEntityController.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 4/22/2020, 4:03:21 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/22/2020   Jayanta Karmakar     Initial Version
**/
({
	init : function(component, event, helper) {
        var v = component.get('v.recordId');
        console.log(v);
		component.set('v.Spinner',true);
		var action = component.get("c.fetchInvoiceDetails");
        action.setParams({
            'invoiceId': v
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
				} else if(resp.Journal_Created__c){
					component.set('v.errorMessage','Journal already created !');
                    component.set('v.showError',true);
                    component.set('v.Spinner',false);
				} else {
                    var action2 = component.get("c.pushReciptToERP");
                    action2.setParams({
                        'recordId': v,
                        'isReceipt' : false
                    });
                    action2.setCallback(this, function(response){
                        var state = response.getState();
                        component.set('v.Spinner',false);
                        if (state === "SUCCESS") {
                            var result2  = response.getReturnValue();
                            if(result2 == 'Success' || result2 == 'SUCCESS'){
                                component.set('v.sucessMessage','Journal records created !');
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