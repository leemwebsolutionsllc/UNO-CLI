import Foundation

// MARK: - Card Definitions

// Okay, let's define the colors for the cards using emojis.
enum Color: String {
    case red = "🟥"
    case yellow = "🟨"
    case green = "🟩"
    case blue = "🟦"
    case wild = "⬛️" // Using a black square for wild cards.
}

// Now, defining the symbols (numbers and action symbols) for the cards.
enum Symbol: String {
    case zero = "0️⃣"
    case one = "1️⃣"
    case two = "2️⃣"
    case three = "3️⃣"
    case four = "4️⃣"
    case five = "5️⃣"
    case six = "6️⃣"
    case seven = "7️⃣"
    case eight = "8️⃣"
    case nine = "9️⃣"
    case skip = "⛔️"
    case reverse = "🔄"
    case drawTwo = "⁺2"
    case drawFour = "⁺4"
    case colorChange = "🎨"
}

// Creating the Card struct to represent each card in the game.
struct Card {
    var color: Color
    var symbol: Symbol

    // This function will generate the visual representation of the card.
    func displayLines() -> [String] {
        let number = symbol.rawValue
        let colorEmoji = color.rawValue
        // For wild cards, use a black square as the background.
        let blank = color == .wild ? "⬛️" : colorEmoji

        // Building each line of the card's appearance.
        let line1 = "\(number)\(colorEmoji)\(colorEmoji)"
        let line2 = "\(colorEmoji)\(blank)\(colorEmoji)"
        let line3 = "\(colorEmoji)\(blank)\(colorEmoji)"
        let line4 = "\(colorEmoji)\(colorEmoji)\(number)"

        // Returning the array of lines to display the card.
        return [line1, line2, line3, line4]
    }
}

// MARK: - Deck Definitions

// Creating the Deck class to manage the deck of cards.
class Deck {
    var cards: [Card] = []

    init() {
        createDeck() // Building the deck when initializing.
        shuffle()    // Shuffling the deck after creation.
    }

    // Function to create the full deck of UNO cards.
    func createDeck() {
        // Defining all possible colors and symbols for standard cards.
        let colors: [Color] = [.red, .yellow, .green, .blue]
        let symbols: [Symbol] = [.zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .skip, .reverse, .drawTwo]

        // Looping through colors and symbols to create each card.
        for color in colors {
            for symbol in symbols {
                let card = Card(color: color, symbol: symbol)
                cards.append(card) // Adding the card to the deck.
                // Adding duplicates for all cards except zero.
                if symbol != .zero {
                    cards.append(card)
                }
            }
        }

        // Adding wild cards and draw four cards to the deck.
        for _ in 0..<4 {
            let wildCard = Card(color: .wild, symbol: .colorChange)
            cards.append(wildCard)

            let drawFourCard = Card(color: .wild, symbol: .drawFour)
            cards.append(drawFourCard)
        }
    }

    // Function to shuffle the deck. using the build in shuffle method
    func shuffle() {
        cards.shuffle()
    }

    // Function to draw a card from the top of the deck.
    func drawCard() -> Card? {
        if cards.isEmpty {
            return nil // If the deck is empty, return nil.
        }
        return cards.removeFirst() // Remove and return the top card.
    }

    // Function to add cards back to the deck (e.g., when reshuffling).
    func addCards(_ newCards: [Card]) {
        cards.append(contentsOf: newCards)
        shuffle()
    }
}

// MARK: - Player Definitions

// Creating the Player class to represent each player in the game.
class Player {
    var name: String
    var hand: [Card] = []

    init(name: String) {
        self.name = name
    }

    // Function for the player to draw a card from the deck.
    func drawCard(from deck: Deck) {
        if let card = deck.drawCard() {
            hand.append(card) // Adding the drawn card to the player's hand.
        }
    }

    // Function to play a card from the player's hand.
    func playCard(at index: Int) -> Card {
        return hand.remove(at: index)
    }

    // Function to check if the player has any playable cards.
    func hasPlayableCard(topCard: Card) -> Bool {
        for card in hand {
            // A card is playable if it matches the color, symbol, or is a wild card.
            if card.color == topCard.color || card.symbol == topCard.symbol || card.color == .wild {
                return true
            }
        }
        return false // No playable cards found.
    }
}

