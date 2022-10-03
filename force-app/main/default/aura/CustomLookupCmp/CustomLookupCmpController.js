/**
 * @File Name          : CustomLookupCmpController.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 5/6/2020, 2:59:30 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/25/2020   Jayanta Karmakar     Initial Version
**/
({
    searchField : function(component, event, helper) {
        console.log('called on focus');
        var currentText = event.getSource().get("v.value");
        var resultBox = component.find('resultBox');
        component.set("v.LoadingText", true);
        $A.util.addClass(resultBox, 'slds-is-open');
        /*if(currentText.length > 0) {
            $A.util.addClass(resultBox, 'slds-is-open');
        }
        else {
            $A.util.removeClass(resultBox, 'slds-is-open');
        } */
        var action = component.get("c.getResults");
        action.setParams({
            "ObjectName" : component.get("v.objectName"),
            "fieldName" : component.get("v.fieldName"),
            "value" : currentText,
            "filtertxt" : component.get("v.filter")
        });
        
        action.setCallback(this, function(response){
            console.log('response==>>', response);
            var STATE = response.getState();
            if(STATE === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.searchRecords", response.getReturnValue());
                if(component.get("v.searchRecords").length == 0) {
                    console.log('000000');
                }
            }
            else if (STATE === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            component.set("v.LoadingText", false);
        });
        
        $A.enqueueAction(action);
    },
    clearSearch: function (component, event, helper) {
        console.log('clear search called');
        if(! component.get("v.selectedData")){
            var resultBox = component.find('resultBox');
            $A.util.removeClass(resultBox, 'slds-is-open');
        }
    },    
    setSelectedRecord : function(component, event, helper) {
        console.log('selected record called');
        component.set("v.selectedData",true);
        var currentText = event.currentTarget.id;
        var resultBox = component.find('resultBox');
        console.log(currentText);
        $A.util.removeClass(resultBox, 'slds-is-open');
        //component.set("v.selectRecordName", currentText);
        console.log(JSON.stringify(event.currentTarget.dataset));
        component.set("v.selectRecordName", event.currentTarget.dataset.name);
        component.set("v.selectRecordAmnt", event.currentTarget.dataset.record);
        console.log('-------------------------------------');
        console.log(event.currentTarget.dataset.indt);
        console.log(JSON.stringify(event.currentTarget.dataset));
        component.set("v.invoiceDate", event.currentTarget.dataset.indt);
        component.set("v.selectRecordId", currentText);
        component.set("v.invoiceTaxAmt", event.currentTarget.dataset.inctx);        
        component.find('userinput').set("v.readonly", true);
        var val = component.get("v.valueChanged");
        val = !val;
        component.set("v.valueChanged", val);
    }, 
    
    resetData : function(component, event, helper) {
        component.set("v.selectRecordName", "");
        component.set("v.selectRecordId", "");
        component.set("v.selectRecordAmnt", "0.0");
        component.find('userinput').set("v.readonly", false);
        var val = component.get("v.valueChanged");
        val = !val;
        component.set("v.valueChanged", val);
    }
})