/**
 * @File Name          : Lex_CreditMemoController.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 09-06-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/20/2020   Jayanta Karmakar     Initial Version
**/
({
    // Onload function
    init: function (component, event, helper) {
        //$A.get('e.force:refreshView').fire();
		var myPageRef = component.get("v.pageReference");
        var recordId = myPageRef.state.c__recordId;
        if(recordId!= undefined){
            
            component.set("v.recordId", recordId);
            component.set("v.isRecordEdit", true);
            component.set("v.showPushToOracle", false);
            
        }
    	
        //Merul
         helper.fetchPicklistValues(component,event,helper,'Account', 'Oracle_Site_Id__c', false);   
        console.log(recordId);
        
        if(component.get("v.recordId") != '' && component.get("v.recordId") != undefined){
             helper.fetchOldData(component, event, helper,component.get("v.recordId"));
            
        }
        helper.getUserProfile(component, event, helper);
        helper.fetchBMMetaData(component, event, helper);
        
    },
    onScenarioChange : function (cmp, event, helper) {
        //alert(cmp.get("v.selectedScenario") );
        if(cmp.get("v.selectedScenario") == 'Invoice Not Paid / Partially Paid') {
            cmp.set("v.showInvoiceSelection", true);
        } else {
            cmp.set("v.showInvoiceSelection", false);
        }
    },
    doConfirm : function (cmp, event, helper) {
        cmp.set("v.isReview", true);
    },
    doEdit: function (cmp, event, helper) {
        cmp.set("v.isReview", false);
    },
    onEntityChange : function(component, event, helper) {
        console.log(component.get('v.selectedLookUpRecord'));
        if(component.get('v.selectedLookUpRecord').Id === undefined){
            var creditMemoRec = component.get("v.creditMemo");
            creditMemoRec.Oracle_Invoice_Type__c = '';
            component.set("v.creditMemo", creditMemoRec);
            var invoiceWrap = component.get('v.selectedInvoiceLookUp');
            invoiceWrap = "";//[];
            component.set('v.selectedInvoiceLookUp',invoiceWrap);
            
        } else {
            helper.fetchRevenue(component, event, helper);
        }
    },
    onShowInvoiceLine : function(component, event, helper) {
        var selectedIndex = event.getSource().get("v.name");
        if(component.get("v.selectedInvoice") == selectedIndex) {
            component.set("v.selectedInvoice", -1);
        } else {
            component.set("v.selectedInvoice", selectedIndex);
        } 
    },
    onTypeChange : function (component, event, helper){
		var creditMemoRec = component.get("v.creditMemo");
        //alert(creditMemoRec.Oracle_Invoice_Type__c);
        if(creditMemoRec.Oracle_Invoice_Type__c){
            component.set('v.isInvoiceTypeNotSelected', false);
        } else {
            component.set('v.isInvoiceTypeNotSelected', true);
        }
        if(creditMemoRec.Oracle_Invoice_Type__c == '') {
            //alert('on type change');
            //var invoiceWrap = component.get('v.selectedInvoiceLookUp');
            //invoiceWrap = [];
            //component.set('v.selectedInvoiceLookUp',invoiceWrap);
        }
    },
    doShowInvoice : function (component, event, helper){
        var invoiceRec = [];
        invoiceRec = component.get('v.selectedInvoiceLookUp');
        //alert(component.get('v.selectedInvoiceLookUp'));
        if(component.get('v.selectedInvoiceLookUp') === undefined || component.get('v.selectedInvoiceLookUp') == ''){
            //helper.showToast('error', 'Error!', 'Please select receipt first');
            var invoiceWrap = component.get('v.invoiceLineItems');
            invoiceWrap = [];
            component.set('v.invoiceLineItems',invoiceWrap);
        }else if(component.get('v.onLoadStart') == false){
            
            helper.fetchLineItem(component, event, helper,component.get('v.selectedInvoiceLookUp').Id, null);
        }
    },
    doShowInvoiceLine : function(component, event, helper) {
        if(component.get('v.selectedInvoiceLookUp').length <= 0){
            helper.showToast('error', 'Error!', 'Please select invoices');
            component.set('v.showInvoiceSelectionTable', false);
        }else {
            
           component.set('v.showInvoiceSelectionTable', true);  
            
        	helper.fetchLineItem(component, event, helper, component.get('v.selectedInvoiceLookUp').Id, null);
        }
    },
    onClickInvoice : function(component, event, helper) {
        var selectedIndex = event.getSource().get("v.name");
        if(component.get("v.selectedInvoice") == selectedIndex) {
            component.set("v.selectedInvoice", -1);
        } else {
            component.set("v.selectedInvoice", selectedIndex);
        } 
    },
    onCheck : function(component, event, helper){
        console.log(event.getSource().get('v.checked'));
        event.getSource().set('v.value', event.getSource().get('v.checked')); 
    },
    onUnitChange : function (component, event, helper) {
        component.set('v.selectedLookUpRecord', ""); 
        if(component.get('v.selectedOU') == undefined || component.get('v.selectedOU') == '--None--'  || component.get('v.selectedOU') == ""){
            component.set('v.unitSelected' , true);
            helper.showToast('error', 'Error!', 'Please select operating unit');
            component.set('v.isSourceNotSelected' , true);
        }else{
            helper.setSourceSystemVal(component, event, helper);
            component.set('v.isSourceNotSelected' , false);
            component.set('v.unitSelected' , false);
            var sourceSyslist = [];
            component.set("v.sourceSystemList",sourceSyslist);
            var selectedOU =  component.get("v.selectedOU");
            var sourceSys ;
            if(selectedOU == '104') {
                sourceSys = {  picklistLabel : "BM",  picklistVal  : "BM"};
                sourceSyslist.push(sourceSys);
            }
            if(selectedOU == '501') {
                sourceSys = {  picklistLabel : "BM",  picklistVal  : "BM"};
                sourceSyslist.push(sourceSys);
            }
            
            if(selectedOU == '502') {
                sourceSys = {  picklistLabel : "BM",  picklistVal  : "BM"};
                sourceSyslist.push(sourceSys);
            }
            if(selectedOU == '701') {
                sourceSys = {  picklistLabel : "BM",  picklistVal  : "BM"};
                sourceSyslist.push(sourceSys);
            }
            if(selectedOU == '102') {
                sourceSys = {  picklistLabel : "BM",  picklistVal  : "BM"};
                sourceSyslist.push(sourceSys);
            }
            if(selectedOU == '103') {
                sourceSys = {  picklistLabel : "BM",  picklistVal  : "BM"};
                sourceSyslist.push(sourceSys);
            }
            
            if(selectedOU == '101') {
                console.log('-----------------OU Change method called---------------------');
                component.set('v.isSourceNotSelected' , true);
                sourceSys = {  picklistLabel : "BM - ADGM",  picklistVal  : "BM - ADGM"};
                sourceSyslist.push(sourceSys);
                sourceSys = {  picklistLabel : "BM - Arbitration",  picklistVal  : "BM - Arbitration"};
                sourceSyslist.push(sourceSys);
                component.set("v.customerFilter", "{!'AND Oracle_Party_Id__c != null AND Oracle_Party_Id__c !=\''+'\' AND Source_System__c =\'' + v.sourceSystem+ '\''}");
            }
            
            component.set("v.sourceSystemList",sourceSyslist);
            //helper.fetchRevenue(component, event, helper,component.get('v.selectedOU'));
        }
        
    },
    
    onSourceChange : function (component, event, helper) {
        if(component.get('v.sourceSystem') == undefined || component.get('v.sourceSystem') == '--None--'  || component.get('v.sourceSystem') == ""){
            component.set('v.isSourceNotSelected' , true);
            helper.showToast('error', 'Error!', 'Please select source system name');
        }else{
            component.set('v.isSourceNotSelected' , false);
            //helper.fetchRevenue(component, event, helper,component.get('v.selectedOU'));
        }
        
    },
    handleEntityChange: function (cmp, event, helper) {
        var selEntity = cmp.get('v.selectedLookUpRecord');
        console.log(JSON.stringify(selEntity));
        if(selEntity.Id){
            cmp.set('v.isEntityNotSelected',false);
        } else {
            cmp.set('v.isEntityNotSelected',true);
        }
    },
	saveAction : function(component, event, helper) {
        
        var isValid = helper.validate(component, event, helper);

        console.log('isValid '+isValid);

        var rec = [];
        rec = component.get("v.invoiceLineItems");
        var nullValuemessage;
        console.log(rec);
        if(component.get('v.selectedLookUpRecord').Id === undefined){
            $A.util.addClass(component.find('customer').sendComponent(), 'slds-has-error');
            if(nullValuemessage === undefined){
                nullValuemessage = component.find('customer').get("v.label").replace('*','');
            }else{
                nullValuemessage += ', ' + component.find('customer').get("v.label").replace('*','');
            }
        }
        if(isValid){
            if( component.get("v.selectedScenario") == 'Invoice Not Paid / Partially Paid' && component.get('v.creditMemo.Oracle_Invoice_Type__c') == undefined || component.get('v.creditMemo.Oracle_Invoice_Type__c') == '--Noon--'){
                helper.showToast('error', 'Error!', 'Please select Invoice Type');
            }else if(component.get('v.creditMemo.Payment_Currency__c') == undefined || component.get('v.creditMemo.Payment_Currency__c') == '--Noon--'){
                helper.showToast('error', 'Error!', 'Please add Payment Currency');
            } else if((component.get('v.inAmount') == undefined || component.get('v.inAmount') == null || component.get('v.inAmount') <= 0) && component.get("v.selectedScenario") != 'Invoice Not Paid / Partially Paid'){
                helper.showToast('error', 'Error!', 'Please add correct amount');
            } else if(nullValuemessage === undefined ){
                //alert(component.get('v.inAmount'));
                component.set("v.isReview", true);
                console.log('-----------about to call the helper-----------');
                helper.saveRec(component, event, helper, component.get('v.creditMemo'),component.get("v.invoiceLineItems"), component.get('v.selectedLookUpRecord').Id, component.get('v.inAmount'),  component.get("v.selectedScenario"));
            }
        }
        
    },
    pushToOracle : function(component, event, helper) {
        var puchToOracle = false;
        if(component.get("v.Name") == 'ADGM Finance Manager')
            puchToOracle = true;
        component.set("v.Spinner", true); 
        var action = component.get("c.pushMemoToOracle");
		// set parameter
        action.setParams({
            'creditMemoId' : component.get('v.creditMemo').Id,
            'isPushToOracle' : puchToOracle
        });
        //component.set("v.Spinner", false);
        action.setCallback(this, function(response) {
			var state = response.getState();
            component.set("v.Spinner", false);
			if (state === "SUCCESS" ) {
                if(response.getReturnValue() == "Success") {
                    helper.showToast('success', 'Success!', 'Credit Memo submitted for approval');
                    component.set('v.sourceSystem', '--None--');
                    component.set("v.onLoadStart", true);
                    //component.set("v.creditMemo", "{'sobjectType': 'Invoice__c','Oracle_Invoice_Type__c': '','Status__c': 'Draft','Entity__c': '','Payment_Currency__c' : ''}");
                    component.set("v.showInvoiceSelectionTable",false );
                    component.set("v.selectedLookUpRecord", "");
                    //component.set("v.selectedInvoiceLookUp", "[]");
                    component.set("v.selectedInvoiceLookUp", "");
                    component.set("v.invoiceLineItems", "[]");
                    component.set("v.isReview", false);
                    component.set("v.showPushToOracle", false);
                    
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get('v.creditMemo').Id,
                        "slideDevName": "related"
                    });
                    navEvt.fire();
                    
                }
					
                else 
                    helper.showToast('error', 'Error!', response.getReturnValue());
			} else {
				console.log("Failed with state: " + state);
			}
            component.set("v.Spinner", false);
		});
       // component.set("v.Spinner", false);
		$A.enqueueAction(action);
    },
    close: function(component, event, helper) {
        
          
     },
		
    handleChange: function (component, event) {
        component.set("v.currencySelected",event.getParam("value"));
    },
    
    checkboxSelect: function(component, event, helper) {
        component.set("v.checkBoxValue",event.getSource().get('v.checked'));
   
	},
    
    closeAction : function(component, event, helper) {
         $A.get('e.force:refreshView').fire();
          
     },
    
    // initialize Invoice records 
    onInitializeInvoice : function (component, event, helper) {
       var nullValuemessage;
        if(component.get('v.selectedLookUpRecord').Id === undefined){
            $A.util.addClass(component.find('customer').sendComponent(), 'slds-has-error');
            if(nullValuemessage === undefined){
                nullValuemessage = component.find('customer').get("v.label").replace('*','');
            }else{
                nullValuemessage += ', ' + component.find('customer').get("v.label").replace('*','');
            }
        } else {
            helper.fetchEntity(component, event, helper, component.get('v.selectedLookUpRecord').Id);
        }
    },
    onCreditMemoRefund : function (component, event, helper) {
    	console.log(component.get('v.creditMemo'));
        var creditMemoDetails = component.get('v.creditMemo');
    	//alert(component.get('v.creditMemo').Id);
        
        if(component.get('v.creditMemo').Id != undefined && component.get('v.creditMemo').Id != null && component.get('v.creditMemo').Id != ''){
            component.set('v.showInvoiceSelectionTable', true);
        	component.set('v.showInvoiceSelection', true);
            
        }
        
        if(component.get("v.selectedScenario") == 'Invoice Fully Paid'){
            /*window.setTimeout(
                $A.getCallback(function() {
                    helper.fetchLineItem(component, event, helper, component.get('v.selectedInvoiceLookUp'), creditMemoDetails);
                }), 2000
            );*/
            //helper.fetchLineItem(component, event, helper, component.get('v.selectedInvoiceLookUp'), creditMemoDetails);
            component.set('v.showPushToOracle', true);
            helper.fetchLineItem(component, event, helper, null, creditMemoDetails);
        }
	},
    onReloadClick : function (component, event, helper) {
        component.set('v.sourceSystem', '--None--');
        component.set("v.onLoadStart", true);
        var creditMemoObj = component.get('v.creditMemo');
        creditMemoObj.Id = null;
        component.set("v.creditMemo", creditMemoObj);
        component.set("v.showInvoiceSelectionTable",false );
        if(component.get("v.isReload") == false)
        	component.set("v.isReload", true);
        else 
            component.set("v.isReload", false);
        //component.set("v.selectedLookUpRecord", "");
        
        //component.set("v.selectedInvoiceLookUp", "");
        component.set("v.invoiceLineItems", "[]");
        component.set("v.isReview", false);
        component.set("v.showPushToOracle", false);
    },
   
    onMemoCancellation : function (component, event, helper) {
        var action = component.get("c.getListViews");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "Invoice__c"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
    },

    viewDocuments : function(component, event, helper){
        window.open('/'+component.get('v.creditMemo.Id'),'_blank');
    }
})