import { LightningElement } from 'lwc';
export default class numberconvert extends LightningElement {

    handlenumber(event){
        alert('sorry');
        this.value = event.detail.value;
        console.log('event');
}
}