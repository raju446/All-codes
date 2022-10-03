({
	fetchOpenReceipts : function(component, event, helper) {
		console.log(component.get("v.selectedEntityId"));
        var action = component.get("c.getReceiptDetails");
        action.setParams({ entityId : component.get('v.selectedEntityId')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response.getReturnValue().wrapper==>>', response.getReturnValue());
            component.set('v.receiptLst', response.getReturnValue());
        });
        $A.enqueueAction(action);
	},
    fetchOpenInvoices : function(component, event, helper) {
		console.log(component.get("v.selectedInvoiceEntityId"));
        var action = component.get("c.getInvoiceDetails");
        action.setParams({ entityId : component.get('v.selectedInvoiceEntityId'),
                          paymentCurrency : component.get('v.selectedReceipt').Payment_Currency__c,
                          selectedReceiptId : component.get('v.selectedReceiptId')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response.getReturnValue().wrapper==>>', response.getReturnValue());
            component.set('v.applicationLst', response.getReturnValue());
        });
        $A.enqueueAction(action);
	}
})