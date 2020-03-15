/*
 * teamInfo.c - Team info source code file for mls app
 *
 * Author Roy Kravitz (roy.kravitz@pdx.edu)
 *
 * This is the source code file that for functionality specific to the Team Info database that
 * is part of an ECE 361 homework assignment.
 *
 * This file, and its associated header files (including the functions that you
 * need to provide) are meant to be used by your Linked List ADT and main() to deliver
 * the functionality required in the assignment
 *
 * @note:  You need to provide the code for several of these functions
 */

// include files
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "teamInfo.h"

// constants
#define MAX_TEAMS 100
#define NUM_OF_FIELDS_PER_RECORD 7


/**
 * Creates a new Team Info record
 *
 * @param name      (pointer to a char[]) containing the name of the team
 * @param nickname  (pointer to a char[]) containing the nickname of the team
 * @param league    (int) containing the league the team plays in (MLS, NWSL, USL, Other)
 * @param conf      (int) containing the conference the team plays in (Eastern, Wsstern, NWSL, Other}
 * @param nwins     (int) containing the number of wins during the regular season
 * @param nlosses   (int) containing the number of losses during the regular season
 * @param ndraws    (int) containing the number of draws during the regular season
 *
 * @returns         a pointer to a new TeamInfo record. The caller can check for validity
 * by checking for a "" name
 */
TeamInfoPtr_t createTeamInfoRecord(const char* name, const char* nickname, int league,
					int conf, int nwins, int nlosses, int ndraws)
{
    // Pointer to team info structure
    TeamInfoPtr_t teamInfoPtr = malloc(sizeof(TeamInfo_t));

    // Allocating space for teamInfoPtr (without malloc, unknown if pointer points at enough space)
//    teamInfoPtr = (TeamInfoPtr_t) malloc(sizeof(TeamInfo_t));

    // Place team info into proper member of team info structure
    strcpy(teamInfoPtr->name, name);
    strcpy(teamInfoPtr->nickname, nickname);
    teamInfoPtr->league = league;
    teamInfoPtr->conf = conf;
    teamInfoPtr->wins = nwins;
    teamInfoPtr->losses = nlosses;
    teamInfoPtr->draws = ndraws;

    return teamInfoPtr;      // pass back pointer of populated team info structure
}


/**
* Displays the information from a team record on stdout
*
* @param teamInfoPtr    (pointer to the team record) being examined
*
* @returns          nothing
*/
void display_team_info(TeamInfoPtr_t teamInfoPtr)
{
	// Print team info (members) from TeamInfo structure
	// Each team will be displayed as: <team name> <# of wins>-<# of losses>-<# of draws>
	printf("%-30s %d-%d-%d\n", teamInfoPtr->name, teamInfoPtr->wins, teamInfoPtr->losses, teamInfoPtr->draws);

	/*  Other info of each team that could also be displayed if desired
	printf("Team Nickname: %s\n", teamInfoPtr->nickname);
	printf("Team League: %s\n", get_league_str(teamInfoPtr->league)); // displays league string of team using get_league_str returned string
	printf("Team Conference: %s\n", get_conf_str(teamInfoPtr->conf)); // displays league string of team using get_conf_str returned string
	printf("Team Wins: %s\n", teamInfoPtr->wins);
	printf("Team Losses: %s\n", teamInfoPtr->losses);
	printf("Team Draws: %s\n\n", teamInfoPtr->draws);
	*/
}


/**
 * readTeamInfo() - reads the team info from a file
 * and creates an array of pointers to team Info records
 *
 * @param fname     (pointer to char[]) file name of  team info file to read
 * @param teams[]   (array of team info records) array to put pointers to team records into
 *
 * @returns         the number of team records stored
 *
 * @note You may have to include part (or all) of the absolute path in the file name.  It depends
 * on what directory(s) you are building and running your application from
 */
