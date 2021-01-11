public with sharing class FS_AddToCalendarController {
    @AuraEnabled(cacheable=true)
    public static List<OrderApi__Sales_Order_Line__c> getEvents(Id salesOrderId){
        //Id currentSOId ='';
        List<OrderApi__Sales_Order_Line__c> sol = [
            SELECT Id, Name, 
                OrderApi__Item__r.EventApi__Event__r.EventApi__Description__c, 
                OrderApi__Item__r.EventApi__Event__r.EventApi__Display_Name__c, 
                OrderApi__Line_Description__c, 
                OrderApi__Item__r.EventApi__Event__r.EventApi__Start_Date_Time__c,  
                OrderApi__Item__r.EventApi__Event__r.EventApi__End_Date_Time__c 
            FROM OrderApi__Sales_Order_Line__c 
            WHERE OrderApi__Sales_Order__c =: salesOrderId AND OrderApi__Item__r.OrderApi__Is_Event__c = true
        ];
        System.debug(sol);
        return sol;
    }
}
    