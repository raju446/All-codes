/**
 * @description       : 
 * @author            : Jayanta Karmakar
 * @group             : 
 * @last modified on  : 30-05-2021
 * @last modified by  : Jayanta Karmakar
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   30-05-2021   Jayanta Karmakar   Initial Version
**/
({
    // Onload function
    init: function (cmp, event, helper) {
        helper.fetchAccPicklistValues(cmp,'Oracle_Site_Id__c',false);
		var myPageRef = cmp.get("v.pageReference");
        console.log(myPageRef);
        var recordId = myPageRef.state.c__recordId;
        if(recordId){
            console.log(recordId);
            cmp.set("v.recordId", recordId);
            helper.fetchCurrentRecord(cmp);
            // fetch duplicate values 
            helper.fetchDuplicateData(cmp);
        } else {
            cmp.set("v.hasNoId",true);
        }
    },

    // on clicking select all checkbox
    onSelectAll : function (component, event, helper) {
        var selectedIndex = component.get("v.selectedIndex");
        var records = component.get("v.data");
        var selectedVal = component.get("v.selectAll");
        //var radioIndex = component.get("v.selectedIndex");
        var selectedCheckboxCount = component.get("v.selectedCount");
        var maxLength = 10 - selectedCheckboxCount;
        if(records.length < 10){
            maxLength = records.length;
        }
        if(selectedIndex == -1) {
            helper.showTostMSG(component, event, helper, 'Error', "Please select master record.");
            event.getSource().set("v.value", false);
        } else {   
        
            if(selectedVal){
                for(var index = 0 ; index < maxLength; index++){
                    console.log(records[index]);
                    if(selectedIndex != index && !records[index].isSelected && records[selectedIndex].accountRec.RecordType.Name == records[index].accountRec.RecordType.Name) {
                        records[index].isSelected = true; 
                        selectedCheckboxCount++;
                    } else if(records.length > maxLength + 1){
                        maxLength++;
                    }
                    
                }
            } else {
                for(var index = 0 ; index < records.length; index++){
                    records[index].isSelected = false;
                    
                }
                selectedCheckboxCount = 0;
            }
            component.set("v.selectedCount",selectedCheckboxCount);
            component.set("v.data",records);
        }
    },
	// action on radion button select
    onRadionButtonSelection : function (component, event, helper) {
        var newSelectedIndex = event.getSource().get("v.name");
        var selectedCheckboxCount = component.get("v.selectedCount");
        //alert(index);
        var currentSet = component.get("v.data");
        if(currentSet[newSelectedIndex].isSelected) {
            currentSet[newSelectedIndex].isSelected = false; 
            component.set("v.selectedCount", component.get("v.selectedCount") - 1);
        }
        var oldSelectedIndex = component.get("v.selectedIndex");
        if(oldSelectedIndex != -1 && currentSet[newSelectedIndex].accountRec.RecordType.Name != currentSet[oldSelectedIndex].accountRec.RecordType.Name) {
            for(var index = 0 ; index < currentSet.length; index++){
                currentSet[index].isSelected = false;
            }
            selectedCheckboxCount = 0;
            component.set("v.selectAll", false);
        }
        
        component.set("v.data", currentSet);
        component.set("v.selectedCount",selectedCheckboxCount);
        component.set("v.selectedIndex", newSelectedIndex);
    },
    // after checkbox selection action
    updateSelectedText: function (cmp, event) {
        var selectedRows = event.getParam('selectedRows');
        cmp.set('v.selectedRowsCount', selectedRows.length);
        cmp.set("v.selectedRowsList" ,event.getParam('selectedRows') );
    },
    //on change of picklist
    onPrimaryChange: function (cmp, event, helper) {
        
        helper.onChangeRecord(cmp);
    },
    // Merge button action
    mergeAccount :  function (cmp, event, helper){
        var index = cmp.get("v.selectedIndex");
        var records = cmp.get("v.data");
        var recordLst = [];
        if(records) {
            for(var ind =0; ind < records.length; ind++){
                if(records[ind].isSelected){
                    recordLst.push(records[ind].accountRec);
                }
            }
        }
        
        if(! records){
            helper.showTostMSG(cmp, event, helper, 'Error', "No record has been selected.");
        } else if(recordLst.length == 0) {
            helper.showTostMSG(cmp, event, helper, 'Error', "Please select record to merge with master record.");
        } else if(index < 0){
            helper.showTostMSG(cmp, event, helper, 'Error', "Primary entity needs to be selected");
        } else if (confirm("Are you confirm to merge the selected data!")) {
            
                // Call apex controller to perform merge operation
                var action = cmp.get("c.mergeEntities");
                // Set parameter
                action.setParams({
                    "masterRecord": records[index].accountRec,
                    "listDuplicates": recordLst
                });
                cmp.set("v.Spinner", true);
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    cmp.set("v.Spinner", false);
                    if (state === "SUCCESS") {
                        console.log('state'+state);
                        
                        var toastEvent = $A.get("e.force:showToast");
                        console.log('---->'+response.getReturnValue());
                        if(response.getReturnValue() == 'Success') {
                            // Fetch data again
                            if(cmp.get("v.recordId") != null && cmp.get("v.recordId") != '') {
                                helper.fetchDuplicateData(cmp);
                            } else {
                                helper.searchEntities(cmp);
                            }
                            
                            toastEvent.setParams({
                                "title": "Success!",
                                "type" : "success",
                                "message": "The record has been updated successfully."
                            });
                            
                            
                        } else {
                            toastEvent.setParams({
                                "title": "Error!",
                                "type" : "error",
                                "message": response.getReturnValue()
                            });
                            
                        }//end if
                        toastEvent.fire();
            
                } else {
                    console.log("Failed with state: " + state);
                }
            });
            $A.enqueueAction(action); 
        }
    },
   
    // Search button action
    searchButtonClick : function (cmp, event, helper) {
        var sEntityName = cmp.find("entitynameinput");
        var swebsite = cmp.find("entitywebsiteinput");
        
        
        if(sEntityName.get("v.validity").valid) {
            helper.searchEntities(cmp);
        } else {
            var records = [];
            cmp.set("v.data", records);
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
    // clear search panel
    clear : function(component,event,helper){
        component.set("v.entityname", ""); 
        component.set("v.entityEmail", "");
        component.set("v.entityPhone", "");
        component.set("v.entityWebsite", "");
		$A.get('e.force:refreshView').fire();
        // fetch duplicate values 
        if(component.get("v.recordId")){
            helper.fetchDuplicateData(component);
        } else {
            component.set("v.data", []);
        }
        
    },
    // action on selection of checkbox
    onSelect: function(cmp, event, helper) {
        var selectedCheckboxCount = cmp.get("v.selectedCount");
        var selectedVal = event.getSource().get("v.value");
        var index = event.getSource().get("v.name");
        var selectedIndex = cmp.get("v.selectedIndex");
        var records = cmp.get("v.data");
        if(selectedIndex == -1) {
            helper.showTostMSG(cmp, event, helper, 'Error', "Please select master record.");
            event.getSource().set("v.value", false);
        } else if (records[selectedIndex].accountRec.RecordType.Name != records[index].accountRec.RecordType.Name) {
            helper.showTostMSG(cmp, event, helper, 'Error', "You can merge only similar record type data");
            event.getSource().set("v.value", false);
        } else if(selectedCheckboxCount >= 10 && selectedVal){
            helper.showTostMSG(cmp, event, helper, 'Error', "You can select only 10 records for merge.");
            event.getSource().set("v.value", false);
        } else {
            
            if(selectedVal) {
                cmp.set("v.selectedCount", cmp.get("v.selectedCount") + 1);
            } else {
                cmp.set("v.selectedCount", cmp.get("v.selectedCount") -1);
            }    
        }
        
         
    },
    // After revisit the page
    onPageReferenceChanged: function(cmp, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    // Redirection method account record
    navigateBack : function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": component.get("v.recordId"),
          "slideDevName": "related"
        });
        navEvt.fire();
    }
})