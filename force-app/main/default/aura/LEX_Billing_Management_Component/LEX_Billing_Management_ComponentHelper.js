/**
 * @File Name          : LEX_Billing_Management_ComponentHelper.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 07-12-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/16/2020   Jayanta Karmakar     Initial Version
**/
({
    fetchUser : function(component) {
		var action = component.get("c.fetchUserDetails");
		
        component.set("v.Spinner", true);
        action.setCallback(this, function(response) {
			var state = response.getState();
            component.set("v.Spinner", false);
			if (state === "SUCCESS") {
                   
                component.set("v.currentProfileName", response.getReturnValue());
                if(response.getReturnValue() == "ADGM Finance Manager") {
                    component.set("v.dynamicBtnName", 'Push to Oracle');
                }
			} else {
				console.log("Failed with state: " + state);
			}
		});
       // component.set("v.Spinner", false);
		$A.enqueueAction(action);
        
    },
    fetchBMMetaData : function (component, event, helper) {
        var action = component.get("c.fetchBillingManagementMDTDetail");
        component.set("v.Spinner", true);
        action.setCallback(this, function(response) {
            component.set("v.Spinner", false);
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                let resp = response.getReturnValue();
                component.set('v.bmMdt', resp);
                if(resp.Default_OU__c == 'All'){
                    component.set('v.isOUDisabled', false);
                } else {
                    component.set('v.SITEID', resp.Default_OU__c); 
                    component.set('v.entitySourceSys', resp.Default_Source_System__c);
                    component.set('v.isOUDisabled', true);
                    if(resp.Default_OU__c == '101'){
                        component.set('v.isSSDisabled', true);
                    }
                }
			} else {
				console.log("Failed with state: " + state);
			}
		});
       // component.set("v.Spinner", false);
		$A.enqueueAction(action);
    },
    fetchAccPicklistValues : function(component, fieldAPIName, nullRequired) {
		var action = component.get("c.fetchAccountPicklistVal");
		// set parameter
        action.setParams({
            'fieldAPIname': fieldAPIName,
            'nullRequired': nullRequired 
        });
        component.set("v.Spinner", true);
        action.setCallback(this, function(response) {
			var state = response.getState();
            component.set("v.Spinner", false);
			if (state === "SUCCESS") {
                //var records = response.getReturnValue();
                if(fieldAPIName == 'Oracle_Site_Id__c') {
                   
                    component.set("v.oracleSiteIdPicklist", response.getReturnValue());
                } 
			} else {
				console.log("Failed with state: " + state);
			}
		});
       // component.set("v.Spinner", false);
		$A.enqueueAction(action);
        
	},
	// search the entity records
	searchEntites : function(component, event, helper) {
        //alert('searchEntites');
		var action = component.get("c.getRelatedEntity");
		// set parameter
        action.setParams({
            "sName": component.get("v.entityname"), 
            "sADGMID": component.get("v.ADGMID"),
            "sSiteID": component.get("v.SITEID"),
            'sRelatedEntity' : component.get("v.selectedEntityId"), 
            "sSourceSys" : component.get("v.entitySourceSys")
        });
        component.set("v.Spinner", true); 
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            //component.set("v.Spinner", false);
			if (state === "SUCCESS") {
                component.set("v.listEntityWrapper", response.getReturnValue());
                if(response.getReturnValue() == null || response.getReturnValue().length == 0) {
                    component.set("v.isNoSearchDataFound", true);
                } else {
                    component.set("v.isNoSearchDataFound", false);
                }
                helper.renderPage(component,event);
                //alert(response.getReturnValue());
                component.set("v.showTable", true);
			} else {
				console.log("Failed with state: " + state);
                console.log("Failed with state: " + response.getReturnValue());
                helper.showTostMSG(component, event, helper, 'Error', response.getReturnValue(),"dismissible");
			}
            component.set("v.Spinner",false);
		});         
		$A.enqueueAction(action);
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    // call and get initialized Receipt records 
    initializeReceipt : function(component, event, helper) {
        var records = component.get("v.listEntityWrapper");
        var selectedIndex = component.get("v.selectedIndex");
        
        if(selectedIndex == -1 ) {
            helper.showTostMSG(component, event, helper, 'Error', 'Please select entity for receipt creation',"dismissible");
        } else {
            var selectedAccount = records[component.get("v.selectedIndex")].accountRec;
            component.set("v.selectedEntityName", records[component.get("v.selectedIndex")].accountRec.Name);
            var action = component.get("c.getReceipts");
            // set parameter
            action.setParams({
                "selectedAccount": selectedAccount
            });
            component.set("v.Spinner", true);
            action.setCallback(this, function(response) {
                var state = response.getState();
                 component.set("v.Spinner", false);
                if (state === "SUCCESS") {
                    var records = [];
                    if(component.get("v.listReceiptsWrapper").length > 0) {
                        records =  component.get("v.listReceiptsWrapper");
                    }                                      
                    records.push(response.getReturnValue()[0]); 
                    
                    component.set("v.listReceiptsWrapper", records);
                    component.set("v.showReceiptTable", true);
                    var payMethodPicklistVals = component.get('v.paymentModePicklist'); 
                    var payCurrencyPicklistVals = component.get('v.PaymentCurrencyPicklist');
                    if(payMethodPicklistVals.length <= 0){
                        helper.fetchPicklistValues(component, 'Payment_Method__c', true);
                    }
                    if( payCurrencyPicklistVals.length <= 0){
                        helper.fetchPicklistValues(component, 'Payment_Currency__c', true);
                    }
                    
                    
                } else {
                    console.log("Failed with state: " + state);
                    console.log("Failed with state: " + response.getReturnValue());
                    helper.showTostMSG(component, event, helper, 'Error', response.getReturnValue(),"dismissible");
                }
            });
            
            $A.enqueueAction(action);
        }
        
    },
    // call and get initialized Invoice records 
    initializeInvoice : function(component, event, helper) {
        var records = component.get("v.listEntityWrapper");
        var selectedIndex = component.get("v.selectedIndex");
        
        if(selectedIndex == -1 ) {
            helper.showTostMSG(component, event, helper, 'Error', 'Please select entity for invoice creation',"dismissible");
        } else {
            var selectedAccount = records[component.get("v.selectedIndex")].accountRec;
            component.set("v.selectedEntityName", records[component.get("v.selectedIndex")].accountRec.Name);
            var action = component.get("c.getInvoice");
            // set parameter
            action.setParams({
                "selectedAccount": selectedAccount, 
                
            });
            component.set("v.Spinner", true);
            action.setCallback(this, function(response) {
                var state = response.getState();
                component.set("v.Spinner", false);
                if (state === "SUCCESS") {
                    var records = [];
                    console.log(response.getReturnValue());
                    console.log(component.get("v.listInvoiceWrapper"));
                    records =  component.get("v.listInvoiceWrapper");
                    records.push(response.getReturnValue()[0]);
                    
                    component.set("v.listInvoiceWrapper", records);
                    component.set("v.showInvoiceTable", true);
                    helper.fetchInvoicePicklistValues(component, 'Payment_Currency__c', true);
                } else {
                    console.log("Failed with state: " + state);
                    console.log("Failed with state: " + response.getReturnValue());
                    helper.showTostMSG(component, event, helper, 'Error', response.getReturnValue(),"dismissible");
                }
            });
            //component.set("v.Spinner", false);
            $A.enqueueAction(action);
        }
        
    },
    // call and get initialized Invoice line item records 
    initializeInvoiceLineItem : function(component, event, helper, selectedIndex) {
        var records = component.get("v.listEntityWrapper");
        var invoiceWrapper = [];
        invoiceWrapper =  component.get("v.listInvoiceWrapper");
        if(invoiceWrapper[selectedIndex].invoiceRec.Id == null || invoiceWrapper[selectedIndex].invoiceRec.Id =='') {
            helper.showTostMSG(component, event, helper, 'Error', 'Please save invoice first',"dismissible");
        }
        else {
            //var selectedInvoice = invoiceWrapper[selectedIndex].invoiceRec;
            var selectedAccount = records[component.get("v.selectedIndex")].accountRec;
            var action = component.get("c.getInvoiceLineItem");
            // set parameter
            action.setParams({
                "listInvoiceWrapper": invoiceWrapper,
                "indexVal" : selectedIndex,
                "selectedAcc" : selectedAccount
            });
            component.set("v.Spinner", true);
            action.setCallback(this, function(response) {
                var state = response.getState();
                component.set("v.Spinner", false);
                if (state === "SUCCESS") {
                    var records = [];
                    console.log(response.getReturnValue());
                    console.log(component.get("v.listInvoiceWrapper"));
                    records =  response.getReturnValue();
                    //records.push(response.getReturnValue()[0]);
                    console.log('----------------->');
                    console.log(records);
                    component.set("v.listInvoiceWrapper", records);
                    //component.set("v.showInvoiceTable", true);
                    //helper.fetchInvoicePicklistValues(component, 'Payment_Currency__c', true);
                } else {
                    console.log("Failed with state: " + state);
                    console.log("Failed with state: " + response.getReturnValue());
                    helper.showTostMSG(component, event, helper, 'Error', response.getReturnValue(),"dismissible");
                }
            });
            //component.set("v.Spinner", false);
            $A.enqueueAction(action);
        }
        
    },
	fetchInvoicePicklistValues : function(component, fieldAPIName, nullRequired) {
		var action = component.get("c.fetchInvoicePicklistVal");
		// set parameter
        action.setParams({
            'fieldAPIname': fieldAPIName,
            'nullRequired': nullRequired 
        });
        component.set("v.Spinner", true);
        action.setCallback(this, function(response) {
			var state = response.getState();
            component.set("v.Spinner", false);
			if (state === "SUCCESS") {
                //var records = response.getReturnValue();
				if(fieldAPIName == 'Payment_Currency__c') {
                    component.set("v.PaymentCurrencyPicklist", response.getReturnValue());
                }
			} else {
				console.log("Failed with state: " + state);
			}
		});
       // component.set("v.Spinner", false);
		$A.enqueueAction(action);
        
	},    
    fetchPicklistValues : function(component, fieldAPIName, nullRequired) {
		var action = component.get("c.fetchReceiptPicklistVal");
		// set parameter
        action.setParams({
            'fieldAPIname': fieldAPIName,
            'nullRequired': nullRequired 
        });
        component.set("v.Spinner", false);
        action.setCallback(this, function(response) {
			var state = response.getState();
            component.set("v.Spinner", false);
			if (state === "SUCCESS") {
                //var records = response.getReturnValue();
                if(fieldAPIName == 'Payment_Method__c') {
                    component.set("v.paymentModePicklist", response.getReturnValue());
                } else if(fieldAPIName == 'Payment_Currency__c') {
                    component.set("v.PaymentCurrencyPicklist", response.getReturnValue());
                } 
			} else {
				console.log("Failed with state: " + state);
			}
		});
       // component.set("v.Spinner", false);
		$A.enqueueAction(action);
        
	},
    
    validateReceiptRec : function(component, event,helper,rec,pos) {
        var isValid = true;
        var msgArray = [];
        var msgSet = new Set(); 
        var errorMsg = "";
        var low,high = 0;
        if(pos >= 0){
            low = pos;
            high = pos+1;
        } else {
            low = 0;
            high = rec.length;
        }
        
        for(var position = low; position < high; position++){
            var inputCmp1 = component.find("Amount");
            var inputCmp2 = component.find("payCurrency");
            var inputCmp3 = component.find("ModeOfPay");
            var inputCmp4 = component.find("TransRef");
            var inputCmp5 = component.find("AmountApplied"); 
            var inputCmp6 = component.find("recDate");
            
            if(Array.isArray(inputCmp1)){
                $A.util.removeClass(inputCmp1[position], 'errorFld');
            } else {
                $A.util.removeClass(inputCmp1, 'errorFld');
            }
            
            if(Array.isArray(inputCmp2)){
                $A.util.removeClass(inputCmp2[position], 'errorFld');
            } else {
                $A.util.removeClass(inputCmp2, 'errorFld');
            }
            
            if(Array.isArray(inputCmp3)){
                $A.util.removeClass(inputCmp3[position], 'errorFld');
            } else {
                $A.util.removeClass(inputCmp3, 'errorFld');
            }
            
            if(Array.isArray(inputCmp4)){
                $A.util.removeClass(inputCmp4[position], 'errorFld');
            } else {
                $A.util.removeClass(inputCmp4, 'errorFld');
            }

            if(Array.isArray(inputCmp5)){
                $A.util.removeClass(inputCmp5[position], 'errorFld');
            } else {
                $A.util.removeClass(inputCmp5, 'errorFld');
            }

            if(Array.isArray(inputCmp6)){
                $A.util.removeClass(inputCmp6[position], 'errorFld');
            } else {
                $A.util.removeClass(inputCmp6, 'errorFld');
            }
        }
        
        for(var position = low; position < high; position++){
            if(rec[position].receiptRec.Payment_Currency__c == null || rec[position].receiptRec.Payment_Currency__c == "" || rec[position].receiptRec.Payment_Currency__c =="None"){
                msgArray.push('Payment Currency should not be blank');
                msgSet.add('Payment Currency should not be blank');
                var inputCmp = component.find("payCurrency");
                if(Array.isArray(inputCmp)){
                    $A.util.addClass(inputCmp[position], 'errorFld');
                } else {
                    $A.util.addClass(inputCmp, 'errorFld');
                } 
            }
            
            if(rec[position].receiptRec.Amount__c <= 0 || rec[position].receiptRec.Amount__c == null || rec[position].receiptRec.Amount__c == ""){
                msgArray.push('Amount must be greater than 0');
                msgSet.add('Amount must be greater than 0');
                var inputCmp = component.find("Amount");
                if(Array.isArray(inputCmp)){
                    $A.util.addClass(inputCmp[position], 'errorFld');
                } else {
                    $A.util.addClass(inputCmp, 'errorFld');
                } 
            } 
    
            if(rec[position].receiptRec.Payment_Method__c == null || rec[position].receiptRec.Payment_Method__c == "" || rec[position].receiptRec.Payment_Method__c =="None"){
                msgArray.push('Payment Method must be selected');
                msgSet.add('Payment Method must be selected');
                var inputCmp = component.find("ModeOfPay");
                if(Array.isArray(inputCmp)){
                    $A.util.addClass(inputCmp[position], 'errorFld');
                } else {
                    $A.util.addClass(inputCmp, 'errorFld');
                } 
            } 
            if(rec[position].receiptRec.Transaction_Reference__c == null || rec[position].receiptRec.Transaction_Reference__c.trim() == ""){
               // msgArray.push('Transactaion Reference can not be blank');
                msgSet.add('Transaction Reference should not be blank');
                var inputCmp = component.find("TransRef");
                if(Array.isArray(inputCmp)){
                    $A.util.addClass(inputCmp[position], 'errorFld');
                } else {
                    $A.util.addClass(inputCmp, 'errorFld');
                } 
            }

            if(rec[position].relatedInvoice != null && rec[position].relatedInvoice != "" && (rec[position].invoiceAmountApplied == null || rec[position].invoiceAmountApplied == "")){
                // msgArray.push('Transactaion Reference can not be blank');
                 msgSet.add('Invoice Amount Applied can not be blank if Related Invoice is there');
                 var inputCmp = component.find("AmountApplied");
                 if(Array.isArray(inputCmp)){
                     $A.util.addClass(inputCmp[position], 'errorFld');
                 } else {
                     $A.util.addClass(inputCmp, 'errorFld');
                 } 
            }

            if(rec[position].relatedInvoice != null && rec[position].relatedInvoice != "" && rec[position].invoiceAmountApplied != null && rec[position].invoiceAmountApplied != ""){
                if(rec[position].relatedInvoice.split(',').length != rec[position].invoiceAmountApplied.split(',').length){
                    msgSet.add('Number of Invoice and Amount Applied should be same');
                    var inputCmp = component.find("AmountApplied");
                    var inputCmp1 = component.find("relatedInvoice");
                    if(Array.isArray(inputCmp)){
                        $A.util.addClass(inputCmp[position], 'errorFld');
                    } else {
                        $A.util.addClass(inputCmp, 'errorFld');
                    } 

                    if(Array.isArray(inputCmp1)){
                        $A.util.addClass(inputCmp1[position], 'errorFld');
                    } else {
                        $A.util.addClass(inputCmp1, 'errorFld');
                    } 
                }     
            }


            
           /* if(msgArray.length > 0){
                for(var v = 0; v < msgArray.length;v++){
                    errorMsg += msgArray[v]+"\n";
                }
                
                helper.showTostMSG(component, event, helper, 'Error', errorMsg);
            	isValid = false;
            }  */

            if(rec[position].receiptRec.Receipt_Date__c != null && rec[position].receiptRec.Receipt_Date__c != ''){
                var dt = new Date();
                var dt1 = new Date(rec[position].receiptRec.Receipt_Date__c);
                if(dt1.getTime() > dt.getTime()){
                    msgSet.add('Receipt date can not be greated than today');
                    var inputCmp = component.find("recDate");
                    if(Array.isArray(inputCmp)){
                        $A.util.addClass(inputCmp[position], 'errorFld');
                    } else {
                        $A.util.addClass(inputCmp, 'errorFld');
                    }
                }
            }

            if(rec[position].receiptRec.Receipt_Date__c == null || rec[position].receiptRec.Receipt_Date__c == ''){
                msgSet.add('Receipt date can not be blank');
                var inputCmp = component.find("recDate");
                if(Array.isArray(inputCmp)){
                    $A.util.addClass(inputCmp[position], 'errorFld');
                } else {
                    $A.util.addClass(inputCmp, 'errorFld');
                }
            }

        }
        
        if(msgSet.size > 0){
            msgArray = Array.from(msgSet);
            for(var v = 0; v < msgArray.length;v++){
                errorMsg += msgArray[v]+"\n";
            }
            
            helper.showTostMSG(component, event, helper, 'Error', errorMsg,"sticky");
            isValid = false;
        }  
        
        return isValid;
    },
    
    validateInvoiceRec : function(component, event,helper,rec,pos) {
        var isValid = true;
        var msgArray = [];
        var msgSet = new Set(); 
        var errorMsg = "";
        var low,high = 0;
        if(pos >= 0){
            low = pos;
            high = pos+1;
        } else {
            low = 0;
            high = rec.length;
        }
        
        for(var position = low; position < high; position++){
            var inputCmp1 = component.find("InvpayCurrency");
            //var inputCmp2 = component.find("InvMarkupAmount");
            var inputCmp3 = component.find("InvTransRef");
            //var inputCmp4 = component.find("InvCost");
            //var inputCmp5 = component.find("InvTaxAmount");
            var inputCmp6 = component.find("invDate");
            var inputCmp7 = component.find("payTerm");
          //  var inputCmp8 = component.find("InvpayCurrency");
            
            
            
            if(Array.isArray(inputCmp1)){
                $A.util.removeClass(inputCmp1[position], 'errorFld');
            } else {
                $A.util.removeClass(inputCmp1, 'errorFld');
            }
            /*
            if(Array.isArray(inputCmp2)){
                $A.util.removeClass(inputCmp2[position], 'errorFld');
            } else {
                $A.util.removeClass(inputCmp2, 'errorFld');
            }
            */
            if(Array.isArray(inputCmp3)){
                $A.util.removeClass(inputCmp3[position], 'errorFld');
            } else {
                $A.util.removeClass(inputCmp3, 'errorFld');
            }
            /*
            if(Array.isArray(inputCmp4)){
                $A.util.removeClass(inputCmp4[position], 'errorFld');
            } else {
                $A.util.removeClass(inputCmp4, 'errorFld');
            }
            
            if(Array.isArray(inputCmp5)){
                $A.util.removeClass(inputCmp5[position], 'errorFld');
            } else {
                $A.util.removeClass(inputCmp5, 'errorFld');
            }*/

            if(Array.isArray(inputCmp6)){
                $A.util.removeClass(inputCmp6[position], 'errorFld');
            } else {
                $A.util.removeClass(inputCmp6, 'errorFld');
            }

            if(Array.isArray(inputCmp7)){
                $A.util.removeClass(inputCmp7[position], 'errorFld');
            } else {
                $A.util.removeClass(inputCmp7, 'errorFld');
            }

          /*  if(Array.isArray(inputCmp8)){
                $A.util.removeClass(inputCmp8[position], 'errorFld');
            } else {
                $A.util.removeClass(inputCmp8, 'errorFld');
            } */
        }
        
        for(var position = low; position < high; position++){
            
            if(rec[position].invoiceRec.Payment_Currency__c == null || rec[position].invoiceRec.Payment_Currency__c == "" || rec[position].invoiceRec.Payment_Currency__c =="None"){
               // msgArray.push('Payment Currency should not be blank');
                msgSet.add('Payment Currency should not be blank');
                var inputCmp = component.find("InvpayCurrency");
                console.log(inputCmp);
                if(Array.isArray(inputCmp)){
                    $A.util.addClass(inputCmp[position], 'errorFld');
                } else {
                    $A.util.addClass(inputCmp, 'errorFld');
                } 
            } 
            /*
            if(rec[position].invoiceRec.Markup_Amount__c <= 0 || rec[position].invoiceRec.Markup_Amount__c == null || rec[position].invoiceRec.Markup_Amount__c == ""){
               // msgArray.push('Amount must be grater than 0');
                msgSet.add('Markup Amount must be greater than 0');
                //var inputCmp = component.find("InvAmount");
                if(Array.isArray(inputCmp2)){
                    $A.util.addClass(inputCmp2[position], 'errorFld');
                } else {
                    $A.util.addClass(inputCmp2, 'errorFld');
                } 
            } 
            
            if(rec[position].invoiceRec.Cost__c <= 0 || rec[position].invoiceRec.Cost__c == null || rec[position].invoiceRec.Cost__c == ""){
               // msgArray.push('Amount must be grater than 0');
                msgSet.add('Cost must be greater than 0');
                //var inputCmp = component.find("InvAmount");
                if(Array.isArray(inputCmp4)){
                    $A.util.addClass(inputCmp4[position], 'errorFld');
                } else {
                    $A.util.addClass(inputCmp4, 'errorFld');
                } 
            } 
            if(rec[position].invoiceRec.Tax_Amount__c <= 0 || rec[position].invoiceRec.Tax_Amount__c == null || rec[position].invoiceRec.Tax_Amount__c == ""){
               // msgArray.push('Amount must be grater than 0');
                msgSet.add('Tax Amount must be greater than 0');
                //var inputCmp = component.find("InvAmount");
                if(Array.isArray(inputCmp5)){
                    $A.util.addClass(inputCmp5[position], 'errorFld');
                } else {
                    $A.util.addClass(inputCmp5, 'errorFld');
                } 
            } 
            */
            if(rec[position].invoiceRec.Transaction_Reference__c == null || rec[position].invoiceRec.Transaction_Reference__c.trim() == ""){
                //msgArray.push('Transactaion Reference can not be blank');
                msgSet.add('Transaction Reference should not be blank');
                var inputCmp = component.find("InvTransRef");
                if(Array.isArray(inputCmp)){
                    $A.util.addClass(inputCmp[position], 'errorFld');
                } else {
                    $A.util.addClass(inputCmp, 'errorFld');
                } 
            }

            if(rec[position].invoiceRec.Invoice_Date__c != null && rec[position].invoiceRec.Invoice_Date__c != ''){
                //console.log(rec[position].invoiceRec.Invoice_Date__c.getTime() > new Date().getTime());
                console.log(rec[position].invoiceRec.Invoice_Date__c);
                var dt = new Date();
                var dt1 = new Date(rec[position].invoiceRec.Invoice_Date__c);
                console.log(dt);
                console.log(dt1);
                console.log(dt1.getTime() > dt.getTime());
                if(dt1.getTime() > dt.getTime()){
                    msgSet.add('Invoice date can not be greated than today');
                    var inputCmp = component.find("invDate");
                    if(Array.isArray(inputCmp)){
                        $A.util.addClass(inputCmp[position], 'errorFld');
                    } else {
                        $A.util.addClass(inputCmp, 'errorFld');
                    }
                }
            }

            if(rec[position].invoiceRec.Invoice_Date__c == null || rec[position].invoiceRec.Invoice_Date__c == ''){
                msgSet.add('Invoice date can not be null');
                var inputCmp = component.find("invDate");
                if(Array.isArray(inputCmp)){
                    $A.util.addClass(inputCmp[position], 'errorFld');
                } else {
                    $A.util.addClass(inputCmp, 'errorFld');
                }
            }

            if(rec[position].invoiceRec.Payment_Term__c == null || rec[position].invoiceRec.Payment_Term__c == ''){
                msgSet.add('Payment Term can not be null');
                var inputCmp = component.find("payTerm");
                if(Array.isArray(inputCmp)){
                    $A.util.addClass(inputCmp[position], 'errorFld');
                } else {
                    $A.util.addClass(inputCmp, 'errorFld');
                }
            }

           /* if(rec[position].invoiceRec.Payment_Currency__c == null || rec[position].invoiceRec.Payment_Currency__c == '' || rec[position].invoiceRec.Payment_Currency__c == 'None'){
                msgSet.add('Invoice Currency can not be null');
                var inputCmp = component.find("InvpayCurrency");
                if(Array.isArray(inputCmp)){
                    $A.util.addClass(inputCmp[position], 'errorFld');
                } else {
                    $A.util.addClass(inputCmp, 'errorFld');
                }
            } */
        }
        
        if(msgSet.size > 0){
            msgArray = Array.from(msgSet);
            for(var v = 0; v < msgArray.length;v++){
                errorMsg += msgArray[v]+"\n";
            }
            
            helper.showTostMSG(component, event, helper, 'Error', errorMsg,"sticky");
            isValid = false;
        }  
        
        return isValid;
    },

    validateInvoiceLineRec : function(component, event,helper, rec, pos, invRec) {
        var isValid = true;
        var msgSet = new Set(); 
        var errorMsg = "";
        var item = ["lineAmount","lineTaxAmount","lineItemRef","ItemDesc"];
        console.log(rec);
        console.log(pos);
        for(var count = 0; count < item.length; count++){
            var itemDom = component.find(item[count]);
            console.log(itemDom);

            if(Array.isArray(itemDom)){
                for(var counter1 = 0 ; counter1 < itemDom.length; counter1++){
                    if(itemDom[counter1].get("v.name") == pos){
                        $A.util.removeClass(itemDom[counter1], 'errorFld');
                    }
                }    
            } else {
                $A.util.removeClass(itemDom, 'errorFld');
            }
        }

        if(rec.Amount__c == null || rec.Amount__c <= 0){
            msgSet.add("Amount Can not be less than 0");
            var itemDom = component.find(item[0]);
            if(Array.isArray(itemDom)){
                for(var counter1 = 0 ; counter1 < itemDom.length; counter1++){
                    if(itemDom[counter1].get("v.name") == pos){
                        $A.util.addClass(itemDom[counter1], 'errorFld');
                    }
                }    
            } else {
                $A.util.addClass(itemDom, 'errorFld');
            }
        }    

        if(rec.Tax_Amount__c == null || rec.Tax_Amount__c < 0 || rec.Tax_Amount__c == ""){
            msgSet.add("Tax Amount Can not be less than 0");
            var itemDom = component.find(item[1]);
            if(Array.isArray(itemDom)){
                for(var counter1 = 0 ; counter1 < itemDom.length; counter1++){
                    if(itemDom[counter1].get("v.name") == pos){
                        $A.util.addClass(itemDom[counter1], 'errorFld');
                    }
                }    
            } else {
                $A.util.addClass(itemDom, 'errorFld');
            }
        }  

        if(rec.Item_Description__c == null || rec.Item_Description__c == ""){
            msgSet.add("Item Description can not be blank");
            var itemDom = component.find(item[3]);
            if(Array.isArray(itemDom)){
                for(var counter1 = 0 ; counter1 < itemDom.length; counter1++){
                    if(itemDom[counter1].get("v.name") == pos){
                        $A.util.addClass(itemDom[counter1], 'errorFld');
                    }
                }    
            } else {
                $A.util.addClass(itemDom, 'errorFld');
            }
        }  

        console.log(invRec);
       /* if(invRec.Item_Reference__c == null || invRec.Item_Reference__c == ""){
            msgSet.add("Item Reference can not be blank");
            var itemDom = component.find(item[2]);
            if(Array.isArray(itemDom)){
                for(var counter1 = 0 ; counter1 < itemDom.length; counter1++){
                    if(itemDom[counter1].get("v.name") == pos){
                        $A.util.addClass(itemDom[counter1], 'errorFld');
                    }
                }    
            } else {
                $A.util.addClass(itemDom, 'errorFld');
            }
        }  */

        var msgArray = [];
        if(msgSet.size > 0){
            msgArray = Array.from(msgSet);
            for(var v = 0; v < msgArray.length;v++){
                errorMsg += msgArray[v]+"\n";
            }
            
            helper.showTostMSG(component, event, helper, 'Error', errorMsg,"sticky");
            isValid = false;
        } 

       /* var v = component.find(item[0]);
        console.log(v);
        
        console.log(v[0].get("v.name")); */
        return isValid;
    },
    
    // search the entity records
    createReceiptRec : function(component, event, helper, index) {
        var records = component.get("v.listReceiptsWrapper");
        var receiptRecords = [];
       
        if(index >= 0){
            for(var counter = 0; counter < records.length ; counter++) {
            	if(counter == index) {
                    if(helper.validateReceiptRec(component, event,helper,records,counter)){
                        receiptRecords.push(records[counter]);
                        records[counter].isEditable = true;
                        records[counter].isRemoveEnable = true;
                    } else {
                        return;
                    }
            	}
            }
        } else if(index == -1) {
            if(records.length < 1){
                helper.showTostMSG(component, event, helper, 'Error', 'No Receipt records to save.',"sticky");
                return;
            }
            if(helper.validateReceiptRec(component, event,helper,records,index)){
                for(var counter = 0; counter < records.length ; counter++){
                    records[counter].isEditable = true;
                    records[counter].isRemoveEnable = true;
                    receiptRecords.push(records[counter]);
                	
                }	    
            } else {
                return;
            }
        }
       
        /*for(var counter = 0; counter < records.length ; counter++) {
            if(counter == index) {
                if(helper.validateReceiptRec(component, event,helper,records,counter)){
                    receiptRecords.push(records[counter].receiptRec);
               		records[counter].isEditable = true;
                } else {
                    return;
                }
            } else if(index == -1) {
                if(helper.validateReceiptRec(component, event,helper,records,index)){
                    receiptRecords.push(records[counter].receiptRec);
                	records[counter].isEditable = true;
                } else {
                    return;
                }
            }
        } */
        
        console.log(receiptRecords[0]);
        var action = component.get("c.createReceiptRecords");
		// set parameter
        action.setParams({
            "listReceiptsVal": receiptRecords,
            "indexVal" : index
        });
        component.set("v.Spinner", true);
        action.setCallback(this, function(response) {
			var state = response.getState();
            component.set("v.Spinner", false);
			if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                if(resp[0].msg != 'Success'){
                    helper.showTostMSG(component, event, helper, 'Error', resp.msg,"dismissible");
                } else{
                    console.log(resp);	
                    if(index < 0){
                        component.set("v.listReceiptsWrapper", resp);
                    } else {
                        var recs = component.get("v.listReceiptsWrapper");
                        for(var counter = 0; counter < recs.length ; counter++){
                            if(counter == index){
                                recs[index] = resp[0];
                            }
                        }
                        component.set("v.listReceiptsWrapper", recs);
                    }
                }
                
                
                

               /* if(response.getReturnValue() == 'Success') {
                    component.set("v.listReceiptsWrapper", records);
                } else {
                    helper.showTostMSG(component, event, helper, 'Error', response.getReturnValue());
                } */
			} else {

                helper.showTostMSG(component, event, helper, 'Error', response.getReturnValue(),"dismissible");
			}
		});
       // component.set("v.Spinner", false);
		$A.enqueueAction(action);
    },
    
    // Create Invoice records
    createInvoiceRec : function(component, event, helper, index, isInvoiceSave) {
        var records = component.get("v.listInvoiceWrapper");
        for(var cnt =0; cnt < records.length; cnt++){
            if(records[cnt].invoiceRec.Invoice_Class__c == null || records[cnt].invoiceRec.Invoice_Class__c == ""){
                records[cnt].invoiceRec.Invoice_Class__c = "Invoice";
            }
        }
        console.log(records);
        console.log('====================XXXXXXXXXXX===========================');
        var invoiceRecords = [];
        
        
        if(index >= 0){
            for(var counter = 0; counter < records.length ; counter++) {
            	if(counter == index) {
                    if(helper.validateInvoiceRec(component, event,helper,records,counter)){
                        invoiceRecords.push(records[counter]);
                		records[counter].isEditable = true;
                        records[counter].isRemoveEnable = true;
                    } else {
                        return;
                    }
            	}
            }
        } else if(index == -1) {
            if(records.length < 1){
                helper.showTostMSG(component, event, helper, 'Error', 'No Invoice records to save.',"sticky");
                return;
            }
            if(helper.validateInvoiceRec(component, event,helper,records,index)){
                for(var counter = 0; counter < records.length ; counter++){
                    records[counter].isEditable = true;
                    records[counter].isRemoveEnable = true;
                    invoiceRecords.push(records[counter]);
               		
                }	    
            } else {
                return;
            }
        }
        
       /* for(var counter = 0; counter < records.length ; counter++) {
            if(counter == index) {
                invoiceRecords.push(records[counter].invoiceRec);
                records[counter].isEditable = true;
            } else if(index == -1) {
                invoiceRecords.push(records[counter].invoiceRec);
                records[counter].isEditable = true;
            }
        } */
        
        console.log(invoiceRecords[0]);
        var action = component.get("c.createInvoicewithLineItem");
		// set parameter
        action.setParams({
            "listInvoicesVal": invoiceRecords,
            "indexVal" : index,
            "isInvoice" : isInvoiceSave
        });
        component.set("v.Spinner", true);
        action.setCallback(this, function(response) {
			var state = response.getState();
            component.set("v.Spinner", false);
			if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                console.log(resp);

                if(resp[0].msg != 'Success'){
                    helper.showTostMSG(component, event, helper, 'Error', resp.msg,"dismissible");
                } else{
                    console.log("In else condition---");
                    if(index < 0){
                        component.set("v.listInvoiceWrapper", resp);
                    } else {
                        var recs = component.get("v.listInvoiceWrapper");
                        for(var counter = 0; counter < recs.length ; counter++){
                            if(counter == index){
                                recs[index] = resp[0];
                            }
                        }
                        component.set("v.listInvoiceWrapper", recs);
                        var v = component.get("v.listInvoiceWrapper");
                        console.log(v);
                    }
                }
			} else {

                helper.showTostMSG(component, event, helper, 'Error', response.getReturnValue(),"dismissible");
			}
		});
       // component.set("v.Spinner", false);
		$A.enqueueAction(action);
    },
    // Create Invoice records
    createInvoiceLineItemRec : function(component, event, helper, invoiceIndex, invLineIndex) {
        var records = component.get("v.listInvoiceWrapper");
        console.log(records);
        console.log(invoiceIndex);
        console.log(invLineIndex);
        console.log('====================XXXXXXXXXXX===========================');
        var invoiceRecords = [];
        
         if(invoiceIndex >= 0){
            for(var counter = 0; counter < records.length ; counter++) {
            	if(counter == invoiceIndex) {
                    //if(helper.validateInvoiceRec(component, event,helper,records,counter)){
                        invoiceRecords.push(records[counter]);
                		records[counter].isEditable = true;
                        records[counter].isRemoveEnable = true;
                    //} else {
                    //    return;
                   // }
            	}
            }
        } else if(invoiceIndex == -1) {
            if(records.length < 1){
                helper.showTostMSG(component, event, helper, 'Error', 'No Invoice line item records to save.',"sticky");
                return;
            }
            //if(helper.validateInvoiceRec(component, event,helper,records,index)){
                for(var counter = 0; counter < records.length ; counter++){
                    records[counter].isEditable = true;
                    records[counter].isRemoveEnable = true;
                    invoiceRecords.push(records[counter]);	
                }	    
        }
        
        var action = component.get("c.createInvoicewithLineItem");
		// set parameter
        action.setParams({
            "listInvoicesVal": invoiceRecords,
            "indexVal" : invLineIndex,
            "isInvoice" : false
        });
        component.set("v.Spinner", true);
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            component.set("v.Spinner", false);
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                console.log(resp);
                console.log(resp[0].listInvoiceLineItemWrap[invLineIndex].msg);
                if(resp[0].listInvoiceLineItemWrap[invLineIndex].msg != 'Success'){
                    helper.showTostMSG(component, event, helper, 'Error', resp.msg,"dismissible");
                } else{
                    if(invoiceIndex < 0){
                        component.set("v.listInvoiceWrapper", resp);
                    } else {
                        var recs = component.get("v.listInvoiceWrapper");
                        for(var counter = 0; counter < recs.length ; counter++){
                            if(counter == invoiceIndex){
                                console.log(resp[0]);
                                console.log(resp[0].listInvoiceLineItemWrap);
                                recs[invoiceIndex] = resp[0];
                            }
                        }
                        console.log(recs);
                        component.set("v.listInvoiceWrapper", recs);
                    }
                }
			} else {

                helper.showTostMSG(component, event, helper, 'Error', response.getReturnValue(),"dismissible");
			}
		});
       // component.set("v.Spinner", false);
		$A.enqueueAction(action);
        
    },
    
    showConfirm : function (component, event, helper) {
		var cepRecords = component.get("v.listReceiptsWrapper");
        var invRecords = component.get("v.listInvoiceWrapper");
        var isConfirmed = false;
        if(cepRecords.length >0 || invRecords.length > 0){
            if (confirm("Any unsaved data will be lost!")) {
                isConfirmed = true;
                var records = [];
                component.set("v.listReceiptsWrapper", records);
                component.set("v.listInvoiceWrapper", records); 
            } else {
                return;
            }
        }
        return isConfirmed;
    },
    
    fetchOldEntityData : function(component, event, helper, accId) {
        var cepRecords = component.get("v.listReceiptsWrapper");
        var invRecords = component.get("v.listInvoiceWrapper");
        if((cepRecords.length == 0 && invRecords.length == 0)){
            //component.set("v.showCreateButtons",true);
            //component.set("v.selectedIndex", event.getSource().get("v.name"));
            
            
            var action = component.get("c.getRelatedReceipts");
            // set parameter
            action.setParams({
                "selectedAccountId": accId
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
                        //
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
                "selectedAccountId": accId
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
                        //component.set("v.selectedEntityName", entityRecords[entIndex].accountRec.Name);
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
        }        
    },
     submitRecForApproval : function(component, event, helper, recIds, invoiceIds) {
       var action = component.get("c.submitRecordsForApproval");
		// set parameter
        action.setParams({
            "listReceiptWrapper": recIds,
            "listInvoiceWrapper": invoiceIds 
         });
         
        component.set("v.Spinner", false);
        action.setCallback(this, function(response) {
			var state = response.getState();
            component.set("v.Spinner", false);
			if (state === "SUCCESS" && response.getReturnValue() == "Success") {
                var records = [];
                component.set("v.listReceiptsWrapper", records);
                component.set("v.listInvoiceWrapper", records);  
                var entityRecords = component.get("v.listEntityWrapper");
                var entIndex = component.get("v.selectedIndex");
                helper.fetchOldEntityData(component, event, helper, entityRecords[entIndex].accountRec.Id);
                component.set('v.isOpenSFAModal',false);
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
         
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            console.log(response.getReturnValue());
            component.set("v.Spinner", false);
			if (state === "SUCCESS" && response.getReturnValue() == "Success") {
                var records = [];
                component.set("v.listReceiptsWrapper", records);
                component.set("v.listInvoiceWrapper", records);  
                var entityRecords = component.get("v.listEntityWrapper");
                var entIndex = component.get("v.selectedIndex");
                helper.fetchOldEntityData(component, event, helper, entityRecords[entIndex].accountRec.Id);
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
    // pagination calculation
    renderPage: function(component, event) {
        component.set("v.Spinner",true);
        var records = component.get("v.listEntityWrapper");
        console.log('Entity record count');
        console.log($A.get("$Label.c.Entity_Record_Count"));
        if(records != null) {
            component.set("v.maxPage", Math.ceil((records.length)/$A.get("$Label.c.Entity_Record_Count")));
            
            var pageNumber = component.get("v.pageNumber");
            component.set("v.startIndex", (pageNumber-1)*$A.get("$Label.c.Entity_Record_Count"));
            
            component.set("v.endIndex", pageNumber*$A.get("$Label.c.Entity_Record_Count"));
        }
        component.set("v.Spinner",false);
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