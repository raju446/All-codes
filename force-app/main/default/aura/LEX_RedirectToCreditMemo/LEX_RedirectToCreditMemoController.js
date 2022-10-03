({
	init : function(component, event, helper) {
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__Lex_CreditMemo',
            },
            state: {
                "c__recordId": component.get("v.recordId")
            }
        };
        component.set("v.pageReference", pageReference);
        var navService = component.find("navService");
        var pageReference = component.get("v.pageReference");
        var action = component.get("c.getCreditMemoStatus");
        // set parameter
        action.setParams({
            "creditMemoId": component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('state'+state);
                var records = response.getReturnValue();
                if(records != null && records == 'Success') {
                    navService.navigate(pageReference);
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