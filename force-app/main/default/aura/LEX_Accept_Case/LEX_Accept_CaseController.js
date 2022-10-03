({
    doInit: function (component, event, helper) {
		var caseId = component.get("v.recordId");
		var loggedInUserId;
		//Gets the logged in user id
		var userAction = component.get("c.getUserId"); // method in the apex class
		userAction.setCallback(this, function(a) {
			loggedInUserId = a.getReturnValue(); // variable in the component
		});
		$A.enqueueAction(userAction);
		// Prepare the action to load Case record
		var action = component.get("c.getCase");
		action.setParams({"caseId": caseId});

		// Configure response handler
		action.setCallback(this, function(response) {
			var state = response.getState();
			if(state === "SUCCESS") {
				var caseRecord = response.getReturnValue();
				
				console.log(caseRecord);
				if(caseRecord){
                    console.log(caseRecord.IsClosed);
					if (caseRecord.IsClosed == false) {
						if (loggedInUserId == caseRecord.OwnerId) {
							component.set("v.caseMsg", 'You are already the owner of this case.');
						} 
						else 
						{
								//Save the case obj with in progress status
								var upsertAction = component.get("c.saveCaseWithOwner"); // method in the apex class
								upsertAction.setParams({"caseId": caseId});
								upsertAction.setCallback(this, function(a) {
									var state = a.getState();
									if(state === "SUCCESS") {
                                        console.log('set..');
										component.set("v.caseMsg", a.getReturnValue());
                                        //$A.get("e.force:closeQuickAction").fire();
                						//$A.get('e.force:refreshView').fire();
									}
									else {
										console.log('Problem saving case, response state: ' + state);
									}
								});
								$A.enqueueAction(upsertAction);
								
						}
					} else {
						component.set("v.caseMsg", 'Case is already closed.');
					}
				}
			} else {
				console.log('Problem getting account, response state: ' + state);
			}
		});
		$A.enqueueAction(action);
	
	},
	closeAction:function (component, event, helper) {
		//Close the popup
		var dismissActionPanel = $A.get("e.force:closeQuickAction");
		dismissActionPanel.fire();
		$A.get('e.force:refreshView').fire();
	}

    })