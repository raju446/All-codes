import { LightningElement,track } from 'lwc';
import insertAccountMethod from '@salesforce/apex/createrecord.insertAccountMethod';
import accName from '@salesforce/schema/student2__c.Name';
import accgender from '@salesforce/schema/student2__c.gender__c';
import accfees from '@salesforce/schema/student2__c.fees__c';
import accresults from '@salesforce/schema/student2__c.results__c';
import accmarks from '@salesforce/schema/student2__c.marks__c';

import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class createrecord extends LightningElement {
    @track student2__cid;
    @track error;    
    @track getstudemt2Record={
        Name:accName,       
        gender__c:accgender,  
        fees__c:accfees, 
        results__c:accresults,         
        marks__c:accmarks
              
    };   

   
    nameInpChange(event){
       this.getstudent2Record.Name = event.target.value;
       //window.console.log(this.getstudent2Record.Name);
     }

     genderInpChange(event){
       this.getstudent2Record.gender = event.target.value;
       //window.console.log(this.getstudent2Record.gender);
    }
    
    feesInpChange(event){
        this.getstudent2Record.fees = event.target.value;
        //window.console.log(this.getstudent2Record.fees);
      }

      resultsInpChange(event){
        this.getstudent2Record.results = event.target.value;
        //window.console.log(this.getstudent2Record.results);
      }

      marksChange(event){
        this.getstudent2Record.marks = event.target.value;
        //window.console.log(this.gestudent2Record.marks);
      }
          
    
      savestudent2Action(){
        window.console.log('before save' + this.createstudent2);
        insertAccountMethod({accountObj:this.getstudent2Record})
        .then(result=>{
          window.console.log(this.createstudent2);
            this.getstudent2Record={};
            this.student2__cid=result.Id;
            window.console.log('after save' + this.student2__cid);
            
            const toastEvent = new ShowToastEvent({
              title:'Success!',
              message:'student created successfully',
              variant:'success'
            });
            this.dispatchEvent(toastEvent);
        })
        .catch(error=>{
           this.error=error.message;
           window.console.log(this.error);
        });
      }
    
    
    }