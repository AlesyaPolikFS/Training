@isTest
private class FS_ReceiptsCountTest {
    @TestSetup static void testSetup() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule = new Framework.RoutingRule();
        routingRule.apexClass = FS_ReceiptsCount.class.getName();
        routingRule.namespace = '';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'OrderApi__Receipt__c';
        routingRule.executionOrder = 10;
        rules.add(routingRule);
        Framework.Config.push(rules);

        Account acc = new Account(Name = 'Test');
        insert acc;
        Contact con = new Contact(FirstName = 'testfn', LastName = 'testln', AccountId = acc.Id);
        insert con;

        OrderApi__Sales_Order__c testSalesOrder = new OrderApi__Sales_Order__c(
            OrderApi__Account__c = acc.Id,
            OrderApi__Contact__c = con.Id
        );

        insert testSalesOrder;

        OrderApi__Receipt__c testReceiptToPayment = new OrderApi__Receipt__c (
            OrderApi__Account__c = acc.Id,
            OrderApi__Contact__c = con.Id,
            OrderApi__Sales_Order__c = testSalesOrder.Id,
            OrderApi__Type__c = 'Payment'
        );

        insert testReceiptToPayment;

        OrderApi__Receipt__c testReceiptToRefund = new OrderApi__Receipt__c (
            OrderApi__Account__c = acc.Id,
            OrderApi__Contact__c = con.Id,
            OrderApi__Sales_Order__c = testSalesOrder.Id,
            OrderApi__Type__c = 'Refund'
        );

        insert testReceiptToRefund;       
    }

    @isTest 
    public static void updatePaymentReceiptCount() {

    Account account = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
    Contact contact = [SELECT Id FROM Contact WHERE LastName = 'testln' LIMIT 1];
    OrderApi__Sales_Order__c order = [SELECT Id, OrderApi__Account__c, FS_Payment_Receipt_Count__c FROM OrderApi__Sales_Order__c LIMIT 1];
    OrderApi__Receipt__c newPaymentReceipt = new OrderApi__Receipt__c(
        OrderApi__Account__c = account.Id,
        OrderApi__Contact__c = contact.Id,
        OrderApi__Sales_Order__c = order.Id,
        OrderApi__Type__c = 'Payment'
    );

    Test.starttest();
    insert newPaymentReceipt;
    Test.stopTest();

    OrderApi__Sales_Order__c saleOrder = [SELECT Id,FS_Payment_Receipt_Count__c FROM OrderApi__Sales_Order__c LIMIT 1];
    System.assertEquals(2, saleOrder.FS_Payment_Receipt_Count__c);    
    }

    @isTest 
    public static void updateRefundReceiptCount() {

    Account account = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
    Contact contact = [SELECT Id FROM Contact WHERE LastName = 'testln' LIMIT 1];
    OrderApi__Sales_Order__c order = [SELECT Id, OrderApi__Account__c, FS_Payment_Receipt_Count__c FROM OrderApi__Sales_Order__c LIMIT 1];
    OrderApi__Receipt__c newRefundReceipt = new OrderApi__Receipt__c(
        OrderApi__Account__c = account.Id,
        OrderApi__Contact__c = contact.Id,
        OrderApi__Sales_Order__c = order.Id,
        OrderApi__Type__c = 'Refund'
    );

    Test.starttest();
    insert newRefundReceipt;
    Test.stopTest();

    OrderApi__Sales_Order__c saleOrder = [SELECT Id,FS_Refund_Receipt_Count__c FROM OrderApi__Sales_Order__c LIMIT 1];
    System.assertEquals(2, saleOrder.FS_Refund_Receipt_Count__c);    
    }

    @isTest 
    public static void updatePaymentReceiptCountOnDelete() {

        OrderApi__Receipt__c receipt = [SELECT Id FROM OrderApi__Receipt__c LIMIT 1];
        Test.startTest();
        delete receipt;
        Test.stopTest();

        OrderApi__Sales_Order__c salesOrder = [SELECT Id,FS_Refund_Receipt_Count__c FROM OrderApi__Sales_Order__c LIMIT 1];
        System.assertEquals(1, salesOrder.FS_Refund_Receipt_Count__c);
    }
}