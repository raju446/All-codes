/**
 * @File Name          : LEX_CreateReceiptController.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 5/8/2020, 4:02:28 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/29/2020   Jayanta Karmakar     Initial Version
**/
({
	doInit : function(component, event, helper) {
      //  helper.fetchPicklistValues(component, 'Payment_Currency__c', false);
       // helper.fetchPicklistValues(component, 'Payment_Method__c', false);
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
    oncNoChange: function (cmp, event, helper) {
        var inpval = cmp.get("v.newReceiptObject").Credit_Card_F_L_Four_Digits__c;
        if(inpval.length == 4){
            inpval = inpval+"-XXXX-XXXX-";
            cmp.set("v.newReceiptObject.Credit_Card_F_L_Four_Digits__c",inpval);
        } else if(inpval.length == 5){
            let fFour = inpval.substr(0,4);
            let fifthChar = inpval.substr(4,1);
            if(fifthChar > -1){
                inpval = fFour+"-XXXX-XXXX-"+fifthChar;
            } else {
                inpval = fFour+"-XXXX-XXXX-";
            }
            cmp.set("v.newReceiptObject.Credit_Card_F_L_Four_Digits__c",inpval);
        } else if(inpval.length <= 14 && inpval.length > 4){
            inpval = inpval.substr(0,4);
            cmp.set("v.newReceiptObject.Credit_Card_F_L_Four_Digits__c",inpval);
        }
    },
    handleValueChange: function (cmp, event, helper) {
        console.log('on value change called');
        var v = cmp.get('v.invoiceLineItems');
        console.log(JSON.stringify(v));
        var reptObj = cmp.get('v.newReceiptObject');
        console.log(JSON.stringify(reptObj));
        var iApplied = 0;
        let invIds = [];
        for(var i=0;i<v.length;i++){
            if(! v[i].invoiceId){
                v[i].Amount = 0;
            } else if(v[i].Amount){
                iApplied += v[i].Amount;
            }
            invIds.push(v[i].invoiceId);
        }
        let v1 = '('+ invIds.join(',') + ')';
        cmp.set('v.selectedInvoiceIds',invIds);
        cmp.set('v.selInvIds',v1);
        console.log('iApplied '+iApplied);
        console.log('reptObj.Amount__c '+reptObj.Amount__c);

        for(var i=0;i<v.length;i++){
            if(!v[i].Amount && (reptObj.Amount__c - iApplied) > 0 ){
                if( (reptObj.Amount__c - iApplied) >= parseFloat(v[i].invoiceBalAmt)  ){
                    v[i].Amount = parseFloat(v[i].invoiceBalAmt);
                    iApplied += v[i].Amount;
                }else{
                    v[i].Amount = (reptObj.Amount__c - iApplied);
                    iApplied += v[i].Amount;
                }
            }else if(v[i].invoiceBalAmt < 0){
                /*v[i].Amount = (reptObj.Amount__c - iApplied) + parseFloat(v[i].invoiceBalAmt);
                iApplied += v[i].Amount;*/
            }
        }

        console.log('iApplied '+iApplied);

    },
    doAction: function (component, event, helper) {
        component.set("v.ShowReceiptCreateModal", true);
        component.set("v.invoiceLineItems", []);
        component.set("v.newReceiptObject", { 'sobjectType': 'Receipt__c'});
        var today = new Date();
        var tdate = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
        console.log(tdate);
        component.set("v.todaysDate", tdate);
        
        let mon =  (today.getMonth()+1) < 10 ? '0'+(today.getMonth()+1) : (today.getMonth()+1);
        let dt = today.getDate() < 10 ? '0'+today.getDate() : today.getDate();
        tdate = today.getFullYear()+'-'+mon+'-'+dt;//tdate+'T00:00:00.000z' 
        component.set("v.newReceiptObject.GL_Date__c", tdate);
        
        var args = event.getParam("arguments");
       // component.set("v.accSiteId", args.siteId);
        component.set("v.entityId", args.accountId);
        if(args.oldReceiptObject != null) {
            component.set("v.newReceiptObject", args.oldReceiptObject);
        }
        if(args.oldinvoiceLineItems != null) {
            component.set("v.invoiceLineItems", args.oldinvoiceLineItems);
        }
        helper.fetchPicklistValues(component, 'Payment_Currency__c', false);
        helper.fetchPicklistValues(component, 'Payment_Method__c', false);
    },
    doAddRelatedInvoice : function(component, event, helper){
        helper.addInvoiceLine(component, event, helper);
    },
    removeRow: function(component, event, helper) {
        var lineList = component.get("v.invoiceLineItems");
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        lineList.splice(index, 1);
        component.set("v.invoiceLineItems", lineList);
    },
    saveReceipt : function(component, event, helper){
        component.set("v.disableSave", true);
        helper.upsertReceipt(component, event, helper);
    },
    closeModel : function(component, fieldAPIName, nullRequired){
        component.set("v.newReceiptObject", "{ 'sobjectType': 'Receipt__c'}");
        component.set("v.invoiceLineItems", "object[]");
        component.set("v.isReview", false);
        component.set("v.ShowReceiptCreateModal", false);
    },
    toggleReview: function (component, event, helper) {
        var isValid = helper.validateReceipt(component, event, helper);
        console.log(isValid);
        if(isValid){
            var isReview = component.get("v.isReview");
            isReview = !isReview;
            component.set("v.isReview", isReview);
        }
    }
})