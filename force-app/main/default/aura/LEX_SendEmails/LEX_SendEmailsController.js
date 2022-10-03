({
	// Onload function
    init: function (component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var recordId = myPageRef.state.c__recordId;
        component.set("v.recordId", recordId);
        
        component.set('v.attachmentColumns', [
            {label: 'Title', fieldName: 'linkName', type: 'url', typeAttributes: {label: { fieldName: 'Title' }, target: '_blank'}},
            {label: 'File Type', fieldName: 'FileType', type: 'text'},
            {label: 'File Size (MB)', fieldName: 'ContentSize', type: 'number', cellAttributes: { alignment: "left"}}]);
        
        
		// call helper 
		// Internal Invite call
		helper.fetchData(component,event, helper, false);
		// external Invite call
		helper.fetchData(component,event, helper, true);
        helper.fetchGroupData(component);
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
    // Pagination render
    renderPage: function(component, event, helper) {
        helper.renderPage(component, event, component.get("v.listCampaignMemberWrapper"));
    },
    onInviteTypeChange : function (component, event, helper) {
        component.set("v.showPagination", false);
        var currentVal = event.getSource().get("v.value");
        if(currentVal == 'Internal Invite') {
            
            component.set("v.selectAll", component.get("v.selectAllInternal"));
            component.set("v.listCampaignMemberExternal",  component.get("v.listCampaignMemberWrapper"));
            component.set("v.listCampaignMemberWrapper",  component.get("v.listCampaignMemberInternal"));
        } else {
            component.set("v.selectAll", component.get("v.selectAllExternal"));
            component.set("v.listCampaignMemberInternal",  component.get("v.listCampaignMemberWrapper"));
            component.set("v.listCampaignMemberWrapper",  component.get("v.listCampaignMemberExternal"));
        } //end else - if
        var currentRec = component.get("v.listCampaignMemberWrapper");
        
        if(currentRec != null && currentRec.length > 0) {
            component.set("v.pageNumber", 1);
            component.set("v.showPagination", true);
        }//end if
        
        helper.renderPage(component, event);
    }, 
    // next Recipients Process
    nextRecipientsProcess : function (component, event, helper) {
        var selectedVal = component.get("v.inviteType");
        if(selectedVal != 'Internal Invite') {
            component.set("v.listCampaignMemberExternal",  component.get("v.listCampaignMemberWrapper"));
        } else {
            component.set("v.listCampaignMemberInternal",  component.get("v.listCampaignMemberWrapper"));
        } //end else - if
        if(component.get("v.selectedRecipientCount") <= 0 ) {
            helper.showTostMSG(component, event, helper, 'Error', 'Please select recipients to send an email');
        } else {
            component.set("v.showRecipientsTable", false);
            component.set("v.showEmailTemplateTable", true);
            if(component.get("v.isBack") == false) {
                helper.fetchAttachmentData(component);
                helper.fetchOrgWideData(component);
                helper.fetchEmailTempleteData(component);
            } else {
                var selectedRowsIds = component.get("v.selectedAttachmentId");
                component = component.find("partnerTable");
    			component.set("v.selectedRows", selectedRowsIds);
            }//end if
            
        }
        
    },
    // after checkbox selection action
    updateSelectedTemplete: function (component, event, helper) {
        component.set("v.selectedEmailTempletes" ,event.getParam('selectedRows') );
    },
    // call send email process
    sendEmailProcess : function (component, event, helper) {
        console.log(component.get("v.listCampaignMemberWrapper"));
        console.log(component.get("v.selectedEmailTempletes")[0]);
        if(component.get("v.selectedEmailTempletes").length <= 0) {
            helper.showTostMSG(component, event, helper, 'Error', 'Please select at least one email template');
        } else if(component.get("v.totalSelectedSize") > 5 ){
            helper.showTostMSG(component, event, helper, 'Error', 'Selected files exceeds the maximum size limit of 5MB.');
        } else {
            helper.callSendEmail(component, event, helper); 
        }
        
    },
    // back button action
    backProcess : function (component, event, helper) {
        component.set("v.showEmailTemplateTable", false);
        component.set("v.showRecipientsTable", true);
        component.set("v.isBack", true);
    },
    // After picklist value change
    onPicklistChange : function (component, event, helper) {        
        var currentVal = event.getSource().get("v.value");
        
    },
    // Cancel button process
    cancelButton : function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
    	var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": component.get('v.recordId'),
          "slideDevName": "details"
        });
        navEvt.fire();
    },
    
    // call save group name function
    saveEventGroup :  function (component, event, helper) {
        if(component.get("v.objGroup").Name != '' && component.get("v.objGroup").Name != null ) {
        	component.set("v.isPopupShow", false);
        	helper.callSaveEventGroup(component, event, helper);    
        } else {
            helper.showTostMSG(component, event, helper, 'Error', 'Please enter name');
        }
        
    },
    // on single check box click
    checkBoxAction : function (component, event, helper) {
        var currentVal = event.getSource().get("v.value");
        component.set("v.selectAll", false);
         var selectedVal = component.get("v.inviteType");
        
        if(currentVal == true && selectedVal != 'Internal Invite') {
            component.set("v.totalSelectedExternal", component.get("v.totalSelectedExternal") + 1);
            component.set("v.selectedRecipientCount", component.get("v.selectedRecipientCount") + 1);
        } else if(currentVal == true && selectedVal == 'Internal Invite') {
            component.set("v.totalSelectedInternal", component.get("v.totalSelectedInternal") + 1);
            component.set("v.selectedRecipientCount", component.get("v.selectedRecipientCount") + 1);
        } else if(currentVal != true && selectedVal != 'Internal Invite') { 
            component.set("v.totalSelectedExternal", component.get("v.totalSelectedExternal") - 1);
            component.set("v.selectedRecipientCount", component.get("v.selectedRecipientCount") - 1);
        } else if(currentVal != true && selectedVal == 'Internal Invite') { 
            component.set("v.totalSelectedInternal", component.get("v.totalSelectedInternal") - 1);
            component.set("v.selectedRecipientCount", component.get("v.selectedRecipientCount") - 1);
        }
    },
    // radion button action
    onRadionButtonSelection :  function (component, event, helper) {
        component.set("v.selectedIndex", event.getSource().get("v.name"))
        
        component.set("v.selectedEmailTempletes", component.get("v.emailTemplateData")[event.getSource().get("v.name")]);
        console.log(component.get("v.selectedEmailTempletes"));
    },
    // check all the members for send email
    onSelectAll : function (component, event, helper) {
        var records = component.get("v.listCampaignMemberWrapper");
        var selectedVal = component.get("v.selectAll");
        var currentType = component.get("v.inviteType");
        if(currentType == 'Internal Invite') {
            component.set("v.selectAllInternal", selectedVal);
        } else {
            component.set("v.selectAllExternal", selectedVal);
        } 
        for(var index =  0; index < records.length; index++ ) {
            if(selectedVal == true && !records[index].isSelected && currentType == 'Internal Invite' ) {
               component.set("v.totalSelectedInternal", component.get("v.totalSelectedInternal") + 1);
               component.set("v.selectedRecipientCount", component.get("v.selectedRecipientCount") + 1); 
            } else if(selectedVal != true && records[index].isSelected && currentType == 'Internal Invite') {
                component.set("v.totalSelectedInternal", component.get("v.totalSelectedInternal") - 1);
                component.set("v.selectedRecipientCount", component.get("v.selectedRecipientCount") - 1); 
            } if(selectedVal == true && !records[index].isSelected && currentType != 'Internal Invite' ) {
               component.set("v.totalSelectedExternal", component.get("v.totalSelectedExternal") + 1);
               component.set("v.selectedRecipientCount", component.get("v.selectedRecipientCount") + 1); 
            } else if(selectedVal != true && records[index].isSelected && currentType != 'Internal Invite') {
                component.set("v.totalSelectedExternal", component.get("v.totalSelectedExternal") - 1);
                component.set("v.selectedRecipientCount", component.get("v.selectedRecipientCount") - 1); 
            }
            records[index].isSelected = selectedVal;
            
        }
        component.set("v.listCampaignMemberWrapper", records);
    },
    // After revisit the page
    onPageReferenceChanged: function(cmp, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    
    updateSelectedAttachment: function (cmp, event, helper) {
        var selectedRows = event.getParam('selectedRows');
         
        
        var attachmentId = [];
        cmp.set('v.selectedAttachment', selectedRows.Id);
        var totalSize = 0;
        // check the total selected file size
        selectedRows.forEach(function(record){
            console.log(record.Id);
            attachmentId.push(record.Id);
            totalSize = totalSize + record.ContentSize;
        });
        cmp.set("v.totalSelectedSize", totalSize);
        cmp.set("v.selectedAttachmentId", attachmentId);
        console.log(totalSize);
        if(totalSize > 5) {
            helper.showTostMSG(cmp, event, helper, 'Error', 'Selected files exceeds the maximum size limit of 5MB.');
        }//end if
        console.log(cmp.get('v.selectedAttachmentId'));
    },
    onTemplateClone : function (component, event, helper) {
        //if(confirm('Are You Sure!!!')){} 
        
        var currentVal = event.getSource().get("v.value");
        var action = component.get("c.createEmailTemplate");
        // set parameter
        action.setParams({
            "templateID": currentVal     
        });
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log('state'+state);
                var records = response.getReturnValue();
                if(records != null) {
                    component.set("v.emailTemplateData", records);
                }//end if 
              
			} else {
                helper.showTostMSG(component, event, helper, 'Error', response.getReturnValue());
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
        
    }
    
})