// MARK: - Game Logic

// Creating the Game class to manage the game flow.
class Game {
    var deck = Deck()
    var discardPile: [Card] = []
    var player: Player
    var cpu: Player
    var currentPlayer: Player
    var isReversed = false

    init() {
        player = Player(name: "You")
        cpu = Player(name: "CPU")
        currentPlayer = player
        startGame() // Starting the game upon initialization.
    }

    // Function to start the game.
    func startGame() {
        explainRules()
        determineStartingPlayer()
        dealCards()
        flipStartingCard()
        gameLoop()
    }

    // Function to explain the game rules to the player.
    func explainRules() {
        print("Welcome to UNO CLI!")
        print("""
        Game Rules:
        - Match the top card by color or number/symbol.
        - You may choose to draw a card instead of playing one.
        - If you draw a playable card, you can choose to play it immediately.
        - Special cards (Wild, Draw Two, Draw Four, Reverse, Skip) have special effects.
        - When a Draw Two or Draw Four is played against you, you draw cards and skip your turn.
        - First player to get rid of all their cards wins!
        """)
    }

    // Function to determine who starts the game.
    func determineStartingPlayer() {
        print("Let's flip a coin to see who starts first.")
        print("Choose Heads or Tails (H/T): ", terminator: "")
        guard let choice = readLine()?.uppercased(), (choice == "H" || choice == "T") else {
            // If input is invalid, prompt again.
            print("Invalid input. Please enter 'H' for Heads or 'T' for Tails.")
            determineStartingPlayer()
            return
        }

        let coinFlip = Bool.random() ? "H" : "T"
        print("Coin flip result is: \(coinFlip == "H" ? "Heads" : "Tails")")

        if choice == coinFlip {
            print("You start first!")
            currentPlayer = player
        } else {
            print("CPU starts first!")
            currentPlayer = cpu
        }
    }

    // Function to deal initial cards to each player.
    func dealCards() {
        for _ in 0..<7 {
            player.drawCard(from: deck)
            cpu.drawCard(from: deck)
        }
    }

    // Function to flip the starting card onto the discard pile.
    func flipStartingCard() {
        if var startingCard = deck.drawCard() {
            // Ensuring the starting card is not a Draw Four card.
            while startingCard.symbol == .drawFour {
                deck.cards.append(startingCard)
                deck.shuffle()
                if let newStartingCard = deck.drawCard() {
                    startingCard = newStartingCard
                }
            }
            discardPile.append(startingCard)
            print("\nStarting card is:")
            displayCard(card: startingCard)
            // If the starting card is a special card, apply its effect.
            if startingCard.symbol == .skip || startingCard.symbol == .reverse || startingCard.symbol == .drawTwo {
                print("Starting card is a special card. Applying effect...")
                applySpecialCardEffect(card: startingCard, against: currentPlayer)
            }
        }
    }

    // Main game loop where turns alternate between player and CPU.
    func gameLoop() {
        while true {
            print("\n----------------------------------------")
            let topCard = discardPile.last!
            if currentPlayer === player {
                // It's the player's turn.
                print("\nYour turn!")
                print("Top card on discard pile:")
                displayCard(card: topCard)
                // Show how many cards the CPU has left.
                print("CPU has \(cpu.hand.count) card(s) left.")
                print("\nYour hand:")
                displayHand(hand: player.hand)
                playerTurn(topCard: topCard)
                // Check if the player has won.
                if player.hand.isEmpty {
                    print("Congratulations! You have won the game!")
                    break
                }
                switchTurn()
            } else {
                // It's the CPU's turn.
                print("\nCPU's turn.")
                sleep(1) // Adding a slight delay to simulate thinking.
                cpuTurn(topCard: topCard)
                // Check if the CPU has won.
                if cpu.hand.isEmpty {
                    print("CPU has won the game. Better luck next time!")
                    break
                }
                switchTurn()
            }
        }
    }

