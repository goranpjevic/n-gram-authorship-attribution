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
  max_ngrams{(⍺=0)∨⍺>≢⍵:⍵⋄⍺↑⍵}sorted_ngrams
}

⍝ generate author models
gm←{
  mkdirsh←⎕sh'mkdir -p examples models'
  model_files←⎕sh'ls all/*'
  ⍵∘{
    (⍺ngrams⊃⎕nget⍵)(⎕csv⍠'IfExists' 'Replace')'models/',(≢'all/')↓⍵
  }¨model_files
}

⍝ attribute authorship to each of the example files based on all of the models
aa←{
  example_files←⎕sh'ls examples/*'
  model_files←⎕sh'ls models/*'
  ⎕←'example_id' 'model_id' 'equal'⍪a←↑⍵∘{
    example_ngrams example_frequencies←↓⍉⍺0ngrams⊃⎕nget⍵
    dists←{
      model_ngrams model_frequencies←↓⍉⎕csv⍵
      ⍝ calculate the distance between n and m
      model_frequencies←⍎¨model_frequencies
      all_ex_f←(example_frequencies,0)[example_ngrams⍳∪example_ngrams,model_ngrams]
      all_mo_f←(model_frequencies,0)[model_ngrams⍳∪example_ngrams,model_ngrams]
      all_ex_f eq1 all_mo_f
    }¨model_files
    min_dist_id←(≢'models/')↓⊃model_files⌷⍨⊃⍋dists
    current_id←(≢'examples/')↓⍵
    current_id(,⍥⊂,≡)min_dist_id
  }¨example_files
  ⎕←'accuracy: ',(+/÷≢),1↑⍉⌽a
}

eq1←(+/2*⍨2×-÷+)

usage←{
  ⎕←'usage:',⎕ucs 10
  ⎕←'  aa.apl [option] [args]',⎕ucs 10
  ⎕←'  options:',⎕ucs 10
  ⎕←'     generate author models:',⎕ucs 10
  ⎕←'       m [max_ngram_size] [max_ngrams] [filename]',⎕ucs 10
  ⎕←'     attribute authorship to each of the example files based on all of the models:',⎕ucs 10
  ⎕←'       a [max_ngram_size]'
}

main←{
  1=≢⍵:usage⍬
  (4=≢⍵)∧'m'=2⊃⍵:gm(⍎⍵⊃⍨⊢)¨3 4
  (3=≢⍵)∧'a'=2⊃⍵:aa⍎3⊃⍵
  usage⍬
}

main 2⎕nq#'getcommandlineargs'
