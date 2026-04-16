Title: Plan — Convert "Task — Onboarding Completed" Flow to Apex

Objective
- Convert the existing record-triggered Flow (Task — Onboarding Completed) into a clean, production-ready, bulkified Apex implementation following 2026 best practices.
- Deliverables: Trigger file, Handler class, and Test class skeleton — all written and organized for immediate deployment and testing.

Scope (what the Flow currently does)
- After-save, record-triggered on Task (create and update).
- When Task.Status == "Completed" and Task.Subject contains "Onboarding":
  - If Task is related to a Contact (WhoId), write a dated stamp into Contact.Description (append if Description exists).
- The Flow runs per record; conversion must be bulk-safe for insert/update batches.

High-level conversion approach
1. Trigger (TaskOnboardingTrigger)
   - After insert, after update
   - Lightweight: delegate all logic to a handler class
   - Only responsible for passing Trigger.new and Trigger.oldMap to the handler

2. Handler class (TaskOnboardingHandler)
   - Public with sharing class with a single entrypoint: handleAfter(List<Task> newList, Map<Id, Task> oldMap)
   - Responsibilities:
     - Detect which Tasks newly meet the criteria (Status changed to Completed or newly Created Completed + Subject contains 'onboarding')
       - Compare prior values when oldMap is present to avoid reprocessing unchanged records
     - Collect Contact IDs (prefer WhoId, defensive fallback to WhatId only if necessary)
     - Query Contacts in bulk and FOR UPDATE (to avoid race conditions) — select Id, Description
     - Compute the stamp string once per transaction: "[Onboarding task completed: YYYY-MM-DD]"
     - Append stamp to Contact.Description (preserve existing content with newline)
     - Perform one bulk update of Contacts
     - Handle and log DML exceptions without re-throwing (business decision: do not roll back entire transaction)
     - Provide minimal telemetry/logging via System.debug or Platform Event (optional)
   - Bulk-safety:
     - No SOQL/DML in loops
     - Single SOQL for Tasks (if requerying) and single SOQL for Contacts
     - Single bulk DML update
   - Idempotency:
     - Skip Contacts already stamped today (optional enhancement)
     - Use transaction-level static Set<Id> to prevent double-processing in same transaction

3. Test class skeleton (TaskOnboardingHandlerTest)
   - Tests to include:
     - Single-record test: create Contact, insert Task with Subject containing "Onboarding" and Status = "Completed", assert Contact.Description contains stamp.
     - Bulk test: insert 200 Contacts + Tasks in bulk, run insert or update, assert all Contact.Description values updated (bulk coverage).
     - Negative test: Task with non-matching subject should not update Contact.
     - Update test: Task moved from non-completed -> Completed should trigger; Task already Completed/Onboarding before update should not trigger duplicate.
     - Exception handling test: (optional) simulate DML failure via a validation rule or mock and assert handler logs/behaves as expected.
   - Use Test.startTest()/Test.stopTest() and queries for assertions.
   - Keep tests deterministic: use Date.today() sensibly and assert partial substring (e.g., 'Onboarding task completed') rather than full date if needed.

Implementation details and best practices
- Use with sharing on handler to respect org sharing rules.
- Use small, well-named helper methods for clarity (e.g., collectCandidateTaskIds, collectContactIds, buildStamp, applyStamp).
- Prefer WhoId for Contact detection:
  - Use Id.getSObjectType() if available in current API; otherwise prefix '003' check is acceptable.
- Use Schema.describe for enterprise-grade detection if required.
- Use FOR UPDATE on Contact query to reduce race conditions when multiple processes update same records.
- Avoid throwing exceptions that roll back the originating transaction unless business requires strict atomicity.
- Add logging via System.debug and consider adding a Platform Event for operational visibility in production.
- Keep code commented and include method-level ApexDoc.

Files to be written
- force-app/main/default/triggers/TaskOnboardingTrigger.trigger
  - Minimal trigger delegating to handler
- force-app/main/default/classes/TaskOnboardingHandler.cls
  - Production-ready implementation as described
- force-app/main/default/classes/TaskOnboardingHandlerTest.cls
  - Test skeleton covering single, bulk, negative, and update scenarios

Deployment notes
- Deactivate the Flow in the org before enabling/deploying the Apex implementation to avoid duplicate writes.
- Run all tests and confirm code coverage. The handler and tests will be written to target 100% coverage for the new code paths.
- Optionally run a staged deploy (validation-only) before full deploy.
