trigger TaskOnboardingTrigger on Task (after insert, after update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            TaskOnboardingHandler.handleAfter(Trigger.new, Trigger.oldMap);
        }
    }
}