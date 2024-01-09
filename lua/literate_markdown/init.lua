local M = {}

local path = require("plenary.path")

--- Create a absolute path
--- Expands ~ to home directory
--- @param file_name string File name to expand
--- @param buffer integer Buffer id of the markdown file (0 is current buffer)
--- @return string Expanded file name
local function expand_file_name(file_name, buffer)
	local home = os.getenv("HOME")
	if home ~= nil then
		file_name = file_name:gsub("~", home)
	end
	if not file_name:match("^/") then
		local buf_path = path:new(vim.api.nvim_buf_get_name(buffer))
		file_name = buf_path:parent() .. "/" .. file_name
	end
	return file_name
end

--- Extract info from code block
--- If the code block is not a literate code block, returns nil, nil
--- @param match table<integer, TSNode> Match from query
--- @param buffer integer Buffer id of the markdown file (0 is current buffere)
--- @return string | nil file Filename to export code to
--- @return string | nil code Code inside the code block
local function extract_code_block(match, buffer)
	local info = vim.treesitter.get_node_text(match[1], buffer)
	local file = string.match(info, 'file%s*=%s*"([^"]*)"')
	if file == nil then
		return nil, nil
	end
	local code = vim.treesitter.get_node_text(match[2], buffer)
	local expanded_file = expand_file_name(file, buffer)
	return expanded_file, code
end

--- Extract code blocks from markdown file
--- @param buffer integer Buffer id of the markdown file (0 is current buffer)
--- @return {string: string[]} mapping of file names to code blocks
local function extract_code_blocks(buffer)
	local root = vim.treesitter.get_node({ bufnr = buffer }):tree():root()
	local query =
		vim.treesitter.query.parse("markdown", "(fenced_code_block (info_string) @info (code_fence_content) @content)")

	local code_blocks = {}
	for _, match, _ in query:iter_matches(root, buffer, root:start(), root:end_()) do
		local file, code = extract_code_block(match, buffer)
		if file == nil or code == nil then
			goto continue
		end

		if code_blocks[file] == nil then
			code_blocks[file] = {}
		end
		table.insert(code_blocks[file], code)

		::continue::
	end

	return code_blocks
end

--- Setup literate_markdown.nvim
--- @param opts {export_on_save: boolean} Options for literate_markdown.nvim
function M.setup(opts)
	opts = opts or {
		export_on_save = false,
	}

	if opts.export_on_save then
		vim.api.nvim_create_augroup("literate_markdown", {})
		vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = {"*.md"},
            callback = function()
                M.export_code_blocks()
            end
        })
	end
end

--- Export code blocks from markdown file to their source files
function M.export_code_blocks()
	local buffer = 0
	local code_blocks = extract_code_blocks(buffer)

	for file_name, blocks in pairs(code_blocks) do
		local file = io.open(file_name, "w")
		if file == nil then
			vim.notify("Failed to open file: " .. file_name, vim.log.levels.ERROR)
			goto continue
		end

		for _, code in ipairs(blocks) do
			file:write(code)
			file:write("\n\n")
		end
		file:close()

		::continue::
	end
end

return M
