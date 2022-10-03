({
	// Onload function
    init: function (component, event, helper) {
        var today = new Date();
        var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
        console.log(date);
        component.set("v.todayDate", date);
        component.set("v.selectedEntityId", null);
        helper.fetchAccPicklistValues(component, 'Oracle_Site_Id__c', true);
        helper.fetchUser(component);
    },
    enablePage : function(component, event,helper) {
        var params = event.getParam('arguments');
        //$A.get('e.force:refreshView').fire();
        //alert(params.entityRecordId);
        
        if(params.entityRecordId == 'Detail') {
            component.set("v.selectedEntityId", null);
        } else {
            
            component.set("v.selectedEntityId", params.entityRecordId);
            helper.searchEntites(component, event, helper);
            component.set("v.selectedIndex", 0);
            //onRadionButtonSelection(component, event, helper);
            component.set("v.showCreateButtons",true);
			component.set("v.showTable",true); 
            //var entityRec = component.get("v.listEntityWrapper");
            //component.set("v.selectedEntityName", entityRec[0].accountRec.Name);
            var records = [];
            component.set("v.listReceiptsWrapper", records);
            component.set("v.listInvoiceWrapper", records); 
            helper.fetchOldEntityData(component, event, helper, component.get("v.selectedEntityId"));
        }
        
        
    },
	// this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    // clear search fields
    clear : function(component,event,helper){
        component.set("v.entityname", "");
        component.set("v.SITEID", "");
        component.set("v.ADGMID", "");
        component.set("v.entityEmail", "");
        component.set("v.showTable", false);
        component.set("v.showReceiptTable", false);
        component.set("v.selectedIndex", -1);
        component.set("v.showInvoiceTable", false);
		var records = [];
        component.set("v.listReceiptsWrapper", records);
        component.set("v.listInvoiceWrapper", records);      
    },
    
    // Search button action
    searchButtonClick : function (component, event, helper) {
        var isConfirmed = helper.showConfirm(component, event, helper); 
        var cepRecords = component.get("v.listReceiptsWrapper");
        var invRecords = component.get("v.listInvoiceWrapper");
        
        var sEntityName = component.find("entitynameinput");
        var sADGMID = component.find("ADGMIDinput");
        var sSITEID = component.find("SITEIDinput");
       // alert(sEntityName.get("v.validity").tooShort);
        //console.log(sEntityName.get("v.validity"));
        if(isConfirmed || (cepRecords.length == 0 && invRecords.length == 0)){
            component.set("v.selectedIndex", -1);
            
            if((component.get("v.entityname") == null || component.get("v.entityname").trim() == '') 
               && (component.get("v.ADGMID") == null || component.get("v.ADGMID").trim() == '') && (component.get("v.SITEID") == null || component.get("v.SITEID").trim() == '')) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type" : "error",
                    "message": "Entity Name, ADGM ID and Site ID is blank. Please enter some value to search."
                });
                toastEvent.fire(); 
            } else if(sEntityName.get("v.validity").valid && sADGMID.get("v.validity").valid && sSITEID.get("v.validity").valid){
                //alert('hiiii');
                // search entities
                component.set("v.showInvoiceTable", false);
                component.set("v.showReceiptTable", false);
                var records = [];
                component.set("v.listReceiptsWrapper", records);
                component.set("v.listInvoiceWrapper", records); 
                helper.searchEntites(component, event, helper);
            }
        }
        //cmp.set("v.loaded", true);
        //helper.searchEntities(cmp);
    },
    // check all the entity
    onSelectAll : function (component, event, helper) {
        
        var records = component.get("v.listEntityWrapper");
        var selectedVal = component.get("v.selectAll");
        console.log(selectedVal);
        for(var index =  0; index < records.length; index++ ) {
            records[index].isSelected = selectedVal;
        }
        component.set("v.listEntityWrapper", records);
    },
    
    onRadionButtonSelection : function (component, event, helper) {
        var isConfirmed = helper.showConfirm(component, event, helper); 
        var cepRecords = component.get("v.listReceiptsWrapper");
        var invRecords = component.get("v.listInvoiceWrapper");
        var entityRecords = component.get("v.listEntityWrapper");
        component.set("v.showCreateButtons",true);
        component.set("v.selectedIndex", event.getSource().get("v.name"));
        var entIndex = component.get("v.selectedIndex");
        component.set("v.selectedEntityName", entityRecords[entIndex].accountRec.Name);
        if(isConfirmed || (cepRecords.length == 0 && invRecords.length == 0)){
            helper.fetchOldEntityData(component, event, helper, entityRecords[entIndex].accountRec.Id);
            
            /*
            
            component.set("v.selectedIndex", event.getSource().get("v.name"));
            var entityRecords = component.get("v.listEntityWrapper");
            var entIndex = component.get("v.selectedIndex");

            var action = component.get("c.getRelatedReceipts");
            // set parameter
            action.setParams({
                "selectedAccountId": entityRecords[entIndex].accountRec.Id
            });
            component.set("v.Spinner", true);
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

                        helper.fetchPicklistValues(component, 'Payment_Method__c', true);
                        helper.fetchPicklistValues(component, 'Payment_Currency__c', true);
                        component.set("v.selectedEntityName", entityRecords[entIndex].accountRec.Name);
                        component.set("v.listReceiptsWrapper", records);
                        component.set("v.showReceiptTable", true);
                        
                    }  else {
                        component.set("v.listReceiptsWrapper", records);
                        component.set("v.showReceiptTable", false);
                    }
                } else {
                    console.log("Failed with state: " + state);
                    console.log("Failed with state: " + response.getReturnValue());
                    helper.showTostMSG(component, event, helper, 'Error', response.getReturnValue(),"dismissible");
                }
            });
            
            $A.enqueueAction(action);
            
            var action1 = component.get("c.getRelatedInvoice");
            // set parameter
            action1.setParams({
                "selectedAccountId": entityRecords[entIndex].accountRec.Id
            });
            component.set("v.Spinner", true);
            action1.setCallback(this, function(response) {
                var state = response.getState();
                component.set("v.Spinner", false);
                if (state === "SUCCESS") {
                    var records = [];
                    var responseRecords = response.getReturnValue();

                    if(responseRecords.length > 0) {
                        for(var ind = 0 ; ind< responseRecords.length ; ind++){
                            //invRecords.push(response.getReturnValue()[ind]);
                            records.push(response.getReturnValue()[ind]);
                        }

                        helper.fetchPicklistValues(component, 'Payment_Method__c', true);
                        helper.fetchPicklistValues(component, 'Payment_Currency__c', true);
                        component.set("v.selectedEntityName", entityRecords[entIndex].accountRec.Name);
                        component.set("v.listInvoiceWrapper", records);
                        component.set("v.showInvoiceTable", true);
                        
                    }  else {
                        component.set("v.listInvoiceWrapper", records);
                        component.set("v.showInvoiceTable", false);
                    }
                } else {
                    console.log("Failed with state: " + state);
                    console.log("Failed with state: " + response.getReturnValue());
                    helper.showTostMSG(component, event, helper, 'Error', response.getReturnValue(),"dismissible");
                }
            });
            
            $A.enqueueAction(action1);
            */
        } 
    },
    // initialize Receipt records 
    onInitializeReceipt : function (component, event, helper) {
        helper.initializeReceipt(component, event, helper);
    },
    // initialize Receipt records 
    onCreateReceiptRec : function (component, event, helper) {
        var currentIndex = event.getSource().get("v.name");
       console.log(currentIndex);
        helper.createReceiptRec(component, event, helper, currentIndex);
    },
    onCreateAllReceiptRec : function (component, event, helper) {
        var currentIndex = -1;
       console.log(currentIndex);
        helper.createReceiptRec(component, event, helper, currentIndex);
    },
    onEditReceiptRec : function (component, event, helper) {
        var records = component.get("v.listReceiptsWrapper");
        var currentIndex = event.getSource().get("v.name");
        for(var counter = 0; counter < records.length ; counter++) {
            if(counter == currentIndex) {
                records[counter].isEditable = false;
                records[counter].isRemoveEnable = true;
            } 
        }
        component.set("v.listReceiptsWrapper", records);
	},
    // initialize Invoice records 
    onInitializeInvoice : function (component, event, helper) {
        helper.initializeInvoice(component, event, helper);
    },
    onCreateInvoiceRec : function (component, event, helper) {
        var currentIndex = event.getSource().get("v.name");
       console.log(currentIndex);
        helper.createInvoiceRec(component, event, helper, currentIndex, true);
    },
    onCreateAllInvoiceRec : function (component, event, helper) {
        var currentIndex = -1;
       console.log(currentIndex);
        helper.createInvoiceRec(component, event, helper, currentIndex, true);
    },
    onEditInvoiceRec : function (component, event, helper) {
        var records = component.get("v.listInvoiceWrapper");
        var currentIndex = event.getSource().get("v.name");
        for(var counter = 0; counter < records.length ; counter++) {
            if(counter == currentIndex) {
                records[counter].isEditable = false;
                records[counter].isRemoveEnable = true;
            } 
        }
        component.set("v.listInvoiceWrapper", records);
    },
    // initialize Invoice line item records 
    onInitializeInvoiceLineItem : function (component, event, helper) {
        var selectedIndexVal = event.getSource().get("v.name");
        helper.initializeInvoiceLineItem(component, event, helper, selectedIndexVal);
    },
    onCreateInvoiceLineItemRec : function (component, event, helper) {
        var currentIndex = event.getSource().get("v.name");
        
        var splittedValues = currentIndex.toString().split("-");
        //alert(splittedValues[0]);
        //alert(splittedValues[1]);
        console.log(currentIndex);
        var records = component.get("v.listInvoiceWrapper");
        var isValid = helper.validateInvoiceLineRec(component, event, helper, records[splittedValues[1]].listInvoiceLineItemWrap[splittedValues[0]].invoiceLineItemRec, currentIndex, records[splittedValues[1]].invoiceRec);
        console.log(isValid);
        if(isValid){
            helper.createInvoiceLineItemRec(component, event, helper, splittedValues[1], splittedValues[0]);
        }
        //helper.createInvoiceLineItemRec(component, event, helper, splittedValues[1], splittedValues[0]);
    },

    onEditInvoiceLineItemRec : function (component, event, helper) {
        var currentIndex = event.getSource().get("v.name");
        console.log(currentIndex);
        var splittedValues = currentIndex.toString().split("-");
        console.log(currentIndex);
        var records = component.get("v.listInvoiceWrapper");
        for(var counter = 0; counter < records.length ; counter++) {
            if(counter == splittedValues[1]) {
                records[counter].listInvoiceLineItemWrap[splittedValues[0]].isEditable = false;
                records[counter].listInvoiceLineItemWrap[splittedValues[0]].isRemoveEnable = true;
            }
        }
        component.set("v.listInvoiceWrapper", records);
    },

    onRemoveInvoiceLineItemRec : function (component, event, helper) {
        var currentIndex = event.getSource().get("v.name");
        var splittedValues = currentIndex.toString().split("-");
        console.log(currentIndex);

        var records = component.get("v.listInvoiceWrapper");
        console.log(records);
        records[splittedValues[1]].listInvoiceLineItemWrap.splice(splittedValues[0],1);
        console.log(records);
        component.set("v.listInvoiceWrapper",records);
       // helper.createInvoiceLineItemRec(component, event, helper, splittedValues[1], splittedValues[0]);
    },

    removeReceiptElement : function (component, event, helper) {
        var currentIndex = event.getSource().get("v.name");
        var records = component.get("v.listReceiptsWrapper");
        if(currentIndex == 0) {
            component.set("v.listReceiptsWrapper", records.slice(1 , records.length));
        } else if(currentIndex == records.length-1) {
            component.set("v.listReceiptsWrapper", records.slice(0 , records.length-1));
        } else {
            var newRecords1 = records.slice(0, currentIndex);
            var newRecords2 = records.slice(currentIndex+1, records.length);
            component.set("v.listReceiptsWrapper", newRecords1.concat(newRecords2));
        }
    },
    removeInvoiceElement : function (component, event, helper) {
        var currentIndex = event.getSource().get("v.name");
        var records = component.get("v.listInvoiceWrapper");
        if(currentIndex == 0) {
            component.set("v.listInvoiceWrapper", records.slice(1 , records.length));
        } else if(currentIndex == records.length-1) {
            component.set("v.listInvoiceWrapper", records.slice(0 , records.length-1));
        } else {
            var newRecords1 = records.slice(0, currentIndex);
            var newRecords2 = records.slice(currentIndex+1, records.length);
            component.set("v.listInvoiceWrapper", newRecords1.concat(newRecords2));
        }
    },
    openCE: function(component, event, helper) {
		var isConfirmed = helper.showConfirm(component, event, helper); 
        var cepRecords = component.get("v.listReceiptsWrapper");
        var invRecords = component.get("v.listInvoiceWrapper");
        if(isConfirmed || (cepRecords.length == 0 && invRecords.length == 0)){
            var evt = $A.get("e.c:LEX_CreateEntityEvent");
            evt.setParams({ 
                "showMod": true,
                "isPersonAccount": false
            });
            
            evt.fire();   
        }
   	},
    openPersonAcc: function(component, event, helper) {
        var isConfirmed = helper.showConfirm(component, event, helper); 
        var cepRecords = component.get("v.listReceiptsWrapper");
        var invRecords = component.get("v.listInvoiceWrapper");
        if(isConfirmed || (cepRecords.length == 0 && invRecords.length == 0)){
            var evt = $A.get("e.c:LEX_CreateEntityEvent");
            evt.setParams({ 
                "showMod": true,
                "isPersonAccount": true
            });
            
            evt.fire();   
        }
   	},
    
    handleComponentEvent : function(component, event) { 
        
        var retAcc = event.getParam("returnedAccounts");
        if(retAcc != null){
            console.log('Account created and called back listner');
        	console.log(retAcc);
            var obj = "{\"accountRec\":"+retAcc+",\"isSelected\":true}";
            console.log(obj);
            obj = JSON.parse(obj);
            console.log(obj);
            var arraySize = 0;
            
            var lstCmp = component.get("v.listEntityWrapper");
            if(lstCmp != null && lstCmp != []) {
                arraySize = lstCmp.length;
            } else {
                lstCmp = [];
            }
            lstCmp.push(obj);
            
        	component.set("v.listEntityWrapper", lstCmp); 
            component.set("v.selectedIndex", arraySize);
            component.set("v.showTable", true);
            component.set("v.showCreateButtons",true);
            var records = [];
            component.set("v.listReceiptsWrapper", records);
            component.set("v.listInvoiceWrapper", records);
            component.set("v.showReceiptTable", false);
            component.set("v.showInvoiceTable", false);
        }
 	},
    // Redirection method account record
    navigateBack : function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": component.get("v.selectedEntityId"),
          "slideDevName": "related"
        });
        navEvt.fire();
    },
    toggleSFAModal : function (component, event, helper) {
        if (confirm("Any unsaved data will be lost after submission!")) {
            var currentState = component.get('v.isOpenSFAModal');
            currentState = !currentState;
            component.set('v.isOpenSFAModal',currentState);
        }
		
    },
    cancelSubmitforApproval : function (component, event, helper) {
        component.set('v.isOpenSFAModal',false);
    },
    onSubmitForApproval : function (component, event, helper) {
		var chkboxes = false;
        var receiptWrapper = [];
        var invoiceWrapper = [];
        
        receiptWrapper =  component.get("v.listReceiptsWrapper");
        invoiceWrapper =  component.get("v.listInvoiceWrapper");
        for(var index =  0; index < receiptWrapper.length; index++ ) { 
            if(receiptWrapper[index].isSelectedForApproval == true) {
               chkboxes = true; 
                break;
            }
        }
        
        if(!chkboxes) {
            for(var index =  0; index < invoiceWrapper.length; index++ ) { 
                if(invoiceWrapper[index].isSelectedForApproval == true) {
                    chkboxes = true; 
                    break;
                }
            }
        }
        alert('onSubmitForApproval');
        if(!chkboxes) {
            helper.showTostMSG(component, event, helper, 'Error','Please select receipt/invoice for approval',"dismissible");
        } else {
            //alert('Inside If');
            helper.submitRecForApproval(component, event, helper,receiptWrapper,invoiceWrapper);
        }
        
    },
    onReceiptCheckBoxAction : function (component, event, helper) {
        var selectedIndex = event.getSource().get("v.name");
        var receiptWrapper = [];
        receiptWrapper =  component.get("v.listReceiptsWrapper");
        receiptWrapper[selectedIndex].isSelectedForApproval = event.getSource().get('v.checked');
        component.set("v.listReceiptsWrapper", receiptWrapper); 
    },
    onInvoiceCheckBoxAction : function (component, event, helper) {
        //alert('inside check box');
        
        var selectedIndex = event.getSource().get("v.name");
        //alert(selectedIndex);
        var invoiceWrapper = [];
        invoiceWrapper =  component.get("v.listInvoiceWrapper");
        invoiceWrapper[selectedIndex].isSelectedForApproval = event.getSource().get('v.checked');
        //alert(event.getSource().get('v.checked'));
        component.set("v.listInvoiceWrapper", invoiceWrapper); 
    },
    
    onPushToOracle : function(component, event, helper) {
        var receiptWrapper = [];
        receiptWrapper =  component.get("v.listReceiptsWrapper");
        var selectedIndex = event.getSource().get("v.name");
        component.set("v.Spinner", true);
        helper.pushReceiptToOracle(component, event, helper,receiptWrapper[selectedIndex].receiptRec.Id, true);
        //alert('Selected Index is--->'+selectedIndex);
    },
    
    onPushToOracleInvoice : function(component, event, helper) {
        var invoiceWrapper = [];
        invoiceWrapper =  component.get("v.listInvoiceWrapper");
        var selectedIndex = event.getSource().get("v.name");
        if(invoiceWrapper[selectedIndex].listInvoiceLineItemWrap.length > 0){
            component.set("v.Spinner", true);
            helper.pushReceiptToOracle(component, event, helper,invoiceWrapper[selectedIndex].invoiceRec.Id, false);
        } else {
            helper.showTostMSG(component, event, helper, 'Error', "No Line Item found for the selected Invoice","sticky");
        }
        
        //alert('Selected Index is--->'+selectedIndex);
    }
    
})