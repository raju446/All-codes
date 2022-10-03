({
	doInit : function(component, event, helper) {
        var action = component.get("c.getUserInfo");
                // Check the user profile to enable/disable Entity creation.
                action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (component.isValid() && state === "SUCCESS") {
                            var userInfo = response.getReturnValue();
                            console.log(userInfo);
                            var allowEntityCreationProfileList = ['system admin','crm courts','pwc system admin','system administrator','system admin lex','crm ra business development', 'crm protocol', 'crm contact centre agent - protocol', 'crm - arbitration center'];
                            if(userInfo){
                                if(allowEntityCreationProfileList.indexOf(userInfo.Profile.Name.toLowerCase()) < 0){
                                    component.set("v.allowRecordCreation", false);
                                    console.log('false');
                                }
                                else{
                                    component.set("v.allowRecordCreation", true);
                                    var fetchEntityRecordTypeAction = component.get("c.fetchEntityRecordTypeValues");
                                    fetchEntityRecordTypeAction.setCallback(this, function(response) {
                                        component.set("v.lstOfRecordType", response.getReturnValue());
                                        if(response.getReturnValue()){
                                            var recordTypes = response.getReturnValue();
                                            console.log('recordTypes'+recordTypes);
                                            if(recordTypes)
                                                component.find("selectid").set("v.value", recordTypes[0]);
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
    * and pass the selected RecordType values[label] and this "getEntityRecTypeId"
    * apex method return the selected recordType ID.
    * When RecordType ID comes, we have call  "e.force:createRecord"
    * event and pass object API Name and 
    * set the record type ID in recordTypeId parameter. and fire this event
    * if response state is not equal = "SUCCESS" then display message on various situations.
    */
   createRecord: function(component, event, helper) {
      component.set("v.isOpen", true);
 
      var action = component.get("c.getEntityRecTypeId");
      var recordTypeLabel = component.find("selectid").get("v.value");
       console.log('recordTypeLabel'+recordTypeLabel);
      action.setParams({
         "recordTypeLabel": recordTypeLabel
      });
      action.setCallback(this, function(response) {
         var state = response.getState();
         if (state === "SUCCESS") {
            var createRecordEvent = $A.get("e.force:createRecord");
            var RecTypeID  = response.getReturnValue();
             console.log('RecTypeID'+RecTypeID);
            createRecordEvent.setParams({
               "entityApiName": 'Account',
               "recordTypeId": RecTypeID
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
   },
 
   closeModal: function(component, event, helper) {
      // set "isOpen" attribute to false for hide/close model box 
      component.set("v.isOpen", false);
   },
 
   openModal: function(component, event, helper) {
      // set "isOpen" attribute to true to show model box
      component.set("v.isOpen", true);
   },
})