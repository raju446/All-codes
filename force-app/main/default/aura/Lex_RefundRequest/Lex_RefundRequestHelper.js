/**
 * @File Name          : Lex_RefundRequestHelper.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 09-07-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/22/2020   Jayanta Karmakar     Initial Version
**/
({
     fetchOldRefund : function(component, event, helper){
         console.log(component.get("v.recordId"));
        var action = component.get("c.getOldData");
        // set parameter
        action.setParams({
            'refundId': component.get("v.recordId")//'a2c25000000Rq7dAAC'
        });
        
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log('------------------------------------------------------------');
                console.log(response.getReturnValue());
                if(response.getReturnValue().objRefund.Pushed_To_Oracle__c){
                    this.showToast('warning','Warning','Record already Pushed to oracle');
                    component.set('v.isReview',true);
                } 
                    component.set("v.onLoad", true);
                    console.log(response.getReturnValue().objRefund.CustomerOU__c);
                    component.set("v.sourceSystem", response.getReturnValue().objRefund.CustomerOU__c);
                    component.set("v.refund", response.getReturnValue().objRefund);
                    //component.set("v.sourceSystem", response.getReturnValue().objRefund.Entity__r.Source_System_Name__c);
                    if(response.getReturnValue().selectedEntity != null)
                        component.set("v.selectedLookUpRecord", response.getReturnValue().selectedEntity);
                    if(response.getReturnValue().selectedReceipt != null){
                        component.set("v.selectedReceiptLookUpRecord", response.getReturnValue().selectedReceipt);
                        if(response.getReturnValue().objRefund.Scenario__c == 'Receipt generated but invoice not generated'){
                            component.set("v.maxVal", response.getReturnValue().selectedReceipt.Amount__c);
                        } else {
                            component.set("v.maxVal", response.getReturnValue().selectedReceipt.Total_Applied_Amount__c);
                        }
                    }   
                    console.log(component.get("v.selectedReceiptLookUpRecord"));
                    if(response.getReturnValue().selectedCreditMemo != null){
                        component.set("v.selectedCreditMemoLookUpRecord", response.getReturnValue().selectedCreditMemo);
                        component.set("v.maxVal", (response.getReturnValue().selectedCreditMemo.Invoice_Balance__c * -1));
                    }
                    
                    if(response.getReturnValue().selectedCreditMemoReceipt != null){
                        component.set("v.selectedCreditMemoReceptiLookUpRecord", response.getReturnValue().selectedCreditMemoReceipt);
                    }
                    
                    if(response.getReturnValue().listInvoiceLine != null)
                        component.set("v.listInvoiceWrapper", response.getReturnValue().listInvoiceLine);
                    
                    
                    component.set("v.onLoad", false);
                
                //component.set("v.selectedReferenceReceipt", response.getReturnValue().selectedReceipt);
			} else {
				console.log("Failed with state: " + state);
			}
		});
       // -component.set("v.Spinner", false);
		$A.enqueueAction(action);
    },
     showTostMSG : function(component, event, isSuccess, msg) {
        var toastEvent = $A.get("e.force:showToast");
        if(isSuccess == 'Success') {
            toastEvent.setParams({
                "title": "Success!",
                "type" : "success",
                "message": msg
                
            });
        } else {
            toastEvent.setParams({
                "title": "Error!",
                "type" : "error",
                "message": msg
                
            });
            
        }//end else- if
        toastEvent.fire();
    },
    uploadFileOnChange: function (cmp, event, helper) {
        this.showSpinner(cmp);
        var fileAttribute = cmp.get("v.uploadedFiles");
        console.log(fileAttribute);
        let fileObj = event.getSource().get("v.files");
        let compName = event.getSource().get("v.name");
        console.log(event.getSource().get("v.name"));
        console.log(fileObj);
         

        var file = fileObj[0];   
        if(file.size > 2500000){
            this.showToast('error','Error','File size is too big.');
            return;
        }  
        
        var fileReader = new FileReader();        
        fileReader.readAsDataURL(file); 
        fileReader.onloadstart = function(){
            console.log('Load Start+++');
        }    
        fileReader.onprogress = function(){
            console.log('Loading......');
        }  
        fileReader.onloadend = function()
        {
            console.log('Load end---');
        }          
        fileReader.onload = function () {                
            var fileContentBase64 = fileReader.result.split('base64,')[1]; 
            if(compName == 'ceoApproval'){
                fileAttribute[0].blobval = fileContentBase64;
                fileAttribute[0].fileName = file.name;
                fileAttribute[0].isUploaded = true;
            } else {
                fileAttribute[1].blobval = fileContentBase64;
                fileAttribute[1].fileName = file.name;
                fileAttribute[1].isUploaded = true;
            }
            cmp.set("v.uploadedFiles",fileAttribute);
            console.log(cmp.get("v.uploadedFiles"));
            console.log(fileContentBase64);
            helper.hideSpinner(cmp);
        }
    },
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    fetchPicklistValues : function(component, objectName,fieldAPIName, nullRequired) {
        this.showSpinner(component);
		var action = component.get("c.fetchPicklistVal");
        action.setParams({
            'objectApi' : objectName,
            'fieldAPIname': fieldAPIName,
            'nullRequired': nullRequired 
        });
        action.setCallback(this, function(response) {
            this.hideSpinner(component);
			var state = response.getState();
            component.set("v.Spinner", false);
			if (state === "SUCCESS") {
                //var records = response.getReturnValue();
                console.log(response.getReturnValue());
                if(fieldAPIName == 'Payment_Method__c' && objectName == 'Refund__c') {
                    component.set("v.paymentModePicklist", response.getReturnValue());
                } else if(fieldAPIName == 'Payment_Method__c' && objectName == 'Receipt__c') {
                    component.set("v.receiptPaymentModePicklist", response.getReturnValue());
                } else if(fieldAPIName == 'Transaction_Types__c') {
                    component.set("v.transactionTypesPicklist", response.getReturnValue());
                } else if(fieldAPIName == 'Scenario__c') {
                    component.set("v.scenarioPicklist", response.getReturnValue());
                }else if(fieldAPIName == 'Oracle_Site_Id__c'){
                    component.set("v.ouList", response.getReturnValue());
                }else if(fieldAPIName == 'Source_System__c'){
                    component.set("v.sourceSystems", response.getReturnValue());
                }
			} else {
				console.log("Failed with state: " + state);
			}
		});
       // component.set("v.Spinner", false);
		$A.enqueueAction(action);
        
	},
    
    fetchRevenue : function(component, event, helper, accSourceval){
        helper.showSpinner(component);
        var action = component.get("c.getInvoiceRevenue");
        action.setParams({
            'sourceSystemName': accSourceval
        });
        action.setCallback(this, function(response) {
            helper.hideSpinner(component);
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                
                console.log('inside type');
                component.set("v.invoiceTypes", response.getReturnValue());
                console.log(response.getReturnValue());  
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
    },
    fetchInvoice : function(component, event, helper, receiptId){
        helper.showSpinner(component);
        var action = component.get("c.getRelatedInvoice");
        action.setParams({
            'selectedReceiptId': receiptId,
            'mapOldRefundLine' : null
        });
        action.setCallback(this, function(response) {
            helper.hideSpinner(component);
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                
                console.log('inside type');
                component.set("v.listInvoiceWrapper", response.getReturnValue());
                console.log(response.getReturnValue());  
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
    },
    fetchReceiptPaymentMethod: function (component, event, helper) {
        helper.showSpinner(component);
        var action = component.get("c.fetchReceiptDetails");
        action.setParams({
            'receiptId': component.get('v.selectedReceiptLookUpRecord').Id
        });
        action.setCallback(this, function(response) {
            helper.hideSpinner(component);
			var state = response.getState();
			if (state === "SUCCESS") {
                var responseVal = response.getReturnValue();
                console.log(responseVal);
                if(responseVal.length > 0){
                    component.set("v.refund.Currency__c", responseVal[0].Payment_Currency__c);
                    if(responseVal[0].Payment_Method__c.toUpperCase().includes("CARD")){
                        component.set("v.refund.Payment_Method__c", "Credit Card");
                        component.set("v.refund.Actual_Payment_Method__c", responseVal[0].Payment_Method__c); //"Credit Card"
                        component.set("v.ccNumber",responseVal[0].Credit_Card_F_L_Four_Digits__c);
                        component.set("v.refund.Card_First_Last_Digit__c",responseVal[0].Credit_Card_F_L_Four_Digits__c);
                        component.set("v.authCode",responseVal[0].Authorization_Code__c);
                        component.set("v.refund.Authorization_Code__c",responseVal[0].Authorization_Code__c);
                    } else {
                        component.set("v.refund.Payment_Method__c", "Bank Transfer");
                        component.set("v.refund.Actual_Payment_Method__c", responseVal[0].Payment_Method__c); //"Bank Transfer" 
                    }
                    if(component.get("v.refund").Scenario__c == "Receipt generated but invoice not generated"){
                        component.set("v.refund.Amount__c", responseVal[0].Amount__c);
                        component.set("v.maxVal", responseVal[0].Amount__c);
                    } else {
                        component.set("v.refund.Amount__c", 0.0);
                        component.set("v.maxVal", responseVal[0].Total_Applied_Amount__c);
                    }
                }
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
    },
    fetchBMMetaData : function (component, event, helper) {
        var action = component.get("c.fetchBillingManagementMDTDetail");
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                let resp = response.getReturnValue();
                //component.set('v.bmMdt', resp);
                if(resp.Default_OU__c == 'All'){
                    component.set('v.isOUDisabled', false);
                } else {
                    component.set('v.sourceSystem', resp.Default_OU__c);
                    component.set('v.isOUDisabled', true);
                    if(resp.Default_Source_System__c != 'All'){
                        component.set('v.refund.Source_System__c', resp.Default_Source_System__c);
                    }
                    component.set('v.isSourceNotSelected', false);
                    component.set('v.isNotAuthoritySelected',false);
                    if(resp.Label == 'Billing Management Court'){
                        component.set('v.refund.Transaction_Types__c', 'Courts Refund');
                        component.set('v.defTraType', 'Courts Refund');
                        component.set('v.isTransactionTypeDisabled', true);
                    }
                    if(resp.Label == 'Billing Management RA'){
                        component.set('v.refund.Transaction_Types__c', 'RA Refund');
                        component.set('v.defTraType', 'RA Refund');
                        component.set('v.isTransactionTypeDisabled', true);
                    }
                }
			} else {
				console.log("Failed with state: " + state);
			}
		});
       // component.set("v.Spinner", false);
		$A.enqueueAction(action);
    },
    fetchBankDetailsFromIBAN: function (component, event, helper) {
        helper.showSpinner(component);
        var action = component.get("c.fetchIBAN");
        action.setParams({
            'entityId' : component.get('v.selectedLookUpRecord').Id,
            'IBANNum' : component.get('v.refund').IBAN_Number__c
        });
        action.setCallback(this, function(response) {
            helper.hideSpinner(component);
			var state = response.getState();
			if (state === "SUCCESS") {
                let responseData = response.getReturnValue();
                console.log(JSON.stringify(responseData));
                if(responseData.P_OP_RETURN_STATUS == 'E'){
                    helper.showToast("error","Error", responseData.P_OP_RETURN_MSG);
                } else {
                    component.set("v.refund.Vendor_Name__c", responseData.P_OP_VENDOR_NAME);
                    component.set("v.refund.Vendor_Number__c", responseData.P_OP_VENDOR_NUMBER);
                    component.set("v.refund.Bank_Name__c", responseData.P_OP_BANK_NAME);
                    component.set("v.refund.Bank_Account_Number__c", responseData.P_OP_BANK_ACCOUNT_NUM);
                    component.set("v.refund.Supplier_Number__c", responseData.P_OP_VENDOR_SITE_ID);
                }
			} else {
				console.log("Failed with state: " + state);
                helper.showToast("error","Error", state);
			}
		});
		$A.enqueueAction(action);
    },
    fetchBankDetailsFromIBANNew: function (component, event, helper) {
        helper.showSpinner(component);
        var action = component.get("c.fetchIBAN_New");
        action.setParams({
            'entityId' : component.get('v.selectedLookUpRecord').Id,
            'IBANNum' : component.get('v.refund').IBAN_Number__c
        });
        action.setCallback(this, function(response) {
            helper.hideSpinner(component);
			var state = response.getState();
			if (state === "SUCCESS") {
                let responseData = response.getReturnValue();
                console.log(JSON.stringify(responseData));
                console.log('responseData.VENDOR_NAME==='+responseData.VENDOR_NAME);
                var str = responseData.VENDOR_NAME.replaceAll('[^a-zA-Z0-9\\s+]', '');
                console.log('str==='+str);
                    component.set("v.refund.Vendor_Name__c", responseData.VENDOR_NAME);
                    component.set("v.refund.Vendor_Number__c", responseData.VENDOR_NUMBER);
                    component.set("v.refund.Bank_Name__c", responseData.BANK_NAME);
                    component.set("v.refund.Bank_Account_Number__c", responseData.BANK_ACCOUNT_NUM);
                    component.set("v.refund.Supplier_Number__c", responseData.VENDOR_SITE_CODE);
			} else {
				console.log("Failed with state: " + state);
                helper.showToast("error","Error", state);
			}
		});
		$A.enqueueAction(action);
    },
    showToast: function(type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message,
            "mode": "sticky"
        });
        toastEvent.fire();
    },
    doSaveRecord: function (cmp, event, helper) {
        debugger;
        var refundObj = cmp.get('v.refund');
        console.log('listInvoiceWrapper==='+JSON.stringify(cmp.get('v.listInvoiceWrapper')));
        console.log('refundObj==='+JSON.stringify(refundObj));
        console.log('uploadedFiles==='+JSON.stringify(cmp.get('v.uploadedFiles')));
        this.showSpinner(cmp);
        var action = cmp.get("c.saveRefundRecord");
        action.setParams({
            "refundRecord" : refundObj,
            "invoiceList" : cmp.get("v.listInvoiceWrapper"),
            "attachmentFiles" : cmp.get("v.uploadedFiles")
        });
        action.setCallback(this, function(response) {
            this.hideSpinner(cmp);
			var state = response.getState();
            console.log('state==='+state);
			if (state === 'SUCCESS') {
                console.log('response==='+response.getReturnValue());
                var responseData = response.getReturnValue();
                if(responseData.includes('ERROR')){
                    helper.showToast('error','Error',responseData);
                } else {
                    cmp.set('v.refundId',responseData);
                   // cmp.set('v.attachmentModal',true);
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": responseData,
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                }
			} else {
				console.log("Failed with state: " + state);
                helper.showToast("error","Error", state);
			}
		});
		$A.enqueueAction(action);
    },
    handleCreditMemoChange: function (component, event, helper) {
        var creditMemoRec = component.get("v.selectedCreditMemoLookUpRecord");
        if(creditMemoRec.Id){
            this.showSpinner(component);
            var action = component.get("c.fetchCreditMemoDetails");
            action.setParams({
                'cmId' : creditMemoRec.Id
            });
            action.setCallback(this, function(response) {
                this.hideSpinner(component);
                var state = response.getState();
                if (state === "SUCCESS") {
                    let responseData = response.getReturnValue();
                    component.set('v.refund.Amount__c',(responseData[0].Invoice_Balance__c * -1));
                    component.set('v.maxVal',(responseData[0].Invoice_Balance__c * -1));
                    component.set('v.refund.Payment_Method__c',"Bank Transfer");
                    component.set('v.refund.Currency__c',responseData[0].Payment_Currency__c);
                    component.set('v.refund.Credit_Memo__c',creditMemoRec.Id);
                } else {
                    console.log("Failed with state: " + state);
                    helper.showToast("error","Error", state);
                }
            });
            $A.enqueueAction(action);
        } else {
            component.set('v.refund.Amount__c',0.0);
            component.set('v.refund.Payment_Method__c',null);
            component.set('v.refund.Currency__c',null);
            component.set('v.refund.Credit_Memo__c',null);
        }
    },
    validateRefund: function (cmp, event, helper) {
        let isValid = true;
        let refundObj = cmp.get("v.refund");
        console.log(JSON.stringify(refundObj));
        let attachmentFiles = cmp.get("v.uploadedFiles");
        let errorFields = [];
        if(! refundObj.Scenario__c || refundObj.Scenario__c == 'None'){
            errorFields.push('Scenario');
        }
        if(! cmp.get("v.sourceSystem")){
            errorFields.push('Authority');
        }
        if(! refundObj.Entity__c){
            errorFields.push('Customer');
        }
        if(refundObj.Scenario__c){
            if(refundObj.Scenario__c == 'Receipt and Invoice are generated' || refundObj.Scenario__c == 'Receipt generated but invoice not generated'){
                if(! refundObj.Receipt__c){
                    errorFields.push('Receipt');
                }
            } else if (refundObj.Scenario__c == 'Credit Memo'){
                if(! refundObj.Credit_Memo__c){
                    errorFields.push('Credit Memo');
                }
            }
        }
        
        if(! refundObj.Payment_Method__c || refundObj.Payment_Method__c == 'None'){
            errorFields.push('Payment Method');
        }

        if(refundObj.Payment_Method__c && refundObj.Payment_Method__c != 'None'){
            if(refundObj.Payment_Method__c == 'Bank Transfer'){
                if(! refundObj.IBAN_Number__c){
                    errorFields.push('IBAN No');
                }
                if(! refundObj.Bank_Account_Number__c){
                    errorFields.push('Account Number');
                }
            } else {
                if(! refundObj.Card_First_Last_Digit__c){
                    errorFields.push('Credit Card Number');
                }
            }
        }
        
        if(! refundObj.Transaction_Types__c || refundObj.Transaction_Types__c == 'None'){
            errorFields.push('Transaction Type');
        }
        if(! refundObj.Amount__c){
            errorFields.push('Amount');
        }
        
        if(! attachmentFiles[0].isUploaded && !cmp.get("v.recordId")){
            errorFields.push('CEO Approval');
        }

        if(errorFields.length > 0){
            let msg = 'Following fields can not be null : '
            msg += errorFields.join(', ');
            this.showToast('error','Error',msg);
            isValid = false;
        }
        
        var maxAmount = cmp.get('v.maxVal');
        if(refundObj.Scenario__c == 'Receipt and Invoice are generated'){
            var allLines = cmp.get("v.listInvoiceWrapper");
            for(var i=0;i<allLines.length;i++){
                for(var j =0;j<allLines[i].listInvoiceLineRec.length;j++){
                    var totalLineRefundAmnt = 0.0;
                    if(allLines[i].listInvoiceLineRec[j].refundAmount){
                        totalLineRefundAmnt += parseFloat(allLines[i].listInvoiceLineRec[j].refundAmount); 
                    }
                    if(totalLineRefundAmnt > allLines[i].appliedAmount){
                        this.showToast('error','Error','Refund amount total can not be more than Total Invoice Applied Amount.');
                        isValid = false;
                    }
                }
            }
            if(refundObj.Amount__c > maxAmount){
                console.log(maxAmount);
                console.log(refundObj.Amount__c);
                this.showToast('error','Error','Refund amount can not be more than Receipt Amount.');
                isValid = false;
            }
        } else if(refundObj.Scenario__c == 'Receipt generated but invoice not generated'){
            if(refundObj.Amount__c > maxAmount){
                this.showToast('error','Error','Refund amount can not be more than Receipt Amount.');
                isValid = false;
            }
        } else if(refundObj.Scenario__c == 'Credit Memo'){
            console.log(maxAmount);
            console.log(refundObj.Amount__c);
            if(refundObj.Amount__c > maxAmount){
                this.showToast('error','Error','Refund amount can not be more than Credit Memo Amount.');
                isValid = false;
            }
        }
        
        /*if(refundObj.Scenario__c == 'Credit Memo' && refundObj.Payment_Method__c == 'Credit Card'){
            this.showToast('error','Error','For Credit Memo, Payment Method should be Bank Transfer only.');
            isValid = false;
        }*/
        
        /*if(refundObj.Payment_Method__c == 'Credit Card'){
            if(refundObj.Card_First_Last_Digit__c != cmp.get('v.ccNumber')){
                this.showToast('error','Error','Credit Card Number mismatch.');
                isValid = false;
            } 
        } */
        return isValid;
    }
})