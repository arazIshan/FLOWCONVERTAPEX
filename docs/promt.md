You are an expert Salesforce Developer and Flow Architect.

I want you to complete this full end-to-end task:

### Task:
1. **Create a Simple but Useful Flow**
   - Suggest and design **one simple, realistic Record-Triggered Flow** (Auto-launched, After Save).
   - Choose a practical business scenario (for example: Case management, Lead, Opportunity, Account, or Task).
   - First, describe clearly in business terms what the Flow should do.

2. **Provide the Flow Metadata**
   - Give me the **complete .flow-meta.xml** code for the Flow you created.

3. **Analyze the Flow**
   After creating the Flow, analyze it and output **exactly** in this Markdown format:

   ### 1. Flow Visualization (Story)
   Explain in simple, plain English what the Flow is doing, like telling a short story that even a non-technical person can understand. Write it step-by-step.

   ### 2. Business Logic Mistakes & Improvements
   Find all real business-logic issues, design problems, risks, or bad practices.  
   For each issue give:
   - Severity (High / Medium / Low)
   - Why it is a problem
   - How to fix or improve it

   ### 3. Convert to Clean Apex
   Convert the entire Flow 100% into clean, production-ready, bulkified Apex code (2026 best practices).  
   Provide:
   - Trigger file
   - Handler class
   - Test class skeleton