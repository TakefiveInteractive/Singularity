#(set! paper-alist (cons '("my size" . (cons (* 10 in) (* 1 in))) paper-alist))
#(set-default-paper-size "my size")

\paper {
  left-margin = 0
  top-margin = 0
  right-margin = 0
  bottom-margin = 0
}

\header {
  tagline = ""  % removed 
}

musicOne = \absolute {
  \clef treble
     g'4 a'4 b'4 c''4 d''1 r1
}
verseOne = \lyricmode {
  要 是 能 重 来 我 要 选 李 白
}
\score {
  <<
    \new Voice = "one" {
      \time 4/4
      \musicOne
    }
    \new Lyrics \lyricsto "one" {
      \verseOne
    }
  >>
}

\version "2.18.2"
