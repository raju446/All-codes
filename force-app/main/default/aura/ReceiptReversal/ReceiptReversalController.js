/**
 * @File Name          : ReceiptReversalController.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 5/6/2020, 12:30:29 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/30/2020   Jayanta Karmakar     Initial Version
**/
({
	init : function(component, event, helper) {
		let currentRecId = component.get("v.recordId");
		if(currentRecId){
			var action = component.get("c.getReceiptDetails");
			action.setParams({
				'receiptId': currentRecId
			});
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					console.log(response.getReturnValue());
					let receiptObj = response.getReturnValue();
					if(! receiptObj.Journal_Created__c){
						helper.showToast('error','Error','Journals are not created yet.');
						component.set('v.hasError',true);
					} else if(receiptObj.Is_Reversed__c){
						helper.showToast('error','Error','Receipt is already reversed.');
						component.set('v.hasError',true);
					} else {
						component.set('v.hasError',false);
					}
				} else {
					console.log("Failed with state: " + state);
				}
			});
			$A.enqueueAction(action);
		}
	},
	updateReceipt : function(component, event, helper) {
		var action = component.get("c.pushReceiptToOracle");
		component.set('v.Spinner',true);
		action.setParams({
			'receiptId': component.get("v.recordId")
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			component.set('v.Spinner',false);
			if (state === "SUCCESS") {
				console.log(response.getReturnValue());
				let receiptObj = response.getReturnValue();
				if(receiptObj == 'SUCCESS'){
					$A.get("e.force:closeQuickAction").fire();
					helper.showToast('success','Success','Receipt reversed successfully.');
				} else {
					helper.showToast('error','Error',receiptObj);
				}
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
		//$A.get("e.force:closeQuickAction").fire();
	}
})