({
	// Onload function
    init: function (component, event, helper) {
        var action = component.get("c.checkContactPrivate");
        // set parameter
        action.setParams({
            "contactId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {

                component.set("v.isShowData", response.getReturnValue());              
			} else {
				component.set("v.isShowData", false);
			}
		});
		$A.enqueueAction(action);
		
	}
})