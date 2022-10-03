({
	doInit : function(component, event, helper) {
        var recordTypeAction = component.get("c.fetchCampaignRecordTypeValues");
        recordTypeAction.setCallback(this, function (response) {
            var responseValue = response.getReturnValue();
            console.log(responseValue);
            var custs = [];
            var recordTypes = responseValue.mapRecordTypes;
            
            var keyVal = [];
            var i=0;
            for(var key in recordTypes){
                console.log(key);
                if(key != 'Select a Record Type')
                	keyVal[i] = key;
                i++;
            }
            console.log(keyVal);
            keyVal.sort();
            for(var key in keyVal) {
                custs.push({value:recordTypes[keyVal[key]], key:keyVal[key]});
            }
            console.log(custs);
            if(recordTypes['Select a Record Type']  != null )
            	custs.push({value:recordTypes['Select a Record Type'], key:'Select a Record Type'});
            component.set('v.mapOfRecordType', custs);
           
        });
        $A.enqueueAction(recordTypeAction);

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
      component.set("v.isOpen", true);
 		var createRecordEvent = $A.get("e.force:createRecord");
       var RecTypeID = component.get("v.selectedRecordTypeId");
       console.log('RecTypeID'+RecTypeID);

       createRecordEvent.setParams({
           "entityApiName": 'Campaign',
           "recordTypeId": RecTypeID,
           "defaultFieldValues": {
               'CRM_Event_Requestor__c' : $A.get("$SObjectType.CurrentUser.Id")
           }
       });
       createRecordEvent.fire();
       component.set("v.isOpen", false);
   },
    optionSelected: function(component, event, helper) {
        var recordId = event.target.getAttribute("value");
		component.set("v.selectedRecordTypeId", recordId);
        
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