---
name: todo
description: Todoist Work project only — list, add, complete, search work tasks
allowed-tools: Bash
---

Manage tasks in the Todoist **Work** project via REST API v1. Auth via env var `TODOIST_API_KEY` (never echoed, never written to a file).

**Scope: Work project only.** Never list, read, search or modify any other project; Sos's personal projects are off-limits from the work machine.

Base URL: `https://api.todoist.com/api/v1`
Auth header: `Authorization: Bearer $TODOIST_API_KEY`

## Known Projects

| ID | Name |
|----|------|
| 6MmCwQ7gMwf4JvHF | Work |

## Usage

`/todo <command> [args]`

### Commands

**list** — Show Work tasks
```
/todo list
/todo list today
```

**add <task>** — Add a task to Work project
```
/todo add Fix MCP Confluence bug
/todo add Review PR by Friday p1
```

**done <task name or ID>** — Complete a task
```
/todo done Fix MCP
```

**search <query>** — Search within the Work project
```
/todo search CKA
```

## API Endpoints

### List tasks
```bash
curl -s -H "Authorization: Bearer $TODOIST_API_KEY" \
  "https://api.todoist.com/api/v1/tasks?project_id=<PROJECT_ID>"
```

### Add task
```bash
curl -s -X POST -H "Authorization: Bearer $TODOIST_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"content":"<TASK>","project_id":"<PROJECT_ID>","priority":<1-4>,"due_string":"<DATE>"}' \
  "https://api.todoist.com/api/v1/tasks"
```
Priority: 1=normal, 2=medium, 3=high, 4=urgent. Parse from user input: "p1"→4, "p2"→3, "p3"→2, default→1.
Due date: parse natural language like "Friday", "tomorrow", "Apr 20" into `due_string`.

### Complete task
```bash
curl -s -X POST -H "Authorization: Bearer $TODOIST_API_KEY" \
  "https://api.todoist.com/api/v1/tasks/<TASK_ID>/close"
```
To find the task ID, list tasks and match by content substring.

### Search (filter)
```bash
curl -s -H "Authorization: Bearer $TODOIST_API_KEY" \
  "https://api.todoist.com/api/v1/tasks?filter=<FILTER>"
```
Always scope filters to Work: `##Work & search: <query>`, `##Work & (today | overdue)`, `##Work & p1`.

## Output format

Present tasks as a clean table:

| Priority | Due | Task |
|----------|-----|------|

Sort by priority (urgent first), then due date (overdue first). Flag overdue tasks.

## Important

- NEVER echo or log the API token
- Project is always **Work** (6MmCwQ7gMwf4JvHF). If asked for another project, decline and say why
- When adding tasks, confirm what was created
- When completing, confirm the task name
