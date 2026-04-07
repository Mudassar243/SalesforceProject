public class MyQueueableJob implements Queueable {

   

    public void execute(QueueableContext context) {
        
        List<Account> accList = [SELECT Id, companyStatus__c FROM Account];

        for(Account acc : accList) {
            acc.companyStatus__c = 'Updated';
        }

        update accList;
    }
}
