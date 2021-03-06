module Hailo::Lists
  DEFAULT_SWAP_TOKENS = Hash{
    "dislike" => "like",
    "hate" => "hate",
    "i" => "you",
    "i'd" => "you'd",
    "i'll" => "i'll",
    "i'm" => "you're",
    "i've" => "you've",
    "like" => "dislike",
    "me" => "you",
    "my" => "your",
    "mine" => "yours",
    "myself" => "yourself",
    "yes" => "no",
    "why" => "because",
  }

  DEFAULT_BAN_TOKENS = Set{
    "a",
    "ability",
    "able",
    "about",
    "absolute",
    "absolutely",
    "across",
    "actual",
    "actually",
    "after",
    "afternoon",
    "again",
    "against",
    "ago",
    "agree",
    "all",
    "almost",
    "along",
    "already",
    "although",
    "always",
    "am",
    "an",
    "and",
    "another",
    "any",
    "anyhow",
    "anything",
    "anyway",
    "are",
    "aren't",
    "around",
    "as",
    "at",
    "away",
    "back",
    "bad",
    "be",
    "been",
    "before",
    "behind",
    "being",
    "believe",
    "belong",
    "best",
    "better",
    "between",
    "big",
    "bigger",
    "biggest",
    "bit",
    "both",
    "buddy",
    "but",
    "by",
    "call",
    "called",
    "calling",
    "came",
    "can",
    "can't",
    "cannot",
    "care",
    "caring",
    "case",
    "catch",
    "caught",
    "certain",
    "certainly",
    "change",
    "close",
    "closer",
    "come",
    "coming",
    "common",
    "constant",
    "constantly",
    "could",
    "current",
    "day",
    "days",
    "derived",
    "describe",
    "describes",
    "determine",
    "determines",
    "did",
    "didn't",
    "do",
    "does",
    "doesn't",
    "doing",
    "don't",
    "done",
    "doubt",
    "down",
    "each",
    "earlier",
    "early",
    "else",
    "enjoy",
    "especially",
    "even",
    "ever",
    "every",
    "everybody",
    "everyone",
    "everything",
    "fact",
    "fair",
    "fairly",
    "far",
    "fellow",
    "few",
    "find",
    "fine",
    "for",
    "form",
    "found",
    "from",
    "full",
    "further",
    "gave",
    "get",
    "getting",
    "give",
    "given",
    "giving",
    "go",
    "going",
    "gone",
    "good",
    "got",
    "gotten",
    "great",
    "had",
    "has",
    "hasn't",
    "have",
    "haven't",
    "having",
    "held",
    "here",
    "high",
    "hold",
    "holding",
    "how",
    "if",
    "in",
    "indeed",
    "inside",
    "instead",
    "into",
    "is",
    "isn't",
    "it",
    "it's",
    "its",
    "just",
    "keep",
    "kind",
    "knew",
    "know",
    "known",
    "large",
    "larger",
    "largets",
    "last",
    "late",
    "later",
    "least",
    "less",
    "let",
    "let's",
    "level",
    "likes",
    "little",
    "long",
    "longer",
    "look",
    "looked",
    "looking",
    "looks",
    "low",
    "made",
    "make",
    "making",
    "many",
    "mate",
    "may",
    "maybe",
    "mean",
    "meet",
    "mention",
    "mere",
    "might",
    "moment",
    "more",
    "morning",
    "most",
    "move",
    "much",
    "must",
    "near",
    "nearer",
    "never",
    "next",
    "nice",
    "nobody",
    "none",
    "noon",
    "noone",
    "not",
    "note",
    "nothing",
    "now",
    "obvious",
    "of",
    "off",
    "on",
    "once",
    "only",
    "onto",
    "opinion",
    "or",
    "other",
    "our",
    "out",
    "over",
    "own",
    "part",
    "particular",
    "particularly",
    "perhaps",
    "person",
    "piece",
    "place",
    "pleasant",
    "please",
    "popular",
    "prefer",
    "pretty",
    "put",
    "quite",
    "real",
    "really",
    "receive",
    "received",
    "recent",
    "recently",
    "related",
    "result",
    "resulting",
    "results",
    "said",
    "same",
    "saw",
    "say",
    "saying",
    "see",
    "seem",
    "seemed",
    "seems",
    "seen",
    "seldom",
    "sense",
    "set",
    "several",
    "shall",
    "short",
    "shorter",
    "should",
    "show",
    "shows",
    "simple",
    "simply",
    "small",
    "so",
    "some",
    "someone",
    "something",
    "sometime",
    "sometimes",
    "somewhere",
    "sort",
    "sorts",
    "spend",
    "spent",
    "still",
    "stuff",
    "such",
    "suggest",
    "suggestion",
    "suppose",
    "sure",
    "surely",
    "surround",
    "surrounds",
    "take",
    "taken",
    "taking",
    "tell",
    "than",
    "thank",
    "thanks",
    "that",
    "that's",
    "thats",
    "the",
    "their",
    "them",
    "then",
    "there",
    "therefore",
    "these",
    "they",
    "thing",
    "things",
    "this",
    "those",
    "though",
    "thoughts",
    "thouroughly",
    "through",
    "tiny",
    "to",
    "today",
    "together",
    "told",
    "tomorrow",
    "too",
    "total",
    "totally",
    "touch",
    "try",
    "twice",
    "under",
    "understand",
    "understood",
    "until",
    "up",
    "us",
    "used",
    "using",
    "usually",
    "various",
    "very",
    "want",
    "wanted",
    "wants",
    "was",
    "watch",
    "way",
    "ways",
    "we",
    "we're",
    "well",
    "went",
    "were",
    "what",
    "what's",
    "whatever",
    "whats",
    "when",
    "where",
    "where's",
    "which",
    "while",
    "whilst",
    "who",
    "who's",
    "whom",
    "will",
    "wish",
    "with",
    "within",
    "wonder",
    "wonderful",
    "worse",
    "worst",
    "would",
    "wrong",
    "yesterday",
    "yet",
  }

  private def process_swap_tokens(token_map) : Hash(String, String)
    swap_tokens = Hash(String, String).new
    token_map.each do |a, b|
      swap_tokens[a] = b
      swap_tokens[b] = a
      swap_tokens[a.upcase] = b.upcase
      swap_tokens[b.upcase] = a.upcase
    end

    swap_tokens
  end

  private def process_ban_tokens(tokens) : Set(String)
    ban_tokens = Set(String).new

    tokens.each do |token|
      ban_tokens << token
      ban_tokens << token.upcase
    end

    ban_tokens
  end

  private def swap_token(text) : String?
    @swap_tokens[text]?
  end

  private def token_banned?(text) : Bool
    @ban_tokens.includes? text
  end
end
