vim.api.nvim_create_autocmd('FileType', {
 pattern = { '<filetype>' },
 callback = function() 
     vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
     vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

     vim.treesitter.start() 
 end,
})
