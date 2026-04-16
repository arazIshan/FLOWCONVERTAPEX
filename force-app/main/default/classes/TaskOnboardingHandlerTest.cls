@IsTest
private with sharing class TaskOnboardingHandlerTest {
    @IsTest static void testSingleTaskAppendsDescription() {
        Contact c = new Contact(LastName = 'TestContact');
        insert c;

        Task t = new Task(Subject = 'Onboarding - Welcome call', Status = 'Completed', WhoId = c.Id, OwnerId = UserInfo.getUserId(), ActivityDate = Date.today());
        Test.startTest();
            insert t;
        Test.stopTest();

        Contact cAfter = [SELECT Id, Description FROM Contact WHERE Id = :c.Id];
        System.assertNotEquals(null, cAfter.Description, 'Description should not be null');
        System.assert(cAfter.Description.contains('Onboarding task completed'), 'Description should contain the onboarding stamp');
    }

    @IsTest static void testBulkTasksAppendDescription() {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) contacts.add(new Contact(LastName = 'Bulk' + i));
        insert contacts;

        List<Task> tasks = new List<Task>();
        for (Contact c : contacts) {
            tasks.add(new Task(Subject = 'Onboarding step ' + c.LastName, Status = 'Completed', WhoId = c.Id, OwnerId = UserInfo.getUserId(), ActivityDate = Date.today()));
        }

        Test.startTest();
            insert tasks;
        Test.stopTest();

        List<Contact> updated = [SELECT Id, Description FROM Contact WHERE Id IN :contacts];
        for (Contact uc : updated) {
            System.assertNotEquals(null, uc.Description, 'Description should not be null for ' + uc.Id);
            System.assert(uc.Description.contains('Onboarding task completed'), 'Each contact description should contain the onboarding stamp');
        }
    }

    @IsTest static void testNoActionWhenSubjectDoesNotMatch() {
        Contact c = new Contact(LastName='NoMatch');
        insert c;
        Task t = new Task(Subject='General Follow Up', Status='Completed', WhoId = c.Id, OwnerId = UserInfo.getUserId(), ActivityDate = Date.today());

        Test.startTest();
            insert t;
        Test.stopTest();

        Contact cAfter = [SELECT Description FROM Contact WHERE Id = :c.Id];
        System.assertEquals(null, cAfter.Description, 'Description should remain null when subject does not match');
    }
}