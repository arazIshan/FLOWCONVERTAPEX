### 2. Business Logic Mistakes & Improvements

Below are real business-logic issues, design problems, risks, and bad practices identified for the "Task — Onboarding Completed" Flow. For each issue: Severity, Why it is a problem, and How to fix or improve it.

Issue 1 — Text matching fragility
- Severity: Medium
- Why it is a problem:
  - The Flow relies on free-text matching (Subject contains "Onboarding"). Users may type variations, typos, different punctuation, or localized terms, causing missed detections or false negatives/positives.
- How to fix or improve:
  - Use a standardized field (Task_Type__c picklist) to mark onboarding tasks, or a checkbox indicating onboarding. If free-text must be used, normalize text (lowercase) and implement a small synonym/regex list to match common variations. Provide training and UI hints to encourage consistent Subject values.

Issue 2 — Relation field ambiguity (WhoId vs WhatId)
- Severity: Medium
- Why it is a problem:
  - The Flow checks Task.WhoId to detect a Contact. Some processes might relate a Task to a Contact via WhatId incorrectly, or relate to Leads/Accounts. Relying on the wrong field can miss related Contacts or incorrectly update non-Contact records.
- How to fix or improve:
  - Prefer WhoId for Contact detection. Add explicit checks for WhoId sObjectType (or use Id prefix mapping) and ignore WhatId unless business processes deliberately use it for Contacts. Add a Decision element that verifies WhoId is a Contact and, if not present, do not proceed.

Issue 3 — Overwriting vs appending data
- Severity: Medium
- Why it is a problem:
  - If the Flow sets Contact.Description directly to the stamp, existing valuable information may be overwritten. This risks data loss and surprises users who expect Description to hold important notes.
- How to fix or improve:
  - Append the stamp to Description instead of overwriting. Alternatively, write the stamp to a dedicated field (Onboarding_Stamp__c) or create a child audit object to store timestamped entries so original data remains intact.

Issue 4 — No guard for duplicate execution
- Severity: Medium
- Why it is a problem:
  - The Flow may run multiple times (user edits, integrations), producing duplicate stamps or repeated updates. This increases noise in Contact.Description and causes unnecessary DML.
- How to fix or improve:
  - Add logic to check whether the stamp for today's date already exists before appending. Add a checkbox or audit record to indicate a stamp was created for a given Task, or use an Idempotency key. In Apex, store processed IDs in a transaction-level cache or use Platform Cache for cross-transaction dedupe.

Issue 5 — Bulk processing and performance
- Severity: Medium
- Why it is a problem:
  - If a data load or automation updates many Tasks at once, the Flow must handle bulk context. Per-record updates in Flow can hit governor limits or run inefficiently.
- How to fix or improve:
  - Ensure the Flow is configured to run in bulk mode and uses collection updates. Prefer converting complex bulk logic to Apex (bulkified) which can control SOQL/DML aggregation and error handling.

Issue 6 — Lack of audit/history
- Severity: Low
- Why it is a problem:
  - A single checkbox or a single stamp in Description does not provide a structured, auditable history of onboarding tasks (who completed what and when). This makes reporting and troubleshooting harder.
- How to fix or improve:
  - Create a child object (Onboarding_Task_Completion__c) with ContactId, TaskId, CompletedBy, CompletedDate, and Notes. Use Flow/Apex to create a record in that object instead of or in addition to stamping Description.

Issue 7 — Permissions and field-level security
- Severity: High
- Why it is a problem:
  - The Flow updates Contact.Description (or other fields). If the running user or system context lacks update permissions or FLS, the Flow may fail or behave unexpectedly.
- How to fix or improve:
  - Run the Flow in system context where appropriate (administrator-level) or ensure running user has proper permissions. For Apex, use "with sharing" or "without sharing" deliberately and check FLS (Schema.sObjectType.Contact.fields.Description.isUpdateable()) before performing updates, or use an integration user with the required permissions.

Issue 8 — Error handling and rollback behavior
- Severity: Medium
- Why it is a problem:
  - If the update to Contact fails (validation rules, required fields, triggers), the entire transaction could be rolled back, causing unexpected behavior for the originating Task save.
- How to fix or improve:
  - Decide business transactional behavior: perform the Contact update asynchronously (Queueable/Platform Event) so the Task save is not blocked. Alternatively, catch exceptions in Apex and handle them gracefully (log, notify administrators) without rolling back the Task save.

Issue 9 — Internationalization / date formatting
- Severity: Low
- Why it is a problem:
  - The stamp includes a date. Different users/orgs may require localized date formats; the literal YYYY-MM-DD may not be preferred.
- How to fix or improve:
  - Format dates according to user locale in Apex using Date.format(), or store structured date in a child record rather than free-text stamp.

Issue 10 — Test coverage and edge cases
- Severity: Low
- Why it is a problem:
  - Tests may not cover edge cases like Tasks without WhoId, Tasks linked to Leads, Tasks updated multiple times, or mass-load scenarios. Missing edge tests can lead to regressions.
- How to fix or improve:
  - Expand test suite to include these scenarios, including bulk inserts/updates, Tasks related to Leads, Tasks with null Subjects, and verification of no duplicate stamps.

Summary recommendations
- Prefer structured data (picklists, checkboxes, child records) over free-text matching.
- Use WhoId for Contact detection; avoid updating fields that may cause data loss.
- Convert complex bulk logic to Apex for robust performance and error handling, and ensure tests cover bulk and edge cases.
- Add audit/history tracking for traceability and reporting.