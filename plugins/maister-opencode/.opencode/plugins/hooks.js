/**
 * Maister OpenCode Plugin
 * Registers skills/agents/commands via OpenCode's JS event system.
 */

import path from "path";
import fs from "fs";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
// hooks.js lives at: plugins/maister-opencode/.opencode/plugins/hooks.js
// Plugin root is:    plugins/maister-opencode/
const PLUGIN_ROOT = path.resolve(__dirname, "../..");

/**
 * Resolves model aliases to the configured small_model value.
 * Maps common small/fast model aliases to OpenCode's small_model config.
 *
 * @param {string} modelValue - The model value from agent frontmatter
 * @param {string} smallModel - The small_model from OpenCode config
 * @returns {string|undefined} - Resolved model value or undefined
 */
function resolveModelAlias(modelValue, smallModel) {
  // Aliases that should map to small_model
  const SMALL_MODEL_ALIASES = [
    "haiku", // Claude Code alias
    "gpt-4o-mini", // OpenAI small model
    "small", // Generic alias
    "fast", // Generic alias
  ];

  // If no model specified or it's 'inherit', return undefined (let OpenCode decide)
  if (!modelValue || modelValue === "inherit") {
    return undefined;
  }

  // If it's a small model alias and we have a configured small_model, use it
  if (SMALL_MODEL_ALIASES.includes(modelValue.toLowerCase())) {
    if (smallModel) {
      return smallModel;
    }
    // If no small_model configured, return undefined (inherit)
    console.warn(
      `[Maister] Agent uses '${modelValue}' but no small_model configured in opencode.json - falling back to inherit`,
    );
    return undefined;
  }

  // Otherwise, pass through the original value
  return modelValue;
}

// Simple frontmatter parser — handles arrays and simple key-value pairs
function parseFrontmatter(content) {
  const normalized = content.replace(/\r\n?/g, "\n");
  const match = normalized.match(/^---\n([\s\S]*?)\n---\n?([\s\S]*)$/);
  if (!match) return { data: {}, content: normalized.trim() };

  const data = {};
  const lines = match[1].split("\n");
  let currentKey = null;
  let currentArray = null;

  for (const line of lines) {
    // Check for array item
    if (line.trim().startsWith("-") && currentArray) {
      const value = line.trim().slice(1).trim();
      if (value) {
        currentArray.push(value);
      }
      continue;
    }

    const colonIdx = line.indexOf(":");
    if (colonIdx > 0) {
      const key = line.slice(0, colonIdx).trim();
      const value = line
        .slice(colonIdx + 1)
        .trim()
        .replace(/^["']|["']$/g, "");

      // If value is empty, might be start of array
      if (!value) {
        currentKey = key;
        currentArray = [];
        data[key] = currentArray;
      } else {
        data[key] = value;
        currentKey = null;
        currentArray = null;
      }
    }
  }
  return { data, content: match[2].trim() };
}

function loadMarkdownDir(dir) {
  try {
    return fs
      .readdirSync(dir)
      .filter((f) => f.endsWith(".md"))
      .map((f) => {
        const raw = fs.readFileSync(path.join(dir, f), "utf8");
        const { data, content } = parseFrontmatter(raw);
        return { file: f, data, content };
      });
  } catch {
    return [];
  }
}

export const MaisterPlugin = async ({ $, directory }) => {
  return {
    /**
     * Register maister's skills, commands, and agents so OpenCode discovers
     * them without requiring manual config file edits.
     */
    config: async (config) => {
      // Get small_model config for alias resolution
      // Try from config parameter first, fallback to reading opencode.json
      let smallModel = config.small_model;

      if (!smallModel) {
        try {
          // Check project-level opencode.json
          const projectConfigPath = path.join(directory, "opencode.json");
          if (fs.existsSync(projectConfigPath)) {
            const rawConfig = fs.readFileSync(projectConfigPath, "utf8");
            const opencodeConfig = JSON.parse(rawConfig);
            smallModel = opencodeConfig.small_model;
          }
        } catch (error) {
          console.warn(
            `Couldn't read or parse opencode.json config - small_model remains undefined`,
          );
        }
      }

      // Debug logging (can be removed after confirming functionality)
      if (process.env.MAISTER_DEBUG_MODELS) {
        console.log("[Maister] Model resolution debug:");
        console.log("  config.small_model:", config.small_model);
        console.log("  resolved small_model:", smallModel);
      }

      // --- Skills ---
      config.skills = config.skills || {};
      config.skills.paths = config.skills.paths || [];
      const skillsDir = path.join(PLUGIN_ROOT, "skills");
      if (!config.skills.paths.includes(skillsDir)) {
        config.skills.paths.push(skillsDir);
      }

      // --- Commands ---
      config.command = config.command || {};
      const commandsDir = path.join(PLUGIN_ROOT, "commands");
      for (const { data, content } of loadMarkdownDir(commandsDir)) {
        const name = data.name;
        if (!name) continue;
        // Don't overwrite commands the user has explicitly configured
        if (config.command[name]) continue;
        config.command[name] = {
          template: content,
          ...(data.description && { description: data.description }),
          ...(data.agent && { agent: data.agent }),
          ...(data.model && { model: data.model }),
          ...(data.subtask !== undefined && {
            subtask: data.subtask === "true",
          }),
        };
      }

      // --- Agents ---
      config.agent = config.agent || {};
      const agentsDir = path.join(PLUGIN_ROOT, "agents");
      for (const { data, content } of loadMarkdownDir(agentsDir)) {
        const name = data.name;
        if (!name) continue;
        // Don't overwrite agents the user has explicitly configured
        if (config.agent[name]) continue;

        try {
          config.agent[name] = {
            prompt: content,
            ...(data.description && { description: data.description }),
            // Resolve model aliases (haiku, gpt-4o-mini, etc.) to small_model
            ...(() => {
              const resolvedModel = resolveModelAlias(data.model, smallModel);
              return resolvedModel ? { model: resolvedModel } : {};
            })(),
            ...(data.color && { color: data.color }),
            ...(data.mode && { mode: data.mode }),
            // Add skills array if present
            ...(data.skills &&
              Array.isArray(data.skills) && { skills: data.skills }),
          };
        } catch (error) {
          console.warn(
            `[Maister] Failed to register agent '${name}': ${error.message}`,
          );
        }
      }
    },

    /**
     * Post-compaction reminder.
     * Injects orchestrator state reminder into the compaction context so the
     * AI knows to re-read orchestrator-state.yml after the context is rebuilt.
     */
    "experimental.session.compacting": async (input, output) => {
      const tasksDir = `${directory}/.maister/tasks`;
      try {
        await $`test -d ${tasksDir}`;
        output.context.push(`## Maister Workflow State
If an orchestrator workflow was active before compaction, you MUST re-read
orchestrator-state.yml in that task's directory to verify completed_phases
and determine the next phase. Use the question tool at Phase Gates.`);
      } catch {
        // No .maister/tasks directory — not a maister project, skip injection
      }
    },
  };
};
