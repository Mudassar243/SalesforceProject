public without sharing class FollowUpController {

    @AuraEnabled(cacheable=true)
    public static List<Contact> getPendingFollowUps(){
        return [
            SELECT Id, Name, Follow_Up_Due_Date__c
            FROM Contact
            WHERE Follow_Up_Status__c = 'Pending'
        ];
    }

    @AuraEnabled
    public static void markCompleted(Id contactId, String notes){
        Contact con = [SELECT Id, Follow_Up_Status__c, Follow_Up_Notes__c FROM Contact WHERE Id = :contactId LIMIT 1];

        con.Follow_Up_Status__c = 'Completed';
        con.Follow_Up_Notes__c = notes;
        update con;

        FollowUpLogger.Request req = new FollowUpLogger.Request();
        req.contactId = contactId;
        req.actionTaken = 'Completed';
        req.notes = notes;

        FollowUpLogger.logFollowUps(new List<FollowUpLogger.Request>{req});
    }
}