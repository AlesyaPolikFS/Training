@isTest
public with sharing class FS_ContactUpdateTest {
    @TestSetup
    static void makeData(){
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule= new Framework.RoutingRule();
        routingRule.apexClass = FS_ContactUpdate.class.getName();
        routingRule.namespace = '';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'Contact';
        routingRule.executionOrder = 10;
        rules.add(routingRule);
        Framework.Config.push(rules);

        Account acc = new Account(
            Name = 'TestAccount'
        );
        insert acc;

        Contact con1 = new Contact(
            FirstName = 'Mister',
            LastName = 'Smith',
            FS_Individual_Membership_Type__c = 'Type1',
            AccountId = acc.Id
        );
        insert con1;
        User cu = [SELECT Id FROM User WHERE id=: UserInfo.getUserId() LIMIT 1];
        System.runAs(cu) {
            Profile p = [SELECT Id FROM Profile WHERE Name='Fonteva 	Customer Community Login User']; 
            User u1 = new User(
                Alias = 'wefwefd', 
                Email='standarduserzebra@testorg.com', 
                EmailEncodingKey='UTF-8', 
                LastName='TRE', 
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', 
                ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', 
                UserName='erfefe@testorg.com',
                FS_Individual_Membership_Type__c='Type2',
                ContactId = con1.Id
            );
            insert u1;
        }

    }

    @isTest
    public static void testUpdateContact() {
        Contact con1 = [SELECT Id, FS_Individual_Membership_Type__c FROM Contact WHERE LastName = 'Smith' LIMIT 1];
        con1.FS_Individual_Membership_Type__c = 'lalala';
        Test.startTest();
        User cu = [SELECT Id FROM User WHERE id=: UserInfo.getUserId() LIMIT 1];
        System.runAs(cu) {
            update con1;
        }
        Test.stopTest();
        System.assertEquals(con1.FS_Individual_Membership_Type__c, [SELECT FS_Individual_Membership_Type__c FROM User WHERE ContactId =: con1.Id].FS_Individual_Membership_Type__c);

    }
}