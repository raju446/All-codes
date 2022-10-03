({
    getHasAccsess: function(component, event, helper) {
        var caseId = component.get("v.recordId");
        var action = component.get("c.CloseCaseAccsess"); // method in the apex class
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
    getQucikText: function(component, event, helper) {
        var action = component.get("c.fetchQuickText");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" && response.getReturnValue() != null) {
                component.set("v.options", response.getReturnValue());
                
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    getapexmethod: function(component, event, helper) {
        var caseId = component.get("v.recordId");
        var Resolution = component.get("v.caseResolution");
        
        console.log(Resolution);
        console.log(caseId);
        
        if (Resolution != null && Resolution !=''){
            var closeAction = component.get("c.closeCase"); 
            console.log("hi");
            
            
            closeAction.setParams({
                CaseId : caseId,
                reason : Resolution
            });
            closeAction.setCallback(this, function(response) {
                var state = response.getState();
                console.log(state);
                console.log("hi");
                if (component.isValid() && state === "SUCCESS") {
                    var conts = response.getReturnValue();
                    if(conts == 'The Case has been Closed'){
                        helper.showToast(component,
                                         event,
                                         helper,
                                         conts,
                                         "success");
                    }else{
                        helper.showToast(component,
                                         event,
                                         helper,
                                         conts,
                                         "error");
                    }
                    console.log(conts);  
                }else {
                    console.log("Failed with state: " + state);
                }
                
            });
            $A.enqueueAction( closeAction);
            
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
            /*$A.get('e.force:refreshView').fire();
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Success Message',
                message: 'The Case has been closed successfully',
                messageTemplate: 'Record {0} created! See it {1}!',
                duration:' 5000',
                key: 'info_alt',
                type: 'success',
                mode: 'pester'
            });
            toastEvent.fire();*/
        } 
    },
    
    showToast: function(component, event, helper, msg, type) {
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: "dismissible",
            message: msg,
            type: type
        });
        toastEvent.fire();
    }
    
})