({
	getHasAccsess: function(component, event, helper) {
		var caseId = component.get("v.recordId");
		var action = component.get("c.EscalateData"); // method in the apex class
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
                console.log(component.get("v.EscReason"));
          
			}
			else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
	},
    
	   EscalateCaseReason : function(component, event, helper) {
		var caseId = component.get("v.recordId");
        var EscReason = component.get("v.EscReason");
         
        
        console.log(EscReason);
        console.log(caseId);
        
        if (EscReason != null && EscReason != ''){
		    var escalateAction = component.get("c.changeOwner"); 
            console.log("hiii");
          
		escalateAction.setParams({
			CaseId : caseId,
            escReason : EscReason,
            
		});
            console.log("here")
        escalateAction.setCallback(this, function(response) {
			var state = response.getState();
            console.log(state);
            console.log("hi");
			if (component.isValid() && state === "SUCCESS") {
                 var conts = response.getReturnValue();
                  console.log("done");  
                }else {
				console.log("Failed with state: " + state);
			}
         
		});
		$A.enqueueAction(escalateAction);
        
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
		dismissActionPanel.fire();
        $A.get('e.force:refreshView').fire();
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: 'The Case has been escalated successfully',
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