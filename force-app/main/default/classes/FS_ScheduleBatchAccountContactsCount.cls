public with sharing class FS_ScheduleBatchAccountContactsCount implements Schedulable {
    public void execute(SchedulableContext context) {
        FS_BatchAccountContactsCount updateAccountContactCount = new FS_BatchAccountContactsCount(); 
        Database.executeBatch(updateAccountContactCount, 200);
    }
}
