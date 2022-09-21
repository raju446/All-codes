({
 myAction : function(component, event, helper) 
    {
        var ConList = component.get("c.getRelatedList");
        ConList.setParams
        ({
            recordId: component.get("v.recordId")
        });
        
        ConList.setCallback(this, function(data) 
   {
        component.set("v.OpportunityList", data.getReturnValue());
        });
        
        $A.enqueueAction(ConList);
 },
   doPerform:function(component,event,helper){
        var action=component.get('c.createOpportunity');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            }
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
            title : 'Success',
            message:'Opportunity Record is Rreated',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
    });
        toastEvent.fire();
     });
        $A.enqueueAction(action)
         $A.get('e.force:refreshView').fire();
   }
})