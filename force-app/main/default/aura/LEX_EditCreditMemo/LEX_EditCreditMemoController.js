({
	init : function(component, event, helper) {
		helper.fetchInvoiceInfo(component, event, helper);
        
	},
    doAddRelatedInvoice : function(component, event, helper){
        var invLineLst = component.get("v.invoiceLineItems");
        invLineLst.push({"invoiceNo":"","Amount":0.0,"invoiceId":"","invoiceBalAmt":0.0,"lineItemId":""});
        console.log(invLineLst);
        component.set("v.invoiceLineItems", invLineLst);
	},
    removeRow: function(component, event, helper) {
        var lineList = component.get("v.invoiceLineItems");
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        lineList.splice(index, 1);
        component.set("v.invoiceLineItems", lineList);
	},
	doUpdate: function (cmp, event, helper) {
		var invoiceLineItemsDetails = cmp.get('v.invoiceLineItems');
        console.log(invoiceLineItemsDetails);
		helper.performInsert(cmp, event, helper);
	},
	pushToOracle: function (cmp, event, helper) {
        console.log('here ');
		helper.pushToOracle(cmp, event, helper);
    },
    handleValueChange : function(component, event, helper){
        var v = component.get('v.invoiceLineItems');        
    }
})