import { LightningElement, track, api } from "lwc";

export default class AddressInput extends LightningElement {
  @api
  get address() {
    return this.address_;
  }
  set address(value) {
    this.address_ = JSON.parse(JSON.stringify(value));
    if (this.address_.BillingCountry === "USA") {
      this.address_.BillingCountry = "United States";
    }
  }
  @api
  stateOptions;
  @api
  validity;
  @api
  variant = "label-inline";

  @track address_;
  timeout = {};
  touched = new Set();

  validateAddressImp() {
    const allValid = [...this.template.querySelectorAll(".address-required")].reduce(
      (validSoFar, inputCmp) => {
        if (this.touched.has(inputCmp.name)) {
          console.log(inputCmp.name);
          //if we have entered the field. If it's empty and has not been touched, don't show the error field
          inputCmp.reportValidity();
        }
        return validSoFar && inputCmp.checkValidity();
      },
      true
    );
    this.validity = allValid;
    if (allValid) {
      this.despatchValidEvent();
      console.log("All form entries look valid. Ready to submit!");
    } else {
      this.despatchInvalidEvent();
      console.log("Please update the invalid form entries and try again.");
    }
  }

  validateAddress() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.validateAddressImp();
    }, 50);
  }

  handleStreetChange(event) {
    this.touched.add("street");
    this.address_.BillingStreet = event.detail.value;
    this.validateAddress();
  }
  handleStreet2Change(event) {
    this.touched.add("street2");
    this.address_.BillingStreet2 = event.detail.value;
    this.validateAddress();
  }
  handleCityChange(event) {
    this.touched.add("city");
    this.address_.BillingCity = event.detail.value;
    this.validateAddress();
  }
  handlePostCodeChange(event) {
    this.touched.add("zip");
    this.address_.BillingPostalCode = event.detail.value;
    this.validateAddress();
  }
  handleStateChange(event) {
    this.touched.add("state");
    this.address_.BillingState = event.detail.value;
    this.validateAddress();
  }
  handleCountryChange(event) {
    this.touched.add("country");
    this.address_.BillingCountry = event.detail.value;
    this.validateAddress();
  }

  handleInternationalChange(event) {
    this.address_.internationalAddress = event.target.checked;
    if (this.address_.internationalAddress) {
      this.address_.BillingCountry = "";
    } else {
      this.address_.BillingCountry = "United States";
    }
    this.touched.clear();
    this.validateAddress();
  }

  despatchValidEvent() {
    var address = this.address_;

    const detail = {
      type: "addressvalid",
      value: {
        BillingCountry: address.BillingCountry,
        BillingStreet: address.BillingStreet,
        BillingStreet2: address.BillingStreet2,
        BillingCity: address.BillingCity,
        BillingPostalCode: address.BillingPostalCode,
        BillingState: address.BillingState,
        InternationalAddress: address.internationalAddress
      }
    };

    console.log(detail);
    const changeEvent = new CustomEvent("addressvalid", { detail: detail });
    this.dispatchEvent(changeEvent);
  }

  despatchInvalidEvent() {
    var address = this.address_;
    const detail = {
      type: "addressinvalid",
      value: {
        BillingCountry: address.BillingCountry,
        BillingStreet: address.BillingStreet,
        BillingStreet2: address.BillingStreet2,
        BillingCity: address.BillingCity,
        BillingPostalCode: address.BillingPostalCode,
        BillingState: address.BillingState,
        InternationalAddress: address.internationalAddress
      }
    };

    const changeEvent = new CustomEvent("addressinvalid", { detail: detail });
    this.dispatchEvent(changeEvent);
  }
  get countryOptions() {
    return this.countries;
  }

  countries = [
    {
      value: "India",
      key: "IN",
      label: "India"
    }

  ];

}