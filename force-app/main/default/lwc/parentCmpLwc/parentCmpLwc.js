import { LightningElement, track, wire } from 'lwc';
import retrieveContactRecords from '@salesforce/apex/displacontactreletedrecord.retrieveContactRecords';

export default class TeacherCmpLwc extends LightningElement {
      
    @track teacher2__c;
    @track records;
    @track errorMsg;    

    @wire (retrieveContactRecords, {accId:'$teacher2__c'})
      wireConRecord({error,data}){
        if(data){
          this.records = data;     
          this.errorMsg = undefined;    
        }else{         
          this.errorMsg = error;
          this.records = undefined;
        }
      }

    handleChangeAction(event){
      this.teacher2__c = event.detail;
      window.console.log('teacher2__c ' + this.teacher2__c);
    }


}