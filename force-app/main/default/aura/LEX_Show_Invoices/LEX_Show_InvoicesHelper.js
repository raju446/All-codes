/**
 * @File Name          : LEX_Show_InvoicesHelper.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 3/5/2020, 11:34:57 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/5/2020   Jayanta Karmakar     Initial Version
**/
({
	fetcholdData : function(component, event, helper, selectedAccId){
        // get select account receipts 
        var action = component.get("c.getRelatedInvoice");
        //alert(args.param1);
        // set parameter
        action.setParams({
            "selectedAccountId": selectedAccId
        });
        component.set("v.Spinner", true);
        //alert('fetch old data');
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.Spinner", false);
            if (state === "SUCCESS") {
                var records = [];
                var responseRecords = response.getReturnValue();
                
                if(responseRecords.length > 0) {
                    for(var ind = 0 ; ind< responseRecords.length ; ind++){
                        //cepRecords.push(response.getReturnValue()[ind]);
                        records.push(response.getReturnValue()[ind]);
                    }
                    //
                    component.set("v.listInvoiceWrapper", records);
                    //component.set("v.showReceiptTable", true);
                    
                }  else {
                    component.set("v.listInvoiceWrapper", records);
                    //component.set("v.showReceiptTable", false);
                }
            } else {
                console.log("Failed with state: " + state);
                console.log("Failed with state: " + response.getReturnValue());
                helper.showTostMSG(component, event, helper, 'Error', response.getReturnValue(),"dismissible");
            }
        });
        
        $A.enqueueAction(action);
    },
    submitRecForApproval : function(component, event, helper, invoiceWrapperVal) {
        var action = component.get("c.submitRecordsForApproval");
        // set parameter
        action.setParams({
            "listReceiptWrapper": null,
            "listInvoiceWrapper": invoiceWrapperVal 
        });
        
        component.set("v.Spinner", true);
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.Spinner", false);
            if (state === "SUCCESS" && response.getReturnValue() == "Success") {
                var records = [];
                component.set("v.listInvoiceWrapper", records);  
                helper.fetcholdData(component, event, helper, component.get("v.selectedEntityId"));
                
                helper.showTostMSG(component, event, helper, 'Success', 'Selected records are submitted successfully for approval',"dismissible");
            } else {
                console.log("Failed with state: " + state);
                console.log(state);
                helper.showTostMSG(component, event, helper, 'Error', state,"dismissible");
            }
        });
        // component.set("v.Spinner", false);
        $A.enqueueAction(action);
    },
    
    pushReceiptToOracle : function(component, event, helper, recId, isReceiptVal) {
        //  alert(recId);
        var action = component.get("c.pushReciptToERP");
        // set parameter
        action.setParams({
            "recordId": recId,
            "isReceipt" : isReceiptVal
        });
        
        component.set("v.Spinner", true);
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            console.log(response.getReturnValue());
            component.set("v.Spinner", false);
            if (state === "SUCCESS" && response.getReturnValue() == "SUCCESS") {
                var records = [];
                component.set("v.listInvoiceWrapper", records);
                helper.fetcholdData(component, event, helper, component.get("v.selectedEntityId"));
                if(!component.get("v.isRecPushed"))
                    component.set("v.isRecPushed", true);  
                else
                    component.set("v.isRecPushed", false);
                //component.set('v.isOpenSFAModal',false);
                helper.showTostMSG(component, event, helper, 'Success', 'Selected record is successfully pushed to oracle',"dismissible");
            } else {
                console.log("Failed with state: " + state);
                console.log(state);
                helper.showTostMSG(component, event, helper, 'Error', response.getReturnValue(),"dismissible");
            }
        });
        // component.set("v.Spinner", false);
        $A.enqueueAction(action);
    },
    showTostMSG : function(component, event, helper, isSuccess, msg, msgMode) {
        var toastEvent = $A.get("e.force:showToast");
        if(isSuccess == 'Success') {
            toastEvent.setParams({
                "mode" : "sticky",
                "title": "Success!",
                "type" : "success",
                "message": msg,
                "mode" : msgMode
            });
        } else {
            toastEvent.setParams({
                "mode" : "sticky",
                "title": "Error!",
                "type" : "error",
                "message": msg,
                "mode" : msgMode
            });
            
        }//end else- if
        toastEvent.fire();
    }
})