/**
 * @description       : 
 * @author            : Jayanta Karmakar
 * @group             : 
 * @last modified on  : 02-20-2021
 * @last modified by  : Jayanta Karmakar
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   01-05-2021   Jayanta Karmakar   Initial Version
**/
({
    init : function(component, event, helper) {
        var action = component.get("c.returnProcessInstance");
        action.setParams({
            receiptId : component.get("v.recordId")
        });
        action.setCallback(this, $A.getCallback(function(response) {
            var response = response.getReturnValue();
            console.log(response.isSuccess);
            if(! response.isSuccess){
                helper.showToast('error','Error','No active approval process found.','dismissible');
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            } else {
                component.set('v.picklistVals',response.paymentStatusVals);
                component.set('v.selectedPicklistVal',response.selectedPaymentStatus);
                component.set('v.amnt',response.receiptAmount);
                component.set('v.originalAmnt',response.originalAmount);
            }
        }));
        $A.enqueueAction(action); 
    },
    
    acceptReceipt: function (component, event, helper) {
        if(helper.validateForm(component, event, helper)){
            helper.acceptOrRejectReceipt(component, event, helper,'Approve',component.get("v.payeesName"),'Receipt Approved');    
        }
    },
    
    rejectReceipt: function (component, event, helper) {
        let isPayeeMandatory = component.get("v.selectedPicklistVal") === 'Payment Received from Incorrect Source' && $A.util.isEmpty(component.get("v.payeesName")) ? false : true;
        if(component.get("v.rejectionMsg") && helper.validateForm(component, event, helper) && isPayeeMandatory){
            helper.acceptOrRejectReceipt(component, event, helper,'Reject',component.get("v.payeesName"),component.get("v.rejectionMsg"));
        } else if(!isPayeeMandatory){
            helper.showToast('error','Error','Payee Name is mandatory','dismissible');
        } else {
            helper.showToast('error','Error','Rejection Comment is Mandatory','dismissible');
        }
        
    }
})