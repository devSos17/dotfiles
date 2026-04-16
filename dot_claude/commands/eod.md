End-of-day review. Help me close the work day and plan tomorrow.

Steps:

## 1. Review today
- Fetch completed tasks from Todoist for today (Work project)
- Check `git log --since="8am" --until="now" --oneline` across any repos with recent activity in ~/dev/
- Summarize: what got done today

## 2. Check pending
- Fetch remaining open tasks for Work project: `(today | overdue) & ##Work`
- Flag anything that's still open — ask if it should move to tomorrow or be deprioritized

## 3. Plan tomorrow
- Ask me: "Que quieres priorizar manana?"
- Based on my answer, create or reschedule tasks in Todoist for tomorrow (use reschedule-tasks, not update-tasks)
- Keep it to 3-5 tasks max — no overloading

## 4. Close
- Confirm tomorrow's plan in a clean table
- Say: "Listo, descansa. Manana arrancamos con /kickoff"
