({
    // Get url id
    getParamValue : function( tabName, paramName ) {
 
        var url = window.location.href;
        var paramValue = window.location.href.split('id=').pop();
       
        return paramValue;
    }, 
    // fetch Campaign Member
	fetchData : function(component, event, helper, fetchExternal) {
        var action = component.get("c.getRecipientsData");
        // set parameter
        action.setParams({
            "campaignId": component.get("v.recordId"),
            "isExternal": fetchExternal
        });
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                component.set("v.showRecipientsTable", true);
                console.log('state'+state);
                var records = response.getReturnValue();
                if(records != null) {
                    
                    component.set("v.totalInvitee",  component.get("v.totalInvitee") + records.length);
                    component.set("v.campaignName", records[0].campaignMemberRec.Campaign.Name);
                    if(fetchExternal) {
                        component.set("v.listCampaignMemberExternal", records);
                    } else {
                        component.set("v.showPagination", true);
                        component.set("v.listCampaignMemberInternal", records);
                        component.set("v.listCampaignMemberWrapper",  component.get("v.listCampaignMemberInternal"));
                        helper.renderPage(component,event);
                    }
            		
                    component.set("v.showRecipientsTable", true);
                } 
                 
              
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
	},
    // fetch Group Data
    fetchGroupData  : function(component) {
    	var action = component.get("c.getGroups");
        // set parameter
        action.setParams({
            "fieldAPIname": 'CRM_Group__c',
            "nullRequired": true
        });
    	action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log('state'+state);
                var records = response.getReturnValue();
                if(records != null) {
                    component.set("v.groupPicklist", records);
                }//end if 
              	console.log(component.get("v.groupPicklist"));
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
	},
    // fetch attachments
    fetchAttachmentData : function(component) {
        var action = component.get("c.getCampaignAttachment");
        // set parameter
        action.setParams({
            "campaignId": component.get("v.recordId")     
        });
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log('state'+state);
                var records = response.getReturnValue();
                if(records != null) {
                    var records = response.getReturnValue();
                    records.forEach(function(record){
                        record.ContentSize  = (record.ContentSize)/ 1000000;
                        record.linkName = '/lightning/r/ContentDocument/'+record.Id+'/view';
                    });
                    component.set("v.attachmentData", records);
                }//end if 
              
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
    },
    // fetch Email Templete Data
    fetchEmailTempleteData : function(component) {
        var action = component.get("c.getEmailTempletesData");
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log('state'+state);
                var records = response.getReturnValue();
                if(records != null) {
                    component.set("v.emailTemplateData", records);
                    component.set("v.showEmailTemplateTable", true);
                }//end if 
              
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
    },
    fetchOrgWideData: function(component) {
        var action = component.get("c.getAllOrgWideEmail");
        // set parameter
        action.setParams({
            "relatedId":null     
        });
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log('state'+state);
                var records = response.getReturnValue();
                if(records != null) {
                    component.set("v.orgWidePicklist", records);
                }//end if 
              
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
    },
    // pagination calculation
    renderPage: function(component, event) {
        var records = component.get("v.listCampaignMemberWrapper");
        component.set("v.maxPage", Math.ceil((records.length)/$A.get("$Label.c.Send_Email_Max_Records")));
        
        var pageNumber = component.get("v.pageNumber");
        component.set("v.startIndex", (pageNumber-1)*$A.get("$Label.c.Send_Email_Max_Records"));
        
        component.set("v.endIndex", pageNumber*$A.get("$Label.c.Send_Email_Max_Records"));
        
	},
    // save event call
    callSaveEventGroup : function(component, event, helper) { 
    	var action = component.get("c.saveEventGroupRec");
         // set parameter
        action.setParams({
            "objEventGroup": component.get("v.objGroup")
        });
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log('state'+state);
                var records = response.getReturnValue();
                
                if(response.getReturnValue() == 'Success') {
                    helper.showTostMSG(component, event, helper, 'Success', 'The record has been save successfully.');
                    helper.fetchGroupData(component);
                    component.set("v.isPopupShow", false);
                    
                } else {
                    helper.showTostMSG(component, event, helper, 'Error', response.getReturnValue());
                    
                }//end else- if
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
    },
    // send email call
    callSendEmail : function(component, event, helper) { 
        var action = component.get("c.sendEmailToAllCampaignMembers");
         // set parameter
        action.setParams({
            "listInternalCampaignMember": component.get("v.listCampaignMemberInternal"),
            "listExternalCampaignMember": component.get("v.listCampaignMemberExternal"),
            "objEmailTemplate": component.get("v.selectedEmailTempletes")[0],
            "isBCC" : component.get("v.isBcc"),
            "orgWideId" : component.get("v.selectedOrgId"),
            "listAttIds" : component.get("v.selectedAttachmentId"),
            "delegatedBy" : ''
        });
         action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log('state'+state);
                var records = response.getReturnValue();
                if(response.getReturnValue() == 'Success') {
                    helper.showTostMSG(component, event, helper, 'Success', 'The email has been send successfully.');
                    $A.get('e.force:refreshView').fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get('v.recordId'),
                        "slideDevName": "Details"
                    });
                    navEvt.fire();
                } else {
                    helper.showTostMSG(component, event, helper, 'Error', response.getReturnValue());
                    
                }//end else- if
              
			} else if (state === "ERROR") {
                var errors = response.getError();

                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +errors[0].message);
                    }
                }
				console.log("Failed with state: " + state);
            } else {
                console.log("Failed with state: " + state);
            }
		});
		$A.enqueueAction(action);
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