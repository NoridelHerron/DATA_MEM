----------------------------------------------------------------------------------
-- Noridel Herron
-- reusable_function.vhd
-- reusable_function for Testbenches
-- 5/5/2025
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package reusable_function is
    -- Converts std_logic_vector to hexadecimal string
    function to_hexstring(sig: std_logic_vector) return string;
end reusable_function;
