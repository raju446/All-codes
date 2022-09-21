import { api, LightningElement, track } from 'lwc';

import submitScoreAction from '@salesforce/apex/createstudent.submitScoreAction';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';


export default class createstudent extends NavigationMixin (LightningElement) {

    @track scoreObName;
    @track scoreObjfees;
    @track scoreObjgender;
    @track scoreObjresult;
    @track scoreObjAnnual;
   @track scoreObjDesignations;
    @track scoreRecoreId;
    @track errorMsg;

   scoreHandleChange(event){
        if(event.target.name == 'scoreName'){
        this.scoreObName = event.target.value;  
        //window.console.log('scoreObName ##' + this.scoreObName);
        }
      if(event.target.name == 'scoreEmail'){
        this.scoreObjfees = event.target.value;  
      }

      if(event.target.name == 'scorePhone'){
        this.scoreObjgender = event.target.value;  
      }
      if(event.target.name == 'scoreCity'){
        this.scoreObjresult = event.target.value;  
      }
      if(event.target.name == 'scoreAnnual'){
        this.scoreObjAnnual = event.target.value;  
      }
      if(event.target.name == 'scoreObjDesignations'){
        this.scoreObjDesignations = event.target.value;  
      }


 }

 submitAction(){
   alert("1");
    submitScoreAction({name:this.scoreObName,fees:this.scoreObjfees,gender:this.scoreObjgender,results:this.scoreObjresult})
    .then(result=>{
        this.scoreRecoreId = result.Id;
        window.console.log('scoreRecoreId##Vijay2 ' + this.scoreRecoreId);       
        const toastEvent = new ShowToastEvent({
            title:'Success!',
            message:'Record created successfully',
            variant:'success'
          });
          this.dispatchEvent(toastEvent);

          /*Start Navigation*/
          this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.scoreRecoreId,
                objectApiName: 'hotel__c',
                actionName: 'view'
            },
         });
         /*End Navigation*/

    })
    .catch(error =>{
       this.errorMsg=error.message;
       window.console.log(this.error);
    });

 }
}