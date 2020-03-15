/*
 * LinkedList.c - Linked List ADT
 *
 * Originator: Roy Kravitz (roy.kravitz@pdx.edu)
 * Author:  Shaun Crippen
 *
 * This is the source code file for a Linked List ADT that
 * implements a singly linked list.  I've tried to define the
 * API in a way that we can change implementations but keep
 * the API the same
 *
 * @note Code is based on DynamicStack.c from Narasimha Karumanchi
 * @note Data Structures and Algorithms Made Easy, Career Monk Publishers, 2016
 *
 * @note Prints messages to stdio.  This is Karumanchi's doing
 */

#include <stdio.h>
#include <stdlib.h>
#include "teamInfo_LinkedList.h"

// API functions

/**
 * Creates a new instance of the Linked List
 *
 * @returns	Pointer to the new Linked List instance if it succeeds.  NULL if it fails
 */
LinkedListPtr_t createLList(void) {
	LinkedListPtr_t L = (LinkedListPtr_t) malloc(sizeof(LinkedList_t));
	if(!L)
		return NULL;
	L->head = NULL;
	L->count = 0;
	return L;
}


/**
 * Returns the number of items in the list
 *
 * @param L is a Pointer to a LinkedList instance
 *
 * @returns	Returns the number of nodes in the linked list
 */
int getLengthOfLList(LinkedListPtr_t L){
	return L->count;
}


/**
 * Inserts a new node into the linked list
 *
 * @param L is a Pointer to a LinkedList instance
 * @param data is the data item to put into the ndw node
 * @param pos is the position in the list to insert the item
 *
 * @returns	void
 */
void insertNodeInLList(LinkedListPtr_t L, TeamInfoPtr_t data, int pos){
	ListNodePtr_t head = L->head;
	ListNodePtr_t q, p;
	ListNodePtr_t newNode = (ListNodePtr_t) malloc(sizeof(ListNode_t));

	int k = 1;

	if(!newNode){
		printf("LinkedList ADT: Memory Error\n");
		return;
	}
	newNode->data = data;
	p = head;
	if ((pos == 1) || (p == NULL)){
		newNode->next = head;
		L->head = newNode;
		L->count++;
	}
	else {
		while((p != NULL) && (k < pos)){
			k++;
			q = p;
			p = p->next;
		}
		newNode->next = q->next;
		q->next = newNode;
		L->count++;
	}
}


/**
 * Deletes a new node into the linked list
 *
 * @param L is a Pointer to a LinkedList instance
 * @param pos is the position in the list to insert the item
 *
 * @returns	void
 */
void deleteNodeFromLLinkedList(LinkedListPtr_t L, int pos) {
	ListNodePtr_t head = L->head;
	ListNodePtr_t q, p;

	int k = 1;

	p = head;
	if(head == NULL){
		printf("LinkedList ADT: List Empty\n");
		return;
	}
	else if( pos == 1){
		L->head = head->next;
		free(p);
		L->count--;
	}
	else {
		while((p!=NULL) && (k < pos)){
			k++;
			q = p;
			p = p->next;
		}
		if(p == NULL){
			printf("LinkedList ADT: Position does not exist\n");
		}
		else{
			q->next = p->next;
			free(p);
			L->count--;
		}

	}
}


/**
 * Prints all of the data items in the Linked List
 *
 * @param L is a Pointer to a LinkedList instance
 *
 * @returns	void
 */
void printLList(LinkedListPtr_t L) {

	ListNodePtr_t head = L->head;

	// Move head pointer through list and print data from each node.
	// double arrow operator notation: head is a pointer to a node in the specified linked list,
	// whose data is a team info struct. Team info members are accessed with the second arrow operator
	while(head != NULL){
        printf("%-30s %1d-%d-%-d\n", head->data->name, head->data->wins, head->data->losses, head->data->draws);
		head = head->next;
	}
	printf("\n");
}

/**
 * Gets user-specified node data in the Linked List
 *
 * @param L is a Pointer to a LinkedList instance
 *
 * @returns	Pointer to team info at node
 */
TeamInfoPtr_t getTeamInfoRecord(LinkedListPtr_t L, int pos) {

    ListNodePtr_t current;       // Pointer to current node in linked list

    // Check if linked list is empty
    if(L->head == NULL)
    {
        printf("Team info list is empty.\n");
        exit(-1);               // exit program since error
    }

    // Traverse the list
    current = L->head;           // Start at front of list
    int i;
    for(i = 0; i < pos; i++)
        current = current->next; // point to next node

    return current->data;        // Return pointer to data of specified node in list
}
