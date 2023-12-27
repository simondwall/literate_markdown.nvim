local M = {}

--- Extract info from code block
--- If the code block is not a literate code block, returns nil, nil
--- @param match table<integer, TSNode> Match from query
--- @param buffer integer Buffer id of the markdown file (0 is current buffere)
--- @return string | nil file Filename to export code to
--- @return string | nil code Code inside the code block
local function extract_code_block(match, buffer)
    local info = vim.treesitter.get_node_text(match[1], buffer)
    local file = string.match(info, "file%s*=%s*\"([^\"]*)\"")
    if file == nil then
        return nil, nil
    end
    local code = vim.treesitter.get_node_text(match[2], buffer)
    return file, code
end

--- Extract code blocks from markdown file
--- @param buffer integer Buffer id of the markdown file (0 is current buffer)
--- @return {string: string[]} mapping of file names to code blocks
local function extract_code_blocks(buffer)
    local root = vim.treesitter.get_node({ bufnr = buffer }):tree():root()
    local query = vim.treesitter.query.parse("markdown",
        "(fenced_code_block (info_string) @info (code_fence_content) @content)")

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
--- @param opts {} Options for literate_markdown.nvim
function M.setup(opts)
    opts = opts or {}
end

--- Export code blocks from markdown file to their source files
function M.export_code_blocks()
    local code_blocks = extract_code_blocks(0)

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