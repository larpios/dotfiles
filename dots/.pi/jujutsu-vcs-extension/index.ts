/**
 * Jujutsu (jj) VCS Integration Extension
 *
 * Provides tools and UI integration for jujutsu VCS operations.
 * Jujutsu is a modern VCS with improved git workflows.
 */

import { Type } from "typebox";
import { defineTool, type ExtensionAPI } from "@earendil-works/pi-coding-agent";

// Register status line tool
const statusTool = defineTool({
	name: "jj_status",
	label: "Jujutsu Status",
	description: "Show current jujutsu repository status",
	parameters: Type.Object({}),
	async execute(_toolCallId, _params, _onUpdate, ctx) {
		try {
			const { stdout } = await ctx.exec("jj", ["status", "-T", "ui_status()"]);
			const status = stdout.trim();

			// Parse status
			let statusText = "Unknown";
			if (status.includes("working")) statusText = "Working tree has changes";
			else if (status.includes("parent")) statusText = "Working tree clean";
			else if (status.includes("descendant")) statusText = "Ahead of parent";
			else if (status.includes("unresolved"))
				statusText = "Unresolved conflicts";
			else if (status.includes("conflict")) statusText = "Conflicts detected";

			return {
				content: [
					{ type: "text", text: `Jujutsu Status: ${statusText}\n\n${status}` },
				],
				details: { status, statusText },
			};
		} catch (error) {
			return {
				content: [
					{
						type: "text",
						text: "Jujutsu not initialized or not in a jujutsu repository.",
					},
				],
				details: { error: String(error) },
			};
		}
	},
});

// Register changes tool
const changesTool = defineTool({
	name: "jj_changes",
	label: "Jujutsu Changes",
	description: "List all changes in the working tree",
	parameters: Type.Object({}),
	async execute(_toolCallId, _params, _onUpdate, ctx) {
		try {
			const { stdout } = await ctx.exec("jj", ["changes", "-T", "changes()"]);
			return {
				content: [{ type: "text", text: `Jujutsu Changes:\n\n${stdout}` }],
				details: { changes: stdout },
			};
		} catch (error) {
			return {
				content: [{ type: "text", text: "Failed to list changes." }],
				details: { error: String(error) },
			};
		}
	},
});

// Register diff tool
const diffTool = defineTool({
	name: "jj_diff",
	label: "Jujutsu Diff",
	description: "Show diff for a specific change",
	parameters: Type.Object({
		change: Type.String({ description: "Change ID or name" }),
	}),
	async execute(_toolCallId, params, _onUpdate, ctx) {
		try {
			const { stdout } = await ctx.exec("jj", ["diff", params.change]);
			return {
				content: [
					{
						type: "text",
						text: `Diff for change ${params.change}:\n\n${stdout}`,
					},
				],
				details: { change: params.change },
			};
		} catch (error) {
			return {
				content: [
					{
						type: "text",
						text: `Failed to get diff for change ${params.change}`,
					},
				],
				details: { error: String(error) },
			};
		}
	},
});

// Register commit tool
const commitTool = defineTool({
	name: "jj_commit",
	label: "Jujutsu Commit",
	description: "Commit changes with a message",
	parameters: Type.Object({
		message: Type.String({ description: "Commit message" }),
	}),
	async execute(_toolCallId, params, _onUpdate, ctx) {
		try {
			const { stdout } = await ctx.exec("jj", ["commit", "-m", params.message]);
			return {
				content: [
					{
						type: "text",
						text: `Committed with message: ${params.message}\n\n${stdout}`,
					},
				],
				details: { message: params.message },
			};
		} catch (error) {
			return {
				content: [{ type: "text", text: "Failed to commit changes." }],
				details: { error: String(error) },
			};
		}
	},
});

// Register fold tool
const foldTool = defineTool({
	name: "jj_fold",
	label: "Jujutsu Fold",
	description: "Fold a change into its parent",
	parameters: Type.Object({
		change: Type.String({ description: "Change ID or name" }),
	}),
	async execute(_toolCallId, params, _onUpdate, ctx) {
		try {
			const { stdout } = await ctx.exec("jj", ["fold", params.change]);
			return {
				content: [
					{
						type: "text",
						text: `Folded change ${params.change}:\n\n${stdout}`,
					},
				],
				details: { change: params.change },
			};
		} catch (error) {
			return {
				content: [
					{ type: "text", text: `Failed to fold change ${params.change}` },
				],
				details: { error: String(error) },
			};
		}
	},
});

// Register forget tool
const forgetTool = defineTool({
	name: "jj_forget",
	label: "Jujutsu Forget",
	description: "Forget a change (unstage it)",
	parameters: Type.Object({
		change: Type.String({ description: "Change ID or name" }),
	}),
	async execute(_toolCallId, params, _onUpdate, ctx) {
		try {
			const { stdout } = await ctx.exec("jj", ["forget", params.change]);
			return {
				content: [
					{
						type: "text",
						text: `Forgotten change ${params.change}:\n\n${stdout}`,
					},
				],
				details: { change: params.change },
			};
		} catch (error) {
			return {
				content: [
					{ type: "text", text: `Failed to forget change ${params.change}` },
				],
				details: { error: String(error) },
			};
		}
	},
});

