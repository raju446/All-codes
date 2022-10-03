/**
 * @File Name          : Lex_RefundRequestController.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 09-06-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/22/2020   Jayanta Karmakar     Initial Version
**/
({
    // Onload function
    init: function (component, event, helper) 
    {
		helper.fetchPicklistValues(component, 'Refund__c','Payment_Method__c', true);
        helper.fetchPicklistValues(component, 'Refund__c','Transaction_Types__c', true);
        helper.fetchPicklistValues(component, 'Refund__c','Scenario__c', true);
        helper.fetchPicklistValues(component, 'Receipt__c','Payment_Method__c', true);
        helper.fetchPicklistValues(component,'Account', 'Oracle_Site_Id__c', false);
        helper.fetchPicklistValues(component,'Refund__c', 'Source_System__c', false);
        helper.fetchBMMetaData(component, event, helper);
        if(component.get("v.recordId") != undefined){
            helper.fetchOldRefund(component, event, helper);
            component.set("v.isEdit", true);
        }
    },
    goBack: function (cmp, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
        "recordId": cmp.get("v.recordId"),
        "slideDevName": "detail"
        });
        navEvt.fire();
    },
    onFileChange: function (cmp, event, helper) {
        helper.uploadFileOnChange(cmp, event, helper);
    },
    onSourceSystemNameChange : function (cmp, event, helper) {
        cmp.set('v.selectedReceiptLookUpRecord', {});
        cmp.set('v.selectedCreditMemoLookUpRecord', {});
        
        let refundObj = cmp.get('v.refund');
        if(refundObj.Source_System__c == 'AccessADGM'){
            cmp.set('v.receiptFilterCriteria',' AND Payment_Currency__c = \'AED\'');
        } else {
            cmp.set('v.receiptFilterCriteria',' AND Payment_Currency__c = \'USD\'');
        }
                console.log(refundObj.Source_System__c);
        if(refundObj.Source_System__c){
            cmp.set("v.isNotAuthoritySelected", false);
        }else{
            cmp.set("v.isNotAuthoritySelected", true);
        }
    },
    onCreditMemoReceiptChange: function (component, event, helper) {
        let receiptObj = component.get('v.selectedCreditMemoReceptiLookUpRecord');
        if(receiptObj.Id){
            component.set('v.refund.Credit_Memo_Receipt__c', receiptObj.Id);
            helper.showSpinner(component);
            var action = component.get("c.fetchReceiptDetails");
            action.setParams({
                'receiptId': receiptObj.Id
            });
            action.setCallback(this, function(response) {
                helper.hideSpinner(component);
                var state = response.getState();
                if (state === "SUCCESS") {
                    var responseVal = response.getReturnValue();
                    console.log(responseVal);
                    if(responseVal.length > 0){
                        component.set("v.refund.Card_First_Last_Digit__c",responseVal[0].Credit_Card_F_L_Four_Digits__c);
                        component.set("v.refund.Authorization_Code__c",responseVal[0].Authorization_Code__c);
                    }
                } else {
                    console.log("Failed with state: " + state);
                }
            });
            $A.enqueueAction(action);
        } else {
            component.set('v.refund.Credit_Memo_Receipt__c', null);
        }
    },
    oncNoChange: function (cmp, event, helper) {
       /* var inpval = cmp.get("v.refund").Card_First_Last_Digit__c;
        if(inpval.length == 4){
            inpval = inpval+"-XXXX-XXXX-";
            cmp.set("v.refund.Card_First_Last_Digit__c",inpval);
        } else if(inpval.length == 5){
            let fFour = inpval.substr(0,4);
            let fifthChar = inpval.substr(4,1);
            if(fifthChar > -1){
                inpval = fFour+"-XXXX-XXXX-"+fifthChar;
            } else {
                inpval = fFour+"-XXXX-XXXX-";
            }
            cmp.set("v.refund.Card_First_Last_Digit__c",inpval);
        } else if(inpval.length <= 14 && inpval.length > 4){
            inpval = inpval.substr(0,4);
            cmp.set("v.refund.Card_First_Last_Digit__c",inpval);
        } */
    },
    doConfirm : function (cmp, event, helper) {
        if(helper.validateRefund(cmp,event,helper)){
            cmp.set("v.isReview", true);
        }
    },
    doSave: function (cmp, event, helper) {
        helper.doSaveRecord(cmp, event, helper);
    },
    doEdit: function (cmp, event, helper) {
        cmp.set("v.isReview", false);
    },
    fetchBankDetails: function (cmp, event, helper) {
        //helper.fetchBankDetailsFromIBAN(cmp, event, helper);  
        helper.fetchBankDetailsFromIBANNew(cmp, event, helper); 
    },
    handleFilesUpload: function (component, event, helper) {
        var files=event.getParam('files');
        console.log('Files uploaded: '+JSON.stringify(files));
        var fileIds=[];
        var uploadedfIds = component.get("v.uploadedFileIds");
        files.forEach(function(file){
            fileIds.push(file.documentId);
            uploadedfIds.push(file);
        });
        console.log(uploadedfIds);
        console.log(JSON.stringify(uploadedfIds));
        component.set("v.uploadedFileIds", uploadedfIds);
    },
    onAttachmentSave: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get('v.refundId'),
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    onSourceChange : function (component, event, helper) {
        component.set('v.selectedLookUpRecord', {});
        component.set('v.selectedReceiptLookUpRecord', {});
        component.set('v.selectedCreditMemoLookUpRecord', {});
        component.set('v.receiptFilterCriteria',' AND Payment_Currency__c = \'USD\'');
        var sourceSystem = component.get('v.sourceSystem');
        //sourceSystem == '104' || 
        if(sourceSystem){
            if(sourceSystem == '101'){
                component.find('ssysnm').focus();
                component.set("v.isNotAuthoritySelected", true);
                //component.set("v.customerFilter", "{!'AND Oracle_Party_Id__c != null AND Oracle_Party_Id__c !=\''+'\' AND Source_System__c =\'' + v.refund.Source_System__c+ '\''}");
                component.set("v.customerFilter", "{!' AND Source_System__c =\'' + v.refund.Source_System__c+ '\''}");
            } else {
                component.set("v.isNotAuthoritySelected", false);
            }
            
            console.log(sourceSystem);
            var tranType = "";
            let sourceSysName = '';
            if(sourceSystem == '102'){
                tranType = "Refund-Courts";
                sourceSysName = 'BM';//'ADGM Courts';
            } else if(sourceSystem == '103'){
                tranType = "Refund-FSRA";
                sourceSysName = 'BM';//'FSRA';
            } else if(sourceSystem == '104'){
                tranType = "Refund-RA";
                sourceSysName = 'BM';
            } else if(sourceSystem == '501'){
                tranType = "Refund-ACAD";
                sourceSysName = 'BM';//'Academy';
            } else if(sourceSystem == '502'){
                tranType = "Refund-FIN"
                sourceSysName = 'BM';//'Fintech';
            } else if(sourceSystem == '701'){
                tranType = "Refund-BRID"
                sourceSysName = 'BM';//'Bridge Property';
            } else if(sourceSystem == '101'){
                tranType = "Refund-ADGM"
            } 
            component.set("v.refund.Transaction_Types__c",tranType);
            //component.set("v.refund.Transaction_Types__c",tranType);
            component.set("v.refund.Source_System__c",sourceSysName);
        } else {
            component.set("v.isNotAuthoritySelected", true);
        }
    },
    onPaymethodChange: function (cmp, event, helper) {
        let refundObj = cmp.get("v.refund");
        if(refundObj.Payment_Method__c == 'Bank Transfer'){
            cmp.set('v.refundObj.Card_First_Last_Digit__c','');
        }
    },
    onCreditMemoChange: function (cmp, event, helper) {
        if(! cmp.get("v.onLoad")){
            helper.handleCreditMemoChange(cmp, event, helper);
        }
    },
    onEntityChange : function (component, event, helper) {
        if(! component.get("v.onLoad")){
            let selectedAcc = component.get("v.selectedLookUpRecord");
            if(selectedAcc.Id){
                component.set("v.isNotAccountSelected", false);
                component.set("v.refund.Entity__c", selectedAcc.Id);
            } else {
                component.set("v.isNotAccountSelected", true);
            }
            component.set('v.selectedReceiptLookUpRecord',"");
            var invoiceWrap = component.get('v.listInvoiceWrapper');
            invoiceWrap = [];
            component.set('v.listInvoiceWrapper',invoiceWrap);
        }
    },
    onCheck : function(component, event, helper){
        console.log(event.getSource().get('v.checked'));
        console.log(event.getSource().get('v.name'));
        event.getSource().set('v.value', event.getSource().get('v.checked')); 
        
        if(event.getSource().get('v.name')){
          /*  var amnt = component.get("v.invoiceLineAmnt");
            amnt += event.getSource().get('v.name');
            component.set("v.invoiceLineAmnt", amnt); */
           /* var amnt = component.get("v.refund.Amount__c");
            amnt += event.getSource().get('v.name');     
            component.set("v.refund.Amount__c", amnt); */
        }
    },
    onScenarioChange: function (cmp, event, helper) {
        var refundObj = cmp.get('v.refund');
        if(! cmp.get("v.isOUDisabled")){
            cmp.set("v.sourceSystem","");
            cmp.set("v.refund.Source_System__c","");
            
        }
        
        if(cmp.get('v.isTransactionTypeDisabled')){
            var v = cmp.get("v.defTraType");
            console.log(v);
            cmp.set("v.refund.Transaction_Types__c",cmp.get("v.defTraType"));
            console.log('in the if condition');
        } else {
            cmp.set("v.refund.Transaction_Types__c","");
            console.log('in the else condition');
        }
        //cmp.set("v.refund.Source_System__c","");
        cmp.set("v.selectedLookUpRecord","");
        cmp.set("v.selectedReceiptLookUpRecord","");
        cmp.set("v.selectedCreditMemoLookUpRecord","");
        cmp.set("v.refund.Actual_Payment_Method__c","");
        cmp.set("v.refund.Payment_Method__c","");
        cmp.set("v.refund.Currency__c","");
        cmp.set("v.refund.Amount__c","0.0");
        cmp.set("v.refund.Description__c","");
        
        if(refundObj.Scenario__c == 'Receipt and Invoice are generated'){
            //cmp.set('v.receiptFilter','AND Total_Applied_Amount__c > 0 AND Oracle_Receipt_Id__c != null');
            cmp.set('v.receiptFilter','AND Total_Applied_Amount__c > 0');
        } else if (refundObj.Scenario__c == 'Receipt generated but invoice not generated'){
            //cmp.set('v.receiptFilter','AND Total_Applied_Amount__c = 0 AND Oracle_Receipt_Id__c != null');
            cmp.set('v.receiptFilter','AND Total_Applied_Amount__c = 0');
        }
    },
    onInputChange: function (component, event, helper) {
        console.log('input number changed called');
        console.log(event.getSource().get('v.value'));
        var allLines = component.get("v.listInvoiceWrapper");
        console.log(allLines);
        console.log(JSON.stringify(allLines));
        var amnt = 0.0;
        for(var i=0;i<allLines.length;i++){
            for(var j =0;j<allLines[i].listInvoiceLineRec.length;j++){
                if(allLines[i].listInvoiceLineRec[j].refundAmount){
                    if(allLines[i].listInvoiceLineRec[j].refundAmount <= allLines[i].listInvoiceLineRec[j].InvoiceLineRec.Calculated_Amount__c){
                        amnt += parseFloat(allLines[i].listInvoiceLineRec[j].refundAmount); 
                    }
                }
            }
        }
        //var amnt = parseFloat(component.get("v.refund.Amount__c"));
        //amnt += parseFloat(event.getSource().get('v.value')); 
        component.set("v.refund.Amount__c", amnt);
    },
    onShowInvoiceLine : function(component, event, helper) {
        var selectedIndex = event.getSource().get("v.name");
        if(component.get("v.selectedInvoice") == selectedIndex) {
            component.set("v.selectedInvoice", -1);
        } else {
            component.set("v.selectedInvoice", selectedIndex);
        } 
    },
    doShowInvoice : function (component, event, helper){
        if(component.get('v.selectedReceiptLookUpRecord').Id === undefined){
            var invoiceWrap = component.get('v.listInvoiceWrapper');
            invoiceWrap = [];
            component.set('v.listInvoiceWrapper',invoiceWrap);
            component.set('v.refund.Amount__c',0.0);
            component.set('v.refund.Payment_Method__c',null);
            component.set('v.refund.Currency__c',null);
            component.set("v.refund.Actual_Payment_Method__c","");
            if(! component.get('v.isTransactionTypeDisabled')){
                component.set("v.refund.Transaction_Types__c","");
            }
            component.set('v.refund.Receipt__c',null);
        }else{
            component.set('v.refund.Receipt__c',component.get('v.selectedReceiptLookUpRecord').Id);
            if(component.get("v.refund").Scenario__c == "Receipt and Invoice are generated" && !component.get("v.onLoad")){
                helper.fetchInvoice(component, event, helper,component.get('v.selectedReceiptLookUpRecord').Id);
            }
            if(! component.get("v.onLoad")){
                helper.fetchReceiptPaymentMethod(component, event, helper);
            }
            
        }
    },
	saveAction : function(component, event, helper) {
        
       
        
        var inputComponent		 = [component.find('Currency Type'),component.find('Amount'),component.find('BankName'),component.find('BankBranch'),component.find('IBAN')];
        var nullValuemessage;
        
        
        //Null value and white space Checker
        for (var i =0 ; i<inputComponent.length ; i++){
            if(inputComponent[i].get('v.validity').valueMissing || !inputComponent[i].get('v.value').trim() ){
                
                    $A.util.addClass(inputComponent[i], 'slds-has-error');
                    if(nullValuemessage === undefined){
                        nullValuemessage = inputComponent[i].get("v.label");
                    }else{
                        nullValuemessage += ', ' + inputComponent[i].get("v.label");
                    }
                
            }
         }
        
        //Null value Checker for lookup
		if(component.get('v.selectedLookUpRecord').Id === undefined){
			$A.util.addClass(component.find('customer').sendComponent(), 'slds-has-error');
			if(nullValuemessage === undefined){
				nullValuemessage = component.find('customer').get("v.label").replace('*','');
			}else{
				nullValuemessage += ', ' + component.find('customer').get("v.label").replace('*','');
			}
         }
        
        //Null value Checker for file attachement
        if (!component.get("v.fileAttached")){
            if(nullValuemessage === undefined){
				nullValuemessage = 'Bank account confirmation';
			}else{
				nullValuemessage += ', Bank account confirmation' ;
			}
                 $A.util.addClass(component.find('file-input') , 'errorInputFile');
                
        }
        
        
        if(nullValuemessage === undefined ){
           
            if (component.get("v.Amount") <= 0){
                
                helper.showTostMSG(component, event, 'error' , 'Please enter amount greater that 0');
                 
            }else{
                var records = component.get("v.receipt");
                records.Entity__c = component.get('v.selectedLookUpRecord').Id;
                
                component.set("v.Spinner", true); 
                var files = component.get("v.fileToBeUploaded");
                var file = files[0][0];
             	var action = component.get("c.createRefundReceipt");
                action.setParams({
                    
                    objRefundReceipt : records,
                    fileName	   : file.name,
            		base64Data	   : component.get("v.filedata")
                    
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (component.isValid() && state === "SUCCESS") {
                        
                        var conts = response.getReturnValue();
                        console.log(conts);
                        if(conts.returnMessage === 'success'){
                            component.set("v.Spinner", false); 
                            helper.showTostMSG(component, event, 'Success' , 'Refund Request Successful');
                            $A.get('e.force:refreshView').fire();
                            component.find("navId").navigate({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId : conts.returnID, 
                                actionName: 'view',  
                                objectApiName: 'Receipt__c' 
                            }}, true);
                        }else{
                            component.set("v.Spinner", false); 
                            helper.showTostMSG(component, event, 'error' , "Refund Request Error");
                            
                        }
                        
                    }
                    else {
                        component.set("v.Spinner", false); 
                        console.log("Failed with state: " + state);
                        helper.showTostMSG(component, event, 'error' , "Failed with state: " + state);
                    }
                });
               
           		 $A.enqueueAction(action);   
            }
        }else{
             helper.showTostMSG(component, event, 'error' , "Please input " + nullValuemessage);
            
        }
            
    },
    
    Cancel: function(component, event, helper) {
        
        $A.get('e.force:refreshView').fire();
        var navEvent = $A.get("e.force:navigateToList");
        navEvent.setParams({
            "listViewId": "00B0Y000007ueiYUAQ",
            "listViewName": null,
            "scope": "Receipt__c"
        });
        navEvent.fire();
          
     },
        
		
    
    handleChange: function (component, event) {
        component.set("v.currencySelected",event.getParam("value"));
    },
    
    Clear : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
          
     },
    
  
   onFileUploaded:function(component,event,helper){
        
       var files = component.get("v.fileToBeUploaded");
       console.log(files);
       console.log(files[0][0].size);
       console.log(files.length);
       if(files[0][0].size == 0) {
           $A.util.addClass(component.find('file-input') , 'errorInputFile');
           helper.showTostMSG(component, event, 'error' , 'File is empty');
       }else if (files && files.length == 1 && files[0].length == 1 && files[0][0].size < 4000000 ) {
           var file = files[0][0];
           //console.log(file);
           var reader = new FileReader();
           reader.onloadend = function() {
               var dataURL = reader.result;
               var content = dataURL.match(/,(.*)$/)[1];
               component.set("v.filedata",content); 
           }
           reader.readAsDataURL(file);
           component.find("file-input").set("v.disabled", true);
           component.set("v.selectedFileName", files[0][0].name);
           component.set("v.fileAttached",true); 
           $A.util.removeClass(component.find('file-input') , 'errorInputFile');
       }else if (files[0][0].size > 4000000){
           $A.util.addClass(component.find('file-input') , 'errorInputFile');
           helper.showTostMSG(component, event, 'error' , 'File size too big');
           
       }else{
           
           $A.util.addClass(component.find('file-input') , 'errorInputFile');
           helper.showTostMSG(component, event, 'error' , 'Please Select only one file ');
       }
       
              
        
    },
    
    handleRemove:function(component,event,helper){
        
       component.set("v.fileAttached",false); 
       console.log(component.get("v.fileToBeUploaded"));
       component.find("file-input").set("v.disabled", false);
       
        
    },
    
})