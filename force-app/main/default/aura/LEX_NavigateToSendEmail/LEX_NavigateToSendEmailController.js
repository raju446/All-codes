({
	init : function(component, event, helper) {
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__LEX_SendEmails',
            },
            state: {
                "c__recordId": component.get("v.recordId")
            }
        };
        component.set("v.pageReference", pageReference);
        var navService = component.find("navService");
        var pageReference = component.get("v.pageReference");
        var action = component.get("c.getApprovedStatus");
        // set parameter
        action.setParams({
            "campaignId": component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('state'+state);
                var records = response.getReturnValue();
                if(records != null && records == 'Success') {
                    navService.navigate(pageReference);
                } else if(records == 'Campaign is already been closed') {
                    component.set("v.showError", true);
                    component.set("v.errorMessage", records);
                    
                } else  {
                    component.set("v.showError", true);
                    component.set("v.errorMessage", records);
                    
                }//end else - if
                
            } else {
                console.log("Failed with state: " + state);
                component.set("v.showError", true);
                component.set("v.errorMessage", state);
            }
        });
        $A.enqueueAction(action);
        
    }
})