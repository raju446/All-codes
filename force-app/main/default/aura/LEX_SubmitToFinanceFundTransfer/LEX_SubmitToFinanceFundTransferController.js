({
	init : function(component, event, helper) {
		var action1 = component.get("c.submitForApproval");
        action1.setParams({
            "fundTransferId" : component.get("v.recordId")
        });
        action1.setCallback(this, $A.getCallback(function(response) {
            $A.get('e.force:refreshView').fire();
            if(response.getState() === "SUCCESS") {
                var response = response.getReturnValue();
                if(response == 'Success') {
                    component.set("v.showSucess", true);
                    component.set("v.sucessMessage", 'Record submitted for approval successfully');
                } else {
                    component.set("v.showError", true);
                    component.set("v.errorMessage", response);
                }
            } else {
                component.set("v.showError", true);
                component.set("v.errorMessage", state);
            }

        }));
        $A.enqueueAction(action1);
	}
})