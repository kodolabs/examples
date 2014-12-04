module ScoreHelper

  MARKS_DESCRIPTIONS = {
      trash:       "Something that just doesn't work in any way, it's almost offensive rather than anything remotely enjoyable.",
      poor:        "This isn't a game that we would recommend, but you may get a few laughs out of how bad the game actually is.",
      average:     "There's some good qualities to the game, but it just doesn't quite do enough to keep you entertained.
                  We recommend you wait for the sales with this one.",
      good:        "This is a good game that will provide enough entertainment, but hasn't really done enough to show us anything
                  that is truely amazing. The potential is there though.",
      excellent:   "This is a well crafted game that we would highly recommend.",
      masterpiece: "There's nothing we can really fault with this game, it's probably one of the best games ever released
                  and will definitly be in the running to be the Game of the Year. Make sure you pick this up, you can't
                  miss it!"
  }

  MARKS = {
      trash:       1..2.9,
      poor:        3..4.9,
      average:     5..6.9,
      good:        7..7.9,
      excellent:   8..9.9,
      masterpiece: 10..10
  }

  def score_mark(score)
    MARKS.select{|k,v| v.include? score}.keys.first
  end

  def mark_description(score_mark)
    MARKS_DESCRIPTIONS[score_mark]
  end

  def round(score)
    score == 10.0 ? 10 : score
  end
end
