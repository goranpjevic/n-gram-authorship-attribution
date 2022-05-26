#!/usr/bin/env dyalogscript

⍝ get 1 to 10 character n-grams
ngrams←{
  max_ngram_size max_ngrams←⍺
  ⍝ partition input into strings of letters
  w←⍵⊆⍨⊃∨/(⍵=⍥⎕c⊢)¨⎕a
  ⍝ get n-grams of a word
  ng←(⊢,/(' '⍴⍨¯1+⊢),⍨' ',⊣)
  ⍝ get n-grams of all words of sizes 1 to 10
  n←~∘' '¨~∘' '⊃,/,w∘.ng⍳max_ngram_size
  ⍝ sort all n-grams by their frequency
  sorted_ngrams←⍉↑((⊂⍒f)⌷⊢)¨(∪n)(f←(≢⊢)⌸n)
  ⍝ get max_ngrams n-grams
  max_ngrams{⍺≤≢⍵:⍺↑⍵⋄⍵}sorted_ngrams
}

⍝ generate author models
gm←{
  mkdirsh←⎕sh'mkdir -p examples models'
  i←1↓⎕csv⍵
  ⍝ get all unique ids
  uids←∪,ids←⍎¨1↑⍉i
  ⍺∘{
    content←⊃∘⌽¨(,ids=⍵)/↓i
    example←1↑content
    training_model←⊃,/1↓content
    example_out←example⎕nput('examples/',⍕⍵)1
    model_out←(⍺ngrams training_model)(⎕csv⍠'IfExists' 'Replace')'models/',⍕⍵
  }¨uids
}

usage←{
  ⎕←'usage:',⎕ucs 10
  ⎕←'  aa.apl [option] [args]',⎕ucs 10
  ⎕←'  options:'
  ⎕←'    m [max_ngram_size] [max_ngrams] [filename]'
}

main←{
  5≠≢⍵:usage⍬
  'm'=2⊃⍵:((⍎⍵⊃⍨⊢)¨3 4)gm 5⊃⍵
}

main 2⎕nq#'getcommandlineargs'
