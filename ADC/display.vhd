library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL; 

entity display is 
    Port (  
        -- std
        clk : in STD_LOGIC; 
        rst : in STD_LOGIC; 
        -- digits
        d0 : in STD_LOGIC_VECTOR(3 downto 0); 
        d1 : in STD_LOGIC_VECTOR(3 downto 0); 
        d2 : in STD_LOGIC_VECTOR(3 downto 0); 
        d3 : in STD_LOGIC_VECTOR(3 downto 0); 
        -- anode = which digit
        shown_digit : out STD_LOGIC_VECTOR(3 downto 0); 
        -- leds per digit
        seg : out STD_LOGIC_VECTOR(6 downto 0) 
    ); 
end display; 
 
architecture Behavioral of display is 
    -- refresh needed for mux
    signal refresh : unsigned(19 downto 0) := (others => '0'); 
    -- current digit
    signal d : STD_LOGIC_VECTOR(3 downto 0); 
    -- select digit
    signal ds : unsigned(1 downto 0) := (others => '0'); 
begin 

    process(clk, reset) 
    begin 
        if reset = '1' then 
            refresh <= (others => '0'); 
        elsif rising_edge(clk) then 
            refresh <= refresh + 1; 
        end if; 
    end process; 
    ds <= refresh(19 downto 18); 

    process(ds, d0, d1, d2, d3) 
    begin 
        case digit_select is 
            when "00" =>  
                shown_digit <= "1110"; 
                d <= d0; 
            when "01" =>  
                shown_digit <= "1101"; 
                d <= d1; 
            when "10" =>  
                shown_digit <= "1011"; 
                d <= d2; 
            when "11" =>  
                shown_digit <= "0111"; 
                d <= d3; 
            when others => 
                shown_digit <= "1111"; 
                d <= "0000"; 
        end case; 
    end process; 

    process(d) 

    begin 
        case d is 
                                       -- 0 = on 1 = off 
            when "0000" => segments <= "1000000"; -- 0 
            when "0001" => segments <= "1111001"; -- 1 
            when "0010" => segments <= "0100100"; -- 2 
            when "0011" => segments <= "0110000"; -- 3 
            when "0100" => segments <= "0011001"; -- 4 
            when "0101" => segments <= "0010010"; -- 5 
            when "0110" => segments <= "0000010"; -- 6 
            when "0111" => segments <= "1111000"; -- 7 
            when "1000" => segments <= "0000000"; -- 8 
            when "1001" => segments <= "0010000"; -- 9 
            when "1010" => segments <= "0001000"; -- A 
            when "1011" => segments <= "0000011"; -- b (lower case)
            when "1100" => segments <= "1000110"; -- C 
            when "1101" => segments <= "0100001"; -- d 
            when "1110" => segments <= "0000110"; -- E 
            when "1111" => segments <= "0001110"; -- F 
            when others => segments <= "1111111"; 
        end case; 
    end process; 
end Behavioral; 