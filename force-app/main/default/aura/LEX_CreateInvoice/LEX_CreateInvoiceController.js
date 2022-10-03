/**
 * @File Name          : LEX_CreateInvoiceController.js
 * @Description        :
 * @Author             : Jayanta Karmakar
 * @Group              :
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 09-09-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    2/29/2020   Jayanta Karmakar     Initial Version
 **/
({
    doAction: function (component, event, helper) {
      /*  var InvoiceObject = "{ 'sobjectType': 'Invoice__c'}";
        component.set("v.newInvoiceObject", InvoiceObject);
        component.set("v.invoiceLineItems", []);
        component.set("v.selectedLookUpRecords",[]);
        component.set("v.showInvoiceCreateTable", true);
        var invLines = [];
        component.set("v.invoiceLineItems",invLines); */
        //commented
        component.set("v.showInvoiceCreateTable", true);
        
        var today = new Date();
        var tdate = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
        console.log(tdate);
        component.set("v.todaysDate", tdate);
        let mon =  (today.getMonth()+1) < 10 ? '0'+(today.getMonth()+1) : (today.getMonth()+1);
        let dt = today.getDate() < 10 ? '0'+today.getDate() : today.getDate();
        tdate = today.getFullYear()+'-'+mon+'-'+dt;//tdate+'T00:00:00.000z' 
        console.log(tdate);
        component.set('v.newInvoiceObject.GL_Date__c', tdate);
        component.set('v.newInvoiceObject.Invoice_Date__c', tdate);
        var args = event.getParam("arguments");
        component.set("v.accSiteId", args.siteId);
        console.log('--site id is--'+args.siteId);
        component.set("v.entityId", args.accountId);
        console.log('----------'+args.creditMemo);
        component.set("v.isCreditMemo", args.creditMemo);
        helper.fetchRevenueMapping(component, event, helper);
        if(args.oldInvoiceObject != null) {
            component.set("v.newInvoiceObject", args.oldInvoiceObject);
            console.log('----------');
            console.log('----------'+args.oldInvoiceObject);
            //helper.fetchRevenue(component, event, helper,component.get("v.accSiteId"),false,component.find('invType').get('v.value'), component.get("v.isCreditMemo"));
            //helper.fetchRevenueMapping(component, event, helper);
        }
        if(args.oldInvoiceLineItems != null) {
            console.log('/\/\\/\///\/\/\/\/\\');
            console.log(args.oldInvoiceLineItems);
            console.log(component.get('v.revenueMappingObj'));
            for(let i=0;i < args.oldInvoiceLineItems.length; i++){
                if(! args.oldInvoiceLineItems.Discount_Description__c){
                    args.oldInvoiceLineItems[i].EnableDiscountDesc = true;
                }
                    let invLine = args.oldInvoiceLineItems[i];
                    let totalAmount = 0.0;
                    if(invLine.Amount__c && invLine.Quantity__c){
                        totalAmount = invLine.Amount__c * invLine.Quantity__c;
                    }
                    
                    if(invLine.Discount_Amount__c){
                        totalAmount =  totalAmount - invLine.Discount_Amount__c;
                        args.oldInvoiceLineItems[i].EnableDiscountDesc = true;
                        if(invLine.Discount_Amount__c <= 0){
                            args.oldInvoiceLineItems[i].EnableDiscountDesc = false;
                        }
                    } else {
                        args.oldInvoiceLineItems[i].EnableDiscountDesc = false;
                    }
                    
                    if(invLine.Tax__c){
                        if(invLine.Tax__c == '5%'){
                            totalAmount = totalAmount + ((totalAmount * 5)/100) ;
                        }
                    }
                    
                    args.oldInvoiceLineItems[i].LineTotal = totalAmount;
                    console.log(totalAmount);
                   // component.set('v.invoiceLineItems', invLines);
                
            }
            component.set("v.invoiceLineItems", args.oldInvoiceLineItems);
            component.set("v.selectedDept", args.oldInvoiceLineItems[0].Department__c);
        }
        if(args.sourceSys != null && args.sourceSys != '') {
            component.set('v.newInvoiceObject.Source_System__c', args.sourceSys);
        }
        if(args.oldselectedLookUpRecords != null) {
            console.log(args.oldselectedLookUpRecords);
            let receiArray = [];
            for(let i =0 ;i < args.oldselectedLookUpRecords.length; i++){
                let v = args.oldselectedLookUpRecords[i];
                v.Remaning_Amount__c = v.RecAmt;
                receiArray.push(v);
            }
            console.log(receiArray);
            //component.set("v.selectedLookUpRecords", args.oldselectedLookUpRecords);
            component.set("v.selectedLookUpRecords", receiArray);
        }
        
        if(component.get('v.entityId')){
            helper.getEntityOU(component, event, helper);
        }
        
        helper.fetchPicklistValues(component,'Course_Type__c',false);
        helper.fetchPicklistValues(component,'Schools__c',false);
        
        if(component.get("v.isCreditMemo")){
           // helper.fetchRevenue(component, event, helper,args.siteId,true,null, component.get("v.isCreditMemo"));
        }
        
        //helper.fetchRevenueMapping(component, event, helper);
        
        var action = component.get("c.TaxValues");
        action.setCallback(this, function(response) {
			var state = response.getState();
            console.log('custs');
            if (state === "SUCCESS") {
                var custs = [];
                var conts = response.getReturnValue();
                console.log(conts);
                for(var key in conts){
                    custs.push({value:conts[key], key:key});
                }
                
                console.log(custs);
                component.set("v.taxValues", custs); //response.getReturnValue()
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
        
    },
    onServiceTypeChange : function (cmp, event, helper) {
        console.log(event.getSource().get("v.value"));
        console.log('//////////');
        console.log(event.getSource().get("v.name"));
        let currentVal = event.getSource().get("v.value");
        if(currentVal){
            let revMap = cmp.get('v.revenueMappingObj');
            for(let i=0; i< revMap.invRevenueMap.length; i++){
                if(revMap.invRevenueMap[i].serType == currentVal){
                    //cmp.set('v.lineItemList', revMap.invRevenueMap[i].lineItemType);
                    let lines = cmp.get('v.invoiceLineItems');
                    let indx = event.getSource().get("v.name");
                    console.log(revMap.invRevenueMap[i].lineItemType);
                    lines[indx].itemTypes = revMap.invRevenueMap[i].lineItemType;
                    console.log(lines);
                    cmp.set('v.invoiceLineItems',lines);
                }
            }
        } else {
            cmp.set('v.lineItemList', []);
        }
    },
    onItemChange: function (cmp, event, helper) {
        var rts = cmp.get('v.roomRates');
        console.log(event.getSource().get("v.value"));
        let currentVal = event.getSource().get("v.value");
        if(rts.length > 0){
            for(let i=0; i< rts.length; i++){
                if(rts[i].lineType == currentVal){
                    let invLines = cmp.get('v.invoiceLineItems');
                    let indx = event.getSource().get("v.name");
                    invLines[indx].Amount__c = rts[i].usdrate;
                    console.log(invLines);
                    
                    let invLine = invLines[indx];
                    let totalAmount = 0.0;
                    if(invLine.Amount__c && invLine.Quantity__c){
                        totalAmount = invLine.Amount__c * invLine.Quantity__c;
                    }
                    
                    if(invLine.Discount_Amount__c){
                        totalAmount =  totalAmount - invLine.Discount_Amount__c;
                        invLines[indx].EnableDiscountDesc = true;
                        if(invLine.Discount_Amount__c <= 0){
                            invLines[indx].EnableDiscountDesc = false;
                        }
                    } else {
                        invLines[indx].EnableDiscountDesc = false;
                    }
                    
                    if(invLine.Tax__c){
                        if(invLine.Tax__c == '5%'){
                            totalAmount = totalAmount + ((totalAmount * 5)/100) ;
                        }
                    }
                    
                    invLines[indx].LineTotal = totalAmount;
                    
                    cmp.set('v.invoiceLineItems',invLines);
                }
            }
        }
    },
    calculateLineTotal : function (component, event, helper) {
        let invLines = component.get('v.invoiceLineItems');
        let indx = event.getSource().get("v.name");
        console.log(invLines);
        console.log(indx);
        if(invLines.length > 0){
            let invLine = invLines[indx];
            let totalAmount = 0.0;
            if(invLine.Amount__c && invLine.Quantity__c){
                totalAmount = invLine.Amount__c * invLine.Quantity__c;
            }
            
            if(invLine.Discount_Amount__c){
                totalAmount =  totalAmount - invLine.Discount_Amount__c;
                invLines[indx].EnableDiscountDesc = true;
                if(invLine.Discount_Amount__c <= 0){
                    invLines[indx].EnableDiscountDesc = false;
                }
            } else {
                invLines[indx].EnableDiscountDesc = false;
            }
            
            if(invLine.Tax__c){
                if(invLine.Tax__c == '5%'){
                    totalAmount = totalAmount + ((totalAmount * 5)/100) ;
                }
            }
            
            invLines[indx].LineTotal = totalAmount;
            console.log(totalAmount);
            component.set('v.invoiceLineItems', invLines);
        }
    },
    onFileChange: function (cmp, event, helper) {

        var fileAttribute = cmp.get("v.uploadedFiles");
        console.log(fileAttribute);
        let fileObj = event.getSource().get("v.files");
        let compName = event.getSource().get("v.name");
        console.log(event.getSource().get("v.name"));
        console.log(fileObj);
         

        var file = fileObj[0];   
        if(file.size > 2500000){
            helper.showToast('error','Error','File size is too big.');
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
        }
    },
    onCheck : function(component, event, helper){
        console.log(event.getSource().get('v.checked'));
        if(event.getSource().get('v.checked')){
            component.set("v.isSourceInvoiceId",true);
        } else {
            component.set("v.isSourceInvoiceId",false);
        }
        event.getSource().set('v.value', event.getSource().get('v.checked')); 
    },
    onChange : function (component, event, helper) {
        helper.fetchRevenue(component, event, helper,component.get("v.accSiteId"),false,component.find('invType').get('v.value'), component.get("v.isCreditMemo"));
    }, 
    doAddInvoiceLine: function (component, event, helper) {
        helper.addInvoiceLine(component, event, helper);
    },
    removeRow: function (component, event, helper) {
        var lineList = component.get("v.invoiceLineItems");
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        lineList.splice(index, 1);
        component.set("v.invoiceLineItems", lineList);
    },
    toggleReview: function (component, event, helper) {
        //alert(component.get("v.isReview"));
        component.set("v.isValid", true);
        var isValid = helper.validateInvoice(component, event, helper);
        //var isValid = true;
        console.log(isValid);
        if(isValid){
            var isReview = component.get("v.isReview");
            isReview = !isReview;
            component.set("v.isReview", isReview);
        }
    },
    closeModel : function (component, event, helper) {
        //comp.destroy();
        
         helper.closeAll(component, event, helper);
    },
    doSaveInvoice: function (component, event, helper) {
        component.set("v.disableConfirm", true);
        if(component.get("v.isCreditMemo") == true )
        	helper.saveCreditMemo(component, event, helper); 
        else
			helper.saveInvoice(component, event, helper);              
    },
    calculateAmount : function (component, event, helper) {
        console.log('----------------Calculate Amount Called------------------');
        debugger;
        console.log(component.get('v.selectedLookUpRecords'));
        
        var receiptRec = [];
        receiptRec = component.get('v.selectedLookUpRecords');
        var amount = 0.0;//component.get("v.totalAmount");
        for(var i = 0; i < receiptRec.length ; i++) {
            amount = amount + receiptRec[i].Remaning_Amount__c;
        }
        //alert('inside');
        component.set("v.totalAmount", amount);
    },
    
    setAmountToZero : function (component, event, helper) {
        if(! component.get('v.selectedLookUpRecords')){
            component.set("v.totalAmount", 0.0);
        }    
    }
});