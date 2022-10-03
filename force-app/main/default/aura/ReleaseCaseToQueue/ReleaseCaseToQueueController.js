({
    doInit: function (component, event, helper) {
		var caseId = component.get("v.recordId");
		//Save the case obj with in progress status
        var releaseAction = component.get("c.releaseCaseToQueue"); // method in the apex class
        releaseAction.setParams({"caseId": caseId});
        releaseAction.setCallback(this, function(response) {
            var state = response.getState();
            console.log(response);
            if(state === "SUCCESS") {
                var responseMessage = response.getReturnValue();
                console.log('set..');
                if(responseMessage == 'success'){
                    component.set("v.caseMsg", 'Case is released successfully.');
                    var action = component.get("c.getListViews");
                    action.setCallback(this, function(response){
                    var state = response.getState();
                    if (state === "SUCCESS" && responseMessage== 'success') {
                        var listviews = response.getReturnValue();
                        var navEvent = $A.get("e.force:navigateToList");
                        navEvent.setParams({
                            "listViewId": listviews.Id,
                            "listViewName": null,
                            "scope": "Case"
                            });
                            navEvent.fire();
                        }
                    });
                    $A.enqueueAction(action);
                    $A.get('e.force:refreshView').fire();
                }
                    
                else
                component.set("v.caseMsg", responseMessage);
            }
            else {
                console.log('Problem saving case, response state: ' + state);
            }
        });
        $A.enqueueAction(releaseAction);
      
	},
	closeAction:function (component, event, helper) {
		//Close the popup
		$A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
	}

    })