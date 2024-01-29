-- Show `git diff --cached` when editing `COMMIT_EDITMSG`.
vim.cmd.DiffGitCached()
vim.cmd.resize(20)

-- Back to original window, which is editing COMMIT_EDITMGS.
vim.cmd('wincmd p')
vim.cmd('goto 1')

-- Use spell check always for `gitcommit`.
vim.wo.spell = true
