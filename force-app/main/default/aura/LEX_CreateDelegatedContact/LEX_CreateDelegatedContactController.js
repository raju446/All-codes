({
	doInit : function(component, event, helper) {
        if(component.get("v.recordId") != null && component.get("v.recordId") != '') {
           component.set("v.isProtocol", true);
           var ac  = component.get("c.getTaskDetails");
            ac.setParams({
                tskId : component.get("v.recordId")
            });
        
            ac.setCallback(this, function(a) {
                if (a.getState() === "SUCCESS") {
                                      
                    component.set("v.taskRecord", a.getReturnValue());
                } else if (a.getState() === "ERROR") {
                    $A.log("Errors", a.getError());
                }
            });
        
            $A.enqueueAction(ac);
       }else {
       		component.set("v.isOpen", true);    
       }
        var action = component.get("c.getUserInfo");
                // Check the user profile to enable/disable Entity creation.
                action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (component.isValid() && state === "SUCCESS") {
                            var userInfo = response.getReturnValue();
                            console.log(userInfo);
                            var allowEntityCreationProfileList = ['system admin','crm courts','pwc system admin','system administrator','system admin lex','crm ra business development','crm financial centre development', 'crm protocol', 'crm contact centre agent - protocol'];
                            if(userInfo){
                                if(allowEntityCreationProfileList.indexOf(userInfo.Profile.Name.toLowerCase()) < 0){
                                    component.set("v.allowRecordCreation", false);
                                    console.log('false');
                                }
                                else{
                                    component.set("v.allowRecordCreation", true);
                                    var fetchEntityRecordTypeAction = component.get("c.fetchContactRecordTypeValues");
                                    fetchEntityRecordTypeAction.setCallback(this, function(response) {
                                        
                                        if(response.getReturnValue()){
                                            var recordTypes = response.getReturnValue();
                                            component.set("v.lstOfRecordType", response.getReturnValue());
                                            console.log('recordTypes'+recordTypes.length);
                                            if(recordTypes.length == 1){
                                                component.find("selectid").set("v.value", recordTypes[0]);
                                                var a = component.get('c.createRecord');
        										$A.enqueueAction(a);
                                            }
                                        }
                                    });
                                    $A.enqueueAction(fetchEntityRecordTypeAction);
                                }
                            }
                        }
                        
                        else {
                        console.log("Failed with state: " + state);
                        }
                });

                // Send action off to be executed
                $A.enqueueAction(action);
        
	},
 
   /* In this "createRecord" function, first we have call apex class method 
    * and pass the selected RecordType values[label] and this "getContactRecTypeId"
    * apex method return the selected recordType ID.
    * When RecordType ID comes, we have call  "e.force:createRecord"
    * event and pass object API Name and 
    * set the record type ID in recordTypeId parameter. and fire this event
    * if response state is not equal = "SUCCESS" then display message on various situations.
    */
   createRecord: function(component, event, helper) {
       
      
		
      var action = component.get("c.getContactRecTypeId");
       var recordTypeLabel = component.find("selectid").get("v.value");
       console.log('recordTypeLabel'+recordTypeLabel);
      action.setParams({
         "recordTypeLabel": recordTypeLabel
      });
      action.setCallback(this, function(response) {
         var state = response.getState();
         if (state === "SUCCESS") {
            var tskRec = component.get("v.taskRecord");
            var createRecordEvent = $A.get("e.force:createRecord");
            var RecTypeID  = response.getReturnValue();
             //alert(tskRec);
            createRecordEvent.setParams({
               "entityApiName": 'Contact',
               "recordTypeId": RecTypeID,
                "defaultFieldValues": {
                    'AccountId' : tskRec.objTask.CRM_External_Company_Id__c,
                    'FirstName' : tskRec.objTask.CRM_External_First_Name__c,
                    'LastName' : tskRec.objTask.CRM_External_Last_Name__c,
                    'Email' : tskRec.objTask.CRM_External_Email__c,
                    'MobilePhone' : tskRec.objTask.CRM_External_Mobile__c,
                    'CRM_Mobile_Country_Code__c' : tskRec.objTask.CRM_External_Country_Code__c,
                    'CRM_Other_Job_Title__c' : tskRec.objTask.CRM_External_Job_Title__c,
                    'Country__c' : tskRec.objContact.Country__c,
                    'CRM_Delegated_State__c' : tskRec.objContact.State_Province__c,
                    'City__c' : tskRec.objContact.City__c,
                    'Street__c' : tskRec.objContact.Street__c,
                    'Zip_Postal_Code_PO_Box__c' : tskRec.objContact.Zip_Postal_Code_PO_Box__c,
                    'Middle_Name__c' : tskRec.objTask.CRM_External_Middle_Name__c,
                    'CRM_Current_Campaign__c' : tskRec.objTask.WhatId,
                    'CRM_I_Agree__c' : true,
                    'Job_Code__c' : tskRec.objLookup.Id
                }
            });
            createRecordEvent.fire();
             
         } else if (state == "INCOMPLETE") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
               "title": "Oops!",
               "message": "No Internet Connection"
            });
            toastEvent.fire();
             
         } else if (state == "ERROR") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
               "title": "Error!",
               "message": "Please contact your administrator"
            });
            toastEvent.fire();
         }
      });
      $A.enqueueAction(action);
       var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
   },
 
   closeModal: function(component, event, helper) {
      // set "isOpen" attribute to false for hide/close model box 
      component.set("v.isOpen", false);
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
   },
 
   openModal: function(component, event, helper) {
      // set "isOpen" attribute to true to show model box
      component.set("v.isOpen", true);
   },
})