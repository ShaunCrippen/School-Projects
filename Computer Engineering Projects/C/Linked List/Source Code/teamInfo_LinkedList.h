/*
 * teamInfo_LinkedList.h - Team info linked list for mls app
 *
 * Originator:  Roy Kravitz (roy.kravitz@pdx.edu)
 * Author:  Shaun Crippen
 *
 * This is the header file for a Linked list for the MLS app that
 * is part of  ECE 361 homework #3.  It is a modified
 * version of the Linked List ADT that I discussed in my solution to HW #2.
 *
 * The only notable change is that the data field in the list is no
 * longer an int.  Instead it is a structure containing information about
 * an MLS team.
 *
 * @note Code is based on SinglyLinkedList.c from Narasimha Karumanchi
 * @note Data Structures and Algorithms Made Easy, Career Monk Publishers, 2016
 */
#ifndef _TEAM_INFO_LINKEDLIST_H_
#define _TEAM_INFO_LINKEDLIST_H_

// include files
#include "teamInfo.h"

// define the struct that contains a node in the linked list
typedef struct _listNode {
	TeamInfoPtr_t data;		// Pointer to Team info record for the node
	struct _listNode *next;	// next pointer for the node
} ListNode_t, *ListNodePtr_t;

// define the struct that contains an instance of the Linked List
typedef struct _linkedList {
	ListNodePtr_t head;		// pointer to the head node of the list
	int count;				// number of elements on the list
} LinkedList_t, *LinkedListPtr_t;


// Linked List function prototypes
/* TODO:  YOU MAY NEED TO REVISE THESE FUNCTIONS */
/* OR REPLACE THEM IF YOUR API IS DIFFERENT */
LinkedListPtr_t createLList(void);
int getLengthOfLList(LinkedListPtr_t L);
void insertNodeInLList(LinkedListPtr_t L, TeamInfoPtr_t data, int pos);
void deleteNodeFromLLinkedList(LinkedListPtr_t L, int pos);
void printLList(LinkedListPtr_t L);

// Team info record prototypes
/* TODO: YOU NEED TO WRITE THIS FUNCTION */
TeamInfoPtr_t getTeamInfoRecord(LinkedListPtr_t L, int pos);

#endif
