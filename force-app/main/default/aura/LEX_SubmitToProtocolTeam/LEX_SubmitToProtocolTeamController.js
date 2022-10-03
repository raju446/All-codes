({
	// Onload function
    init: function (component, event, helper) {
        
		var action = component.get("c.submitCampaign");
        // set parameter
        action.setParams({
            "campaignId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log('state'+state);
                var records = response.getReturnValue();
                if(!records.includes("Campaign has been submitted successfully") ) {
                    component.set("v.showError", true);
                    component.set("v.errorMessage", records);
                   
                } else {
                    console.log(records);
                    
                     component.set("v.showSucess", true);
                    component.set("v.sucessMessage", records);
                }//end else - if
              
			} else {
                
                component.set("v.showError", true);
                component.set("v.errorMessage", state);
				console.log("Failed with state: " + state);
			} //end else - if
            $A.get('e.force:refreshView').fire();
		});
		$A.enqueueAction(action); 
	}
})