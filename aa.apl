#!/usr/bin/env dyalogscript

⍝ get 1 to 'max_ngram_size' character n-grams
ngrams←{
  max_ngram_size max_ngrams←⍺
  ⍝ partition input into strings of letters
  w←⍵⊆⍨⊃∨/(⍵=⍥⎕c⊢)¨⎕a
  ⍝ get n-grams of a word
  ng←(⊢,/(' '⍴⍨¯1+⊢),⍨' ',⊣)
  ⍝ get n-grams of all words of sizes 1 to 'max_ngram_size'
  n←~∘' '¨~∘' '⊃,/,w∘.ng⍳max_ngram_size
  ⍝ sort all n-grams by their frequency
  sorted_ngrams←⍉↑((⊂⍒f)⌷⊢)¨(∪n)(15⍕¨f←{⍵÷⍥≢n}⌸n)
  ⍝ get max_ngrams n-grams
  max_ngrams{(⍺=0)∨⍺>≢⍵:⍵⋄⍺↑⍵}sorted_ngrams
}

⍝ generate author models
gm←{
  corpus_dir models_dir←⍺
  mkdirsh←⎕sh'mkdir -p ',models_dir
  model_files←⎕sh'ls ',corpus_dir,'/*'
  ⍵∘{
    (⍺ngrams⊃⎕nget⍵)(⎕csv⍠'IfExists' 'Replace')models_dir,'/',(1+≢corpus_dir)↓⍵
  }¨model_files
}

⍝ attribute authorship to each of the example files based on all of the models
aa←{
  eq_id examples_dir models_dir←⍺
  example_files←⎕sh'ls ',examples_dir,'/*'
  model_files←⎕sh'ls ',models_dir,'/*'
  eq←⍎⊃'eq1' 'eq2' 'eq3'[⍎eq_id]
  ⎕←'example_id' 'model_id' 'equal'⍪a←↑⍵∘{
    example_ngrams example_frequencies←↓⍉⍺0ngrams⊃⎕nget⍵
    example_frequencies←⍎¨example_frequencies
    dists←{
      model_ngrams model_frequencies←↓⍉⎕csv⍵
      ⍝ calculate the distance between n and m
      model_frequencies←⍎¨model_frequencies
      all_ngrams←∪example_ngrams,model_ngrams
      all_ex_f←(example_frequencies,0)[example_ngrams⍳all_ngrams]
      all_mo_f←(model_frequencies,0)[model_ngrams⍳all_ngrams]
      all_ex_f eq all_mo_f
    }¨model_files
    min_dist_id←(1+≢models_dir)↓⊃model_files⌷⍨⊃⍋dists
    current_id←(1+≢examples_dir)↓⍵
    current_id(,⍥⊂,≡)min_dist_id
  }¨example_files
  ⎕←'accuracy: ',(+/÷≢),1↑⍉⌽a
}

⍝ distance equations
eq1←+/2*⍨-
eq2←+/2*⍨2×-÷+
eq3←+/|⍤-

usage←{
  ⎕←'usage:',⎕ucs 10
  ⎕←'  aa.apl [option] [args]',⎕ucs 10
  ⎕←'  options:',⎕ucs 10
  ⎕←'     generate author models:',⎕ucs 10
  ⎕←'       m [max_ngram_size] [max_ngrams] [corpus_dir] [models_dir]',⎕ucs 10
  ⎕←'     attribute authorship to each of the example files based on all of the models:',⎕ucs 10
  ⎕←'       a [max_ngram_size] [equation_id] [examples_dir] [models_dir]'
}

main←{
  1=≢⍵:usage⍬
  (6=≢⍵)∧'m'=2⊃⍵:(4↓⍵)gm(⍎⍵⊃⍨⊢)¨3 4
  (6=≢⍵)∧'a'=2⊃⍵:(4↓⍵)aa⍎3⊃⍵
  usage⍬
}

main 2⎕nq#'getcommandlineargs'
