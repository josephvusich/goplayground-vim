function! s:playground(bang)
  if !executable('curl')
    echoerr "install curl command"
    return
  endif
  echon 'Compiling and running...'
  let res = webapi#http#post('https://play.golang.org/compile', {"version": 2, "body": join(getline(1, line('$')), "\n"), "withVet": v:true})
  let obj = webapi#json#decode(res.content)
  if has_key(obj, 'Errors') && len(obj.Errors)
    echohl WarningMsg | echo obj.Errors | echohl None
  elseif has_key(obj, 'Events')
    for line in obj.Events
      if line.Kind == "stdout"
        echo line.Message
      else
        echohl WarningMsg | echo line.Message | echohl None
      endif
    endfor
  else
    echohl WarningMsg | echo 'Unexpected response' | echohl None
    echon 'Keys:'
    for k in keys(obj)
      echo k
    endfor
  endif
endfunction

command! -buffer -bang Playground :call s:playground("<bang>")
nnoremap <buffer> <localleader>e :Playground<cr>
