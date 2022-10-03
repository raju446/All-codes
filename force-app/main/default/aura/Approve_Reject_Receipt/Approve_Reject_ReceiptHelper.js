/**
 * @description       : 
 * @author            : Jayanta Karmakar
 * @group             : 
 * @last modified on  : 02-16-2021
 * @last modified by  : Jayanta Karmakar
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   01-09-2021   Jayanta Karmakar   Initial Version
**/
({
    acceptOrRejectReceipt : function(component, event, helper, approvalAction,payeName,rejectionReason) {
        var action = component.get("c.approveOrRejectReceipt");
        component.set("v.Spinner",true);
        action.setParams({
            recId : component.get("v.recordId"),
            act : approvalAction,
            cmnt : rejectionReason,
            payeeName : payeName,
            paymentStatus : component.get("v.selectedPicklistVal"),
            rctAmount : component.get("v.amnt"),
            originalAmount : component.get("v.originalAmnt")
        });
        action.setCallback(this, $A.getCallback(function(response) {
            var response = response.getReturnValue();
            component.set("v.Spinner",false);
            console.log(response);
            if(response.isSuccess){
                helper.showToast('success','Success',response.msg,'dismissible');
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
            } else {
                helper.showToast('error','Error', response.msg ,'dismissible');
            }
        }));
        $A.enqueueAction(action); 
    },
    
    validateForm: function(component, event, helper){
        if(! component.get('v.selectedPicklistVal') || ! component.get('v.originalAmnt')){
            helper.showToast('error','Error','Payment Status and Amount are Mandatory','dismissible');
            return false;
        } else {
            return true;
        }
    },
    
    showToast: function(type, title, message, toastMode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message,
            "mode" : toastMode
        });
        toastEvent.fire(); 
    }
})