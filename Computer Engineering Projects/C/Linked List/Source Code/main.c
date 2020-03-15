/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Shaun Crippen
    ECE 361, Fall 2019
    Homework 3, Problem 2

    Program Description:
    --------------------
    Creates singly linked lists soccer team information ( name, record, etc.),
    one each for Western and Eastern Conferences (2 linked lists total).
    Each node stores a structure of each team's information

    Displays the following:

    1) Teams by conference

    2) Team information of teams with top 5 win percentage,
       regardless of conference or league.
       [Win% = wins / (wins + losses + draws)]

    3) Team with most wins and team with most losses for each conference.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#include <stdio.h>
#include <stdlib.h>
#include "teamInfo_LinkedList.h"

#define NUM_TEAMS 24    // number of MLS teams in default file.  Change if number of teams is

int main(void)
{
    // create array "teams" of team info pointers for the number of teams in file
    TeamInfoPtr_t teams[NUM_TEAMS];



    // read team info from file, return number of team records.  array teams is now populated with team records from file
    int numRecs = readTeamInfo("C:/Users/Shaun/Desktop/ece361_hw3/teamInfo.txt", teams);


    // Each linked list is empty
    LinkedListPtr_t west_conf = createLList();
    LinkedListPtr_t east_conf = createLList();


    // populate linked lists with team info from array teams[].  Node 1 is head based on design choice.
    // Test conf member to determine which linked list each team info record goes into
    // NOTE: array teams starts at element 0 (j)

    // If team in array teams is from East Conference, store in East Conference linked list east_conf
    for(int j = 0; j < numRecs; j++)
    {
        if(teams[j]->conf == 1)
            insertNodeInLList(east_conf, teams[j], j+1);
    }

    // If team in array teams is from West Conference, store in West Conference linked list west_conf
    for(int j = 0; j < numRecs; j++)
    {
        if(teams[j]->conf == 2)
            insertNodeInLList(west_conf, teams[j], j+1);
    }



    // DISPLAY lISTS OF TEAMS IN WEST AND EAST CONFERENCES (each team listed as: Name  wins-losses-draws)
    // Display Western Conference
    printf("Western Conference Teams:\n");
    printf("-------------------------\n");
    printLList(west_conf);

    // Display Eastern Conference
    printf("Eastern Conference Teams:\n");
    printf("-------------------------\n");
    printLList(east_conf);

    // Display Team with most wins and team with most losses in each conference
    int num_w_teams = getLengthOfLList(west_conf);         // number of west teams in western conference
    int num_e_teams = getLengthOfLList(east_conf);         // number of eat teams in eastern conference
    TeamInfoPtr_t curr_node = malloc(sizeof(TeamInfo_t));  // declare/allocate time info record placeholder for loop iterations
    TeamInfoPtr_t tempW = malloc(sizeof(TeamInfo_t));      // declare/allocate team with most wins placeholder for loop iterations
    TeamInfoPtr_t tempL = malloc(sizeof(TeamInfo_t));      // declare allocate team with most losses placeholder for loop iterations

    // initialize team info record placeholders to head node for loop
    tempW = getTeamInfoRecord(west_conf, 0);  // For finding team with most wins
    tempL = getTeamInfoRecord(west_conf, 0);  // For finding team with most losses



    // FOR LOOP FOR DETERMINING WEST TEAMS WITH MOST WINS & LOSSES
    // index starts at 1 since linked list head node is node 0. No need need to compare head node to itself.
    for(int k = 1; k < num_w_teams; k++)
    {
        curr_node = getTeamInfoRecord(west_conf, k);    // current node being compared

        // team win/loss differential = wins - loss.  Value used for tiebreakers
        int curr_node_win_loss = curr_node->wins - curr_node->losses; // current team win/loss differential
        int tempW_win_loss = tempW->wins - tempW->losses;             // temp team for most wins win/loss differential for tiebreaker
        int tempL_win_loss = tempL->wins - tempL->losses;             // temp team for most losses win/loss differential for tiebreaker

        // DETERMINE TEAM WITH MOST WINS
        // if team @ current node has more wins than placeholder, placeholder now holds current node's team
        // Tiebreaker is win/loss difference if teams have same # wins
        // (IF current node team > temp max team AND current node's win/loss diff > temp max team's win/loss diff, THEN swap current team info with temp max's
        if(curr_node->wins > tempW->wins && curr_node_win_loss > tempW_win_loss)
            tempW = curr_node;

        // DETERMINE TEAM WITH MOST LOSSES
        // Tiebreaker is team with worse win/loss diff
        if(curr_node->losses > tempL->losses && curr_node_win_loss < tempL_win_loss)
            tempL = curr_node;
    }


    // Display West teams with most wins & losses
    printf("Team with most wins in West:\n");  // West team with most wins
    printf("----------------------------\n");
    display_team_info(tempW);                  // Displays name and record members from tempW data member. tempW is node.

    printf("\n");                              // new line for output formatting

    printf("Team with most losses in West:\n");// West team with most losses
    printf("------------------------------\n");
    display_team_info(tempL);                  // Displays team with most losses' name and record from data member. tempL is node.

    printf("\n");                              // added space between best/worst west team and following best/worst east teams



    // FOR LOOP FOR DETERMINING EAST TEAMS WITH MOST WINS & LOSSES
    // re-initialize team info record placeholders to head node for loop.  Used variables from west conference loop
    tempW = getTeamInfoRecord(east_conf, 0);  // For finding team with most wins
    tempL = getTeamInfoRecord(east_conf, 0);  // For finding team with most losses

    // index starts at 1 since linked list head node is node 0. No need need to compare head node to itself.
    for(int k = 1; k < num_e_teams; k++)
    {
        curr_node = getTeamInfoRecord(east_conf, k);                  // current node being compared

        // team win/loss differential = wins - loss.  Value used for tiebreakers
        int curr_node_win_loss = curr_node->wins - curr_node->losses; // current team win/loss differential
        int tempW_win_loss = tempW->wins - tempW->losses;             // temp team for most wins win/loss differential for tiebreaker
        int tempL_win_loss = tempL->wins - tempL->losses;             // temp team for most losses win/loss differential for tiebreaker

        // DETERMINE TEAM WITH MOST WINS
        // if team @ current node has more wins than placeholder, placeholder now holds current node's team
        // Tiebreaker is win/loss difference if teams have same # wins
        // (IF current node team > temp max team AND current node's win/loss diff > temp max team's win/loss diff, THEN swap current team info with temp max's
        if(curr_node->wins > tempW->wins && curr_node_win_loss > tempW_win_loss)
            tempW = curr_node;

        // DETERMINE TEAM WITH MOST LOSSES
        // Tiebreaker is team with worse win/loss diff
        if(curr_node->losses > tempL->losses && curr_node_win_loss < tempL_win_loss)
            tempL = curr_node;
    }

    // Display East teams with most wins & losses
    printf("Team with most wins in East:\n");  // West team with most wins
    printf("----------------------------\n");
    display_team_info(tempW);                  // Displays name and record members from tempW data member. tempW is node.

    printf("\n");                              // new line for output formatting

    printf("Team with most losses in East:\n");// West team with most losses
    printf("------------------------------\n");
    display_team_info(tempL);                  // Displays team with most losses' name and record from data member. tempL is node.

    printf("\n");                              // new line for output formatting

        /*for (int i = 0 ; i < NUM_TEAMS ; i++)
    {
        printf("%s\n", teams[i]);
    }*/


    // DISPLAY TOP 5 TEAMS BASED ON WIN% (picking teams based on win% = picking teams based on wins)
    // populate array with position of top 5 teams in array teams in descending order based on wins

    int win_pos[5];  // holds position in array teams of top 5 win% teams

    int wins = 0;   // base case for comparison
    int winner[5];

    int i, j;
    for (i = 0 ; i < 5; i=i+1)
    {
       //printf("%d\n", i);
       for (j = 0 ; j < NUM_TEAMS; j++)
       {
            if(teams[j]->wins > wins && (teams[j]->wins < winner[i-1]))
            {
                wins = teams[j]->wins;
                win_pos[i]=j;
            }
       }

       winner[i] = wins;
       wins = 0;

    }

    // Display top 5 teams
    printf("Top 5 teams:\n");
    printf("------------\n");
    for(int i = 0;i < 5; i++)
    {
        display_team_info(teams[win_pos[i]]);
    }


    return 0;
}
