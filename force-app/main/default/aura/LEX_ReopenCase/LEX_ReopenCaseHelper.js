({
	getHasAccsess: function(component, event, helper) {
		var caseId = component.get("v.recordId");
		var action = component.get("c.ReopenData"); // method in the apex class
		action.setParams({
			CaseId : caseId
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
                var custs = [];
                var conts = response.getReturnValue();
                console.log(conts); 
                for(var key in conts){
                    custs.push({value:conts[key], key:key});
                     
                }
                component.set("v.hasAccess",key);
                component.set("v.caseMessage",custs);
                console.log(component.get("v.hasAccess"));
                console.log(component.get("v.caseMessage"));
                console.log(component.get("v.reopenReason"));
          
			}
			else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
	},
    
      getapexmethod: function(component, event, helper) {
		var caseId = component.get("v.recordId");
       var ReopenReason = component.get("v.ReopeningReason");

        console.log(ReopenReason);
        console.log(caseId);
        
        if (ReopenReason != null && ReopenReason !=''){
		    var reopenAction = component.get("c.reopenCase"); 
            console.log("hi");
          
		reopenAction.setParams({
			CaseId : caseId,
            reason : ReopenReason
    	});
        reopenAction.setCallback(this, function(response) {
			var state = response.getState();
            console.log(state);
            console.log("hi");
			if (component.isValid() && state === "SUCCESS") {
                 var conts = response.getReturnValue();
                  console.log(conts);  
                }else {
				console.log("Failed with state: " + state);
			}
         
		});
		$A.enqueueAction(reopenAction);
        
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
		dismissActionPanel.fire();
        $A.get('e.force:refreshView').fire();
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: 'The Case has been reopened successfully',
            messageTemplate: 'Record {0} created! See it {1}!',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
        } 
	},   
    
})