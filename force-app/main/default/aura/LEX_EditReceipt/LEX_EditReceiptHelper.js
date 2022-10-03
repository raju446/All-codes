/**
 * @File Name          : LEX_EditReceiptHelper.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 5/2/2020, 8:29:37 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/4/2020   Jayanta Karmakar     Initial Version
**/
({
	fetchReceiptInfo : function(component, event, helper) {
		var action = component.get("c.fetchReceiptDetails");
		helper.showSpinner(component);
		action.setParams({
			receiptId : component.get('v.recordId')
		});
		action.setCallback(this, $A.getCallback(function(response) {
			var response = response.getReturnValue();
			component.set("v.receiptObj", response);
			console.log(response);
			var lines = [];
			if(response.Related_Invoices__r){
				for(var i=0;i<response.Related_Invoices__r.length;i++){
					var lineItem = {};
					lineItem.invoiceNo = response.Related_Invoices__r[i].Invoice__r.Source_Invoice_Id__c;
					lineItem.Amount = response.Related_Invoices__r[i].Amount_Applied__c;
					lineItem.invoiceId = response.Related_Invoices__r[i].Invoice__c;
					lineItem.invoiceBalAmt = 0.0;
					lineItem.AppliedDate = response.Related_Invoices__r[i].Applied_Date__c;
					lines.push(lineItem);
				}
			}
			helper.hideSpinner(component);
			console.log(lines);
				component.set("v.invoiceLineItems", lines);
		}));
		$A.enqueueAction(action);
	},
	performUpdate : function(component, event, helper) {
		if(this.validateRecords(component)){
			var v = component.get('v.invoiceLineItems');
			console.log('====line items====='+v);
			console.log(JSON.stringify(v))
			var action = component.get("c.upsertRelatedInvoiceReceipt");
			helper.showSpinner(component);
			action.setParams({
				receiptObjct : component.get('v.receiptObj'),
				relatedListString : JSON.stringify(v)
			});
			action.setCallback(this, $A.getCallback(function(response) {
				var response = response.getReturnValue();
				console.log(response);
				helper.hideSpinner(component);
				if(response == 'SUCCESS'){
					$A.get("e.force:closeQuickAction").fire();
				} else {
					this.showToast('error','Error',response);
				}
			}));
			$A.enqueueAction(action);
		}
	},
	showToast: function(type, title, message) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": title,
			"type": type,
			"message": message
		});
		toastEvent.fire();
	},
	showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
	},
	validateRecords: function (cmp) {
		let isValid = true;
		let receiptRec = cmp.get('v.receiptObj');
		var allRecs = cmp.get("v.invoiceLineItems");
		let totalAmnt = 0;
		for(let i=0;i<allRecs.length;i++){
			totalAmnt +=  Number(allRecs[i].Amount);
		}
		
		if(totalAmnt > receiptRec.Amount__c){
			isValid = false;
			this.showToast('error','Error','Total Applied amount can not be more than Receipt Amount.');
		}
		
		return isValid;
	}
})