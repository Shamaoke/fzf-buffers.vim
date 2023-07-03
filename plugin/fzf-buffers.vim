vim9script
##                   ##
# ::: Fzf Buffers ::: #
##                   ##

var config = {
  'fzf_default_command': $FZF_DEFAULT_COMMAND,

  'geometry': {
    'width': 0.8,
    'height': 0.8
  },

  'term_command': [
    'fzf',
    '--no-multi',
    '--preview-window=border-left:+{4}-/2',
    '--ansi',
    '--delimiter=\t',
    '--tabstop=1',
    '--expect=esc,enter,ctrl-t,ctrl-s,ctrl-v'
  ],

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

def SetExitCb( ): func(job, number): string

  def Callback(job: job, status: number): string
    var commands: list<string>

    commands = ['quit']

    return execute(commands)
  enddef

  return Callback

enddef

def SetCloseCb(file: string): func(channel): string

  def Callback(channel: channel): string
    var data: list<string> = readfile(file)

    if data->len() < 2
      return execute([':$bwipeout', ':', $"call delete('{file}')"])
    endif

    var key   = data->get(0)
    var value = data->get(-1)->split(':')->get(0)

    var commands: list<string>

    if key == 'enter'
      commands = [':$bwipeout', $"buffer {value}", $"call delete('{file}')"]
    elseif key == 'ctrl-t'
      commands = [':$bwipeout', $"tab sbuffer {value}", $"call delete('{file}')"]
    elseif key == 'ctrl-s'
      commands = [':$bwipeout', $"sbuffer {value}", $"call delete('{file}')"]
    elseif key == 'ctrl-v'
      commands = [':$bwipeout', $"vertical sbuffer {value}", $"call delete('{file}')"]
    else
      commands = [':$bwipeout', $":", $"call delete('{file}')"]
    endif

    return execute(commands)
  enddef

  return Callback

enddef

def ExtendTermCommandOptions(options: list<string>): list<string>
  var PreviewEmpty = ( ) => 'echo ""'

  var PreviewNonEmpty = ( ) => 'bat --color=always --style=numbers --highlight-line={4} {3}'

  var extensions = [
    $'--preview=[[ {{3}} =~ ''\[No Name\]'' ]] && {PreviewEmpty()} || {PreviewNonEmpty()}'
  ]

  return options->extendnew(extensions)
enddef

def ExtendTermOptions(options: dict<any>): dict<any>
  var tmp_file = tempname()

  var extensions =
    { 'out_name': tmp_file,
      'exit_cb': SetExitCb(),
      'close_cb': SetCloseCb(tmp_file) }

  return options->extendnew(extensions)
enddef

def ExtendPopupOptions(options: dict<any>): dict<any>
  var extensions =
    { minwidth:  (&columns * config['geometry']->get('width'))->ceil()->float2nr(),
      minheight: (&lines * config['geometry']->get('height'))->ceil() ->float2nr() }

   return options->extendnew(extensions)
enddef

def SetFzfCommand( ): void

  var command: string

  def Format(key: number, value: any): string
    var result = [
      value->get('bufnr'),
      ':',
      '\\t',
      (value->get('bufnr') == bufnr('') ? '%' : value->get('bufnr') == bufnr('#') ? '#' : ' '),
      '\\t',
      (value->get('name')->fnamemodify(':.') ?? '\[No Name\]'),
      '\\t',
      value->get('lnum')
    ]

    return result->join('')
  enddef

  def ListBuffers(): string
    return getbufinfo()
             ->filter((_, v) => v->get('hidden') != 1)
             ->map(Format)
             ->join('\\n')
  enddef

  command = $"echo {ListBuffers()} | column --table --separator=\\\t --output-separator=\\\t --table-right=1,4"

  $FZF_DEFAULT_COMMAND = command

enddef

def RestoreFzfCommand( ): void
  $FZF_DEFAULT_COMMAND = config->get('fzf_default_command')
enddef

def Start( ): void
  term_start(
    config
      ->get('term_command')
      ->ExtendTermCommandOptions(),
    config
      ->get('term_options')
      ->ExtendTermOptions())
    ->popup_create(
        config
          ->get('popup_options')
          ->ExtendPopupOptions())
enddef

def FzfBF( ): void
  SetFzfCommand()

  try
    Start()
  finally
    RestoreFzfCommand()
  endtry
enddef

command FzfBF FzfBF()

# vim: set textwidth=80 colorcolumn=80:
