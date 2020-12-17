@isTest
private with sharing class FS_TestBatchAccountContactsCount {
    @TestSetup
    static void testSetup() {

        List<Account> accounts = new List<Account>();

        accounts.add(new Account(Name = 'TestAcc1'));
        accounts.add(new Account(Name = 'TestAcc2'));

        insert accounts;        

        Account acc1 = [SELECT Id, Name FROM Account WHERE Name = 'TestAcc1'];
        List<Contact> contacts1 = new List<Contact>();
        

        for (Integer i = 1; i< 6 ; i++) {
            contacts1.add(new Contact(LastName = 'cont' + i, AccountId = acc1.Id, FS_Exempt_from_Count__c = false));
        }

        insert contacts1;

        Account acc2 = [SELECT Id, Name FROM Account WHERE Name = 'TestAcc2'];
        List<Contact> contacts2 = new List<Contact>();
        
        for (Integer i = 7; i < 11 ; i++) {
            contacts1.add(new Contact(LastName = 'cont' + i, AccountId = acc2.Id, FS_Exempt_from_Count__c = true));
        }

        insert contacts2;
    }

        @isTest
        public static void testAccountContactsCount() {
            Test.StartTest();
            FS_BatchAccountContactsCount count = new FS_BatchAccountContactsCount();
            ID batchId = Database.executeBatch(count);
            Test.StopTest();

            Decimal numOfContactsAcc1 = 
            [
                SELECT Id, Name, FS_Contact_Count__c, 
                    (
                        SELECT Id, Name FROM Contacts
                    ) 
                FROM Account 
                WHERE Name = 'TestAcc1'
            ].FS_Contact_Count__c;
                
                
            Decimal numOfContactsAcc2 = 
            [
                SELECT Id, Name, FS_Contact_Count__c, 
                    (
                        SELECT Id, Name FROM Contacts
                    ) 
                FROM Account
                WHERE Name = 'TestAcc2'
            ].FS_Contact_Count__c;

            System.assertEquals(5, numOfContactsAcc1);
            System.assertEquals(0, numOfContactsAcc2);
        }
    }