module PlayingCards

export Card, rank, suit, deck, idx_to_holecards, holecards_to_idx, collision
export string, show

struct Card
    val::UInt8
end

Card(card::Integer) = Card(UInt8(card))
function Card(card::String)
    @assert(length(card) == 2)
    rank_idx = findfirst(card[1], ranks_str)
    suit_idx = findfirst(lowercase(card[2]), suits_str)
    val = ((rank_idx - 1) * 4) + (suit_idx - 1) + 1
    return Card(val)
end

const ranks_str = "23456789TJQKA"
const suits_str = "cdhs"
const suit_emojis = ["♣️","♦️","♥️","♠️"]
const suit_colors = ["\x1b[32m", "\x1b[34m", "\x1b[31m", "\x1b[33m"]
const reset_color = "\x1b[0m"

rank(card) = ((card.val-1) ÷ 4) + 1
suit(card) = ((card.val-1) % 4) + 1

Base.string(card::Card) = ranks_str[rank(card)] * suits_str[suit(card)]

Base.show(io::IO, card::Card) = begin
    print(io, suit_colors[suit(card)])
    print(io, ranks_str[rank(card)])
    print(io, suit_emojis[suit(card)])
    print(io, reset_color)
end

const deck = [Card(i) for i=1:52]

function get_idx_to_holecards()
    mat = Matrix{Card}(undef, 2, 1326)
    idx = 1
    for i in 1:52
        for j in 1:(i-1)
            mat[1, idx] = Card(i)
            mat[2, idx] = Card(j)
            idx += 1
        end
    end
    return mat
end

function get_holecards_to_idx()
    mat = Matrix{UInt16}(undef, 52, 52)
    idx = 1
    for i in 1:52
        for j in 1:(i-1)
            mat[i, j] = idx
            mat[j, i] = idx
            idx += 1
        end
    end
    return mat
end

const _idx_to_holecards = get_idx_to_holecards()
const _holecards_to_idx = get_holecards_to_idx()

idx_to_holecards(idx) = @view _idx_to_holecards[:, idx]
holecards_to_idx(card1, card2) = _holecards_to_idx[card1, card2]
holecards_to_idx(card1::Card, card2::Card) = _holecards_to_idx[card1.val, card2.val]

card_bits(card::Card) = UInt64(1) << card.val
function card_bits(cards::AbstractArray{Card})
    bits = 0
    for card in cards
        bits |= card_bits(card)
    end
    return bits
end

collision(card::Card, cards::Vector{Card}) = card_bits(card) & card_bits(cards) != 0
collision(cards1::Vector{Card}, cards2::Vector{Card}) = card_bits(cards1) & card_bits(cards2) != 0

function collision(cards...)
    bits = 0
    for card in cards
        current_card_bits = card_bits(card)
        if bits & current_card_bits != 0
            return true
        end
        bits |= current_card_bits
    end
    return false
end

end # module PlayingCards
