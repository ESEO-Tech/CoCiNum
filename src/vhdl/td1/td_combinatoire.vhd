library ieee;
use ieee.std_logic_1164.all;

entity td_combinatoire is
    port(
        switches_i : 
        disp_segments_n_o : 
        disp_select_n_o : 
    );
end td_combinatoire;


architecture Behavioral of td_combinatoire is

begin

--Selection d'un seul afficheur 7 segments
disp_select_n_o <= "1110";


--------------------------------------------------
--	Decodeur 7 segments			--
--------------------------------------------------

-----APPROCHE 1 : Affectation simple-----

----segment a
disp_segments_n_o(0) <= (not switches_i(3) and switches_i(2) and not switches_i(1) and not switches_i(0)) or
                        (not switches_i(3) and not switches_i(2) and not switches_i(1) and switches_i(0)) or
                        (switches_i(3) and switches_i(2) and not switches_i(1) and switches_i(0)) or
                        (switches_i(3) and not switches_i(2) and switches_i(1) and switches_i(0));
----segment b
disp_segments_n_o(1) <= (switches_i(3) and switches_i(2) and not switches_i(1) and not switches_i(0)) or
                        (not switches_i(3) and switches_i(2) and not switches_i(1) and switches_i(0)) or
                        (switches_i(3) and switches_i(1) and switches_i(0)) or
                        (switches_i(2) and switches_i(1) and not switches_i(0));
----segment c
disp_segments_n_o(2) <= (switches_i(3) and switches_i(2) and not switches_i(1) and not switches_i(0)) or
                        (not switches_i(3) and not switches_i(2) and switches_i(1) and not switches_i(0)) or
                        (switches_i(3) and switches_i(2) and switches_i(1));
----segment d
disp_segments_n_o(3) <= (not switches_i(3) and switches_i(2) and not switches_i(1) and not switches_i(0)) or
                        (not switches_i(3) and not switches_i(2) and not switches_i(1) and switches_i(0)) or
                        (switches_i(3) and not switches_i(2) and switches_i(1) and not switches_i(0)) or
                        (switches_i(2) and switches_i(1) and switches_i(0));
----segment e
disp_segments_n_o(4) <= (not switches_i(3) and switches_i(2) and not switches_i(1)) or
                        (not switches_i(2) and not switches_i(1) and switches_i(0)) or
                        (not switches_i(3) and switches_i(0));
----segment f
disp_segments_n_o(5) <= (switches_i(3) and switches_i(2) and not switches_i(1) and switches_i(0)) or
                        ((not switches_i(3) and not switches_i(2)) and (switches_i(1) or switches_i(0))) or                 
                        (not switches_i(3) and switches_i(1) and switches_i(0));
----segment g
--disp_segments_n_o(6) <= ??? or
--                        ??? or
--                        ???;


-----APPROCHE 2 : Affectation conditionnelle-----
                     --gfedcba                     
--disp_segments_n_o <=  "1000000" when (switches_i = "0000") else  -- 0
--                      "1111001" when (switches_i = "0001") else  -- 1
--                      "0100100" when (switches_i = "???") else  -- 2
--                      "0110000" when (switches_i = "0011") else  -- 3
--                      "0011001" when (switches_i = "0100") else  -- 4
--                      "0010010" when (switches_i = "0101") else  -- 5
--                      "0000010" when (switches_i = "0110") else  -- 6
--                      "???" 	when (switches_i = "0111") else  -- 7
--                      "0000000" when (switches_i = "1000") else  -- 8
--                      "0010000" when (switches_i = "1001") else  -- 9
--                      "0001000" when (switches_i = "1010") else  -- A
--                      "0000011" when (switches_i = "1011") else  -- B
--                      "1000110" when (switches_i = "1100") else  -- C
--                      "0100001" when (switches_i = "1101") else  -- D
--                      "0000110" when (switches_i = "1110") else  -- E
--                      "0001110";                                 -- F
   
         
-----APPROCHE 2 : Affectation concurrente sélective-----
--with switches_i select
--                     --gfedcba
--disp_segments_n_o <=  "1000000" when "0000",  -- 0
--                      "1111001" when "0001",  -- 1
--                      "0100100" when "???",  -- 2
--                      "0110000" when "0011",  -- 3
--                      "0011001" when "0100",  -- 4
--                      "0010010" when "0101",  -- 5
--                      "0000010" when "0110",  -- 6
--                      "???" when "0111",  -- 7
--                      "0000000" when "1000",  -- 8
--                      "0010000" when "1001",  -- 9
--                      "0001000" when "1010",  -- A
--                      "0000011" when "1011",  -- B
--                      "1000110" when "1100",  -- C
--                      "0100001" when "1101",  -- D
--                      "0000110" when "1110",  -- E
--                      "0001110" when "1111";  -- F



end Behavioral;
