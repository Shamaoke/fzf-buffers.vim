vim9script
##                   ##
# ::: Fzf Buffers ::: #
##                   ##

import 'fzf-run.vim' as Fzf

var spec = {
  'fzf_default_command': $FZF_DEFAULT_COMMAND,

  'set_fzf_data': ( ) =>
    getbufinfo()
      ->filter((_, v) => v->get('hidden') != 1 && v->get('listed') != 0)
      ->map((_, v) =>
          [ v->get('bufnr'),
            ':',
            '\\t',
            (v->get('bufnr') == bufnr('') ? '%' : v->get('bufnr') == bufnr('#') ? '#' : ' '),
            '\\t',
            (v->get('name')->fnamemodify(':.') ?? '\[No Name\]'),
            '\\t',
            v->get('lnum') ]->join('')
        )
      ->join('\\n'),

  'set_fzf_command': (data) => $"echo {data} | column --table --separator=\\\t --output-separator=\\\t --table-right=1,4",

  'set_tmp_file': ( ) => tempname(),

  'geometry': {
    'width': 0.8,
    'height': 0.8
  },

  'commands': {
    'enter':  (entry) => $"buffer {entry->split(':')->get(0)}",
    'ctrl-t': (entry) => $"tab sbuffer {entry->split(':')->get(0)}",
    'ctrl-s': (entry) => $"sbuffer {entry->split(':')->get(0)}",
    'ctrl-v': (entry) => $"vertical sbuffer {entry->split(':')->get(0)}",
    'ctrl-d': (entry) => $"bdelete {entry->split(':')->get(0)}"
  },

  'term_command': [
    'fzf',
    '--no-multi',
    '--preview-window=border-left:+{4}-/2',
    '--preview=bat --color=always --style=numbers --highlight-line={4} {3} 2>/dev/null || echo ""',
    '--ansi',
    '--delimiter=\t',
    '--tabstop=1',
    '--bind=alt-j:preview-down,alt-k:preview-up',
    '--expect=enter,ctrl-t,ctrl-s,ctrl-v,ctrl-d'
  ],

  'set_term_command_options': ( ) => [ ],

  'term_options': {
    'hidden': true,
    'out_io': 'file'
  },

  'popup_options': {
    'title': '─ ::: Fzf Buffers ::: ─',
    'border': [1, 1, 1, 1],
    'borderchars': ['─', '│', '─', '│', '┌', '┐', '┘', '└']
  }
}

command FzfBF Fzf.Run(spec)

# vim: set textwidth=80 colorcolumn=80:
