### 1. Flow Visualization 

A short, plain-English story of what the "Task — Onboarding Completed" Flow does, step-by-step:

1. A team member finishes an activity (a Task) for a contact — for example, they complete a call, email, or meeting and save the Task record with Status = "Completed".  
2. In the Task Subject the team member includes the word "Onboarding" (for example: "Onboarding — Welcome call").  
3. Immediately after the Task is saved, the Flow runs automatically (it is a record-triggered, after-save Flow on Task).  
4. The Flow first checks two conditions:
   - Is the Task Status equal to "Completed"?  
   - Does the Task Subject contain the word "Onboarding"?  
   If either check fails, the Flow does nothing and ends.  
5. If both checks pass, the Flow checks whether the Task is related to a Contact (the Task's WhoId is set to a Contact).  
6. If the Task is related to a Contact, the Flow writes a short dated note into that Contact's Description field. The note looks like:  
   [Onboarding task completed: YYYY-MM-DD]  
   If the Contact already has text in their Description, the Flow appends the note on a new line so existing information is preserved.  
7. The Flow finishes. The Contact's record now includes a timestamped entry in Description indicating an onboarding-related Task was completed.

Why this matters (one-sentence summary):
- This Flow provides a simple, automatic way to mark and timestamp when onboarding-related Tasks were completed for Contacts, so users can quickly see onboarding progress on the Contact record without manual copying or notes.