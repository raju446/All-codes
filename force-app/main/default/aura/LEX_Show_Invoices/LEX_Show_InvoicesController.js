/**
 * @File Name          : LEX_Show_InvoicesController.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 5/17/2020, 6:58:59 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/2/2020   Jayanta Karmakar     Initial Version
**/
({
	doAction : function(component, event, helper) {
        var args = event.getParam("arguments");
        component.set("v.dynamicName", args.param2);
        component.set("v.selectedEntityId", args.param1);
        component.set("v.selectedEntityName", args.param3);
        component.set("v.entitySiteId", args.siteId);
		helper.fetcholdData(component, event, helper, args.param1);
	},
    
    onSubmitClick : function(component, event, helper) {
        var selectedIndex = event.getSource().get("v.name");
        var invoiceWrapper = [];
        invoiceWrapper.push(component.get("v.listInvoiceWrapper")[selectedIndex]);
        if(component.get("v.dynamicName") == 'Submit To Finance')
       		helper.submitRecForApproval(component, event, helper, invoiceWrapper);
        else
            helper.pushReceiptToOracle(component, event, helper, invoiceWrapper[0].invoiceRec.Id, false);
    },
    onShowInvoiceLine : function(component, event, helper) {
        var selectedIndex = event.getSource().get("v.name");
        var btns = component.find("shInl");
        console.log(btns);
        console.log(selectedIndex);
        console.log(Array.isArray(btns));
        if(Array.isArray(btns)){
            console.log(btns[selectedIndex]);
            if(btns[selectedIndex].get("v.iconName") == "utility:chevronright"){
                btns[selectedIndex].set("v.iconName", "utility:chevrondown");
            } else {
                btns[selectedIndex].set("v.iconName", "utility:chevronright");
            }
        } else {
            if(btns.get("v.iconName") == "utility:chevronright"){
                btns.set("v.iconName", "utility:chevrondown");
            } else {
                btns.set("v.iconName", "utility:chevronright");
            }
        }
        
        if(component.get("v.selectedInvoice") == selectedIndex) {
            component.set("v.selectedInvoice", -1);
        } else {
            component.set("v.selectedInvoice", selectedIndex);
        } 
    },
    onEditInvoiceRec : function(component, event, helper) {
        var currentIndex = event.getSource().get("v.name");
        var invoiceRecords = component.get("v.listInvoiceWrapper");
        var childInvoiceCmp = component.find("invoiceCreateComp");
 		childInvoiceCmp.initInvoice(component.get("v.selectedEntityId"), component.get("v.entitySiteId"), invoiceRecords[currentIndex].invoiceRec, invoiceRecords[currentIndex].listInvoiceLineRec, invoiceRecords[currentIndex].listRelatedReceiptClass, false);
    },
    refetchRecord : function(component, event, helper) {
        helper.fetcholdData(component, event, helper, component.get("v.selectedEntityId"));
    },
    viewInvoiceLineDetail : function(component, event, helper){
        var lineIndex = event.getSource().get("v.name");
        console.log(lineIndex);
        var invoiceRecords = component.get("v.listInvoiceWrapper");
        var indexes = lineIndex.split('-');
        console.log(indexes);
        var childInvoiceLineCmp = component.find("invoiceLineComp");
        console.log(invoiceRecords);

        console.log(invoiceRecords[indexes[0]].listInvoiceLineRec[indexes[1]].Id);
        childInvoiceLineCmp.initInvoiceLine(invoiceRecords[indexes[0]].listInvoiceLineRec[indexes[1]].Id);
    }
})