/**
 * Maister OpenCode Plugin
 * Registers skills/agents/commands via OpenCode's JS event system.
 */

import path from 'path'
import fs from 'fs'
import { fileURLToPath } from 'url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
// hooks.js lives at: plugins/maister-opencode/.opencode/plugins/hooks.js
// Plugin root is:    plugins/maister-opencode/
const PLUGIN_ROOT = path.resolve(__dirname, '../..')

// Simple frontmatter parser — no external dependencies
function parseFrontmatter(content) {
  const match = content.match(/^---\n([\s\S]*?)\n---\n?([\s\S]*)$/)
  if (!match) return { data: {}, content: content.trim() }

  const data = {}
  for (const line of match[1].split('\n')) {
    const colonIdx = line.indexOf(':')
    if (colonIdx > 0) {
      const key = line.slice(0, colonIdx).trim()
      const value = line.slice(colonIdx + 1).trim().replace(/^["']|["']$/g, '')
      data[key] = value
    }
  }
  return { data, content: match[2].trim() }
}

function loadMarkdownDir(dir) {
  try {
    return fs.readdirSync(dir)
      .filter(f => f.endsWith('.md'))
      .map(f => {
        const raw = fs.readFileSync(path.join(dir, f), 'utf8')
        const { data, content } = parseFrontmatter(raw)
        return { file: f, data, content }
      })
  } catch {
    return []
  }
}

export const MaisterPlugin = async ({ $, directory }) => {
  return {
    /**
     * Register maister's skills, commands, and agents so OpenCode discovers
     * them without requiring manual config file edits.
     */
    config: async (config) => {
      // --- Skills ---
      config.skills = config.skills || {}
      config.skills.paths = config.skills.paths || []
      const skillsDir = path.join(PLUGIN_ROOT, 'skills')
      if (!config.skills.paths.includes(skillsDir)) {
        config.skills.paths.push(skillsDir)
      }

      // --- Commands ---
      config.command = config.command || {}
      const commandsDir = path.join(PLUGIN_ROOT, 'commands')
      for (const { data, content } of loadMarkdownDir(commandsDir)) {
        const name = data.name
        if (!name) continue
        // Don't overwrite commands the user has explicitly configured
        if (config.command[name]) continue
        config.command[name] = {
          template: content,
          ...(data.description && { description: data.description }),
          ...(data.agent && { agent: data.agent }),
          ...(data.model && { model: data.model }),
          ...(data.subtask !== undefined && { subtask: data.subtask === 'true' }),
        }
      }

      // --- Agents ---
      config.agent = config.agent || {}
      const agentsDir = path.join(PLUGIN_ROOT, 'agents')
      for (const { data, content } of loadMarkdownDir(agentsDir)) {
        const name = data.name
        if (!name) continue
        // Don't overwrite agents the user has explicitly configured
        if (config.agent[name]) continue
        config.agent[name] = {
          prompt: content,
          ...(data.description && { description: data.description }),
          ...(data.model && data.model !== 'inherit' && { model: data.model }),
          ...(data.color && { color: data.color }),
          ...(data.mode && { mode: data.mode }),
        }
      }
    },

    /**
     * Post-compaction reminder.
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
