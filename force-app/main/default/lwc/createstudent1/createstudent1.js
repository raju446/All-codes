import { api, LightningElement, track } from 'lwc';

import submitScoreAction from '@salesforce/apex/createstudent.submitScoreAction';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';


export default class createstudent extends NavigationMixin (LightningElement) {

    @track scoreObName;
    @track scoreObjhotelname;
    @track scoreObjfood;
    @track scoreObjfoodcost;

   scoreHandleChange(event){
        if(event.target.name == 'scoreName'){
        this.scoreObName = event.target.value;  
        //window.console.log('scoreObjName ##' + this.scoreObName);
        }
      if(event.target.name == 'scoreObjhotelname'){
        this.scoreObjhotelname = event.target.value;  
      }

      if(event.target.name == 'scoreObjfood'){
        this.scoreObjfood = event.target.value;  
      }
      if(event.target.name == 'scoreObjfoodcost'){
        this.scoreObjfoodcost = event.target.value;  
      }


 }

 submitAction(){
    submitScoreAction({cardName:this.scoreObName,cardhotelname:this.scoreObjhotelname,cardfood:this.scoreObjfood,cardfoodcost:this.scoreObjfoodcost})
    .then(result=>{
        this.scoreRecoreId = result.Name;
        window.console.log('scoreRecoreName##Vijay2 ' + this.scoreRecoreName);       
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
                objectApiName: 'scoreCard__c',
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