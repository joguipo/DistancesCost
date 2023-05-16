import { LightningElement, api } from 'lwc';

const columns = [
    { label: 'Origin',          fieldName: 'origin',        type: 'String' },
    { label: 'Destination',     fieldName: 'destination',   type: 'String' },
    { label: 'Total Miles',     fieldName: 'miles',         type: 'String' },
    { label: 'Travel Time',     fieldName: 'travelTime',    type: 'String' },
    { label: 'Miles Cost',      fieldName: 'milesCost',     type: 'currency'},

];

export default class MapsAndCostShowResults extends LightningElement {

    @api distancesCostsResults;
    rows = [];
    columns = columns;
    
    connectedCallback() {
        this.formatDistancesCostsTable();
    } 

    formatDistancesCostsTable(results){
        let data = JSON.parse(JSON.stringify(this.distancesCostsResults));
        let index = 0
        let dataLength = data.length;
        let tempData = {};

        for (; index < dataLength; index++) { 
            tempData = {};
            tempData.id          = index + 1;
            tempData.origin      = decodeURI(data[index].origins);
            tempData.destination = decodeURI(data[index].destinations);
            tempData.miles       = data[index].miles;
            tempData.travelTime  = data[index].travelTime;
            tempData.milesCost   = data[index].milesCost;

            this.rows.push(tempData);
        }
    }
    
}