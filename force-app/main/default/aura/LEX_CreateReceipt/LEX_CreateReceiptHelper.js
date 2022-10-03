/**
 * @File Name          : LEX_CreateReceiptHelper.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 7/1/2020, 3:35:04 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/1/2020   Jayanta Karmakar     Initial Version
**/
({
    fetchPicklistValues : function(component, fieldAPIName, nullRequired) {
		var action = component.get("c.fetchReceiptPicklistVal");
        action.setParams({
            'fieldAPIname': fieldAPIName,
            'nullRequired': nullRequired 
        });
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                if(fieldAPIName == "Payment_Method__c"){
                    component.set("v.PaymentMethodPicklist", response.getReturnValue());
                } else {
                    component.set("v.PaymentCurrencyPicklist", response.getReturnValue());
                }    
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
    },
    addInvoiceLine : function(component, fieldAPIName, nullRequired){
        var invLineLst = component.get("v.invoiceLineItems");
        var toDayDate = component.get("v.todaysDate");
        invLineLst.push({"invoiceNo":"","Amount":0.0,"invoiceId":"","invoiceBalAmt":0.0,"AppliedDate":toDayDate,"invDate":""});
        console.log(JSON.stringify(invLineLst));
        component.set("v.invoiceLineItems", invLineLst);
    },
    upsertReceipt : function(component, event, helper){
        component.set("v.Spinner",true);
        var rec = component.get("v.newReceiptObject");
        console.log(JSON.stringify(rec));
        var entityId = component.get("v.entityId");
        rec.Entity__c = entityId;
        rec.Is_Created_Manually__c = true;
        var lines = component.get("v.invoiceLineItems");
        console.log('===========');
        console.log(lines);
            var action = component.get("c.upsertReceiptAndRelatedInvoices");
            action.setParams({
                'recRecord': rec,
                'lineItemsBody': lines,
                'attachmentFiles' : component.get('v.uploadedFiles') 
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                component.set("v.Spinner",false);
                if (state === "SUCCESS") {
                    console.log(response.getReturnValue());  
                    if(response.getReturnValue() == "Success"){
                        component.set("v.newReceiptObject", "{ 'sobjectType': 'Receipt__c'}");
                        component.set("v.invoiceLineItems", "object[]");
                        component.set("v.isReview", false);
                        component.set("v.ShowReceiptCreateModal", false);
                        if(!component.get("v.isRecordSaved"))
                        	component.set("v.isRecordSaved", true);
                        else 
                            component.set("v.isRecordSaved", false);
                        
                        //showToast('Success','Success',response.getReturnValue());
                    } else {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error",
                            "type": "Error",
                            "message": response.getReturnValue()
                        });
                        toastEvent.fire();
                        }
                } else {
                    console.log("Failed with state: " + state);
                    //showToast(helper,'Error','Error',"Failed with state: " + state);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "type": "Error",
                        "message": "Failed with state: " + state
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
            component.set("v.disableSave", false);
    },
    toggleReview: function (component, event, helper) {
        var isReview = component.get("v.isReview");
        isReview = !isReview;
        component.set("v.isReview", isReview);
    },
    showToast: function(type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode" : "sticky",
            "title": title,
            "type": type,
            "message": message
        });
        toastEvent.fire();
    }, 
    validateReceipt : function(component, event, helper){
        var rec = component.get("v.newReceiptObject");
        var lines = component.get("v.invoiceLineItems");
        console.log(JSON.stringify(rec));
        console.log(JSON.stringify(lines)); 
        debugger;
        var isValid = true;
        if(! rec.Payment_Method__c){
            var v = component.find("payMethod");
            v.showHelpMessageIfInvalid(); 
            isValid = false;
        }
        if(rec.Payment_Method__c == 'Card' || rec.Payment_Method__c == 'Credit Card'){
            if(rec.Credit_Card_F_L_Four_Digits__c == '' || rec.Credit_Card_F_L_Four_Digits__c == null){
                helper.showToast("error","Error","Credit Card Number can not be left blank.");
                isValid = false;    
            } 
            if(rec.Authorization_Code__c == '' || rec.Authorization_Code__c == null){
                helper.showToast("error","Error","Authorization Code can not be left blank.");
                isValid = false;    
            }
        }
        if(! rec.Transaction_Reference__c){
            var v = component.find("transferRef");
            v.showHelpMessageIfInvalid(); 
            isValid = false; 
        }
        if(! rec.Amount__c){
            var v = component.find("RecAmount");
            v.showHelpMessageIfInvalid(); 
            isValid = false;
        }
        if(! rec.Payment_Currency__c){
            var v = component.find("curVal");
            v.showHelpMessageIfInvalid(); 
            isValid = false;
        }
        if(! rec.Receipt_Date__c){           
            var v = component.find("recDate");
            v.showHelpMessageIfInvalid();
            isValid = false;
        }
        if(! rec.GL_Date__c){           
            var v = component.find("glDate");
            v.showHelpMessageIfInvalid();
            isValid = false;
        }
        
        if(lines.length > 0){
          /*  var ipAmounts = component.find("ipAmount");
            console.log(ipAmounts);
            if(Array.isArray(ipAmounts)){
                for(var count =0 ; count < ipAmounts.length; count++){
                    if(! ipAmounts[count].checkValidity()){
                        ipAmounts[count].showHelpMessageIfInvalid();
                        isValid = false;
                    }
                }
            } else {
                if(! ipAmounts.checkValidity()){
                    ipAmounts.showHelpMessageIfInvalid();
                    isValid = false;
                }
            } */

            var totalInvoiceVal = 0;
            for(var i =0; i< lines.length; i++){
                console.log(typeof totalInvoiceVal);
                console.log(typeof lines[i].Amount);
                totalInvoiceVal = totalInvoiceVal + Number(lines[i].Amount);
            }
            console.log(totalInvoiceVal);
            console.log(rec.Amount__c);
            console.log(totalInvoiceVal > rec.Amount__c);
           /* if(totalInvoiceVal != rec.Amount__c){
                helper.showToast("error","Error","Total Applied Invoice Amount should be equal to the Receipt Amount.");
                isValid = false;
            }*/
        }
        //isValid = true;
        return isValid;
    }
})