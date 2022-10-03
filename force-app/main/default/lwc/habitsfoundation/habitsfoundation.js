import { LightningElement } from 'lwc';

export default class ButtonBasic extends LightningElement {
    clickedButtonLabel;
    showbankoptions = false;
    handleClick(event) {
        this.showbankoptions = !this.showbankoptions;
    }
    showbank = false;
    handleChange(event) {
        this.showbank = !this.showbank;
    }
}