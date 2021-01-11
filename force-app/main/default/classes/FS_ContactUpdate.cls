global without sharing class FS_ContactUpdate extends Framework.Domain {

    public FS_ContactUpdate(List<Contact> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_ContactUpdate(sObjectList);
        }
    }

    public override void beforeInsert() {
        Framework.Log.push(FS_ContactUpdate.class.getName(),'Before Insert');
        Framework.Log.pop();
    }
    
    public override void afterInsert() {
        Framework.Log.push(FS_ContactUpdate.class.getName(),'After Insert');

        Framework.Log.pop();
    }


    public override void beforeUpdate(Map<Id, SObject> existingRecords) {
        Framework.Log.push(FS_ContactUpdate.class.getName(),'Before update');
        Framework.Log.pop();
    }

    public override void afterUpdate(Map<Id, SObject> existingRecords) {
        Framework.Log.push(FS_ContactUpdate.class.getName(),'After update');
        List<Id> contactsId = new List<Id>();
        for (SObject record : records) {
            contactsId.add(record.Id);
        }
        updateRelatedUsers(contactsId);
        Framework.Log.pop();
    }
    
    public override void afterDelete() {
        Framework.Log.push(FS_ContactUpdate.class.getName(),'After delete');
        Framework.Log.pop();
    }
    @future
    public static void updateRelatedUsers(List<Id> contactIds) {
        List<User> relatedUsers = [
            SELECT Id, FS_Individual_Membership_Type__c, Contact.FS_Individual_Membership_Type__c 
            FROM User 
            WHERE ContactId IN: contactIds
        ];
        List<User> usersToUpdate = new List<User>();

        for (User currentUser : relatedUsers) {
            if (currentUser.FS_Individual_Membership_Type__c != currentUser.Contact.FS_Individual_Membership_Type__c) {
                currentUser.FS_Individual_Membership_Type__c = currentUser.Contact.FS_Individual_Membership_Type__c;
                usersToUpdate.add(currentUser);
            }
        }
        if (!usersToUpdate.isEmpty()) {
            update usersToUpdate;
        }
    }
}