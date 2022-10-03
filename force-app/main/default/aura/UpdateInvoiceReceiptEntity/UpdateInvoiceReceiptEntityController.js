({
    doInit : function(component, event, helper) {
        
    },
    
	updateInvoiceReceipt : function(component, event, helper) {
		var action = component.get("c.updateInvoiceReceiptEntity");
        action.setParams({ objectType : component.get('v.selectedObject') ,
                          invoiceReceiptId : component.get('v.invoiceReceiptId'),
                          entityToUpdate : component.get('v.entityToUpdate')})
                          //updatedInvoiceReceiptWrapList : component.get('v.invRctWrapper');
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response.getReturnValue().wrapper==>>', response.getReturnValue().wrapper);
            var updatedWrapLst = component.get('v.invRctWrapper');
            if(response.getReturnValue().wrapper != null){
                updatedWrapLst.push(response.getReturnValue().wrapper);
                component.set('v.invRctWrapper', updatedWrapLst);
            }
            
            if (state === "SUCCESS") {
                var response = response.getReturnValue().message;
                //alert(response);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": response,
                    duration: '1000'
                });
                toastEvent.fire();
                
            }
            
            component.set('v.invoiceReceiptId', '');
            component.set('v.entityToUpdate', '');
            
        });
        $A.enqueueAction(action);
	},
    fetchSelectedObjectDetails: function(component, event, helper){
        var action = component.get("c.getSelectedObjectDetails");
        action.setParams({ objectType : component.get('v.selectedObject') ,
                          invoiceReceiptId : component.get('v.invoiceReceiptId')})
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if(response.getReturnValue().message == 'Success'){
                component.set('v.showInvoiceReceiptDetail', true);
                component.set('v.entityToUpdate','');
                if(response.getReturnValue().wrapper != null){
                    component.set('v.invoiceReceiptDetails', response.getReturnValue().wrapper);
                }
            }else{
                alert(response.getReturnValue().message);
            }
        });
        
        $A.enqueueAction(action);
    },
    fetchEntityDetails: function(component, event, helper){
        var action = component.get("c.fetchAccountDetails");
        action.setParams({ entityIdToUpdate : component.get('v.entityToUpdate')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(response.getReturnValue().message == 'Success'){
                component.set('v.updateEntityName', response.getReturnValue().wrapper.newEntityId);
                component.set('v.reassignButtonEnabled', true);
                
            }else{
                alert(response.getReturnValue().message);
                component.set('v.reassignButtonEnabled', false);
            }
        });
        $A.enqueueAction(action);
    },
    refreshScreen: function(component, event, helper){
        helper.refreshScreen(component, event, helper);
    },
    reassignEntity: function(component, event, helper){
        var action = component.get("c.updateInvoiceReceiptEntity");
        console.log(component.get('v.invoiceReceiptDetails').invoiceReceiptName);
        console.log(component.get('v.invoiceReceiptDetails').oldEntityId);
        action.setParams({ objectType : component.get('v.selectedObject') ,
                          invoiceReceiptId : component.get('v.invoiceReceiptId'),
                          entityToUpdate : component.get('v.entityToUpdate'),
                          invoiceReceiptName : component.get('v.invoiceReceiptDetails').invoiceReceiptName,
                          newEntityName : component.get('v.updateEntityName'),
                          oldEntityName : component.get('v.invoiceReceiptDetails').oldEntityId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response.getReturnValue().wrapper==>>', response.getReturnValue().wrapper);
            var updatedWrapLst = component.get('v.invRctWrapper');
            if(response.getReturnValue().wrapper != null){
                updatedWrapLst.push(response.getReturnValue().wrapper);
                component.set('v.invRctWrapper', updatedWrapLst);
            }
            
            if (state === "SUCCESS") {
                var response = response.getReturnValue().message;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": response,
                    duration: '1000'
                });
                toastEvent.fire();
                helper.refreshScreen(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    }
})