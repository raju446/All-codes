({
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
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
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
                    
                    if(cmp.get('v.selectedCurrency') == 'Funds Transfer in same currency'){
                        fundTransferObj.To_Currency__c = fundTransferObj.From_Currency__c;
                    }else{
                        if(fundTransferObj.From_Currency__c == 'AED'){
                            fundTransferObj.To_Currency__c = 'USD';
                        }else if(fundTransferObj.From_Currency__c == 'USD'){
                            fundTransferObj.To_Currency__c = 'AED';
                        }
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
    handleCurrencyChange : function(component, event, helper){
        let fundTransferObj = component.get('v.fundTransferObj');
        //console.log(component.get('v.selectedToOU') == '104');
        //console.log(fundTransferObj.From_Source_System__c);
        if(component.get('v.selectedCurrency') == 'Funds Transfer in same currency'){
            if(component.get('v.selectedToOU') == '104'){
                if(fundTransferObj.From_Source_System__c == 'Catalyst'){
                    fundTransferObj.To_Source_System__c = 'Catalyst';
                }else if(fundTransferObj.From_Source_System__c == 'Access'){
                    console.log(fundTransferObj.From_Source_System__c == 'Access');
                    fundTransferObj.To_Source_System__c = 'Access';
                }
            }
            fundTransferObj.To_Currency__c = fundTransferObj.From_Currency__c;
        }else{
            if(component.get('v.selectedToOU') == '104'){
                if(fundTransferObj.From_Source_System__c == 'Catalyst'){
                    fundTransferObj.To_Source_System__c = 'Access';
                }else if(fundTransferObj.From_Source_System__c == 'Access'){
                    fundTransferObj.To_Source_System__c = 'Catalyst';
                }
            }
            if(fundTransferObj.From_Currency__c == 'AED'){
                fundTransferObj.To_Currency__c = 'USD';
            }else if(fundTransferObj.From_Currency__c == 'USD'){
                fundTransferObj.To_Currency__c = 'AED';
            }
        }
        component.set('v.fundTransferObj', fundTransferObj);
    },
    showToast: function(component, event, helper, type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message,
            duration: '1000'
        });
        toastEvent.fire();
    },
    validateRecord: function (cmp, event, helper) {
        var ft = cmp.get('v.fundTransferObj');
        var hasError = false;
        
        if(ft.To_Entity__c == null){
            helper.showToast(cmp, event, helper, 'error', 'Error', 'To Entity cannot be blank.');
            return true;
        }
        
        if(ft.Amount__c > 0){
            var domComp = cmp.find("amnt");
            var v1 = domComp.checkValidity();
            if(!v1){
                domComp.showHelpMessageIfInvalid();
                return true;
            }
        }
        
        if(cmp.get('v.selectedCurrency') == 'Funds Transfer in same currency' && cmp.get('v.selectedOU') == 'Same Operating Unit' && ft.From_Entity__c == ft.To_Entity__c){
            helper.showToast(cmp, event, helper, 'error', 'Error', 'From Entity and To Entity cannot be same.');
            var selectedToEntity = cmp.find('toCustomer');
        	selectedToEntity.clearValues();
            return true;
        }
        
        
        /*if(! ft.From_Currency__c){
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

        //return hasError;*/
        return false;
    },
    doSaveRecord : function(component, event, helper){
        var fundTransferObjRec = component.get("v.fundTransferObj");
        var referenceReceiptRec = component.get("v.selectedReferenceReceipt");
        console.log(JSON.stringify(referenceReceiptRec));
        fundTransferObjRec.Reference_Receipt__c = referenceReceiptRec.Id;
        var action = component.get("c.saveFundTransfer");
        action.setParams({
            'ftObj': fundTransferObjRec,
            'currencyScenario' : component.get('v.selectedCurrency'),
            'ouScenario' : component.get('v.selectedOU'),
            'attachmentFiles' : component.get('v.uploadedFiles') 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(response.getState());
			if (state === "SUCCESS") {
                console.log('response==>>', response);
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
    }
})