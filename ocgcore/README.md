#Ygopro script engine.

##Exposed Functions

These three function need to be provided to the core so it can get card and database information.
- `void set_script_reader(script_reader f);` : Interface provided returns scripts based on number that corrosponses to a lua file, send in a string. 
    
- `void set_card_reader(card_reader f);` : Inferface provided function that provides database information from the `data` table of `cards.cdb`.

- `void set_message_handler(message_handler f);` : Interface provided function that handles errors

These functions create the game itself and then manipulate it.
- `ptr create_duel(uint32 seed);` : Create a the instance of the duel using a random number.
    
- `void start_duel(ptr pduel, int32 options);` : Starts the duel
- `void end_duel(ptr pduel);` : ends the duel
- `void set_player_info(ptr pduel, int32 playerid, int32 lp, int32 startcount, int32 drawcount);` sets the duel up
- `void get_log_message(ptr pduel, byte* buf);`
- `int32 get_message(ptr pduel, byte* buf);`
- `int32 process(ptr pduel);` : do a game tick
- `void new_card(ptr pduel, uint32 code, uint8 owner, uint8 playerid, uint8 location, uint8 sequence, uint8 position);` : add a card to the duel state.
- `void new_tag_card(ptr pduel, uint32 code, uint8 owner, uint8 location);` : add a new card to the tag pool.
- `int32 query_card(ptr pduel, uint8 playerid, uint8 location, uint8 sequence, int32 query_flag, byte* buf, int32 use_cache);` : find out about a card in a specific spot.
- `int32 query_field_count(ptr pduel, uint8 playerid, uint8 location);`Get the number of cards in a specific field/zone.
- `int32 query_field_card(ptr pduel, uint8 playerid, uint8 location, int32 query_flag, byte* buf, int32 use_cache);`
- `int32 query_field_info(ptr pduel, byte* buf);`
- `void set_responsei(ptr pduel, int32 value);`
- `void set_responseb(ptr pduel, byte* buf);`
- `int32 preload_script(ptr pduel, char* script, int32 len);`
