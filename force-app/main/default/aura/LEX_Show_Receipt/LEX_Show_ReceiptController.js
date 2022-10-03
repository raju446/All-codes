/**
 * @File Name          : LEX_Show_ReceiptController.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 3/4/2020, 2:32:01 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/4/2020   Jayanta Karmakar     Initial Version
**/
({
	doAction : function(component, event, helper) {
        var args = event.getParam("arguments");
        component.set("v.dynamicName", 'Push to Oracle');
        component.set("v.selectedEntityId", args.param1);
        component.set("v.entitySiteId", args.siteId);
        component.set("v.selectedEntityName", args.param3);

		helper.fetcholdData(component, event, helper, args.param1);
	},
    refetchRecord : function(component, event, helper) { 
    	helper.fetcholdData(component, event, helper, component.get("v.selectedEntityId"));
    },
    onSubmitClick : function(component, event, helper) {
        var selectedIndex = event.getSource().get("v.name");
        var receiptWrapper = [];
        receiptWrapper.push(component.get("v.listReceiptsWrapper")[selectedIndex]);
        if(component.get("v.dynamicName") == 'Submit To Finance')
       		helper.submitRecForApproval(component, event, helper, receiptWrapper);
        else
            helper.pushReceiptToOracle(component, event, helper, receiptWrapper[0].receiptRec.Id, true);
    },
    onEditReceiptRec : function(component, event, helper) {
        var currentIndex = event.getSource().get("v.name");
        var receiptRecords = component.get("v.listReceiptsWrapper");
        var childReceiptCmp = component.find("receiptCreateComp");
        childReceiptCmp.initReceipt(component.get("v.selectedEntityId"), component.get("v.entitySiteId"), receiptRecords[currentIndex].listrelatedInvoices, receiptRecords[currentIndex].receiptRec);
        
    }
})