    // Function to handle the player's turn.
    func playerTurn(topCard: Card) {
        var turnComplete = false
        while !turnComplete {
            // Asking the player if they want to play a card or draw one.
            print("\nDo you want to [P]lay a card or [D]raw a card? (P/D): ", terminator: "")
            if let choice = readLine()?.uppercased() {
                if choice == "P" {
                    // Player chooses to play a card.
                    print("Enter the index of the card you want to play:")
                    if let input = readLine(), let index = Int(input), index >= 0, index < player.hand.count {
                        let selectedCard = player.hand[index]
                        if isPlayable(card: selectedCard, topCard: topCard) {
                            let playedCard = player.playCard(at: index)
                            discardPile.append(playedCard)
                            print("You played:")
                            displayCard(card: playedCard)
                            // If the card is a special card, apply its effect.
                            if playedCard.symbol == .drawTwo || playedCard.symbol == .drawFour || playedCard.symbol == .skip || playedCard.symbol == .reverse || playedCard.symbol == .colorChange || playedCard.color == .wild {
                                applySpecialCardEffect(card: playedCard, against: cpu)
                            }
                            turnComplete = true // Turn ends after playing a card.
                        } else {
                            print("Invalid card selection. The card doesn't match the top card.")
                        }
                    } else {
                        print("Invalid input. Please enter a valid index.")
                    }
                } else if choice == "D" {
                    // Player chooses to draw a card.
                    if let drawnCard = deck.drawCard() {
                        print("You drew:")
                        displayCard(card: drawnCard)
                        if isPlayable(card: drawnCard, topCard: topCard) {
                            // If the drawn card is playable, ask if they want to play it.
                            print("You can play the drawn card. Do you want to play it? (Y/N): ", terminator: "")
                            if let playChoice = readLine()?.uppercased(), playChoice == "Y" {
                                discardPile.append(drawnCard)
                                print("You played the drawn card.")
                                if drawnCard.symbol == .drawTwo || drawnCard.symbol == .drawFour || drawnCard.symbol == .skip || drawnCard.symbol == .reverse || drawnCard.symbol == .colorChange || drawnCard.color == .wild {
                                    applySpecialCardEffect(card: drawnCard, against: cpu)
                                }
                                turnComplete = true // Turn ends after playing the drawn card.
                            } else {
                                player.hand.append(drawnCard)
                                turnComplete = true // Turn ends after drawing a card.
                            }
                        } else {
                            print("You cannot play the drawn card. It has been added to your hand.")
                            player.hand.append(drawnCard)
                            turnComplete = true // Turn ends after drawing a card.
                        }
                    } else {
                        print("The deck is empty. Cannot draw a card.")
                        turnComplete = true // Turn ends if unable to draw a card.
                    }
                } else {
                    print("Invalid choice. Please enter 'P' to play or 'D' to draw.")
                }
            }
        }
    }

    // Function to handle the CPU's turn.
    func cpuTurn(topCard: Card) {
        if cpu.hasPlayableCard(topCard: topCard) {
            // CPU has a playable card.
            for (index, card) in cpu.hand.enumerated() {
                if isPlayable(card: card, topCard: topCard) {
                    let playedCard = cpu.playCard(at: index)
                    discardPile.append(playedCard)
                    print("CPU played:")
                    displayCard(card: playedCard)
                    // Apply special card effects if applicable.
                    if playedCard.symbol == .drawTwo || playedCard.symbol == .drawFour || playedCard.symbol == .skip || playedCard.symbol == .reverse || playedCard.symbol == .colorChange || playedCard.color == .wild {
                        applySpecialCardEffect(card: playedCard, against: player)
                    }
                    break // CPU's turn ends after playing a card.
                }
            }
        } else {
            // CPU has no playable cards, so it draws one.
            print("CPU has no playable cards. Drawing a card.")
            if let drawnCard = deck.drawCard() {
                // Decide whether to play the drawn card.
                if isPlayable(card: drawnCard, topCard: topCard) {
                    print("CPU played the drawn card:")
                    discardPile.append(drawnCard)
                    displayCard(card: drawnCard)
                    if drawnCard.symbol == .drawTwo || drawnCard.symbol == .drawFour || drawnCard.symbol == .skip || drawnCard.symbol == .reverse || drawnCard.symbol == .colorChange || drawnCard.color == .wild {
                        applySpecialCardEffect(card: drawnCard, against: player)
                    }
                } else {
                    print("CPU cannot play the drawn card.")
                    cpu.hand.append(drawnCard)
                }
            } else {
                print("The deck is empty. CPU cannot draw a card.")
            }
        }
    }

