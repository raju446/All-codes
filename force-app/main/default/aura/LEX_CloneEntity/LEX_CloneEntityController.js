({
	doInit : function(component, event, helper) {
		var action2 = component.get("c.fetchAccountPicklistVal");
        action2.setParams({
            "fieldAPIname" : "Oracle_Site_Id__c",
            "nullRequired" : false
        });
        action2.setCallback(this,function(response){
            var state=response.getState();            // getting the state
            if(state==='SUCCESS'){
                var sourceSystemVal = response.getReturnValue();                
                //console.log(v);
               for (let i = sourceSystemVal.length - 1; i >= 0; --i) {
                    if(sourceSystemVal[i].picklistLabel == component.get("v.selectEntityAuth") || sourceSystemVal[i].picklistLabel =='ADGM Courts OU' ){
                        sourceSystemVal.splice(i,1);
                    }                 
               }
                component.set("v.ouList",sourceSystemVal);
            }
        });
		$A.enqueueAction(action2);
	},
    createEntityRecord : function(component, event, helper) {
        
        //alert(component.get("v.selectEntityId"));
        //alert(component.get("v.selectedSourceSystem"));
        if(component.get("v.selectedSourceSystem") == '' || component.get("v.selectedSourceSystem") == null || component.get("v.selectedSourceSystem") == undefined) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "mode" : "sticky",
                "title": "Error!",
                "type" : "error",
                "message": "Please select Authority"
            });
            toastEvent.fire();            
        }else{
            var action2 = component.get("c.cloneEntity");
            action2.setParams({
                "accId" : component.get("v.selectEntityId"),
                "ouName" : component.get("v.OUName"),
                "sourceSystemName" : component.get("v.selectedSourceSystem")
            });
            action2.setCallback(this,function(response){
                var state=response.getState();            // getting the state
                if(state==='SUCCESS'){
                    //alert(response.getReturnValue().msg);
                    if(response.getReturnValue().msg == 'Success') {
                        console.log(response.getReturnValue());
                        console.log(response.getReturnValue().accountRec);
                        //vname = JSON.stringify(response.getReturnValue().accountRec);
                        var evt = $A.get("e.c:LEX_CreateEntityEvent");
                        evt.setParams({ 
                            "returnedAccounts": JSON.stringify(response.getReturnValue().accountRec)
                        });
                        evt.fire();
                        
                        component.set("v.selectEntityId", "");
                        component.set("v.selectedSourceSystem", "");
                        component.set("v.showCloneEntity",false);
                        component.set("v.selectEntityAuth", "");
                    } else {
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "mode" : "sticky",
                            "title": "Error!",
                            "type" : "error",
                            "message": response.getReturnValue().msg
                        });
                        toastEvent.fire();
                        
                    }
                }
            });
            $A.enqueueAction(action2);  
        }
        
    },
    closeModel : function(component, event, helper) {
        component.set("v.selectEntityId", "");
        component.set("v.selectEntityAuth", "");
        
        component.set("v.selectedSourceSystem", "");
        component.set("v.showCloneEntity",false);
    },
    
    onOUChange : function(cmp, event, helper) {
        var sourceSyslist = [];
        cmp.set("v.OuListSourceSys",sourceSyslist);
        
         var selectedOU=  cmp.get("v.OUName");
        var sourceSys ;
        /*
        if(selectedOU == '104') {
            sourceSys = {  picklistLabel : "Catalyst",  picklistVal  : "Catalyst"};
            sourceSyslist.push(sourceSys);
        }
        if(selectedOU == '501') {
            sourceSys = {  picklistLabel : "Academy",  picklistVal  : "Academy"};
            sourceSyslist.push(sourceSys);
        }
        
        if(selectedOU == '502') {
            sourceSys = {  picklistLabel : "Fintech",  picklistVal  : "Fintech"};
            sourceSyslist.push(sourceSys);
        }
        if(selectedOU == '701') {
            sourceSys = {  picklistLabel : "Bridge Property",  picklistVal  : "Bridge Property"};
            sourceSyslist.push(sourceSys);
        }
        if(selectedOU == '102') {
            sourceSys = {  picklistLabel : "ADGM Courts",  picklistVal  : "ADGM Courts"};
            sourceSyslist.push(sourceSys);
        }
        if(selectedOU == '103') {
            sourceSys = {  picklistLabel : "FSRA",  picklistVal  : "FSRA"};
            sourceSyslist.push(sourceSys);
        }
        */
        if(selectedOU == '101') {
            sourceSys = {  picklistLabel : "BM - ADGM",  picklistVal  : "BM - ADGM"};
            sourceSyslist.push(sourceSys);
            sourceSys = {  picklistLabel : "BM - Arbitration",  picklistVal  : "BM - Arbitration"};
            sourceSyslist.push(sourceSys);
        } else {
            sourceSys = {  picklistLabel : "BM",  picklistVal  : "BM"};
            
            cmp.set('v.selectedSourceSystem', 'BM');
            sourceSyslist.push(sourceSys);
        }
        
        cmp.set("v.OuListSourceSys",sourceSyslist);
    }
})