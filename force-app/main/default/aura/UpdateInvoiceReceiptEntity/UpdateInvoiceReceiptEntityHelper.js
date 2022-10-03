({
    refreshScreen : function(component, event, helper) {
        component.set('v.invoiceReceiptId','');
        component.set('v.entityToUpdate','');
        component.set('v.invoiceReceiptDetails', {});
        component.set('v.showInvoiceReceiptDetail',false);
        component.set('v.updateEntityName','');
        component.set('v.reassignButtonEnabled',false);
    }
})