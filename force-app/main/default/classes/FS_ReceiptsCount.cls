global with sharing class FS_ReceiptsCount extends Framework.Domain{    

    global FS_ReceiptsCount(List<OrderApi__Receipt__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_ReceiptsCount(sObjectList);
        }
    }

    public override void afterInsert() {
        Framework.Log.push(FS_ReceiptsCount.class.getName(),'After Insert');
        updateReceiptsCount(records); 
        Framework.Log.pop();
    }

    public override void afterDelete() {
        Framework.Log.push(FS_ReceiptsCount.class.getName(),'After delete');
        updateReceiptsCount(records);  
        Framework.Log.pop();
    }

    private static void updateReceiptsCount(List<OrderApi__Receipt__c> newReceiptRecords) {
        Map<Id, Map<String, Integer>> orderMap = new Map<Id, Map<String, Integer>>();
        
        List<Id> orderIds = new List<Id>();
        for(OrderApi__Receipt__c receipt : newReceiptRecords) {
            orderIds.add(receipt.OrderApi__Sales_Order__c);
        }
        List<OrderApi__Receipt__c> allReceipts = [
            SELECT Id, OrderApi__Sales_Order__c, OrderApi__Type__c 
            FROM OrderApi__Receipt__c 
            WHERE OrderApi__Sales_Order__c IN: orderIds 
                AND OrderApi__Type__c IN: new List<String> {'Payment','Refund'} 
        ];

        for(OrderApi__Receipt__c receipt : allReceipts) {
            Id orderId = receipt.OrderApi__Sales_Order__c;
            if (!orderMap.containsKey(orderId)) {
                Map<String, Integer> countMap = new Map<String, Integer>();
                countMap.put('Payment', 0);
                countMap.put('Refund', 0);
                orderMap.put(orderId, countMap);
            }
            if (receipt.OrderApi__Type__c == 'Payment') {
                Integer paymentCount = orderMap.get(orderId).get('Payment');
                orderMap.get(orderId).put('Payment', paymentCount + 1);
            }
            if (receipt.OrderApi__Type__c == 'Refund') {
                Integer refundCount = orderMap.get(orderId).get('Refund');
                orderMap.get(orderId).put('Refund', refundCount + 1);
            }
        }

        List<OrderApi__Sales_Order__c> relatedSalesOrders = [
            SELECT Id,FS_Payment_Receipt_Count__c,FS_Refund_Receipt_Count__c 
            FROM OrderApi__Sales_Order__c 
            WHERE Id =:orderMap.keySet()
            ];

        List<OrderApi__Sales_Order__c> ordersToUpdate = new List<OrderApi__Sales_Order__c>();   

        for (OrderApi__Sales_Order__c sOrder : relatedSalesOrders) {
            sOrder.FS_Payment_Receipt_Count__c = orderMap.get(sOrder.Id).get('Payment');
            sOrder.FS_Refund_Receipt_Count__c  = orderMap.get(sOrder.Id).get('Refund');
            ordersToUpdate.add(sOrder);
        }

        if (ordersToUpdate != null && !ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }
    }        
}