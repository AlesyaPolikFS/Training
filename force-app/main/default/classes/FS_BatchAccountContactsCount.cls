public with sharing class FS_BatchAccountContactsCount implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(
            [
                SELECT Id, Name, FS_Contact_Count__c, 
                    (   
                        SELECT Id, Name, FS_Exempt_from_Count__c 
                        FROM Contacts 
                        WHERE FS_Exempt_from_Count__c = false
                    ) 
                FROM Account
            ]
        );
    }

    public void execute(Database.BatchableContext context, List<Account> accountScope) {
        if (accountScope != null) {
            for(Account acc : accountScope) {
                acc.FS_Contact_Count__c = acc.Contacts.size();
            }

            update accountScope;
        }  
    }

    public void finish(Database.BatchableContext context) {}
}