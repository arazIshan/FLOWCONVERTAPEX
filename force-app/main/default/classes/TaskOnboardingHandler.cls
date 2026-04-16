public with sharing class TaskOnboardingHandler {
    // Transaction-level set to avoid duplicate processing within same execution
    private static Set<Id> processedTaskIds = new Set<Id>();

    public static void handleAfter(List<Task> newTasks, Map<Id, Task> oldMap) {
        if (newTasks == null || newTasks.isEmpty()) return;

        Set<Id> candidateTaskIds = new Set<Id>();
        for (Task t : newTasks) {
            if (t == null) continue;
            // Normalize status and subject checks
            String status = t.Status == null ? '' : t.Status.toLowerCase();
            String subject = t.Subject == null ? '' : t.Subject.toLowerCase();
            Boolean isCompleted = status == 'completed';
            Boolean subjectMatches = subject.contains('onboarding');

            if (!isCompleted || !subjectMatches) continue;

            // If update, ensure it wasn't already meeting condition before (avoid re-processing)
            if (oldMap != null && oldMap.containsKey(t.Id)) {
                Task oldT = oldMap.get(t.Id);
                String oldStatus = oldT.Status == null ? '' : oldT.Status.toLowerCase();
                String oldSubject = oldT.Subject == null ? '' : oldT.Subject.toLowerCase();
                Boolean oldCompleted = oldStatus == 'completed';
                Boolean oldSubjectMatches = oldSubject.contains('onboarding');
                if (oldCompleted && oldSubjectMatches) {
                    continue; // already met criteria
                }
            }

            if (!processedTaskIds.contains(t.Id)) {
                processedTaskIds.add(t.Id);
                candidateTaskIds.add(t.Id);
            }
        }

        if (candidateTaskIds.isEmpty()) return;

        // Query tasks to get WhoId/WhatId and ensure bulk-safe collection of Contacts to update
        List<Task> tasks = [SELECT Id, WhoId, WhatId, Subject, Status FROM Task WHERE Id IN :candidateTaskIds];

        Set<Id> contactIdsToUpdate = new Set<Id>();
        for (Task t : tasks) {
            // Prefer WhoId for Contact relation; fallback defensive check on WhatId
            if (t.WhoId != null && String.valueOf(t.WhoId).startsWith('003')) {
                contactIdsToUpdate.add(t.WhoId);
            } else if (t.WhatId != null && String.valueOf(t.WhatId).startsWith('003')) {
                contactIdsToUpdate.add(t.WhatId);
            }
        }

        if (contactIdsToUpdate.isEmpty()) return;

        Map<Id, Contact> contactsById = new Map<Id, Contact>(
            [SELECT Id, Description FROM Contact WHERE Id IN :contactIdsToUpdate FOR UPDATE]
        );

        List<Contact> contactsToUpdate = new List<Contact>();
        String stamp = '[Onboarding task completed: ' + String.valueOf(Date.today()) + ']';

        for (Id cid : contactIdsToUpdate) {
            Contact c = contactsById.get(cid);
            if (c == null) continue;
            String existing = c.Description == null ? '' : c.Description;
            // Append stamp with a separator if description already has content
            String newDesc = existing;
            if (existing != null && existing.trim().length() > 0) {
                newDesc = existing + '\n' + stamp;
            } else {
                newDesc = stamp;
            }
            c.Description = newDesc;
            contactsToUpdate.add(c);
        }

        if (!contactsToUpdate.isEmpty()) {
            try {
                update contactsToUpdate;
            } catch (DmlException e) {
                System.debug('TaskOnboardingHandler: Failed to update contacts: ' + e.getMessage());
            }
        }
    }
}