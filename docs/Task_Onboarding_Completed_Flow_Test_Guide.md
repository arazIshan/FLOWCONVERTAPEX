# Task — Onboarding Completed Flow Test Guide

## Test Step 1: Prepare Test Data
1. Go to **Contacts** tab → Click **New**.
2. Create a test Contact:
   - **First Name**: `Test`
   - **Last Name**: `Onboarding Contact`
   - **Description**: Leave empty
3. Save the Contact.

## Test Step 2: Positive Test (Flow should run and update)
1. Create a new **Task**:
   - **Subject**: `Onboarding - Welcome Call`
   - **Status**: `Completed`
   - **Name (WhoId)**: Select the test Contact above
2. Click **Save**.
3. Open the Contact record and check **Description** field.


