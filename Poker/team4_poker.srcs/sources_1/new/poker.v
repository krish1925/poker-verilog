`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2024 01:04:47 PM
// Design Name: 
// Module Name: poker
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module poker(
    //Outputs
    playerout,
    
    //Inputs
    clk,
    valid
    );
    output[15:0] playerout;
    //reg[7:0] out;
    
    input        clk;
    input valid;



    reg checkflush;
    



    reg [51:0] card_array;
    integer p1 [1:0];
    integer p2 [1:0];
    integer currp [1:0];
    reg player;
    
    integer community [2:0];
    integer rndStart = 0;
    
    integer counter;
    
    integer seed;
    
    function integer randCard;
        input integer s;
        input [51:0] card_array;
        integer card, count;
        begin
            count = 0;
            //card = $random(s) % 52; // Pick a random card
            card = s % 52;
            while ((card_array[card] == 1) && (count < 52)) begin
                card = s % 52; // Pick another if already chosen
                count = count + 1;
            end
            if (count < 52) begin
                card_array[card] = 1; // Mark card as chosen
            end
            else begin
                card = 1; // Indicate failure to find a unique card
            end
            randCard = card;
        end
    endfunction      
    
    function [7:0] cardConvert;
        input integer card;
        integer value, suit;
        begin
            value = card % 13;
            suit = card / 13;
            cardConvert = {value[3:0], suit[3:0]};
        end
    endfunction
    

    // Function to sort cards in ascending order
    function void sortcards;
            input output integer cards[6:0];
            integer i, j, temp;

            begin
                // Sort cards in ascending order
                for (i = 0; i < 4; i = i + 1) begin
                    for (j = 0; j < 4 - i; j = j + 1) begin
                        if (cards[j] > cards[j + 1]) begin
                            temp = cards[j];
                            cards[j] = cards[j + 1];
                            cards[j + 1] = temp;
                        end
                    end
                end
            end
    endfunction
    

  // function to check if there is a royal flush return 20 if not found else return 12(highest card)
    function integer checkroyalflush;
        input integer [1:0] player;
        input integer [2:0] community;
        integer straightflush;
        integer i;

        begin
            // Call checkstraightflush function
            straightflush = checkstraightflush(player, community);

            // Check if it's a straight flush and if any card is an ace (card % 13 = 12)
            if (straightflush != 20) begin
                for (i = 0; i < 5; i = i + 1) begin
                    if ((player[i] % 13) == 12) begin
                        royalflush = 12; // Royal flush found
                        return;
                    end
                end
            end

            royalflush = 20; // Not a royal flush
        end
    endfunction

    //function to check if there is a straight flush
    function integer checkstraightflush;
        input integer [1:0] player;
        input integer [2:0] community;
        integer straight;
        integer flush;

        begin
            // Call checkstraight function
            straight = checkstraight(player, community);
            // Call checkflush function
            flush = checkflush(player, community);

            // Check if it's both a straight and a flush
            if (straight != 20 && flush != 20) begin
                checkstraightflush = straight; // Straight flush found
            end 
            else begin
                checkstraightflush = 20; // Not a straight flush
            end
        end
    endfunction

    // Function to check if there is a 4 of a kind 20 if not found, returns value of 4 of a kind
    function integer check4ofakind;
        input integer [1:0] player;
        input integer [2:0] community;
        integer cards[6:0];
        integer i;

        begin
            // Merge player and community cards
            cards[0] = player[0] % 13;
            cards[1] = player[1] % 13;
            cards[2] = community[0] % 13;
            cards[3] = community[1] % 13;
            cards[4] = community[2] % 13;

            // Sort cards
            sortcards(cards);

            // Check if last 4 cards are equal
            if ((cards[1] == cards[2]) && (cards[2] == cards[3]) && (cards[3] == cards[4])) begin
                check4ofakind = cards[2]; // 4 of a kind found
                return;
            end

            // Check if first 4 cards are equal
            if ((cards[0] == cards[1]) && (cards[1] == cards[2]) && (cards[2] == cards[3])) begin
                check4ofakind = cards[2]; // 4 of a kind found
                return;
            end
            check4ofakind = 20; // No 4 of a kind
        end
    endfunction


    // Function to check if there is a full house, returns the low 2 cards value else 20
    function integer checkfullhouse;
        input integer [1:0] player;
        input integer [2:0] community;
        integer cards[6:0];
        integer i;

        begin
            // Merge player and community cards
            cards[0] = player[0] % 13;
            cards[1] = player[1] % 13;
            cards[2] = community[0] % 13;
            cards[3] = community[1] % 13;
            cards[4] = community[2] % 13;

            // Sort cards
            sortcards(cards);

            // Check if first three cards and then the other two cards are equal
            if ((cards[0] == cards[1]) && (cards[1] == cards[2]) && (cards[3] == cards[4])) begin
                checkfullhouse = cards[3]; // Full house found
                return;
            end

            // Check if first two cards and then the last three cards are equal
            if ((cards[0] == cards[1]) && (cards[2] == cards[3]) && (cards[3] == cards[4])) begin
                checkfullhouse = cards[1]; // Full house found
                return;
            end

            checkfullhouse = 0; // No full house
        end
    endfunction


    //function to check for a flush
    function integer checkflush;
        input integer [1:0] player;
        input integer [2:0] community;
        integer suit[4:0];
        integer i;
        begin
            suit[0] = player[0] / 13;
            suit[1] = player[1] / 13;
            suit[2] = community[0]/ 13;
            suit[3] = community[1]/ 13;
            suit[4] = community[2]/ 13;
            // Check for flush
            if ((suit[0] == suit[1]) && (suit[1] == suit[2]) && (suit[2] == suit[3]) && (suit[3] == suit[4])) begin
                checkflush = highcardnum(player,community); // Flush found
            end else begin
                checkflush = 20; // No flush
            end
        end
    endfunction

    //function to check if there is a straight, 20 if no straight found, else return highest value
    function integer checkstraight;
        input integer [1:0] player;
        input integer [2:0] community;
        integer cards[6:0];
        integer i;

        begin
            // Merge player and community cards
            cards[0] = player[0] % 13;
            cards[1] = player[1] % 13;
            cards[2] = community[0] % 13;
            cards[3] = community[1] % 13;
            cards[4] = community[2] % 13;

            // Sort cards
            sortcards(cards);

            // Check if cards are in ascending order
            for (i = 0; i < 4; i = i + 1) begin
                if (cards[i] + 1 != cards[i + 1]) begin
                    checkstraight = 20; // Not in ascending order
                    return;
                end
            end

            checkstraight = cards[4]; // In ascending order
        end
    endfunction


    // Function to check if there is a three of a kind, return card value if found, else 20
    function integer checkthreeofakind;
        input integer [1:0] player;
        input integer [2:0] community;
        integer cards[6:0];
        integer i;

        begin
            // Merge player and community cards
            cards[0] = player[0] % 13;
            cards[1] = player[1] % 13;
            cards[2] = community[0] % 13;
            cards[3] = community[1] % 13;
            cards[4] = community[2] % 13;

            // Sort cards
            sortcards(cards);

            // Check if first three cards are equal
            if ((cards[0] == cards[1]) && (cards[1] == cards[2])) begin
                checkthreeofakind = cards[2]; // Three of a kind found
                return;
            end
            // Check if middle three cards are equal
            if ((cards[1] == cards[2]) && (cards[2] == cards[3])) begin
                checkthreeofakind = cards[2]; // Three of a kind found
                return;
            end
            // Check if end three cards are equal
            if ((cards[2] == cards[3]) && (cards[3] == cards[4])) begin
                checkthreeofakind = cards[2]; // Three of a kind found
                return;
            end
            checkthreeofakind = 20; // No three of a kind
        end
    endfunction

        // Function to check if there is a two pair returns highest value of that pair, else 20
    function integer checktwopair;
        input integer [1:0] player;
        input integer [2:0] community;
        integer cards[6:0];
        integer high1;
        integer high2;
        integer i;

        begin
            // Merge player and community cards
            cards[0] = player[0] % 13;
            cards[1] = player[1] % 13;
            cards[2] = community[0] % 13;
            cards[3] = community[1] % 13;
            cards[4] = community[2] % 13;

            // Sort cards
            sortcards(cards);

            // Check if the first pair exists
            if ((cards[0] == cards[1]) || (cards[1] == cards[2])) begin
                high1 = cards[1];
                // Check if there's a second pair
                 if ((cards[0] == cards[1] && (cards[2] == cards[3] || cards[3] == cards[4])) ||
                    (cards[1] == cards[2] && cards[3] == cards[4])) begin
                    high2 = cards[3];
                    if (high1 > high2)
                        checktwopair = high1; // Two pair found
                    else
                        checktwopair = high2;
                    return;

                end
            end

            checktwopair = 20; // No two pair
        end
    endfunction

    // Function to check if there is a two of a kind. 20 if not found
    function integer checktwoofakind;
        input integer [1:0] player;
        input integer [2:0] community;
        integer cards[6:0];
        integer i;

        begin
            // Merge player and community cards
            cards[0] = player[0] % 13;
            cards[1] = player[1] % 13;
            cards[2] = community[0] % 13;
            cards[3] = community[1] % 13;
            cards[4] = community[2] % 13;

            // Sort cards
            sortcards(cards);

            // Check adjacent cards for two of a kind
            for (i = 0; i < 4; i = i + 1) begin
                if (cards[i] == cards[i + 1]) begin
                    checktwoofakind = cards[i]; // Two of a kind found
                    return;
                end
            end

            checktwoofakind = 20; // No two of a kind
        end
    endfunction


    function integer highcardnum;
        input integer [1:0] player;
        input integer [2:0] community;
        integer cards[6:0];
        integer max_card;
        integer i;

        begin
            // Merge player and community cards
            cards[0] = player[0] % 13;
            cards[1] = player[1] % 13;
            cards[2] = community[0] % 13;
            cards[3] = community[1] % 13;
            cards[4] = community[2] % 13;

            // Initialize max_card with the first card value
            max_card = cards[0];

            // Loop through the cards to find the highest value
            for (i = 1; i < 5; i = i + 1) begin
                if (cards[i] > max_card) begin
                    max_card = cards[i];
                end
            end

            // Return the highest card value
            highcardnum = max_card;
        end
    endfunction












     
    assign playerout = {cardConvert(currp[0]), cardConvert(currp[1])};
    
    initial begin
        card_array = 0;
        seed = 12345;
        counter = 0;
        player = 0;
    end

    
    always @ (posedge valid) begin
        if (rndStart == 5)
                rndStart = 0;
        if (rndStart != 0)
                    rndStart = rndStart + 1;
        if(rndStart == 0) begin
            p1[0] = randCard(counter, card_array);
            p1[1] = randCard(counter + 1, card_array);
            
            p2[0] = randCard(counter + 2, card_array);
            p2[1] = randCard(counter + 3, card_array);
            
            community[0] = randCard(counter + 4, card_array);
            community[1] = randCard(counter + 5, card_array);
            community[2] = randCard(counter + 6, card_array);
            //community[3] = randCard(counter + 7, card_array);
           //community[4] = randCard(counter + 8, card_array);
            rndStart = 1;
        end
        
        if (player) begin 
            currp[0] = p1[0];
            currp[1] = p1[1];
        end 
        else begin
            currp[0] = p2[0];
            currp[1] = p2[1];
        end
        
        player = ~player;
         if(rndStart == 5) begin
        // Winner determination logic
        integer winner_value = 0;
        integer p1_hand_value = 0;
        integer p2_hand_value = 0;
        
        // Check royal flush first
        p1_hand_value = checkroyalflush(p1, community);
        p2_hand_value = checkroyalflush(p2, community);
        
        if (p1_hand_value != 20 || p2_hand_value != 20) begin
            if (p1_hand_value == 20) winner_value = 2;
            else if (p2_hand_value == 20) winner_value = 1;
            else if (p1_hand_value > p2_hand_value) winner_value = 1;
            else if (p1_hand_value < p2_hand_value) winner_value = 2;
            else winner_value = $random % 2 == 0 ? 1 : 2; // Randomly assign if values are equal
        end
        else begin
            // Check straight flush
            p1_hand_value = checkstraightflush(p1, community);
            p2_hand_value = checkstraightflush(p2, community);
            
            if (p1_hand_value != 20 || p2_hand_value != 20) begin
                if (p1_hand_value == 20) winner_value = 2;
                else if (p2_hand_value == 20) winner_value = 1;
                else if (p1_hand_value > p2_hand_value) winner_value = 1;
                else if (p1_hand_value < p2_hand_value) winner_value = 2;
                else winner_value = $random % 2 == 0 ? 1 : 2; // Randomly assign if values are equal
            end
            else begin
                // Add similar checks for other hands...
            end
        end
        
        // Update winner output
        winner = winner_value;
        end
        
       end
       
       always @ (posedge clk) begin
        counter = counter + 1;
        if (counter + 10 < 0) begin
            counter = 0;
        end
       end
       
endmodule
