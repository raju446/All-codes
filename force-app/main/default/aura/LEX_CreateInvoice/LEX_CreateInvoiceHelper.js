/**
 * @File Name          : LEX_CreateInvoiceHelper.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 11-09-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/29/2020   Jayanta Karmakar     Initial Version
**/
({
    addInvoiceLine : function(component, event, helper){
        var invLineLst = component.get("v.invoiceLineItems");
        //invLineLst.push({"Amount":0.0,"TaxAmount":0.0,"DiscountAmount":0.0,"DiscountTaxAmount":0.0,"ItemDescription":"","ItemReference":"","RecId":""});
        let taxcode = component.get('v.revenueMappingObj').defaultTaxCode;
        let dept = component.get('v.defDept');
        let schoolcode = 'Default';
        if(component.get('v.revenueMappingObj').schoolType){
            schoolcode = component.get('v.revenueMappingObj').schoolType;
        }
        invLineLst.push({"itemTypes" : [],"EnableDiscountDesc":false,"LineTotal":0.0,"Service_Class__c":"","Amount__c":0.0,"Tax__c" : taxcode,"Tax_Amount__c":0.0,"Discount_Amount__c":0.0,"Taxable_Discount_Amount__c":0.0,"Item_Description__c":"","Item_Reference__c":"","Quantity__c":1,"Course_Type__c" : "Default", "Schools__c":schoolcode, "Department__c" : dept,"Discount_Description__c" : ""});
        component.set("v.invoiceLineItems", invLineLst);
    },
    getEntityOU : function(component, event, helper){
        var action = component.get("c.fetchAccountDetails");
        action.setParams({
            'recId': component.get('v.entityId') 
        });
        action.setCallback(this, function(response) {
			var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                console.log('---response---'+resp);
                console.log('---site id is---'+resp.Oracle_Site_Id__c);
                component.set('v.entityOU', resp.Oracle_Site_Id__c);
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
    },
    fetchPicklistValues : function(component, fieldAPIName, nullRequired) {
		var action = component.get("c.fetchInvoiceLineItemPicklistVal");
        action.setParams({
            'fieldAPIname': fieldAPIName,
            'nullRequired': nullRequired 
        });
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                if(fieldAPIName == "Schools__c"){
                    component.set("v.schools", response.getReturnValue());
                } else {
                    component.set("v.courses", response.getReturnValue());
                }    
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
    },
    saveInvoice : function(component, event, helper){
        var rec = component.get("v.newInvoiceObject");
        rec.Is_Created_Manually__c = true;
        console.log(JSON.stringify(rec));
        var errorArray = [];
        var accId = component.get("v.entityId");
        console.log(accId);
        if(accId){
            rec.Entity__c = accId;
        }
        var lines = component.get("v.invoiceLineItems");
        console.log(lines);
		component.set("v.Spinner", true);
        var relatedReceiptsRecs = component.get("v.selectedLookUpRecords");

            var action = component.get("c.upsertInvoiceAndRelatedReceipts");
            action.setParams({
                'invRecord': rec,
                'invoiceLines': lines,
                'relatedReceipts' : relatedReceiptsRecs,
                'isCreditMemo' : component.get("v.isCreditMemo"),
                'attachmentFiles' : component.get('v.uploadedFiles'),
                'selectedDeptVal' : component.get('v.selectedDept')
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                component.set("v.Spinner", false);
                if (state === "SUCCESS") {
                    if(response.getReturnValue() == 'Success'){
                        helper.closeAll(component, event, helper);
                        if(!component.set("v.isRecordSaved"))
                        	component.set("v.isRecordSaved", true);
                        else 
                            component.set("v.isRecordSaved", false);
                        helper.showToast("success","Success", "Invoice Created/Updated Successfully");
                        
                    } else {
                        helper.showToast("error","Error", response.getReturnValue());
                    }
                    console.log(response.getReturnValue());  
                } else {
                    console.log("Failed with state: " + state);
                    helper.showToast("error","Error", "Failed with state: " + state);
                }
            });
            $A.enqueueAction(action);
            component.set("v.disableConfirm", false);
    },
    saveCreditMemo : function(component, event, helper){ 
        //alert('Inside save credit memo');
        var rec = component.get("v.newInvoiceObject");
        rec.Is_Created_Manually__c = true;
        console.log(JSON.stringify(rec));
        var errorArray = [];
        var accId = component.get("v.entityId");
        console.log(accId);
        if(accId){
            rec.Entity__c = accId;
        }
        var lines = component.get("v.invoiceLineItems");
        let selDept = component.get('v.selectedDept');
        for(let i in lines){
            lines[i].Department__c = selDept;
        }
        console.log(lines);
		component.set("v.Spinner", true);
        //var relatedReceiptsRecs = component.get("v.selectedLookUpRecords");

            var action = component.get("c.upsertCreditMemo");
            action.setParams({
                'invRecord': rec,
                'invoiceLines': lines,
                'relatedReceipts' : null,
                'isCreditMemo' : component.get("v.isCreditMemo")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                component.set("v.Spinner", false);
                if (state === "SUCCESS") {
                    if(response.getReturnValue().msg == 'Success'){
                        helper.closeAll(component, event, helper);
                        //component.set("v.newInvoiceObject", "{ 'sobjectType': 'Invoice__c','Payment_Term__c': '','Payment_Currency__c': '','Oracle_Invoice_Type__c' : ''}");
                        //component.set("v.invoiceLineItems", "Invoice_Line_Item__c[]");
                        //component.set("v.selectedLookUpRecords", "");
                        //component.set("v.isReview", false);
                        //component.set("v.showInvoiceCreateTable", false);
                        component.set("v.isRecordSaved", true);
                        helper.showToast("success","Success", "Invoice Created/Updated Successfully");
                        //alert('hiii');
                        component.set("v.objcreditMemoLineItem", response.getReturnValue().listInvoiceLineRec);
                        component.set("v.objCreditMemo", response.getReturnValue().invoiceRec);
                    } else {
                        helper.showToast("error","Error", response.getReturnValue());
                    }
                    console.log(response.getReturnValue());  
                } else {
                    console.log("Failed with state: " + response.getError());
                    console.log( response.getError());
                    helper.showToast("error","Error", "Failed with state: " + state);
                }
            });
            $A.enqueueAction(action);
            component.set("v.disableConfirm", false);
    },
    fetchRevenueMapping : function (component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.getInvoiceRevenueMapping");
        action.setParams({
            'accId': component.get('v.entityId'),
            'isCreditMemo' : component.get("v.isCreditMemo")
        });
        action.setCallback(this, function(response) {
            component.set("v.Spinner", false);
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log('=================================================='); 
                console.log(response.getReturnValue());  
                component.set('v.revenueMappingObj', response.getReturnValue());
                if(response.getReturnValue().departments.length == 1){
                    component.set('v.defDept', response.getReturnValue().departments[0]);
                    component.set('v.selectedDept', response.getReturnValue().departments[0]);
                }
                
                component.set('v.newInvoiceObject.Oracle_Invoice_Type__c', response.getReturnValue().invType);
                component.set('v.newInvoiceObject.Payment_Currency__c', response.getReturnValue().defaultCurrency);
                component.set('v.paymentTermList', response.getReturnValue().listPaymentTerm);
                component.set('v.taxCodeList', response.getReturnValue().listTaxCode);
                component.set('v.currencyToDisplayList', response.getReturnValue().listCurrencyToDisplay);
                component.set('v.operatingUnitObj', response.getReturnValue().ouObj);
                component.set('v.roomRates', response.getReturnValue().roomRates);
                component.set('v.newInvoiceObject.Payment_Term__c', response.getReturnValue().defaultPaymentTerm);
                
                console.log('ILILILILI');
                let lines = component.get('v.invoiceLineItems');
                console.log(lines);
                for(let i=0; i< lines.length; i++){
                    console.log(lines[i].Service_Type__c);
                    let resp = response.getReturnValue();
                    for(let j=0; j < resp.invRevenueMap.length ; j++){
                        console.log(resp.invRevenueMap[j].serType);
                        if(lines[i].Service_Type__c == resp.invRevenueMap[j].serType){
                            lines[i]['itemTypes'] = resp.invRevenueMap[j].lineItemType;
                        }
                    }
                }
                component.set('v.invoiceLineItems' , lines);
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
    },
    fetchRevenue : function(component, event, helper, accOracleId, type, invoiceType, creditMemoVal){
        
        var action = component.get("c.getInvoiceRevenue");
        action.setParams({
            'oracle_SiteId': accOracleId,
            'isType': type,
            'selectedInvoiceType' : invoiceType,
            'isCreditMemo' : creditMemoVal
        });
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                var items = [];
                
                for(var i=0;i<response.getReturnValue().length;i++){
                    items.push( this.titleCase( response.getReturnValue()[i] ) );
                }
                console.log(response.getReturnValue());
                console.log(items);
                console.log('type '+type);
                if(type){
                    console.log('inside type');
                    component.set("v.invoiceTypes", response.getReturnValue());//response.getReturnValue());
                } else {
                    component.set("v.invoiceItemTypes", response.getReturnValue());//response.getReturnValue());
                }
                console.log(response.getReturnValue());  
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
    },
    validateInvoice : function(component, event, helper){
        var rec = component.get("v.newInvoiceObject");
        debugger;
        console.log(JSON.stringify(rec));
        var lines = component.get("v.invoiceLineItems");
        console.log(JSON.stringify(lines));
		var isCreditMemo = component.get("v.isCreditMemo");
        var isValid = true;
        
        /*if(! rec.Transaction_Reference__c && !isCreditMemo){
            var v = component.find("tranRef");
            v.showHelpMessageIfInvalid(); 
            isValid = false;
        }*/
        
        
        if(! component.get('v.selectedDept') && !isCreditMemo){
            var v = component.find("dept");
            v.showHelpMessageIfInvalid(); 
            isValid = false;
        }
        if(! rec.Invoice_Date__c && !isCreditMemo){
            var v = component.find("InvDate");
            v.showHelpMessageIfInvalid(); 
            isValid = false;
        }
        if(! rec.Payment_Term__c && !isCreditMemo){
            var v = component.find("payTerm");
            v.showHelpMessageIfInvalid(); 
            isValid = false;
        }
        if(! rec.Payment_Currency__c ){
            var v = component.find("invCurrency");
            v.showHelpMessageIfInvalid(); 
            isValid = false;
        }
        if(! rec.Oracle_Invoice_Type__c){           
            var v = component.find("invType");
            v.showHelpMessageIfInvalid();
            isValid = false;
        }
        if(! rec.GL_Date__c && !isCreditMemo){
            var v = component.find("glDate");
            v.showHelpMessageIfInvalid(); 
            isValid = false;
        }
        
        /*if(! rec.Credit_Memo_Type__c && isCreditMemo){           
            var v = component.find("cmType");
            v.showHelpMessageIfInvalid();
            isValid = false;
        }*/
        
        if(lines.length == 0 ) {
            helper.showToast("error","Error","Please add line item details");
            isValid = false;
            return isValid;
        }
		
        if(lines.length > 0 && isCreditMemo){
            /*var item = ["lineAmt"]; // ,"lineTaxAmt"
            for(var i = 0; i < item.length; i++){
                var itemDom = component.find(item[i]);
                console.log(itemDom);
                console.log('isArray '+Array.isArray(itemDom));
                if(Array.isArray(itemDom)){
                    for(var j =0; j < itemDom.length; j++){                       
                        if(itemDom[j].get('v.value') == null || itemDom[j].get('v.value') == '' || (item[i] == 'lineAmt' && Number(itemDom[j].get('v.value')) >= 0) || (item[i] == 'lineTaxAmt' && Number(itemDom[j].get('v.value')) > 0)  ){
                            if(item[i] != 'lineTaxAmt'){
                                helper.showToast("error","Error","Please enter negative memo amount.");
                                isValid = false;
                                return isValid;
                            }
                        }
                    }
                } else {
                    console.log(Number(itemDom.get('v.value')));
                    //$A.util.removeClass(itemDom, 'slds-has-error');
                    if(itemDom.get('v.value') == null || itemDom.get('v.value') == '' || (item[i] == 'lineAmt' && Number(itemDom.get('v.value')) >= 0) || (item[i] == 'lineTaxAmt' && Number(itemDom.get('v.value')) > 0)   ) {
                        if(item[i] != 'lineTaxAmt'){
                            helper.showToast("error","Error","Please enter negative memo amount.");
                            isValid = false;
                            return isValid;
                        }
                    }
                }
            }*/
        }
        
        if(lines.length > 0 && !isCreditMemo){
            /*var item = ["lineAmt","selLineTaxAmt","lineItemDesc"]; //"lineTaxAmt" ,"LineItemRef"
            for(var i = 0; i < item.length; i++){
                var itemDom = component.find(item[i]);
                console.log(itemDom);
                if(Array.isArray(itemDom)){
                    for(var j =0; j < itemDom.length; j++){
                        $A.util.removeClass(itemDom[j], 'slds-has-error');
                        if(itemDom[j].get('v.value') == '' || itemDom[j].get('v.value') == null){
                            //itemDom[j].showHelpMessageIfInvalid();
                            if(item[i] != 'lineTaxAmt'){
                                $A.util.addClass(itemDom[j], 'slds-has-error');
                                isValid = false;
                                console.log('--------------------------------------');
                            }
                        }
                    }
                } else {
                    $A.util.removeClass(itemDom, 'slds-has-error');
                    if(itemDom.get('v.value') == null || itemDom.get('v.value') == ''){
                        //itemDom.showHelpMessageIfInvalid();
                        if(item[i] != 'lineTaxAmt'){
                            $A.util.addClass(itemDom, 'slds-has-error');
                            isValid = false;
                        }
                    }
                }
            } */
            
            for(let i=0;i< lines.length; i++){
                let missields = [];
                if(rec.Oracle_Invoice_Type__c == 'Academy Invoice'){
                    if(! lines[i].Course_Type__c){
                        missields.push('Training Type');
                    }
                }
                
                if(rec.Oracle_Invoice_Type__c == 'Academy Invoice'){
                    if(! lines[i].Schools__c){
                        missields.push('School & Initiative Type');
                    }
                }
                
                if(rec.Oracle_Invoice_Type__c != ''){
                    if(!lines[i].Service_Type__c){
                        missields.push('Service Type');
                    }
                }
                
                if(rec.Oracle_Invoice_Type__c == 'RA Invoice'){
                    if(!lines[i].Service_Class__c){
                        missields.push('Service Class');
                    }
                }
                
                if(rec.Oracle_Invoice_Type__c == 'FSRA Invoice'){
                    if(! lines[i].Item_Description__c){
                        missields.push('Fee Type');
                    }
                }   
                
                if(rec.Oracle_Invoice_Type__c == 'FSRA Invoice'){
                    if(! lines[i].Line_Description__c){
                        missields.push('Description');
                    }
                }
                
                if(! lines[i].Amount__c){
                    missields.push('Amount');
                }
                if(! lines[i].Tax__c){
                    missields.push('Tax Amount');
                }
                if(rec.Oracle_Invoice_Type__c == 'FSRA Invoice' || rec.Oracle_Invoice_Type__c == 'ARC Invoice'){
                    if(! lines[i].Quantity__c){
                        missields.push('Quantity');
                    }
                }
                
                if(lines[i].Discount_Amount__c){
                    if(! lines[i].Discount_Description__c){
                        missields.push('Discount Description');
                    }
                }
                
                
                if(missields.length > 0){
                    isValid = true;
                    //helper.showToast("error","Error","Required fields missing : "+ missields.join(','));
                }
                
            }
        }
        
        
        return isValid;
    },
    closeAll: function(component, event, helper){
        var action = component.get("c.invoiceInitialization");
        
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                component.set("v.newInvoiceObject", response.getReturnValue());
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
        var action = component.get("c.lineItemInitialization");
        
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                component.set("v.invoiceLineItems", response.getReturnValue());
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
        //component.set("v.newInvoiceObject", "{ 'sobjectType': 'Invoice__c', 'Payment_Currency__c' : '--None--'}");
        //component.set("v.invoiceLineItems", "Invoice_Line_Item__c[]");
        var recWrap = component.get('v.selectedLookUpRecords');
        recWrap = [];
        component.set('v.selectedLookUpRecords',recWrap);
        component.set("v.isReview", false);
        component.set("v.showInvoiceCreateTable", false);
        component.set("v.totalAmount", 0.0);
        
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
    getTaxValues : function(component, event){
        console.log(component.get("v.taxValues"));
        var action = component.get("c.TaxValues");
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.taxValues", response.getReturnValue());
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
    },
    titleCase : function(str){
    	if(str) {
          return str.toLowerCase().split(' ').map(function(word) {
            return word.replace(word[0], word[0].toUpperCase());
          }).join(' ');
        }else
            return str;
	}
})