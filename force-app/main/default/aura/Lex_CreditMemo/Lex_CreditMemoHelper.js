/**
 * @File Name          : Lex_CreditMemoHelper.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 09-06-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/16/2020   Jayanta Karmakar     Initial Version
**/
({
    getUserProfile : function(component, event, helper) {
        var action = component.get("c.getUserName");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.Name", response.getReturnValue());
                if(component.get("v.Name") == 'ADGM Finance Manager')
                    component.set("v.dynamicName", 'Submit To Oracle');
            }
        });
        $A.enqueueAction(action);
    }
    ,
    fetchOldData : function(component, event, helper, recId) {
        console.log('fetchOldData ');
        var action = component.get("c.getSavedCreditMemo");
		// set parameter
        action.setParams({
            'invoiceId' : recId
        });
        component.set("v.Spinner", false);
        action.setCallback(this, function(response) {
			var state = response.getState();
            console.log('-------');
            console.log(response.getReturnValue());
            component.set("v.Spinner", false);
			if (state === "SUCCESS" && response.getReturnValue() != null) {
                var resVal = response.getReturnValue();
                
                component.set("v.onLoadStart", true);
                if(resVal.objInv.Is_Refundable__c != true) {
                    component.set("v.selectedScenario", 'Invoice Not Paid / Partially Paid');
                    component.set("v.showInvoiceSelection", true);
                } else
                    component.set("v.inAmount", resVal.inAmount);
                component.set("v.creditMemo", resVal.objInv);
                
                component.set("v.selectedOU", resVal.objInv.Entity__r.Oracle_Site_Id__c);
                component.set("v.sourceSystem", resVal.objInv.Entity__r.Source_System__c);
                this.setSourceSystemVal(component, event, helper);
                helper.fetchRevenue(component, event, helper,component.get('v.selectedOU'));
                component.set('v.isSourceNotSelected' , false);
                component.set("v.invoiceTypes", resVal.revenueDetail);
                component.set("v.showInvoiceSelectionTable",true );
                component.set("v.selectedLookUpRecord", resVal.selectedEntity);
                component.set("v.selectedInvoiceLookUp", resVal.selectedInvoice);
                component.set("v.invoiceLineItems", resVal.listRelatedInvLine);
                component.set("v.creditMemoLineItem", resVal.listInvoiceLineItem);
                
                component.set("v.onLoadStart", false);
                
                console.log('fetchOldData end');
			} else {
				helper.showToast("error","Error", "Only credit memo invoices can edit.");
			}
		});
       // component.set("v.Spinner", false);
		$A.enqueueAction(action);
        
	},
	fetchPicklistValues : function(component, event, helper, objectAPIName,fieldAPIName, nullRequired) {
		var action = component.get("c.fetchPicklistVal");
        console.log('@@@@@@@@@@@ objectAPIName in helper: ',objectAPIName);
		// set parameter
        action.setParams({
            'objectApi' : objectAPIName,
            'fieldAPIname': fieldAPIName,
            'nullRequired': nullRequired 
        });
        component.set("v.Spinner", false);
        action.setCallback(this, function(response) {
			var state = response.getState();
            component.set("v.Spinner", false);
			if (state === "SUCCESS") {
                //var records = response.getReturnValue();
                console.log('@@@@@@@@@ picklist response.getReturnValue() '+response.getReturnValue());
                if(fieldAPIName == 'Invoice_Type__c') {
                    component.set("v.invoiceTypePicklist", response.getReturnValue());
                } else if(fieldAPIName == 'Currency__c') {
                    component.set("v.PaymentCurrencyPicklist", response.getReturnValue());
                }else if(fieldAPIName == 'Oracle_Site_Id__c'){
                    component.set("v.ouList", response.getReturnValue());
                    
                }
			} else {
				console.log("Failed with state: " + state);
			}
		});
       // component.set("v.Spinner", false);
		$A.enqueueAction(action);
        
	},
    fetchRevenue : function(component, event, helper){
        var action = component.get("c.getInvoiceRevenue");
        action.setParams({
            'accountId': component.get('v.selectedLookUpRecord').Id
        });
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                
                console.log('inside type');
                component.set("v.invoiceTypes", response.getReturnValue());
                component.set("v.creditMemo.Oracle_Invoice_Type__c", response.getReturnValue()[0]);
                console.log(response.getReturnValue());  
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
    },
    
    fetchEntity : function(component, event, helper, accID){
        var action = component.get("c.getEntityDetail");
        action.setParams({
            'accID': accID
        });
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                
                console.log('inside type');
                component.set("v.accountDetails", response.getReturnValue());
                var childInvoiceCmp = component.find("invoiceCreateComp");
                if(component.get('v.creditMemo').Id != null)
                    childInvoiceCmp.initInvoice(response.getReturnValue().Id, response.getReturnValue().Oracle_Site_Id__c, component.get('v.creditMemo'),component.get('v.creditMemoLineItem'),null, true, component.get('v.sourceSystem'));
                else
                	childInvoiceCmp.initInvoice(response.getReturnValue().Id, response.getReturnValue().Oracle_Site_Id__c, null,null,null, true, component.get('v.sourceSystem'));
                
                console.log(response.getReturnValue());  
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
    },
    fetchLineItem : function(component, event, helper,selectInvoiceId, creditMemoDetails ) {
        //alert('Fetch line item');
		var action = component.get("c.getInvoiceLines");
        // set parameter
        
       

        action.setParams({
            'invoiceID' :  selectInvoiceId,
            'oldSelectedLines' : null,
            'insertedMemo' : creditMemoDetails
        });
        component.set("v.Spinner", false);
        action.setCallback(this, function(response) {
			var state = response.getState();
            component.set("v.Spinner", false);
			if (state === "SUCCESS") {
                component.set("v.invoiceLineItems", response.getReturnValue());
                
			} else {
				console.log("Failed with state: " + state);
			}
		});
       // component.set("v.Spinner", false);
		$A.enqueueAction(action);
        
	},
    saveRec : function(component, event, helper,creditMemoVal, lineItemValues, accIdVal,inAmount, selectedScenarioVal, payCurrency ) {
        component.set("v.Spinner", true);
		var action = component.get("c.saveCreditMemo");
        creditMemoVal.Source_System__c = component.get("v.sourceSystem");
        console.log(creditMemoVal);
        console.log(lineItemValues);
        console.log(accIdVal);
        console.log(inAmount);
        console.log(selectedScenarioVal);
        console.log(payCurrency);
		// set parameter
        action.setParams({
            'objCreditMemo' : creditMemoVal,
            'listInvoiceWrapper' : lineItemValues,
            'accountId' : accIdVal,
            'inAmount' : inAmount,
            'selectedScenario' : selectedScenarioVal
        });
        //component.set("v.Spinner", false);
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('===>'+ response.getReturnValue());
            component.set("v.Spinner", false);
			if (state === "SUCCESS") {
                if((response.getReturnValue()).MSG == 'success'){
                    component.set("v.creditMemo", response.getReturnValue().invRec);
                    component.set("v.showPushToOracle", true);
                	helper.showToast("success","Success", "Credit Memo Created/Updated Successfully");
                } else {
                    console.log("Response: " + JSON.stringify(response.getReturnValue()));
                    component.set("v.isReview", false);    
                    helper.showToast("error","Error: "+response.getReturnValue().MSG, response.getReturnValue());
                }
			} else {
                console.log("Failed with state: " + state);
                component.set("v.isReview", false);
                helper.showToast("error","Error", "Failed with state: " + state);
			}
            component.set("v.Spinner", false);
		});
       // component.set("v.Spinner", false);
		$A.enqueueAction(action);
        
    },
    fetchBMMetaData : function (component, event, helper) {
        var action = component.get("c.fetchBillingManagementMDTDetail");
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                let resp = response.getReturnValue();
                component.set('v.bmMdt', resp);
                if(resp.Default_OU__c == 'All'){
                    component.set('v.isOUDisabled', false);
                } else {
                    component.set('v.selectedOU', resp.Default_OU__c);
                    component.set('v.isOUDisabled', true);
                    if(resp.Default_OU__c != '101'){
                        component.set('v.sourceSystem', 'BM');
                    } else if(resp.Label == 'Billing Management Arbitration' && resp.Default_OU__c == '101'){
                        console.log('-----------------Metadata method called---------------------');
                        component.set('v.sourceSystem', resp.Default_Source_System__c);
                        component.set('v.defaultSource', resp.Default_Source_System__c);
                    }
                    component.set('v.isSourceNotSelected', false);
                }
			} else {
				console.log("Failed with state: " + state);
			}
		});
       // component.set("v.Spinner", false);
		$A.enqueueAction(action);
    },
    validate :function(component, event, helper) {
        var invoiceRec = [];
        var isValid = true;
        invoiceRec = component.get("v.invoiceLineItems");
        var i;
        var j;
        //alert(invoiceRec);
        if(invoiceRec == null && invoiceRec.length == 0 ){
            helper.showToast("error","Error","Please select invoice line item.");
            isValid = false;
            return isValid;
        }
        
        var isSelected = false;
        if(invoiceRec.length > 0 ){
            var item = ["lineAmt"];
            for (i = 0; i < invoiceRec.length; i++){
                var invoiceBal = 0;
                //invoiceBal = Number(-invoiceRec[i].invoiceRec.Invoice_Balance__c);
                invoiceBal = Number(invoiceRec[i].invoiceRec.Invoice_Balance__c);
                //var itemDom = component.find(item[i]);
                var lineAmt = 0;

                for(j = 0; j < invoiceRec[i].listInvoiceLineRec.length; j++) {
                    if(invoiceRec[i].listInvoiceLineRec[j].isSelected){
                    	isSelected = true;
                    }
                    if(invoiceRec[i].listInvoiceLineRec[j].isSelected == false)
                        continue;
                    console.log('invoiceRec[i].listInvoiceLineRec[j].dAmount '+invoiceRec[i].listInvoiceLineRec[j].dAmount);
                    if(Number(invoiceRec[i].listInvoiceLineRec[j].dAmount) != 0){
                        lineAmt = lineAmt + Number(invoiceRec[i].listInvoiceLineRec[j].dAmount);
                        if(invoiceRec[i].listInvoiceLineRec[j].dAmount > invoiceRec[i].listInvoiceLineRec[j].InvoiceLineRec.Line_Amount__c){
                            helper.showToast("error","Error","Credit memo line amount cannot be more than actual line amount.");
                            return false;
                        }
                        if(Number(invoiceRec[i].listInvoiceLineRec[j].dAmount) < 0){
                            helper.showToast("error","Error","Please enter only positive value.");
                            return false;
                        }
                        if(!invoiceRec[i].listInvoiceLineRec[j].InvoiceLineRec.Tax__c || invoiceRec[i].listInvoiceLineRec[j].InvoiceLineRec.Tax__c == '5%' || invoiceRec[i].listInvoiceLineRec[j].InvoiceLineRec.Tax__c == 'ADJUSTMENT 5%' ){
                            lineAmt = lineAmt + (Number(invoiceRec[i].listInvoiceLineRec[j].dAmount)*(5/100));
                        }
                        console.log('lineAmt' +lineAmt );
                    }else {
                        //lineAmt = lineAmt + (Number(invoiceRec[i].listInvoiceLineRec[j].InvoiceLineRec.Calculated_Amount__c) *-1);
                        helper.showToast("error","Error","Please select the amount");
                        return false;
                    }
                }
                
                /*if(lineAmt > 0) {
                    helper.showToast("error","Error","Please enter negative applied amount."+invoiceRec[i].invoiceRec.Name);
                    isValid = false;
                    return isValid;
                }*/
                if(invoiceBal < lineAmt){
                    helper.showToast("error","Error","Total applied memo amount is greater than Invoice Balance Amount."+invoiceRec[i].invoiceRec.Name);
                    isValid = false;
                    return isValid;
                }
            }
        }
        if(!isSelected) {
            helper.showToast("error","Error","Please select at list one invoice line item.");
            isValid = false;
            return isValid;
        }
            
        return isValid;
    },
    setSourceSystemVal : function(component, event, helper ) {
        if(component.get('v.selectedOU') != undefined && component.get('v.selectedOU') != '--None--'  && component.get('v.selectedOU') != ""){
        
            component.set('v.unitSelected' , false);
            var sourceSyslist = [];
            component.set("v.sourceSystemList",sourceSyslist);
            var selectedOU =  component.get("v.selectedOU");
            var sourceSys ;
            
            
            if(selectedOU == '101') {
                sourceSys = {  picklistLabel : "BM - ADGM",  picklistVal  : "BM - ADGM"};
                sourceSyslist.push(sourceSys);
                sourceSys = {  picklistLabel : "BM - Arbitration",  picklistVal  : "BM - Arbitration"};
                sourceSyslist.push(sourceSys);
            } else {
                sourceSys = {  picklistLabel : "BM",  picklistVal  : "BM"};
                
                component.set('v.sourceSystem', 'BM');
                sourceSyslist.push(sourceSys);
            }
            
            component.set("v.sourceSystemList",sourceSyslist);
        }
    },
    cancelMemo : function(component, event, helper ) {
        //alert('Fetch line item');
		var action = component.get("c.memoCancellation");
		// set parameter
        action.setParams({
            'objInvoice' : component.get("v.creditMemo")
        });
        component.set("v.Spinner", false);
        action.setCallback(this, function(response) {
			var state = response.getState();
            component.set("v.Spinner", false);
			if (state === "SUCCESS") {
                helper.showToast("success","Success", "Credit Memo Cancelled Successfully");
			} else {
				helper.showToast("error","Error", response.getReturnValue());
			}
		});
       // component.set("v.Spinner", false);
		$A.enqueueAction(action);
        
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
    }
    
})