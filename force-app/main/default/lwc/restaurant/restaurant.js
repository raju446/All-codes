import { api, LightningElement, track } from 'lwc';

import submitScoreAction from '@salesforce/apex/restaurant.submitScoreAction';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';


export default class restaurant extends NavigationMixin (LightningElement) {

    @track scoreObName;
    @track scoreObjBOOKING_NAMES;
    @track scoreObjSETTING_TYPE;
    @track scoreObjMENU_ITEMS;
   @track scoreObjBILL;
    @track scoreRecoreId;
    @track errorMsg;

   scoreHandleChange(event){
        if(event.target.name == 'scoreName'){
        this.scoreObName = event.target.value;  
        //window.console.log('scoreObName ##' + this.scoreObName);
        }
      if(event.target.name == 'scoreBOOKING_NAMES'){
        this.scoreObjfees = event.target.value;  
      }

      if(event.target.type == 'scoreSETTING_TYPE'){
        this.scoreObjgender = event.target.value;    
      }
      if(event.target.Numbere == 'scoreBILL'){
        this.scoreObjAnnual = event.target.value;
      }

 }

 submitAction(){
   alert("1");
    submitScoreAction({name:this.scoreObName,BOOKING_NAMES:this.scoreObjBOOKING_NAMES ,SETTING_TYPE:this.scoreObjSETTING_TYPE,BILL:this.scoreObjBILL})
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
                objectApiName: 'restaurant__c',
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