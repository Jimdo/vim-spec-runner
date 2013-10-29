""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RUNNING TESTS
"
" This is a modified version of Gary Bernhardt's code that allows to run both
" RSpec and Cucumber tests with the same mappings.
"
" Copied from https://github.com/mlafeldt/dotfiles/blob/master/vim/vimrc
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

nnoremap <leader>t :call RunTestFile()<cr>
nnoremap <leader>T :call RunNearestTest()<cr>
nnoremap <leader>a :call RunTests('')<cr>

function! RunTestFile(...)
  if a:0
    let command_suffix = a:1
  else
    let command_suffix = ""
  endif

  " Run the tests for the previously-marked file.
  let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\)$') != -1
  if in_test_file
    call SetTestFile()
  elseif !exists("t:grb_test_file")
    return
  end
  call RunTests(t:grb_test_file . command_suffix)
endfunction

function! RunNearestTest()
  let spec_line_number = line('.')
  call RunTestFile(":" . spec_line_number)
endfunction

function! SetTestFile()
  " Set the spec file that tests will be run for.
  let t:grb_test_file=@%
endfunction

function! RunTests(filename)
  " Write the file and run tests for the given filename.
  if expand("%") != ""
    :w
  end

  " Jimdo Puppet Sondergeloet
  if filereadable("scripts/spec-runner")
    exec ":!./scripts/spec-runner " . a:filename
    return
  end

  if filereadable("Gemfile")
    let command_prefix = ":!bundle exec "
  else
    let command_prefix = ":!"
  end

  if match(a:filename, '\.feature') != -1
    exec command_prefix . "cucumber --color " . a:filename
  elseif match(a:filename, '_spec.rb') != -1
    exec command_prefix . "rspec --color " . a:filename
  elseif match(a:filename, "") != -1
    if isdirectory("features")
      exec command_prefix . "cucumber --color"
    else
      exec command_prefix . "rspec --color"
    end
  end
endfunction