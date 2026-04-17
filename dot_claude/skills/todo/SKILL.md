---
name: todo
description: Todoist task management — list, add, complete, search tasks
allowed-tools: Bash
---

Manage Todoist tasks via REST API v1. Auth via env var `TODOIST_API_KEY`.

Base URL: `https://api.todoist.com/api/v1`
Auth header: `Authorization: Bearer $TODOIST_API_KEY`

## Known Projects

| ID | Name |
|----|------|
| 6MmCwQ7gMwf4JvHF | Work |
| 6CrfV8c5h5GFp4gp | Inbox |
| 6CrfV8c5hpMwp9F7 | Laif |
| 6W54WWjmFp3qhrWp | Casa |

## Usage

`/todo <command> [args]`

### Commands

**list** — Show tasks (defaults to Work project)
```
/todo list
/todo list inbox
/todo list all
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

**search <query>** — Search across all projects
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
Todoist filter syntax: `search: <query>`, `today`, `overdue`, `p1`, `#Work`, etc.

## Output format

Present tasks as a clean table:

| Priority | Due | Task |
|----------|-----|------|

Sort by priority (urgent first), then due date (overdue first). Flag overdue tasks.

## Important

- NEVER echo or log the API token
- Default project is **Work** (6MmCwQ7gMwf4JvHF) unless specified
- When adding tasks, confirm what was created
- When completing, confirm the task name
