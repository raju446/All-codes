import { LightningElement } from 'lwc';

export default class CompanyB extends LightningElement {
    isSelected = false;

    handleClick() {
        this.isSelected = !this.isSelected;
    }
}