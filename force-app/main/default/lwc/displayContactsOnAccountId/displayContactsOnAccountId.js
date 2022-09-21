import { LightningElement, track, wire } from 'lwc';
import retrieveAccountRecords from '@salesforce/apex/displacontactreletedrecord.retrieveAccountRecords';

export default class displacontactreletedrecord extends LightningElement {
    @wire (retrieveAccountRecords) accData;
    @track getAccId;
     
    handleChangeRadio(event){        
        this.getAccId = event.target.value;
        window.console.log('getAccId ' + this.getAccId);
       const myCustomEventItem = new CustomEvent('myeventdemo',{
            detail: this.getAccId
       });
       this.dispatchEvent(myCustomEventItem);
        
    }
}