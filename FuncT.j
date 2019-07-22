library FuncT
  
  //! textmacro DEFINE_ACTION_1_T takes ACCESS, TARG
    $ACCESS$ function interface Action_$TARG$ takes $TARG$ arg1 returns nothing
  //! endtextmacro

  //! textmacro DEFINE_ACTION_2_T takes ACCESS, TARG1, TARG2
    $ACCESS$ function interface Action_$TARG1$_$TARG2$ takes $TARG1$ arg1, $TARG2$ arg2 returns nothing
  //! endtextmacro

  //! textmacro DEFINE_ACTION_3_T takes ACCESS, TARG1, TARG2, TARG3
    $ACCESS$ function interface Action_$TARG1$_$TARG2$_$TARG3$ takes $TARG1$ arg1, $TARG2$ arg2, $TARG3$ arg3 returns nothing
  //! endtextmacro

  //! textmacro DEFINE_NAMED_ACTION_1_T takes ACCESS, NAME, TARG
    $ACCESS$ function interface $NAME$ takes $TARG$ arg1 returns nothing
  //! endtextmacro

  //! textmacro DEFINE_NAMED_ACTION_2_T takes ACCESS, NAME, TARG1, TARG2
    $ACCESS$ function interface $NAME$ takes $TARG1$ arg1, $TARG2$ arg2 returns nothing
  //! endtextmacro

  //! textmacro DEFINE_NAMED_ACTION_3_T takes ACCESS, NAME, TARG1, TARG2, TARG3
    $ACCESS$ function interface $NAME$ takes $TARG1$ arg1, $TARG2$ arg2, $TARG3$ arg3 returns nothing
  //! endtextmacro

  //! textmacro DEFINE_FUNC_1_T takes ACCESS, TARG, TRETURN
    $ACCESS$ function interface Func_$TARG$_$TRETURN$ takes $TARG$ arg1 returns $TRETURN$
  //! endtextmacro

  //! textmacro DEFINE_FUNC_2_T takes ACCESS, TARG1, TARG2, TRETURN
    $ACCESS$ function interface Func_$TARG1$_$TARG2$_$TRETURN$ takes $TARG1$ arg1, $TARG2$ arg2 returns $TRETURN$
  //! endtextmacro

  //! textmacro DEFINE_FUNC_3_T takes ACCESS, TARG1, TARG2, TARG3 TRETURN
    $ACCESS$ function interface Func_$TARG1$_$TARG2$_$TARG3$_$TRETURN$ takes $TARG1$ arg1, $TARG2$ arg2, $TARG3$ arg3 returns $TRETURN$
  //! endtextmacro

  //! textmacro DEFINE_NAMED_FUNC_1_T takes ACCESS, NAME, TARG, TRETURN
    $ACCESS$ function interface $NAME$ takes $TARG$ arg1 returns $TRETURN$
  //! endtextmacro

  //! textmacro DEFINE_NAMED_FUNC_2_T takes ACCESS, NAME, TARG1, TARG2, TRETURN
    $ACCESS$ function interface $NAME$ takes $TARG1$ arg1, $TARG2$ arg2 returns $TRETURN$
  //! endtextmacro

  //! textmacro DEFINE_NAMED_FUNC_3_T takes ACCESS, NAME, TARG1, TARG2, TARG3 TRETURN
    $ACCESS$ function interface $NAME$ takes $TARG1$ arg1, $TARG2$ arg2, $TARG3$ arg3 returns $TRETURN$
  //! endtextmacro

endlibrary