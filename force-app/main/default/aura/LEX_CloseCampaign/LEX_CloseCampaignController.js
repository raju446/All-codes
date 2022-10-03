({
	// Onload function
    init: function (component, event, helper) {
        
		var action = component.get("c.validationBeforecloseCampaign");
        // set parameter
        action.setParams({
            "campaignId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log('state'+state);
                var records = response.getReturnValue();
                if(records.includes("Campaign has been closed successfully")) {
                    console.log(records);
                    component.set("v.showSucess", true);
                    component.set("v.sucessMessage", records);
                } else {
                    
                    component.set("v.showError", true);
                    component.set("v.errorMessage", records);
                }//end else - if
              
			} else {
                
                component.set("v.showError", true);
                component.set("v.errorMessage", state);
				console.log("Failed with state: " + state);
			} //end else - if
            $A.get('e.force:refreshView').fire();
		});
		$A.enqueueAction(action); 
	},
    
    
    afterYesButton : function(component,event,helper){
        var action = component.get("c.closeCampaign");
        // set parameter
        action.setParams({
            "campaignId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log('state'+state);
                var records = response.getReturnValue();
                if(records == 'Campaign has been closed successfully') {
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                } else {
                    component.set("v.showError", true);
                    component.set("v.showSucess", false);
                	component.set("v.errorMessage", records);
                }
              
			} else {
                
                component.set("v.showError", true);
                component.set("v.showSucess", false);
                component.set("v.errorMessage", state);
				console.log("Failed with state: " + state);
			} //end else - if
		});
		$A.enqueueAction(action); 
    },
    
    cancelButton : function(component,event,helper){
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire();
    }
})