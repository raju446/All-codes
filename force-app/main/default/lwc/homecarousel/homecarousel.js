import { LightningElement } from 'lwc';

export default class LightningExampleLayoutItemSize extends LightningElement {
    renderedCallback() {
        const container = this.template.querySelector('.manualcontainer');
        const CONTAINER_HTML = `<style>.slds-carousel__content { background-color: grey !important;}</style>`;
        container.innerHTML = CONTAINER_HTML;
    }
}