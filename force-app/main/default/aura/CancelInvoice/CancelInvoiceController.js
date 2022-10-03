({
	init : function(component, event, helper) 
    {
       var action = component.get("c.cancelInvoice");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, $A.getCallback(function(response) {
            var response = response.getReturnValue();
            console.log(response);
            if(response.isCancelled){
                helper.showToast('success','Success',response.message,'dismissible');
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
            } else {
                helper.showToast('error','Error', response.message ,'dismissible');
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        }));
        $A.enqueueAction(action); 
        
	}
})