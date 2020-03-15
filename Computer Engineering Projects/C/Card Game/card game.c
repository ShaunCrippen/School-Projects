#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define NUM_CARDS 52
#define NUM_RANKS 13
#define NUM_SUITS 4

// Global declarations for card suits
enum suit_value {HEARTS, DIAMONDS, CLUBS, SPADES};                  // Card suit enumeration
const char *suit_sym[4] = {"\u2665", "\u2666", "\u2663", "\u2660"}; // Unicode card suit symbols

// card information structure
typedef struct card_struct
{
    char *rank;
    enum suit_value suit;
    int value;
} card;

// Function prototypes
void display_deck(card deck[]);
void shuffle_deck(card deck[], int seed);

int main(void)
{
    system("chcp 65001");  // To display suit symbols.
    char *ranks[NUM_RANKS] = {"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"};
    card deck[NUM_CARDS];  // Initialize deck of cards (array of structures)
    int seed;

    // Seed value for shuffling
    printf("\nEnter a seed value: ");
    scanf("%d", &seed);

    // Populate array of structures (card deck)
    for(int i = 0; i < NUM_CARDS; ++i)
    {
        deck[i].rank = ranks[i % NUM_RANKS];
        deck[i].suit = i / NUM_RANKS;

        // Determine card value (Ace = 1, Jack - King = 10, numbered cards = number)
        // Based on rank member string
        if (strcmp(deck[i].rank, "A")== 0)
            deck[i].value = 1;
        else if (strcmp(deck[i].rank, "2")== 0)
            deck[i].value = 2;
        else if (strcmp(deck[i].rank, "3")== 0)
            deck[i].value = 3;
        else if (strcmp(deck[i].rank, "4")== 0)
            deck[i].value = 4;
        else if (strcmp(deck[i].rank, "5")== 0)
            deck[i].value = 5;
        else if (strcmp(deck[i].rank, "6")== 0)
            deck[i].value = 6;
        else if (strcmp(deck[i].rank, "7")== 0)
            deck[i].value = 7;
        else if (strcmp(deck[i].rank, "8")== 0)
            deck[i].value = 8;
        else if (strcmp(deck[i].rank, "9")== 0)
            deck[i].value = 9;
        else if (strcmp(deck[i].rank, "10")== 0 || strcmp(deck[i].rank, "J")== 0 || strcmp(deck[i].rank, "Q")== 0 || strcmp(deck[i].rank, "K")== 0)
            deck[i].value = 10;
    }

    // Display sorted card deck on console (Sorted by suit, then rank)
    printf("\nBefore shuffling:\n");
    display_deck(deck);

    // Call function to shuffle card deck
    shuffle_deck(deck, seed);

    // Display shuffled card deck on console
    printf("\nAfter shuffling:\n");
    display_deck(deck);

    // Display drawn cards and if series of draws equals 21 (WIN), < 21 (BUST), or > 21 (OUT OF CARS)
    printf("\nFind combinations of 21:\n");
    int total = 0;              // Drawn card series total value
    int wins = 0, busts = 0;    // wins & busts totals
    int num_aces = 0;           // flag for if ace has been drawn
    for(int i = 0; i < NUM_CARDS; i++)
    {
        printf("%s%s ", deck[i].rank, suit_sym[deck[i].suit]);  // print drawn card
        total += deck[i].value;                                 // keep track of drawn card value total
        if (strcmp(deck[i].rank, "A") == 0)                     // if ace is drawn, update ace flag
            num_aces++;

        if ((total + 10 == 21) && (num_aces > 0))               // if changing an ace value from 1 to 11 leads to win,
            total += 10;                                        // change ace value.

        if (total > 21)                                         // if drawn cards total is over 21, BUST.
        {
            printf("BUST\n");
            total = 0;
            num_aces = 0;
            busts++;
        }
        else if (total == 21)                                   // If drawn cards add up to 21, WIN.
        {
            printf("WIN\n");
            total = 0;
            num_aces = 0;
            wins++;
        }
    }
    printf("OUT OF CARDS\n\n");                                 // If card deck is depleted, display "OUT OF CARDS".

    // Display number of wins and busts
    printf("Number of wins = %d\n", wins);
    printf("Number of busts = %d\n\n", busts);

    printf("Thanks for playing!\n\n");

    return(0);
}

// Function to display card deck in 4 columns of 13 cards.
// Argument is the card deck as an array of structures.
void display_deck(card deck[])
{
    for(int i = 0; i < NUM_RANKS; i++)
    {
        printf("%2s%s\t", deck[i].rank, suit_sym[deck[i].suit]);
        printf("%2s%s\t", deck[i + NUM_RANKS].rank, suit_sym[deck[i + NUM_RANKS].suit]);
        printf("%2s%s\t", deck[i + NUM_RANKS*2].rank, suit_sym[deck[i + NUM_RANKS*2].suit]);
        printf("%2s%s\n", deck[i + NUM_RANKS*3].rank, suit_sym[deck[i + NUM_RANKS*3].suit]);
    }
}

// Function to shuffle deck of cards
// Arguments are the card deck as an array of structures and the user-provided seed value.
void shuffle_deck(card deck[], int seed)
{
    card temp;      // temporary holding place of card to be swapped
    int swap;       // index of card to be swapped
    srand(seed);    // Seed random numbers with user-provided seed value
    for(int i = 0; i < NUM_CARDS; i++)
    {
        swap = rand() % NUM_CARDS;     // generate pseudo-random card index from 0 to 51
        temp = deck[i];
        deck[i] = deck[swap];
        deck[swap] = temp;
    }
}
