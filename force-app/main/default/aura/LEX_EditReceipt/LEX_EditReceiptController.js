/**
 * @File Name          : LEX_EditReceiptController.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 5/2/2020, 7:41:23 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/4/2020   Jayanta Karmakar     Initial Version
**/
({
	init : function(component, event, helper) {
		helper.fetchReceiptInfo(component, event, helper);
		var today = new Date();
        var tdate = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
        console.log(tdate);
        component.set("v.todaysDate", tdate);
	},
	doAddRelatedInvoice : function(component, event, helper){
		var invLineLst = component.get("v.invoiceLineItems");
		var toDayDate = component.get("v.todaysDate");
        invLineLst.push({"invoiceNo":"","Amount":0.0,"invoiceId":"","invoiceBalAmt":0.0, "AppliedDate":toDayDate});
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
		helper.performUpdate(cmp, event, helper);
	}
})