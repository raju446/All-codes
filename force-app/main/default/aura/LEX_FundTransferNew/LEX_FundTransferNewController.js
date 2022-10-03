({
	init : function(component, event, helper) {
		//helper.fetchPicklistValues(component,helper,'Fund_Transfer__c', 'Scenario__c', true);  
        helper.fetchPicklistValues(component,helper,'Fund_Transfer__c', 'From_Source_System__c', false); 
        helper.fetchPicklistValues(component,helper,'Account', 'Oracle_Site_Id__c', false);  
	},
    
    handleCurrencyChange : function(component, event, helper){
        helper.handleCurrencyChange(component, event, helper);
    },
    doConfirm : function (cmp, event, helper) {
        var isError =  helper.validateRecord(cmp, event, helper);//false
        console.log(isError);
        if(!isError){
            cmp.set("v.isReview", true);    
        }   
    },
    doEdit: function (cmp, event, helper) {
        cmp.set("v.isReview", false);
    },
    doSave: function (cmp, event, helper) {
        helper.doSaveRecord(cmp, event, helper);
    },
    handleOUChange : function(component, event, helper){
        var selectedOU = component.get('v.selectedOU');
        var selectedToEntity = component.find('toCustomer');
        selectedToEntity.clearValues();
        
        if(selectedOU == 'Same Operating Unit' && component.get("v.selectedFromOU") != ''){
            component.set("v.selectedToOU", component.get("v.selectedFromOU"));
            if(component.get('v.fundTransferObj.From_Source_System__c') == 'Access'){
                component.set('v.fundTransferObj.To_Source_System__c','AccessADGM');
            }else{
            	component.set('v.fundTransferObj.To_Source_System__c', component.get('v.fundTransferObj.From_Source_System__c'));    
            }
            
            if(component.get("v.selectedFromOU") == '' || component.get('v.fundTransferObj.From_Source_System__c') == ''){
                component.set('v.isFromEntityReadonly', true);
            	component.set('v.isToEntityReadonly', true); 
            }else if(component.get('v.fundTransferObj.From_Source_System__c') != '' && component.get("v.selectedFromOU") != ''){
                component.set('v.isFromEntityReadonly', false);
            	component.set('v.isToEntityReadonly', false); 
            }
        }else if(selectedOU == 'Different Operating Unit' && component.get("v.selectedFromOU") != ''){
            component.set("v.selectedToOU", '');
            component.set('v.fundTransferObj.To_Source_System__c', '');
            component.set('v.isToEntityReadonly', true);
        }else if(component.get("v.selectedFromOU") == ''){
        	component.set('v.isFromEntityReadonly', true);
            component.set('v.isToEntityReadonly', true);
        }
        
        helper.handleCurrencyChange(component, event, helper);
        
    },
    onFromOUChange : function(component, event, helper){
        var ouname = component.get("v.selectedFromOU");
        
        let sourceSysName = '';
        if(ouname == '102' || ouname == '103' || ouname == '501' || ouname == '502' || ouname == '701'){
            sourceSysName = 'BM';
        } 
        component.set('v.fundTransferObj.From_Source_System__c', sourceSysName);
        
        var ouScenario = component.get("v.selectedOU");
        if(ouScenario == 'Same Operating Unit'){
            
            var selectedFromEntity = component.find('fromCustomer');
        	selectedFromEntity.clearValues();
            var selectedToEntity = component.find('toCustomer');
        	selectedToEntity.clearValues();
            
            component.set("v.selectedToOU", ouname);
            component.set('v.fundTransferObj.To_Source_System__c', component.get('v.fundTransferObj.From_Source_System__c'));
            if(ouname == '' || component.get('v.fundTransferObj.From_Source_System__c') == ''){
            	component.set('v.isFromEntityReadonly', true);
            	component.set('v.isToEntityReadonly', true);    
            }else if(component.get('v.fundTransferObj.From_Source_System__c') != '' && ouname != ''){
                component.set('v.isFromEntityReadonly', false);
            	component.set('v.isToEntityReadonly', false);
            }
        }else if(ouScenario == 'Different Operating Unit'){
            var selectedFromEntity = component.find('fromCustomer');
        	selectedFromEntity.clearValues();
            if(ouname == '' || component.get('v.fundTransferObj.From_Source_System__c') == ''){
            	component.set('v.isFromEntityReadonly', true);
            }else if(component.get('v.fundTransferObj.From_Source_System__c') != '' && ouname != ''){
                component.set('v.isFromEntityReadonly', false);
            }
        }
        
        helper.handleCurrencyChange(component, event, helper);
    },
    onFromSourceSystemChange : function(component, event, helper){
        let ouname = component.get("v.fundTransferObj.From_Source_System__c");
        let ouScenario = component.get("v.selectedOU");
        if(ouScenario == 'Same Operating Unit'){
            component.set('v.fundTransferObj.To_Source_System__c', component.get('v.fundTransferObj.From_Source_System__c'));
            if(ouname != ''){
                component.set('v.isFromEntityReadonly', false);
            	component.set('v.isToEntityReadonly', false);
            }else{
                component.set('v.isFromEntityReadonly', true);
            	component.set('v.isToEntityReadonly', true);
            }
        }else{
            if(component.get('v.fundTransferObj.From_Source_System__c') == ''){
                component.set('v.isFromEntityReadonly', true);
            }else{
                component.set('v.isFromEntityReadonly', false);
            }
        }
        
        let ft = component.get("v.fundTransferObj");
        if(ft.From_Source_System__c == 'Access'){
            component.set('v.receiptFilterCriteria','AND Payment_Currency__c = \'AED\'');
        } else if(ft.From_Source_System__c == 'Catalyst'){
            component.set('v.receiptFilterCriteria','AND Payment_Currency__c = \'USD\'');
        } else {
            component.set('v.receiptFilterCriteria','');
        }
        
        helper.handleCurrencyChange(component, event, helper);
        
    },
    handleFromEntityValueChange : function (cmp, event, helper) {
        
        var selectedFromReceipt = cmp.find('fromReceipt');
        selectedFromReceipt.clearValues();
        
        let fromEntity = cmp.get("v.selectedLookUpRecordFrom");
        if(fromEntity.Id){
            cmp.set('v.fundTransferObj.From_Entity__c', fromEntity.Id);
            console.log('cmp.getv.fundTransferObj.To_Entity__c)==>', cmp.get('v.fundTransferObj.To_Entity__c'));
            if(cmp.get('v.fundTransferObj.To_Entity__c') != '' && cmp.get('v.fundTransferObj.To_Entity__c') != undefined){
               cmp.set('v.disableReceiptSelection', false);    
        	}else{
            	cmp.set('v.disableReceiptSelection', true);    
        	}
        
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
            cmp.set('v.disableReceiptSelection', true);
		}
 	},
    onToOUChange : function(component, event, helper){
        var ouname = component.get("v.selectedToOU");
        console.log('ouname==>>' , ouname);
        let sourceSysName = '';
        if(ouname == '102' || ouname == '103' || ouname == '501' || ouname == '502' || ouname == '701' || ouname == '104'){
            sourceSysName = 'BM';
        } 
        component.set('v.fundTransferObj.To_Source_System__c', sourceSysName);
        
        if(component.get("v.selectedOU") == 'Different Operating Unit'){
            if(ouname == '' || component.get('v.fundTransferObj.To_Source_System__c') == ''){
            	component.set('v.isToEntityReadonly', true);
            }else if(component.get('v.fundTransferObj.To_Source_System__c') != '' && ouname != ''){
                component.set('v.isToEntityReadonly', false);
            }
        }
        
        helper.handleCurrencyChange(component, event, helper);
        if(component.get("v.selectedOU") == 'Different Operating Unit'){
        	if(component.get('v.fundTransferObj.To_Source_System__c') == ''){
                component.set('v.isToEntityReadonly', true);
            }else{
                component.set('v.isToEntityReadonly', false);
            }
        }
    },
    onToSourceSystemChange : function(component, event, helper){
        console.log('called');
        var ouname = component.get("v.fundTransferObj.To_Source_System__c");
        if(component.get("v.selectedOU") == 'Different Operating Unit'){
        	if(component.get('v.fundTransferObj.To_Source_System__c') == ''){
                component.set('v.isToEntityReadonly', true);
            }else{
                component.set('v.isToEntityReadonly', false);
            }
        }
        
        helper.handleCurrencyChange(component, event, helper);
        
    },
    handleToEntityValueChange : function (component, event, helper) {
        
        
        let toEntity = component.get("v.selectedLookUpRecordTo");
        
        if(toEntity.Id){
            component.set('v.fundTransferObj.To_Entity__c', toEntity.Id);
            component.set('v.disableReceiptSelection', false);
        } else {
            component.set('v.fundTransferObj.To_Entity__c', null);
            component.set('v.disableReceiptSelection', true);
        }
    },
    handleReceiptValueChange: function (component, event, helper) {
        var recId = component.get("v.selectedReferenceReceipt");
        var showDate = (JSON.stringify(recId) == "{}")?true:false;
        component.set("v.isGLDateReadOnly",showDate);
        if(showDate){
            component.set("v.fundTransferObj.GL_Date__c",null);
        } 
        if(component.get("v.canFetchReceiptDetails")){
            helper.fetchReceiptBalance(component, event, helper);
        } else {
            component.set("v.canFetchReceiptDetails",true);
        }
    },
    glDateSelected: function(cmp,event,helper){
        var glDate = cmp.get("v.fundTransferObj.GL_Date__c");
        cmp.set("v.isGLDateNotSelected",(glDate == null));
    },
    onFileChange: function (cmp, event, helper) {
        helper.uploadFileOnChange(cmp, event, helper);
    }
})