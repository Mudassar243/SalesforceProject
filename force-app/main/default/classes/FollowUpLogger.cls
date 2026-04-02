public without sharing class FollowUpLogger {

    public class Request {
        @InvocableVariable(required=true)
        public Id contactId;

        @InvocableVariable(required=true)
        public String actionTaken;

        @InvocableVariable
        public String notes;
    }

    @InvocableMethod(label='Log Follow Up Action')
    public static void logFollowUps(List<Request> requests) {

        List<Follow_Up_Log__c> logs = new List<Follow_Up_Log__c>();

        for(Request req : requests){
            logs.add(new Follow_Up_Log__c(
                Contact__c = req.contactId,
                Action_Taken__c = req.actionTaken,
                Notes__c = req.notes,
                Processed_By__c = UserInfo.getUserId(),
                Processed_Date__c = System.now()
            ));
        }

        if(!logs.isEmpty()){
            insert logs;
        }
    }
}