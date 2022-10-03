/**
 * @File Name          : LEX_CreateEntityController.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 09-16-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/3/2020   Jayanta Karmakar     Initial Version
**/
({
	doInit : function(component, event, helper) {
		var action = component.get("c.fetchEntityRecordTypeValues");
        action.setCallback(this,function(response){
            var state=response.getState();            // getting the state
            if(state==='SUCCESS'){
                component.set('v.recTypeMap',response.getReturnValue());    // setting the value in attribute    
            }
        });
        
        var action0 = component.get("c.fetchAccountPicklistVal");
        action0.setParams({
            fieldAPIname : 'Oracle_Site_Id__c',
            nullRequired : false
        });
        action0.setCallback(this, $A.getCallback(function(response) {
            //var response = response.getReturnValue();
            console.log(response);
            var sourceSystemVal = response.getReturnValue();    
            console.log(sourceSystemVal); 
                for (let i = sourceSystemVal.length - 1; i >= 0; --i) {
                    if(sourceSystemVal[i].picklistLabel == 'ADGM Courts OU' ){
                      //  sourceSystemVal.splice(i,1);
                    }
               }
                //console.log(v);
               
            component.set('v.OuList', sourceSystemVal);
            component.set('v.OUListPerson', sourceSystemVal);
            
        }));
        $A.enqueueAction(action0);

        var action1 = component.get("c.fetchAddressPicklistVal");
        action1.setParams({
            "fieldAPIname" : "Country_ALPHA_3__c",
            "nullRequired" : false
        });
        action1.setCallback(this,function(response){
            var state=response.getState();            // getting the state
            if(state==='SUCCESS'){
                var v = response.getReturnValue();
                console.log(v);
                component.set("v.countryoptions",response.getReturnValue());
            }
        });

        var action2 = component.get("c.fetchAccountPicklistVal");
        action2.setParams({
            "fieldAPIname" : "Source_System_Name__c",
            "nullRequired" : false
        });
        action2.setCallback(this,function(response){
            var state=response.getState();            // getting the state
            if(state==='SUCCESS'){
                var v = response.getReturnValue();
                console.log(v);
                for(let i=0;i<v.length;i++){
                    if(v[i].picklistVal == 'Courts' ){
                        v.splice(i,1);
                    } 
                    
                }
                component.set("v.sourceSystem",v);
                component.set("v.sourceSystemPerson",v);
            }
        });
        
        var action3 = component.get("c.fetchAccountPicklistVal");
        action3.setParams({
            "fieldAPIname" : "Registered_for_Tax__c",
            "nullRequired" : false
        });
        action3.setCallback(this,function(response){
            var state=response.getState();            // getting the state
            if(state==='SUCCESS'){
                var v = response.getReturnValue();
                console.log(v);
                component.set("v.isRegisteredWithTaxVal",v);
            }
        });

        $A.enqueueAction(action);
        $A.enqueueAction(action1);
        $A.enqueueAction(action2);
        $A.enqueueAction(action3);
        
    },
    openModel: function(component, event, helper) {
      /*  var dta = component.get("v.newEntityObject");
        console.log(dta);
        dta.Name = "";
        dta.Account_Name_Arabic__c = "";
        dta.Source_System_Id__c = "";
        component.set("v.newEntityObject",dta);
        component.set("v.sourceSysId","");
        //component.set('v.OuList', '');
        component.set("v.newEntityObject",{'sobjectType':'Account',
                'Name': '',
                'Account_Name_Arabic__c': '',
                'Email': '',
                'Phone': '',
                'Id' : ''}); */
      // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.isOpen", true);
                
   	},
 
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.selectedEntityOU", "");
       // component.set("v.OuList",null);
        component.set("v.isOpen", false);
    },
    
    onRegisteredFoTaxChange: function (component, event, helper) {
        var dta = component.get("v.newEntityObject");
        if(dta.Registered_for_Tax__c != 'Yes'){
            dta.Tax_Registration_Number__c = null;
            component.set("v.newEntityObject",dta);
            var spinner = component.find("trnNo");
            $A.util.removeClass(spinner, "slds-has-error");
        }
    },
    
    createEntityRecord: function(component, event, helper) {
        var selectedCountry = "";
        //console.log(v.get("v.value"));
        var contactRecId = null;
        var personAcc= component.get("v.isPersonAcc");
        var isError = false;

        if(personAcc){
            var authNamePer = component.find("OUNamePer");
            if(authNamePer.get("v.value") == "" || authNamePer.get("v.value") == null ||!authNamePer.get("v.validity").valid) {
                authNamePer.showHelpMessageIfInvalid();
                isError = true;
                
            }
            var authNamePer = component.find("sourceSystemNamePer");
            if(authNamePer.get("v.value") == "" || authNamePer.get("v.value") == null ||!authNamePer.get("v.validity").valid) {
                authNamePer.showHelpMessageIfInvalid();
                isError = true;
            }
            var conStreetDom = component.find("conStreet");
            var addObj = component.get("v.newAddressObject");
            addObj.Street_Name_of_Cluster_on_the_Island__c = conStreetDom.get("v.value");            
            component.set("v.newAddressObject",addObj);
            var countryDom = component.find("concountry");
            if(countryDom){
                selectedCountry = countryDom.get("v.value");
            }   
        }
        
        if( !personAcc) {
            var field1 = component.find("Entity_Name");
            //var recType = component.find("Entity_RecordType");
            var arabicName = component.find("Entity_Arabic_Name");
            //var sourceSystem = component.find("Source_System_Id");
            var cntry = component.find("address_country");
            var streetname = component.find("address_Street");
            var siteIDVal = component.find("oracleSiteId");
            var sourceSystemVal = component.find("sourceSystemName");
            var entityRec = component.get('v.newEntityObject');
            /*if(recType.get("v.value").trim() == "" || !recType.get("v.validity").valid) {
                recType.showHelpMessageIfInvalid();
                isError = true;
            }*/
            if(entityRec.Registered_for_Tax__c == 'Yes' && ! entityRec.Tax_Registration_Number__c){
                var trn = component.find("trnNo");
                trn.showHelpMessageIfInvalid();
                isError = true;
            }
            
            if(field1.get("v.value").trim() == "" || !field1.get("v.validity").valid) {
                field1.showHelpMessageIfInvalid();
                isError = true;
            }
           
            if(cntry.get("v.value") == ""|| cntry.get("v.value") == null || !cntry.get("v.validity").valid) {
                cntry.showHelpMessageIfInvalid();
                isError = true;
            }
            if(streetname.get("v.value") == "" || streetname.get("v.value") == null ||!streetname.get("v.validity").valid) {
                streetname.showHelpMessageIfInvalid();
                isError = true;
            }
            if(siteIDVal.get("v.value") == "" || siteIDVal.get("v.value") == null ||!siteIDVal.get("v.validity").valid) {
                siteIDVal.showHelpMessageIfInvalid();
                isError = true;
            }
            if(sourceSystemVal.get("v.value") == "" || sourceSystemVal.get("v.value") == null ||!sourceSystemVal.get("v.validity").valid) {
                sourceSystemVal.showHelpMessageIfInvalid();
                isError = true;
            }
            
          
        } else {
            var params = event.getParams();
            contactRecId = params.response.id;              
        }
        
      	//debugger;
        if(!isError) {
            component.set("v.Spinner", true); 
			var newAcc = component.get("v.newEntityObject");
            var newAccRecordType = component.get("v.selectedValue");
            var action = component.get("c.saveAccount");
            action.setParams({ 
                "acc": newAcc,
                "sRecordTypeId" : newAccRecordType,
                "isPersonAcc" : component.get("v.isPersonAcc"),
                "Concountry" : selectedCountry,
                "contactId" : contactRecId,
                "sourceSystemIDVal" : component.get("v.sourceSysId"),
                "objAddress" : component.get("v.newAddressObject"),
                "OUName" : component.get("v.OUName"),
                "sourceSystemName" : component.get("v.sourceSysName")
            });
            
            
            action.setCallback(this, function(a) {
                //debugger;
                   var state = a.getState();
                    if (state === "SUCCESS") {
                        var name = a.getReturnValue();
                        
                        console.log(name);
                        //debugger;
                        if(name.msg == "Success"){
                           var name = JSON.stringify(name.accountRec);

                            var action1 = component.get("c.pushAccountToOracle");
                            action1.setParams({ 
                                "accId": name
                            });

                            action1.setCallback(this, function(ac) {
                                var state = ac.getState();
                                console.log(state);
                                if(state === "SUCCESS"){
                                    console.log(name);
                                    console.log(ac.getReturnValue());
                                    
                                    var vname = JSON.parse(name);
                                    vname.Oracle_Party_Id__c = ac.getReturnValue();
                                    console.log(vname);
                                    vname = JSON.stringify(vname);
                                    var evt = $A.get("e.c:LEX_CreateEntityEvent");
                                    evt.setParams({ 
                                        "returnedAccounts": vname
                                    });
                                    evt.fire();
                                    component.set("v.Spinner", false);
                                    component.set("v.newAddressObject", { 'sobjectType': 'Address__c' });
                                    component.set("v.newEntityObject", { 'sobjectType': 'Account', 'Is_Manually_Created__c' : true });
                                    component.set("v.selectedEntityOU", "");
                                    //component.set("v.OuList",null);
                                }
                            });
                            $A.enqueueAction(action1);
							component.set("v.isOpen", false);
                            
                            //debugger;
                        } else {
                           // debugger;
                            component.set("v.Spinner", false);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "mode" : "sticky",
                                "title": "Error!",
                                "type" : "error",
                                "message": name.msg
                            });
                            toastEvent.fire();
                        }
                    }
                	component.set("v.Spinner", false);
                });
            $A.enqueueAction(action);
           
            
        } else {
            //console.log(field1.showHelpMessageIfInvalid());
            //field1.showHelpMessageIfInvalid();
            return;
        }
    },
     handleSubmit: function(cmp, event, helper) {
        //alert('hiiii');
        cmp.set('v.Spinner', true);
    },
    handleComponentEvent : function(cmp, event, helper) { 
        //alert('Chlid called');
        
        var personAccCheck = event.getParam("isPersonAccount"); 
        cmp.set("v.isPersonAcc", personAccCheck);
        var sourceSystemVal = cmp.get("v.OUListPerson") ;
        var entityId = event.getParam("selectedEntityId");
        //alert(entityId);
        /*
        for (let i = sourceSystemVal.length - 1; i >= 0; --i) {
            
            if(sourceSystemVal[i].picklistLabel != 'ADGM Academy OU' && personAccCheck) {
                console.log(sourceSystemVal);
                sourceSystemVal.splice(i,1);
                console.log(sourceSystemVal);
            }
        }
        */
        cmp.set("v.OUListPerson",sourceSystemVal);
        var oldOU = event.getParam("selectedEntityOU");
        var OUListVal = cmp.get("v.OuList") ;
        if(oldOU != undefined && oldOU != '' && oldOU != null) {
            for (let i = OUListVal.length - 1; i >= 0; --i) {
                if(OUListVal[i].picklistLabel == oldOU ){
                   // OUListVal.splice(i,1);
                }
            }    
            cmp.set("v.OuList", OUListVal);
        } 
        
        cmp.set("v.selectedValue", "");
        cmp.set("v.OUName", "");
        cmp.set("v.newEntityObject.Oracle_Site_Id__c", "");
        cmp.set("v.newEntityObject.Name", "");
        cmp.set("v.newEntityObject.Account_Name_Arabic__c", "");
        cmp.set("v.newEntityObject.Email", "");
        cmp.set("v.newEntityObject.Phone", "");
        cmp.set("v.OuListSourceSys", "");
        
        cmp.set("v.newEntityObject.Source_System__c", "");
        cmp.set("v.newEntityObject.Tax_Registration_Number__c", "");
        //alert('Hii');
        
        if(entityId != undefined) {
            
            helper.fetchCloneEntityDetails(cmp, event, helper, entityId);
        }
        helper.fetchBMMetaData(cmp, event, helper);
        var message = event.getParam("showMod"); 
        cmp.set("v.isOpen", message);
        //cmp.set("v.Spinner", true);
     },
    
    onOUChange : function(cmp, event, helper) {
        var sourceSyslist = [];
        cmp.set("v.OuListSourceSys",sourceSyslist);
        
         var selectedOU;
        //var isPersonAccVal = cmp.get("v.isPersonAcc");
        if(cmp.get("v.isPersonAcc")) {
            selectedOU =  cmp.get("v.OUName");
        } else {
            selectedOU =  cmp.get("v.newEntityObject.Oracle_Site_Id__c");
        }
        var sourceSys ;
        
        if(selectedOU != '101'){
            sourceSys = {  picklistLabel : "BM",  picklistVal  : "BM"};
            sourceSyslist.push(sourceSys);
            cmp.set('v.newEntityObject.Source_System__c', 'BM');
            if("v.isPersonAcc"){
                cmp.set('v.sourceSysName', 'BM');
            }
        }
        
        if(selectedOU == '101') {
            sourceSys = {  picklistLabel : "BM - ADGM",  picklistVal  : "BM - ADGM"};
            sourceSyslist.push(sourceSys);
            sourceSys = {  picklistLabel : "BM - Arbitration",  picklistVal  : "BM - Arbitration"};
            sourceSyslist.push(sourceSys);
        }
        
        cmp.set("v.OuListSourceSys",sourceSyslist);
    }
})