/**
 * Maister OpenCode Plugin
 * Registers skills/agents paths and replicates Claude Code hook behaviors
 * using OpenCode's JS event system.
 */

import path from 'path'
import { fileURLToPath } from 'url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
// hooks.js lives at: plugins/maister-opencode/.opencode/plugins/hooks.js
// Plugin root is:    plugins/maister-opencode/
const PLUGIN_ROOT = path.resolve(__dirname, '../..')

export const MaisterPlugin = async ({ $, directory }) => {
  return {
    /**
     * Register maister's skills directory so OpenCode discovers skills
     * without requiring manual symlinks or config file edits.
     */
    config: async (config) => {
      config.skills = config.skills || {}
      config.skills.paths = config.skills.paths || []
      const skillsDir = path.join(PLUGIN_ROOT, 'skills')
      if (!config.skills.paths.includes(skillsDir)) {
        config.skills.paths.push(skillsDir)
      }
    },

    /**
     * Post-compaction reminder (maps from post-compact-reminder.sh).
     * Injects orchestrator state reminder into the compaction context so the
     * AI knows to re-read orchestrator-state.yml after the context is rebuilt.
     */
    "experimental.session.compacting": async (input, output) => {
      const tasksDir = `${directory}/.maister/tasks`
      try {
        await $`test -d ${tasksDir}`
        output.context.push(`## Maister Workflow State
If an orchestrator workflow was active before compaction, you MUST re-read
orchestrator-state.yml in that task's directory to verify completed_phases
and determine the next phase. Use the question tool at Phase Gates.`)
      } catch {
        // No .maister/tasks directory — not a maister project, skip injection
      }
    },
  }
}
