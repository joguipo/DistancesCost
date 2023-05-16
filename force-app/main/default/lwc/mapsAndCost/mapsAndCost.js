import { LightningElement } from 'lwc';
import { ShowToastEvent }   from 'lightning/platformShowToastEvent';
import getAutocomplete      from '@salesforce/apex/GoogleMapsController.getAutocompleteResults';
import getDistances         from '@salesforce/apex/GoogleMapsController.getDistancesResults';


export default class MapsAndCost extends LightningElement {
    
    // Inputs variables
    searchAddress           = '';
    originResults           = [];
    destinationResults      = [];

    // Resutls
    calcAndCosts            = []

    // Component variables
    showOriginResults       = false;
    showDestinationResults  = false;
    showResults             = false;
    disabledBtn             = true;
    originAddress           = '';
    destinationAddress      = '';
    type

    // Radio buttons variables
    radioSelectedValue      = 'driving';
    radioOptions            = [
        {label: 'driving',  value: 'driving'},
        {label: 'walking',  value: 'walking'},
        {label: 'bicycling',value: 'bicycling'},
        {label: 'transit',  value: 'transit'}
    ]


    // HANDLE THE USER'S TYPING
    handleInputChange(event) {
        let type = event.currentTarget.dataset.type;
        this.searchAddress = event.target.value;
        console.log('type', type);
        if (this.searchAddress.length >= 3) {
            this.getAutocompleteData(type);
        }else{
            this.disabledBtn = true;
            this.showResults = false;
            if (type == 'origin') {
                this.showOriginResults  = false;
                // this.originResults      = [];
            }else{
                this.showDestinationResults  = false;
                // this.destinationResults      = [];
            }
        }
    }

    // CALL AUTO COMPLETE API
    getAutocompleteData(addrsType){//type){
        getAutocomplete({input : encodeURI(this.searchAddress)})
        .then(result => {
            // console.log('result --> ', result); 
            let resultJson = result;
            
            if (resultJson.hasOwnProperty('errors')) {
                console.log('has error -> ', this.resultJson)
                this.showToast('Something wrong', this.resultJson.errors[0].message, 'error', 'dismissible');
            }else{
                // console.log('result --> ', resultJson);
                if (addrsType == 'origin') {
                    this.originResults          = resultJson;
                    this.showOriginResults      = true;  
                }else{
                    this.destinationResults     = resultJson;
                    this.showDestinationResults = true;
                }
            }
        })
        .catch(error => {
            console.log('Error --> ',error);
            this.showToast('Something wrong', 'Please, try again later or contact customer support', 'error', 'dismissible'); 
        })
    }

    // FORMAT AND ASSIGN DATA DEPENDS OF THE INPUT SELECTED
    handleResultSelection(event){
        this.showResults = false;
        if (event.currentTarget.dataset.type == 'origin') {
            this.originAddress          = event.currentTarget.outerText;
            this.showOriginResults      = false;
        }else{
            this.destinationAddress     = event.currentTarget.outerText;
            this.showDestinationResults = false;
        }
        if(this.originAddress.length > 0 || this.destinationAddress.length > 0){
            this.disabledBtn = false;
        }
    }

    // CALL GOOGLE API DISTNCES
    handleGetDirections(event){
        this.calcAndCosts = [];
        let originEncode        = encodeURI(this.originAddress);
        let destinationEncode   = encodeURI(this.destinationAddress);
        getDistances({origins: originEncode, destinations: destinationEncode, mode: this.radioSelectedValue})
        .then(result => {
            // console.log('result --> ', result);
            let resultJson = JSON.parse(result);
            if (resultJson.status == "OK") {
                console.log('distances resultJson -> ', resultJson);
                this.calcAndCosts.push(resultJson);
                this.showResults = true;
            }else{
                this.showToast('Something wrong', "Invalid Request - Please check the addresess", 'error', 'dismissible');
            }
        })
        .catch(error => {
            console.log('Error --> ',error);
            this.showToast('Something wrong', 'Please, try again later or contact customer support', 'error', 'dismissible'); 
        })

    }

    // RADIO BUTTON CHANGE VALUE HANDLER
    handleRadioChange(event){
        this.showResults = false;
        this.radioSelectedValue = event.detail.value;
    }

    // SHOW ERROR MESSAGES
    showToast(toastTitle, toastMsg, toastVariant, toastMode){
        console.log('showToast')
        const evt = new ShowToastEvent({
            title: toastTitle
            ,message: toastMsg
            ,variant: toastVariant
            ,mode: toastMode
        });
        this.dispatchEvent(evt);  
    }


}