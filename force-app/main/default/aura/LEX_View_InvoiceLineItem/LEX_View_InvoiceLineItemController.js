/**
 * @File Name          : LEX_View_InvoiceLineItemController.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 3/3/2020, 9:44:30 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/2/2020   Jayanta Karmakar     Initial Version
**/
({
    closeModal : function(component, event, helper) {
        component.set("v.showModal", false);
    },
    doAction: function (component, event, helper){
        var args = event.getParam("arguments");
        component.set("v.InvoiceLineItemId", args.invLineId);
        component.set("v.showModal", true);
    }
})