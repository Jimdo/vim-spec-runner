if exists("g:spec_runner_loaded")
  finish
endif
let g:spec_runner_loaded = 1

command RunTestFile    call <SID>RunTestFile()
command RunNearestTest call <SID>RunNearestTest()
command RunAllTests    call <SID>RunTests('')

if !hasmapto(':RunTestFile<cr>')
  nnoremap <leader>t :RunTestFile<cr>
endif

if !hasmapto(':RunNearestTest<cr>')
  nnoremap <leader>T :RunNearestTest<cr>
endif

if !hasmapto(':RunAllTests<cr>')
  nnoremap <leader>a :RunAllTests<cr>
endif

function s:RunTestFile(...)
  if a:0
    let command_suffix = a:1
  else
    let command_suffix = ""
  endif

  " Run the tests for the previously-marked file.
  let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\)$') != -1
  if in_test_file
    call s:SetTestFile(command_suffix)
  elseif !exists("t:grb_test_file")
    return
  end
  call s:RunTests(t:grb_test_file)
endfunction

function s:RunNearestTest()
  let spec_line_number = line('.')
  call s:RunTestFile(":" . spec_line_number)
endfunction

function s:SetTestFile(command_suffix)
  " Set the spec file that tests will be run for.
  let t:grb_test_file=@% . a:command_suffix
endfunction

function s:RunTests(filename)
  " Write the file and run tests for the given filename.
  if expand("%") != ""
    :w
  end

  " First choice: project-specific test script
  if filereadable("script/test")
    exec ":!./script/test " . a:filename
    return
  elseif filereadable("scripts/test")
    exec ":!./scripts/test " . a:filename
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
