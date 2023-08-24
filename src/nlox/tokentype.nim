type
  TokenType* = enum
    ## Enumerator of all possible token types
    # Single-character tokens.
    LeftParen,    # (
    RightParen,   # )
    LeftBrace,    # {
    RightBrace,   # }
    Comma,        # ,
    Dot,          # .
    Minus,        # -
    Plus,         # +
    Semicolon,    # ;
    Slash,        # /
    Star,         # *
    # One or two character tokens.
    Bang,         # !
    BangEqual,    # !=
    Equal,        # =
    EqualEqual,   # ==
    Greater,      # >
    GreaterEqual, # >=
    Less,         # <
    LessEqual,    # <=
    # Literals.
    Identifier,   # [A-Z_a-z][0-9A-Z_a-z]*
    String,       # "string" | ""
    Number,       # 123 | 123.0
    # Keywords.
    And,          # and
    Class,        # class
    Else,         # else
    False,        # false
    Fun,          # fun
    For,          # for
    If,           # if
    Nil,          # nil
    Or,           # or
    Print,        # print
    Return,       # return
    Super,        # super
    This,         # this
    True,         # true
    Var,          # var
    While,        # while

    Eof           # End-of-file
