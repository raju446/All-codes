/**
 * @File Name          : customLookupPublicController.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 4/29/2020, 1:28:46 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/22/2020   Jayanta Karmakar     Initial Version
**/
({
   onfocus : function(component,event,helper){
       $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
         var getInputkeyWord = '';
         helper.searchHelper(component,event,getInputkeyWord);
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
       // get the search Input keyword   
         var getInputkeyWord = component.get("v.SearchKeyWord");
       // check if getInputKeyWord size id more then 0 then open the lookup result List and 
       // call the helper 
       // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
             var forOpen = component.find("searchRes");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
             component.set("v.listOfSearchRecords", null ); 
             var forclose = component.find("searchRes");
               $A.util.addClass(forclose, 'slds-is-close');
               $A.util.removeClass(forclose, 'slds-is-open');
          }
	},
    
     handleShowError: function (cmp, event, helper) {
          var isShowError = cmp.get("v.showError");
          if(isShowError){
               var lookupF = cmp.find("lookupField");
               $A.util.addClass(lookupF, 'slds-has-error');
          } else {
               $A.util.removeClass(lookupF, 'slds-has-error');  
          }  
     },
     
    sendComp : function(component,event,helper){
         var forclose = component.find("lookupField");
         return forclose;
    },
    
    sendPillComp : function(component,event,helper){
         var forclose = component.find("lookup-pill-selected");
         return forclose;
    },
    
  // function for clear the Record Selaction 
    clear :function(component,event,heplper){
         var pillTarget = component.find("lookup-pill");
         var lookUpTarget = component.find("lookupField"); 
         var removeError = component.find("lookup-pill-selected");
        
         $A.util.addClass(pillTarget, 'slds-hide');
         $A.util.removeClass(pillTarget, 'slds-show');
        
         $A.util.removeClass(removeError, 'slds-has-error');
        
         $A.util.addClass(lookUpTarget, 'slds-show');
         $A.util.removeClass(lookUpTarget, 'slds-hide');
         console.log('test');
         component.set("v.SearchKeyWord",null);
         component.set("v.listOfSearchRecords", null );
         component.set("v.selectedRecord", {} );   
    },
    
  // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
    // get the selected Account record from the COMPONETN event 	 
       var selectedAccountGetFromEvent = event.getParam("recordByEvent");
       console.log(selectedAccountGetFromEvent);
	   component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
       
        var forclose = component.find("lookup-pill");
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
  
        var forclose = component.find("searchRes");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');  
      
     },
     handleValueChange: function (cmp, event, helper) {
          var v = cmp.get('v.selectedRecord');
          console.log(JSON.stringify(v));
          var w = cmp.get('v.SearchField');
          console.log(w);
          console.log(v[w]);
          cmp.set('v.pillLabel', v[w]);
          if(v[w]){
               var forclose = cmp.find("lookup-pill");
               $A.util.addClass(forclose, 'slds-show');
               $A.util.removeClass(forclose, 'slds-hide');
               var lookUpTarget = cmp.find("lookupField");
               $A.util.addClass(lookUpTarget, 'slds-hide');
               $A.util.removeClass(lookUpTarget, 'slds-show'); 
          }
          
     }
})