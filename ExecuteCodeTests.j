library ExecuteCodeTests initializer Initialize requires ExecuteCode

  private function Test1 takes nothing returns nothing
    call BJDebugMsg("Code executed!")
  endfunction

  private function Initialize takes nothing returns nothing

    call ExecuteCode(function Test1)

  endfunction

endlibrary