require "./spec_helper"

include Hailo::Parse

record TokenTest,
  input : String,
  tokens : Array(String),
  output : String

TOKEN_TESTS = [
  TokenTest.new(
    %{ " why hello there. «yes». "foo is a bar", e.g. bla ... yes},
    %w(" why hello there . « yes ». " foo is a bar ", e.g. bla ... yes),
    %{" Why hello there. «Yes». "Foo is a bar", e.g. bla ... yes.},
  ),
  TokenTest.new(
    %{someone: how're you?},
    %w(someone : how're you ?),
    %{Someone: How're you?},
  ),
  TokenTest.new(
    %{what?! well...},
    %w(what ?! well ...),
    %{What?! Well...},
  ),
  TokenTest.new(
    %{hello. you: what are you doing?},
    %w(hello . you : what are you doing ?),
    %{Hello. You: What are you doing?},
  ),
  TokenTest.new(
    %{foo: foo: foo: what are you doing?},
    %w(foo : foo : foo : what are you doing ?),
    %{Foo: Foo: Foo: What are you doing?},
  ),
  TokenTest.new(
    %{I'm talking about this key:value thing},
    %w{i'm talking about this key : value thing},
    %{I'm talking about this key:value thing.},
  ),
  TokenTest.new(
    %{what? but that's impossible},
    %w{what ? but that's impossible},
    %{What? But that's impossible.},
  ),
  TokenTest.new(
    %{on example.com? yes},
    %w{on example.com ? yes},
    %{On example.com? Yes.},
  ),
  TokenTest.new(
    %{pi is 3.14, well, almost},
    %w{pi is 3.14 , well , almost},
    %{Pi is 3.14, well, almost.},
  ),
  TokenTest.new(
    %{foo 0.40 bar or .40 bar bla 0,40 foo ,40},
    %w{foo 0.40 bar or .40 bar bla 0,40 foo ,40},
    %{Foo 0.40 bar or .40 bar bla 0,40 foo ,40.},
  ),
  TokenTest.new(
    %{sá ''karlkyns'' aðili í [[hjónaband]]i tveggja lesbía?},
    %w{sá '' karlkyns '' aðili í [[ hjónaband ]] i tveggja lesbía ?},
    %{Sá ''karlkyns'' aðili í [[hjónaband]]i tveggja lesbía?},
  ),
  TokenTest.new(
    %{you mean i've got 3,14? yes},
    %w{you mean i've got 3,14 ? yes},
    %{You mean I've got 3,14? Yes.},
  ),
  TokenTest.new(
    %{Pretty girl like her "peak". oh and you’re touching yourself},
    %w{pretty girl like her " peak ". oh and you’re touching yourself},
    %{Pretty girl like her "peak". Oh and you’re touching yourself.},
  ),
  TokenTest.new(
    %{http://foo.BAR/bAz},
    %w{http://foo.BAR/bAz},
    %{http://foo.BAR/bAz},
  ),
  TokenTest.new(
    %{http://www.example.com/some/path?funny**!(),,:;@=&=},
    %w{http://www.example.com/some/path?funny**!(),,:;@=&=},
    %{http://www.example.com/some/path?funny**!(),,:;@=&=},
  ),
  TokenTest.new(
    %{svn+ssh://svn.wikimedia.org/svnroot/mediawiki},
    %w{svn+ssh://svn.wikimedia.org/svnroot/mediawiki},
    %{svn+ssh://svn.wikimedia.org/svnroot/mediawiki},
  ),
  TokenTest.new(
    %{foo bar baz. i said i'll do this},
    %w{foo bar baz . i said i'll do this},
    %{Foo bar baz. I said I'll do this.},
  ),
  TokenTest.new(
    %{talking about i&34324 yes},
    %w{talking about i & 34324 yes},
    %{Talking about i&34324 yes.},
  ),
  TokenTest.new(
    %{talking about i},
    %w{talking about i},
    %{Talking about i.},
  ),
  TokenTest.new(
    %{none, as most animals do, I love conservapedia.},
    %w{none , as most animals do , I love conservapedia .},
    %{None, as most animals do, I love conservapedia.},
  ),
  TokenTest.new(
    %{hm...},
    %w{hm ...},
    %{Hm...},
  ),
  TokenTest.new(
    %{anti-scientology demonstration in london? hella-cool},
    %w{anti-scientology demonstration in london ? hella-cool},
    %{Anti-scientology demonstration in london? Hella-cool.},
  ),
  TokenTest.new(
    %{This. compound-words are cool},
    %w{this . compound-words are cool},
    %{This. Compound-words are cool.},
  ),
  TokenTest.new(
    %{Foo. Compound-word},
    %w{foo . compound-word},
    %{Foo. Compound-word.},
  ),
  TokenTest.new(
    %{one},
    %w{one},
    %{One.},
  ),
  TokenTest.new(
    %{cpanm is a true "religion"},
    %w{cpanm is a true " religion "},
    %{Cpanm is a true "religion."},
  ),
  TokenTest.new(
    %{cpanm is a true "anti-religion"},
    %w{cpanm is a true " anti-religion "},
    %{Cpanm is a true "anti-religion."},
  ),
  TokenTest.new(
    %{Maps to weekends/holidays},
    %w{maps to weekends / holidays},
    %{Maps to weekends/holidays.},
  ),
  TokenTest.new(
    %{s/foo/bar},
    %w{s / foo / bar},
    %{s/foo/bar},
  ),
  TokenTest.new(
    %{Where did I go? http://foo.bar/},
    %w{where did I go ? http://foo.bar/},
    %{Where did I go? http://foo.bar/},
  ),
  TokenTest.new(
    %{What did I do? s/foo/bar/},
    %w{what did I do ? s / foo / bar /},
    %{What did I do? s/foo/bar/},
  ),
  TokenTest.new(
    %{I called foo() and foo(bar)},
    %w{I called foo () and foo ( bar )},
    %{I called foo() and foo(bar)},
  ),
  TokenTest.new(
    %{foo() is a function},
    %w{foo () is a function},
    %{foo() is a function.},
  ),
  TokenTest.new(
    %{the symbol : and the symbol /},
    %w{the symbol : and the symbol /},
    %{The symbol : and the symbol /},
  ),
  TokenTest.new(
    %{.com bubble},
    %w{.com bubble},
    %{.com bubble.},
  ),
  TokenTest.new(
    %{við vorum þar. í norður- eða vesturhlutanum},
    %w{við vorum þar . í norður- eða vesturhlutanum},
    %{Við vorum þar. Í norður- eða vesturhlutanum.},
  ),
  TokenTest.new(
    %{i'm talking about -postfix. yeah},
    %w{i'm talking about - postfix . yeah},
    %{I'm talking about -postfix. yeah.},
  ),
  TokenTest.new(
    %{But..what about me? but...no},
    %w{but .. what about me ? but ... no},
    %{But..what about me? But...no.},
  ),
  TokenTest.new(
    %{For foo'345 'foo' bar},
    %w{for foo ' 345 ' foo ' bar},
    %{For foo'345 'foo' bar.},
  ),
  TokenTest.new(
    %{loves2spooge},
    %w{loves2spooge},
    %{Loves2spooge.},
  ),
  TokenTest.new(
    %{she´ll be doing it now},
    %w{she´ll be doing it now},
    %{She´ll be doing it now.},
  ),
  TokenTest.new(
    %{CPAN upload: Crypt-Rijndael-MySQL-0.02 by SATOH},
    %w{CPAN upload : Crypt-Rijndael-MySQL-0.02 by SATOH},
    %{CPAN upload: Crypt-Rijndael-MySQL-0.02 by SATOH.},
  ),
  TokenTest.new(
    %{I use a resolution of 800x600 on my computer},
    %w{I use a resolution of 800x600 on my computer},
    %{I use a resolution of 800x600 on my computer.},
  ),
  TokenTest.new(
    %{WOAH 3D},
    %w{WOAH 3D},
    %{WOAH 3D.},
  ),
  TokenTest.new(
    %{jarl sounds like yankee negro-lovers. britain was even into old men.},
    %w{jarl sounds like yankee negro-lovers . britain was even into old men .},
    %{Jarl sounds like yankee negro-lovers. Britain was even into old men.},
  ),
  TokenTest.new(
    %{just look at http://beint.lýðræði.is does it turn tumi metrosexual},
    %w{just look at http://beint.lýðræði.is does it turn tumi metrosexual},
    %{Just look at http://beint.lýðræði.is does it turn tumi metrosexual.},
  ),
  TokenTest.new(
    %{du: Invalid option --^},
    %w{du : invalid option --^},
    %{Du: Invalid option --^},
  ),
  TokenTest.new(
    %{4.1GB downloaded, 95GB uploaded},
    %w{4.1GB downloaded , 95GB uploaded},
    %{4.1GB downloaded, 95GB uploaded.},
  ),
  TokenTest.new(
    %{Use <http://google.com> as your homepage},
    %w{use < http://google.com > as your homepage},
    %{Use <http://google.com> as your homepage.},
  ),
  TokenTest.new(
    %{Foo http://æðislegt.is,>>> bar},
    %w{foo http://æðislegt.is ,>>> bar},
    %{Foo http://æðislegt.is,>>> bar.},
  ),
  TokenTest.new(
    %{Foo http://æðislegt.is,$ bar},
    %w{foo http://æðislegt.is ,$ bar},
    %{Foo http://æðislegt.is,$ bar.},
  ),
  TokenTest.new(
    %{http://google.is/search?q="stiklað+á+stóru"},
    %w{http://google.is/search?q= " stiklað + á + stóru "},
    %{http://google.is/search?q="stiklað+á+stóru"},
  ),
  TokenTest.new(
    %{this is STARGΛ̊TE},
    %w{this is STARGΛ̊TE},
    %{This is STARGΛ̊TE.},
  ),
  TokenTest.new(
    %{tumi.st@gmail.com tumi.st@gmail.com tumi.st@gmail.com},
    %w{tumi.st@gmail.com tumi.st@gmail.com tumi.st@gmail.com},
    %{tumi.st@gmail.com tumi.st@gmail.com tumi.st@gmail.com},
  ),
  TokenTest.new(
    %{tumi@foo},
    %w{tumi@foo},
    %{tumi@foo},
  ),
  TokenTest.new(
    %{tumi@foo.co.uk},
    %w{tumi@foo.co.uk},
    %{tumi@foo.co.uk},
  ),
  TokenTest.new(
    %{e.g. the river},
    %w{e.g. the river},
    %{E.g. the river.},
  ),
  TokenTest.new(
    %{dong–licking is a really valuable book.},
    %w{dong–licking is a really valuable book .},
    %{Dong–licking is a really valuable book.},
  ),
  TokenTest.new(
    %{taka úr sources.list},
    %w{taka úr sources.list},
    %{Taka úr sources.list.},
  ),
  TokenTest.new(
    %{Huh? what? i mean what is your wife a...goer...eh? know what a dude last night...},
    %w{huh ? what ? i mean what is your wife a ... goer ... eh ? know what a dude last night ...},
    %{Huh? What? I mean what is your wife a...goer...eh? Know what a dude last night...},
  ),
  TokenTest.new(
    %{neeeigh!},
    %w{neeeigh !},
    %{Neeeigh!},
  ),
  TokenTest.new(
    %{neeeigh.},
    %w{neeeigh .},
    %{Neeeigh.},
  ),
  TokenTest.new(
    %{odin-: foo-- # blah. odin-: yes},
    %w{odin- : foo -- # blah . odin- : yes},
    %{Odin-: Foo-- # blah. Odin-: Yes.},
  ),
  TokenTest.new(
    %{struttin' that nigga},
    %w{struttin' that nigga},
    %{Struttin' that nigga.},
  ),
  TokenTest.new(
    %{"maybe" and A better deal. "would" still need my coffee with tea.},
    %w{" maybe " and A better deal . " would " still need my coffee with tea .},
    %{"Maybe" and A better deal. "Would" still need my coffee with tea.},
  ),
  TokenTest.new(
    %{This Acme::POE::Tree module is neat. Acme::POE::Tree},
    %w{this Acme::POE::Tree module is neat . Acme::POE::Tree},
    %{This Acme::POE::Tree module is neat. Acme::POE::Tree},
  ),
  TokenTest.new(
    %{I use POE-Component-IRC},
    %w{I use POE-Component-IRC},
    %{I use POE-Component-IRC.},
  ),
  TokenTest.new(
    %{You know, 4-3 equals 1},
    %w{you know , 4-3 equals 1},
    %{You know, 4-3 equals 1.},
  ),
  TokenTest.new(
    %{moo-5 moo-5-moo moo_5},
    %w{moo-5 moo-5-moo moo_5},
    %{Moo-5 moo-5-moo moo_5.},
  ),
  TokenTest.new(
    %{::Class Class:: ::Foo::Bar Foo::Bar:: Foo::Bar},
    %w{::Class Class:: ::Foo::Bar Foo::Bar:: Foo::Bar},
    %{::Class Class:: ::Foo::Bar Foo::Bar:: Foo::Bar},
  ),
  TokenTest.new(
    %{It's as simple as C-u C-c C-t C-t t},
    %w{it's as simple as C-u C-c C-t C-t t},
    %{It's as simple as C-u C-c C-t C-t t.},
  ),
  TokenTest.new(
    %{foo----------},
    %w{foo ----------},
    %{foo----------},
  ),
  TokenTest.new(
    %{HE'S A NIGGER! HE'S A... wait},
    %w{HE'S A NIGGER ! HE'S A ... wait},
    %{HE'S A NIGGER! HE'S A... wait.},
  ),
  TokenTest.new(
    %{I use\nPOE-Component-IRC},
    %w{I use POE-Component-IRC},
    %{I use POE-Component-IRC.},
  ),
  TokenTest.new(
    %{I use POE-Component- \n IRC},
    %w{I use POE-Component-IRC},
    %{I use POE-Component-IRC.},
  ),
  TokenTest.new(
    %{I wrote theres_no_place_like_home.ly. And then some.},
    %w{I wrote theres_no_place_like_home.ly . and then some .},
    %{I wrote theres_no_place_like_home.ly. And then some.},
  ),
  TokenTest.new(
    %{The file is /hlagh/bar/foo.txt. Just read it.},
    %w{the file is /hlagh/bar/foo.txt . just read it .},
    %{The file is /hlagh/bar/foo.txt. Just read it.},
  ),
  TokenTest.new(
    %{The file is C:\\hlagh\\bar\\foo.txt. Just read it.},
    %w{the file is C:\hlagh\bar\foo.txt . just read it .},
    %{The file is C:\\hlagh\\bar\\foo.txt. Just read it.},
  ),
  TokenTest.new(
    %{2011-05-05 22:55 22:55Z 2011-05-05T22:55Z 2011-W18-4 2011-125 12:00±05:00 22:55 PM},
    %w{2011-05-05 22:55 22:55Z 2011-05-05T22:55Z 2011-W18-4 2011-125 12:00±05:00} + [%{22:55 PM}],
    %{2011-05-05 22:55 22:55Z 2011-05-05T22:55Z 2011-W18-4 2011-125 12:00±05:00 22:55 PM.},
  ),
  TokenTest.new(
    %{<@literal> oh hi < literal> what is going on?},
    %w{<@literal> oh hi} + [%{< literal>}] + %w{what is going on ?},
    %{<@literal> oh hi < literal> what is going on?},
  ),
  TokenTest.new(
    %{It costs $.50, no, wait, it cost $2.50... or 50¢},
    %w{it costs $.50 , no , wait , it cost $2.50 ... or 50¢},
    %{It costs $.50, no, wait, it cost $2.50... or 50¢.},
  ),
  TokenTest.new(
    %{10pt or 12em or 15cm},
    %w{10pt or 12em or 15cm},
    %{10pt or 12em or 15cm.},
  ),
  TokenTest.new(
    %{failo is #1},
    %w{failo is #1},
    %{Failo is #1.},
  ),
  TokenTest.new(
    %{We are in #perl},
    %w{we are in #perl},
    %{We are in #perl.},
  ),
  TokenTest.new(
    %{</foo>},
    %w{</foo>},
    %{</foo>},
  ),
  TokenTest.new(
    %{ATMs in Baltimore},
    %w{ATMs in baltimore},
    %{ATMs in baltimore.},
  ),
  TokenTest.new(
    %{http://fchan.us/src/ah_1271559748395.greenroon_goldfuchs_seite.jpg},
    %w{http://fchan.us/src/ah_1271559748395.greenroon_goldfuchs_seite.jpg},
    %{http://fchan.us/src/ah_1271559748395.greenroon_goldfuchs_seite.jpg},
  ),
  TokenTest.new(
    %{http://leech.nix.is/torrent/complete/BBC.Horizon.2010.What.Makes.a.Genius.HDTV.x264.AC3.MVGroup.org.mkv},
    %w{http://leech.nix.is/torrent/complete/BBC.Horizon.2010.What.Makes.a.Genius.HDTV.x264.AC3.MVGroup.org.mkv},
    %{http://leech.nix.is/torrent/complete/BBC.Horizon.2010.What.Makes.a.Genius.HDTV.x264.AC3.MVGroup.org.mkv},
  ),
  TokenTest.new(
    %{http://www.youtube.com/watch?v=swZdt4_IM8E&feature=autoplay&list=PL2C15A44F11B16E05&index=64&playnext=6},
    %w{http://www.youtube.com/watch?v=swZdt4_IM8E&feature=autoplay&list=PL2C15A44F11B16E05&index=64&playnext=6},
    %{http://www.youtube.com/watch?v=swZdt4_IM8E&feature=autoplay&list=PL2C15A44F11B16E05&index=64&playnext=6},
  ),
  TokenTest.new(
    %{/Creative/Writing/Notebook/Illustrations/itsatrap.jpg},
    %w{/Creative/Writing/Notebook/Illustrations/itsatrap.jpg},
    %{/Creative/Writing/Notebook/Illustrations/itsatrap.jpg.},
  ),
  TokenTest.new(
    %{earle: [2008] The Sun And The Neon Light/06-booka_shade-redemption.mp3 is also kick ass},
    %w{earle : [ 2008 ] the sun and the neon light / 06-booka_shade-redemption.mp3 is also kick ass},
    %{Earle: [2008] the sun and the neon light/06-booka_shade-redemption.mp3 is also kick ass.},
  ),
  TokenTest.new(
    %{http://pictures.mastermarf.com/blog/2008/081206-love-this-thread.jpg},
    %w{http://pictures.mastermarf.com/blog/2008/081206-love-this-thread.jpg},
    %{http://pictures.mastermarf.com/blog/2008/081206-love-this-thread.jpg},
  ),
  TokenTest.new(
    %{(10:27:51 PM) Benedikt Kristinsson: hvað er IMAP?},
    ["(10:27:51 PM)"] + %w{benedikt kristinsson : hvað er IMAP ?},
    %{(10:27:51 PM) benedikt kristinsson: Hvað er IMAP?},
  ),
  TokenTest.new(
    %{go to http://google.com, then search},
    %w{go to http://google.com , then search},
    %{Go to http://google.com, then search.},
  ),
  TokenTest.new(
    %{http://example.com: it sucks},
    %w{http://example.com : it sucks},
    %{http://example.com: it sucks.},
  ),
  TokenTest.new(
    %{[go here](http://example.com)},
    %w{[ go here ]( http://example.com )},
    %{[go here](http://example.com)},
  ),
  TokenTest.new(
    %{Http://www.bbspot.com/news/2008/colbert_perkins052808.html},
    %w{Http://www.bbspot.com/news/2008/colbert_perkins052808.html},
    %{Http://www.bbspot.com/news/2008/colbert_perkins052808.html},
  ),
  TokenTest.new(
    %{Http://farm4.static.flickr.com/photos/jonny5/1986909659/sizes/o},
    %w{Http://farm4.static.flickr.com/photos/jonny5/1986909659/sizes/o},
    %{Http://farm4.static.flickr.com/photos/jonny5/1986909659/sizes/o},
  ),
  TokenTest.new(
    %{--foo -d --bar-baz},
    %w{--foo -d --bar-baz},
    %{--foo -d --bar-baz},
  ),
]

describe "Tokenizer" do
  it "Test should follow the spec" do
    TOKEN_TESTS.each do |test|
      tokens = make_tokens(test.input)
      tokens_text = tokens.map(&.text)
      tokens_text.should eq test.tokens
      output = make_output(tokens)
      output.should eq test.output
    end
  end
end
