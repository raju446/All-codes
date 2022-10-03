/**
 * @File Name          : LEX_FundTransferController.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 11-09-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/12/2020   Jayanta Karmakar     Initial Version
**/
({
    // Onload function
    init: function (component, event, helper) {
        helper.fetchPicklistValues(component,helper,'Fund_Transfer__c', 'Scenario__c', true);  
        helper.fetchPicklistValues(component,helper,'Fund_Transfer__c', 'From_Source_System__c', false); 
        helper.fetchPicklistValues(component,helper,'Account', 'Oracle_Site_Id__c', false);   
        if(component.get("v.recordId") != undefined){
            helper.fetchOldFundTransfer(component, event, helper);
            component.set("v.isEdit" , true);
        }
    },
    handleGoldenValueChange : function (component, event, helper){
        helper.fetchRelatedEntitiesToGoldenEntity(component, event, helper);
    },
    handleReceiptValueChange: function (cmp, event, helper) {
        var recId = cmp.get("v.selectedReferenceReceipt");
        var showDate = (JSON.stringify(recId) == "{}")?true:false;
        cmp.set("v.isGLDateReadOnly",showDate);
        if(showDate){
            cmp.set("v.fundTransferObj.GL_Date__c",null);
        }
        if(cmp.get("v.canFetchReceiptDetails")){
            helper.fetchReceiptBalance(cmp, event, helper);
        } else {
            cmp.set("v.canFetchReceiptDetails",true);
        }
    },
    handleEntityChange: function (cmp, event, helper) {
        helper.handleEntityValueChange(cmp, event, helper);
    },
    onFromOUChange : function (cmp, event, helper) {
        var ouname = cmp.get("v.selectedFromOU");
        if(ouname != '104' && ouname != '101'){
            cmp.set('v.isFromEntityReadonly', false);
        } else {
            cmp.set('v.isFromEntityReadonly', true);
        }
        
        let sourceSysName = '';
        if(ouname == '102'){
            sourceSysName = 'BM';
        } else if(ouname == '103'){
            sourceSysName = 'BM';
        } else if(ouname == '501'){
            sourceSysName = 'BM';
        } else if(ouname == '502'){
            sourceSysName = 'BM';
        } else if(ouname == '701'){
            sourceSysName = 'BM';
        } 
        cmp.set('v.fundTransferObj.From_Source_System__c', sourceSysName);
        //cmp.set('v.receiptFilterCriteria','AND Payment_Currency__c = \'USD\'');
        cmp.set('v.selectedUnidentifiedEntity', {});
        cmp.set('v.selectedLookUpRecordFrom', {});
        
        var ft = cmp.get('v.fundTransferObj');
        if(ft.Scenario__c != 'Payment in one currency and services in other currency | Same OU' && ft.Scenario__c != 'Unidentified customer balance transfer' && ft.Scenario__c != 'One customer to another customer balance transfer - Same OU'){
            if(ouname == cmp.get("v.selectedToOU")){
                helper.showToast(cmp, event, helper, 'error', 'Error', 'From and To Operating Unit Can not be same.');
                cmp.set("v.selectedFromOU", null);
            }
        }
    }, 
    onToOUChange : function (cmp, event, helper) {
        var ouname = cmp.get("v.selectedToOU");
        if(ouname != '104' && ouname != '101'){
            cmp.set('v.isToEntityReadonly', false);
        } else {
            cmp.set('v.isToEntityReadonly', true);
        }
        
        let sourceSysName = '';
        if(ouname == '102'){
            sourceSysName = 'BM';
        } else if(ouname == '103'){
            sourceSysName = 'BM';
        } else if(ouname == '501'){
            sourceSysName = 'BM';
        } else if(ouname == '502'){
            sourceSysName = 'BM';
        } else if(ouname == '701'){
            sourceSysName = 'BM';
        } 
        cmp.set('v.fundTransferObj.To_Source_System__c', sourceSysName);
        
        cmp.set('v.selectedIdentifiedEntity', {});
        cmp.set('v.selectedLookUpRecordTo', {});
        
        var ft = cmp.get('v.fundTransferObj');
        if(ft.Scenario__c != 'Payment in one currency and services in other currency | Same OU' && ft.Scenario__c != 'Unidentified customer balance transfer' && ft.Scenario__c != 'One customer to another customer balance transfer - Same OU'){
            if(ouname == cmp.get("v.selectedFromOU")){
                helper.showToast(cmp, event, helper, 'error', 'Error', 'From and To Operating Unit Can not be same.');
                cmp.set("v.selectedToOU", null);
            }
        }
    },
    doConfirm : function (cmp, event, helper) {
        var isError = false ;// helper.validateRecord(cmp, event, helper);
        if(! isError){
            cmp.set("v.isReview", true);    
        }   
    },
    doSave: function (cmp, event, helper) {
        helper.doSaveRecord(cmp, event, helper);
    },
    doEdit: function (cmp, event, helper) {
        cmp.set("v.isReview", false);
    }, 
    handleChange: function (component, event) {
        component.set("v.currencySelected",event.getParam("value"));
    },
    handleScenarioChange: function (cmp, event, helper) {
        cmp.set("v.selectedFromOU","");
        cmp.set("v.selectedToOU","");
        cmp.set("v.selectedLookUpRecordFrom",{});
        cmp.set("v.selectedLookUpRecordTo",{});
        cmp.set("v.selectedReferenceReceipt",{});
        cmp.set("v.selectedIdentifiedEntity",{});
        cmp.set("v.selectedUnidentifiedEntity",{});
        cmp.set("v.fundTransferObj.From_Currency__c","");
        cmp.set("v.fundTransferObj.To_Currency__c","");
        cmp.set("v.fundTransferObj.Description__c","");
        cmp.set("v.fundTransferObj.Amount__c","");
        
        helper.handleOnChangeScenario(cmp, event, helper);  
    },
    onFileChange: function (cmp, event, helper) {
        helper.uploadFileOnChange(cmp, event, helper);
    },
    goBack: function (cmp, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
        "recordId": cmp.get("v.fundTransferObj").Id,
        "slideDevName": "detail"
        });
        navEvt.fire();
    },
    closeAction : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    onFromSourceSystemChange : function (cmp, event, helper) {
        let ft = cmp.get("v.fundTransferObj");
        console.log(ft.From_Source_System__c);
        if(ft.From_Source_System__c){
            cmp.set('v.isFromEntityReadonly', false);
        } else {
            cmp.set('v.isFromEntityReadonly', true);
        }
        
        if(ft.From_Source_System__c == 'AccessADGM'){
            cmp.set('v.receiptFilterCriteria','AND Payment_Currency__c = \'AED\'');
        } else if(ft.From_Source_System__c == 'Catalyst'){
            cmp.set('v.receiptFilterCriteria','AND Payment_Currency__c = \'USD\'');
        } else {
            cmp.set('v.receiptFilterCriteria','');
        }
        
        if(ft.Scenario__c == 'Payment in one currency and services in other currency | Same OU'){
            if(ft.From_Source_System__c && ft.To_Source_System__c){
                if(ft.From_Source_System__c == ft.To_Source_System__c){
                    helper.showToast(cmp, event, helper,'error','Error','Source Systems can not be same');
                    cmp.set("v.fundTransferObj.From_Source_System__c" , null);
                }
            }
        }
        
        cmp.set('v.selectedUnidentifiedEntity', {});
        cmp.set('v.selectedLookUpRecordFrom', {});
    },
    handleFromEntityValueChange : function (cmp, event, helper) {
        let fromEntity = cmp.get("v.selectedLookUpRecordFrom");
        if(fromEntity.Id){
            cmp.set('v.fundTransferObj.From_Entity__c', fromEntity.Id);
            var action = cmp.get("c.fetchFromEntityDetails");
            action.setParams({
                entityId : fromEntity.Id
            });
            action.setCallback(this, $A.getCallback(function(response) {
                var response = response.getReturnValue();
                console.log(response);
                cmp.set('v.fromEntityParentId', response.ParentId);
            }));
            $A.enqueueAction(action);
        } else {
            cmp.set('v.fundTransferObj.From_Entity__c', null);
        }
    },
    handleToEntityValueChange : function (cmp, event, helper) {
        let toEntity = cmp.get("v.selectedLookUpRecordTo");
        if(toEntity.Id){
            cmp.set('v.fundTransferObj.To_Entity__c', toEntity.Id);
        } else {
            cmp.set('v.fundTransferObj.To_Entity__c', null);
        }
    },
    onUnidenfiedEntityChange : function (cmp, event, helper) {
        let unEn = cmp.get("v.selectedUnidentifiedEntity");
        if(unEn.Id){
            cmp.set('v.fundTransferObj.From_Entity__c', unEn.Id);
            var action = cmp.get("c.fetchUnidentifiedEntityDetails");
            action.setParams({
                'entityId': unEn.Id
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(response.getReturnValue());
                if (state === "SUCCESS") {
                    console.log(response.getReturnValue().RecordTypeId);
                    if(response.getReturnValue().RecordTypeId){
                        cmp.set('v.identifiedEntityType', response.getReturnValue().RecordTypeId);
                    } 
                } else {
                    console.log("Failed with state: " + state);
                } 
            });
            $A.enqueueAction(action);
        } else {
            cmp.set('v.fundTransferObj.From_Entity__c', null);
        }
    },
    onIdenfiedEntityChange : function (cmp, event, helper) {
        let idEn = cmp.get("v.selectedIdentifiedEntity");
        if(idEn.Id){
            cmp.set('v.fundTransferObj.To_Entity__c', idEn.Id);
            cmp.set('v.isEntitiesSelected', false);
        } else {
            cmp.set('v.fundTransferObj.To_Entity__c', null);
        }
    },
    onToSourceSystemChange: function (cmp, event, helper) {
        let ft = cmp.get("v.fundTransferObj");
        if(ft.To_Source_System__c){
            cmp.set('v.isToEntityReadonly', false);
        } else {
            cmp.set('v.isToEntityReadonly', true);
        }
        if(ft.Scenario__c == 'Payment in one currency and services in other currency | Same OU'){
            if(ft.From_Source_System__c && ft.To_Source_System__c){
                if(ft.From_Source_System__c == ft.To_Source_System__c){
                    helper.showToast(cmp, event, helper,'error','Error','Source Systems can not be same');
                    cmp.set("v.fundTransferObj.To_Source_System__c" , null);
                }
            }
        }
        
        if(ft.Scenario__c == 'Payment in one currency and services in other currency | Different OU'){
            if(ft.To_Source_System__c){
                if(ft.To_Source_System__c == 'AccessADGM'){
                    helper.showToast(cmp, event, helper,'error','Error','Only USD Source System can be selected');
                    cmp.set("v.fundTransferObj.To_Source_System__c" , null);
                }
            }
        }
        
        cmp.set('v.selectedIdentifiedEntity', {});
        cmp.set('v.selectedLookUpRecordTo', {});
    },
    glDateSelected: function(cmp,event,helper){
        var glDate = cmp.get("v.fundTransferObj.GL_Date__c");
        cmp.set("v.isGLDateNotSelected",(glDate == null));
    }
})