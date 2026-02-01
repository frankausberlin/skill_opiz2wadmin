# Instructions for Agent Journaling

To ensure that all agents can quickly understand the history and context of a project, every significant action or task performed must be documented in the `~/labor/agent_journal` directory.

## File Naming Convention

Use descriptive and informative filenames that allow for quick scanning.
Format: `minidescription_or_keywords_but_informative.md`

Example: `setup_pi_optimization_scripts.md` or `fix_nginx_config_error.md`

## Content Structure

Each journal entry should be compact and focus on the most important information:

1.  **Date & Time**: When the action took place.
2.  **Task Overview**: What was the objective?
3.  **Actions Taken**: What exactly was done? (Commands run, files edited, etc.)
4.  **Reasoning (Why)**: Why was this approach chosen?
5.  **Outcome**: What was the result? (Success, errors encountered, next steps).

## Guidelines

*   **Be Concise**: Only include the most relevant details.
*   **Technical Accuracy**: Use exact filenames and commands.
*   **Inter-Agent Communication**: Write as if you are explaining the state of the project to another AI agent who just arrived.