    // Function to check if a card is playable.
    func isPlayable(card: Card, topCard: Card) -> Bool {
        // A card is playable if it matches the color, symbol, is a wild card, or the top card is wild.
        return card.color == topCard.color || card.symbol == topCard.symbol || card.color == .wild || topCard.color == .wild
    }

    // Function to apply the effects of special cards.
    func applySpecialCardEffect(card: Card, against player: Player) {
        switch card.symbol {
        case .drawTwo:
            print("\(player.name) must draw two cards and skip their turn.")
            for _ in 0..<2 {
                player.drawCard(from: deck)
            }
            // Skip the player's turn if it's currently their turn.
            if currentPlayer === player {
                switchTurn()
            }
        case .drawFour:
            print("\(player.name) must draw four cards and skip their turn.")
            for _ in 0..<4 {
                player.drawCard(from: deck)
            }
            // The player who played the card chooses a new color.
            if currentPlayer === self.player {
                chooseNewColor()
            } else {
                cpuChooseNewColor()
            }
            // Skip the player's turn if it's currently their turn.
            if currentPlayer === player {
                switchTurn()
            }
        case .skip:
            print("\(player.name)'s turn is skipped.")
            // Skip the player's turn if it's currently their turn.
            if currentPlayer === player {
                switchTurn()
            }
        case .reverse:
            print("Game direction reversed.")
            isReversed.toggle()
            // In a two-player game, reverse acts like a skip.
            if currentPlayer === player {
                switchTurn()
            }
        case .colorChange:
            // Wild card played, so choose a new color.
            if currentPlayer === self.player {
                chooseNewColor()
            } else {
                cpuChooseNewColor()
            }
        default:
            break // No special effect for standard cards.
        }
    }

    // Function for the player to choose a new color.
    func chooseNewColor() {
        print("Choose a color to change to: [R]ed, [Y]ellow, [G]reen, [B]lue")
        if let input = readLine()?.uppercased() {
            var selectedColor: Color?
            switch input {
            case "R":
                selectedColor = .red
            case "Y":
                selectedColor = .yellow
            case "G":
                selectedColor = .green
            case "B":
                selectedColor = .blue
            default:
                print("Invalid input. Please choose a valid color.")
                chooseNewColor() // Prompt again if input is invalid.
                return
            }
            if let color = selectedColor {
                print("You changed the color to \(color.rawValue).")
                // Update the top card's color to the chosen color.
                if var topCard = discardPile.last {
                    topCard.color = color
                    discardPile[discardPile.count - 1] = topCard
                }
            }
        }
    }

    // Function for the CPU to choose a new color.
    func cpuChooseNewColor() {
        // CPU randomly selects a new color.
        let newColor = [Color.red, Color.yellow, Color.green, Color.blue].randomElement()!
        print("CPU changed color to \(newColor.rawValue).")
        // Update the top card's color to the chosen color.
        if var topCard = discardPile.last {
            topCard.color = newColor
            discardPile[discardPile.count - 1] = topCard
        }
    }

    // Function to switch turns between player and CPU.
    func switchTurn() {
        currentPlayer = (currentPlayer === player) ? cpu : player
    }

    // MARK: - Display Functions

    // Function to display a card's visual representation.
    func displayCard(card: Card) {
        let lines = card.displayLines()
        for line in lines {
            print(line)
        }
    }

    // Function to display the player's hand with cards side by side.
    func displayHand(hand: [Card]) {
        var handLines = [String](repeating: "", count: 5) // 4 lines for card + 1 line for indices.
        for (index, card) in hand.enumerated() {
            let cardLines = card.displayLines()
            for i in 0..<cardLines.count {
                handLines[i] += cardLines[i] + "   " // Adding spaces between cards.
            }
            handLines[4] += " [\(index)]     " // Adding the index below each card.
        }
        for line in handLines {
            print(line)
        }
    }
}

// Start the game by creating an instance of the Game class.
let game = Game()
