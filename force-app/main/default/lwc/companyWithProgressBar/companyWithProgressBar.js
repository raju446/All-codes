import { LightningElement, track,api } from 'lwc';

export default class LightningExampleLayoutItemSize extends LightningElement {
    @track timeHolder = 1;
    @track greetingMessage = 'Good morning!';
    @api progressvalue;
    connectedCallback() {
        setInterval(() => {
            var currentdate = new Date();
            this.timeHolder = currentdate.getHours() + ":" + currentdate.getMinutes();
            if (currentdate.getHours() > 12 && currentdate.getHours() < 15)
                this.greetingMessage = 'Good afternoon!';
            else if (currentdate.getHours() > 15 && currentdate.getHours() < 21)
                this.greetingMessage = 'Good evening!';
            // this.counter = this.counter + 1;
        }, 500);
    }
}