public class UpdateContactsBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name FROM Contact');
    }

    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        for(Contact c : scope) {
            c.Title += ' - Updated';
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Batch Completed');
    }
}