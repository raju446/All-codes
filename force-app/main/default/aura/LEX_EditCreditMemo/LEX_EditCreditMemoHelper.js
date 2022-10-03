({
	fetchInvoiceInfo : function(component, event, helper) {
		var action = component.get("c.fetchInvoiceDetails");
		helper.showSpinner(component);
		action.setParams({
			invoiceId : component.get('v.recordId')
		});
		action.setCallback(this, $A.getCallback(function(response) {
			var response = response.getReturnValue();
			component.set("v.invoiceObj", response.objInvoice);
			var lines = [];
			//alert(response.listRelatedInvRecClass.length);
			console.log(response);
            if(response.listRelatedInvRecClass){
                if(response.listRelatedInvRecClass.length == 0) {
                    //lines.push({"invoiceNo":"","Amount":null,"invoiceId":"","invoiceBalAmt":0.0,"lineItemId":""});
				}				
                for(var i=0;i<response.listRelatedInvRecClass.length;i++){
					var lineItem = {};
					lineItem.invoiceNo = response.listRelatedInvRecClass[i].invoiceNo;
					lineItem.Amount = response.listRelatedInvRecClass[i].Amount < 0 ? response.listRelatedInvRecClass[i].Amount*-1 : response.listRelatedInvRecClass[i].Amount;
					lineItem.invoiceId = response.listRelatedInvRecClass[i].invoiceId;
					lineItem.invoiceBalAmt = response.listRelatedInvRecClass[i].invoiceBalAmt;
					lineItem.lineItemId = response.listRelatedInvRecClass[i].lineItemId;
					lineItem.LineItem = response.listRelatedInvRecClass[i].LineItem;
					lineItem.invTaxAmount = response.listRelatedInvRecClass[i].invTaxAmount;
                    lineItem.lineItemGLDate = response.listRelatedInvRecClass[i].lineItemGLDate;
					lines.push(lineItem);
				}
            } 
			helper.hideSpinner(component);
			console.log(lines);
			component.set("v.invoiceLineItems", lines);
		}));
		$A.enqueueAction(action);
	},
    performInsert : function(component, event, helper) {
		if(this.validateRecords(component)){
			var invoiceLineItemsDetails = component.get('v.invoiceLineItems');
			var action = component.get("c.upsertInvoice");
			helper.showSpinner(component);
			action.setParams({
				objInvoice : component.get('v.invoiceObj'),
				listRelatedInvRecClass : JSON.stringify(invoiceLineItemsDetails)
			});
			action.setCallback(this, $A.getCallback(function(response) {
				var response = response.getReturnValue();
				console.log(response);
				helper.hideSpinner(component);
				if(response == 'SUCCESS'){
					//$A.get("e.force:closeQuickAction").fire();
                    $A.get("e.force:closeQuickAction").fire();
					//component.set('v.showPushToOracle', true);
					//this.fetchInvoiceInfo(component, event, helper);
				} else {
					this.showToast('error','Error',response);
				}
			}));
			$A.enqueueAction(action);
		}
	},
	pushToOracle : function(component, event, helper){
		var invoiceLineItemsDetails = component.get('v.invoiceLineItems');
		var action = component.get("c.pushCMLineToOracle");
		console.log(invoiceLineItemsDetails);
		helper.showSpinner(component);
		action.setParams({
			listRelatedInvRecClass : JSON.stringify(invoiceLineItemsDetails)
		});
		action.setCallback(this, $A.getCallback(function(response) {
			console.log(response.getReturnValue());
			var res = response.getReturnValue();
			helper.hideSpinner(component);
			if(res == 'SUCCESS'){
				$A.get("e.force:closeQuickAction").fire();
			} else {
				this.showToast('error','Error',res);
			}
		}));
		$A.enqueueAction(action);
	},
    validateRecords: function (cmp) {
		let isValid = true;
		let invoiceRec = cmp.get('v.invoiceObj');
		var allRecs = cmp.get("v.invoiceLineItems");
		let totalAmnt = 0;
		
		/*for(let i=0;i<allRecs.length;i++){
			totalAmnt +=  Number(allRecs[i].Amount);
		}
        
		if(totalAmnt > invoiceRec.Invoice_Balance__c && invoiceRec.Invoice_Balance__c < 0){
			isValid = false;
			this.showToast('error','Error','Total Applied amount can not be more than Credit Memo Amount.');
		}
		if(totalAmnt < invoiceRec.Invoice_Balance__c && invoiceRec.Invoice_Balance__c > 0){
			isValid = false;
			this.showToast('error','Error','Total Applied amount can not be more than Credit Memo Amount.');
		}*/

		for(let i=0;i<allRecs.length;i++){
			totalAmnt +=  Number(allRecs[i].Amount);

			console.log(' invNo '+allRecs[i].invoiceNo);
			console.log(' invNo '+allRecs[i].Amount);
			console.log('==>>', allRecs[i].invoiceBalAmt);	
            if(allRecs[i].invoiceBalAmt > 0){
                if( Number(allRecs[i].Amount) == 0 ){
                    this.showToast('error','Error','Please enter the amount to update.');
                    isValid = false;
                }else if( allRecs[i].invoiceNo == null || allRecs[i].invoiceNo == "" ){
                    this.showToast('error','Error','Please select the Invoice to proceed.');
                    isValid = false;
                }else if(Number(allRecs[i].Amount) < 0){
                    this.showToast('error','Error','Please enter only positive values.');
                    isValid = false;
                }else if(Number(allRecs[i].Amount) > Number(allRecs[i].invoiceBalAmt)){
                    this.showToast('error','Error','Applied amount greater than invoice balance.');
                    isValid = false;
                }
            }
			

			console.log(JSON.stringify(invoiceRec));

			/*if(invoiceRec.Total_Taxable_Amount__c != 0 && invoiceRec.Invoice_Balance__c != 0){
				var taxAmt = (Number(allRecs[i].Amount)*(5/100));
				totalAmnt += taxAmt; 
			}*/

		}
		console.log('totalAmnt '+totalAmnt);
		totalAmnt = totalAmnt*-1;

		if( isValid && totalAmnt < invoiceRec.Invoice_Balance__c){
			isValid = false;
			this.showToast('error','Error','Total Applied amount can not be more than Credit Memo Amount.');
		}

		
		return isValid;
	},
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
	},
    showToast: function(type, title, message) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": title,
			"type": type,
			"message": message
		});
		toastEvent.fire();
	}
})