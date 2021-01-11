import { LightningElement, wire, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import SUCCESS_LOGO from '@salesforce/resourceUrl/success_payment';
import getEvents from '@salesforce/apex/FS_AddToCalendarController.getEvents';


    const columns = [
        { label: 'Event Name', fieldName: 'name' },
        { label: 'Event Start Date/Time', fieldName: 'startDate', type: 'date' },
        { label: 'Event End Date/Time', fieldName: 'endDate', type: 'date' },
        { type: "button", typeAttributes: {  
            label: 'add To Calendar',  
            name: 'addToCalendar',  
            title: 'addToCalendar',  
            disabled: false,  
            value: 'addToCalendar',  
            iconPosition: 'left'  
        }}
      
    ];

export default class FS_OrderConfirmation extends NavigationMixin(LightningElement) {

    successLogo = SUCCESS_LOGO;
    data = [];
    columns = columns;
    soId = 'a1J4R00000KbSomUAF';


    @wire(getEvents, { salesOrderId: '$soId'})
    dataFromApex({ error , data}) {
        if (data) {
        console.log(JSON.parse(JSON.stringify(data)));

            this.data = data.map( item => {
                return {
                    id : item.id,
                    name : item.OrderApi__Item__r.EventApi__Event__r.EventApi__Display_Name__c,
                    startDate : item.OrderApi__Item__r.EventApi__Event__r.EventApi__Start_Date_Time__c,
                    endDate : item.OrderApi__Item__r.EventApi__Event__r.EventApi__End_Date_Time__c,
                    description : item.OrderApi__Item__r.EventApi__Event__r.EventApi__Description__c,
                    subject : item.OrderApi__Item__r.EventApi__Event__r.EventApi__Display_Name__c
                }
            })
        } else if (error) {
            console.log("error", error);
        }
     }     
    callRowAction (event) {
        let data = event.detail.row;
        console.log('data', data);
        
        if (event.detail.action.name === 'addToCalendar' ) {            
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__webPage',
                attributes: {
                    url: "Event_Generation_Page"
                },
                state : {
                    id: data.id,
                    start: data.startDate,
                    end: data.endDate,
                    subject: data.subject,
                    description: data.description
                }
            }).then(url => {
                let first = window.location.href.slice(0, window.location.href.indexOf('.lightning'));
                let second = url.replace('/lightning/webpage','--c.visualforce.com/apex');
                window.open(first + second);
            });
        }
    }
}