int readTeamInfo(char* fname, TeamInfoPtr_t  teams[])
{
    FILE *fp;           // pointer to team info file
    char buf[100];      // input buffer

    // holding variables for fields in the team info record
    char tir_name[MAX_TEAM_NAME];
    char tir_nickname[MAX_TEAM_NICKNAME];
    int tir_league;
    int tir_conf;
    int tir_wins;
    int tir_losses;
    int tir_draws;

    int nfields = 0;		// number of fields read from file
    int nrecs = 0;          // number of records
    TeamInfoPtr_t tir;		// pointer to team info record

    // open the team info file for reading
    if ((fp = fopen(fname, "r")) == NULL) {
        fprintf(stderr, "readTeamInfo: Could  not open team info file: %s (%s)...exiting\n",
			fname, strerror(errno));
        exit(1);
    }

	tir = (TeamInfoPtr_t) malloc(sizeof(TeamInfo_t));
	if (!tir) {
		fprintf(stderr, "readTeamInfo: Could not create Team Info record...exiting\n");
		exit(1);
	}

	// ready to read team info records
    printf("readTeamInfo: Reading team info file...\n");

    // get record from team info file
    while (!feof(fp)) {
		fgets(buf, sizeof(buf), fp);
		buf[strlen(buf) - 1] = '\0';    // trim the string
		if ((buf[0] == '/') && (buf[1] == '/'))  {
			// this is a comment, display and skip it
			printf("%s\n", buf);
		}  // display and skip comments
		else {  // try to process a team info record
			if (strlen(buf) > 0) {  // is it a blank line?
				// use scanf() to parse the team info line in the file
				nfields = sscanf(buf, "%30s %5s %d %d %d-%d-%d",
					tir_name, tir_nickname, &tir_league, &tir_conf,
					&tir_wins, &tir_losses, &tir_draws);

				if (nfields != NUM_OF_FIELDS_PER_RECORD) {  // is the team info line valid?
					// error parsing the line
					fprintf(stderr,
					"readTeamInfo: Error parsing team info record: #fields read = %d\tline=%s\n",
					nfields, buf);
					fprintf(stderr,
  					  "name= %s\tnickname= %s\tleague= %d\tconference= %d\twins-losses-ties= %d-%d-%d\n",
					tir_name, tir_nickname, tir_league, tir_conf, tir_wins, tir_losses, tir_draws);
				}  // invalid team info line - wrong number of fields
				else {  // add the record to the array of teams
					// replace underscores ('_') with space in the team name
					for(int i = 0; i < strlen(tir_name); i++) {
						if (tir_name[i] == '_') {
							tir_name[i] = ' ';
						}
					}

					// create a new team info record and add it to the array
					tir = createTeamInfoRecord(tir_name, tir_nickname, tir_league, tir_conf, tir_wins,
						tir_losses, tir_draws);
					teams[nrecs] = tir;
					printf("readTeamInfo: Added record %d\n", nrecs);
					nrecs++;
				} // right number of fields - add team info record to array
			} // not an empty line
		} // try to process a team info record
    } // read all of the line of the file
    fclose(fp);

    printf("\n\n");   // new line after last "Added record" line

    return nrecs;
}


// MAY DELETE, DON'T THINK I USE
// Helper functions
/**
 * get_conf_str() - returns a string containing the conference the team plays.
 * Assumes that sufficient space has been allocated for the return string
 *
 * @param conf    (int) conference
 *
 * @returns         a pointer to a char array holding the conference the team plays in
 */
/*static char* get_conf_str(int conf)
{
    static char conf_ptr[MAX_CONF_TXT];	// string containing name of conference.
									// static so it hangs around after function returns
    switch (conf)
    {
        case CONF_OTHER:     strcpy(conf_ptr, "OTHER");     break;
        case CONF_EASTERN:   strcpy(conf_ptr, "EASTERN");   break;
        case CONF_WESTERN:   strcpy(conf_ptr, "WESTERN");   break;
        case CONF_NWSL:      strcpy(conf_ptr, "NWSL");      break;

        default:             strcpy(conf_ptr, "?????");     break;
    }
    return conf_ptr;
}
*/

/**
 * get_league_str() - returns a string containing the league the team plays in.
 * Assumes that sufficient space has been allocated for the return string
 *
 * @param league   (int) league the team plays in
 *
 * @returns         a pointer to a char array holding the league the team plays in
 */
/*static char* get_league_str(int league)
{
	static char league_ptr[MAX_LEAGUE_TXT];	// string containing name of league.
											// static so it hangs around after function returns
    switch (league)
    {
        case LEAGUE_OTHER:   strcpy(league_ptr, "OTHER");   break;
        case LEAGUE_MLS:     strcpy(league_ptr, "MLS");     break;
        case LEAGUE_USL:     strcpy(league_ptr, "USL");     break;
        case LEAGUE_NWSL:    strcpy(league_ptr, "NWSL");    break;

        default:             strcpy(league_ptr, "?????");   break;
    }
    return league_ptr;
}
*/
