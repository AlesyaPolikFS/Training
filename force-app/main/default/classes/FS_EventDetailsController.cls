public without sharing class FS_EventDetailsController {
    @AuraEnabled(cacheable=true)
    public static List<OrderApi__Sales_Order_Line__c> getEvents(String receiptNumber){
        //Id currentSOId ='';
        List<OrderApi__Sales_Order_Line__c> sol = [
            SELECT Id, Name, 
                OrderApi__Item__r.EventApi__Event__r.EventApi__Description__c, 
                OrderApi__Item__r.EventApi__Event__r.EventApi__Display_Name__c, 
                OrderApi__Line_Description__c, 
                OrderApi__Item__r.EventApi__Event__r.EventApi__Start_Date_Time__c,  
                OrderApi__Item__r.EventApi__Event__r.EventApi__End_Date_Time__c 
            FROM OrderApi__Sales_Order_Line__c 
            WHERE OrderApi__Sales_Order__c IN (SELECT OrderApi__Sales_Order__c FROM OrderApi__Receipt__c WHERE Name =: receiptNumber) AND OrderApi__Item__r.OrderApi__Is_Event__c = true];
            OrderApi__Receipt__c rec = [SELECT OrderApi__Sales_Order__c FROM OrderApi__Receipt__c WHERE Name =: receiptNumber];
        return sol;
    }

    @AuraEnabled(cacheable=true)
    public static string getBaseUrl(){
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'FS_PaymentConfirmationUrl' LIMIT 1];
        return sr.Body.toString();
    }
}