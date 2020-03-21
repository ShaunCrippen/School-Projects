/*
Shaun Crippen
ECE 585 winter 2020
Cache Simulator

Program Description:
--------------------
Simulates a single-level writeback cache using either true LRU or 1-bit LRU replacement policies.
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

// Declare struct to hold all cache block info, called cache slot
typedef struct cache_slots
{
    int valid;
    int dirty;
    unsigned long tag;   // address tag
    unsigned long index; // number of sets
    long int LRU_count;  // tracks how long a block has been in cache
    int cache_block;     // this is the "way" for a given index
    int MRU;
} cache_slot;


int main(void)
{
    // Declare output variables
    int num_reads = 0;
    int num_writes = 0;
    int num_invalidates = 0;
    float num_hits = 0;
    float num_misses = 0;
    int num_evictions = 0;
    int num_writebacks = 0;
    int num_accesses = 0;

    // Scan in user options
    int num_sets;
    int num_ways;
    int line_size;
    int replacement_policy;

    printf("ENTER NUMBER OF SETS: ");
    scanf("%d", &num_sets);

    printf("ENTER NUMBER OF WAYS: ");
    scanf("%d", &num_ways);

    printf("ENTER LINE SIZE: ");
    scanf("%d", &line_size);

    printf("ENTER REPLACEMENT POLICY: ");
    scanf("%d", &replacement_policy);

    // Create array of struct to represent cache
    cache_slot cache_array[num_ways * num_sets];
    int current_block;
    int set_index = 0;                              // starting point to index in cache, range: 0 to num_sets - 1
    for(int i = 0; i < num_ways * num_sets; i++)
    {
        //Initialize LRU, MRU, valid, dirty to zero for "empty" cache
        cache_array[i].LRU_count = 0;
        cache_array[i].MRU = 0;
        cache_array[i].valid = 0;
        cache_array[i].dirty = 0;

        //Populate index, and block (way)
        current_block = (i % num_ways) + 1;         // select which cache block to create per index
        cache_array[i].cache_block = current_block;
        cache_array[i].index = set_index;
        if(current_block == num_ways)
            set_index++;                            // increment index, after all ways at current index are populated
    }

    // Declare flag to determine if a request was serviced
    int request_serviced;

    // parse the trace file, pull out one request at a time, clean it, and service it
    FILE* fp = NULL;                                        // Declare an empty file pointer
    fp = fopen("trace2.txt", "r");                          // ALWAYS SAME FILE NAME, IN THE SAME LOCATION AS CODE.
    if(fp == NULL)
        printf("unable to open file\n");
    char trace_string[11];                                  // 1 element for access type, 1 white space, 8 hex address digits, 1 for end of string
    char access_type[2];                                    // access type + 1 for end of string
    char hex_address_str[9];                                // 8 hex address digits + 1 for end of string
    unsigned long num_index_bits;                           // holds the number of bits expected for index field
    unsigned long num_bytesel_bits;                         // holds the number of bits expected for byte select field
    unsigned long tag_length;                               // holds the number of bits expected for tag field
    unsigned long request_index;                            // hold the "cleaned" index field of the current request
    unsigned long request_tag;                              // hold the "cleaned" tag field of the current request
    unsigned long hex_address;                              // holds the decimal converted hex address


    // With cache created, service each request from trace file one request at a time
    while((fgets(trace_string, 11, fp)) != NULL)
    {
        // split hex address into address fields: tag, index, byte select
        strncpy(access_type, trace_string, 1);                   // Pull request type from current file string and put it into access type string
        access_type[1] = '\0';                                   // MANUALLY place string end of request type
        strncpy(hex_address_str, trace_string + 2, 8);           // get 8 hex address digits
        hex_address_str[8] = '\0';                               // MANUALLY place string end of hex address

        // Separate and clean the index, byte sel, and tag fields for the request address
        num_index_bits = log2(num_sets);                     // Determine #bits in address for index
        num_bytesel_bits = log2(line_size);                  // Determine #bits in address for data select
        tag_length = 32 - num_index_bits - num_bytesel_bits; // # tag bits is remaining bits in 32-bit address

        hex_address = strtoul(hex_address_str, NULL, 16);                                             // Convert hex_address_str to unsigned long var called hex_address

        request_index = (((1 << num_index_bits) - 1) & (hex_address >> num_bytesel_bits));            // extract request address field bits from converted hex address, start at end of byte sel LSBs, go for length num_index_bits
        request_tag = (((1 << tag_length) - 1) & (hex_address >> (num_index_bits+num_bytesel_bits))); // extract request index field bits from converted hex address, start at end of request index bits, go for tag length


        // Check if cache replacement policy is true LRU
        if(replacement_policy == 0)
        {
            request_serviced = 0;          // Initialize request flag to zero for starting point.
                                           // If flag set, grab next request from file

            // For each address request, increment the LRU count for valid cache data to keep track of time since data used
            for(int i = 0; i < (num_ways * num_sets); i++)
            {
                if(cache_array[i].valid == 1)
                    cache_array[i].LRU_count++;
            }

//------------------------------------------------------------- LRU READ ---------------------------------------------------------------
            if(strcmp(access_type, "0") == 0)
            {
                num_reads++;
                num_accesses++;
                for(int i = 0; i < (num_ways * num_sets); i++)  // checking for hit
                {
                    if(request_serviced == 1)
                        break;
                    if(request_index == cache_array[i].index && request_tag == cache_array[i].tag && (cache_array[i].valid == 1))
                    {
                        num_hits++;
                        request_serviced = 1;
                        cache_array[i].LRU_count = 0;       // hit so reset count, count keeps tracks of last use
                    }
                }

                int replacement_index;
                long int max_LRU_count;

                for(int i = 0; i < (num_ways * num_sets); i++)  // checking for miss, looking for open (invalid) cache slot
                {
                    if(request_serviced == 1)
                        break;
                    if(request_index == cache_array[i].index && (cache_array[i].valid == 0))
                    {
                        num_misses++;
                        cache_array[i].valid = 1;
                        cache_array[i].dirty = 0;
                        cache_array[i].tag = request_tag;
                        cache_array[i].LRU_count = 0;
                        request_serviced = 1;
                    }
                }

                for(int i = 0; i < (num_ways * num_sets); i++)  // MISS occurred, need to evict. finding LRU replacement policy victim
                {
                    if(request_serviced == 1)
                        break;

                    if(request_index == cache_array[i].index && cache_array[i].cache_block == 1) // if the first cache block (first way) in the set
                    {
                        replacement_index = i;
                        max_LRU_count = cache_array[i].LRU_count;
                    }

                    else if(request_index == cache_array[i].index)                               // comparing start point to find LRU cache block
                    {
                        if(cache_array[i].LRU_count > max_LRU_count)
                        {
                            max_LRU_count = cache_array[i].LRU_count;
                            replacement_index = i;
                        }
                    }
                }

                // Do the replacement based on the LRU block found
                for(int j = 0; j < 1; j++)
                {
                    if(request_serviced == 1)
                        break;

                    num_misses++;
                    num_evictions++;
                    cache_array[replacement_index].tag = request_tag;
                    cache_array[replacement_index].LRU_count = 0;
                    request_serviced = 1;

                    if(cache_array[replacement_index].dirty == 1)
                        num_writebacks++;
                        cache_array[replacement_index].dirty = 0;
                }
            }

//------------------------------------------------------------ LRU WRITE --------------------------------------------------------------
            else if(strcmp(access_type, "1") == 0)
            {
                num_writes++;
                num_accesses++;
                for(int i = 0; i < (num_ways * num_sets); i++)  // looking for hit
                {
                    if(request_serviced == 1)
                        break;

                    if(request_index == cache_array[i].index && request_tag == cache_array[i].tag && (cache_array[i].valid == 1))
                    {
                        num_hits++;
                        cache_array[i].dirty =1;
                        request_serviced = 1;
                        cache_array[i].LRU_count = 0;
                    }
                }

                int replacement_index;
                long int max_LRU_count;

                for(int i = 0; i < (num_ways * num_sets); i++)  // MISS occurred, looking for open (invalid) cache slot
                {
                    if(request_serviced == 1)
                        break;

                    if(request_index == cache_array[i].index && (cache_array[i].valid == 0))
                    {
                        num_misses++;
                        cache_array[i].valid = 1;
                        cache_array[i].dirty = 1;
                        cache_array[i].tag = request_tag;
                        cache_array[i].LRU_count = 0;
                        request_serviced = 1;
                    }
                }

                for(int i = 0; i < (num_ways * num_sets); i++)  // MISS occurred, eviction required... Looking for LRU victim
                {
                    if(request_serviced == 1)
                        break;

                    if(request_index == cache_array[i].index && cache_array[i].cache_block == 1)        // if the first cache block (first way) in the set
                    {
                        replacement_index = i;
                        max_LRU_count = cache_array[i].LRU_count;
                    }

                    else if(request_index == cache_array[i].index)                                      // comparing start point to find LRU cache block
                    {
                        if(cache_array[i].LRU_count > max_LRU_count)
                        {
                            max_LRU_count = cache_array[i].LRU_count;
                            replacement_index = i;
                        }
                    }
                }

                // Do replacement based on found LRU block

                for(int k = 0; k < 1; k++)
                {
                    if(request_serviced == 1)
                        break;

                    num_misses++;
                    num_evictions++;
                    cache_array[replacement_index].tag = request_tag;
                    cache_array[replacement_index].LRU_count = 0;
                    request_serviced = 1;
                    if(cache_array[replacement_index].dirty == 1)
                        num_writebacks++;
                    else                                        // dirty was "0" so set it
                        cache_array[replacement_index].dirty = 1;
                }
            }

//--------------------------------------------------------- LRU INVALIDATE -----------------------------------------------------------
            else if(strcmp(access_type, "2") == 0)
            {
                num_invalidates++;
                num_accesses++;
                for(int i = 0; i < (num_ways * num_sets); i++)  // looking for hit
                {
                    if(request_index == cache_array[i].index && request_tag == cache_array[i].tag && (cache_array[i].valid == 1))
                    {
                        num_evictions++;
                        cache_array[i].valid = 0;
                        if(cache_array[i].dirty == 1)
                        {
                            cache_array[i].dirty = 0;
                            num_writebacks++;
                        }
                    }
                }
            }
        }               // End of true LRU


        else if(replacement_policy == 1)                       // Since not true LRU, 1-bit LRU policy (MRU)
        {
            // check replacement policy and access type for current memory request and service it.
            request_serviced = 0;                              // clear flag before servicing request.

//------------------------------------------------------------- MRU READ ---------------------------------------------------------------
            if(strcmp(access_type, "0") == 0)
            {
                num_reads++;
                num_accesses++;
                for(int i = 0; i < (num_ways * num_sets); i++) // checking for hit
                {
                    if(request_serviced == 1)
                        break;

                    if(request_index == cache_array[i].index && request_tag == cache_array[i].tag && (cache_array[i].valid == 1))
                    {
                        num_hits++;
                        cache_array[i].MRU = 1;
                        request_serviced =1;
                    }
                }

                for(int i = 0; i < (num_ways * num_sets); i++)  // Miss, looking for open cache slot (invalid block in set)
                {
                    if(request_serviced == 1)
                        break;

                    if(request_index == cache_array[i].index && (cache_array[i].valid == 0))
                    {
                        num_misses++;
                        cache_array[i].valid =1;
                        cache_array[i].dirty = 0;
                        cache_array[i].tag = request_tag;
                        cache_array[i].MRU =1;
                        request_serviced = 1;
                    }
                }

                for(int i = 0; i < (num_ways * num_sets); i++)  // Miss, looking for MRU replacement victim (MRU = 0)
                {
                    if(request_serviced == 1)
                        break;
                    if(request_index == cache_array[i].index && (cache_array[i].valid == 1) && (cache_array[i].MRU == 0))
                    {
                        cache_array[i].tag = request_tag;
                        cache_array[i].MRU = 1;
                        num_evictions++;
                        num_misses++;
                        request_serviced = 1;
                        if(cache_array[i].dirty == 1)
                        {
                            num_writebacks++;
                            cache_array[i].dirty = 0;
                        }
                    }
                }

                int replacement_index;

                for(int i = 0; i < (num_ways * num_sets); i++)  // Miss, All MRU's in set are 1
                {
                    if(request_serviced == 1)
                        break;
                    if(request_index == cache_array[i].index && cache_array[i].MRU == 1 && cache_array[i].valid == 1)            // reset all MRUs in set to 0
                        cache_array[i].MRU = 0;
                    if(request_index == cache_array[i].index && cache_array[i].cache_block == 1)    // selects first cache block in set to be victim
                        replacement_index = i;
                }

                // Do the replacement
                for(int k = 0; k < 1; k++)
                {


                    if(request_serviced == 1)
                        break;
                    cache_array[replacement_index].tag = request_tag;
                    cache_array[replacement_index].MRU = 1;
                    num_evictions++;
                    num_misses++;
                    request_serviced = 1;
                    if(cache_array[replacement_index].dirty == 1)
                    {
                        num_writebacks++;
                        cache_array[replacement_index].dirty = 0;
                    }
                }
            }

//------------------------------------------------------------ MRU WRITE --------------------------------------------------------------
            else if(strcmp(access_type, "1") == 0)
            {
                num_writes++;
                num_accesses++;
                for(int i = 0; i < (num_ways * num_sets); i++)  // Checking for hit
                {
                    if(request_serviced == 1)
                        break;

                    if(request_index == cache_array[i].index && request_tag == cache_array[i].tag && (cache_array[i].valid == 1))
                    {
                        num_hits++;
                        cache_array[i].MRU = 1;
                        request_serviced = 1;
                        cache_array[i].dirty = 1;
                    }
                }

                for(int i = 0; i < (num_ways * num_sets); i++)  // miss, looking for open slot (MRU = 0)
                {
                    if(request_serviced == 1)
                        break;

                    if(request_index == cache_array[i].index && cache_array[i].valid == 0)
                    {
                        num_misses++;
                        cache_array[i].valid = 1;
                        cache_array[i].dirty = 1;
                        cache_array[i].tag = request_tag;
                        cache_array[i].MRU = 1;
                        request_serviced = 1;
                    }
                }

                for(int i = 0; i < (num_ways * num_sets); i++)  // miss (and no open slots), looking for replacement (MRU = 0)
                {
                    if(request_serviced == 1)
                        break;
                    if(request_index == cache_array[i].index && (cache_array[i].valid == 1) && cache_array[i].MRU == 0)
                    {
                       cache_array[i].tag = request_tag;
                       cache_array[i].MRU = 1;
                       num_evictions++;
                       num_misses++;
                       request_serviced = 1;
                       if(cache_array[i].dirty == 1)
                            num_writebacks++;
                       else
                            cache_array[i].dirty = 1;
                    }
                }

                int replacement_index;
                for(int i = 0; i < (num_ways * num_sets); i++)  // miss (and all MRUs in set are 1)
                {
                    if(request_serviced == 1)
                        break;
                    if(request_index == cache_array[i].index && cache_array[i].MRU == 1)
                        cache_array[i].MRU = 0;
                    if(request_index == cache_array[i].index && cache_array[i].cache_block == 1)
                        replacement_index = i;
                }

                // Do replacement
                for(int k = 0; k < 1; k++)
                {
                    if(request_serviced == 1)
                        break;
                    cache_array[replacement_index].tag = request_tag;
                    cache_array[replacement_index].MRU = 1;
                    num_evictions++;
                    num_misses++;
                    request_serviced = 1;
                    if(cache_array[replacement_index].dirty == 1)
                        num_writebacks++;
                    else
                        cache_array[replacement_index].dirty = 1;
                }
            }
//--------------------------------------------------------- MRU INVALIDATE -----------------------------------------------------------
            else if(strcmp(access_type, "2") == 0)
            {
                num_invalidates++;
                num_accesses++;
                for(int i = 0; i < (num_ways * num_sets); i++)  // looking for hit
                {
                    if(request_index == cache_array[i].index && request_tag == cache_array[i].tag && (cache_array[i].valid == 1))
                    {
                        num_evictions++;
                        cache_array[i].valid = 0;
                        if(cache_array[i].dirty == 1)
                        {
                            cache_array[i].dirty = 0;
                            num_writebacks++;
                        }
                    }
                }
            }
        }              // End of 1-bit LRU
    }                  // End of request service, check another request.

fclose(fp);            // Close trace file since finished with it


    // Display cache simulation results
    printf("\n\n");
    printf("-----CACHE SIMULATION RESULTS-----\n");
    printf("Total number of cache accesses: %d\n", num_accesses);
    printf("         Number of cache reads: %d\n", num_reads);
    printf("        Number of cache writes: %d\n", num_writes);
    printf("   Number of cache invalidates: %d\n", num_invalidates);
    printf("          Number of cache hits: %.0f\n", num_hits);
    printf("        Number of cache misses: %.0f\n", num_misses);
    printf("               Cache hit ratio: %.2f%%\n", num_hits / num_accesses * 100);
    printf("              Cache miss ratio: %.2f%%\n", num_misses / num_accesses * 100);
    printf("     Number of cache evictions: %d\n", num_evictions);
    printf("    Number of cache writebacks: %d\n", num_writebacks);
    printf("\n");


    return 0;
}
