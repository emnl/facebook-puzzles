require 'levenshtein'

#
# Diffinder is created by Emanuel Andersson 2010
# It is release under the MIT License
# Like it? Please send pictures of cute puppies to emanuel@imemanuel.com
# Source can be found at github.com/eandersson
#
# TODO:
#   * getApproxWords cleanup
#   * Make usable for real use
#   * Smoother method- and variable names
#   * etc...
#

class Diffinder

  # Level of match-precision, heigher is faster but less accurate
  # 1 == 100%, ie only get and compare exact words
  @@precision = 0.3

  # init/construct/main input text and path to a wordlist
  def initialize(text, wordlist)

    @text = text
    @words = getWords(@text)
    @wordlist = getWordlist(wordlist)

    @approx = getApproxWords(@words, @wordlist)
    @diff = diffFilter(@words, @approx)

    # @diff.each {|word| puts "#{word[0]} needed #{word[1][0][1]} changes to become #{word[1][0][0]}" }

  end

  # Get words from string, add removal of . and similar for real use
  def getWords(text)
    text.downcase!
    text.strip!
    return text.split(' ')
  end

  # Read wordlist-file and return array
  def getWordlist(file_path)
    return File.open(file_path).readlines
  end

  # Get the total diff in spectrum (see diffFilter)
  def getTotalDiff(diffSpectrum = @diff)
    total_diff = 0
    diffSpectrum.each {|word| total_diff += word[1][0][1]}
    return total_diff
  end

  # Get words first letters depending on precision
  def begLetters(word)
    maxLetters = 10*@@precision
    nrLetters = (word.length*@@precision)
    nrLetters = maxLetters if nrLetters > maxLetters
    return word[0..(nrLetters-1)]
  end

  # Get approximate words from first letters
  def getApproxWords(words, wordlist)
    begLetterWords = []
    candidates = []

    for word in words
      begLetterWords.push(begLetters(word))
    end

    for w in wordlist
      if begLetterWords.include?(begLetters(to_word(w)))
        candidates.push(to_word(w))
      end
    end

    return candidates
  end

  # Use Levenshtein distance to return diff between words
  def diff(word1, word2)
    Levenshtein::distance(word1, word2)
  end

  # Return similar words in a sorted spectrum
  # RETURNS: [[word, [[candidate, diff], [candidate, diff], ...]], [word, [[candidate, diff], [candidate, diff], ...]], ...]
  # Candidates are sorted by diff, lowest first, ie [n][1][0] would return the word (candidate) most similar to n
  def diffFilter(words, wordlist)
    spectrum = []

    for word in words
      wordpos = spectrum.length
      spectrum[wordpos] = [word, []]

      for w in wordlist
        spectrum[wordpos][1].push([w, diff(w,word)])
      end

      spectrum[wordpos][1].sort! {|x,y| x[1] <=> y[1] }
    end

    return spectrum
  end

  # Simple clean-up for comparison
  def to_word(word)
    return word.downcase.strip
  end
end