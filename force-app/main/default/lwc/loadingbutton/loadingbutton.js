import { LightningElement } from 'lwc';

export default class Loadingbutton extends LightningElement {
    progress = 0;
    isProgressing = false;
    showloadingtions = false;
    actionToggleBar = false;

    handleClick(event) {
        this.showloadingtions = !this.showloadingtions;
    }
    get computedLabel() {
        return this.isProgressing ? 'Click' : 'Open';
    }
    actionToggleBar() {
        this.isProgressing = true;            
            this._interval = setInterval(() => {
                this.progress = this.progress === 100 ? 0 : this.progress +1;
            },200);
        this.progress = stop;
    }
    actionToggleBar(){
        this.actionToggleBar = !this.actionToggleBar;
    }
}