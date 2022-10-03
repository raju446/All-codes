import { LightningElement, track } from 'lwc';

export default class Servieshelp extends LightningElement {
    @track value='';

    Value = 'Some text value';

    handleKeyUp(event) {
       let val = event.target.value;
       this.Value = val;
       console.log(val);
    }

    get showPublicRegister(){
        let cardName = 'Public register';
        return cardName.includes(this.Value)&& this.Value;
    }
}