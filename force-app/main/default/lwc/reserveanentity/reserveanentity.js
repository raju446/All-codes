import { LightningElement } from 'lwc';

export default class Reserveanentity extends LightningElement {
    value = '';

    get options() {
        return [
            { label: 'Reserve a Company Name', value: 'option1' },
        ];
    }
}