import { LightningElement } from "lwc";

import { NavigationMixin } from "lightning/navigation";

export default class ExploreNavigation extends NavigationMixin(
  LightningElement
) {
    close() {
    const config = {
        type: 'standard__webPage',
        attributes: {
            url: 'https://twitter.com/adglobalmarket'
        }
	};
    this[NavigationMixin.Navigate](config);
  }
}