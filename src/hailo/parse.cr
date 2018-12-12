require "string_scanner"
require "./token"

module Hailo::Parse
  # words

  ALPHABET   = /(?:[\p{L}\p{M}])/
  SPACE      = /\s/
  NONSPACE   = /\S/
  DASH       = /[–-]/
  POINT      = /[.,]/
  APOSTROPHE = /['’´]/
  ELLIPSIS   = /(?:\.{2,}|…)/
  WORD_CHAR  = /#{ALPHABET}|[\d_]/
  NWORD_CHAR = /[^\s\p{L}\p{M}\d_]/
  BARE_WORD  = /#{WORD_CHAR}++/
  NON_WORD   = /#{NWORD_CHAR}++/
  CURRENCY   = /[¤¥¢£\$]/
  NUMBER     = /#{CURRENCY}?+#{POINT}\d++(?:#{POINT}\d++)*+(?:#{CURRENCY}|#{ALPHABET}++)?+|#{CURRENCY}?+\d++(?:#{POINT}\d++)*+(?:#{CURRENCY}|#{ALPHABET}++)?+(?!\d|#{ALPHABET})/
  APOST_WORD = /#{ALPHABET}++(?:#{APOSTROPHE}#{ALPHABET}++)++/
  ABBREV     = /#{ALPHABET}(?:\.#{ALPHABET})++\./
  DOTTED     = /#{BARE_WORD}?\.#{BARE_WORD}(?:\.#{BARE_WORD})*+/
  WORD_TYPES = /#{NUMBER}|#{ABBREV}|#{DOTTED}|#{APOST_WORD}|#{BARE_WORD}/
  WORD       = /#{WORD_TYPES}(?:(?:#{DASH}#{WORD_TYPES})++|#{DASH}(?!#{DASH}))?+/

  # special tokens

  TWAT_NAME    = /@[A-Za-z0-9_]+/
  EMAIL        = /[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+(?:\.[A-Za-z]{2,4})*/
  PERL_CLASS   = /(?:::\w+(?:::\w+)*|\w+(?:::\w+)+)(?:::)?|\w+::/
  ESC_SPACE    = /(?:\\ )+/
  NAME         = /(?:#{BARE_WORD}|#{ESC_SPACE})+/
  FILENAME     = /(?:#{NAME})?\.#{NAME}(?:\.#{NAME})*|#{NAME}/
  UNIX_PATH    = /\/#{FILENAME}(?:\/#{FILENAME})*\/?/
  WIN_PATH     = /#{ALPHABET}:\\#{FILENAME}(?:\\#{FILENAME})*\\?/
  PATH         = /#{UNIX_PATH}|#{WIN_PATH}/
  DATE         = /[0-9]{4}-[Ww]?[0-9]{1,2}-[0-9]{1,2}/
  TIME         = /[0-9]{1,2}:[0-9]{2}(?::[0-9]{2})?(?:[Zz]| ?(?:am|AM|pm|PM)|[-+±][0-9]{2}(?::?[0-9]{2})?)?/
  PAREN_TIME   = /\(#{TIME}\)/
  SQUARE_TIME  = /\[#{TIME}\]/
  DATETIME     = /#{DATE}[Tt]#{TIME}/
  IRC_NICK     = /<(?: |[&~]?[@%+~&])?[A-Za-z_`\-^\|\\\{\}\[\]][A-Za-z_0-9`\-^\|\\\{}\[\]]+>/
  IRC_CHAN     = /[#&+][^ \a\0\012\015,:]{1,199}/
  NUMERO       = /#[0-9]+/
  CLOSE_TAG    = /<\/(?:-|#{WORD_CHAR})+>/
  IPV4         = /[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/
  IPV6         = /(?:(?:[0-9A-Fa-f]{0,4})?:){1,7}[0-9A-Fa-f]{0,4}/
  HOST_WORD    = /#{BARE_WORD}(?:-+#{BARE_WORD})*/
  HOSTNAME     = /#{HOST_WORD}(?:\.#{HOST_WORD})*/
  URI_SCHEME   = /(?:#{HOST_WORD}\+)?#{BARE_WORD}:\/\//
  PORT         = /:[0-9]+/
  URI_EXTRA1   = /[-\d_.~$!#&'()*+,\/:;=?@\[\]]/
  URI_EXTRA2   = /[-\d_~$!#&'()*+,\/:;=?@\[\]]/
  URI_PATH     = /\/(?:(?:#{ALPHABET}+|#{URI_EXTRA1}+)*(?:#{ALPHABET}+|#{URI_EXTRA2}+))?/
  URI          = /#{URI_SCHEME}(?:#{HOSTNAME}|#{IPV4}|#{IPV6})#{PORT}?#{URI_PATH}?/
  OPT_PART     = /(?:#{ALPHABET}|\d)(?:#{ALPHABET}|[_\d])+/
  OPT_SHORT    = /-(?:#{ALPHABET}|\d)(?!#{ALPHABET}|\d)/
  OPT_LONG     = /--#{OPT_PART}(?:-#{OPT_PART})*/
  SPECIAL_WORD = /(?>#{URI}|#{OPT_SHORT}|#{OPT_LONG}|#{CLOSE_TAG}|#{IRC_NICK}|#{IRC_CHAN}|#{DATETIME}|#{DATE}|#{TIME}|#{PAREN_TIME}|#{SQUARE_TIME}|#{PERL_CLASS}|#{EMAIL}|#{TWAT_NAME}|#{PATH}|#{NUMERO})/

  RX_DASH_NEWL  = /(#{DASH})\s*\n+\s*/
  RX_NEWLINE    = /\s*\n+\s*/
  RX_SPACE      = /\s+/
  RX_NON_SPACE  = /\S+/
  RX_WORD_APOST = /#{APOSTROPHE}(?!#{ALPHABET}|#{NUMBER})/
  RX_APOSTROPHE = /#{APOSTROPHE}/
  RX_APOST      = {
    "'" => /[’´](?!#{ALPHABET}|#{NUMBER})/,
    "’" => /['´](?!#{ALPHABET}|#{NUMBER})/,
    "´" => /['’](?!#{ALPHABET}|#{NUMBER})/,
  }

  RX_TOKEN_NORMAL  = /(?P<word>#{WORD})|(?P<non_word>#{NON_WORD})/
  RX_TOKEN_SPECIAL = /(?P<special>#{SPECIAL_WORD})|#{RX_TOKEN_NORMAL}/
  RX_MIXED_CASE    = /\p{Ll}+\p{Lu}|\p{Lu}{2,}\p{Ll}|(?:\p{Lu}+#{NWORD_CHAR}+)(?<!I')(?:\p{Lu}*\p{Ll})/

  # Capitalization
  # The goal here is to catch the most common cases where a word should be
  # capitalized. We try hard to guard against capitalizing things which
  # don't look like proper words. Examples include URLs and code snippets.

  OPEN_QUOTE  = /['"‘“„«»「『‹‚]/
  CLOSE_QUOTE = /['"’“”«»」』›‘]/
  TERMINATOR  = /[?!‽]+|(?<!\.)\./
  ADDRESS     = /:/
  PUNCTUATION = /[?!‽,;.:]/
  BOUNDARY    = /#{CLOSE_QUOTE}?(?:\s*#{TERMINATOR}|#{ADDRESS})\s+#{OPEN_QUOTE}?\s*/
  LOOSE_WORD  = /#{IRC_CHAN}|#{DATETIME}|#{DATE}|#{TIME}|#{PATH}|#{NUMBER}|#{ABBREV}|#{APOST_WORD}|#{NUMERO}|#{BARE_WORD}(?:#{DASH}(?:#{WORD_TYPES}|#{BARE_WORD})|#{APOSTROPHE}(?!#{ALPHABET}|#{NUMBER}|#{APOSTROPHE})|#{DASH}(?!#{DASH}{2}))*/
  SPLIT_WORD  = /#{LOOSE_WORD}(?:\/#{LOOSE_WORD})?(?=#{PUNCTUATION}(?:\s+|$)|#{CLOSE_QUOTE}|#{TERMINATOR}|\s+|$)/

  # we want to capitalize words that come after "On example.com?"
  # or "You mean 3.2?", but not "Yes, e.g."

  DOTTED_STRICT = /#{LOOSE_WORD}(?:#{POINT}(?:\d+|#{WORD_CHAR}{2,}))?/
  WORD_STRICT   = /#{DOTTED_STRICT}(?:#{APOSTROPHE}#{DOTTED_STRICT})*/

  SEPARATOR = %{\u0008}

  RX_CAPITALIZE_FIRST  = /^\s*#{OPEN_QUOTE}?\s*\K#{SPLIT_WORD}(?=#{ELLIPSIS}|(?:(?:#{CLOSE_QUOTE}|#{TERMINATOR}|#{ADDRESS}|#{PUNCTUATION}+)?(?:\s|$)))/
  RX_CAPITALIZE_SECOND = /^#{SPLIT_WORD}(?:\s*#{TERMINATOR}|#{ADDRESS})\s+\K#{SPLIT_WORD}/
  RX_CAPITALIZE_REST_A = /(?:#{ELLIPSIS}|\s+)#{OPEN_QUOTE}?\s*#{WORD_STRICT}#{BOUNDARY}\K#{SPLIT_WORD}/
  RX_CAPITALIZE_REST_B = /#{SEPARATOR}#{WORD_STRICT}#{SEPARATOR}#{BOUNDARY}\K#{SPLIT_WORD}/
  RX_END_PARAGRAPH     = /(?:#{ELLIPSIS}|\s+|^)#{OPEN_QUOTE}?(?:#{SPLIT_WORD}(?:\.#{SPLIT_WORD})*)\K(#{CLOSE_QUOTE}?)$/
  RX_CAPITALIZE_IM     = /(?:(?:#{ELLIPSIS}|\s+)|#{OPEN_QUOTE})\Ki(?=#{APOSTROPHE}#{ALPHABET})/

  private def make_tokens(input) : Array(Token)
    tokens = Array(Token).new

    # remove line continuation dashes
    input = input.gsub(RX_DASH_NEWL, "\\1")

    scanner = StringScanner.new(input)

    got_word = false
    while !scanner.eos?
      got_word = false if scanner.skip(RX_SPACE)
      token = scanner.scan(got_word ? RX_TOKEN_NORMAL : RX_TOKEN_SPECIAL)
      break if !token

      if scanner["special"]?
        tokens << Token.new(token)
        got_word = true
      elsif scanner["word"]?
        if tokens.empty?
          token += scanner[0] if scanner.scan(RX_WORD_APOST)
        else
          last_char = tokens[-1].text[-1].to_s
          if last_char =~ RX_APOSTROPHE && scanner.scan(RX_APOST[last_char])
            token += scanner[0]
          end
        end

        if token != token.upcase && token !~ RX_MIXED_CASE
          token = token.downcase
        end

        tokens << Token.new(token)
        got_word = true
      elsif scanner["non_word"]?
        spacing = Token::Spacing::Normal

        non_space_next = scanner.check(RX_NON_SPACE)
        if got_word
          spacing = non_space_next ? Token::Spacing::Infix : Token::Spacing::Postfix
        elsif non_space_next
          spacing = Token::Spacing::Prefix
        end

        tokens << Token.new(token, spacing)
        got_word = false
      end
    end

    tokens
  end

  private def make_output(tokens) : String
    output = String.build do |str|
      tokens.each_with_index do |token, i|
        str << token.text

        # append whitespace if this is not a prefix token or infix token,
        # and this is not the last token, and the next token is not
        # a postfix/infix token
        last_i = tokens.size - 1
        if i != last_i &&
           ![Token::Spacing::Prefix, Token::Spacing::Infix].includes?(token.spacing) &&
           !(i < last_i && [Token::Spacing::Postfix, Token::Spacing::Infix].includes?(tokens[i + 1].spacing))
          str << " "
        end
      end
    end

    format_output(output)
  end

  private def format_output(text) : String
    {RX_CAPITALIZE_FIRST, RX_CAPITALIZE_SECOND}.each do |pattern|
      text = text.sub(pattern) do |match|
        match.sub(/^./) { |first| first.upcase }
      end
    end

    {RX_CAPITALIZE_REST_A, RX_CAPITALIZE_REST_B}.each do |pattern|
      text = text.gsub(pattern) do |match|
        SEPARATOR + match.sub(/^./) { |c| c.upcase } + SEPARATOR
      end
    end

    text = text.gsub(SEPARATOR, "")
    text = text.gsub(RX_END_PARAGRAPH, ".\\1")
    text = text.gsub(RX_CAPITALIZE_IM, "I")

    text
  end
end
