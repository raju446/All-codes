/**
 * @File Name          : LEX_CreateEntityHelper.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 5/19/2020, 2:21:14 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/16/2020   Jayanta Karmakar     Initial Version
**/
({
	fetchCloneEntityDetails : function(component, event, helper, entityIdVal) {
		var action = component.get("c.fetchEntityDetails");
        action.setParams({
            'entityId': entityIdVal
        });
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                //alert(response.getReturnValue().objAcc.Name);
                component.set("v.newEntityObject.Name", response.getReturnValue().objAcc.Name);
                component.set("v.newEntityObject.Account_Name_Arabic__c", response.getReturnValue().objAcc.Account_Name_Arabic__c);
                component.set("v.newEntityObject.Email__c", response.getReturnValue().objAcc.Email__c);
                component.set("v.newEntityObject.Phone", response.getReturnValue().objAcc.Phone);
                component.set("v.newEntityObject.Source_System_Id__c", response.getReturnValue().objAcc.Source_System_Id__c);
                component.set("v.newEntityObject.Registered_for_Tax__c", response.getReturnValue().objAcc.Registered_for_Tax__c);
                component.set("v.newEntityObject.Tax_Registration_Number__c", response.getReturnValue().objAcc.Tax_Registration_Number__c);
                component.set("v.newAddressObject.Building_Name__c", response.getReturnValue().objAddressObject.Building_Name__c);
                component.set("v.newAddressObject.Floor__c", response.getReturnValue().objAddressObject.Floor__c);
                component.set("v.newAddressObject.Office_Number__c", response.getReturnValue().objAddressObject.Office_Number__c);
                component.set("v.newAddressObject.Country__c", response.getReturnValue().objAddressObject.Country__c);
                component.set("v.newAddressObject.State__c", response.getReturnValue().objAddressObject.State__c);
                component.set("v.newAddressObject.County__c", response.getReturnValue().objAddressObject.County__c);
                component.set("v.newAddressObject.Emirates__c", response.getReturnValue().objAddressObject.Emirates__c);
                component.set("v.newAddressObject.Street_Name_of_Cluster_on_the_Island__c", response.getReturnValue().objAddressObject.Street_Name_of_Cluster_on_the_Island__c);
                component.set("v.newAddressObject.POBoxNumber__c", response.getReturnValue().objAddressObject.POBoxNumber__c);
                //component.set("v.newAddressObject", response.getReturnValue().objAddressObject);
                //component.set("v.newEntityObject", response.getReturnValue().objAcc);
                //component.set("v.newEntityObject.Id", "");
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
    },
    fetchBMMetaData : function (component, event, helper) {
        var action = component.get("c.fetchBillingManagementMDTDetail");
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                let resp = response.getReturnValue();
                component.set('v.bmMdt', resp);
                if(resp.Default_OU__c == 'All'){
                    component.set('v.isOUDisabled', false);
                } else {
                    component.set('v.OUName', resp.Default_OU__c);
                    component.set('v.newEntityObject.Oracle_Site_Id__c', resp.Default_OU__c);
                    console.log(resp.Default_OU__c);
                    component.set('v.isOUDisabled', true);
                    component.set('v.newEntityObject.Source_System__c', resp.Default_Source_System__c);
                    component.set('v.sourceSysName', resp.Default_Source_System__c);
                    /*if(resp.Default_OU__c != '101'){
                        component.set('v.newEntityObject.Source_System__c', 'BM');
                        component.set('v.sourceSysName', 'BM');
                    }*/
                }
			} else {
				console.log("Failed with state: " + state);
			}
		});
       // component.set("v.Spinner", false);
		$A.enqueueAction(action);
    }
})