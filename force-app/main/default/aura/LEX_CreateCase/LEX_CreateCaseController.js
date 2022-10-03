({
    doInit: function (component, event, helper) {

        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            console.log(response.tabId);
        });
        var fetchCaseRecordTypeAction = component.get("c.fetchCaseRecordTypeValues");
        fetchCaseRecordTypeAction.setCallback(this, function (response) {
            var responseValue = response.getReturnValue();
            console.log(responseValue);
            var optionsList = [];
            var recordTypes = responseValue.recordType;
            var profileName = responseValue.user.Profile.Name;
            console.log(profileName);
            component.set("v.UserProfileName", profileName);
            for (var key in recordTypes) {
                if (recordTypes.hasOwnProperty(key)) {
                    console.log(recordTypes[key]);
                    optionsList.push({
                        value: key,
                        label: recordTypes[key]
                    });
                }
            };
            console.log(optionsList);
            component.set('v.lstOfRecordType', optionsList);
            component.find("selectid").set("v.value", optionsList[0].value); //Setting the default value on load for the select list.
            /*
            component.set("v.lstOfRecordType", response.getReturnValue());
            console.log(response.getReturnValue());
            if(response.getReturnValue()){
                var recordTypes = response.getReturnValue();
                console.log('recordTypes'+recordTypes);
                if(recordTypes)
                    component.find("selectid").set("v.value", recordTypes[0]);
            }
            */
        });
        $A.enqueueAction(fetchCaseRecordTypeAction);

    },

    /* In this "createRecord" function, first we have call apex class method 
     * and pass the selected RecordType values[label] and this "getEntityRecTypeId"
     * apex method return the selected recordType ID.
     * When RecordType ID comes, we have call  "e.force:createRecord"
     * event and pass object API Name and 
     * set the record type ID in recordTypeId parameter. and fire this event
     * if response state is not equal = "SUCCESS" then display message on various situations.
     */
    createRecord: function (component, event, helper) {
        var profileName = component.get("v.UserProfileName");
        console.log(profileName);
        
        var createRecordEvent = $A.get("e.force:createRecord");
        var RecTypeID = component.find("selectid").get("v.value");
        //Set Case Origin:Manual for the below profiles.
        var setCaseOriginForProfiles = ['crm contact centre agent','crm contact centre manager','crm ra business development','adgm business admin','adgm marketing admin','crm case management'];
        if(profileName && setCaseOriginForProfiles.indexOf(profileName.toLowerCase()) > -1){
            createRecordEvent.setParams({
                "entityApiName": 'Case',
                "recordTypeId": RecTypeID,
                "defaultFieldValues": {
                    'Origin' : 'Manual'
                }
            });
        }
        else{
            createRecordEvent.setParams({
                "entityApiName": 'Case',
                "recordTypeId": RecTypeID
            });
        }
        console.log(createRecordEvent);
        createRecordEvent.fire();

        /*
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({
                tabId: focusedTabId
            });

        })
        */
        
    },
    onTabClosed: function (component, event, helper) {

        var workspaceAPI = component.find("workspace");
        workspaceAPI.focusTab({
            tabId: component.get("v.newTabValue")
        });

    },
    onTabCreated: function (component, event, helper) {
        //alert(event.getParam('tabId'));
        component.set("v.newTabValue", event.getParam('tabId'));

    },
    closeModal: function (component, event, helper) {
        // set "isOpen" attribute to false for hide/close model box 
        component.set("v.isOpen", false);
    },

    openModal: function (component, event, helper) {
        // set "isOpen" attribute to true to show model box
        component.set("v.isOpen", true);
    },
})