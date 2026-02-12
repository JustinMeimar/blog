There are some NeoVim/Vim settings I find make a big diference in my QOL.

#### Vim

1. `opts.scrolloff = 15`

When scrolling in Vim it can be annoying to hold `j` all the way until the bottom of 
the screen to trigger the movement. This option triggers scrolling `15` lines from
the bottom of the buffer. Similarly for scrolling up.

2. `opts.incsearch = false`

If you have ever used `/` to quickly search for strings in your current buffer, you may
have noticed Vim likes to immediately flicker to any matches of the partial string. This
setting prevents seeking to matches until manually invoked with `C-n` for next or `C-N`
for previous match.

#### Telescope (NeoVim)

3. Fuzzy finding in the current buffer. Telescope comes with a fuzzy file finder and a
project wide live grep finder out of the box. However, if you know what your looking for
is in the current buffer, it is worth making a keymap for `current_buffer_fuzzy_find`.

```
<leader>/ current_buffer_fuzzy_find
```

A corollary to this is to set `file_ignore_patterns` to some common file paths to ignore.

```
file_ignore_patterns = [
    "^.git/"
    "^node_modules/"
    "^build/"
    "^dist/"
    "^__pycache__/"
    "^venv/"
    "^env/"
  ];
```

4. Preventing Memoryless Fuzzy finding. A common flow I encountered was: Use the fuzzy
finder, jump into one of several matches to investigate, then reopen the fuzzy finder
to an empty search buffer, forcing me to re-type the previous search string.

Adding a keymap for resume:

```
<leader>fl = "resume" # find last
```

