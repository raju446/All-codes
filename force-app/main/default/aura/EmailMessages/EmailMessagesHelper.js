({
      getEmailList: function(component, event, helper) {
		var caseId = component.get("v.recordId");
		var action = component.get("c.getEmailMessages"); // method in the apex class
		action.setParams({
			CaseId : caseId
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
                
                var conts = response.getReturnValue();
                console.log(conts); 
                  
                component.set("v.EmailMessages",conts);
                console.log(component.get("v.EmailMessages"));
                
          
			}
			else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
	},
    
     MarkEmailUnread: function(component, event, helper) {
		var caseId = component.get("v.recordId");
        var idx = event.target.id;
		var markRead = component.get("c.UnreadEmailCheck"); // method in the apex class
		markRead.setParams({
			CaseId : caseId,
            idSelected : idx
		});
		$A.enqueueAction(markRead);
	},
    
})