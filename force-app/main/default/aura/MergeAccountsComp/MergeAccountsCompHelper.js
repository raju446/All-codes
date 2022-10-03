/**
 * @description       : 
 * @author            : Jayanta Karmakar
 * @group             : 
 * @last modified on  : 30-05-2021
 * @last modified by  : Jayanta Karmakar
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   27-05-2021   Jayanta Karmakar   Initial Version
**/
({
    fetchAccPicklistValues : function(component, fieldAPIName, nullRequired) {
		var action = component.get("c.fetchPickListValue");
		// set parameter
        action.setParams({
            'fieldAPIname': fieldAPIName
        });
        component.set("v.Spinner", true);
        action.setCallback(this, function(response) {
			var state = response.getState();
            component.set("v.Spinner", false);
			if (state === "SUCCESS") {
                //var records = response.getReturnValue();
                if(fieldAPIName == 'Oracle_Site_Id__c') {
                    component.set("v.ouPicklist", response.getReturnValue());
                } 
			}else{
				console.log("Failed with state: " + state);
			}
		});
       // component.set("v.Spinner", false);
		$A.enqueueAction(action);
	},
    // Fetch current record data
    fetchCurrentRecord : function(cmp) {
         // fetch current data
		var action = cmp.get("c.getCurrentAccount");
        action.setParams({
            "recordId": cmp.get("v.recordId")
        });
        cmp.set("v.Spinner", true);
		action.setCallback(this, function(response) {
            var state = response.getState();
            cmp.set("v.Spinner", false);
			if (state === "SUCCESS") {
                console.log('state'+state);
                var currentRec = response.getReturnValue();
                cmp.set("v.entityEmail", currentRec[0].Email__c);
                cmp.set("v.entityPhone", currentRec[0].Phone);
                cmp.set("v.entityWebsite", currentRec[0].Website);
                cmp.set("v.entityname", currentRec[0].Name);
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
    },
    onChangeRecord : function(cmp) {
		var selVal = cmp.get("v.selectedValue");
        var dataLst = cmp.get("v.data");
        for(var index =0 ; index < dataLst.length; index++){
            if(dataLst[index].Id == selVal){
                var newLst = [];
                newLst.push(dataLst[index]);
				cmp.set("v.selecteddata",newLst);                
            }
        }
    },
    // Fetch Duplicate record data
	fetchDuplicateData : function(cmp) {
        console.log('Inside fetchDuplicateData'+cmp.get("v.recordId"));
        
        // fetch duplicate data
		var action = cmp.get("c.getDuplicateAccounts");
        action.setParams({
            "recordId": cmp.get("v.recordId")
        });
        cmp.set("v.Spinner", true);
		action.setCallback(this, function(response) {
            var state = response.getState();
            cmp.set("v.Spinner", false);
			if (state === "SUCCESS") {
                console.log('state'+state);
                var records =response.getReturnValue();
               // records.forEach(function(record){
                    //record.linkName = '/'+record.Id;
                //});
                //console.log(records);
                cmp.set("v.data", records);
               // cmp.set("v.loaded", false);
                for(var index =0; index< records.length; index++){
                    if(records[index].accountRec.Id == cmp.get("v.recordId")){
                        cmp.set("v.selectedIndex", index);
                    }
                }
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
        
	},
	// Search Entities 
	searchEntities : function(cmp) {
        console.log('Inside searchEntities'+cmp.get("v.recordId"));
        var action = cmp.get("c.getSearchResult");
        var v = cmp.get("v.data");
        console.log(v);
        cmp.set("v.Spinner", true); 
        // set parameter
        action.setParams({
            "recordId": cmp.get("v.recordId"),
            "listCurrentAccounts" : cmp.get("v.data"),
            "sName": cmp.get("v.entityname"), 
            "sEmail": cmp.get("v.entityEmail"),
            "sPhone": cmp.get("v.entityPhone"),
            "sWebsite": cmp.get("v.entityWebsite"),
            "siteid" : cmp.get("v.SelectedOU")
        });
		action.setCallback(this, function(response) {
            var state = response.getState();
            cmp.set("v.Spinner", false); 
			if (state === "SUCCESS") {
                console.log('state'+state);
                var records =response.getReturnValue();
                //records.forEach(function(record){
                   // record.linkName = '/'+record.Id;
               // });
                console.log(records);
                cmp.set("v.data", records);
              
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
        
	},
	// define table row actions    
    getRowActions: function (cmp, row, doneCallback) {
        var actions = [{
            'label': 'Show Details',
            'iconName': 'utility:zoomin',
            'name': 'show_details'
        },
        {
            'label': 'Remove Duplicate',
            'iconName': 'utility:cut',
            'name': 'Remove_Duplicate'
        }];
       

        // simulate a trip to the server
        setTimeout($A.getCallback(function () {
            doneCallback(actions);
        }), 200);
    },
    showTostMSG : function(component, event, helper, isSuccess, msg) {
        var toastEvent = $A.get("e.force:showToast");
        if(isSuccess == 'Success') {
            toastEvent.setParams({
                "title": "Success!",
                "type" : "success",
                "message": msg
            });
        } else {
            toastEvent.setParams({
                "title": "Error!",
                "type" : "error",
                "message": msg
            });
            
        }//end else- if
        toastEvent.fire();
    }
    
})