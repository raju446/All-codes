/**
 * @File Name          : LEX_FundTransferHelper.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 5/27/2020, 3:57:23 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/12/2020   Jayanta Karmakar     Initial Version
**/
({
    fetchOldFundTransfer : function(component, event, helper){
        var action = component.get("c.getOldData");
        // set parameter
        action.setParams({
            'fundTransferId': component.get("v.recordId")//'a2c25000000Rq7dAAC'
        });
        
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                debugger;
                console.log(JSON.stringify(response.getReturnValue()));
                console.log(response.getReturnValue());
                component.set("v.canFetchReceiptDetails",false);
                
                component.set("v.selectedGoldenRecord", response.getReturnValue().selectedGoldenEntity);
                component.set("v.selectedReferenceReceipt", response.getReturnValue().selectedReceipt);
                component.set("v.receiptBalance", response.getReturnValue().selectedReceipt.Remaning_Amount__c);
                component.set("v.selectedFromOU", response.getReturnValue().objFund_Transfer.FromOU__c);
                component.set("v.selectedToOU", response.getReturnValue().objFund_Transfer.ToOU__c);
                component.set("v.fundTransferObj", response.getReturnValue().objFund_Transfer);
                
                console.log("------------------------");
                console.log(response.getReturnValue().objFund_Transfer.Scenario__c);
                if(response.getReturnValue().objFund_Transfer.Scenario__c == 'Unidentified Customer Fund Transfer'){
                    component.set("v.selectedUnidentifiedEntity", response.getReturnValue().selectedFromEntity);
                    component.set("v.selectedIdentifiedEntity", response.getReturnValue().selectedToEntity);
                } else {
                    component.set("v.selectedLookUpRecordFrom", response.getReturnValue().selectedFromEntity);
                    component.set("v.selectedLookUpRecordTo", response.getReturnValue().selectedToEntity);
                }
                component.set("v.isNotReceiptSelected",false);
               // component.set("v.isGLDateNotSelected",false);
                this.handleEntityValueChange(component, event, helper);
                if(response.getReturnValue().objFund_Transfer.Pushed_To_Oracle__c){
                    component.set('v.isReview',true);
                    this.showToast(component, event, helper,'warning','Warning','Record Already Pushed to Oracle');
                }
			} else {
				console.log("Failed with state: " + state);
			}
		});
       // -component.set("v.Spinner", false);
		$A.enqueueAction(action);
    }, 
    
	
    fetchPicklistValues : function(component,helper,objectApiName, fieldAPIName, isnullRequired) {
		var action = component.get("c.fetchPicklistVal");
		// set parameter
        action.setParams({
            'objectApi': objectApiName,
            'fieldAPIname': fieldAPIName,
            'nullRequired': isnullRequired 
        });
        helper.showSpinner(component);
        action.setCallback(this, function(response) {
			var state = response.getState();
            helper.hideSpinner(component);
			if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                if(fieldAPIName == 'Scenario__c'){
                    component.set("v.scenarios", response.getReturnValue());
                } else if(fieldAPIName == 'Oracle_Site_Id__c'){
                    component.set("v.ouList", response.getReturnValue());
                } else if(fieldAPIName == 'From_Source_System__c'){
                    component.set("v.sourceSystems", response.getReturnValue());
                }
                    
			} else {
				console.log("Failed with state: " + state);
			}
		});
       // -component.set("v.Spinner", false);
		$A.enqueueAction(action);
    },
    
    fetchRelatedEntitiesToGoldenEntity : function(component, event, helper){
        var v = component.get("v.selectedGoldenRecord");
        
        if(!v.Id){
            component.set('v.isNotGoldenESelected', true);
        } else {
            component.set('v.isNotGoldenESelected', false);
        }
        console.log(JSON.stringify(v));
        var ft = component.get('v.fundTransferObj');
        console.log(JSON.stringify(ft));
        var isRegistered = false;
        if(ft.Scenario__c == 'Payment in one currency and services in other currency | Same OU'){
            isRegistered = true;
        }
        var action = component.get("c.fetchChildAccounts");
        helper.showSpinner(component);
        action.setParams({
            'goldenEntityId': v.Id,
            'isOnlyRegistered': isRegistered  
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(response.getState());
            helper.hideSpinner(component);
			if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                console.log(component.get("v.childAccouns"));
                var returnVal = response.getReturnValue();
                if(returnVal.length > 0){
                    for(let i=0;i<returnVal.length;i++){
                        if(returnVal[i].Record_Type_Name__c == 'ADGM_Registered_Company'){
                            returnVal[i].sSystem = 'RA';  
                        } else if (returnVal[i].Record_Type_Name__c == 'ADGM_Academy'){
                            returnVal[i].sSystem = 'Academy';
                        } else if (returnVal[i].Record_Type_Name__c == 'ADGM_Arbitration_Center'){
                            returnVal[i].sSystem = 'Arbitration Center';
                        } else if (returnVal[i].Record_Type_Name__c == 'ADGM_Courts'){
                            returnVal[i].sSystem = 'Courts';
                        } else if (returnVal[i].Record_Type_Name__c == 'ADGM_Fintech'){
                            returnVal[i].sSystem = 'Fintech';
                        } else if (returnVal[i].Record_Type_Name__c == 'ADGM_FSRA'){
                            returnVal[i].sSystem = 'FSRA';
                        } else if (returnVal[i].Record_Type_Name__c == 'Bridge_Property'){
                            returnVal[i].sSystem = 'Bridge Property';
                        } else if (returnVal[i].Record_Type_Name__c == 'ADGM_Guest'){
                            returnVal[i].sSystem = 'Guest';
                        } 
                    }
                    
                    if(ft.Scenario__c == 'Payment in one currency and services in other currency | Different OU'){
                        var hasRegistered = false;
                        for(let i=0;i<returnVal.length; i++){
                            if(returnVal[i].Record_Type_Name__c == 'ADGM_Registered_Company'){
                                hasRegistered = true;
                                break;
                            }
                        }
                        if(hasRegistered){
                            component.set("v.childAccouns", returnVal);
                        } else {
                            this.showToast(component, event, helper,'warning','Warning','No OU wiht AED Receipt Found');
                        }
                    } else {
                        component.set("v.childAccouns", returnVal);
                    }
                } else {
                    if(v.Id){
                        this.showToast(component, event, helper,'warning','Warning','No Record Found');
                    }
                }
			} else {
				console.log("Failed with state: " + state);
			} 
		});
		$A.enqueueAction(action);
    },
    fetchReceiptBalance: function (cmp, event, helper) {
        var selectedReceipt = cmp.get("v.selectedReferenceReceipt");
        console.log(JSON.stringify(selectedReceipt));
        if(selectedReceipt.Id){
            cmp.set('v.isNotReceiptSelected', false);
            //cmp.set("v.isGLDateNotSelected",false);
            var action = cmp.get("c.fetchReceiptBalance");
            helper.showSpinner(cmp);
            action.setParams({
                'receiptId': selectedReceipt.Id 
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(response.getState());
                helper.hideSpinner(cmp);
                if (state === "SUCCESS") {
                    console.log(response.getReturnValue());
                    var resp = response.getReturnValue();
                    cmp.set("v.receiptBalance", resp.Remaning_Amount__c); //Receipt_Balance__c
                    var fundTransferObj = cmp.get("v.fundTransferObj");
                    fundTransferObj.Amount__c = resp.Remaning_Amount__c; //Receipt_Balance__c
                    fundTransferObj.From_Currency__c = resp.Payment_Currency__c;
                    if(fundTransferObj.Scenario__c == 'Payment in one currency and services in other currency | Same OU'){
                        if(fundTransferObj.From_Currency__c == 'AED'){
                            fundTransferObj.To_Currency__c = 'USD';
                        } else {
                            fundTransferObj.To_Currency__c = 'AED';
                        }
                    } else if(fundTransferObj.Scenario__c == 'Payment in one currency and services in other currency | Different OU'){
                        cmp.set("v.fundTransferObj.To_Currency__c", 'USD');    
                    }else {
                        fundTransferObj.To_Currency__c = resp.Payment_Currency__c;
                    }
                    cmp.set("v.fundTransferObj", fundTransferObj);
                } else {
                    console.log("Failed with state: " + state);
                } 
            });
            $A.enqueueAction(action);
        } else {
            var ft = cmp.get('v.fundTransferObj');
            ft.Amount__c = 0.0
            ft.To_Currency__c = null;
            ft.From_Currency__c = null;
            ft.Description__c = null;
            cmp.set("v.fundTransferObj", ft);
            cmp.set("v.receiptBalance", 0.0);
            cmp.set('v.isNotReceiptSelected', true);
            cmp.set("v.isGLDateNotSelected",true);
        }
    },
    handleEntityValueChange: function (cmp, event, helper) {
        var fundTransferObj = cmp.get("v.fundTransferObj");
        console.log(JSON.stringify(fundTransferObj));
        if(fundTransferObj.Scenario__c == 'Payment in one currency and services in other currency | Same OU'){
            if(fundTransferObj.From_Entity__c){
                fundTransferObj.To_Entity__c = fundTransferObj.From_Entity__c;
                cmp.set("v.fundTransferObj", fundTransferObj);
                cmp.set("v.isEntitiesSelected", false);
            }
        }
        else if(fundTransferObj.From_Entity__c && fundTransferObj.To_Entity__c){
            var ft = cmp.get('v.fundTransferObj');
            if(ft.Scenario__c == 'Customer Paid in AED and wants to use services in USD(Same OU)'){
                cmp.set("v.isEntitiesSelected", false);
            } else if(fundTransferObj.From_Entity__c == fundTransferObj.To_Entity__c){
                helper.showToast(cmp, event, helper,"error","Error","From and To Entity can not be same.");
                fundTransferObj.To_Entity__c = null;
                cmp.set("v.fundTransferObj", fundTransferObj);
            } else{
                cmp.set("v.isEntitiesSelected", false);
            }
        } else {
            cmp.set("v.isEntitiesSelected", true);
        }
    },
    doSaveRecord : function(component, event, helper){
        var fundTransferObjRec = component.get("v.fundTransferObj");
        var referenceReceiptRec = component.get("v.selectedReferenceReceipt");
        console.log(JSON.stringify(referenceReceiptRec));
        fundTransferObjRec.Reference_Receipt__c = referenceReceiptRec.Id;
        var action = component.get("c.saveFundTransfer");
        action.setParams({
            'ftObj': fundTransferObjRec,
            'attachmentFiles' : component.get('v.uploadedFiles') 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(response.getState());
			if (state === "SUCCESS") {
                if(response.getReturnValue().isSuccess){
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                    "recordId": response.getReturnValue().message,
                    "slideDevName": "detail"
                    });
                    navEvt.fire();
                } else {
                    helper.showToast(component, event, helper,'error', 'Error', response.getReturnValue().message);
                }
			} else {
				console.log("Failed with state: " + state);
			} 
		});
		$A.enqueueAction(action);
    },

    handleOnChangeScenario: function (cmp, event, helper) {
        cmp.set('v.selectedGoldenRecord',{});
        cmp.set('v.selectedReferenceReceipt', {});
        cmp.set('v.selectedFromOU', null);
        cmp.set('v.selectedToOU', null);
        var ft = cmp.get('v.fundTransferObj');
        var newFT = {'sobjectType': 'Fund_Transfer__c', 'Amount__c':0.0, 'Status__c':'Draft', 'Scenario__c': ft.Scenario__c};
        cmp.set("v.fundTransferObj", newFT);
        if(ft.Scenario__c == 'Payment in one currency and services in other currency | Different OU'){
            cmp.set('v.receiptFilterCriteria','AND Payment_Currency__c = \'AED\'');
            cmp.set("v.fundTransferObj.To_Currency__c", 'USD');
            cmp.set('v.selectedFromOU','104');
            cmp.set('v.fundTransferObj.From_Source_System__c','AccessADGM');
        } else {
            cmp.set('v.receiptFilterCriteria','');
        }
        
        if(ft.Scenario__c == 'Payment in one currency and services in other currency | Same OU' || ft.Scenario__c == 'Payment in one currency and services in other currency | Different OU' || 
        ft.Scenario__c == 'Unidentified customer balance transfer' || !ft.Scenario__c || ft.Scenario__c == 'None'){
            cmp.set('v.isToCurrencyReadonly', true);
        } else {
            cmp.set('v.isToCurrencyReadonly', false);
        }
        
        if(ft.Scenario__c == 'Payment in one currency and services in other currency | Same OU'){
            cmp.set('v.selectedFromOU','104');
            cmp.set('v.selectedToOU','104');
            
        } 
        
        if(ft.Scenario__c == 'Unidentified customer balance transfer'){
            cmp.set('v.isNotGoldenESelected',false);
        } else {
            cmp.set('v.isNotGoldenESelected',true);
        }
    },
    
    showToast: function(component, event, helper, type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message
        });
        toastEvent.fire();
    },
    validateRecord: function (cmp, event, helper) {
        var ft = cmp.get('v.fundTransferObj');
        var hasError = false;
        if(! ft.From_Currency__c){
            var domComp = cmp.find("frmcurrency");
            domComp.showHelpMessageIfInvalid();
            hasError = true;
        }
        
        if(! ft.To_Currency__c){
            var domComp = cmp.find("tocurrency");
            domComp.showHelpMessageIfInvalid();
            hasError = true;
        }

        if(ft.Amount__c > 0){
            var domComp = cmp.find("amnt");
            var v1 = domComp.checkValidity();
            if(!v1){
                domComp.showHelpMessageIfInvalid();
                hasError = true;
            }
        }
        
        if(! ft.From_Entity__c){
            helper.showToast(component, event, helper, 'error', 'Error', 'You must select Source Entity');
            hasError = true;
        }
        
        if(! ft.To_Entity__c){
            helper.showToast(component, event, helper, 'error', 'Error', 'You must select Receiving Entity');
            hasError = true;
        }
        
        if(ft.From_Currency__c == 'AED' && ft.From_Source_System__c != 'AccessADGM'){
            helper.showToast(component, event, helper, 'error', 'Error', 'You must select AED Source System');
            hasError = true;
        }
        
        if(ft.To_Currency__c == 'AED' && ft.To_Source_System__c != 'AccessADGM'){
            helper.showToast(component, event, helper, 'error', 'Error', 'You must select AED Source System');
            hasError = true;
        }

        //return hasError;
        return false;
    },
    
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
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
            this.showToast(cmp, event, helper, 'error','Error','File size is too big.');
            return;
        }  
        
        var fileReader = new FileReader();        
        fileReader.readAsDataURL(file);          
        fileReader.onload = function () {                
            var fileContentBase64 = fileReader.result.split('base64,')[1]; 
            fileAttribute[0].blobval = fileContentBase64;
            fileAttribute[0].fileName = file.name;
            fileAttribute[0].isUploaded = true;
            cmp.set("v.uploadedFiles",fileAttribute);
            console.log(cmp.get("v.uploadedFiles"));
            console.log(fileContentBase64);
            helper.hideSpinner(cmp);
        }
    },
})