// Register edit tool
const editTool = defineTool({
	name: "jj_edit",
	label: "Jujutsu Edit",
	description: "Edit a change's message",
	parameters: Type.Object({
		change: Type.String({ description: "Change ID or name" }),
	}),
	async execute(_toolCallId, params, _onUpdate, ctx) {
		try {
			const { stdout } = await ctx.exec("jj", ["edit", params.change]);
			return {
				content: [
					{
						type: "text",
						text: `Edited change ${params.change}:\n\n${stdout}`,
					},
				],
				details: { change: params.change },
			};
		} catch (error) {
			return {
				content: [
					{ type: "text", text: `Failed to edit change ${params.change}` },
				],
				details: { error: String(error) },
			};
		}
	},
});

// Register resolve tool
const resolveTool = defineTool({
	name: "jj_resolve",
	label: "Jujutsu Resolve",
	description: "Resolve conflicts in a change",
	parameters: Type.Object({
		change: Type.String({ description: "Change ID or name" }),
	}),
	async execute(_toolCallId, params, _onUpdate, ctx) {
		try {
			const { stdout } = await ctx.exec("jj", ["resolve", params.change]);
			return {
				content: [
					{
						type: "text",
						text: `Resolved conflicts in change ${params.change}:\n\n${stdout}`,
					},
				],
				details: { change: params.change },
			};
		} catch (error) {
			return {
				content: [
					{
						type: "text",
						text: `Failed to resolve conflicts in change ${params.change}`,
					},
				],
				details: { error: String(error) },
			};
		}
	},
});

// Register operations tool
const operationsTool = defineTool({
	name: "jj_operations",
	label: "Jujutsu Operations",
	description: "List all operations (commits, folds, etc.)",
	parameters: Type.Object({}),
	async execute(_toolCallId, _params, _onUpdate, ctx) {
		try {
			const { stdout } = await ctx.exec("jj", [
				"operations",
				"-T",
				"operations()",
			]);
			return {
				content: [{ type: "text", text: `Jujutsu Operations:\n\n${stdout}` }],
				details: { operations: stdout },
			};
		} catch (error) {
			return {
				content: [{ type: "text", text: "Failed to list operations." }],
				details: { error: String(error) },
			};
		}
	},
});

// Register parents tool
const parentsTool = defineTool({
	name: "jj_parents",
	label: "Jujutsu Parents",
	description: "Show parent changes",
	parameters: Type.Object({}),
	async execute(_toolCallId, _params, _onUpdate, ctx) {
		try {
			const { stdout } = await ctx.exec("jj", ["parents", "-T", "parents()"]);
			return {
				content: [{ type: "text", text: `Jujutsu Parents:\n\n${stdout}` }],
				details: { parents: stdout },
			};
		} catch (error) {
			return {
				content: [{ type: "text", text: "Failed to show parents." }],
				details: { error: String(error) },
			};
		}
	},
});

// Register summary tool
const summaryTool = defineTool({
	name: "jj_summary",
	label: "Jujutsu Summary",
	description: "Show a summary of the repository",
	parameters: Type.Object({}),
	async execute(_toolCallId, _params, _onUpdate, ctx) {
		try {
			const { stdout } = await ctx.exec("jj", ["summary", "-T", "summary()"]);
			return {
				content: [{ type: "text", text: `Jujutsu Summary:\n\n${stdout}` }],
				details: { summary: stdout },
			};
		} catch (error) {
			return {
				content: [{ type: "text", text: "Failed to get summary." }],
				details: { error: String(error) },
			};
		}
	},
});

// Register branch tool
const branchTool = defineTool({
	name: "jj_branch",
	label: "Jujutsu Branch",
	description: "Show current branch",
	parameters: Type.Object({}),
	async execute(_toolCallId, _params, _onUpdate, ctx) {
		try {
			const { stdout } = await ctx.exec("jj", ["branch", "-T", "branch()"]);
			return {
				content: [{ type: "text", text: `Current Branch: ${stdout}` }],
				details: { branch: stdout },
			};
		} catch (error) {
			return {
				content: [{ type: "text", text: "Failed to get branch." }],
				details: { error: String(error) },
			};
		}
	},
});

// Export extension
export default function (pi: ExtensionAPI) {
	// Register all tools
	pi.registerTool(statusTool);
	pi.registerTool(changesTool);
	pi.registerTool(diffTool);
	pi.registerTool(commitTool);
	pi.registerTool(foldTool);
	pi.registerTool(forgetTool);
	pi.registerTool(editTool);
	pi.registerTool(resolveTool);
	pi.registerTool(operationsTool);
	pi.registerTool(parentsTool);
	pi.registerTool(summaryTool);
	pi.registerTool(branchTool);

	// Subscribe to lifecycle events
	pi.on("turn_start", async () => {
		// Check for unresolved conflicts
		try {
			const { stdout } = await pi.exec("jj", ["status", "-T", "ui_status()"]);
			if (stdout.includes("unresolved") || stdout.includes("conflict")) {
				pi.events.emit("warning", {
					title: "Jujutsu Conflicts",
					message:
						"There are unresolved conflicts in your jujutsu repository. Please resolve them before continuing.",
				});
			}
		} catch {
			// Not in a jujutsu repo, ignore
		}
	});

	// Show status in footer
	pi.on("message_update", async (event) => {
		if (
			event.type === "message_update" &&
			event.assistantMessageEvent.type === "text_delta"
		) {
			// Could add status line updates here
		}
	});
}
