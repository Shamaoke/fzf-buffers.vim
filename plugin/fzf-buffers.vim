vim9script
##                   ##
# ::: Fzf Buffers ::: #
##                   ##

import 'fzf-run.vim' as Fzf

var spec = {
  'set_fzf_data': (data) =>
    getbufinfo()
      ->filter((_, v) => v->get('hidden') != 1 && v->get('listed') != 0)
      ->map((_, v) =>
          [ v->get('bufnr'),
            ':',
            "\t",
            (v->get('bufnr') == bufnr('') ? '%' : v->get('bufnr') == bufnr('#') ? '#' : ' '),
            "\t",
            (v->get('name')->fnamemodify(':.') ?? '[No Name]'),
            "\t",
            v->get('lnum') ]->join('')
        )
      ->writefile(data),

  'set_tmp_file': ( ) => tempname(),
  'set_tmp_data': ( ) => tempname(),

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
    '--bind=ctrl-h:first,ctrl-e:last,alt-h:preview-top,alt-e:preview-bottom,alt-j:preview-down,alt-k:preview-up,alt-p:toggle-preview,alt-x:change-preview-window(right,90%|right,50%)',
    '--expect=enter,ctrl-t,ctrl-s,ctrl-v,ctrl-d'
  ],

  'set_term_command_options': (data) =>
    [ $"--bind=start:reload^cat '{data}' | column --table --separator='\t' --output-separator='\t' --table-right=1,4^" ],

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
