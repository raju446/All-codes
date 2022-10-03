({
	onEntityChange : function(component, event, helper) {
        if(component.get('v.selectedLookUpRecord').Id === undefined){
            component.set('v.showInvoiceEntitySelection', false);
            component.set('v.receiptLst', null);
            component.set('v.selectedReceipt', {});
            component.set('v.selectedEntityId', '');
        } else {
            component.set("v.selectedEntityId", component.get('v.selectedLookUpRecord').Id);
            helper.fetchOpenReceipts(component, event, helper);
        }
    },
    invoiceEntityChange : function(component, event, helper) {
        if(component.get('v.selectedInvoiceEntityRecord') === undefined || component.get('v.selectedInvoiceEntityRecord') == null){
                        
        } else {
            component.set("v.selectedInvoiceEntityId", component.get('v.selectedInvoiceEntityRecord').Id);
            helper.fetchOpenInvoices(component, event, helper);
        }
    },
    receiptSelection: function(component, event) {
        var selected = event.getSource().get("v.text");
        var receiptLst = component.get('v.receiptLst');
        var selectedRcpt;
        
        if(component.get('v.selectedReceiptId') != selected && component.get('v.selectedReceiptId') != ''){
            var childCmp = component.find("customerInvEntity")
 			childCmp.clearValues();        	
            component.set('v.selectedInvoiceEntityId', null);
            component.set('v.applicationLst', null);
            component.set('v.newApplicationLst', null);
        }
        
        for(var i = 0; i < receiptLst.length; i++){
            if(receiptLst[i].Id == selected){
                selectedRcpt = receiptLst[i];
                component.set('v.selectedReceiptId', selected);
                component.set('v.selectedReceipt', selectedRcpt);
                component.set('v.remaningAmnt', component.get('v.selectedReceipt').Remaning_Amount__c);
                component.set('v.showInvoiceEntitySelection', true);
                
                component.set('v.invoiceCustomerFilter', 'AND Oracle_Site_Id__c =\'' + receiptLst[i].Entity__r.Oracle_Site_Id__c+ '\'');
                break;
            }
        }
    },
    invoiceSelection: function(component, event, helper){
        var remaningAmnt = component.get('v.selectedReceipt').Remaning_Amount__c;
        var totalAppliedAmnt = 0;
        
        var appLst = component.get('v.applicationLst');
        
        for(var i = 0; i < appLst.length; i++){
            if(appLst[i].isSelected){
                console.log(appLst[i]);
                totalAppliedAmnt += appLst[i].appliedAmnt;
            }
        }
        console.log('remaningAmnt==>>', remaningAmnt);  
		console.log('totalAppliedAmnt==>>', totalAppliedAmnt); 
        
        if(totalAppliedAmnt > remaningAmnt){
            alert('Applied amount is more than receipt remaning amount.');
            var selectedInv = event.getSource().get("v.text");
            
            for(var i = 0; i < appLst.length; i++){
                if(selectedInv == appLst[i].invoiceId){
                    appLst[i].isSelected = false;
                }
            }
            component.set('v.applicationLst', appLst);
        }else if(totalAppliedAmnt < remaningAmnt){
            component.set('v.remaningAmnt', (remaningAmnt - totalAppliedAmnt).toFixed(2));
        }
        var createAppLst = [];
        for(var i = 0; i < appLst.length; i++){
            if(appLst[i].isSelected){
                createAppLst.push(appLst[i]);
            }
        }
        console.log(createAppLst);
        component.set('v.newApplicationLst', createAppLst);
        
    },
    saveApplications : function(component, event, helper){
        var applicationLst = component.get('v.applicationLst');
        var createApplicationLst = [];
        for(var i = 0; i < applicationLst.length; i++){
            if(applicationLst[i].isSelected){
                createApplicationLst.push(applicationLst[i]);
            }
        }
        console.log('==>>', createApplicationLst);
        var action = component.get("c.createApplicationRecords");
        action.setParams({ appLst : JSON.stringify(createApplicationLst)});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(response.getReturnValue());
            var response = response.getReturnValue();
            var successMsg = response.message;
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": successMsg,
                    duration: '1000'
                });
                toastEvent.fire();
                var childCmp = component.find("customerInvEntity");
 				childCmp.clearValues();  
                var childCmp2 = component.find("customer");
                childCmp2.clearValues(); 
            }
            
        });
        $A.enqueueAction(action);
    }
})