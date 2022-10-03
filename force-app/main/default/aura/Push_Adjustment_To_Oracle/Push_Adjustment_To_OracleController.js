/**
 * @File Name          : Push_Adjustment_To_OracleController.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 7/9/2020, 11:14:56 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/15/2020   Jayanta Karmakar     Initial Version
**/
({
	init : function(component, event, helper) {
        component.set('v.Spinner',true);
        var action1 = component.get("c.getAdjustmentDetails");
        action1.setParams({
            recordId : component.get("v.recordId")
        });
        action1.setCallback(this, $A.getCallback(function(response) {
            var response = response.getReturnValue();
            console.log(response);
            if(response.Status__c != 'Approved' && response.Status__c != 'Error' && response.Status__c != 'Success'){
                component.set('v.errorMessage','Status should be Success or Approved or Error !');
                component.set('v.showError',true);
                component.set('v.Spinner',false);
            } else if(response.Status__c == 'Approved' || response.Status__c == 'Error' || response.Status__c == 'Success'){
                var action = component.get("c.pushAdjustmentToOracle");
                // set parameter
                action.setParams({
                    'adjustmentId' : component.get("v.recordId")
                });
                component.set("v.Spinner", false);
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    component.set("v.Spinner", false);
                    if (state === "SUCCESS" ) {
                        if(response.getReturnValue().P_OP_STATUS == 'Success' || response.getReturnValue().P_OP_STATUS == 'success') {
                            component.set("v.showSucess", true);
                            component.set("v.sucessMessage", 'Record has been sucessfully push' );
                        } else {
                            component.set("v.showError", true);
                            component.set("v.errorMessage", response.getReturnValue().P_OP_ERROR_MSG );
                        }
                            
                        
                        
                        $A.get('e.force:refreshView').fire();
                            
                    } else {
                        console.log("Failed with state: " + state);
                        component.set("v.showError", true);
                        component.set("v.errorMessage", state);
                        //helper.showToast('error', 'Error!', state);
                    }
                });
            // component.set("v.Spinner", false);
                $A.enqueueAction(action);
            } else {
                console.log('inside else condition');
                component.set('v.Spinner',false);
            }
        }));
        $A.enqueueAction(action1);
        /*
		var action = component.get("c.pushAdjustmentToOracle");
		// set parameter
        action.setParams({
            'adjustmentId' : component.get("v.recordId")
        });
        component.set("v.Spinner", false);
        action.setCallback(this, function(response) {
			var state = response.getState();
            component.set("v.Spinner", false);
			if (state === "SUCCESS" ) {
                if(response.getReturnValue().P_OP_STATUS == 'Success' || response.getReturnValue().P_OP_STATUS == 'success') {
                    component.set("v.showSucess", true);
                    component.set("v.errorMessage", 'Record has been sucessfully push' );
                } else {
                    component.set("v.showError", true);
                    component.set("v.errorMessage", response.getReturnValue().P_OP_ERROR_MSG );
                }
                    
                
                
                $A.get('e.force:refreshView').fire();
                    
			} else {
				console.log("Failed with state: " + state);
                component.set("v.showError", true);
                component.set("v.errorMessage", state);
                helper.showToast('error', 'Error!', state);
			}
		});
       // component.set("v.Spinner", false);
		$A.enqueueAction(action); */
	}
})